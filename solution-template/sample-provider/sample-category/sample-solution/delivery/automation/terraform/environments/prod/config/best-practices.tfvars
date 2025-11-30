#------------------------------------------------------------------------------
# Best Practices Configuration
#------------------------------------------------------------------------------
# Aligned with AWS Well-Architected Framework 6 pillars:
#
# IN THIS FILE:
#   Cost Optimization     - Budgets, alerts, cold storage tiering
#   Reliability           - Backup plans, retention policies, DR
#   Operational Excellence - AWS Config, compliance monitoring
#
# IN OTHER CONFIG FILES (cross-reference):
#   Security              - See security.tfvars (WAF, GuardDuty, KMS, IAM)
#   Performance Efficiency - See compute.tfvars (instance types, scaling)
#                           See cache.tfvars (caching layer)
#   Sustainability        - Achieved via right-sizing in compute.tfvars
#                           Consider Graviton instances for lower carbon
#------------------------------------------------------------------------------

config_rules = {
  #----------------------------------------------------------------------------
  # Operational Excellence: AWS Config Rules
  #----------------------------------------------------------------------------
  enabled          = true
  enable_recorder  = true
  # bucket_name    = ""        # Auto-generated: {name_prefix}-config
  retention_days   = 365
}

guardduty_enhanced = {
  #----------------------------------------------------------------------------
  # Security: Enhanced GuardDuty
  #----------------------------------------------------------------------------
  # Note: Basic GuardDuty may already be enabled via the security module.
  # Set enabled = true for additional protections like S3 protection,
  # EKS protection, and malware scanning.
  enabled              = false    # Set true if not using security module
  enable_eks_protection     = false    # Enable if using EKS
  enable_malware_protection = true
  # findings_bucket    = ""       # Auto-generated if empty
  severity_threshold   = 7        # Alert on High/Critical only
}

backup = {
  #----------------------------------------------------------------------------
  # Reliability: AWS Backup
  #----------------------------------------------------------------------------
  enabled = true

  # Daily backups (retain 30 days)
  daily_schedule   = "cron(0 5 * * ? *)"     # 5 AM UTC daily
  daily_retention  = 30

  # Weekly backups (retain 90 days)
  weekly_schedule  = "cron(0 5 ? * SUN *)"   # Sunday 5 AM UTC
  weekly_retention = 90

  # Monthly backups (retain 1 year, cold storage after 90 days)
  monthly_schedule   = "cron(0 5 1 * ? *)"   # 1st of month 5 AM UTC
  monthly_retention  = 365
  cold_storage_days  = 90

  # Cross-region DR (optional)
  enable_cross_region = false
  dr_retention        = 30
  # dr_kms_key_arn    = ""        # Required if cross-region enabled

  # Advanced options
  enable_continuous = false       # Point-in-time recovery
  enable_windows_vss = false      # Windows application-consistent backups

  # Compliance (WORM)
  enable_vault_lock        = false
  vault_lock_min_retention = 7
  vault_lock_max_retention = 365
  vault_lock_changeable_days = 3
}

budget = {
  #----------------------------------------------------------------------------
  # Cost Optimization: AWS Budgets
  #----------------------------------------------------------------------------
  enabled = true

  # Monthly cost budget
  monthly_amount     = 1000          # Adjust to expected monthly spend
  alert_thresholds   = [50, 80, 100] # Alert at 50%, 80%, 100%
  forecast_threshold = 100           # Alert if forecast exceeds 100%

  # Alert recipients
  alert_emails = [
    # "finance@example.com",
    # "team-lead@example.com"
  ]

  # Service-specific budgets (optional)
  enable_service_budgets      = false
  ec2_budget_amount           = 0    # 0 = disabled
  rds_budget_amount           = 0
  data_transfer_budget_amount = 0

  # Usage budget (optional)
  enable_usage_budget   = false
  ec2_usage_hours_limit = 1000

  # Budget actions - automated cost control (use with caution!)
  enable_actions     = false
  action_approval    = "MANUAL"      # MANUAL or AUTOMATIC
  action_threshold   = 100
  ec2_instances_to_stop = [
    # "i-1234567890abcdef0"   # Non-critical instances to stop
  ]
}
