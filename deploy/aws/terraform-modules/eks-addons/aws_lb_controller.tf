provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-central-1:${local.aws_account_id}:cluster/myDDS"
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
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::${local.aws_account_id}:role/AmazonEKSLoadBalancerControllerRole"
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
