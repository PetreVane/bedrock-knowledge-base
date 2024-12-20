

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "aws_region" {
  description = "The AWS region"
  type = string
}

variable "create_oidc_provider" {
  description = "Whether to create the OIDC provider or use an existing one"
  type = bool
  default = true
}

variable "ecr_repository_arn" {
  description = "The arn of the ecr repository on which the github role has access to"
  type = string
}

variable "github_token" {
  description = "Github Personal Access token which allows to save Secrets into Github"
  type = string
}

variable "owner" {
  description = "The owner of the repository"
  type = string
}

variable "knowledge_base_bucket_arn" {
  description = "The name of the bucket where the knowledge base is stored"
  type = string
}

variable "github_repositories" {
  description = "The list of github repositories to be added to the OIDC provider"
  type = list(string)
}