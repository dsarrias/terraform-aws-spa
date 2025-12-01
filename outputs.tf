output "acm_validation_record" {
  description = "CNAME value you need to add in your DNS registry to validate the ACM certificate in case of using your own domain."
  value = try([
    for dvo in aws_acm_certificate.this[0].domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ], null)
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name. This is the endpoint for the website."
  value       = try(aws_cloudfront_distribution.this.domain_name, null)
}