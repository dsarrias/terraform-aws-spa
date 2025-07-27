resource "aws_cloudfront_origin_access_control" "this" {
  name                              = aws_s3_bucket.this.id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  http_version        = var.http_version
  aliases             = [var.domain]
  price_class         = var.price_class

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.this.id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = aws_s3_bucket.this.id
    cache_policy_id  = data.aws_cloudfront_cache_policy.this.id

    compress               = true
    viewer_protocol_policy = var.viewer_protocol_policy
  }

  ordered_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    path_pattern           = "*"
    target_origin_id       = aws_s3_bucket.this.id
    viewer_protocol_policy = var.viewer_protocol_policy
    cache_policy_id        = data.aws_cloudfront_cache_policy.this.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = var.cloudfront_default_certificate != true ? aws_acm_certificate.this[0].arn : null
    minimum_protocol_version       = var.cloudfront_default_certificate != true ? var.minimum_protocol_version : null
    ssl_support_method             = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = var.custom_error_response.error_caching_min_ttl
    error_code            = var.custom_error_response.error_code
    response_code         = var.custom_error_response.response_code
    response_page_path    = var.custom_error_response.response_page_path
  }
}