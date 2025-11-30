#------------------------------------------------------------------------------
# Application Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# Application-specific settings and environment variables.
# Generated from: delivery/raw/configuration.csv #SHEET: application
#------------------------------------------------------------------------------

application = {
  #----------------------------------------------------------------------------
  # Application Identity
  #----------------------------------------------------------------------------
  name    = "sample-solution"            # Must match solution_name
  version = "1.0.0"                      # Semantic versioning

  #----------------------------------------------------------------------------
  # Server Configuration
  #----------------------------------------------------------------------------
  port = 8080                            # Application server port

  #----------------------------------------------------------------------------
  # Logging & Debugging
  #----------------------------------------------------------------------------
  log_level    = "warn"                  # Production: warn or error only
  enable_debug = false                   # Production: disabled

  #----------------------------------------------------------------------------
  # Endpoints
  #----------------------------------------------------------------------------
  health_path  = "/health"               # Health check endpoint
  metrics_path = "/metrics"              # Prometheus metrics endpoint

  #----------------------------------------------------------------------------
  # Security
  #----------------------------------------------------------------------------
  # CORS origins - restrict to known frontend domains
  # cors_origins = ["https://app.example.com", "https://www.example.com"]

  #----------------------------------------------------------------------------
  # Rate Limiting
  #----------------------------------------------------------------------------
  rate_limit      = 1000                 # Requests per minute per client
  session_timeout = 3600                 # Session timeout in seconds (1 hour)
}
