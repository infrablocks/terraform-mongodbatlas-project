output "existing_teams" {
  value = {
    for existing_team in mongodbatlas_teams.team:
      existing_team.name => {
        id: existing_team.team_id
     }
  }
}
