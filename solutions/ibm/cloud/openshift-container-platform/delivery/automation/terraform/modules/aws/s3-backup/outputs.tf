#------------------------------------------------------------------------------
# AWS S3 Backup Module Outputs
#------------------------------------------------------------------------------

output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.backup.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.backup.arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.backup.bucket_domain_name
}
