provider "aws" {
  region = var.region
}

resource "aws_route53_record" "student_cnames" {
  for_each = merge(var.acm_records, var.cdn_records)

  zone_id = var.hosted_zone_id
  name    = each.key
  type    = each.value.type
  ttl     = each.value.ttl

  records = [each.value.record]
}
