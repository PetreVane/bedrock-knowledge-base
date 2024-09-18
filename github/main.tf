terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.owner
}

# Retrieves information about the AWS account ID, user, and ARN
# for the current AWS session.
data "aws_caller_identity" "current" {}

# Attempts to retrieve an existing AWS IAM OpenID Connect provider configuration
# for GitHub. This is used to check if it already exists to avoid creating a duplicate.
data "aws_iam_openid_connect_provider" "existing_github_provider" {
  # Determines whether to retrieve the existing provider or not
  # based on the value of var.create_oidc_provider.
  count = var.create_oidc_provider ? 0 : 1
  # URL of the OIDC provider, pointing to GitHub Actions.
  url = "https://token.actions.githubusercontent.com"
}

# Retrieves the TLS certificate from GitHub's OIDC configuration endpoint.
# This is used to secure the connection by verifying the server's identity.
data "tls_certificate" "github_actions" {
  # URL from which to fetch the TLS certificate for the OIDC provider.
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Manages the creation of an AWS IAM OpenID Connect provider for GitHub Actions.
# This enables integration of GitHub Actions with AWS IAM security for authentication.
resource "aws_iam_openid_connect_provider" "github_actions" {
  # Creates the OIDC provider if var.create_oidc_provider is true; otherwise, skips creation.
  count = var.create_oidc_provider ? 1 : 0
  # Client IDs allowed to authenticate with this provider; here it allows STS service.
  client_id_list  = ["sts.amazonaws.com"]
  # Uses the SHA1 fingerprint from the retrieved TLS certificate to ensure secure connection.
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
  # URL of the OIDC provider, linking to GitHub Actions.
  url             = "https://token.actions.githubusercontent.com"
}


/*
This block defines local variables:

- role_name is set to a string that includes the account id and region, making it unique
- oidc_provider_arn is a conditional that decides which OIDC provider ARN to use based on whether
  we're creating a new one or using an existing one.

 */
locals {
  // construct a unique role name
  role_name = "github_actions_role-${var.aws_region}"
  oidc_provider_arn = var.create_oidc_provider ? (
    length(aws_iam_openid_connect_provider.github_actions) > 0 ?
    aws_iam_openid_connect_provider.github_actions[0].arn :
    null
  ) : (
    length(data.aws_iam_openid_connect_provider.existing_github_provider) > 0 ?
    data.aws_iam_openid_connect_provider.existing_github_provider[0].arn :
    null
  )
}

# Defines the IAM policy document for the assume role policy
data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    # Allows the AssumeRoleWithWebIdentity action
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"
      # Uses the OIDC provider ARN, falling back to a constructed ARN if not provided
      identifiers = [
          local.oidc_provider_arn != null ? local.oidc_provider_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      ]
    }

    # Condition to ensure the token audience matches sts.amazonaws.com
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Condition to limit the role assumption to specific GitHub repositories
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.owner}/${var.github_repo}:*"]
    }
  }
}

# Creates the IAM role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name               = local.role_name
  # Uses the assume role policy document defined above
  assume_role_policy = data.aws_iam_policy_document.github_actions_policy.json
}

# Defines the IAM policy with permissions for GitHub Actions to interact with ECR
resource "aws_iam_policy" "github_actions_ecr_policy" {
  name        = "${local.role_name}-ecr-policy"
  description = "IAM policy for GitHub Actions role to interact with ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = var.ecr_repository_arn
      },
      {
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*"
      }
    ]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_ecr_policy.arn
}

# Adds new entry in GitHub Actions secrets -
# If this fails, you have to add the secrets manually. Make sure your token has repo permissions
resource "github_actions_secret" "aws_account_id" {
  repository       = var.github_repo
  secret_name      = "AWS_ACCOUNT_ID"
  plaintext_value  = data.aws_caller_identity.current.account_id
}

resource "github_actions_secret" "aws_region" {
  repository  = var.github_repo
  secret_name = "AWS_REGION"
  plaintext_value = var.aws_region
}