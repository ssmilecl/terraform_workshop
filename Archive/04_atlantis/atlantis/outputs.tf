output "atlantis_url" {
  description = "URL of Atlantis"
  value       = module.atlantis.url
}

output "webhook_url" {
  description = "Webhook URL for GitHub"
  value       = "${module.atlantis.url}/events"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.atlantis.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.atlantis.alb.zone_id
}
