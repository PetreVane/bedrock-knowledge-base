
resource "random_id" "generator" {
  byte_length = 4
}

# Api Gateway
resource "aws_api_gateway_rest_api" "kb_api" {
  name = "knowledge_base_rest_api-${random_id.generator.hex}"
}

# Resources
resource "aws_api_gateway_resource" "kb_api_resource" {
  parent_id   = aws_api_gateway_rest_api.kb_api.root_resource_id
  path_part   = "query"
  rest_api_id = aws_api_gateway_rest_api.kb_api.id
}

# Request validator
resource "aws_api_gateway_request_validator" "kb_request_validator" {
  name        = "Request Body Validator"
  rest_api_id = aws_api_gateway_rest_api.kb_api.id
  validate_request_body       = true
  validate_request_parameters = false
}

# Request validator model
resource "aws_api_gateway_model" "kb_req_validator_model" {
  content_type = "application/json"
  name         = "2356"
  description = "Validation model for KB API"
  rest_api_id  = aws_api_gateway_rest_api.kb_api.id

  schema = jsonencode({
    type = "object"
    required = ["query"]
    properties = {
      query = { type = "string" }
    }
  })
}

# Method
resource "aws_api_gateway_method" "kb_api_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.kb_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.kb_api.id

  api_key_required = true
  request_validator_id = aws_api_gateway_request_validator.kb_request_validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.kb_req_validator_model.name
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

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.kb_api_resource.id,
      aws_api_gateway_method.kb_api_method.id,
      aws_api_gateway_integration.kb_api_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage
resource "aws_api_gateway_stage" "kb_api_stage" {
  deployment_id = aws_api_gateway_deployment.kb_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.kb_api.id
  stage_name    = var.deployment_env
}

# API Key
resource "aws_api_gateway_api_key" "kb_api_key" {
  name = "knowledge_base_api_key"
  enabled = true
}

# Usage plan
resource "aws_api_gateway_usage_plan" "kb_usage_plan" {
  name = "knowledge_base_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.kb_api.id
    stage  = aws_api_gateway_stage.kb_api_stage.stage_name
  }

  quota_settings {
    limit  = 1000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 50
    rate_limit = 50
  }
}

# Associate the apy key with the usage plan
resource "aws_api_gateway_usage_plan_key" "kb_usage_plan_association" {
  key_id = aws_api_gateway_api_key.kb_api_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.kb_usage_plan.id
}

# Error message
resource "aws_api_gateway_gateway_response" "kb_error_message" {
  response_type = "MISSING_AUTHENTICATION_TOKEN"
  rest_api_id   = aws_api_gateway_rest_api.kb_api.id
  status_code = "403"

  response_templates = {
    "application/json" = "{\"message\": \"Missing or invalid API key\"}"
  }
}

