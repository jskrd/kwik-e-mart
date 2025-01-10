locals {
  environments           = ["preview", "production"]
  production_branch_name = "main"
  project_name           = "kwik-e-mart"
}

module "ecr_repository" {
  source = "./modules/ecr-repository"

  project_name = local.project_name
}

module "iam_roles" {
  source = "./modules/iam-roles"

  project_name = local.project_name
}

module "ecs_clusters" {
  source = "./modules/ecs-cluster"

  for_each = toset(local.environments)

  environment  = each.value
  project_name = local.project_name
}

module "ecs_task_definitions" {
  source = "./modules/ecs-task-definitions"

  for_each = toset(var.branch_names)

  branch_name                 = each.value
  ecr_repository_url          = module.ecr_repository.url
  ecs_task_execution_role_arn = module.iam_roles.ecs_task_execution_role_arn
  environment                 = each.value == local.production_branch_name ? "production" : "preview"
  project_name                = local.project_name
}
