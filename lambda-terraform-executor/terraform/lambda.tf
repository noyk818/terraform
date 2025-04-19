locals {
  aws_account_id   = data.aws_caller_identity.current.account_id
  aws_user_arn     = data.aws_caller_identity.current.arn
  aws_user_id      = data.aws_caller_identity.current.user_id
  lambda_file_name = "../lambda.zip"
}

# Lambdaのロールを作成し、ECSのフルアクセス権限を付与
resource "aws_iam_role" "ecs_lambda_role" {
  name = "ecs-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_lambda_policy" {
  name       = "attach-ecs"
  roles      = [aws_iam_role.ecs_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# LambdaのFunctionを作成
# ECSの起動と停止を行うLambda関数を作成する
resource "aws_lambda_function" "ecs_scheduler" {
  function_name    = "ecs-scheduler"
  role             = aws_iam_role.ecs_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = local.lambda_file_name
  source_code_hash = filebase64sha256("${local.lambda_file_name}")

  environment {
    variables = {
      CLUSTER_NAME = "cluster-name"
      SERVICE_NAME = "service-name1,service-name2" # 複数のサービス名をカンマ区切りで指定
    }
  }
}

# event ruleを作成
# 8時にECSを起動、10時にECSを停止する
resource "aws_cloudwatch_event_rule" "start_ecs" {
  name                = "start-ecs"
  schedule_expression = "cron(0 23 * * ? *)" # UTC時間で23時は日本時間の8時
}

resource "aws_cloudwatch_event_rule" "stop_ecs" {
  name                = "stop-ecs"
  schedule_expression = "cron(0 13 * * ? *)" # UTC時間で13時は日本時間の22時
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_ecs.name
  target_id = "StartECSTarget"
  arn       = aws_lambda_function.ecs_scheduler.arn
  input     = jsonencode({ desiredCount = 1 })
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_ecs.name
  target_id = "StopECSTarget"
  arn       = aws_lambda_function.ecs_scheduler.arn
  input     = jsonencode({ desiredCount = 0 })
}
