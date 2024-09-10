

output "bedrock_kb_role_arn" {
  value = aws_iam_role.bedrock_kb_role.arn
}

output "bedrock_kb_role_name" {
  value = aws_iam_role.bedrock_kb_role.name
}

output "iam_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.bedrock_kb_policy_attachment.id
}

output "tf_lambda_executor_role_arn" {
  value = aws_iam_role.tf_lambda_executor_role.arn
}