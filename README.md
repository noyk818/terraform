# terraform
# メモ
- tfstate：状態情報を保持するファイル
- tfstate.backup：上記の1世代前
- dataブロック：既存の情報を参照する
- localsブロック：ローカル変数を定義
- variableブロック：環境毎の変数を定義
- resourceブロック：
# コマンド
## 実行
terraform init
terraform plan
terraform apply
## フォーマットを揃える
terraform fmt
## インポートしたい(importsブロックを追加後)
terraform plan -generate-config-out=test2.tf
terraform import aws_ecs_task_definition.my_task my-task-family:498
## 登録されているリソース確認
terraform state list
terraform state show {リソース}

# 設定
## アカウント情報とかを共有したい場合
### Windows
mklink shared.tf ..\shared.tf
### Linux
ln -s ../shared.tf shared.tf