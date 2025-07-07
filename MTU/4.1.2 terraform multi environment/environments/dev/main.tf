# Development Environment Configuration
# This environment can use the latest/experimental module versions

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local values for development environment
locals {
  environment    = "development"
  project_prefix = "${var.environment}-${var.project_name}"

  # Development-specific configurations
  dev_config = {
    enable_versioning = false # Disabled for faster iteration
    lifecycle_days    = 7     # Short retention for cost optimization
    enable_encryption = false # Disabled for dev simplicity
    enable_logging    = false # Disabled to reduce costs
  }

  # Environment-specific tags
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "terraform-multi-env"
    Owner         = var.owner
    ModuleVersion = "v4.11.0" # Latest version for testing
    CostCenter    = "development"
    SecurityLevel = "low"
  }
}

# S3 Bucket Module - Using LATEST version for testing new features
# Development uses cutting-edge versions to test new functionality
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0" # Latest version for dev testing

  bucket = "${local.project_prefix}-storage-${random_string.suffix.result}"

  # Development-specific settings (permissive for testing)
  versioning = {
    enabled = local.dev_config.enable_versioning
  }

  # Short lifecycle for dev (cost optimization)
  lifecycle_rule = [{
    id     = "dev_cleanup"
    status = "Enabled"

    expiration = {
      days = local.dev_config.lifecycle_days
    }
  }]

  # No encryption in dev for simplicity
  server_side_encryption_configuration = {}

  # Allow public access for dev testing
  block_public_acls       = !var.allow_public_access
  block_public_policy     = !var.allow_public_access
  ignore_public_acls      = !var.allow_public_access
  restrict_public_buckets = !var.allow_public_access

  tags = local.common_tags
}
