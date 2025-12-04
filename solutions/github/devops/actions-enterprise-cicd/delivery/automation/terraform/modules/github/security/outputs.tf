# GitHub Security Module Outputs

output "advanced_security_enabled" {
  description = "Whether Advanced Security is enabled"
  value       = var.enable_advanced_security
}

output "secret_scanning_enabled" {
  description = "Whether secret scanning is enabled"
  value       = var.enable_secret_scanning
}

output "oidc_customization_enabled" {
  description = "Whether OIDC customization is enabled"
  value       = var.enable_oidc_customization
}
