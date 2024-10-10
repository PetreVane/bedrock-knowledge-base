
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
  description = "Pinecone Environment"
  type        = string
  default     = "us-east-1"
}

variable "default_email_address" {
  description = "Default email address where sns messages are sent"
  type        = string
  default     = "petre.vane@gmail.com"
}

variable "github_repo" {
  description = "The name of the Github repository where the actions workflow file is stored"
  type        = string
  default     = "Claude-Knowledge-Base-Agent-with-RAG"
}

variable "github_repo_owner" {
  description = "The owner of the Github repository"
  type        = string
  default     = "PetreVane"
}

variable "github_token" {
  description = "Github access token"
  type        = string
}

variable "anthropic_api_key" {
  description = "Anthropic API Key for Claude"
  type        = string
}

variable "aws_environment" {
  description = "The AWS environment in which this solution is deployed. Defaults to DEV"
  type        = string
  default     = "DEV"
}