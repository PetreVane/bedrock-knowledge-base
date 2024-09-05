
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

variable "embedings_model_arn" {
  description = "The ARN of the model to use for creating embeddings"
  type = string
}

variable "knowledge_base_arn" {
  description = "The arn of the knowledge base"
  type = string
}