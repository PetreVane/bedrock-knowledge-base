
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    pinecone = {
      source = "pinecone-io/pinecone"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "pinecone" {
  api_key     = var.pinecone_api_key
}

module "s3" {
  source = "./s3"
}

module "secrets_manager" {
  source = "./secrets_manager"
  pinecone_api_key = var.pinecone_api_key
}

module "iam" {
  source               = "./iam"
  region = var.region
  kb_source_bucket_arn = module.s3.kb_bucket_arn
  pinecone_secret_arn = module.secrets_manager.pinecone_secret_arn
  embedings_model_arn = module.bedrock.embedings_model_arn
  knowledge_base_arn = module.bedrock.knowledge_base_arn
}

module "pinecone" {
  source           = "./pinecone_vectorDB"
  pinecone_environment = var.pinecone_environment
}

module "bedrock" {
  source = "./bedrock_knowledge_base"
  
  knowledge_base_role_arn        = module.iam.bedrock_kb_role_arn
  pinecone_connection_string     = module.pinecone.pinecone_host
  pinecone_credential_secret_arn = module.secrets_manager.pinecone_secret_arn
  pinecone_index_name            = module.pinecone.pincone_index_name
  source_bucket_arn              = module.s3.kb_bucket_arn
#   pinecone_api_key               = ""
}