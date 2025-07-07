# Outputs for Production Environment

output "bucket_info" {
  description = "Information about the S3 bucket created"
  value = {
    bucket_name = aws_s3_bucket.prod_bucket.id
    bucket_arn  = aws_s3_bucket.prod_bucket.arn
    region      = var.aws_region
    versioning  = "Enabled"
    encryption  = "AES256"
  }
}

output "environment_info" {
  description = "Environment information"
  value = {
    environment  = var.environment
    project_name = var.project_name
    deployed_at  = timestamp()
  }
}

output "deployment_summary" {
  description = "Summary of what was deployed"
  value = {
    resources_created = "1 S3 bucket (with versioning & encryption)"
    environment_type  = "Production"
    ci_cd_stage       = "Prod deployment (tests passed)"
  }
}
