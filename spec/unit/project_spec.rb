# frozen_string_literal: true

require 'spec_helper'

describe 'project' do
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

    it 'creates a project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .once)
    end

    it 'includes the component and deployment identifier in the name' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(
                :name, including(component)
                         .and(including(deployment_identifier))
              ))
    end

    it 'uses the provided organization ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(:org_id, organization_id))
    end

    it 'does not add any teams to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(:teams, a_nil_value))
    end
  end

  describe 'when no existing teams provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.existing_teams = []
      end
    end

    it 'does not add any teams to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(:teams, a_nil_value))
    end
  end

  describe 'when one existing team provided' do
    before(:context) do
      component = var(role: :root, name: 'component')
      deployment_identifier = var(role: :root, name: 'deployment_identifier')

      existing_teams = output(role: :prerequisites, name: 'existing_teams')
      existing_team_name = "#{component}-#{deployment_identifier}-support"

      @existing_team = {
        id: existing_teams[existing_team_name.to_sym][:id],
        name: existing_team_name,
        usernames: ['toby+user1@go-atomic.io'],
        role_names: ['GROUP_DATA_ACCESS_READ_ONLY']
      }
      @plan = plan(role: :root) do |vars|
        vars.existing_teams = [@existing_team]
      end
    end

    it 'adds a team to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(
                :teams,
                containing_exactly(
                  a_hash_including(
                    team_id: @existing_team[:id],
                    role_names: @existing_team[:role_names]
                  )
                )))
    end
  end

  describe 'when many existing teams provided' do
    before(:context) do
      component = var(role: :root, name: 'component')
      deployment_identifier = var(role: :root, name: 'deployment_identifier')

      existing_teams = output(role: :prerequisites, name: 'existing_teams')
      existing_team1_name = "#{component}-#{deployment_identifier}-support"
      existing_team2_name = "#{component}-#{deployment_identifier}-billing"

      @existing_team1 = {
        id: existing_teams[existing_team1_name.to_sym][:id],
        name: existing_team1_name,
        usernames: ['toby+user1@go-atomic.io'],
        role_names: ['GROUP_DATA_ACCESS_READ_ONLY']
      }
      @existing_team2 = {
        id: existing_teams[existing_team2_name.to_sym][:id],
        name: existing_team2_name,
        usernames: ['toby+user2@go-atomic.io'],
        role_names: ['GROUP_READ_ONLY']
      }
      @plan = plan(role: :root) do |vars|
        vars.existing_teams = [@existing_team1, @existing_team2]
      end
    end

    it 'adds all teams to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(
                :teams,
                containing_exactly(
                  a_hash_including(
                    team_id: @existing_team1[:id],
                    role_names: @existing_team1[:role_names]
                  ),
                  a_hash_including(
                    team_id: @existing_team2[:id],
                    role_names: @existing_team2[:role_names]
                  )
                )))
    end
  end

  describe 'when no dedicated teams provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.dedicated_teams = []
      end
    end

    it 'does not add any teams to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(:teams, a_nil_value))
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

    it 'adds a team to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(
                :teams,
                containing_exactly(
                  a_hash_including(
                    role_names:
                      containing_exactly(*@dedicated_team[:role_names])
                  )
                )))
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

    it 'adds all teams to the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_project')
              .with_attribute_value(
                :teams,
                containing_exactly(
                  a_hash_including(
                    role_names:
                      containing_exactly(*@dedicated_team1[:role_names])
                  ),
                  a_hash_including(
                    role_names:
                      containing_exactly(*@dedicated_team2[:role_names])
                  )
                )))
    end
  end
end
