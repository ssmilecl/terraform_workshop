output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.cloudfront_distribution_domain_name
}

output "website_url" {
  description = "Website URL"
  value       = "https://${var.student_subdomain}"
}
