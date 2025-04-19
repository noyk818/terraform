# 概要
- 指定した時刻にECSを停止、起動する
- environmentのCLUSTER_NAMEとSERVICE_NAMEで指定

# 使用リソース
- aws_iam_role
- aws_iam_policy_attachment
- aws_lambda_function
- aws_cloudwatch_event_rule
  - EventBridgeのバス>ルールを作成
    - 開始、終了時刻を指定
- aws_cloudwatch_event_target
  - ターゲットでLambdaを指定し、Inputパラメータを付与

# pythonの作り方
```shell
cd lambda/
zip -r ../lambda.zip ./*
```

