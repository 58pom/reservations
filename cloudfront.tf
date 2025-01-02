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
    compress = true
    # キャッシュポリシー
    cache_policy_id = aws_cloudfront_cache_policy.policy.id
    # オリジンリクエストポリシー
    origin_request_policy_id = aws_cloudfront_origin_request_policy.policy.id
    # レスポンスヘッダーポリシー
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.managed.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
# CloudFrontキャッシュポリシー
resource aws_cloudfront_cache_policy policy {
    name        = "cloudfront-cache-policy-s3-test"
    min_ttl     = 1
    max_ttl     = 31536000
    default_ttl = 86400
    parameters_in_cache_key_and_forwarded_to_origin {
        headers_config {
            header_behavior = "none"
        }
        cookies_config {
            cookie_behavior = "none"
        }
        query_strings_config {
            query_string_behavior = "none"
        }
        enable_accept_encoding_brotli = true
        enable_accept_encoding_gzip = true
    }
}

# CloudFrontオリジンリクエストポリシー
resource aws_cloudfront_origin_request_policy policy {
    name    = "test-origin-policy"
    headers_config {
        header_behavior = "none"
    }
    cookies_config {
        cookie_behavior = "none"
    }
    query_strings_config {
        query_string_behavior = "none"
    }
}

# CloudFrontレスポンスヘッダー
## マネージドポリシーを指定する場合は、resourceではなくdataでnameのみを指定する
# data aws_cloudfront_response_headers_policy managed {
#     name    = "Managed-SimpleCORS"
# }
# OAC を作成
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "cf-oac-with-tf-example"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
