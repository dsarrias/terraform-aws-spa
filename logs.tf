locals {
  create_logs_bucket = var.enable_cloudfront_logging || var.enable_s3_logging
}

# S3 server access logs only support SSE-S3 targets
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = "${aws_s3_bucket.this.bucket}-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront standard logging (legacy) writes through ACLs
resource "aws_s3_bucket_ownership_controls" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.access_logs_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.enable_s3_logging ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id
  policy = data.aws_iam_policy_document.logs[0].json
}

resource "aws_s3_bucket_logging" "this" {
  count = var.enable_s3_logging ? 1 : 0

  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "s3/"
}
