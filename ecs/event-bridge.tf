

resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  name = "ecr_image_push_event-${random_id.generator.hex}"
  description = "Captures ECR push events"

  event_pattern = jsonencode({
    source = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type = ["PUSH"]
      result = ["SUCCESS"]
      repository-name = [var.ecr_repository_name]
      "image-tag": [{"prefix": "STAGING-"}]
    }
  })
}

resource "aws_cloudwatch_event_target" "update_ecs_task" {
  rule      = aws_cloudwatch_event_rule.ecr_image_push.name
  target_id = "UpdateECSService"
  arn       = aws_ecs_cluster.main_cluster.arn
  role_arn  = aws_iam_role.eventbridge_ecs_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.container_blueprint.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = aws_subnet.ecs_public_subnets[*].id
      assign_public_ip = true
      security_groups  = [aws_security_group.ecs_security_group.id]
    }
    group               = aws_ecs_service.deployed_container.name
    platform_version    = "LATEST"
  }
}

