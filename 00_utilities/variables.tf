variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "main_hosted_zone_id" {
  description = "Main workshop Route53 hosted zone ID (aws.jrworkshop.au)"
  type        = string
}

variable "student_zones" {
  description = "Map of student domains to their nameservers"
  type = map(object({
    nameservers = list(string)
  }))
}
