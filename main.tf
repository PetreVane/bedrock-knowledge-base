
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
  environment = var.pinecone_environment
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
}