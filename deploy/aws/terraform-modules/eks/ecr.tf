resource "aws_ecr_repository" "uploader" {
  name                 = "uploader"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "retriever" {
  name                 = "retriever"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "expire_untagged_images" {
  for_each = toset(["uploader", "retriever"])

  repository = each.value
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  depends_on = [
    aws_ecr_repository.uploader,
    aws_ecr_repository.retriever,
  ]
}
