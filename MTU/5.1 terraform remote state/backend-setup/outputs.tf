# Outputs for Backend Setup

output "state_bucket_name" {
  description = "Name of the S3 bucket created for state storage (with random suffix)"
  value       = aws_s3_bucket.state_bucket.id
}

output "state_lock_table_name" {
  description = "Name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.state_lock.name
}

output "setup_complete" {
  description = "Confirmation that backend setup is complete"
  value       = "✅ Backend setup complete! You can now use remote state in your main configuration."
}

output "next_steps" {
  description = "What to do next"
  value = [
    "1. Go to the main directory (cd ../)",
    "2. Run 'terraform init' to initialize with remote state",
    "3. Run 'terraform plan' and 'terraform apply' to test state locking",
    "4. Try running 'terraform plan' from multiple terminals to see locking in action!"
  ]
}
