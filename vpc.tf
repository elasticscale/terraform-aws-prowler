module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "4.0.2"
  name               = "${var.prefix}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = var.use_nat_gateway
  single_nat_gateway = true
  enable_vpn_gateway = false
}