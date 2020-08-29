module network {
  source             = "git::https://github.com/jafow/terraform-modules//aws-blueprints/network?ref=tags/network-0.1.2"
  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  name               = var.vpc_name
  namespace          = var.namespace
  region             = var.region
  stage              = var.stage
  tags               = var.tags
}
