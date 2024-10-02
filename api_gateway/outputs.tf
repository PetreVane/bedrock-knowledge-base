
output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.kb_api.execution_arn
}

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.kb_api_deployment.invoke_url}${aws_api_gateway_resource.kb_api_resource.path}"
}