

output "ecr_repository_arn" {
  value = aws_ecr_repository.docker_repository.arn
}

output "ecr_registry_id" {
  value = aws_ecr_repository.docker_repository.registry_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.docker_repository.repository_url
}

output "ecr_repository_name" {
  value = aws_ecr_repository.docker_repository.name
}