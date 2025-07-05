# Variables for Combined terraform state rm + terraform import Demo

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "demo"
}

variable "bucket_suffix" {
  description = "Unique suffix for S3 bucket names to avoid conflicts"
  type        = string
  default     = "12345"
} 
