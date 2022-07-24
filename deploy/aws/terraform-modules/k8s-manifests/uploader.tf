locals {
  name      = "uploader"
  port      = 8080
  namespace = "default"
  selector  = "uploader"
  replicas  = 1
  image     = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/uploader:latest"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-central-1:${local.aws_account_id}:cluster/${var.cluster_name}"
}

resource "kubernetes_manifest" "uploader_deployment" {
  provider = kubernetes
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = local.name
      namespace = local.namespace
    }
    spec = {
      replicas = local.replicas
      selector = {
        matchLabels = {
          app = local.selector
        }
      }
      template = {
        metadata = {
          labels = {
            app = local.name
          }
        }
        spec = {
          containers = [
            {
              name  = local.name
              image = local.image
              ports = [
                {
                  containerPort = local.port
                }
              ]
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "uploader_service" {
  provider = kubernetes
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = local.name
      namespace = local.namespace
    }
    spec = {
      type = "NodePort"
      ports = [
        {
          port = local.port
        }
      ]
      selector = {
        app = local.selector
      }
    }
  }

  depends_on = [kubernetes_manifest.uploader_deployment]
}

resource "kubernetes_manifest" "uploader_ingress" {
  provider = kubernetes
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = local.name
      namespace = local.namespace
      annotations = {
        "kubernetes.io/ingress.class"                = "alb"
        "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"      = "ip"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
      }
    }
    spec = {
      rules = [
        {
          http = {
            paths = [
              {
                path     = "/health"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = local.name
                    port = {
                      number = local.port
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.uploader_service]
}
