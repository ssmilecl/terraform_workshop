terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-keweizhang" # Replace with your bucket name
    key            = "terraform_workshop/01_basic/hosted_zone/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
