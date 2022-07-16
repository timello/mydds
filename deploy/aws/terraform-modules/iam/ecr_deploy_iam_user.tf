data "aws_iam_policy_document" "ecr_deployer" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchCheckLayerAvailability",
      "iam:PassRole",
      "iam:ListAccountAliases",
      "logs:DescribeSubscriptionFilters",
      "logs:PutSubscriptionFilter"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "oid_ecr_deployer" {
  name               = "terraformOIDECRDeployerRole"
  assume_role_policy = data.aws_iam_policy_document.oid_github.json
}

resource "aws_iam_role_policy" "oid_ecs_deployer" {
  name   = "terraformOIDECRDeployerPolicy"
  role   = aws_iam_role.oid_ecr_deployer.id
  policy = data.aws_iam_policy_document.ecr_deployer.json
}
