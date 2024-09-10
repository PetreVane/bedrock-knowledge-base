
output "kb_bucket_arn" {
  value = aws_s3_bucket.knowledge_base_bucket.arn
}

output "kb_bucket_id" {
  value = aws_s3_bucket.knowledge_base_bucket.id
}

output "lambda_object_key" {
  value = aws_s3_object.lambda_object.key
}

output "knowledge_files_folder_key" {
  value = aws_s3_object.knowledge_files_folder.key
}