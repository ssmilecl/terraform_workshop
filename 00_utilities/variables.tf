variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "acm_records" {
  description = "Map of ACM DNS records to create"
  type = map(object({
    type   = string
    ttl    = number
    record = string
  }))
}

variable "cdn_records" {
  description = "Map of CloudFront DNS records to create"
  type = map(object({
    type   = string
    ttl    = number
    record = string
  }))
}
