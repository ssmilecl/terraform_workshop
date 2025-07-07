# Backend Setup for Remote State Demo
# This creates the S3 bucket and DynamoDB table needed for remote state
# Run this FIRST before using remote state in the main configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Uses LOCAL state because we're creating the backend infrastructure
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for storing Terraform state files
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.state_bucket_name

  tags = {
    Name    = "Terraform State Bucket"
    Purpose = "Remote State Storage"
  }
}

# Enable versioning to keep state file history
resource "aws_s3_bucket_versioning" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for security
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for security
resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "state_lock" {
  name         = var.state_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform State Lock Table"
    Purpose = "State Locking"
  }
}
