

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "data_source_id" {
  type = string
  description = "Data source id used by bedrock knowledge base"
}

variable "knowledge_base_id" {
  type = string
  description = "Bedrock knowledge base id"
}

variable "s3_bucket_arn" {
  type = string
  description = "S3 bucket arn for bedrock knowledge base"
}

variable "s3_bucket_id" {
  type = string
  description = "The bucket id where the lambda code is stored"
}

variable "tf_lambda_executor_role" {
  type = string
  description = "The role ARN used to execute the lambda function"
}

variable "lambda_results_sns_topic" {
  description = "SNS topic for sending lambda executions results"
  type = string
}

variable "kb_request_processor_role" {
  description = "The role ARN for Knowledge Base request processor"
  type = string
}

variable "aws_region" {
  description = "The AWS region"
  type = string
}

variable "aws_access_key_id" {
  description = "The aws access key id for bedrock user. See module bedrock_knowledge_base/iam.tf file"
  type = string
}

variable "aws_secret_access_key" {
  description = "The aws secret access key id for bedrock user. See module bedrock_knowledge_base/iam.tf file"
  type = string
}

variable "api_gateway_execution_arn" {
  description = "The AWS Gateway ARN"
}