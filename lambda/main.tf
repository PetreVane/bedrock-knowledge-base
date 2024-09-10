
resource "random_id" "generator" {
  byte_length = 4
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = var.s3_bucket_id
  key    = "lambda_files/${data.archive_file.lambda_zip.output_path}"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

resource "aws_lambda_function" "document_ingestion_executor" {
  function_name = "document_ingestion_executor-${random_id.generator.hex}"
  role          = var.tf_lambda_executor_role
  handler       = "index.handler"
  s3_bucket     = var.s3_bucket_id // should point to: module.s3.lambda_object_key
  s3_key        = aws_s3_object.lambda_zip.key
  memory_size   = 128
  timeout       = 300
  runtime       = "python3.12"

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = var.knowledge_base_id
      DATA_SOURCE_ID = var.data_source_id
    }
  }
  depends_on = [aws_s3_object.lambda_zip]
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.document_ingestion_executor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}


