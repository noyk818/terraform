data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_user_arn   = data.aws_caller_identity.current.arn
  aws_user_id    = data.aws_caller_identity.current.user_id
  s3_bucket_name = "terraform-demo-${local.aws_account_id}"
}

// 1回目実行後にコメントアウトを外して2回目実行
data "aws_s3_bucket" "terraform_demo" {
  bucket = local.s3_bucket_name
}