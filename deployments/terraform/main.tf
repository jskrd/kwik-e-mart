module "shared" {
  source = "./environments/shared"

  project_name = local.project_name
}

module "preview" {
  source = "./environments/preview"

  ecr_repository_url          = module.shared.ecr_repository_url
  ecs_task_execution_role_arn = module.shared.ecs_task_execution_role_arn
  project_name                = local.project_name
}

module "production" {
  source = "./environments/production"

  ecr_repository_url          = module.shared.ecr_repository_url
  ecs_task_execution_role_arn = module.shared.ecs_task_execution_role_arn
  project_name                = local.project_name
}
