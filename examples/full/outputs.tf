output "project_id" {
  value = module.project.project_id
}

output "dedicated_teams" {
  value = [
    for team in local.dedicated_teams:
      {
        id: module.project.dedicated_teams["${var.component}-${var.deployment_identifier}-${team.name_suffix}"].id
        name_suffix: team.name_suffix
        usernames: team.usernames
        role_names: team.role_names
      }
  ]
}

output "existing_teams" {
  value = local.existing_teams
}

output "ip_access_list" {
  value = local.ip_access_list
}

output "database_users" {
  value = local.database_users
}