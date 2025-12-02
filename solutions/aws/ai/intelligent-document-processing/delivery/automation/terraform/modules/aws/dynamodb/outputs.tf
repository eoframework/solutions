#------------------------------------------------------------------------------
# AWS DynamoDB Table Module - Outputs
#------------------------------------------------------------------------------

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "Timestamp label of the DynamoDB stream"
  value       = aws_dynamodb_table.this.stream_label
}
