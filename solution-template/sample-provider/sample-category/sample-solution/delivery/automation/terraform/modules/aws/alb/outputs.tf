# Generic AWS ALB Module - Outputs

output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID for Route 53"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics"
  value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_name" {
  description = "Target group name"
  value       = aws_lb_target_group.this.name
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (null if no certificate)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}
