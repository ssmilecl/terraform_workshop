# Backend Setup Configuration

# AWS Region
aws_region = "us-east-1"

# Remote State Backend Configuration
# IMPORTANT: Change bucket name to something unique for your use case
state_bucket_name    = "terraform-state-demo-bucket-12345"
state_dynamodb_table = "terraform-state-demo-locks"
