# Variables for Backend Setup

variable "aws_region" {
  description = "AWS region for the state bucket and DynamoDB table"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state (must be globally unique)"
  type        = string
  default     = "terraform-state-demo-bucket-12345"
}

variable "state_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-demo-locks"
}
