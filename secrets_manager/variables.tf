
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
