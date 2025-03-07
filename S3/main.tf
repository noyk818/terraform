// 1回目
# resource "aws_s3_bucket" "terraform_demo" {
#   bucket = local.s3_bucket_name
# }

// 2回目
resource "aws_s3_bucket" "terraform_demo" {
  acceleration_status = null
  arn                 = data.aws_s3_bucket.terraform_demo.arn
  bucket              = data.aws_s3_bucket.terraform_demo.bucket
  force_destroy = true
  object_lock_enabled = false
  tags          = {}
  tags_all      = {}
}

resource "aws_s3_bucket_versioning" "terraform_demo_versioning" {
  bucket = data.aws_s3_bucket.terraform_demo.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_demo_sse" {
  bucket = data.aws_s3_bucket.terraform_demo.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = null
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_request_payment_configuration" "terraform_demo_request_payment" {
  bucket = data.aws_s3_bucket.terraform_demo.bucket
  payer = "BucketOwner"
}