resource "aws_s3_bucket" "nodes" {
  for_each = var.nodes

  bucket = each.value
}

resource "aws_s3_bucket_public_access_block" "nodes" {
  for_each = var.nodes

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
