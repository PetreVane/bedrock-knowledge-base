# Generate a random ID with a byte length of 4 for unique identification
resource "random_id" "generator" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

# Create an IAM policy document for the Bedrock Knowledge Base
data "aws_iam_policy_document" "bedrock_kb_policy" {
  # First statement allows S3 actions on the specified bucket and its objects
  statement {
	actions = [
	  "s3:GetObject",
	  "s3:ListBucket",
	  "s3:DeleteObject",
	  "s3:DeleteBucket",
	  "s3:DeleteBucketPolicy"
	]
	effect = "Allow"
	resources = [
	  var.kb_source_bucket_arn,
	  "${var.kb_source_bucket_arn}/*"
	]
  }
  
  # Second statement allows access to Secrets Manager for specific actions
  statement {
	actions = [
	  "secretsmanager:GetSecretValue",
	  "secretsmanager:DeleteSecret"
	]
	effect = "Allow"
	resources = [
	  var.pinecone_secret_arn
	]
  }
  
  # Third statement allows actions related to Bedrock models and data sources
  statement {
	actions = [
		"bedrock:ListFoundationModels",
	  	"bedrock:InvokeModel",
		"bedrock:InvokeStreamingModel",
	  	"bedrock:DeleteModel",
	  	"bedrock:DeleteDataSource",
		"bedrock:StartIngestionJob",
		"bedrock:AssociateThirdPartyKnowledgeBase"
	]
	effect   = "Allow"
    resources = [
      var.embedings_model_arn,
	  "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"       # ARN of all resources in the knowledge base
    ]
  }
}

# Create an IAM policy using the defined policy document
resource "aws_iam_policy" "bedrock_kb_policy_json" {
  name        = "BedrockKnowledgeBasePolicy-${random_id.generator.hex}"
  description = "Policy for AWS Bedrock Knowledge Base"
  policy      = data.aws_iam_policy_document.bedrock_kb_policy.json
}


# Create a trust policy document for the Bedrock Knowledge Base role
data "aws_iam_policy_document" "bedrock_kb_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
		  "bedrock.amazonaws.com",
		  "lambda.amazonaws.com"
	  ]
    }
	effect = "Allow"
  }
}

# Create the IAM role for the Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_kb_role" {
  name               = "BedrockKnowledgeBaseRole-${var.region}-${random_id.generator.hex}"
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_trust_policy.json
}

# Attach the previously created policy to the IAM role
resource "aws_iam_role_policy_attachment" "bedrock_kb_policy_attachment" {
  role       = aws_iam_role.bedrock_kb_role.name
  policy_arn = aws_iam_policy.bedrock_kb_policy_json.arn
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_iam_role_policy_attachment.bedrock_kb_policy_attachment]
  create_duration = "30s"
}


// iam role for lambda function
resource "aws_iam_role" "tf_lambda_executor_role" {
	name = "tf_lambda_executor_role-${random_id.generator.hex}"
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Action = "sts:AssumeRole",
			Effect = "Allow",
			Principal = {
				Service = "lambda.amazonaws.com"
			}
		}]
	})
}

resource "aws_iam_policy" "lambda_permission_policy" {
	name        = "LambdaPermissionPolicy-${random_id.generator.hex}"
	description = "Policy which grants a lambda function read access to a specific S3 bucket, CloudWatch Logs permissions and triggers bedrock ingestion job"

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = [
					"s3:List*",
					"s3:ListBucket",
					"s3:GetObject"
				],
				Resource = "${var.knowledge_base_arn}/*",
				Effect   = "Allow"
			},
			{
				Action = [
					"logs:CreateLogGroup",
					"logs:CreateLogStream",
					"logs:PutLogEvents"
				],
				Resource = "arn:aws:logs:*:*:*",
				Effect   = "Allow"
			},
			{
				Action = [
					"bedrock:StartIngestionJob",
					"bedrock:AssociateThirdPartyKnowledgeBase"
					],
				Effect = "Allow",
				Resource = "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
			},
			{
				Action = [
					"sns:Publish"
				],
				Effect = "Allow",
				Resource = var.sns_topic_arn
			}
		]
	})
}


resource "aws_iam_role_policy_attachment" "tf_s3_policy_attach" {
	policy_arn = aws_iam_policy.lambda_permission_policy.arn
	role       = aws_iam_role.tf_lambda_executor_role.name
}
