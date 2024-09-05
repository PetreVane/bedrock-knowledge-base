# Generate a random ID with a byte length of 4 for unique identification
resource "random_id" "generator" {
  byte_length = 4
}

# Create an IAM policy document for the Bedrock Knowledge Base
data "aws_iam_policy_document" "bedrock_kb_policy" {
  # First statement allows S3 actions on the specified bucket and its objects
  statement {
	actions = [
	  "s3:GetObject", # Permission to retrieve objects from S3
	  "s3:ListBucket", # Permission to list objects in the S3 bucket
	  "s3:DeleteObject", # Permission to delete objects from S3
	  "s3:DeleteBucket", # Permission to delete the S3 bucket
	  "s3:DeleteBucketPolicy"  # Permission to delete the bucket policy
	]
	effect = "Allow"        # Allow these actions
	resources = [
	  var.kb_source_bucket_arn, # ARN of the S3 bucket
	  "${var.kb_source_bucket_arn}/*"     # ARN of all objects in the bucket
	]
  }
  
  # Second statement allows access to Secrets Manager for specific actions
  statement {
	actions = [
	  "secretsmanager:GetSecretValue", # Permission to retrieve secret values
	  "secretsmanager:DeleteSecret"      # Permission to delete secrets
	]
	effect = "Allow"                   # Allow these actions
	resources = [
	  var.pinecone_secret_arn             # ARN of the Pinecone secret
	]
  }
  
  # Third statement allows actions related to Bedrock models and data sources
  statement {
	actions = [
	  "bedrock:InvokeModel", # Permission to invoke Bedrock models
	  "bedrock:DeleteModel", # Permission to delete Bedrock models
	  "bedrock:DeleteDataSource"           # Permission to delete data sources
	]
	effect   = "Allow"                    # Allow these actions
    resources = [
      var.embedings_model_arn,            # ARN of the embedding model
      "${var.knowledge_base_arn}/*"        # ARN of all resources in the knowledge base
    ]
  }
}

# Create an IAM policy using the defined policy document
resource "aws_iam_policy" "bedrock_kb_policy" {
  name        = "BedrockKnowledgeBasePolicy-${random_id.generator.hex}"  # Unique policy name
  description = "Policy for AWS Bedrock Knowledge Base"                  # Description of the policy
  policy      = data.aws_iam_policy_document.bedrock_kb_policy.json     # JSON representation of the policy
}

# Create the IAM role for the Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_kb_role" {
  name               = "BedrockKnowledgeBaseRole-${var.region}-${random_id.generator.hex}"  # Unique role name
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_trust_policy.json           # Trust policy for the role
}

# Create a trust policy document for the Bedrock Knowledge Base role
data "aws_iam_policy_document" "bedrock_kb_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]  # Action that allows assuming the role
    principals {
      type        = "Service"      # Specify the principal type as a service
      identifiers = ["bedrock.amazonaws.com"]  # Identifier for the Bedrock service
    }
  }
}

# Attach the previously created policy to the IAM role
resource "aws_iam_role_policy_attachment" "bedrock_kb_policy_attachment" {
  role       = aws_iam_role.bedrock_kb_role.name  # Role to which the policy is attached
  policy_arn = aws_iam_policy.bedrock_kb_policy.arn  # ARN of the policy being attached
}
