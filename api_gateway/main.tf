
resource "random_id" "generator" {
  byte_length = 4
}

# Api Gateway
resource "aws_api_gateway_rest_api" "kb_api" {
  name = "knowledge_base_rest_api"
}

# Resources
resource "aws_api_gateway_resource" "kb_api_resource" {
  parent_id   = aws_api_gateway_rest_api.kb_api.root_resource_id
  path_part   = "query"
  rest_api_id = aws_api_gateway_rest_api.kb_api.id
}

//TODO: add authorization to API Gateway
# Method
resource "aws_api_gateway_method" "kb_api_method" {
  authorization = "NONE" // change this
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.kb_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.kb_api.id

  request_parameters = {
    "method.request.querystring.query" = true
  }
}

# Integration
resource "aws_api_gateway_integration" "kb_api_integration" {
  http_method = aws_api_gateway_method.kb_api_method.http_method
  resource_id = aws_api_gateway_resource.kb_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.kb_api.id

  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = var.request_processor_invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "kb_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.kb_api.id
  stage_name = var.deployment_env

  depends_on = [aws_api_gateway_integration.kb_api_integration]
}