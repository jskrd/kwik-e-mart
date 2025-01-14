module "route53" {
  source = "./modules/route53"

  base_domain  = local.base_domain
  project_name = local.project_name
}

module "acm" {
  source = "./modules/acm"

  route53_zone_arn  = module.route53.zone_arn
  route53_zone_name = module.route53.zone_name
}

module "vpc" {
  source = "./modules/vpc"

  for_each = local.environments

  availability_zones = local.vpc_availability_zones
  environment        = each.value
  project_name       = local.project_name
  project_octet      = local.project_octet
}

module "alb" {
  source = "./modules/alb"

  for_each = local.deployments

  banches           = each.value
  certificate_arn   = module.acm.certificate_arn
  environment       = each.key
  project_name      = local.project_name
  public_subnet_ids = module.vpc[each.key].public_subnet_ids
  route53_zone_name = module.route53.zone_name
  vpc_id            = module.vpc[each.key].id
}

module "iam" {
  source = "./modules/iam"

  project_name = local.project_name
}

module "ecr" {
  source = "./modules/ecr"

  project_name = local.project_name
}

module "ecs" {
  source = "./modules/ecs"

  for_each = local.deployments

  banches                     = each.value
  ecr_repository_url          = module.ecr.repository_url
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  environment                 = each.key
  private_subnet_ids          = module.vpc[each.key].private_subnet_ids
  project_name                = local.project_name
  vpc_id                      = module.vpc[each.key].id
  web_target_group_arn        = module.alb[each.key].web_target_group_arn
}
