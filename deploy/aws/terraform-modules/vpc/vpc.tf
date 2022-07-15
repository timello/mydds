resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket = "${var.vpc_name}-vpc-flow-logs"
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  # The following parameters are required to be enabled when creating a VPC
  # for private API Gateway.
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_flow_log           = var.enable_flow_log
  flow_log_destination_type = var.enable_flow_log ? "s3" : null
  flow_log_destination_arn  = var.enable_flow_log ? aws_s3_bucket.vpc_flow_logs.arn : null

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }
}

data "aws_vpc_endpoint_service" "apigw" {
  count   = var.enable_apigw_endpoint ? 1 : 0
  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  count = var.enable_apigw_endpoint ? 1 : 0

  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.apigw[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = module.vpc.private_subnets
  # https://st-g.de/2019/07/be-careful-with-aws-private-api-gateway-endpoints
  private_dns_enabled = var.apigw_endpoint_private_dns_enabled
}

data "aws_vpc_endpoint_service" "dynamodb" {
  count   = var.enable_dynamodb_endpoint ? 1 : 0
  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.dynamodb[0].service_name
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  for_each = {
    for id in module.vpc.private_route_table_ids :
    id => id
    if var.enable_dynamodb_endpoint
  }

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = each.value
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id = module.vpc.vpc_id
  # https://github.com/hashicorp/terraform-provider-aws/issues/17417
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  for_each = {
    for id in module.vpc.private_route_table_ids :
    id => id
    if var.enable_s3_endpoint
  }

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = each.value
}
