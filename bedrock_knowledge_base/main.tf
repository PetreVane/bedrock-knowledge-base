data "aws_partition" "current" {}
data "aws_region" "current" {}

resource "random_id" "generator" {
  byte_length = 4
}

resource "aws_bedrockagent_knowledge_base" "knowledge_base_with_pinecone" {
  name        = "${var.knowledge_base_name}-${random_id.generator.hex}"
  description = var.knowledge_base_description
  role_arn    = var.knowledge_base_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedings_model}"
    }
  }

  storage_configuration {
    type = "PINECONE"
    pinecone_configuration {
      connection_string       = "https://${var.pinecone_connection_string}"
      credentials_secret_arn  = "${var.pinecone_credential_secret_arn}"
      field_mapping {
        text_field      = "text"
        metadata_field  = "metadata"
      }
    }
  }
}

resource "aws_bedrockagent_data_source" "kb_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.knowledge_base_with_pinecone.id
  name              = var.data_source_name
  description       = var.data_source_description
  data_deletion_policy  = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn          = var.source_bucket_arn
    }
  }
}