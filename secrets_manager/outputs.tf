

output "pinecone_secret_arn" {
  value = aws_secretsmanager_secret_version.pinecone_api_key.arn
}