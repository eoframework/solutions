#------------------------------------------------------------------------------
# Dns Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dns = {
  domain_name = "app.example.com"  # Application domain
  health_check_failure_threshold = 3  # Failures before failover
  health_check_interval = 30  # Health check interval seconds
  hosted_zone_id = "Z0123456789ABCDEFGHIJ"  # Route 53 hosted zone ID
}
