# Development Environment Configuration
# This environment can use experimental settings and latest module versions

aws_region   = "us-east-1"
environment  = "development"
project_name = "terraform-multi-env-demo"
owner        = "dev-team"

# Development-specific S3 configurations (permissive for testing)
allow_public_access   = true  # Allow public access for dev testing
enable_logging        = false # Disabled to reduce costs in dev
backup_retention_days = 7     # Short retention for cost optimization

# Note: Development can use latest module versions and experimental features
# This environment is designed for:
# - Testing new module versions
# - Experimenting with configurations
# - Fast iteration and development
# - Cost optimization over security/compliance 
