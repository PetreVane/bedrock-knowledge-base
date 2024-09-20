
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "bedrock_kb_name" {
  description = "Bedrock knowledge name"
  type = string
}

variable "bedrock_kb_id" {
  description = "Bedrock knowledge id"
  type = string
}

variable "ecr_registry" {
  description = "ECR Registry where the docker images are stored"
  type = string
}

variable "ecr_repository" {
  description = "ECR Repository where the docker images are stored"
  type = string
}