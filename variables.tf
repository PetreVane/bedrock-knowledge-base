
variable "region" {
  description = "AWS region"
  type        = string
}

variable "pinecone_api_key" {
  description = "Pinecone api key"
  type        = string
}

variable "pinecone_environment" {
  description = "Pinecone Environment"
  type        = string
}

variable "default_email_address" {
  description = "Default email address where sns messages are sent"
  type        = string
}

variable "github_repositories" {
  description = "The list of github repositories to be added to the OIDC provider"
  type        = list(string)
  default     = ["Claude-Knowledge-Base-Agent-with-RAG", "obsidian", "bedrock-knowledge-base"]
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

