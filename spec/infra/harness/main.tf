module "project" {
  source = "../../../../"

  component = var.component
  deployment_identifier = var.deployment_identifier

  organization_id = var.organization_id

  dedicated_teams = var.dedicated_teams
}
