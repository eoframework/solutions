#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  archive_after_days = 0  # Move to Archive storage after days
  coldline_after_days = 0  # Move to Coldline storage after days
  cross_region_replication = false  # Enable cross-region replication
  enable_dr_kms = false  # Enable DR KMS key
  enable_health_check = false  # Enable DR health check
  enabled = false  # Enable DR infrastructure
  failover_mode = "manual"  # Failover mode
  health_check_interval_sec = 0  # Health check interval (seconds)
  health_check_path = ""  # Health check endpoint path
  health_check_port = 0  # Health check port
  health_check_timeout_sec = 0  # Health check timeout (seconds)
  healthy_threshold = 0  # Consecutive healthy checks required
  key_rotation_days = 0  # DR KMS key rotation period (days)
  rpo_minutes = 1440  # Recovery Point Objective (minutes)
  rto_minutes = 480  # Recovery Time Objective (minutes)
  strategy = "BACKUP_ONLY"  # DR strategy
  # Consecutive unhealthy checks for failover
  unhealthy_threshold = 0
}
