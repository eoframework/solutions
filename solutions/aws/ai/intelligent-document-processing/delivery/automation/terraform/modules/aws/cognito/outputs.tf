#------------------------------------------------------------------------------
# AWS Cognito User Pool Module - Outputs
#------------------------------------------------------------------------------

output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_domain" {
  description = "Domain of the Cognito User Pool"
  value       = var.domain != null ? aws_cognito_user_pool_domain.this[0].domain : null
}

output "client_ids" {
  description = "Map of client names to client IDs"
  value       = { for k, v in aws_cognito_user_pool_client.this : k => v.id }
}

output "client_secrets" {
  description = "Map of client names to client secrets (sensitive)"
  value       = { for k, v in aws_cognito_user_pool_client.this : k => v.client_secret }
  sensitive   = true
}

output "resource_server_identifiers" {
  description = "Map of resource server names to identifiers"
  value       = { for k, v in aws_cognito_resource_server.this : k => v.identifier }
}

output "resource_server_scopes" {
  description = "Map of resource server names to scope identifiers"
  value = {
    for k, v in aws_cognito_resource_server.this : k => [
      for scope in v.scope : "${v.identifier}/${scope.scope_name}"
    ]
  }
}
