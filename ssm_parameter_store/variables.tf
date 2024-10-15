
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "bedrock_kb_name" {
  description = "Bedrock knowledge name"
  type = string
}

variable "bedrock_kb_id" {
  description = "Bedrock knowledge id"
  type = string
}

variable "ecr_registry_id" {
  description = "ECR Registry ID where the docker images are stored"
  type = string
}

variable "ecr_repository_name" {
  description = "ECR Repository Name where the docker images are stored"
  type = string
}

variable "ecr_repository_arn" {
  description = "The arn of the ECR repository"
  type = string
}

variable "bedrock_user_access_key_id" {
  description = "Access key id for bedrock user"
  type = string
}

variable "bedrock_user_access_key_secret" {
  description = "Access key secret for bedrock user"
  type = string
}

variable "anthropic_api_key" {
  description = "Anthropic API key for Claude"
  type = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket where the data is stored"
  type = string
}