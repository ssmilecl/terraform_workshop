provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "4.4.0"

  name = "atlantis"

  # VPC
  # VPC configuration using data sources
  vpc_id               = data.aws_vpc.atlantis.id
  alb_subnets          = data.aws_subnets.public.ids
  service_subnets      = data.aws_subnets.private.ids
  certificate_arn      = var.certificate_arn
  validate_certificate = false

  # Atlantis
  atlantis = {
    environment = [
      {
        name  = "ATLANTIS_GH_USER"
        value = var.github_user
      },
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "${var.github_organization}/*"
      },
      {
        name  = "ATLANTIS_ENABLE_DIFF_MARKDOWN_FORMAT"
        value = "true"
      }
    ]
    secrets = [
      {
        name      = "ATLANTIS_GH_TOKEN"
        valueFrom = aws_secretsmanager_secret.github_token.arn
      },
      {
        name      = "ATLANTIS_GH_WEBHOOK_SECRET"
        valueFrom = aws_secretsmanager_secret.webhook_secret.arn
      }
    ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = [
      aws_secretsmanager_secret.github_token.arn,
      aws_secretsmanager_secret.webhook_secret.arn
    ]
    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }

  # Enable EFS for persistent storage
  enable_efs = true
  efs = {
    mount_targets = {
      for subnet in var.private_subnet_ids :
      data.aws_subnet.private[subnet].availability_zone => {
        subnet_id = subnet
      }
    }
  }

  tags = var.tags
}

# Secrets for GitHub token and webhook
resource "aws_secretsmanager_secret" "github_token" {
  name = "atlantis/github-token"
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  name = "atlantis/webhook-secret"
}

# Data source to get AZ for EFS mount targets
data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}
