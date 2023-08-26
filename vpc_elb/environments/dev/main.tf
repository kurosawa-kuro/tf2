module "vpc" {
  source = "../../modules/vpc"
}

module "alb" {
  source                     = "../../modules/alb"
  subnet_ids                 = module.vpc.public_subnet_ids
}
