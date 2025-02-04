provider "aws" {
  region = var.region
}
# Create NS records in the main zone for student zones
resource "aws_route53_record" "student_ns_records" {
  for_each = var.student_zones

  zone_id = var.main_hosted_zone_id
  name    = each.key
  type    = "NS"
  ttl     = 300

  records = each.value.nameservers
}
