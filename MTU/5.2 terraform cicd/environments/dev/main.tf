# Simple Development Environment - S3 Bucket Only
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
    bucket  = "terraform-cicd-demo-state-bucket"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 bucket for development environment
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    Purpose     = "CI/CD Demo"
    ManagedBy   = "Terraform"
  }
}
