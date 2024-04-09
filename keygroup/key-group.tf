locals {
  create_key_group = var.public_keys != null ?  true : false
  public_keys      = local.create_key_group ? var.public_keys : {}
}

data "aws_ssm_parameter" "this" {
  for_each = local.public_keys
  name     = each.value["encoded_key_path"]
}

resource "aws_cloudfront_public_key" "this" {
  for_each    = local.public_keys
  name        = each.key
  comment     = try(each.value["comments"], "")
  encoded_key = data.aws_ssm_parameter.this[each.key].value
  lifecycle {
    ignore_changes = [
      encoded_key
    ]
  }
}

resource "aws_cloudfront_key_group" "this" {
  count   = local.create_key_group ? 1 : 0
  name    = var.name
  comment = var.comment
  items   = [for key, _ in local.public_keys : aws_cloudfront_public_key.this[key].id]

  depends_on = [
    aws_cloudfront_public_key.this
  ]
}

#
#resource "aws_cloudfront_origin_access_identity" "this" {
#  for_each = local.create_origin_access_identity ? var.origin_access_identities : {}
#  comment = each.value
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
#
#resource aws_cloudfront_public_key "this" {
#  for_each = { for key in var.public_keys: key.name => key }
#
#  name        = each.key
#  comment     = coalesce(try(each.value.comments, ""), each.key)
#  encoded_key = file("${path.root}/${each.value.key_file}")
#
#  lifecycle {
#    ignore_changes = [
#      encoded_key
#    ]
#  }
#}
#
#resource aws_cloudfront_key_group "this" {
#  for_each = { for group in var.key_groups: group.name => group }
#
#  name        = each.key
#  comment     = coalesce(try(each.value.comments, ""), each.key)
#  items       = [for key_name in split(",", each.value.keys): aws_cloudfront_public_key.this[key_name].id]
#
#  depends_on = [
#    aws_cloudfront_public_key.this
#  ]
#}
#
#resource aws_cloudfront_field_level_encryption_profile "this" {
#  for_each = { for profile in var.encryption_profiles: profile.name => profile }
#
#  name = each.key
#  comment = coalesce(try(each.value.comments, ""), format("Encryption Profile - %s", each.key))
#
#  encryption_entities {
#    items {
#      public_key_id = aws_cloudfront_public_key.this[each.value.key_name].id
#      provider_id   = each.value.provider_id
#
#      field_patterns {
#        items = each.value.field_patterns
#      }
#    }
#  }
#
#  depends_on = [
#    aws_cloudfront_public_key.this
#  ]
#}

#resource "aws_cloudfront_public_key" "example" {
#  comment     = "example public key"
#  encoded_key = file("public_key.pem")
#  name        = "example-key"
#}

/*
  bgp_asn    = each.value["bgp_asn"]
  ip_address = each.value["ip_address"]
  type       = "ipsec.1"

  tags = merge(
    local.tags,
    var.customer_gateway_tags,
    { Name = format("%s-%s-custom-gw", local.name_prefix, each.key) },
  )
*/
