# Production Environment Configuration
# This environment uses only well-tested, stable module versions with enterprise-grade settings
# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local values for production environment
locals {
  environment    = "production"
  project_prefix = "${var.environment}-${var.project_name}"

  # Production-specific configurations (most restrictive and secure)
  prod_config = {
    enable_versioning = true # Always enabled in production
    lifecycle_days    = 365  # Long retention for compliance
    enable_encryption = true # Always encrypted in production
    enable_logging    = true # Always enabled for audit
  }

  # Environment-specific tags
  common_tags = {
    Environment      = var.environment
    Project          = var.project_name
    ManagedBy        = "terraform-multi-env"
    Owner            = var.owner
    ModuleVersion    = "v3.14.1" # Well-tested stable version (behind staging for safety)
    CostCenter       = "production"
    SecurityLevel    = "high"
    CriticalityLevel = "high"
    BackupRequired   = "true"
  }
}

# S3 Bucket Module - Using PRODUCTION-PROVEN version
# Production uses only well-tested versions with proven stability
module "main_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1" # Production-proven version (conservative approach)

  bucket = "${local.project_prefix}-storage-${random_string.suffix.result}"

  # Production-specific settings (maximum security)
  versioning = {
    enabled = local.prod_config.enable_versioning
  }

  # Production lifecycle with compliance-grade retention
  lifecycle_rule = [{
    id     = "production_retention"
    status = "Enabled"

    expiration = {
      days = local.prod_config.lifecycle_days
    }

    # Multi-tier storage optimization
    transition = [
      {
        days          = 30
        storage_class = "STANDARD_IA"
      },
      {
        days          = 90
        storage_class = "GLACIER"
      },
      {
        days          = 365
        storage_class = "DEEP_ARCHIVE"
      }
    ]

    noncurrent_version_expiration = {
      noncurrent_days = 90 # Clean up old versions after 90 days
    }
  }]

  # Production-grade encryption (always enabled)
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true # Cost optimization for KMS
    }
  }

  # Maximum security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.common_tags
}
