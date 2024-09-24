
resource "random_id" "generator" {
  byte_length = 4
}

data "aws_ecr_image" "most_recent" {
  repository_name = var.ecr_repository_name
  most_recent = true
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/kb-frontend"
  retention_in_days = 1
}

# Cluster
resource "aws_ecs_cluster" "main_cluster" {
  name = "main_cluster-${var.aws_region}"
}

# Task definition
resource "aws_ecs_task_definition" "container_blueprint" {
  family = "kb-frontend-blueprint"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn =     aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "kb_frontend-${var.aws_region}"
      image     =  data.aws_ecr_image.most_recent.image_uri
      essential = true
      logCofiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
       secrets = [
        {
          name = "BAWS_ACCESS_KEY_ID"
          valueFrom = "${var.bedrock_user_access_key_id}"
        },
        {
          name = "BAWS_SECRET_ACCESS_KEY"
          valueFrom = "${var.bedrock_user_access_key_secret}"
        },
        {
          name = "ANTHROPIC_API_KEY"
          valueFrom = "${var.anthropic_api_key}"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "deployed_container" {
  name            = "kb_frontend_container"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.container_blueprint.id
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.ecs_public_subnets[*].id
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_security_group.id]
  }
  deployment_controller {
    type = "ECS"
  }
}
