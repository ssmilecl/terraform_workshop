# Variables for Production Environment

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-multi-env-demo"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "production-team"
}

# Production-specific variables (most restrictive for security and compliance)
variable "allow_public_access" {
  description = "Allow public access to production buckets"
  type        = bool
  default     = false # Never allow public access in production
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true # Always enabled in production for audit
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 365 # Long retention for production

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 2555
    error_message = "Backup retention must be between 1 and 2555 days (7 years max)."
  }
}
