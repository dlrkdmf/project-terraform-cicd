resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline-role"
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
                }
            ]
        }
    EOF
}

# S3 FullAccess 정책 연결
resource "aws_iam_role_policy_attachment" "attach3" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = data.aws_iam_policy.S3_FullAccess.arn
}

# CodeBuildAdminAccess 정책
data "aws_iam_policy" "CodeBuildAdminAccess" {
    name = "AWSCodeBuildAdminAccess"
}

# CodeBuildAdminAccess 정책 연결
resource "aws_iam_role_policy_attachment" "attach4" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = data.aws_iam_policy.CodeBuildAdminAccess.arn
}

# AmazonECS_FullAccess 정책
data "aws_iam_policy" "ECSFullAccess" {
    name = "AmazonECS_FullAccess"
}

# AmazonECS_FullAccess 정책 연결
resource "aws_iam_role_policy_attachment" "attach5" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = data.aws_iam_policy.ECSFullAccess.arn
}

# codepipeline_bucket 버킷 생성
resource "aws_s3_bucket" "mybucket" {
    bucket = "bucket-1203"
}

resource "aws_s3_bucket_accelerate_configuration" "example" {
    bucket = aws_s3_bucket.mybucket.id
    status = "Enabled"
}

# code pipeline 구성
resource "aws_codepipeline" "my_pipeline" {
    name = "my-pipeline" 
    role_arn = aws_iam_role.codepipeline_role.arn
    artifact_store {
        location = aws_s3_bucket.mybucket.bucket
        type = "S3"
    }
    # source stage
    stage {
        name = "Source"
        action {
            name = "Source"
            category = "Source"
            owner = "ThirdParty"
            provider = "GitHub"
            version = "1"
            output_artifacts = ["source_output"]
            configuration = {
                Owner = var.github_owner
                Repo = var.github_repo
                Branch = var.github_branch
                OAuthToken = var.github_token
            }
        }
    }
    # Build Stage
    stage {
        name = "Build"
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["source_output"]
            output_artifacts = ["build_output"]
            configuration = {
                ProjectName = aws_codebuild_project.my_build.name
            }
            }
        }

    # Deploy Stage
    stage {
        name = "Deploy"
        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "ECS"
            input_artifacts = ["build_output"]
            version = "1"
            configuration = {
                ClusterName = aws_ecs_cluster.my_cluster.name
                ServiceName = aws_ecs_service.my-web-svc.name
                FileName = "imagedefinitions.json"
             }
        }
    }
}

    



            