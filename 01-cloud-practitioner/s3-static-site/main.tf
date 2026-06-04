locals {
  tags = merge({
    Project       = "aws-certification-portfolio"
    Environment   = "study"
    Certification = "cloud-practitioner"
    Module        = "s3-static-site"
  }, var.tags)
}

resource "aws_s3_bucket" "site" {
  # checkov:skip=CKV2_AWS_6: estudo — bucket de site estático é público por design (acesso bloqueado abaixo é intencionalmente desligado)
  bucket = var.bucket_name
  tags   = merge(local.tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "site" {
  # checkov:skip=CKV_AWS_53: estudo — site estático público exige ACLs/policy públicas
  # checkov:skip=CKV_AWS_54: estudo — site estático público exige block_public_policy desligado
  # checkov:skip=CKV_AWS_55: estudo — site estático público exige ignore_public_acls desligado
  # checkov:skip=CKV_AWS_56: estudo — site estático público exige restrict_public_buckets desligado
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document { suffix = "index.html" }
  error_document { key = "error.html" }
}

resource "aws_s3_bucket_policy" "site" {
  # checkov:skip=CKV_AWS_70: estudo — leitura pública (Principal "*") é o objetivo do site estático
  bucket     = aws_s3_bucket.site.id
  depends_on = [aws_s3_bucket_public_access_block.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket_website_configuration.site.website_endpoint
    origin_id   = "S3-${var.bucket_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags
}
