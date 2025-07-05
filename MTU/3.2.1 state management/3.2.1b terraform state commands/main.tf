# Terraform Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example: Combined terraform state rm + terraform import
# This demonstrates the complete lifecycle of removing a resource from state
# and importing it back, showing how to manage existing resources

# S3 bucket that will stay managed throughout the demo
resource "aws_s3_bucket" "managed_bucket" {
  bucket = "${var.environment}-managed-bucket-${var.bucket_suffix}"

  tags = {
    Name        = "${var.environment}-managed-bucket"
    Type        = "state_rm_demo"
    Management  = "always_managed"
    Environment = var.environment
    Purpose     = "Stays under Terraform management"
  }
}

# S3 bucket that will be removed from state then imported back
resource "aws_s3_bucket" "state_lifecycle_bucket" {
  bucket = "${var.environment}-lifecycle-bucket-${var.bucket_suffix}"

  tags = {
    Name        = "${var.environment}-lifecycle-bucket"
    Type        = "state_rm_demo"
    Management  = "state_lifecycle_demo"
    Environment = var.environment
    Purpose     = "Demonstrates state rm + import workflow"
  }
} 
