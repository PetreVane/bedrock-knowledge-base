
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "pinecone_api_key" {
  description = "Pinecone api key"
  type        = string
}

variable "pinecone_environment" {
  description = "Pinecone Environemnt"
  type        = string
  default     = "us-east-1"
}

variable "inference_model_id" {
  description = "Model used for inference"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}