#------------------------------------------------------------------------------
# Application Configuration - DR Environment
#------------------------------------------------------------------------------
# Same as production - application config must match for failover compatibility.
#------------------------------------------------------------------------------

application = {
  enable_debug    = false
  health_path     = "/health"
  log_level       = "warn"
  metrics_path    = "/metrics"
  name            = "sample-solution"
  port            = 8080
  rate_limit      = 1000
  session_timeout = 3600
  version         = "1.0.0"
}

solution = {
  abbr          = "smp"
  category_name = "sample-category"
  name          = "sample-solution"
  provider_name = "sample-provider"
}
