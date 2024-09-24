

variable "aws_region" {
  description = "The AWS region"
  type = string
}

variable "cidr_block" {
  description = "The CIDR block for VPC"
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "subnet_cidr_block" {
  type = list(string)
  description = "List of CIDR blocks for subnets"
}


variable "availability_zone" {
  type = list(string)
  description = "A list containing the availability zones in the region"
}

variable "bedrock_kb_arn" {
  description = "The arn of bedrock knowledge base"
  type = string
}

variable "ecr_repository_arn" {
  description = "The arn of the ecr repository"
  type = string
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type = string
}

variable "bedrock_user_credentials_arn" {
  description = "Bedrock user credentials from Secret Manager"
  type = string
}

variable "anthropic_api_key_arn" {
  description = "Anthropic API Key used by container"
  type = string
}

variable "image_tag" {
  description = "The tag attached to the image when it is pushed to ECR repository"
  type = string
}

variable "bedrock_user_access_key_id" {
  description = "Access key id for bedrock user"
  type = string
}

variable "bedrock_user_access_key_secret" {
  description = "Access key secret for bedrock user"
  type = string
}

variable "anthropic_api_key" {
  description = "Anthropic API key for Claude"
  type = string
}
