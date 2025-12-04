#------------------------------------------------------------------------------
# AWS Route53 Module Outputs
#------------------------------------------------------------------------------

output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.zone_id
}

output "api_fqdn" {
  description = "API server FQDN"
  value       = aws_route53_record.api.fqdn
}

output "api_int_fqdn" {
  description = "Internal API server FQDN"
  value       = aws_route53_record.api_int.fqdn
}

output "apps_wildcard_fqdn" {
  description = "Apps wildcard FQDN"
  value       = var.ingress_lb_dns_name != null ? aws_route53_record.apps_wildcard[0].fqdn : null
}

output "console_fqdn" {
  description = "Console FQDN"
  value       = var.ingress_lb_dns_name != null ? aws_route53_record.console[0].fqdn : null
}
