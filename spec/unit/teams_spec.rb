# frozen_string_literal: true

require 'spec_helper'

describe 'teams' do
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

    it 'does not create any teams' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_team'))
    end
  end

  describe 'when no dedicated teams provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.dedicated_teams = []
      end
    end

    it 'does not create any teams' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_team'))
    end
  end

  describe 'when one dedicated team provided' do
    before(:context) do
      @dedicated_team = {
        name_suffix: 'developers',
        usernames: %w[
          toby+user1@go-atomic.io
          toby+user2@go-atomic.io
        ],
        role_names: %w[
          GROUP_DATA_ACCESS_ADMIN
          GROUP_CLUSTER_MANAGER
        ]
      }
      @plan = plan(role: :root) do |vars|
        vars.dedicated_teams = [@dedicated_team]
      end
    end

    it 'creates a team' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .once)
    end

    it 'derives a name from the component, deployment identifier and ' \
       'name suffix' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .with_attribute_value(
                :name, "#{component}-#{deployment_identifier}-developers"
              ))
    end

    it 'uses the provided organization ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .with_attribute_value(:org_id, organization_id))
    end

    it 'uses the provided usernames' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .with_attribute_value(
                :usernames,
                containing_exactly(
                  'toby+user1@go-atomic.io',
                  'toby+user2@go-atomic.io'
                )
              ))
    end
  end

  describe 'when many dedicated teams provided' do
    before(:context) do
      @dedicated_team1 = {
        name_suffix: 'developers',
        usernames: %w[
          toby+user1@go-atomic.io
          toby+user2@go-atomic.io
        ],
        role_names: %w[
          GROUP_DATA_ACCESS_ADMIN
          GROUP_CLUSTER_MANAGER
        ]
      }
      @dedicated_team2 = {
        name_suffix: 'admins',
        usernames: ['toby+user3@go-atomic.io'],
        role_names: ['GROUP_OWNER']
      }
      @plan = plan(role: :root) do |vars|
        vars.dedicated_teams = [@dedicated_team1, @dedicated_team2]
      end
    end

    it 'creates a team for each provided dedicated team' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .twice)
    end

    it 'derives a name from the component, deployment identifier and ' \
       'name suffix' do
      %w[developers admins].each do |name_suffix|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_team')
                .with_attribute_value(
                  :name, "#{component}-#{deployment_identifier}-#{name_suffix}"
                ))
      end
    end

    it 'uses the provided organization ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_team')
              .with_attribute_value(:org_id, organization_id)
              .twice)
    end

    it 'uses the provided usernames' do
      [
        %w[toby+user1@go-atomic.io toby+user2@go-atomic.io],
        ['toby+user3@go-atomic.io']
      ].each do |usernames|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_team')
                .with_attribute_value(
                  :usernames, containing_exactly(*usernames)
                ))
      end
    end
  end
end
