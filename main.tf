# see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
# see - https://github.com/ankit-jn/terraform-aws-examples/blob/main/aws-cdn/dev.tfvars

locals {
  cloudfront_name_prefix = format("%s-%s", var.context.project, var.service_name)
  custom_error_response  = var.enable_custom_error_response ? [
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/errors/404.html"
    },
    {
      error_code         = 403
      response_code      = 403
      response_page_path = "/errors/403.html"
    }
  ] : []
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = format("%s-cf-oac", local.cloudfront_name_prefix)
  description                       = format("%s-cf-oac Policy", local.cloudfront_name_prefix)
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_protocol                  = var.signing_protocol
  signing_behavior                  = var.signing_behavior
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  comment             = format("%s-cf-dist", local.cloudfront_name_prefix)
  price_class         = var.price_class
  aliases             = var.domain_aliases
  retain_on_delete    = false
  wait_for_deployment = var.wait_for_deployment

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = var.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_path              = var.origin_path

    #    domain_name (Required) - DNS domain name of either the S3 bucket, or web site of your custom origin.
    #    origin_id (Required) - Unique identifier for the origin.
    #    origin_path (Optional) - Optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin.
    #    origin_shield - (Optional) CloudFront Origin Shield configuration information. Using Origin Shield can help reduce the load on your origin.
    #    origin_access_control_id (Optional) - Unique identifier of a CloudFront origin access control for this origin.
    #    s3_origin_config - (Optional) CloudFront S3 origin configuration information. If a custom origin is required, use custom_origin_config instead.
    #    connection_attempts (Optional) - Number of times that CloudFront attempts to connect to the origin. Must be between 1-3. Defaults to 3.
    #    connection_timeout (Optional) - Number of seconds that CloudFront waits when trying to establish a connection to the origin. Must be between 1-10. Defaults to 10.
    #    custom_origin_config - The CloudFront custom origin configuration information. If an S3 origin is required, use origin_access_control_id or s3_origin_config instead.
    #    custom_header (Optional) - One or more sub-resources with name and value parameters that specify header data that will be sent to the origin (multiples allowed).
  }

  # see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#default_cache_behavior
  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.bucket_domain_name

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress

    forwarded_values {
      query_string = var.forward_query_string
      headers      = var.forward_headers
      cookies {
        forward = var.forward_cookies
      }
    }

    #  allowed_methods (Required) - Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin.
    #  cached_methods (Required) - Controls whether CloudFront caches the response to requests using the specified HTTP methods.
    #  cache_policy_id (Optional) - Unique identifier of the cache policy that is attached to the cache behavior.
    #  compress (Optional) - Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false).
    #  field_level_encryption_id (Optional) - Field level encryption configuration ID.
    #  lambda_function_association (Optional) - A config block that triggers a lambda function with specific actions (maximum 4).
    #  function_association (Optional) - A config block that triggers a cloudfront function with specific actions (maximum 2).
    #  default_ttl (Optional) - Default amount of time (in seconds)
    #  max_ttl (Optional) - Maximum amount of time (in seconds)
    #  min_ttl (Optional) - Minimum amount of time
    #  origin_request_policy_id (Optional) - Unique identifier of the origin request policy that is attached to the behavior.
    #  path_pattern (Required) - Pattern (for example, images/*.jpg) that specifies which requests you want this cache behavior to apply to.
    #  realtime_log_config_arn (Optional) - ARN of the real-time log configuration that is attached to this cache behavior.
    #  response_headers_policy_id (Optional) - Identifier for a response headers policy.
    #  smooth_streaming (Optional) - Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior.
    #  target_origin_id (Required) - Value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior.
    #  trusted_key_groups (Optional) - List of key group IDs that CloudFront can use to validate signed URLs or signed cookies. See the CloudFront User Guide for more information about this feature.
    #  trusted_signers (Optional) - List of AWS account IDs (or self) that you want to allow to create signed URLs for private content. See the CloudFront User Guide for more information about this feature.
    #  viewer_protocol_policy (Required) - Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern.
  }

  # see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#ordered_cache_behavior
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    iterator = behavior

    content {
      target_origin_id           = behavior.value.target_origin_id
      path_pattern               = try(behavior.value.path_pattern, "*")
      allowed_methods            = try(behavior.value.allowed_methods, ["GET", "HEAD", "OPTIONS"])
      cached_methods             = try(behavior.value.cached_methods, ["GET", "HEAD", "OPTIONS"])
      # forward rules
      cache_policy_id            = try(behavior.value.cache_policy_id, null)
      origin_request_policy_id   = try(behavior.value.origin_request_policy_id, null)

      #
      viewer_protocol_policy     = try(behavior.value.viewer_protocol_policy, "https-only")
      compress                   = try(behavior.value.compress, false)
      #
      default_ttl                = try(behavior.value.default_ttl, 86400)
      min_ttl                    = try(behavior.value.min_ttl, 0)
      max_ttl                    = try(behavior.value.max_ttl, 31536000)
      smooth_streaming           = try(behavior.value.smooth_streaming, true)
      realtime_log_config_arn    = try(behavior.value.realtime_log_config_arn, null)
      trusted_signers            = try(behavior.value.trusted_signers, null)
      trusted_key_groups         = try(behavior.value.trusted_key_groups, null)
      response_headers_policy_id = try(behavior.value.response_headers_policy_id, null)

      dynamic "lambda_function_association" {
        for_each = try(behavior.value.lambda_functions, {})
        iterator = lambda
        content {
          event_type   = lambda.value.event_type # lambda_function_association.value["event_type"]
          lambda_arn   = lambda.value.arn
          include_body = try(lambda.value.include_body, false)
        }
      }

      dynamic "function_association" {
        for_each = try(behavior.value.cloudfront_functions, {})
        iterator = ass
        content {
          event_type   = ass.value.event_type
          function_arn = ass.value.function_arn
        }
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.viewer_minimum_protocol_version
  }

  dynamic "custom_error_response" {
    for_each = flatten([local.custom_error_response])

    content {
      error_code = custom_error_response.value["error_code"]

      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.context.tags, {
    Name = format("%s-cf-dist", local.cloudfront_name_prefix)
  })

}
