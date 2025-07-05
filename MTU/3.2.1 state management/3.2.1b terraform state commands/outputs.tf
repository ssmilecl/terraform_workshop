# Outputs for Combined terraform state rm + terraform import Demo

output "managed_bucket_name" {
  description = "Name of the S3 bucket that stays managed"
  value       = aws_s3_bucket.managed_bucket.bucket
}

output "managed_bucket_arn" {
  description = "ARN of the S3 bucket that stays managed"
  value       = aws_s3_bucket.managed_bucket.arn
}

output "state_lifecycle_bucket_name" {
  description = "Name of the S3 bucket used for state rm + import demo"
  value       = aws_s3_bucket.state_lifecycle_bucket.bucket
}

output "state_lifecycle_bucket_arn" {
  description = "ARN of the S3 bucket used for state rm + import demo"
  value       = aws_s3_bucket.state_lifecycle_bucket.arn
}

output "demo_summary" {
  description = "Summary of the demo setup"
  value = {
    managed_bucket         = aws_s3_bucket.managed_bucket.bucket
    state_lifecycle_bucket = aws_s3_bucket.state_lifecycle_bucket.bucket
    region                 = var.aws_region
    environment            = var.environment
    demo_type              = "state_rm_import_combined"
  }
} 
