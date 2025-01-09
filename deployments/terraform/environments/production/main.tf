module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name = "kwik-e-mart"
  environment  = "production"
}
