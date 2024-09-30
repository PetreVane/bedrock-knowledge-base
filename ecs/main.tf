
resource "random_id" "generator" {
  byte_length = 4
}

locals {
  image_uri = try(var.ecr_repository_name, "") != "" ? (
    "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}:latest"
  ) : (
    "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
  )
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
      image     =  local.image_uri
      essential = true

      /*
       Tails the NPM debug log
      - Starts your Node.js application with npm start
      - Tails any log files in the /root/.npm/_logs/ directory
      - Redirects the tailed output to stdout (file descriptor 1)
      - Uses wait to keep the container running
      */
    command = [
        "/bin/sh",
        "-c",
        "npm start & tail -f /root/.npm/_logs/*.log > /proc/1/fd/1 2>&1 & wait"
      ]

      logConfiguration = {
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
