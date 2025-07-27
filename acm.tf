resource "aws_acm_certificate" "this" {
  count = var.cloudfront_default_certificate != true ? 1 : 0

  provider          = aws.useast1
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
