# Outputs for Staging Environment

output "environment_info" {
  description = "Staging environment information"
  value = {
    environment    = local.environment
    project_prefix = local.project_prefix
    aws_region     = var.aws_region
    module_version = local.common_tags.ModuleVersion
    security_level = local.common_tags.SecurityLevel
    cost_center    = local.common_tags.CostCenter
    allow_public   = var.allow_public_access
    retention_days = var.backup_retention_days
  }
}

output "storage_info" {
  description = "S3 storage information"
  value = {
    bucket_name        = module.main_bucket.s3_bucket_id
    bucket_arn         = module.main_bucket.s3_bucket_arn
    bucket_domain_name = module.main_bucket.s3_bucket_bucket_domain_name
  }
}

output "module_versions" {
  description = "Module versions used in staging"
  value = {
    s3_module_version    = "3.15.0" # Stable version tested in dev
    terraform_version    = ">=1.0"
    aws_provider_version = "~> 5.0"
  }
}

output "security_features" {
  description = "Security features enabled in staging"
  value = {
    public_access_blocked = !var.allow_public_access
    versioning_enabled    = local.staging_config.enable_versioning
    encryption_enabled    = local.staging_config.enable_encryption
    logging_enabled       = local.staging_config.enable_logging
    block_public_acls     = true
    block_public_policy   = true
    retention_policy      = "${var.backup_retention_days} days"
  }
}

output "bucket_configuration" {
  description = "Bucket configuration summary"
  value = {
    bucket_name    = module.main_bucket.s3_bucket_id
    versioning     = local.staging_config.enable_versioning
    lifecycle_days = local.staging_config.lifecycle_days
    encryption     = local.staging_config.enable_encryption
    public_access  = var.allow_public_access
    logging        = local.staging_config.enable_logging
  }
}

output "environment_comparison" {
  description = "Staging environment characteristics"
  value = {
    strategy = "Stable versions tested in development"
    security = "Production-like security settings"
    cost     = "Balanced with medium retention and security features"
    purpose  = "Validate configurations before production deployment"
  }
}

output "comparison_with_dev" {
  description = "Key differences between staging and development"
  value = {
    staging_features = [
      "Public access disabled (dev: enabled)",
      "Versioning enabled (dev: disabled)",
      "Encryption enabled (dev: disabled)",
      "Longer retention: 30 days (dev: 7 days)",
      "Production-like security settings"
    ]
    module_progression = "Dev tests latest versions → Staging uses stable tested versions → Prod uses well-proven versions"
  }
}
