locals {
  availability_zones = {
    preview    = ["eu-west-1a", "eu-west-1b"]
    production = ["eu-west-1a", "eu-west-1b"]
  }
  base_domain = "skrd.io"
  deployments = {
    for env in local.environments : env => toset([
      for branch in var.branches : branch
      if(env == "production" && branch == local.production_branch) ||
      (env == "preview" && branch != local.production_branch)
    ])
  }
  environments      = toset(["preview", "production"])
  production_branch = "main"
  project_name      = "kwik-e-mart"
  project_octet     = 228
  region            = "eu-west-1"
}
