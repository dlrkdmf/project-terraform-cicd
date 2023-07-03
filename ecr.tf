# Elastic Container Registry 생성
resource "aws_ecr_repository" "my_ecr" {
    name = "my-image-repo"
    image_tag_mutability = "MUTABLE"

    force_delete = true
    
    image_scanning_configuration {
        scan_on_push = true
    }
}

# ECR 역할 생성
resource "aws_iam_role" "ecr_access_role" {
    name = "ecr-access-role"

      assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  EOF
}

# ECR 정책 
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ecr-access-policy"
  description = "Allows access to ECR repositories"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
          ],
          "Resource": "*"
        }
      ]
    }
  EOF
}

# ECR 정책 연결
resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
