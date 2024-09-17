
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "lambda_zip_name" {
  description = "The name of the lambda zip file"
  type = string
}

variable "lambda_zip_file_path" {
  description = "The local path of the lambda zip file"
  type = string
}

variable "lambda_permission_allow_execution" {
  type = string
  description = "The permission which allows lambda invocations from s3 bucket"
}

variable "lambda_arn" {
  type        = string
  description = "The arn of the lambda function triggered by document upload"
}