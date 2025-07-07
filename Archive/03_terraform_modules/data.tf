# Reference existing ACM certificate
data "aws_acm_certificate" "existing" {
  provider = aws.us_east_1
  domain   = var.base_student_subdomain # This should be the main domain from step 01
  statuses = ["ISSUED"]
}
