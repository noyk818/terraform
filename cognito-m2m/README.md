# 概要
- Cognitoを構築してM2MのCredential認証を行う

# 使用リソース
- aws_cognito_user_pool
  - ユーザプール作成
- aws_cognito_user_pool_client
  - アプリケーションクライアント作成
  - カスタムスコープ設定
- aws_cognito_resource_server
  - リソースサーバ作成
  - カスタムスコープ設定

# 認証試験
curl -X POST \
  -u "<ClientId>:<ClientSecret>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&scope=https://api.example.com/read" \
  https://myapp-m2m.auth.ap-northeast-1.amazoncognito.com/oauth2/token 

# JWT内容
{
  "kid": "<kid>",
  "alg": "RS256"
}
{
  "sub": "<sub>",
  "token_use": "access",
  "scope": "https://api.example.com/read",
  "auth_time": 1746164626,
  "iss": "https://cognito-idp.ap-northeast-1.amazonaws.com/<poolId>",
  "exp": 1746168226,
  "iat": 1746164626,
  "version": 2,
  "jti": "<jti>",
  "client_id": "<clientId>"
}
