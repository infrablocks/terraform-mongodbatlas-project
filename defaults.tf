locals {
  # default for cases when `null` value provided, meaning "use default"
  existing_teams  = var.existing_teams == null ? [] : var.existing_teams
  dedicated_teams = var.dedicated_teams == null ? [] : var.dedicated_teams
  ip_access_list  = var.ip_access_list == null ? [] : var.ip_access_list
  database_users  = var.database_users == null ? [] : var.database_users
  labels          = var.labels == null ? {} : var.labels
}
