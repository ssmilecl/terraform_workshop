# Variables for Staging Environment

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-multi-env-demo"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "staging-team"
}

# Staging-specific variables (more restrictive than dev)
variable "allow_public_access" {
  description = "Allow public access to staging buckets"
  type        = bool
  default     = false # Staging should be more secure
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true # Enabled in staging for monitoring
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30 # Longer retention for staging

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}
