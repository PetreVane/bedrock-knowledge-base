
resource "random_id" "generate" {
  byte_length = 8
}

resource "aws_s3_bucket" "knowledge_base_bucket" {
  bucket = "tf-bedrock-knowledge-base-${random_id.generate.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.knowledge_base_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}