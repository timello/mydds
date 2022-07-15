variable "vpc_name" {}
variable "cidr" {}
variable "availability_zones" {
  type = set(string)
}

variable "private_subnets" {
  type = set(string)
}

variable "public_subnets" {
  type = set(string)
}

variable "environment" {}

variable "enable_vpn_gateway" {
  default = false
  type    = bool
}

variable "enable_nat_gateway" {
  default = false
  type    = bool
}

variable "enable_dns_hostnames" {
  default = false
  type    = bool
}

variable "enable_dns_support" {
  default = false
  type    = bool
}

variable "enable_apigw_endpoint" {
  default = false
  type    = bool
}

variable "apigw_endpoint_private_dns_enabled" {
  default = false
  type    = bool
}

variable "enable_dynamodb_endpoint" {
  default = false
  type    = bool
}

variable "enable_s3_endpoint" {
  default = false
  type    = bool
}

variable "enable_flow_log" {
  default = false
  type    = bool
}
