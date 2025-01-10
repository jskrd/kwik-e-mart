output "ecr_repository_url" {
  value = module.ecr_repository.url
}

output "ecs_task_execution_role_arn" {
  value = module.iam_roles.ecs_task_execution_role_arn
}
