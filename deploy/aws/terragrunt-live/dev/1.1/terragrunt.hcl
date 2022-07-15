iam_role = "arn:aws:iam::${local.common_vars.aws_account_id}:role/${local.common_vars.role_name}"

locals {
  module_name    = path_relative_to_include()
  module_version = fileexists("${get_terragrunt_dir()}/local_vars.yml") ? yamldecode(file("${get_terragrunt_dir()}/local_vars.yml")).module_version : "latest"
  common_vars    = yamldecode(file(find_in_parent_folders("common_vars.yml")))
}

terraform {
  source = "../../../../terraform-modules//${local.module_name}"
}

inputs = {
  aws_environment = local.common_vars.aws_environment
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = local.common_vars.bucket_name
    key            = "${local.module_name}/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tiagomello-${local.common_vars.aws_account_id}-state-lock"
  }
}

# TODO: https://github.com/hashicorp/terraform-provider-aws/issues/24452
generate "terraform" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.1.2"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.11.0"
    }
  }
}
EOF
}

# Cost allocation tags
generate "tags" {
  path      = "tags.tf"
  if_exists = "skip"
  contents  = <<EOF
locals {
  module_name = basename(abspath(path.module))
  default_tags = {
    "terraform:module" = "${local.module_name}"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "eu-central-1"
  default_tags {
    tags = local.default_tags
  }
}
EOF
}
