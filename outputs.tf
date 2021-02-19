output "project_id" {
  value = mongodbatlas_project.project.id
}

output "dedicated_teams" {
  value = {
    for team in mongodbatlas_team.team: team.name => {
      id: team.team_id
    }
  }
}
