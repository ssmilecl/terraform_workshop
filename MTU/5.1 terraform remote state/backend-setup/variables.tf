# Variables for Backend Setup

variable "aws_region" {
  description = "AWS region for the state bucket and DynamoDB table"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_prefix" {
  description = "Prefix for the S3 bucket name (random suffix will be added for uniqueness)"
  type        = string
  default     = "terraform-state-demo-bucket"
}

variable "state_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-demo-locks"
}
