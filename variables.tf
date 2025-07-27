variable "namespace" {
  description = "Namespace used to generate the S3 bucket name and KMS alias in case of usage. Not needed if using `bucket_name`."
  type        = string
  default     = "website-s3-spa"
}

variable "web_repository" {
  description = "Repository of the website from where you will push the code to S3."
  type        = string
}

variable "bucket_name" {
  description = "Unique name for the bucket to be created. If not used the bucket will have the project name as a prefix."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Your own KMS key ID to encrypt S3 objects."
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "If enabled it will create a KMS key to be used in the S3 buckets instead of the default 'aws/s3' AWS KMS master key."
  type        = bool
  default     = false
}

# CloudFront
variable "default_root_object" {
  description = "The object that CloudFront returns when the root URL of the distribution is requested."
  type        = string
  default     = "index.html"
}

variable "http_version" {
  description = "The HTTP version that CloudFront will support when communicating with viewers."
  type        = string
  default     = "http2"
}

variable "price_class" {
  description = "The price class for the CloudFront distribution, controlling the edge locations used."
  type        = string
  default     = "PriceClass_100"
}

variable "domain" {
  description = "yourdomain.tld - This will be used to create the certificate CloudFront will use."
  type        = string
  default     = ""
}

variable "cloudfront_default_certificate" {
  description = "`true` only allows TLSv1 and makes variable `domain` unused. `false` forces using a custom domain that creates a cert using `minimum_protocol_version`."
  type        = bool
  default     = false
}

variable "minimum_protocol_version" {
  description = "The minimum SSL/TLS protocol version that CloudFront will support for HTTPS connections."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "custom_error_response" {
  description = "Custom error response settings for CloudFront, allowing you to serve custom error pages."
  type = object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  })
  default = {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }
}

variable "allowed_methods" {
  description = "List of allowed HTTP methods that CloudFront processes and forwards to the origin."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "List of HTTP methods that CloudFront caches responses for."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "The protocol policy to apply to viewers (e.g., redirect to HTTPS)."
  type        = string
  default     = "redirect-to-https"
}

variable "cache_policy" {
  description = "The cache policy ID or name used by CloudFront for the distribution's behavior."
  type        = string
  default     = "Managed-CachingOptimized"
}
