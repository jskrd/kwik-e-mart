locals {
  environment = "production"
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  environment  = local.environment
  project_name = var.project_name
}

module "ecs_task_definitions" {
  source = "../../modules/ecs-task-definitions"

  ecr_repository_url          = var.ecr_repository_url
  ecs_task_execution_role_arn = var.ecs_task_execution_role_arn
  environment                 = local.environment
  project_name                = var.project_name
}
