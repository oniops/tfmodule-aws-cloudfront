variable "name" {
  type        = string
  description = "A name to identify the key group."
}

variable "comment" {
  type        = string
  default     = null
  description = "A comment to describe the key group."
}

variable "public_keys" {
  type        = map(any)
  default     = {}
  description = <<EOF
Collection of Configuration map (with following key-pair) for Public Keys.

  public_keys = {
    contentS3 = {
      encoded_key_path = "/my/cloudfront/contents/publicKey"         # (Required) The ssm parameter-store path for the public key.
      comments = "Generate Cloudfront Presign URLs for contents-s3"   # (Optional) Any comments about the public key.
    }
    fileStoreS3 = {
      encoded_key_path = "/my/cloudfront/filestore/publicKey"
      comments = "Generate Cloudfront Presign URLs for file-store-s3"
    }
  }
EOF
}