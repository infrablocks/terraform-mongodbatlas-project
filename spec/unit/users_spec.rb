# frozen_string_literal: true

require 'spec_helper'

describe 'users' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:organization_id) do
    var(role: :root, name: 'organization_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create any database users' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_database_user'))
    end
  end

  describe 'when no database users provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.database_users = []
      end
    end

    it 'does not create any database users' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_database_user'))
    end
  end

  describe 'when one database user provided' do
    before(:context) do
      @database_user = {
        username: 'user-1',
        password: 'password-1',
        roles: [
          {
            role_name: 'readAnyDatabase',
            database_name: 'admin',
            collection_name: 'stuff'
          },
          {
            role_name: 'readWrite',
            database_name: 'specific',
            collection_name: 'things'
          }
        ],
        labels: {
          important: 'thing',
          something: 'else'
        },
        scopes: []
      }
      @plan = plan(role: :root) do |vars|
        vars.database_users = [@database_user]
      end
    end

    it 'creates a database user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .once)
    end

    it 'uses the provided username' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:username, 'user-1'))
    end

    it 'uses the provided password' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:password, matching('password-1')))
    end

    it 'uses an auth database name of "admin"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:auth_database_name, 'admin'))
    end

    it 'adds each of the roles to the user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :roles,
                containing_exactly(
                  a_hash_including(
                    role_name: 'readAnyDatabase',
                    database_name: 'admin',
                    collection_name: 'stuff'
                  ),
                  a_hash_including(
                    role_name: 'readWrite',
                    database_name: 'specific',
                    collection_name: 'things'
                  )
                )))
    end

    it 'adds each of the provided labels to the user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'important',
                    value: 'thing'
                  ),
                  a_hash_including(
                    key: 'something',
                    value: 'else'
                  )
                )))
    end

    it 'adds labels for component and deployment identifier to the user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'Component',
                    value: component
                  ),
                  a_hash_including(
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier
                  )
                )))
    end

    it 'adds each of the scopes to the user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:scopes, a_nil_value))
    end
  end

  describe 'when many database users provided' do
    before(:context) do
      @database_user1 = {
        username: 'user-1',
        password: 'password-1',
        roles: [
          {
            role_name: 'readAnyDatabase',
            database_name: 'admin',
            collection_name: 'stuff'
          },
          {
            role_name: 'readWrite',
            database_name: 'specific',
            collection_name: 'things'
          }
        ],
        labels: {
          important: 'thing',
          something: 'else'
        },
        scopes: []
      }
      @database_user2 = {
        username: 'user-2',
        password: 'password-2',
        roles: [
          {
            role_name: 'dbAdmin',
            database_name: 'specific',
            collection_name: 'things'
          }
        ],
        labels: {},
        scopes: [
          {
            type: 'CLUSTER',
            name: 'some-cluster'
          }
        ]
      }
      @plan = plan(role: :root) do |vars|
        vars.database_users = [@database_user1, @database_user2]
      end
    end

    it 'creates a database user for each provided' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .twice)
    end

    it 'uses the provided username for each user' do
      [@database_user1, @database_user2].each do |user|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(:username, user[:username]))
      end
    end

    it 'uses the provided password' do
      [@database_user1, @database_user2].each do |user|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(:password, matching(user[:password])))
      end
    end

    it 'uses an auth database name of "admin"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:auth_database_name, 'admin')
              .twice)
    end

    it 'adds each of the roles to the user' do
      [@database_user1, @database_user2].each do |user|
        role_matchers = user[:roles].collect do |role|
          a_hash_including(role)
        end
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :roles, containing_exactly(*role_matchers)))
      end
    end

    it 'adds each of the provided labels to the user' do
      [@database_user1, @database_user2].each do |user|
        label_matchers = user[:labels].collect do |key, value|
          a_hash_including(
            key: key.to_s,
            value:
          )
        end
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :labels, a_collection_including(*label_matchers)))
      end
    end

    it 'adds labels for component and deployment identifier to the user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'Component',
                    value: component
                  ),
                  a_hash_including(
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier
                  )
                )
              )
              .twice)
    end

    it 'adds each of the scopes to the user' do
      [@database_user1, @database_user2].each do |user|
        scope_matchers = user[:scopes].collect do |scope|
          a_hash_including(scope)
        end
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :scopes, a_collection_including(*scope_matchers)))
      end
    end
  end
end
