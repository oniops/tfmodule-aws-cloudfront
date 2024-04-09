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
  type        = list(string)
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  default     = null # ["tools.customer.co.kr"]
}

variable "create_origin_access_identity" {
  type    = bool
  default = false
}

variable "origin_access_identities" {
  type        = map(string)
  default     = {}
  description = <<EOF

  origin_access_identities = {
    s3_oac = "CloudFront can access by s3_oac"
    s3_two = "CloudFront can access by s3_two"
  }
EOF

}

variable "allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. ` GET, PUT, POST, DELETE, HEAD`) for AWS CloudFront"
}

variable "cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. ` GET, PUT, POST, DELETE, HEAD`)"
}

variable "viewer_protocol_policy" {
  type        = string
  default     = "redirect-to-https"
  description = "allow-all - redirect-to-https"
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
  type    = bool
  default = true
}

variable "forward_query_string" {
  type        = bool
  default     = false
  description = "Forward query strings to the origin that is associated with this cache behavior"
}

variable "forward_headers" {
  description = "Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify `*` to include all headers."
  type        = list(string)
  default     = []
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
  type        = list(string)
  default     = null
}

variable "ordered_cache_behaviors" {
  type    = any
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
    },
  ]

EOF
}

