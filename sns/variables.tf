
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "email_address" {
  description = "The email address for lambda execution results"
  type = string
}