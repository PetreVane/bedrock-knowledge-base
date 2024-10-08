

# Saves secrets into SSM Parameter Store
# These are later retrieved by Github Actions role and used to build a docker image
resource "aws_ssm_parameter" "bedrock_kb_name" {
  name = "/bedrock/bedrock_knowledge_base_name"
  type = "String"
  value = var.bedrock_kb_name
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "bedrock_kb_id" {
  name = "/bedrock/bedrock_knowledge_base_id"
  type = "String"
  value = var.bedrock_kb_id
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "ecr_registry_id" {
  name = "/github-actions/ecr_registry"
  type = "String"
  value = var.ecr_registry_id
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "ecr_repository_name" {
  name = "/github-actions/ecr_repository_name"
  type = "String"
  value = var.ecr_repository_name
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "ecr_repository_arn" {
  name = "/ecs/ecr_repository_arn"
  type = "String"
  value = var.ecr_repository_arn
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "bedrock_user_access_key_id" {
  name = "/bedrock/user_access_key_id"
  type = "String"
  value = var.bedrock_user_access_key_id
  tags = merge(var.tags, { Name = "terraform_project" })
}

resource "aws_ssm_parameter" "bedrock_user_access_key_secret" {
  name = "/bedrock/user_access_key_secret"
  type = "String"
  value = var.bedrock_user_access_key_secret
  tags = merge(var.tags, { Name = "terraform_project" })
}
