resource "aws_s3_bucket" "terraform_demo" {
  acceleration_status = null
  bucket              = local.s3_bucket_name
  force_destroy = true
  object_lock_enabled = false
  tags          = {}
  tags_all      = {}
}

resource "aws_s3_bucket_versioning" "terraform_demo_versioning" {
  bucket = local.s3_bucket_name
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_demo_sse" {
  bucket = local.s3_bucket_name
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = null
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_request_payment_configuration" "terraform_demo_request_payment" {
  bucket = local.s3_bucket_name
  payer = "BucketOwner"
}
