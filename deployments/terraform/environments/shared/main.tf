module "ecr_repository" {
  source = "../../modules/ecr-repository"

  project_name = var.project_name
}

module "iam_roles" {
  source = "../../modules/iam-roles"

  project_name = var.project_name
}
