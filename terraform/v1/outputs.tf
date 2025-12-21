# Outputs for Version 1

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.web[*].id
}
