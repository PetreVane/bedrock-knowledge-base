
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
  api_key = var.pinecone_api_key
}

module "s3" {
  source                            = "./s3"
  lambda_arn                        = module.lambda.lambda_function_arn
  lambda_permission_allow_execution = module.lambda.lambda_permission_allow_execution
  lambda_zip_file_path              = module.lambda.lambda_zip_file_path
  lambda_zip_name                   = module.lambda.lambda_zip_file_name
}

module "secrets_manager" {
  source           = "./secrets_manager"
  pinecone_api_key = var.pinecone_api_key
  kb_name          = module.iam.bedrock_kb_role_name
}

module "iam" {
  source               = "./iam"
  region               = var.region
  kb_source_bucket_arn = module.s3.kb_bucket_arn
  pinecone_secret_arn  = module.secrets_manager.pinecone_secret_arn
  embedings_model_arn  = module.bedrock.embedings_model_arn
  knowledge_base_arn   = module.bedrock.knowledge_base_arn
}

module "pinecone" {
  source               = "./pinecone_vectorDB"
  pinecone_environment = var.pinecone_environment
}

module "bedrock" {
  source = "./bedrock_knowledge_base"

  knowledge_base_role_arn        = module.iam.bedrock_kb_role_arn
  pinecone_connection_string     = module.pinecone.pinecone_host
  pinecone_credential_secret_arn = module.secrets_manager.pinecone_secret_arn
  pinecone_index_name            = module.pinecone.pincone_index_name
  source_bucket_arn              = module.s3.kb_bucket_arn
  iam_policy_attachment_id       = module.iam.iam_policy_attachment_id
  region                         = var.region
}

module "lambda" {
  source                  = "./lambda"
  data_source_id          = module.bedrock.knowledge_base_data_source_id
  knowledge_base_id       = module.bedrock.knowledge_base_id
  s3_bucket_arn           = module.s3.kb_bucket_arn
  s3_bucket_id            = module.s3.kb_bucket_id
  tf_lambda_executor_role = module.iam.tf_lambda_executor_role_arn
  s3_bucket_key           = module.s3.lambda_object_key
}