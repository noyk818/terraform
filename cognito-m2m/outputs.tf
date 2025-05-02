output "region" {
  value = var.default_region
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_user_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_user_id" {
  value = data.aws_caller_identity.current.user_id
}
