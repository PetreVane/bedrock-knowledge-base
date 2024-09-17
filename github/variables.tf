

variable "aws_region" {
  description = "The AWS region"
  type = string
}

variable "create_oidc_provider" {
  description = "Whether to create the OIDC provider or use an existing one"
  type = bool
  default = true
}

variable "github_repo" {
  description = "The name of the Github repository where the actions workflow file is stored"
  type = string
}

variable "ecr_repository_arn" {
  description = "The arn of the ecr repository on which the github role has access to"
  type = string
}