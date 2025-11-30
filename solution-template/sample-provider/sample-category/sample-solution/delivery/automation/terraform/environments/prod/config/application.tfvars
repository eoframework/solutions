#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  enable_debug = false  # Enable Debug
  health_path = "/health"  # Health Path
  log_level = "warn"  # Log Level
  metrics_path = "/metrics"  # Metrics Path
  name = "sample-solution"  # Solution name for resource naming
  port = 8080  # Cache port number
  rate_limit = 1000  # Rate Limit
  session_timeout = 3600  # Session Timeout
  version = "1.0.0"  # Version
}

solution = {
  abbr = "smp"  # Solution abbreviation (3-4 chars)
  category_name = "sample-category"  # Solution category
  name = "sample-solution"  # Solution name for resource naming
  provider_name = "sample-provider"  # Provider organization name
}
