module "shared" {
  source = "./environments/shared"
}

module "preview" {
  source = "./environments/preview"
}

module "production" {
  source = "./environments/production"
}
