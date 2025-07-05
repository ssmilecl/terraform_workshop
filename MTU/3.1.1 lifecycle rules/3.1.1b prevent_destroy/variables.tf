# Variables for prevent_destroy example

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "bucket_suffix" {
  description = "Unique suffix for S3 bucket names"
  type        = string
  default     = "12345" # Change this to a unique value
} 
