output "web_task_definition_arn" {
  value = aws_ecs_task_definition.web.arn
}

output "worker_task_definition_arn" {
  value = aws_ecs_task_definition.worker.arn
}

output "scheduler_task_definition_arn" {
  value = aws_ecs_task_definition.scheduler.arn
}
