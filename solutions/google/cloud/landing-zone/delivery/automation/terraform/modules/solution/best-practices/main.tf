#------------------------------------------------------------------------------
# Best Practices Module
#------------------------------------------------------------------------------
# Consolidated module for GCP best practices aligned with Well-Architected Framework:
# - Operational Excellence: Cloud Monitoring (handled by separate monitoring module)
# - Security: Security Command Center, Cloud Armor
# - Reliability: DR Replication
# - Cost Optimization: Billing Budgets
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Cost Optimization: Billing Budgets
#------------------------------------------------------------------------------
module "budgets" {
  source = "../../gcp/best-practices/cost-optimization/budgets"
  count  = var.budget.enabled ? 1 : 0

  billing_account_id    = var.billing_account_id
  name_prefix           = var.name_prefix
  project_ids           = var.project_ids
  budget                = var.budget
  notification_channels = var.notification_channels
}

#------------------------------------------------------------------------------
# Security: Security Command Center
#------------------------------------------------------------------------------
module "scc" {
  source = "../../gcp/best-practices/security/scc"
  count  = var.security.scc_tier != "Disabled" ? 1 : 0

  org_id      = var.org_id
  name_prefix = var.name_prefix
  scc = {
    tier                             = var.security.scc_tier
    enable_public_resource_detection = var.security.scc_public_resource_detection
    enable_notifications             = var.security.scc_notifications_enabled
  }
  pubsub_topic_id = var.scc_pubsub_topic_id
}

#------------------------------------------------------------------------------
# Security: Cloud Armor WAF
#------------------------------------------------------------------------------
module "cloud_armor" {
  source = "../../gcp/best-practices/security/cloud-armor"
  count  = var.security.cloud_armor_enabled ? 1 : 0

  project_id  = var.security_project_id
  name_prefix = var.name_prefix
  cloud_armor = {
    enabled                        = var.security.cloud_armor_enabled
    enable_owasp_rules             = var.security.cloud_armor_owasp_rules
    enable_rate_limiting           = var.security.cloud_armor_rate_limiting
    rate_limit_requests_per_minute = var.security.rate_limit_requests_per_minute
    rate_limit_ban_duration_sec    = var.security.rate_limit_ban_duration_sec
    blocked_countries              = var.security.blocked_countries
  }
}

#------------------------------------------------------------------------------
# Reliability: DR Replication
#------------------------------------------------------------------------------
module "dr_replication" {
  source = "../../gcp/best-practices/reliability/dr-replication"
  count  = var.dr.enabled ? 1 : 0

  project_id    = var.security_project_id
  name_prefix   = var.name_prefix
  dr_region     = var.dr_region
  common_labels = var.common_labels

  dr = {
    enabled                   = var.dr.enabled
    cross_region_replication  = var.dr.cross_region_replication
    archive_after_days        = var.dr.archive_after_days
    coldline_after_days       = var.dr.coldline_after_days
    enable_health_check       = var.dr.enable_health_check
    health_check_interval_sec = var.dr.health_check_interval_sec
    health_check_timeout_sec  = var.dr.health_check_timeout_sec
    healthy_threshold         = var.dr.healthy_threshold
    unhealthy_threshold       = var.dr.unhealthy_threshold
    health_check_port         = var.dr.health_check_port
    health_check_path         = var.dr.health_check_path
    enable_dr_kms             = var.dr.enable_dr_kms
    key_rotation_days         = var.dr.key_rotation_days
  }
}
