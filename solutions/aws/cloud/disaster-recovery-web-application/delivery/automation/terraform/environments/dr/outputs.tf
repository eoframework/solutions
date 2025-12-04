#------------------------------------------------------------------------------
# DR Web Application - DR Environment Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name for failover"
  value       = module.core.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = module.core.alb_zone_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint (read-only until failover)"
  value       = module.database.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.database.reader_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name (receives replicas)"
  value       = module.storage.bucket_name
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.security.kms_key_arn
}

output "dr_status" {
  description = "DR environment status"
  value = {
    region           = var.aws.region
    primary_region   = var.aws.dr_region
    standby_mode     = true
    asg_capacity     = var.compute.asg_desired_capacity
    is_primary_db    = var.database.is_primary_region
  }
}

output "failover_runbook" {
  description = "DR failover steps"
  value = <<-EOT
    DR Failover Runbook:
    1. Verify primary region failure via Route 53 health checks
    2. Scale ASG: aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${local.name_prefix}-asg --desired-capacity 3
    3. Promote Aurora: aws rds failover-global-cluster --global-cluster-identifier ${var.solution.abbr}-global
    4. Verify application health at ALB endpoint
    5. Update DNS if manual failover mode

    RTO Target: ${var.dr.rto_target_minutes} minutes
    RPO Target: ${var.dr.rpo_target_minutes} minutes
  EOT
}
