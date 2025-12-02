#------------------------------------------------------------------------------
# AWS API Gateway REST API Module - Outputs
#------------------------------------------------------------------------------

output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "API Gateway REST API ARN"
  value       = aws_api_gateway_rest_api.this.arn
}

output "root_resource_id" {
  description = "Root resource ID"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "execution_arn" {
  description = "Execution ARN for Lambda permissions"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_name" {
  description = "Deployed stage name"
  value       = aws_api_gateway_stage.this.stage_name
}

output "invoke_url" {
  description = "Invoke URL for the API"
  value       = aws_api_gateway_stage.this.invoke_url
}
