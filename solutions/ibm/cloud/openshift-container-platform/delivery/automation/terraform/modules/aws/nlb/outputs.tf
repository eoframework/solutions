#------------------------------------------------------------------------------
# AWS NLB Module Outputs
#------------------------------------------------------------------------------

output "api_lb_arn" {
  description = "API load balancer ARN"
  value       = aws_lb.api.arn
}

output "api_lb_dns_name" {
  description = "API load balancer DNS name"
  value       = aws_lb.api.dns_name
}

output "api_lb_zone_id" {
  description = "API load balancer zone ID"
  value       = aws_lb.api.zone_id
}

output "api_target_group_arn" {
  description = "API target group ARN"
  value       = aws_lb_target_group.api.arn
}

output "mcs_target_group_arn" {
  description = "Machine Config Server target group ARN"
  value       = aws_lb_target_group.mcs.arn
}

output "ingress_lb_arn" {
  description = "Ingress load balancer ARN"
  value       = var.create_ingress_lb ? aws_lb.ingress[0].arn : null
}

output "ingress_lb_dns_name" {
  description = "Ingress load balancer DNS name"
  value       = var.create_ingress_lb ? aws_lb.ingress[0].dns_name : null
}

output "ingress_lb_zone_id" {
  description = "Ingress load balancer zone ID"
  value       = var.create_ingress_lb ? aws_lb.ingress[0].zone_id : null
}

output "ingress_http_target_group_arn" {
  description = "Ingress HTTP target group ARN"
  value       = var.create_ingress_lb ? aws_lb_target_group.ingress_http[0].arn : null
}

output "ingress_https_target_group_arn" {
  description = "Ingress HTTPS target group ARN"
  value       = var.create_ingress_lb ? aws_lb_target_group.ingress_https[0].arn : null
}
