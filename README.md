# tfmodule-aws-cloudfront

## Usage

사전에, SSM ParameterStore에 CloudFront Public Key를 등록해야 합니다. (예: `/dev/cloudfront/contents/publicKey`)

```hcl
locals {
  project = "demo"
  context = {
    region      = "ap-northeast-2"
    project     = local.project
    pri_domain  = "backend.opsnow.com"
    name_prefix = "demo-an2d"
    tags        = {
      Team = "DevOps"
    }
  }
}

data "aws_cloudfront_cache_policy" "cache" {
  name = "Managed-CachingOptimized"
}

module "cfKeyGrp" {
  source      = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-cloudfront.git?ref=v1.0.0//keygroup/"
  name        = "${local.project}-cf-keygroup"
  public_keys = {
    "contents-s3-pub" = {
      comments         = "Generate Cloudfront Presign URLs for contents-s3"
      encoded_key_path = "/dev/cloudfront/contents/publicKey"
    }
  }
}

module "cf" {
  source = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-cloudfront.git?ref=v1.0.0"

  context                     = module.ctx.context
  service_name                = "contents"
  #
  bucket_domain_name          = "dev-an2d-contents-s3.s3.amazonaws.com"
  bucket_regional_domain_name = "dev-an2d-contents-s3.s3.ap-northeast-2.amazonaws.com"
  acm_certificate_arn         = data.aws_acm_certificate.this.arn
  domain_aliases              = [local.domain_aliases]

  ordered_cache_behaviors = var.public_keys != null ? [
    {
      target_origin_id       = module.s3Contents.bucket_domain_name
      path_pattern           = "/reports/*"
      default_ttl            = 0
      max_ttl                = 0
      viewer_protocol_policy = "redirect-to-https"
      trusted_key_groups     = [module.cfKeyGrp.id]
      cache_policy_id        = data.aws_cloudfront_cache_policy.cache.id
      compress               = true
    },
    {
      target_origin_id       = module.s3Contents.bucket_domain_name
      path_pattern           = "/uploads/*"
      default_ttl            = 0
      max_ttl                = 0
      viewer_protocol_policy = "redirect-to-https"
      trusted_key_groups     = [module.cfKeyGrp.id]
      cache_policy_id        = data.aws_cloudfront_cache_policy.cache.id
      compress               = true
    }
  ] : []

  depends_on = [module.cfKeyGrp]
}


```