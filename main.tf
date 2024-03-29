locals {
  resolved_dedicated_teams = {
    for dedicated_team in local.dedicated_teams:
      "${var.component}-${var.deployment_identifier}-${dedicated_team.name_suffix}" => dedicated_team
  }

  resolved_existing_teams = {
    for existing_team in local.existing_teams: existing_team.id => existing_team
  }

  resolved_cidr_block_entries = {
    for entry in local.ip_access_list:
        entry.value => entry
    if entry.type == "cidr-block"
  }

  resolved_ip_address_entries = {
    for entry in local.ip_access_list:
        entry.value => entry
    if entry.type == "ip-address"
  }

  resolved_database_users = {
    for database_user in local.database_users:
      database_user.username => database_user
  }
}

resource "mongodbatlas_team" "team" {
  for_each = local.resolved_dedicated_teams

  name   = each.key
  org_id = var.organization_id
  usernames = each.value.usernames
}

resource "mongodbatlas_project" "project" {
  org_id = var.organization_id
  name = "${var.component}-${var.deployment_identifier}"

  dynamic "teams" {
    for_each = local.resolved_dedicated_teams
    content {
      team_id = mongodbatlas_team.team[teams.key].team_id
      role_names = teams.value.role_names
    }
  }

  dynamic "teams" {
    for_each = local.resolved_existing_teams
    content {
      team_id = teams.key
      role_names = teams.value.role_names
    }
  }
}

resource "mongodbatlas_project_ip_access_list" "cidr_block_entry" {
  for_each = local.resolved_cidr_block_entries

  project_id = mongodbatlas_project.project.id
  cidr_block = each.key
  comment    = each.value.comment
}

resource "mongodbatlas_project_ip_access_list" "ip_address_entry" {
  for_each = local.resolved_ip_address_entries

  project_id = mongodbatlas_project.project.id
  ip_address = each.key
  comment    = each.value.comment
}

resource "mongodbatlas_database_user" "user" {
  for_each = local.resolved_database_users

  project_id = mongodbatlas_project.project.id
  username = each.key
  password = each.value.password
  auth_database_name = "admin"

  dynamic "roles" {
    for_each = each.value.roles

    content {
      role_name = roles.value.role_name
      database_name = roles.value.database_name
      collection_name = roles.value.collection_name
    }
  }

  dynamic "labels" {
    for_each = merge(local.resolved_labels, each.value.labels)
    content {
      key = labels.key
      value = labels.value
    }
  }

  dynamic "scopes" {
    for_each = { for scope in each.value.scopes: "${scope.type}-${scope.name}" => scope }

    content {
      name = scopes.value.name
      type = scopes.value.type
    }
  }
}
