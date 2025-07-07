# Staging Environment Configuration
# This environment uses stable versions tested in development

aws_region   = "us-east-1"
environment  = "staging"
project_name = "terraform-multi-env-demo"
owner        = "staging-team"

# Staging-specific S3 configurations (more secure than dev)
allow_public_access   = false # No public access in staging
enable_logging        = true  # Enabled for monitoring
backup_retention_days = 30    # Longer retention than dev

# Note: Staging uses stable module versions that have been tested in dev
# This environment is designed for:
# - Testing production-like configurations
# - Validating changes before production deployment
# - More security and compliance than development
# - Performance testing with production-like settings 
