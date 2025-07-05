# Outputs for prevent_destroy example

output "critical_bucket_name" {
  description = "Name of the critical S3 bucket (protected by prevent_destroy)"
  value       = aws_s3_bucket.critical_data.bucket
}

output "critical_bucket_arn" {
  description = "ARN of the critical S3 bucket"
  value       = aws_s3_bucket.critical_data.arn
}

output "regular_bucket_name" {
  description = "Name of the regular S3 bucket (can be destroyed)"
  value       = aws_s3_bucket.regular_data.bucket
}

output "regular_bucket_arn" {
  description = "ARN of the regular S3 bucket"
  value       = aws_s3_bucket.regular_data.arn
} 
