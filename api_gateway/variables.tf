

variable "deployment_env" {
  description = "The environment in which the infrastructure is deployed"
  default = "DEV"
}

variable "request_processor_invoke_arn" {
  description = "The invoke ARN of the Lambda function triggered by api gateway"
  type = string
  //This invoke_arn includes the necessary path and action for invoking the Lambda function.
}