variable "student_subdomain" {
  description = "Subdomain assigned to student (e.g., student1.workshop.com)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1" # Required for ACM with CloudFront
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}
