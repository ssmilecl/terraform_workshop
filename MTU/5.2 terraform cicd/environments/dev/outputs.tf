# Outputs for Development Environment

output "bucket_info" {
  description = "Information about the S3 bucket created"
  value = {
    bucket_name = aws_s3_bucket.dev_bucket.id
    bucket_arn  = aws_s3_bucket.dev_bucket.arn
    region      = var.aws_region
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
    resources_created = "1 S3 bucket"
    environment_type  = "Development"
    ci_cd_stage       = "Dev deployment"
  }
}
