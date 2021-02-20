locals {
  dedicated_teams = {
    for dedicated_team in var.dedicated_teams:
      "${var.component}-${var.deployment_identifier}-${dedicated_team.name_suffix}" => dedicated_team
  }

  existing_teams = {
    for existing_team in var.existing_teams: existing_team.id => existing_team
  }

  cidr_block_entries = {
    for entry in var.ip_access_list:
        entry.value => entry
    if entry.type == "cidr-block"
  }

  ip_address_entries = {
    for entry in var.ip_access_list:
        entry.value => entry
    if entry.type == "ip-address"
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

  dynamic "teams" {
    for_each = local.existing_teams
    content {
      team_id = teams.key
      role_names = teams.value.roles
    }
  }
}

resource "mongodbatlas_project_ip_access_list" "cidr_block_entry" {
  for_each = local.cidr_block_entries

  project_id = mongodbatlas_project.project.id
  cidr_block = each.key
  comment    = each.value.comment
}

resource "mongodbatlas_project_ip_access_list" "ip_address_entry" {
  for_each = local.ip_address_entries

  project_id = mongodbatlas_project.project.id
  ip_address = each.key
  comment    = each.value.comment
}
