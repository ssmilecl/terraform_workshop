# Variables for terraform taint example

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}



variable "ami_id" {
  description = "AMI ID for EC2 instance (Amazon Linux 2023)"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2023 in us-east-1 (update as needed)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
