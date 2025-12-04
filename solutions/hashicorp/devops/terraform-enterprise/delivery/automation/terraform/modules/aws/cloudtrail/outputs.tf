#------------------------------------------------------------------------------
# AWS CloudTrail Module Outputs
#------------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.main.id
}

output "bucket_name" {
  description = "CloudTrail S3 bucket name"
  value       = aws_s3_bucket.cloudtrail.id
}

output "bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = aws_s3_bucket.cloudtrail.arn
}
