

variable "aws_region" {
  description = "The AWS region where the repository is created"
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "image_tag" {
  description = "The tag attached to the image when it is pushed to ECR repository"
  type = string
}