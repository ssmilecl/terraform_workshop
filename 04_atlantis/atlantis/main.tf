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
  vpc_id          = data.aws_vpc.atlantis.id
  alb_subnets     = data.aws_subnets.public.ids
  service_subnets = data.aws_subnets.private.ids

  # Certificate configuration
  certificate_arn     = var.certificate_arn
  route53_zone_id     = var.route53_zone_id
  route53_record_name = var.route53_record_name

  # Disable certificate creation/import in the module
  create_certificate = false

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
        valueFrom = data.aws_ssm_parameter.github_token.arn
      },
      {
        name      = "ATLANTIS_GH_WEBHOOK_SECRET"
        valueFrom = data.aws_ssm_parameter.webhook_secret.arn
      }
    ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = [
      data.aws_ssm_parameter.github_token.arn,
      data.aws_ssm_parameter.webhook_secret.arn
    ]
    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }

  # Enable EFS for persistent storage
  enable_efs = true
  efs = {
    mount_targets = {
      for subnet in data.aws_subnets.private.ids :
      data.aws_subnet.private[subnet].availability_zone => {
        subnet_id = subnet
      }
    }
  }

  tags = var.tags
}

