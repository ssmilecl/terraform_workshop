# Variables for Development Environment

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-multi-env-demo"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "dev-team"
}

# Development-specific variables (more permissive for testing)
variable "allow_public_access" {
  description = "Allow public access to development buckets (for testing)"
  type        = bool
  default     = true # Dev can be more permissive for testing
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false # Disabled for dev to reduce costs
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7 # Short retention for dev

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}
