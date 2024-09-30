data "aws_caller_identity" "current" {}

# ==== ECS Execution Role ===
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role-${random_id.generator.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_execution_role_ecr_access" {
  description = "IAM policy for ECS tasks to other AWS services"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": var.ecr_repository_arn
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_role_ecr_access.arn
}

# ==== ECS Task Role ===
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role-${random_id.generator.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_bedrock_access.arn
}

resource "aws_iam_policy" "ecs_bedrock_access" {
  name        = "ecs_bedrock_access_policy-${random_id.generator.hex}"
  description = "IAM policy for ECS tasks to access Bedrock and related services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid"    : "BedrockAll",
        "Effect" : "Allow",
        "Action": [
          "bedrock:*"
        ],
        "Resource": "${var.bedrock_kb_arn}"
      },
      {
        "Sid"    : "APIsWithAllResourceAccess",
        "Effect": "Allow",
        "Action" : [
          "iam:ListRoles",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        "Resource": "*"
      },
      {
        "Sid"    : "PassRoleToBedrock",
        "Effect": "Allow",
        "Action": [
          "iam:*"
        ],
        "Resource": "${var.bedrock_kb_arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:*"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Sid": "IAMUserAccess",
        "Effect": "Allow",
        "Action": [
          "iam:*"
        ],
        "Resource": "${var.bedrock_user}"
      }
    ]
  })
}


resource "aws_iam_role" "eventbridge_ecs_role" {
  name = "eventbridge_ecs_role-${random_id.generator.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event_bridge_ecs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  role       = aws_iam_role.eventbridge_ecs_role.name
}

resource "aws_iam_role_policy" "eventbridge_update_ecs_policy" {
  name = "eventbridge_update_ecs_policy"
  role = aws_iam_role.eventbridge_ecs_role.id

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "${aws_ecs_service.deployed_container.id}"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:RunTask"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_cloudwatch_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
