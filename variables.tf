variable "create" {
  type    = bool
  default = true
}

# CloudFront Variables
variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the distribution is enabled to accept end user requests for content."
}

variable "service_name" {
  type = string
}

variable "wait_for_deployment" {
  type    = bool
  default = true
}

# origin_access_control
variable "origin_access_control_description" {
  type        = string
  default     = null
  description = "The description of origin that this Origin Access Control is for."
}

variable "origin_access_control_origin_type" {
  type        = string
  default     = "s3"
  description = "The type of origin that this Origin Access Control is for. Valid values are s3, and mediastore"
}

variable "signing_protocol" {
  type        = string
  default     = "sigv4"
  description = "Determines how CloudFront signs (authenticates) requests.The only valid value is sigv4."
}

variable "signing_behavior" {
  type        = string
  default     = "always"
  description = "Specifies which requests CloudFront signs. Valid values are always, never, and no-override."
}

variable "is_ipv6_enabled" {
  type        = bool
  default     = true
  description = "Whether the IPv6 is enabled for the distribution."
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
}

variable "bucket_regional_domain_name" {
  type = string
}

variable "bucket_domain_name" {
  type = string
}

variable "origin_path" {
  type        = string
  default     = ""
  description = "Optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin."
}

variable "origin_access_control_id" {
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
  type        = string
  description = "CloudFront provides two ways to send authenticated requests to an Amazon S3 origin: origin access control (OAC) and origin access identity (OAI). OAC helps you secure your origins, such as for Amazon S3."
  default     = null
}

variable "connection_attempts" {
  type        = number
  description = "Number of times that CloudFront attempts to connect to the origin. Must be between 1-3. Defaults to 3."
  default     = null
}

variable "connection_timeout" {
  type        = number
  description = "Number of seconds that CloudFront waits when trying to establish a connection to the origin. Must be between 1-10. Defaults to 10."
  default     = null
}


variable "origin_shield" {
  type = object({
    enabled = bool
    region  = string
  })
  default     = null
  description = <<EOF
Using Origin Shield can help reduce the load on your origin.
  see - https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
  origin_shield = {
    enabled = true
    region  = "us-east-1"
  }
EOF
}

variable "custom_header" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
  description = <<EOF
List of one or more custom headers passed to the origin
  see - https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
  custom_header = [
    {
      "Cache-Control" = "X-Custom-Header",
      "HeaderValue": "MyCustomValue"
    }
  ]
EOF
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100"
  description = <<EOF
  Price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100.

PriceClass_100: North America + Europe and Israel
PriceClass_200: North America + Europe and Israel + Asia + India
PriceClass_All: ALL

EOF

}

variable "domain_aliases" {
  type = list(string)
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  default     = null # ["tools.customer.co.kr"]
}

variable "create_origin_access_identity" {
  type    = bool
  default = false
}

variable "origin_access_identities" {
  type = map(string)
  default = {}
  description = <<EOF

  origin_access_identities = {
    s3_oac = "CloudFront can access by s3_oac"
    s3_two = "CloudFront can access by s3_two"
  }
EOF

}

################################################################################
# default_cache_behavior
################################################################################

variable "allowed_methods" {
  type = list(string)
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. ` GET, PUT, POST, DELETE, HEAD`) for AWS CloudFront"
}

variable "cached_methods" {
  type = list(string)
  default = ["GET", "HEAD"]
  description = "List of cached methods (e.g. ` GET, PUT, POST, DELETE, HEAD`)"
}

variable "cache_policy_id" {
  type        = string
  default     = ""
  description = "Unique identifier of the cache policy that is attached to the cache behavior. If configuring the default_cache_behavior either cache_policy_id or forwarded_values must be set."
}

variable "viewer_protocol_policy" {
  type        = string
  default     = "redirect-to-https"
  description = "Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId. One of allow-all, https-only, or redirect-to-https."
}

