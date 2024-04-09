output "distribution_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "oac_id" {
  value = aws_cloudfront_origin_access_control.this.id
}

output "oac_name" {
  value = aws_cloudfront_origin_access_control.this.name
}

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
