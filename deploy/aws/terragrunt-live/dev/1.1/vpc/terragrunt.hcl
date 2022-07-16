include {
  path = find_in_parent_folders()
}

inputs = {
  vpc_name              = "tiagomello-dev"
  cidr                  = "10.10.0.0/22"
  availability_zones    = ["eu-central-1a", "eu-central-1b"]
  private_subnets       = ["10.10.0.0/24", "10.10.2.0/24"]
  public_subnets        = ["10.10.1.0/24", "10.10.3.0/24"]
  environment           = "dev"
  enable_nat_gateway    = true
  enable_dns_hostnames  = true
  enable_dns_support    = true
}
