locals {
  existing_teams = {
  for existing_team in var.existing_teams:
  existing_team.name => existing_team
  }
}

resource "mongodbatlas_teams" "team" {
  for_each  = local.existing_teams
  org_id    = var.organization_id
  name      = each.key
  usernames = each.value.usernames
}
