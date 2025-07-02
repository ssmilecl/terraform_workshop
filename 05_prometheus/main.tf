provider "aws" {
  region = var.region
}

locals {
  tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

module "prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.2.0"

  # Workspace
  workspace_name   = var.workspace_name
  create_workspace = var.create_workspace

  # Alert manager
  create_alertmanager_configuration = var.alertmanager_configuration != null ? true : false
  alertmanager_configuration        = var.alertmanager_configuration

  # Rule group namespaces
  rule_group_namespaces = var.rule_group_namespaces

  tags = local.tags
}
