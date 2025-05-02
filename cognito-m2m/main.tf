locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_user_arn   = data.aws_caller_identity.current.arn
  aws_user_id    = data.aws_caller_identity.current.user_id
}

resource "aws_cognito_user_pool" "this" {
  name = "user-pool-m2m"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "myapp-m2m"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "client_credentials" {
  name            = "m2m-client"
  user_pool_id    = aws_cognito_user_pool.this.id
  generate_secret = true

  allowed_oauth_flows                   = ["client_credentials"]
  allowed_oauth_scopes                 = [
    "${aws_cognito_resource_server.api.identifier}/read",
    "${aws_cognito_resource_server.api.identifier}/write"
  ]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_resource_server" "api" {
  identifier = "https://api.example.com"
  name       = "example-api"

  scope {
    scope_name  = "read"
    scope_description = "Read access to the API"
  }

  scope {
    scope_name  = "write"
    scope_description = "Write access to the API"
  }

  user_pool_id = aws_cognito_user_pool.this.id
}
