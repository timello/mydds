data "aws_iam_policy_document" "eks_cluster" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "EKSClusterRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.private.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}

data "aws_iam_policy_document" "fargate_pods" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "eks-fargate-pods.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "fargate_pods" {
  name               = "EKSFargatePodsRole"
  assume_role_policy = data.aws_iam_policy_document.fargate_pods.json
}

resource "aws_eks_fargate_profile" "eks_cluster" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${var.cluster_name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pods.arn
  subnet_ids             = data.aws_subnets.private.ids

  selector {
    namespace = var.fg_profile_namespace
  }
}
