
# 1. create a secret manager
# 2. store the pinecone api key in secret manager
# 3. update the knowledge base role so that it can read this secret only

resource "aws_secretsmanager_secret" "pinecone_api_key" {
  name = "apiKey"
}

resource "aws_secretsmanager_secret_version" "pinecone_api_key" {
  secret_id = aws_secretsmanager_secret.pinecone_api_key.id
  secret_string = var.pinecone_api_key
}