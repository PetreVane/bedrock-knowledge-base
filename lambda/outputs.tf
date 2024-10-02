
output "document_ingestion_zip_output_path" {
  value = data.archive_file.document_ingestion_zip.output_path
}

output "document_ingestion_zip_id" {
  value = data.archive_file.document_ingestion_zip.id
}

output "document_ingestion_executor_id" {
  value = aws_lambda_function.document_ingestion_executor.id
}

output "document_ingestion_executor_arn" {
  value = aws_lambda_function.document_ingestion_executor.arn
}

output "lambda_s3_allow_execution_id" {
  value = aws_lambda_permission.lambda_s3_permission.id
}

output "request_processor_arn" {
  value = aws_lambda_function.kb_request_processor.arn
}

output "request_processor_invoke_arn" {
  value = aws_lambda_function.kb_request_processor.invoke_arn
}