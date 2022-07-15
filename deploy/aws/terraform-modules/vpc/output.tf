output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpce_apigw_network_interface_ids" {
  value = var.enable_apigw_endpoint ? aws_vpc_endpoint.apigw[0].network_interface_ids : null
}

output "vpce_apigw_subnet_ids" {
  value = var.enable_apigw_endpoint ? aws_vpc_endpoint.apigw[0].subnet_ids : null
}

output "s3_vpce_id" {
  value = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}
