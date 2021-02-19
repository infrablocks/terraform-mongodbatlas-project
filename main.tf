locals {
  dedicated_teams = {
    for dedicated_team in var.dedicated_teams:
      "${var.component}-${var.deployment_identifier}-${dedicated_team.name_suffix}" => dedicated_team
  }
}

resource "mongodbatlas_team" "team" {
  for_each = local.dedicated_teams

  name   = each.key
  org_id = var.organization_id
  usernames = each.value.usernames
}

resource "mongodbatlas_project" "project" {
  org_id = var.organization_id
  name = "${var.component}-${var.deployment_identifier}"

  dynamic "teams" {
    for_each = local.dedicated_teams
    content {
      team_id = mongodbatlas_team.team[teams.key].team_id
      role_names = teams.value.roles
    }
  }
}
