

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

variable "s3_bucket_key" {
  description = "The object key pointing for the lambda zip file in s3"
  type = string
}


variable "tf_lambda_executor_role" {
  type = string
  description = "The role used to execute the lambda function"
}

variable "lambda_results_sns_topic" {
  description = "SNS topic for sending lambda executions results"
  type = string
}
