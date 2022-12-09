locals {
  existing_teams_map = {
    for existing_team in local.existing_teams:
      existing_team.name => existing_team
  }
}

resource "mongodbatlas_teams" "team" {
  for_each  = local.existing_teams_map
  org_id    = var.organization_id
  name      = each.key
  usernames = each.value.usernames
}
