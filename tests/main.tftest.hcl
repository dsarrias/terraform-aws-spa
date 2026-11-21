mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::mock-bucket"
    }
  }

  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:eu-west-1:123456789012:key/00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "aws_cloudfront_distribution" {
    defaults = {
      arn = "arn:aws:cloudfront::123456789012:distribution/EMOCK"
    }
  }

  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    }
  }
}

mock_provider "aws" {
  alias = "useast1"

  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "aws_wafv2_web_acl" {
    defaults = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/mock/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {}

variables {
  bucket_name    = "my.site.example.com"
  domain         = "site.example.com"
  web_repository = "owner/repo"
}

run "defaults" {
  assert {
    condition     = length(aws_wafv2_web_acl.this) == 0 && aws_cloudfront_distribution.this.web_acl_id == null
    error_message = "WAF must be disabled by default"
  }

  assert {
    condition     = length(aws_s3_bucket.logs) == 0 && length(aws_cloudfront_distribution.this.logging_config) == 0
    error_message = "Access logging must be disabled by default"
  }

  assert {
    condition     = length(aws_acm_certificate.this) == 1
    error_message = "ACM certificate must be created for a custom domain"
  }
}

run "waf" {
  variables {
    create_waf     = true
    waf_rate_limit = 500
  }

  assert {
    condition     = aws_cloudfront_distribution.this.web_acl_id == aws_wafv2_web_acl.this[0].arn
    error_message = "WAF web ACL must be attached to CloudFront"
  }

  assert {
    condition     = aws_wafv2_web_acl.this[0].name == "my-site-example-com"
    error_message = "WAF name must not contain dots"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this[0].rule) == 4
    error_message = "WAF must have the rate limit rule plus 3 managed rule groups"
  }
}

run "all_logging" {
  variables {
    enable_cloudfront_logging  = true
    enable_s3_logging          = true
    access_logs_retention_days = 7
  }

  assert {
    condition     = aws_s3_bucket.logs[0].bucket == "my.site.example.com-logs"
    error_message = "Logs bucket must be named <bucket>-logs"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this.logging_config) == 1 && length(aws_s3_bucket_logging.this) == 1
    error_message = "CloudFront and S3 logging must both be enabled"
  }

  assert {
    condition     = one(one(aws_s3_bucket_lifecycle_configuration.logs[0].rule).expiration).days == 7
    error_message = "Logs must expire after access_logs_retention_days"
  }
}

run "cloudfront_logging_only" {
  variables {
    enable_cloudfront_logging = true
  }

  assert {
    condition     = length(aws_s3_bucket.logs) == 1 && length(aws_s3_bucket_policy.logs) == 0 && length(aws_s3_bucket_logging.this) == 0
    error_message = "Only the logs bucket must be created without S3 access logging"
  }
}

run "kms" {
  variables {
    create_kms_key = true
  }

  assert {
    condition     = length(aws_kms_key.this) == 1
    error_message = "KMS key must be created when create_kms_key is true"
  }
}

run "invalid_waf_rate_limit" {
  command = plan

  variables {
    waf_rate_limit = 5
  }

  expect_failures = [var.waf_rate_limit]
}
