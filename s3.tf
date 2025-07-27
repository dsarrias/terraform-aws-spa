resource "random_id" "this" {
  count = var.bucket_name != null ? 0 : 1

  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name != null ? var.bucket_name : "${var.namespace}-${random_id.this[0].hex}"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id != null ? var.kms_key_id : var.create_kms_key != false ? aws_kms_key.this[0].id : null
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : var.create_kms_key != false ? "aws:kms" : "AES256"
    }
    bucket_key_enabled = var.kms_key_id != null ? true : var.create_kms_key != false ? true : null
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = var.default_root_object
  }
}
