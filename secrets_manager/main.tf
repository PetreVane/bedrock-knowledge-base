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
