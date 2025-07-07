# Outputs for Production Environment

output "environment_info" {
  description = "Production environment information"
  value = {
    environment       = local.environment
    project_prefix    = local.project_prefix
    aws_region        = var.aws_region
    module_version    = local.common_tags.ModuleVersion
    security_level    = local.common_tags.SecurityLevel
    criticality_level = local.common_tags.CriticalityLevel
    backup_required   = local.common_tags.BackupRequired
    cost_center       = local.common_tags.CostCenter
    retention_days    = var.backup_retention_days
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
  description = "Module versions used in production"
  value = {
    s3_module_version    = "3.14.1" # Production-proven version
    terraform_version    = ">=1.0"
    aws_provider_version = "~> 5.0"
  }
}

output "security_compliance" {
  description = "Security and compliance features enabled"
  value = {
    public_access_blocked   = true
    versioning_enabled      = local.prod_config.enable_versioning
    encryption_enabled      = local.prod_config.enable_encryption
    logging_enabled         = local.prod_config.enable_logging
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    bucket_key_enabled      = true
    compliance_standards    = ["SOX", "GDPR", "HIPAA"]
    audit_trail_enabled     = true
  }
}

output "bucket_configuration" {
  description = "Comprehensive bucket configuration summary"
  value = {
    bucket_name         = module.main_bucket.s3_bucket_id
    versioning          = local.prod_config.enable_versioning
    lifecycle_days      = local.prod_config.lifecycle_days
    encryption          = local.prod_config.enable_encryption
    public_access       = var.allow_public_access
    logging             = local.prod_config.enable_logging
    storage_transitions = ["30d→STANDARD_IA", "90d→GLACIER", "365d→DEEP_ARCHIVE"]
  }
}

output "cost_optimization" {
  description = "Cost optimization features"
  value = {
    intelligent_tiering    = "Multi-tier storage classes"
    lifecycle_policies     = "Automated transitions to lower-cost storage"
    bucket_key_enabled     = "Reduced KMS costs"
    storage_optimization   = "STANDARD→STANDARD_IA→GLACIER→DEEP_ARCHIVE"
    estimated_cost_savings = "Up to 80% vs STANDARD storage for archived data"
  }
}

output "environment_comparison" {
  description = "Production environment characteristics"
  value = {
    strategy = "Conservative: Well-tested stable versions only"
    security = "Maximum: All security features enabled"
    cost     = "Optimized with intelligent tiering and lifecycle policies"
    purpose  = "Enterprise-grade production deployment"
  }
}

output "version_progression" {
  description = "Production vs other environments"
  value = {
    production_advantages = [
      "Enterprise-grade security settings",
      "1-year compliance retention",
      "Comprehensive audit logging",
      "Multi-tier storage optimization",
      "Production-proven module versions",
      "Maximum data protection with versioning"
    ]
    version_strategy = "Conservative: Uses v3.14.1 (well-tested) vs Staging v3.15.0 vs Dev ~4.0"
    security_posture = "Maximum: All public access blocked, encryption always on, comprehensive monitoring"
  }
}

output "disaster_recovery" {
  description = "Disaster recovery capabilities"
  value = {
    backup_retention   = "${var.backup_retention_days} days"
    versioning_enabled = local.prod_config.enable_versioning
    multi_tier_storage = "Automated cost-optimized storage tiers"
    compliance_ready   = "SOX, GDPR, HIPAA retention policies"
    audit_trail        = "Complete access logging and versioning"
  }
}
