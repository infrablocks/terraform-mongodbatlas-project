locals {
  existing_teams = [
    for existing_team in var.existing_teams: {
      id: data.terraform_remote_state.prerequisites.outputs.existing_teams[existing_team.name].id,
      roles: existing_team.roles
    }
  ]
}

data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "project" {
  source = "../../../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  organization_id = var.organization_id

  existing_teams = local.existing_teams
  dedicated_teams = var.dedicated_teams

  ip_access_list = var.ip_access_list
}
