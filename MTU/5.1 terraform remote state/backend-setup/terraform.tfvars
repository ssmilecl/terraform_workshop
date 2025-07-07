# Backend Setup Configuration

# AWS Region
aws_region = "us-east-1"

# Remote State Backend Configuration
# Random suffix will be automatically added to bucket name for uniqueness
state_bucket_prefix  = "terraform-state-demo-bucket"
state_dynamodb_table = "terraform-state-demo-locks"
