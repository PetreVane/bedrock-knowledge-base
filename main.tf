
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
  lambda_arn                        = module.lambda.document_ingestion_executor_arn
  lambda_permission_allow_execution = module.lambda.lambda_s3_allow_execution_id
  lambda_zip_file_path              = module.lambda.document_ingestion_zip_output_path
  lambda_zip_name                   = module.lambda.document_ingestion_zip_id
}

module "secrets_manager" {
  source                         = "./secrets_manager"
  pinecone_api_key               = var.pinecone_api_key
  kb_name                        = module.iam.bedrock_kb_role_name
  bedrock_user_access_key_id     = module.bedrock.bedrock_user_access_key_id
  bedrock_user_access_key_secret = module.bedrock.bedrock_user_access_key_secret
  anthropic_api_key              = var.anthropic_api_key
  ecs_execution_role_name        = module.ecs.ecs_execution_role_name
  ecs_task_role_name             = module.ecs.ecs_task_role_name
}

module "iam" {
  source               = "./iam"
  region               = var.region
  kb_source_bucket_arn = module.s3.kb_bucket_arn
  pinecone_secret_arn  = module.secrets_manager.pinecone_secret_arn
  embedings_model_arn  = module.bedrock.embeddings_model_arn
  knowledge_base_arn   = module.bedrock.knowledge_base_arn
  sns_topic_arn        = module.sns.sns_topic_arn
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
  source_bucket_prefix           = module.s3.knowledge_files_folder_key
  iam_policy_attachment_id       = module.iam.iam_policy_attachment_id
  region                         = var.region
}

module "lambda" {
  source                   = "./lambda"
  data_source_id           = module.bedrock.knowledge_base_data_source_id
  knowledge_base_id        = module.bedrock.knowledge_base_id
  s3_bucket_arn            = module.s3.kb_bucket_arn
  s3_bucket_id             = module.s3.kb_bucket_id
  tf_lambda_executor_role  = module.iam.lambda_document_ingestion_arn
  s3_bucket_key            = module.s3.lambda_object_key
  lambda_results_sns_topic = module.sns.sns_topic_arn

  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  aws_access_key_id         = module.bedrock.bedrock_user_access_key_id
  aws_region                = var.region
  aws_secret_access_key     = module.bedrock.bedrock_user_access_key_secret
  kb_request_processor_role = module.iam.lambda_request_processor_arn
}

module "sns" {
  source        = "./sns"
  email_address = var.default_email_address
}

module "github" {
  source             = "./github"
  aws_region         = var.region
  github_repo        = var.github_repo
  ecr_repository_arn = module.ecr.ecr_repository_arn
  github_token       = var.github_token
  owner              = var.github_repo_owner
}

module "ecr" {
  source     = "./ecr"
  aws_region = var.region
  image_tag  = var.aws_environment
}

module "ssm_parameter_store" {
  source              = "./ssm_parameter_store"
  bedrock_kb_id       = module.bedrock.knowledge_base_id
  bedrock_kb_name     = module.bedrock.knowledge_base_name
  ecr_registry_id     = module.ecr.ecr_registry_id
  ecr_repository_name = module.ecr.ecr_repository_name
  ecr_repository_arn  = module.ecr.ecr_repository_arn

  anthropic_api_key              = var.anthropic_api_key
  bedrock_user_access_key_id     = module.bedrock.bedrock_user_access_key_id
  bedrock_user_access_key_secret = module.bedrock.bedrock_user_access_key_secret
}

module "ecs" {
  source                       = "./ecs"
  availability_zone            = ["${var.region}a", "${var.region}b", "${var.region}c"]
  aws_region                   = var.region
  bedrock_kb_arn               = module.bedrock.knowledge_base_arn
  cidr_block                   = "10.0.0.0/16"
  ecr_repository_arn           = module.ssm_parameter_store.ecr_repository_arn
  ecr_repository_name          = module.ssm_parameter_store.ecr_repository_name
  subnet_cidr_block            = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  anthropic_api_key_arn        = module.secrets_manager.anthropic_api_key_arn
  bedrock_user_credentials_arn = module.secrets_manager.bedrock_user_credentials_arn
  image_tag                    = var.aws_environment

  anthropic_api_key              = module.ssm_parameter_store.anthropic_api_key
  bedrock_user_access_key_id     = module.ssm_parameter_store.bedrock_user_access_key_id
  bedrock_user_access_key_secret = module.ssm_parameter_store.bedrock_user_access_key_secret
  bedrock_user                   = module.bedrock.bedrock_user_arn
}

module "api_gateway" {
  source                       = "./api_gateway"
  request_processor_arn        = module.lambda.request_processor_arn
  request_processor_invoke_arn = module.lambda.request_processor_invoke_arn
}