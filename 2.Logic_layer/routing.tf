# Define the Route 53 Hosted Zone for shopease_dev12290605_app.com
resource "aws_route53_zone" "shopease_zone" {
  name = "dev11411-app.xyz"
}

# Health check for Mumbai ALB
resource "aws_route53_health_check" "mumbai_health_check" {
  fqdn              = aws_lb.alb_mumbai.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = 3
}

# Health check for Virginia ALB
resource "aws_route53_health_check" "virginia_health_check" {
  fqdn              = aws_lb.alb_virginia.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = 3
}

# Latency-based routing record for Mumbai ALB
resource "aws_route53_record" "latency_mumbai" {
  zone_id = aws_route53_zone.shopease_zone.zone_id
  name    = "dev11411-app.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.alb_mumbai.dns_name
    zone_id                = aws_lb.alb_mumbai.zone_id
    evaluate_target_health = true
  }

  set_identifier = "Mumbai"
  latency_routing_policy {
    region = "ap-south-1"
  }

  health_check_id = aws_route53_health_check.mumbai_health_check.id
}

# Latency-based routing record for Virginia ALB
resource "aws_route53_record" "latency_virginia" {
  zone_id = aws_route53_zone.shopease_zone.zone_id
  name    = "dev11411-app.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.alb_virginia.dns_name
    zone_id                = aws_lb.alb_virginia.zone_id
    evaluate_target_health = true
  }

  set_identifier = "Virginia"
  latency_routing_policy {
    region = "us-east-1"
  }

  health_check_id = aws_route53_health_check.virginia_health_check.id
}
