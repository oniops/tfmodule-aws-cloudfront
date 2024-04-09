data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}

/*
resource "aws_cloudfront_distribution" "media" {
  origin {
    domain_name = data.aws_s3_bucket.bucket1.bucket_domain_name
    origin_id   = "S3-Bucket"
    s3_origin_config {
      origin_access_identity = var.cloudfront-access-identity-path
    }
  }

  origin {
    domain_name = data.aws_s3_bucket.bucket2.bucket_domain_name
    origin_id   = "S3-Bucket2"

    s3_origin_config {
      origin_access_identity = var.cloudfront-access-identity-path
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    target_origin_id = "S3-Bucket"
    cache_policy_id = data.aws_cloudfront_cache_policy.cache-optimized.id
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/other*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Bucket2"
    cache_policy_id = data.aws_cloudfront_cache_policy.cache-optimized.id
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert-validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  aliases = ["local.cdn-domain-name"]
}
*/

/*
resource "aws_cloudfront_cache_policy" "static" {
  name        = "${var.service_name}-${var.short_environment}-static"
  comment     = ""
  default_ttl = 60
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Origin"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}
*/