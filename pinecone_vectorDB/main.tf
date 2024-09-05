
terraform {
  required_providers {
	pinecone = {
	  source = "pinecone-io/pinecone"
	}
  }
}


resource "pinecone_index" "knowledge_base" {

  dimension = 1024
  name      = "tf-bedrock-knowledge-base"
  metric 	= "cosine"
  spec = {
	serverless = {
	  cloud  = "aws"
	  region = var.pinecone_environment
	}
  }
}