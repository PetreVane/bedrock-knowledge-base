# Generate a random ID with a byte length of 8 for unique identification
resource "random_id" "generate" {
  byte_length = 8
}

locals {
  lambda_zip_file_path = var.lambda_zip_file_path
  lambda_zip_file_name =  var.lambda_zip_name
}

# Create an S3 bucket for the knowledge base
resource "aws_s3_bucket" "knowledge_base_bucket" {
  # Set the name of the bucket, appending a random hex ID for uniqueness
  bucket = "tf-bedrock-knowledge-base-${random_id.generate.hex}"
  
  # Allow the bucket to be forcefully destroyed even if it contains objects
  force_destroy = true
}

# Configure public access settings for the S3 bucket
resource "aws_s3_bucket_public_access_block" "bucket_access" {
  # Reference the ID of the created S3 bucket
  bucket = aws_s3_bucket.knowledge_base_bucket.id

  # Block all public ACLs from being applied to the bucket
  block_public_acls = true
  
  # Block any public policies from being applied to the bucket
  block_public_policy = true
  
  # Ignore any existing public ACLs on the bucket
  ignore_public_acls = true
  
  # Restrict the bucket from being publicly accessible
  restrict_public_buckets = true
}


resource "aws_s3_object" "lambda_object" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  key    = "/lambda_files/${local.lambda_zip_file_name}"
  source = local.lambda_zip_file_path
}

resource "aws_s3_object" "knowledge_files_folder" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id
  key    = "knowledge_base_files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".md"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".txt"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".docx"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".html"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".csv"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".xls"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".xlsx"
  }

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "knowledge_base_files/"
    filter_suffix       = ".tf"
  }
}
