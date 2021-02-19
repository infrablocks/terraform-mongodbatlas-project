require 'spec_helper'

describe 'Teams' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:organization_id) { vars.organization_id }

  let(:dedicated_teams) { vars.dedicated_teams }

  let(:dedicated_teams_ids) do
    output_for(:harness, "dedicated_teams", parse: true)
  end

  it 'creates each of the provided dedicated teams' do
    dedicated_teams.each do |dedicated_team|
      found_team = mongo_db_atlas_client
          .get_one_team_by_name(
              organization_id,
              "#{component}-#{deployment_identifier}-#{dedicated_team["name_suffix"]}")
      found_users = mongo_db_atlas_client
          .get_all_users_assigned_to_team(
              organization_id,
              found_team["id"])
      found_usernames = found_users["results"].map do |found_user|
        found_user["emailAddress"]
      end

      expect(found_usernames).to(contain_exactly(*dedicated_team["usernames"]))
    end
  end

  it 'outputs the id of each created dedicated team' do
    dedicated_teams.each do |dedicated_team|
      team_name = "#{component}-#{deployment_identifier}-#{dedicated_team["name_suffix"]}"
      found_team = mongo_db_atlas_client
          .get_one_team_by_name(
              organization_id,
              team_name)

      expect(dedicated_teams_ids[team_name]["id"])
          .to(eq(found_team["id"]))
    end
  end
end
