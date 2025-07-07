# Simple Production Environment - S3 Bucket Only
# This configuration creates a simple S3 bucket for CI/CD demonstration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # ⚠️ IMPORTANT: Use same bucket from 5.1 backend-setup
    # Run 'terraform output -raw state_bucket_name' in 5.1/backend-setup/ directory
    # Then update the bucket name below
    bucket  = "terraform-state-demo-bucket-51362f55"
    key     = "mtu_5.2/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 bucket for production environment
resource "aws_s3_bucket" "prod_bucket" {
  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    Purpose     = "CI/CD Demo"
    ManagedBy   = "Terraform"
    Criticality = "High"
  }
}

# Enable versioning for production bucket
resource "aws_s3_bucket_versioning" "prod_bucket" {
  bucket = aws_s3_bucket.prod_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for production bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "prod_bucket" {
  bucket = aws_s3_bucket.prod_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
