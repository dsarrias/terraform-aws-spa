data "aws_caller_identity" "current" {}

data "aws_cloudfront_cache_policy" "this" {
  name = var.cache_policy
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.this.arn]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid    = "AllowUseOfKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.this.arn]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.web_repository}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

data "aws_iam_policy_document" "github" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.this.arn]
  }
}