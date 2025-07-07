# Production Environment Configuration
# This environment uses the most restrictive settings for security and compliance

aws_region   = "us-east-1"
environment  = "production"
project_name = "terraform-multi-env-demo"
owner        = "production-team"

# Production-specific S3 configurations (maximum security and compliance)
allow_public_access   = false # Never allow public access in production
enable_logging        = true  # Always enabled for audit compliance
backup_retention_days = 365   # 1 year retention for production

# Note: Production uses only well-tested, stable module versions
# This environment is designed for:
# - Maximum security and compliance
# - Long-term data retention (1 year)
# - Multi-tier storage optimization
# - Comprehensive audit logging
# - Regulatory compliance (SOX, GDPR, HIPAA) 
