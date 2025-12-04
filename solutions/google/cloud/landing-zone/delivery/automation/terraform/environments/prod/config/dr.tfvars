#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  archive_after_days = 90  # Move to Archive storage after days
  coldline_after_days = 365  # Move to Coldline storage after days
  cross_region_replication = true  # Enable cross-region replication
  enable_dr_kms = true  # Enable DR KMS key
  enable_health_check = true  # Enable DR health check
  enabled = true  # Enable DR infrastructure
  failover_mode = "manual"  # Failover mode
  health_check_interval_sec = 5  # Health check interval (seconds)
  health_check_path = "/health"  # Health check endpoint path
  health_check_port = 80  # Health check port
  health_check_timeout_sec = 5  # Health check timeout (seconds)
  healthy_threshold = 2  # Consecutive healthy checks required
  key_rotation_days = 90  # DR KMS key rotation period (days)
  rpo_minutes = 60  # Recovery Point Objective (minutes)
  rto_minutes = 240  # Recovery Time Objective (minutes)
  strategy = "ACTIVE_PASSIVE"  # DR strategy
  # Consecutive unhealthy checks for failover
  unhealthy_threshold = 3
}
