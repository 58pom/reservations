data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"
  aliases = [var.host_domain]

  # オリジンの設定
  origin {
    origin_id   = aws_s3_bucket.main.id
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    # OAC を設定
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn      = aws_acm_certificate.us_east_1_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.main.id
    viewer_protocol_policy = "redirect-to-https"
    # viewer_protocol_policy = "allow-all"
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD"]
    compress = false
    # キャッシュポリシー
    cache_policy_id = data.aws_cloudfront_cache_policy.cache-optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
# OAC を作成
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "cf-oac-with-tf-example"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
