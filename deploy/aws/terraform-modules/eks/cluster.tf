locals {
  cluster_version = "1.22"
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.private.ids

  # TODO: use fargate only: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "backend"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }
}

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "AmazonEKSLoadBalancerControllerRole"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-central-1:415270538324:cluster/myDDS"
}

resource "kubernetes_manifest" "aws_lb_controller_sa" {
  provider = kubernetes
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      }
      name      = "aws-load-balancer-controller"
      namespace = "kube-system"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.load_balancer_controller_irsa_role.iam_role_arn
      }
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = local.aws_region
  }

  set {
    name  = "vpcId"
    value = data.aws_vpc.this.id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
