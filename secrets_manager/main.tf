# Generate a random ID with a byte length of 4 for unique identification
resource "random_id" "generator" {
  byte_length = 4
}

# Define local variables for the Pinecone API key
locals {
  # Create a map containing the API key variable
  pinecone_api_key = {
    apiKey = var.pinecone_api_key  # Assign the Pinecone API key from the variable
  }
}

data "aws_caller_identity" "current" {}

# Create a new secret in AWS Secrets Manager for the Pinecone API key
resource "aws_secretsmanager_secret" "pinecone_api_key" {
  # Set the name of the secret, appending a random hex ID for uniqueness
  name = "apiKey-${random_id.generator.hex}"
}

# Create a version of the secret in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "pinecone_api_key" {
  # Reference the ID of the created secret
  secret_id = aws_secretsmanager_secret.pinecone_api_key.id
  # Encode the local Pinecone API key map as a JSON string and store it as the secret value
  secret_string = jsonencode(local.pinecone_api_key)
}

resource "aws_secretsmanager_secret_policy" "pinecone_api_key_policy" {
  secret_arn = aws_secretsmanager_secret.pinecone_api_key.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.kb_name}"
        }
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.pinecone_api_key.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "bedrock_user_credentials" {
  name = "bedrock_user_key-${random_id.generator.hex}"
}

resource "aws_secretsmanager_secret_version" "bedrock_user_credentials" {
  secret_id = aws_secretsmanager_secret.bedrock_user_credentials.id
  secret_string = jsonencode({
    access_key_id = var.bedrock_user_access_key_id
    secret_access_key = var.bedrock_user_access_key_secret
  })
}

resource "aws_secretsmanager_secret" "claude_api_key" {
  name = "claude_api_key-${random_id.generator.hex}"
}

resource "aws_secretsmanager_secret_version" "claude_api_key_version" {
  secret_id = aws_secretsmanager_secret.claude_api_key.id
  secret_string = jsonencode(var.anthropic_api_key)
}

resource "aws_secretsmanager_secret_policy" "bedrock_secret_policy" {
  secret_arn = aws_secretsmanager_secret.bedrock_user_credentials.arn

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        "Action": [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ]
        "Resource": aws_secretsmanager_secret.bedrock_user_credentials.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret_policy" "claude_secret_policy" {
  secret_arn = aws_secretsmanager_secret.claude_api_key.arn

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ],
        "Resource": aws_secretsmanager_secret.claude_api_key.arn
      }
    ]
  })
}
