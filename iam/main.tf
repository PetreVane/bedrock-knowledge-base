
resource "random_id" "generator" {
  byte_length = 4
}

# Creates an IAM policy for Bedrock Knowledge Base
data "aws_iam_policy_document" "bedrock_kb_policy" {
  statement {
	actions = [
	  "s3:GetObject",
	  "s3:ListBucket",
	  "s3:DeleteObject",
	  "s3:DeleteBucket",
	  "s3:DeleteBucketPolicy"
	]
	effect   = "Allow"
	resources = [
	  var.kb_source_bucket_arn,
	  "${var.kb_source_bucket_arn}/*"
	]
  }
  
  statement {
	actions = [
	  "secretsmanager:GetSecretValue",
	  "secretsmanager:DeleteSecret"
	]
	effect   = "Allow"
	resources = [
	  var.pinecone_secret_arn
	]
  }
  
  statement {
	actions = [
	  "bedrock:InvokeModel",
	  "bedrock:DeleteModel",
	  "bedrock:DeleteDataSource"
	]
	effect   = "Allow"
	resources = [
	  var.embedings_model_arn,
	  "${var.knowledge_base_arn}/*"
	]
  }
}



resource "aws_iam_policy" "bedrock_kb_policy" {
  name        = "BedrockKnowledgeBasePolicy-${random_id.generator.hex}"
  description = "Policy for AWS Bedrock Knowledge Base"
  policy      = data.aws_iam_policy_document.bedrock_kb_policy.json
}

# Create the IAM role for Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_kb_role" {
  name               = "BedrockKnowledgeBaseRole-${var.region}-${random_id.generator.hex}"
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_trust_policy.json
}

data "aws_iam_policy_document" "bedrock_kb_trust_policy" {
  statement {
	actions = ["sts:AssumeRole"]
	principals {
	  type        = "Service"
	  identifiers = ["bedrock.amazonaws.com"]
	}
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "bedrock_kb_policy_attachment" {
  role       = aws_iam_role.bedrock_kb_role.name
  policy_arn = aws_iam_policy.bedrock_kb_policy.arn
}
