#------------------------------------------------------------------------------
# DR Module Outputs
#------------------------------------------------------------------------------

output "dr_kms_key_arn" {
  description = "DR KMS key ARN"
  value       = aws_kms_key.dr.arn
}

output "dr_kms_key_id" {
  description = "DR KMS key ID"
  value       = aws_kms_key.dr.key_id
}

output "dr_bucket_arn" {
  description = "DR S3 bucket ARN"
  value       = aws_s3_bucket.dr.arn
}

output "dr_bucket_name" {
  description = "DR S3 bucket name"
  value       = aws_s3_bucket.dr.id
}

output "health_check_id" {
  description = "Route 53 health check ID"
  value       = var.dr.enable_health_check ? aws_route53_health_check.primary[0].id : ""
}

output "dr_status" {
  description = "DR configuration status"
  value = {
    enabled          = var.dr.enabled
    region           = var.dr_region
    health_check     = var.dr.enable_health_check
    lifecycle_policy = var.dr.enable_lifecycle
  }
}

output "failover_runbook" {
  description = "DR failover runbook steps"
  value = <<-EOT
    ## DR Failover Runbook

    1. Verify primary region health check failure
    2. Promote DR database replica (if applicable)
    3. Update DNS to point to DR region
    4. Verify application health in DR region
    5. Notify stakeholders of failover

    DR Region: ${var.dr_region}
    DR Bucket: ${aws_s3_bucket.dr.id}
  EOT
}
