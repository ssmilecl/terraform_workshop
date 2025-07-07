# Outputs for Development Environment

output "environment_info" {
  description = "Development environment information"
  value = {
    environment    = local.environment
    project_prefix = local.project_prefix
    aws_region     = var.aws_region
    module_version = local.common_tags.ModuleVersion
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
  description = "Module versions used in development"
  value = {
    s3_module_version    = "~> 4.0" # Latest version for testing
    terraform_version    = ">=1.0"
    aws_provider_version = "~> 5.0"
  }
}

output "development_features" {
  description = "Development-specific features enabled"
  value = {
    public_access_enabled = var.allow_public_access
    versioning_disabled   = !local.dev_config.enable_versioning
    encryption_disabled   = !local.dev_config.enable_encryption
    short_retention       = "${local.dev_config.lifecycle_days} days"
    logging_disabled      = !local.dev_config.enable_logging
    cost_optimization     = "enabled"
  }
}

output "bucket_configuration" {
  description = "Bucket configuration summary"
  value = {
    bucket_name    = module.main_bucket.s3_bucket_id
    versioning     = local.dev_config.enable_versioning
    lifecycle_days = local.dev_config.lifecycle_days
    encryption     = local.dev_config.enable_encryption
    public_access  = var.allow_public_access
    logging        = local.dev_config.enable_logging
  }
}

output "next_steps" {
  description = "Recommended next steps for development environment"
  value = [
    "1. Upload test files to development bucket",
    "2. Test new module features with latest versions",
    "3. Validate configuration changes before promoting to staging",
    "4. Monitor costs with short retention policies",
    "5. Use public access for development testing (disabled in staging/prod)"
  ]
}

output "environment_comparison" {
  description = "Development environment characteristics"
  value = {
    strategy = "Latest versions for testing new features"
    security = "Permissive settings for rapid iteration"
    cost     = "Optimized with short retention and minimal features"
    purpose  = "Experiment with new module versions and configurations"
  }
}
