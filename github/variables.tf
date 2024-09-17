

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