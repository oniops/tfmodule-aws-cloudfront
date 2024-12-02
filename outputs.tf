output "id" {
  value = aws_cloudfront_distribution.this.id
}

output "arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "oac_id" {
  value = try(aws_cloudfront_origin_access_control.this[0].id, null)
}

output "oac_name" {
  value = try(aws_cloudfront_origin_access_control.this[0].name, null)
}

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
