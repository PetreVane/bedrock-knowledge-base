# Fetch the current AWS partition information
data "aws_partition" "current" {}

# Fetch the current AWS region information
data "aws_region" "current" {}

# Generate a random ID with a byte length of 4 for unique identification
resource "random_id" "generator" {
  byte_length = 4
}

# Create an AWS Bedrock agent knowledge base using Pinecone for storage
resource "aws_bedrockagent_knowledge_base" "knowledge_base_with_pinecone" {
  # Set the name of the knowledge base, appending a random hex ID for uniqueness
  name = "${var.knowledge_base_name}-${random_id.generator.hex}"
  
  # Provide a description for the knowledge base
  description = var.knowledge_base_description
  
  # Specify the IAM role ARN that the knowledge base will assume
  role_arn = var.knowledge_base_role_arn
  
  # Configure the knowledge base settings
  knowledge_base_configuration {
    # Set the type of knowledge base to VECTOR
    type = "VECTOR"
    
    # Define the vector knowledge base configuration
    vector_knowledge_base_configuration {
      # Specify the ARN of the embedding model using the current partition and region
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedings_model}"
    }
  }
  
  # Configure the storage settings for the knowledge base
  storage_configuration {
    # Set the storage type to PINECONE
    type = "PINECONE"
    
    # Define the Pinecone configuration settings
    pinecone_configuration {
      # Provide the connection string for Pinecone
      connection_string       = "https://${var.pinecone_connection_string}"
      
      # Specify the ARN for the credentials secret used to access Pinecone
      credentials_secret_arn  = "${var.pinecone_credential_secret_arn}"
      
      # Map fields for text and metadata
      field_mapping {
        text_field      = "text"       # Field for storing text data
        metadata_field  = "metadata"   # Field for storing metadata
      }
    }
  }
}

# Create a data source for the knowledge base
resource "aws_bedrockagent_data_source" "kb_data_source" {
  # Link the data source to the created knowledge base using its ID
  knowledge_base_id = aws_bedrockagent_knowledge_base.knowledge_base_with_pinecone.id
  
  # Set the name of the data source
  name              = var.data_source_name
  
  # Provide a description for the data source
  description       = var.data_source_description
  
  # Set the data deletion policy to retain data upon deletion
  data_deletion_policy  = "RETAIN"

  # Configure the data source settings
  data_source_configuration {
    # Set the type of data source to S3
    type = "S3"
    
    # Define the S3 configuration settings
    s3_configuration {
      # Specify the ARN of the S3 bucket where data is stored
      bucket_arn          = var.source_bucket_arn
    }
  }
}
