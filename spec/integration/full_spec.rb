# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  let(:mongo_db_atlas_client) do
    MongoDBAtlasClient.new
  end

  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end

  let(:organization_id) do
    var(role: :full, name: 'organization_id')
  end
  let(:project_id) do
    output(role: :full, name: 'project_id')
  end
  let(:ip_access_list) do
    output(role: :full, name: 'ip_access_list')
  end
  let(:existing_teams) do
    output(role: :full, name: 'existing_teams')
  end
  let(:dedicated_teams) do
    output(role: :full, name: 'dedicated_teams')
  end
  let(:database_users) do
    output(role: :full, name: 'database_users')
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'access' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'adds entries to the project IP access list for each allowed CIDR' do
      expected_cidr_block_entries = ip_access_list.select do |entry|
        entry[:type] == 'cidr-block'
      end

      project_ip_access_list =
        mongo_db_atlas_client
        .get_project_ip_access_list(project_id)['results']
      project_cidr_block_entries = project_ip_access_list.reject do |entry|
        entry['cidrBlock'].nil?
      end

      expected_cidr_block_entries.each do |expected_cidr_block_entry|
        project_cidr_block_entry = project_cidr_block_entries.find do |entry|
          entry['cidrBlock'] == expected_cidr_block_entry[:value]
        end

        expect(project_cidr_block_entry).not_to(be_nil)
        expect(project_cidr_block_entry['comment'])
          .to(eq(expected_cidr_block_entry[:comment]))
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'adds entries to the project IP access list for each allowed IP' do
      expected_ip_address_entries = ip_access_list.select do |entry|
        entry[:type] == 'ip-address'
      end

      project_ip_access_list =
        mongo_db_atlas_client
        .get_project_ip_access_list(project_id)['results']
      project_ip_address_entries = project_ip_access_list.reject do |entry|
        entry['ipAddress'].nil?
      end

      expected_ip_address_entries.each do |expected_ip_address_entry|
        project_ip_address_entry = project_ip_address_entries.find do |entry|
          entry['ipAddress'] == expected_ip_address_entry[:value]
        end

        expect(project_ip_address_entry).not_to(be_nil)
        expect(project_ip_address_entry['comment'])
          .to(eq(expected_ip_address_entry[:comment]))
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'project' do
    it 'creates a project within the organization with a unique name' do
      project = mongo_db_atlas_client.get_one_project(project_id)

      expect(project)
        .to(include(
              'name' => "#{component}-#{deployment_identifier}",
              'orgId' => organization_id
            ))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'associates the provided dedicated teams to the project' do
      project_teams =
        mongo_db_atlas_client
        .get_all_teams_assigned_to_project(project_id)['results']

      dedicated_teams.each do |dedicated_team|
        name_suffix = dedicated_team[:name_suffix]
        created_team =
          mongo_db_atlas_client
          .get_one_team_by_name(
            organization_id,
            "#{component}-#{deployment_identifier}-#{name_suffix}"
          )
        matching_team = project_teams.find do |project_team|
          project_team['teamId'] == created_team['id']
        end

        expect(matching_team).not_to(be_nil)
        expect(matching_team['roleNames'])
          .to(match_array(dedicated_team[:role_names]))
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'associates the provided existing teams to the project' do
      project_teams =
        mongo_db_atlas_client
        .get_all_teams_assigned_to_project(project_id)['results']

      existing_teams.each do |existing_team|
        created_team =
          mongo_db_atlas_client
          .get_one_team_by_name(
            organization_id,
            existing_team[:name]
          )
        matching_team = project_teams.find do |project_team|
          project_team['teamId'] == created_team['id']
        end

        expect(matching_team).not_to(be_nil)
        expect(matching_team['roleNames'])
          .to(match_array(existing_team[:role_names]))
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'teams' do
    it 'creates each of the provided dedicated teams' do
      dedicated_teams.each do |dedicated_team|
        name_suffix = dedicated_team[:name_suffix]

        found_team =
          mongo_db_atlas_client
          .get_one_team_by_name(
            organization_id,
            "#{component}-#{deployment_identifier}-#{name_suffix}"
          )
        found_users =
          mongo_db_atlas_client
          .get_all_users_assigned_to_team(
            organization_id,
            found_team['id']
          )
        found_usernames = found_users['results'].map do |found_user|
          found_user['emailAddress']
        end

        expect(found_usernames)
          .to(match_array(dedicated_team[:usernames]))
      end
    end

    it 'outputs the id of each created dedicated team' do
      dedicated_teams.each do |dedicated_team|
        name_suffix = dedicated_team[:name_suffix]
        team_name = "#{component}-#{deployment_identifier}-#{name_suffix}"
        found_team =
          mongo_db_atlas_client
          .get_one_team_by_name(
            organization_id,
            team_name
          )

        expect(dedicated_team[:id])
          .to(eq(found_team['id']))
      end
    end
  end

  describe 'users' do
    it 'creates the requested database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])

        # required to protect against not found response
        expect(found_database_user['username'])
          .to(eq(database_user[:username]))
      end
    end

    it 'adds all requested roles to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_roles = found_database_user['roles']

        database_user[:roles].each do |role|
          matching_role = found_roles.find do |found_role|
            found_role['roleName'] == role[:role_name]
          end

          expected_database_name =
            role[:database_name] == '' ? nil : role[:database_name]
          expected_collection_name =
            role[:collection_name] == '' ? nil : role[:collection_name]

          expect(matching_role)
            .to(include(
                  {
                    'databaseName' => expected_database_name,
                    'collectionName' => expected_collection_name
                  }.compact
                ))
        end
      end
    end

    it 'adds all requested labels to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_labels = found_database_user['labels']

        database_user[:labels].each do |key, value|
          matching_label = found_labels.find do |found_label|
            found_label['key'] == key.to_s
          end

          expect(matching_label['value']).to(eq(value))
        end
      end
    end

    it 'adds default labels to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_labels = found_database_user['labels']

        {
          'Component' => component,
          'DeploymentIdentifier' => deployment_identifier
        }.each do |key, value|
          matching_label = found_labels.find do |found_label|
            found_label['key'] == key
          end

          expect(matching_label['value']).to(eq(value))
        end
      end
    end

    it 'adds all requested scopes to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_scopes = found_database_user['scopes']

        database_user[:scopes].each do |scope|
          matching_scope = found_scopes.find do |found_scope|
            found_scope['name'] == scope[:name]
          end

          expect(matching_scope).to(include('type' => scope[:type]))
        end
      end
    end
  end
end
