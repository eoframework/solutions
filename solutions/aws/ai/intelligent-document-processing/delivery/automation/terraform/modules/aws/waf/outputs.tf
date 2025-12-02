# Generic AWS WAF Module - Outputs

output "web_acl_id" {
  description = "Web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "Web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_capacity" {
  description = "Web ACL capacity units used"
  value       = aws_wafv2_web_acl.this.capacity
}

output "blocked_ip_set_arn" {
  description = "Blocked IP set ARN"
  value       = length(aws_wafv2_ip_set.blocked) > 0 ? aws_wafv2_ip_set.blocked[0].arn : null
}

output "allowed_ip_set_arn" {
  description = "Allowed IP set ARN"
  value       = length(aws_wafv2_ip_set.allowed) > 0 ? aws_wafv2_ip_set.allowed[0].arn : null
}
