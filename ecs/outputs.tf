

output "ecs_execution_role_name" {
  value = aws_iam_role.ecs_execution_role.name
}

output "ecs_task_role_name" {
  value = aws_iam_role.ecs_task_role.name
}