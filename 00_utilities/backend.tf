terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-keweizhang"                 # Same bucket name used in step 2
    key            = "terraform_workshop/00_utilities/terraform.tfstate" # Note: different state file path
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
