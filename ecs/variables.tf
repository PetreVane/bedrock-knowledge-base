

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

variable "bedrock_user" {
  description = "The user for which have credentials have been generated. These are used by the web app to interact with the AWS account"
  type = string
}
