output "ecr_uri" {
 description = "AWS ECR URI"
 value = aws_ecr_repository.my_ecr.repository_url
}
