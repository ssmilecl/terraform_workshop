# Outputs for Simple State & Locking Demo

output "demo_bucket_info" {
  description = "Information about the demo S3 bucket"
  value = {
    bucket_name = aws_s3_bucket.demo_bucket.id
    bucket_arn  = aws_s3_bucket.demo_bucket.arn
    region      = var.aws_region
  }
}

output "state_info" {
  description = "Information about state management"
  value = {
    state_type   = "Check if backend.tf is configured for remote state or using local state"
    state_file   = "terraform.tfstate (local) or S3 bucket (remote)"
    locking      = "None (local) or DynamoDB (remote)"
    environment  = var.environment
    project_name = var.project_name
  }
}

output "demo_summary" {
  description = "Summary of what this demo shows"
  value = {
    local_state      = "No locking - multiple users can conflict"
    remote_state     = "S3 storage + DynamoDB locking prevents conflicts"
    resource_created = "Simple S3 bucket to demonstrate state management"
  }
}
