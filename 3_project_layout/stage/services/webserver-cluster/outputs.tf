output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The public dns of the load balancer"
}
