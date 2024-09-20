

# Saves secrets into SSM Parameter Store
# These are later retrieved by Github Actions role and used to build a docker image
resource "aws_ssm_parameter" "bedrock_kb_name" {
  name = "/github-actions/bedrock_knowledge_base_name"
  type = "String"
  value = var.bedrock_kb_name
    tags = merge(
    var.tags, { Name = "Bedrock Knoledge Name for Github Actions" }
  )
}

resource "aws_ssm_parameter" "bedrock_kb_id" {
  name = "/github-actions/bedrock_knowledge_base_id"
  type = "String"
  value = var.bedrock_kb_id
    tags = merge(
    var.tags, { Name = "Bedrock Knoledge Name for Github Actions" }
  )
}

resource "aws_ssm_parameter" "ecr_registry" {
  name = "/github-actions/ecr_registry"
  type = "String"
  value = var.ecr_registry
    tags = merge(
    var.tags, { Name = "ECR Registry Name for Github Actions" }
  )
}

resource "aws_ssm_parameter" "ecr_repository" {
  name = "/github-actions/ecr_repository"
  type = "String"
  value = var.ecr_repository
    tags = merge(
    var.tags, { Name = "ECR Repository Name for Github Actions" }
  )
}