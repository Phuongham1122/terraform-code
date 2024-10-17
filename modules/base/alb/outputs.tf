output "DNS_host" {
  value = aws_lb.application_load_balancer.dns_name
}