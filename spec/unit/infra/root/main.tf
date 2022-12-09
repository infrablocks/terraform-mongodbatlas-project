data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "project" {
  source = "./../../../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  organization_id = var.organization_id

  existing_teams  = var.existing_teams
  dedicated_teams = var.dedicated_teams

  ip_access_list = var.ip_access_list

  database_users = var.database_users
}
