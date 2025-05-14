# see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
# see - https://github.com/ankit-jn/terraform-aws-examples/blob/main/aws-cdn/dev.tfvars

locals {
  project                       = var.context.project
  cloudfront_name_prefix        = "${local.project}-${var.service_name}"
  cloudfront_name               = "${local.cloudfront_name_prefix}-cf"
  create                        = var.create
  create_origin_access_control  = local.create && var.create_origin_access_control && var.origin_access_control_id == null
  create_origin_access_identity = local.create && !var.create_origin_access_control && var.origin_access_identity != null

  custom_error_response = var.enable_custom_error_response ? [
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

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  comment             = local.cloudfront_name
  price_class         = var.price_class
  aliases             = var.domain_aliases
  retain_on_delete    = false
  wait_for_deployment = var.wait_for_deployment

  dynamic "logging_config" {
    for_each = length(keys(var.logging_config)) == 0 ? [] : [var.logging_config]

    content {
      bucket = logging_config.value["bucket"]
      prefix = lookup(logging_config.value, "prefix", null)
      include_cookies = lookup(logging_config.value, "include_cookies", null)
    }
  }

  origin {
    domain_name         = var.origin_domain_name
    origin_id           = var.origin_id
    origin_path = var.origin_path
    # origin_access_control_id = local.create_origin_access_control ? aws_cloudfront_origin_access_control.this[0].id : var.origin_access_control_id
    connection_attempts = var.connection_attempts
    connection_timeout  = var.connection_timeout

    dynamic "s3_origin_config" {
      for_each = local.create_origin_access_identity ? [1] : []
      content {
        origin_access_identity = lookup(lookup(aws_cloudfront_origin_access_identity.this, "origin-access-identity", {}), "cloudfront_access_identity_path", "")
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.custom_origin_config
      content {
        http_port              = custom_origin_config.value.http_port
        https_port             = custom_origin_config.value.https_port
        origin_protocol_policy = custom_origin_config.value.origin_protocol_policy
        origin_ssl_protocols   = custom_origin_config.value.origin_ssl_protocols
        origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
        origin_read_timeout = lookup(custom_origin_config.value, "origin_read_timeout", null)
      }
    }

    #    s3_origin_config - (Optional) CloudFront S3 origin configuration information. If a custom origin is required, use custom_origin_config instead.
    #    custom_origin_config - The CloudFront custom origin configuration information. If an S3 origin is required, use origin_access_control_id or s3_origin_config instead.

    dynamic "origin_shield" {
      for_each = var.origin_shield != null ? [true] : []
      content {
        enabled              = var.origin_shield.enabled
        origin_shield_region = var.origin_shield.region
      }
    }

    #  custom_header (Optional) - One or more sub-resources with name and value parameters that specify header data that will be sent to the origin (multiples allowed).
    dynamic "custom_header" {
      for_each = var.custom_header
      content {
        name  = custom_header.key
        value = custom_header.value
      }
    }

  }

  # see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#default_cache_behavior
  default_cache_behavior {

    #  origin_request_policy_id (Optional) - Unique identifier of the origin request policy that is attached to the behavior.
    #  path_pattern (Required) - Pattern (for example, images/*.jpg) that specifies which requests you want this cache behavior to apply to.
    #  realtime_log_config_arn (Optional) - ARN of the real-time log configuration that is attached to this cache behavior.
    #  response_headers_policy_id (Optional) - Identifier for a response headers policy.
    #  smooth_streaming (Optional) - Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior.
    #  trusted_key_groups (Optional) - List of key group IDs that CloudFront can use to validate signed URLs or signed cookies. See the CloudFront User Guide for more information about this feature.
    #  trusted_signers (Optional) - List of AWS account IDs (or self) that you want to allow to create signed URLs for private content. See the CloudFront User Guide for more information about this feature.

    target_origin_id           = var.origin_id
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    viewer_protocol_policy     = var.viewer_protocol_policy
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    compress                   = var.compress
    field_level_encryption_id  = var.field_level_encryption_id

    # Deprecated
    # default_ttl               = var.cache_policy_id == null || var.cache_policy_id == "" ? var.default_ttl : 0
    # min_ttl                   = var.cache_policy_id == null || var.cache_policy_id == "" ? var.min_ttl : 0
    # max_ttl                   = var.cache_policy_id == null || var.cache_policy_id == "" ? var.max_ttl : 0

    # Deprecated
    # dynamic "forwarded_values" {
    #   for_each = var.use_forwarded_values ? [true] : []
    #   content {
    #     headers                 = var.forward_headers
    #     query_string            = var.forward_query_string
    #     query_string_cache_keys = var.query_string_cache_keys
    #     cookies {
    #       forward               = var.forward_cookies
    #       whitelisted_names     = var.whitelisted_names
    #     }
    #   }
    # }

    dynamic "lambda_function_association" {
      for_each = var.lambda_functions
      iterator = lambda
      content {
        event_type   = lambda.value.event_type
        lambda_arn   = lambda.value.lambda_arn
        include_body = lambda.value.include_body
      }
    }

    dynamic "function_association" {
      for_each = var.cloudfront_functions
      iterator = func
      content {
        event_type   = func.value.event_type
        function_arn = func.value.function_arn
      }
    }

  }

  # see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#ordered_cache_behavior
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    iterator = behavior

    content {
      target_origin_id = behavior.value.target_origin_id
      path_pattern = try(behavior.value.path_pattern, "*")
      allowed_methods = try(behavior.value.allowed_methods, ["GET", "HEAD", "OPTIONS"])
      cached_methods = try(behavior.value.cached_methods, ["GET", "HEAD", "OPTIONS"])
      viewer_protocol_policy = try(behavior.value.viewer_protocol_policy, "https-only")
      cache_policy_id = try(behavior.value.cache_policy_id, null)
      origin_request_policy_id = try(behavior.value.origin_request_policy_id, null)
      response_headers_policy_id = try(behavior.value.response_headers_policy_id, null)
      compress = try(behavior.value.compress, false)
      field_level_encryption_id = try(behavior.value.field_level_encryption_id, "")
      smooth_streaming = try(behavior.value.smooth_streaming, true)
      realtime_log_config_arn = try(behavior.value.realtime_log_config_arn, null)
      trusted_signers = try(behavior.value.trusted_signers, null)
      trusted_key_groups = try(behavior.value.trusted_key_groups, null)

      # Deprecated
      # default_ttl      = try(behavior.value.cache_policy_id, null) == null ? try(behavior.value.default_ttl, 86400) : 0
      # min_ttl          = try(behavior.value.cache_policy_id, null) == null ? try(behavior.value.min_ttl, 0) : 0
      # max_ttl          = try(behavior.value.cache_policy_id, null) == null ? try(behavior.value.max_ttl, 31536000) : 0

      # dynamic "forwarded_values" {
      #   for_each = try(behavior.value.use_forwarded_values, false) ? [true] : []
      #
      #   content {
      #     headers                 = try(behavior.value.headers, [])
      #     query_string            = try(behavior.value.query_string, false)
      #     query_string_cache_keys = try(behavior.value.query_string_cache_keys, [])
      #
      #     cookies {
      #       forward               = try(behavior.value.cookies_forward, "none")
      #       whitelisted_names     = try(behavior.value.cookies_whitelisted_names, [])
      #     }
      #   }
      # }

      dynamic "lambda_function_association" {
        for_each = try(behavior.value.lambda_functions, [])
        iterator = lambda
        content {
          event_type = lambda.value.event_type
          lambda_arn = lambda.value.lambda_arn
          include_body = try(lambda.value.include_body, false)
        }
      }

      dynamic "function_association" {
        for_each = try(behavior.value.cloudfront_functions, [])
        iterator = func
        content {
          event_type   = func.value.event_type
          function_arn = func.value.function_arn
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
      response_code = lookup(custom_error_response.value, "response_code", null)
      response_page_path = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.web_acl_arn

  tags = merge(var.context.tags, {
    Name = local.cloudfront_name
  })

}
