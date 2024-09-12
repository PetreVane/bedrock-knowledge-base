
resource "random_id" "generator" {
  byte_length = 4
}

resource "aws_sns_topic" "lambda_executions" {
  name = "lambda_executions-${random_id.generator.hex}"
}

resource "aws_sns_topic_subscription" "topic_subscription" {
  endpoint  = var.email_address
  protocol  = "email"
  topic_arn = aws_sns_topic.lambda_executions.arn
}