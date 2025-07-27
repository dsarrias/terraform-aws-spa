resource "aws_kms_key" "this" {
  count = var.kms_key_id == null && var.create_kms_key != false ? 1 : 0

  description             = "Encrypts/Decrypts S3 objects"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "this" {
  count = var.kms_key_id == null && var.create_kms_key != false ? 1 : 0

  name          = "alias/${var.bucket_name != null ? var.bucket_name : "${var.namespace}-${random_id.this[0].hex}"}"
  target_key_id = aws_kms_key.this[0].key_id
}
