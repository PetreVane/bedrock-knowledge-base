

# Defines a iam user which is used by containerised front end app to interact with Bedrock
resource "aws_iam_user" "bedrock_user" {
  name = "bedrock_user-${random_id.generator.hex}"
}

resource "aws_iam_user_policy_attachment" "bedrock_full_access" {
  user       = aws_iam_user.bedrock_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_iam_access_key" "bedrock_user_key" {
  user = aws_iam_user.bedrock_user.name
}
