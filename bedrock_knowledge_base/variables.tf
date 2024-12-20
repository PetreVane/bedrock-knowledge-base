

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "knowledge_base_name" {
  type        = string
  description = "The name of the knowledge base."
  default = "personal-knowledge-base"
}

variable "knowledge_base_description" {
  type        = string
  description = "The description of the knowledge base."
  default = "This is a knowledge base for the personal usage."
}

variable "data_source_name" {
  type        = string
  description = "The name of the data source."
  default = "S3-bucket"
}

variable "data_source_description" {
  type        = string
  description = "The description of the data source."
  default = "This is a s3 bucket containing pdf files."
}

variable "knowledge_base_role_arn" {
  description = "The role used by the knowledge base to access the data source."
  type        = string
}

variable "pinecone_connection_string" {
  type        = string
  description = "The connection string to the Pinecone API."
}

variable "embeddings_model" {
  description = "The name of the embeddings model to use."
  type = string
}

variable "pinecone_credential_secret_arn" {
  description = "The secret arn where the pinecone api key is hosted"
  type = string
}

variable "source_bucket_arn" {
  description = "The arn of the s3 bucket where the data is stored."
  type = string
}

variable "source_bucket_prefix" {
  description = "The s3 prefix where files are stored"
  type = string
}

variable "iam_policy_attachment_id" {
  description = "The ID of iam policy attachment"
  type = string
}

variable "region" {
  description = "The AWS region"
  type = string
}

