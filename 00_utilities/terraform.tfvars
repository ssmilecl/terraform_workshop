hosted_zone_id = "Z09291682BCE5KJHLY1UO"

acm_records = {
  # ACM Validation Records
  "_369480b506252d9770622ef80bb33ab5.keweizhang.aws.jrworkshop.au." = {
    type   = "CNAME"
    ttl    = 300
    record = "_0660ce302d9bd9a0f8ed1df0380f100d.zfyfvmchrl.acm-validations.aws."
  }
}

cdn_records = {
  # CloudFront Distribution Records
  "keweizhang.aws.jrworkshop.au" = {
    type   = "CNAME"
    ttl    = 300
    record = "d273pizkvy0r3x.cloudfront.net"
  }
}
