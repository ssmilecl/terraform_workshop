output "hosted_zone_id" {
  description = "Hosted zone ID"
  value       = aws_route53_zone.student.zone_id
}

output "hosted_zone_name" {
  description = "Hosted zone name"
  value       = aws_route53_zone.student.name
}

output "nameservers" {
  description = "Nameservers for the student zone"
  value       = aws_route53_zone.student.name_servers
}
