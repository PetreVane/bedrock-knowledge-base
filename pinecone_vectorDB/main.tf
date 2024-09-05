# Specify the Terraform configuration block
terraform {
  required_providers {
	pinecone = {
	  source = "pinecone-io/pinecone"  # Source of the Pinecone provider
	}
  }
}

# Create a Pinecone index resource for the knowledge base
resource "pinecone_index" "knowledge_base" {
  dimension = 1024                          # Set the dimensionality of the index to 1024
  name      = "tf-bedrock-knowledge-base"   # Name of the Pinecone index
  metric    = "cosine"                      # Specify the similarity metric to use (cosine similarity)
  
  # Define the specifications for the index
  spec = {
    serverless = {                          # Configuration for serverless deployment
      cloud  = "aws"                        # Specify the cloud provider as AWS
      region = var.pinecone_environment      # Set the region using the provided variable
    }
  }
}
