# Output Load Balancer DNS for Mumbai
output "mumbai_load_balancer_dns" {
  value       = aws_lb.alb_mumbai.dns_name
  description = "The DNS name of the Load Balancer in Mumbai"
}

# Output Load Balancer DNS for Virginia
output "virginia_load_balancer_dns" {
  value       = aws_lb.alb_virginia.dns_name
  description = "The DNS name of the Load Balancer in Virginia"
}

# Output Route 53 Hosted Zone ID
output "shopease_hosted_names_servers" {
  value       = aws_route53_zone.shopease_zone.name_servers
  description = ""
}

# Output Route 53 Hosted Zone Name
output "shopease_hosted_zone_name" {
  value       = aws_route53_zone.shopease_zone.name
  description = "The name of the Route 53 hosted zone"
}

