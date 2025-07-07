# Simple Terraform State & Locking Demo
# This configuration creates a simple S3 bucket to demonstrate:
# 1. Local state (no locking)
# 2. Remote state with S3 backend (with DynamoDB locking)

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state configuration will be defined in backend.tf
  # Comment out the backend.tf file to use local state
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 bucket - the only resource we need for this demo
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    Purpose     = "State Management Demo"
  }
}
