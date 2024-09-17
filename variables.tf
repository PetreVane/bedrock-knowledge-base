
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
  default     = "anthropic.claude-3-sonnet-20240229-v1"
}

variable "default_email_address" {
  description = "Default email address where sns messages are sent"
  type        = string
  default     = "petre.vane@gmail.com"
}

variable "github_repo" {
  description = "The name of the Github repository where the actions workflow file is stored"
  type        = string
  default     = "PetreVane/anthropic-quickstarts"
}