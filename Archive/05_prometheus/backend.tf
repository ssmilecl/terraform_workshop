terraform {
  backend "s3" {
    bucket         = "terraform-workshop-state"
    key            = "prometheus/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-workshop-locks"
  }
}