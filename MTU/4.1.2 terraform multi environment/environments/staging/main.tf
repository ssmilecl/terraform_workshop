# Staging Environment Configuration
# This environment uses stable, tested module versions from development
# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local values for staging environment
locals {
  environment    = "staging"
  project_prefix = "${var.environment}-${var.project_name}"

  # Staging-specific configurations (more restrictive than dev)
  staging_config = {
    enable_versioning = true # Versioning enabled for staging
    lifecycle_days    = 30   # Longer retention than dev
    enable_encryption = true # Security enabled for staging
    enable_logging    = true # Logging enabled for monitoring
  }

  # Environment-specific tags
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "terraform-multi-env"
    Owner         = var.owner
    ModuleVersion = "v3.15.0" # Stable version tested in dev
    CostCenter    = "staging"
    SecurityLevel = "medium"
  }
}

# S3 Bucket Module - Using STABLE version tested in development
# Staging uses well-tested versions that passed dev validation
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0" # Pinned stable version tested in dev

  bucket = "${local.project_prefix}-storage-${random_string.suffix.result}"

  # Staging-specific settings (more secure than dev)
  versioning = {
    enabled = local.staging_config.enable_versioning
  }

  # Longer lifecycle for staging (production-like)
  lifecycle_rule = [{
    id     = "staging_cleanup"
    status = "Enabled"

    expiration = {
      days = local.staging_config.lifecycle_days
    }

    transition = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }]
  }]

  # Encryption enabled for staging (security requirement)
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # No public access in staging (security requirement)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.common_tags
}
