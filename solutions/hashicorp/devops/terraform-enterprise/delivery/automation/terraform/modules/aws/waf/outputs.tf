#------------------------------------------------------------------------------
# AWS WAF Module Outputs
#------------------------------------------------------------------------------

output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.main.name
}

output "web_acl_capacity" {
  description = "WAF Web ACL capacity units used"
  value       = aws_wafv2_web_acl.main.capacity
}

output "blocked_ip_set_arn" {
  description = "Blocked IP set ARN"
  value       = length(var.blocked_ip_addresses) > 0 ? aws_wafv2_ip_set.blocked[0].arn : ""
}
