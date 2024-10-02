
resource "random_id" "generator" {
  byte_length = 4
}

data "archive_file" "document_ingestion_zip" {
  type        = "zip"
  source_file = "${path.module}/document_ingestion.py"
  output_path = "${path.module}/document_ingestion.zip"
}

resource "aws_s3_object" "document_ingestion_zip" {
  bucket = var.s3_bucket_id
  key    = "lambda_files/${data.archive_file.document_ingestion_zip.output_path}"
  source = data.archive_file.document_ingestion_zip.output_path
  etag   = filemd5(data.archive_file.document_ingestion_zip.output_path)
}

resource "aws_lambda_function" "document_ingestion_executor" {
  function_name = "document_ingestion_executor-${random_id.generator.hex}"
  role          = var.tf_lambda_executor_role
  handler       = "document_ingestion.handler"
  s3_bucket     = var.s3_bucket_id // should point to: module.s3.lambda_object_key
  s3_key        = aws_s3_object.document_ingestion_zip.key
  memory_size   = 128
  timeout       = 300
  runtime       = "python3.12"

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = var.knowledge_base_id
      DATA_SOURCE_ID = var.data_source_id
    }
  }
  depends_on = [aws_s3_object.document_ingestion_zip]
}

resource "aws_lambda_permission" "lambda_s3_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.document_ingestion_executor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_lambda_function_event_invoke_config" "lambda_execution_event" {
  function_name = aws_lambda_function.document_ingestion_executor.id

  destination_config {
    on_success {
      destination = var.lambda_results_sns_topic
    }
    on_failure {
      destination = var.lambda_results_sns_topic
    }
  }
}

# === Lambda API Gateway ===
/*
The following lambda function will be invoked by API Gateway when a request is received.
The lambda function expects the following environmental variables:
- aws region in which the infrastructure is deployed
- aws access key id for a user which is authorised to interact with bedrock; this user is created
  in module bedrock_knowledge_base/iam.tf file
- aws secret access key for aforementioned user
- a bedrock knowledge base id


When a request is received, the lambda function will use the environment variables to create a bedrock agent which attempts
to retrieve 5 documents from your knowledge base, based on your query extracted from gateway request.

The results are returned as json, to be later processed by an LLM of you choice.
 */


data "archive_file" "request_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/request_processor.py"
  output_path = "${path.module}/request_processor.zip"
}

resource "aws_s3_object" "request_processor_zip" {
  bucket = var.s3_bucket_id
  key    = "lambda_files/${data.archive_file.request_processor_zip.output_path}"
  source = data.archive_file.request_processor_zip.output_path
  etag = filemd5(data.archive_file.request_processor_zip.output_path)
}

# process an API request for Bedrock Knowledge Base
resource "aws_lambda_function" "kb_request_processor" {
  function_name = "kb_request_processor-${random_id.generator.hex}"
  role          = var.kb_request_processor_role
  handler       = "request_processor.handler"
  s3_bucket     = var.s3_bucket_id
  s3_key        = aws_s3_object.request_processor_zip.key
  memory_size   = 128
  timeout       = 300
  runtime       = "python3.12"

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = var.knowledge_base_id
      REGION = var.aws_region
      BAWS_ACCESS_KEY_ID = var.aws_access_key_id
      BAWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    }
  }
  depends_on = [aws_s3_object.request_processor_zip]
}

resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kb_request_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}