# Route 53 Hosted Zone
resource "aws_route53_zone" "devesh_app" {
  name = "devesh-app.xyz"
}

# Health Check for Mumbai
resource "aws_route53_health_check" "mumbai_health_check" {
  type              = "HTTP"
  port              = 80
  resource_path     = "/"
  fqdn              = "devesh11411mumbai.s3-website.ap-south-1.amazonaws.com"
  request_interval  = 30
  failure_threshold = 3

  depends_on = [aws_instance.mumbai_instance]
}

# Health Check for Virginia
resource "aws_route53_health_check" "virginia_health_check" {
  type              = "HTTP"
  port              = 80
  resource_path     = "/"
  fqdn              = "devesh11411virginia.s3-website.us-east-1.amazonaws.com"
  request_interval  = 30
  failure_threshold = 3

  depends_on = [aws_instance.virginia_instance]
}

# CloudFront Distribution for Mumbai S3 Bucket
resource "aws_cloudfront_distribution" "mumbai" {
  origin {
    domain_name = "devesh11411mumbai.s3-website.ap-south-1.amazonaws.com"
    origin_id   = "mumbai-s3"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "mumbai-s3"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  enabled             = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# CloudFront Distribution for Virginia S3 Bucket
resource "aws_cloudfront_distribution" "virginia" {
  origin {
    domain_name = "devesh11411virginia.s3-website.us-east-1.amazonaws.com"
    origin_id   = "virginia-s3"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "virginia-s3"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  enabled             = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Route 53 Latency-Based Routing Record for Mumbai
resource "aws_route53_record" "latency_mumbai" {
  zone_id = aws_route53_zone.devesh_app.zone_id
  name    = "devesh-app.xyz"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.mumbai.domain_name
    zone_id                = aws_cloudfront_distribution.mumbai.hosted_zone_id
    evaluate_target_health = false
  }

  set_identifier = "Mumbai"
  latency_routing_policy {
    region = "ap-south-1"
  }

  health_check_id = aws_route53_health_check.mumbai_health_check.id
}

# Route 53 Latency-Based Routing Record for Virginia
resource "aws_route53_record" "latency_virginia" {
  zone_id = aws_route53_zone.devesh_app.zone_id
  name    = "devesh-app.xyz"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.virginia.domain_name
    zone_id                = aws_cloudfront_distribution.virginia.hosted_zone_id
    evaluate_target_health = false
  }

  set_identifier = "Virginia"
  latency_routing_policy {
    region = "us-east-1"
  }

  health_check_id = aws_route53_health_check.virginia_health_check.id
}
