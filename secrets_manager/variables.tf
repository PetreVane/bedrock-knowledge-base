
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "pinecone_api_key" {
  description = "Pinecone api key"
  type = string
}

variable "kb_name" {
  description = "The name of the knowledge base allowed to read the secret api key"
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

variable "ecs_execution_role_name" {
  description = "The ARN of the ECS execution role allowed to access secrets"
  type = string
}

variable "ecs_task_role_name" {
  description = "The ARN of the ECS task role allowed to access secrets"
  type = string
}