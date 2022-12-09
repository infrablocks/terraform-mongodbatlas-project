locals {
  base_labels = {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  resolved_labels = merge(local.labels, local.base_labels)
}