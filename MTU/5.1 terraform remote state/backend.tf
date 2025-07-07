# Backend Configuration for Remote State
# This tells Terraform to store state in S3 with DynamoDB locking

terraform {
  backend "s3" {
    # ⚠️ IMPORTANT: Replace with actual bucket name from backend-setup output
    # Run 'terraform output -raw state_bucket_name' in backend-setup/ directory
    # Then update the bucket name below
    bucket = "terraform-state-demo-bucket-51362f55"

    # Path/key for the state file within the bucket
    key = "terraform-state-demo/terraform.tfstate"

    # AWS region where the bucket is located
    region = "us-east-1"

    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-demo-locks"

    # Enable encryption of state file
    encrypt = true
  }
}

# To use LOCAL state instead of remote state:
# 1. Comment out or rename this file (e.g., backend.tf.disabled)
# 2. Run 'terraform init' to reinitialize with local state
# 3. State will be stored in terraform.tfstate file locally 
