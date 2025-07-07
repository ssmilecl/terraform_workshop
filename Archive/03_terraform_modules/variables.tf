variable "student_subdomain" {
  description = "Subdomain for this module (e.g., module.student1.workshop.com)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "content_version" {
  description = "Version string for static content"
  type        = string
  default     = "v1"
}

variable "base_student_subdomain" {
  description = "Base student subdomain from step 01 (e.g., student1.workshop.com)"
  type        = string
}
