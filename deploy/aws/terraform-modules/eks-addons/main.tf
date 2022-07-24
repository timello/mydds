data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_subnets" "private" {
  tags = {
    Tier = "private"
  }
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.aws_environment]
  }
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
}