variable "default_ttl" {
  type        = number
  default     = 3600
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "max_ttl" {
  type        = number
  default     = 86400
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "compress" {
  type        = bool
  default     = true
  description = "Whether you want CloudFront to automatically compress content for web requests."
}

variable "field_level_encryption_id" {
  type        = string
  default     = ""
  description = "Field level encryption configuration ID"
}

###########################################################
# forwarded_values - Deprecated use cache_policy_id or origin_request_policy_id instead
###########################################################
variable "use_forwarded_values" {
  type    = bool
  default = false
}

variable "forward_headers" {
  description = "Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify `*` to include all headers."
  type = list(string)
  default = []
}

variable "forward_query_string" {
  type        = bool
  default     = false
  description = "Forward query strings to the origin that is associated with this cache behavior"
}

variable "query_string_cache_keys" {
  type        = list(string)
  default     = []
  description = <<EOF
When specified, along with a value of true for query_string, all query strings are forwarded, however only the query string keys listed in this argument are cached.

  query_string_cache_keys = ["is_login", "has_permission"]
EOF
}

variable "whitelisted_names" {
  type        = list(string)
  default     = []
  description = <<EOF
If you have specified whitelist to forward, the whitelisted cookies that you want CloudFront to forward to your origin.

  whitelisted_names = ["ridi_app_theme", "stage"]
EOF
}

variable "forward_cookies" {
  type        = string
  description = "Specifies whether you want CloudFront to forward cookies to the origin. Valid options are all, none or whitelist"
  default     = "none"
}

# viewer_certificate
variable "cloudfront_default_certificate" {
  type        = bool
  description = "if you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution"
  default     = false
}

variable "acm_certificate_arn" {
  type        = string
  description = "Existing ACM Certificate ARN"
  # default     = null
}

variable "viewer_minimum_protocol_version" {
  type        = string
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Valid value is TLSv1.2_2019 or TLSv1.2_2021"
  default     = "TLSv1.2_2021"
}

variable "enable_custom_error_response" {
  type    = bool
  default = false
}

variable "trusted_key_groups" {
  description = "List of key group IDs that CloudFront can use to validate signed URLs or signed cookies"
  type = list(string)
  default     = null
}

################################################################################
# ordered_cache_behaviors
################################################################################

variable "ordered_cache_behaviors" {
  type = any
  default = []

  description = <<EOF
List of configuration map of Cache behaviours for the distribution where each entry will be of
the same strcuture as `default_cache_behavior` except one additional:
path_pattern: (Optional) The pattern (for example, images/*.jpg) that specifies which requests this cache behavior to apply to.

  ordered_cache_behavior = [
    {
      target_origin_id           = "my-content-s3"
      path_pattern               = "/contents/reports/*"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      cache_policy_id            = aws_cloudfront_cache_policy.some.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.some.id
      viewer_protocol_policy     = "redirect-to-https" # One of allow-all, https-only, or redirect-to-https.
      compress                   = true
      min_ttl                    = 0
      default_ttl                = 86400
      max_ttl                    = 31536000
      realtime_log_config_arn    = null
      trusted_key_groups         = [aws_cloudfront_key_group.some.id]
      response_headers_policy_id = aws_cloudfront_response_headers_policy.some.id

      lambda_functions = {
        event_type   = "viewer-request"
        lambda_arn   = aws_lambda_function.some.qualified_arn
        include_body = false
      }

      cloudfront_functions = {
        event_type   = "viewer-request" # Valid values are viewer-request and viewer-response.
        function_arn = cloudfront_functions.some.arn
      }

      forwarded_values = {
        event_type   = "viewer-request" # Valid values are viewer-request and viewer-response.
        function_arn = cloudfront_functions.some.arn
      }



    },
  ]

EOF
}

variable "logging_config" {
  type        = any
  default = {}
  description = <<EOF
The logging configuration that controls how logs are written to your distribution (maximum one).

  logging_config = {
    include_cookies = false
    bucket          = module.log_bucket.s3_bucket_bucket_domain_name
    prefix          = "cloudfront/"
    enabled         = true
  }
EOF
}

variable "web_acl_arn" {
  type        = string
  description = "ARN of the AWS WAF web ACL that is associated with the distribution"
  default     = ""
}
