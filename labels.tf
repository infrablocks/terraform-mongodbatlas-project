locals {
  base_labels = {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }

  labels = merge(var.labels, local.base_labels)
}