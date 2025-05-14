resource "aws_cloudfront_origin_access_control" "this" {
  count       = local.create_origin_access_control ? 1 : 0
  name        = "${local.cloudfront_name}-oac"
  description = (var.origin_access_control_description != null ? var.origin_access_control_description :
    "${local.cloudfront_name}-oac policy")
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_protocol                  = var.signing_protocol
  signing_behavior                  = var.signing_behavior
}

resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = local.create_origin_access_identity ? {
    "origin-access-identity" = "CloudFront can access by ${var.origin_access_identity}"
  } : {}
  comment = each.value
  lifecycle {
    create_before_destroy = true
  }
}

output "aws_cloudfront_origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.this
}