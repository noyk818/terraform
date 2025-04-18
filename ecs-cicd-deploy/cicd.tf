# ECRリポジトリ
resource "aws_ecr_repository" "html_repo" {
  name = "html-site-demo"
}

# S3バケット（CodePipelineアーティファクト用）
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "html-codepipeline-artifacts-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# IAMロール（CodeBuild用）
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_base_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "CodeBuildPolicy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.default_region}:${local.aws_account_id}:log-group:/aws/codebuild/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.bucket}/*"
      }
    ]
  })
}

# IAMポリシー（CodeStar用）
resource "aws_iam_role_policy" "codestar_connection_policy" {
  name = "AllowUseOfCodestarConnection"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = aws_codestarconnections_connection.github.arn
      }
    ]
  })
}

# IAMロール（CodePipeline用）
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-html-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "AllowS3ArtifactAccess"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation"
        ],
        Resource = aws_s3_bucket.codepipeline_bucket.arn
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = aws_codebuild_project.html_build.arn
      },
      {
          Effect = "Allow",
          Action = [
            "ecs:DescribeServices",
            "ecs:UpdateService",
            "ecs:RegisterTaskDefinition",
            "ecs:DescribeTaskDefinition",
            "ecs:ListTasks",
            "ecs:DescribeTasks",
            "iam:PassRole"
          ],
          Resource = "*"
      }
    ]
  })
}

# CodeStar Connections (GitHubアプリ連携)
resource "aws_codestarconnections_connection" "github" {
  name          = "html-github-connection"
  provider_type = "GitHub"
}

# CodeBuildプロジェクト
resource "aws_codebuild_project" "html_build" {
  name          = "html-site-build"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = jsonencode(tonumber(local.aws_account_id))
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = var.default_region
    }

    environment_variable {
      name  = "ENV"
      type  = "PLAINTEXT"
      value = "staging"
    }
  }
  source {
    type            = "CODEPIPELINE"
    buildspec       = "ecs-cicd-deploy/cicd/buildspec.yml"
  }
}

# CodePipeline
resource "aws_codepipeline" "html_pipeline" {
  name     = "html-deploy-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      category         = "Source"
      configuration = {
        BranchName           = "main"
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        DetectChanges        = "true"
        FullRepositoryId     = "noyk818/terraform"
      }
      name             = "Source"
      output_artifacts = ["source_output"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
    }
  }
  stage {
    name = "Build"
    action {
      category         = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.html_build.name
      }
      name             = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1" 
    }
  }
  stage {
    name = "Deploy"
    action {
      category         = "Deploy"
      configuration = {
        ClusterName     = "ecs-cluster"
        ServiceName     = "apache-service"
        FileName        = "imagedefinitions.json"
      }
      name             = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = ["build_output"]
      version          = "1" 
    }
  }
}
