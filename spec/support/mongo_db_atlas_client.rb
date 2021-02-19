require 'httparty'
require 'json'

class MongoDBAtlasClient
  def initialize(base_url = nil, username = nil, password = nil)
    @base_url = base_url ||
        ENV["MONGODB_ATLAS_BASE_URL"] ||
        'https://cloud.mongodb.com/api/atlas/v1.0'
    @username = username ||
        ENV["MONGODB_ATLAS_PUBLIC_KEY"]
    @password = password ||
        ENV["MONGODB_ATLAS_PRIVATE_KEY"]
  end

  def get_one_project(project_id)
    JSON.parse(
        get("/groups/#{project_id}").body)
  end

  def get_all_teams_assigned_to_project(project_id)
    JSON.parse(get("/groups/#{project_id}/teams").body)
  end

  def get_one_team_by_name(organisation_id, team_name)
    JSON.parse(
        get("/orgs/#{organisation_id}/teams/byName/#{team_name}").body)
  end

  def get_all_users_assigned_to_team(organisation_id, team_id)
    JSON.parse(
        get("/orgs/#{organisation_id}/teams/#{team_id}/users").body)
  end

  private

  def get(path, headers = {})
    HTTParty.get(
        "#{@base_url}#{path}",
        default_headers.merge(headers))
  end

  def default_headers
    {
        digest_auth: credentials
    }
  end

  def credentials
    {
        username: @username,
        password: @password
    }
  end
end