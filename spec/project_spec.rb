require 'spec_helper'

describe 'Project' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:organization_id) { vars.organization_id }
  let(:project_id) {
    output_for(:harness, "project_id", parse: true)
  }

  let(:existing_teams) { vars.existing_teams }
  let(:dedicated_teams) { vars.dedicated_teams }

  it 'creates a project within the organization with a unique name' do
    project = mongo_db_atlas_client.get_one_project(project_id)

    expect(project["name"]).to(eq("#{component}-#{deployment_identifier}"))
    expect(project["orgId"]).to(eq(organization_id))
  end

  it 'associates the provided dedicated teams to the project' do
    project_teams = mongo_db_atlas_client
        .get_all_teams_assigned_to_project(project_id)["results"]

    dedicated_teams.each do |dedicated_team|
      created_team = mongo_db_atlas_client
          .get_one_team_by_name(
              organization_id,
              "#{component}-#{deployment_identifier}-#{dedicated_team["name_suffix"]}")
      project_team = project_teams.find do |project_team|
        project_team["teamId"] == created_team["id"]
      end

      expect(project_team).not_to(be_nil)
      expect(project_team["roleNames"])
          .to(contain_exactly(*dedicated_team["roles"]))
    end
  end

  it 'associates the provided existing teams to the project' do
    project_teams = mongo_db_atlas_client
        .get_all_teams_assigned_to_project(project_id)["results"]

    existing_teams.each do |existing_team|
      created_team = mongo_db_atlas_client
          .get_one_team_by_name(
              organization_id,
              existing_team["name"])
      project_team = project_teams.find do |project_team|
        project_team["teamId"] == created_team["id"]
      end

      expect(project_team).not_to(be_nil)
      expect(project_team["roleNames"])
          .to(contain_exactly(*existing_team["roles"]))
    end
  end
end
