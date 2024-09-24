

output "pinecone_secret_arn" {
  value = aws_secretsmanager_secret_version.pinecone_api_key.arn
}

output "bedrock_user_credentials_arn" {
  value = aws_secretsmanager_secret_version.bedrock_user_credentials.arn
}

output "anthropic_api_key_arn" {
  value = aws_secretsmanager_secret_version.anthropic_api_key.arn
}