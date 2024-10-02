

output "bedrock_kb_role_arn" {
  value = aws_iam_role.bedrock_kb_role.arn
}

output "bedrock_kb_role_name" {
  value = aws_iam_role.bedrock_kb_role.name
}

output "iam_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.bedrock_kb_policy_attachment.id
}

output "lambda_document_ingestion_arn" {
  value = aws_iam_role.lambda_document_ingestion_role.arn
}

output "lambda_request_processor_arn" {
  value = aws_iam_role.lambda_request_executor_role.arn
}