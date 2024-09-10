
output "lambda_zip_file_path" {
  value = data.archive_file.lambda_zip.output_path
}

output "lambda_zip_file_name" {
  value = data.archive_file.lambda_zip.id
}

output "lambda_function_name" {
  value = aws_lambda_function.document_ingestion_executor.id
}

output "lambda_function_arn" {
  value = aws_lambda_function.document_ingestion_executor.arn
}

output "lambda_permission_allow_execution" {
  value = aws_lambda_permission.lambda_permission.id
}