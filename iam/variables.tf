

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "region" {
  description = "AWS region"
  type = string
}

variable "kb_source_bucket_arn" {
  description = "S3 bucket arn acting as source for Knowledge Base"
  type = string
}

variable "pinecone_secret_arn" {
  description = "Pinecone api secret arn"
  type = string
}

variable "embeddings_model_arn" {
  description = "The ARN of the model to use for creating embeddings"
  type = string
}

variable "knowledge_base_arn" {
  description = "The arn of the knowledge base"
  type = string
}

variable "sns_topic_arn" {
  description = "The arn of the topic on which Lambda function is allowed to publish messages"
  type = string
}