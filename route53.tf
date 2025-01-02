data "aws_route53_zone" "route53-zone" {
  name         = var.host_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = { for dvo in aws_acm_certificate.us_east_1_cert.domain_validation_options : dvo.domain_name => dvo }
  zone_id  = data.aws_route53_zone.route53-zone.zone_id
  name     = each.value.resource_record_name
  type     = each.value.resource_record_type
  records  = [each.value.resource_record_value]
  ttl      = 60
}

# 証明書発行リクエスト
resource "aws_acm_certificate" "us_east_1_cert" {
  domain_name               = var.host_domain
  subject_alternative_names = [var.host_domain]
  validation_method         = "DNS"
  provider = aws.us-east-1 # CloudFrontの証明書はus-east-1リージョンになければならないため、version.tfでus-east-1を指定
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.us_east_1_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  provider = aws.us-east-1
}

# resource aws_lb_listener listener {
# 	//他パラメーター省略
#   certificate_arn = aws_acm_certificate.cert.arn
# }
