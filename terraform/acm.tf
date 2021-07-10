resource "aws_acm_certificate" "domain" {
  domain_name       = var.domain-name
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}