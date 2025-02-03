variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where Atlantis will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Atlantis ECS tasks"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of ACM certificate to use with ALB"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID for DNS record"
  type        = string
}

variable "github_user" {
  description = "GitHub username for Atlantis"
  type        = string
}

variable "github_organization" {
  description = "GitHub organization/user where repositories are located"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 
