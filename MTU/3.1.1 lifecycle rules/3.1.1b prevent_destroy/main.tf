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

# Example: prevent_destroy
# This S3 bucket cannot be destroyed by terraform destroy
# Useful for critical resources like production databases or important data
resource "aws_s3_bucket" "critical_data" {
  bucket = "${var.environment}-critical-data-${var.bucket_suffix}"

  tags = {
    Name     = "${var.environment}-critical-data"
    Type     = "prevent_destroy_example"
    Critical = "true"
  }

  # Lifecycle rule: prevent_destroy
  # This resource cannot be destroyed via terraform destroy
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# S3 bucket versioning (also protected)
resource "aws_s3_bucket_versioning" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id
  versioning_configuration {
    status = "Enabled"
  }

  # Also protect versioning configuration
#   lifecycle {
#     prevent_destroy = true
#   }
 }

# Regular S3 bucket (for comparison - can be destroyed)
resource "aws_s3_bucket" "regular_data" {
  bucket = "${var.environment}-regular-data-${var.bucket_suffix}"

  tags = {
    Name     = "${var.environment}-regular-data"
    Type     = "normal_resource"
    Critical = "false"
  }

  # No lifecycle rule - can be destroyed normally
}
