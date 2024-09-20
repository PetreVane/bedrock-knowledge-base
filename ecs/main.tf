
resource "random_id" "generator" {
  byte_length = 4
}

# Cluster
resource "aws_ecs_cluster" "main_cluster" {
  name = "main_cluster-${var.aws_region}-${random_id.generator.hex}"
}

# Task definition
resource "aws_ecs_task_definition" "container_blueprint" {
  family = "kb-frontend-blueprint-${random_id.generator.hex}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"  // This is the minimum CPU unit for Fargate
  memory                   = "2048"  // This is the minimum memory for Fargate
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn =     aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "kb_frontend-${var.aws_region}"
      image     = var.ecr_image_uri
      essential = true
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
  name            = "kb_frontend_container-${random_id.generator.hex}"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.container_blueprint.id
  desired_count   = 1
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

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/kb-frontend"
  retention_in_days = 30
}
