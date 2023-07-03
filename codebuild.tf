# codebuild 역할 생성
resource "aws_iam_role" "codebuild_role" {
    name = "codebuild-role"

    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codebuild.amazonaws.com"
                    },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

# ECS 정책
data "aws_iam_policy" "ECS_FullAccess" {
    name = "AmazonEC2ContainerRegistryFullAccess"
}

# ECS 정책 연결
resource "aws_iam_role_policy_attachment" "attach1" {
    role = aws_iam_role.codebuild_role.name
    policy_arn = data.aws_iam_policy.ECS_FullAccess.arn
}

# S3 정책
data "aws_iam_policy" "S3_FullAccess" {
    name = "AmazonS3FullAccess"
}

# S3 정책 연결
resource "aws_iam_role_policy_attachment" "attach2" {
    role = aws_iam_role.codebuild_role.name
    policy_arn = data.aws_iam_policy.S3_FullAccess.arn
}

# 깃허브 액세스 토큰설정
resource "aws_codebuild_source_credential" "github" {
    auth_type = "PERSONAL_ACCESS_TOKEN"
    server_type = "GITHUB"
    token = var.github_token
}

# CodeBuild Project 생성
resource "aws_codebuild_project" "my_build" {
    name = "my-project"
    description = "my_codebuild_project"

    service_role = aws_iam_role.codebuild_role.arn

    artifacts {
        type = "NO_ARTIFACTS"
    }

   environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode             = true
   }

   logs_config {
    cloudwatch_logs {
        status = "DISABLED"
    }
    s3_logs {
        status = "DISABLED"
    }
   }

   source {
    type = "GITHUB"
    location = var.git_repo_url
    git_clone_depth = 1
   }
}

# Codebuild Project Webhook 설정 - 저장소에 변경사항이 푸시되면 웹훅이 호출되어 자동으로 빌드 시작
resource "aws_codebuild_webhook" "test" {
    project_name = aws_codebuild_project.my_build.name
    build_type = "BUILD"
    filter_group {
        filter {
            type = "EVENT"
            pattern = "PUSH"
        }
    }
}
