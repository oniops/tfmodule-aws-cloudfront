output "id" {
  value = try( aws_cloudfront_key_group.this[0].id, "")
}

output "name" {
  value = try( aws_cloudfront_key_group.this[0].name, "")
}