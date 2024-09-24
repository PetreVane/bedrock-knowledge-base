
output "ecr_repository_name" {
  value = aws_ssm_parameter.ecr_repository_name.value
}

output "ecr_repository_arn" {
  value = aws_ssm_parameter.ecr_repository_arn.value
}

output "bedrock_user_access_key_id" {
  value = aws_ssm_parameter.bedrock_user_access_key_id.arn
}

output "bedrock_user_access_key_secret" {
  value = aws_ssm_parameter.bedrock_user_access_key_secret.arn
}

output "anthropic_api_key" {
  value = aws_ssm_parameter.anthropic_api_key.arn
}