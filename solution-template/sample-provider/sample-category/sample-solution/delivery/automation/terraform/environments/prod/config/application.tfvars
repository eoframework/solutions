#------------------------------------------------------------------------------
# Application Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# Application-specific settings and environment variables.
# Generated from: delivery/raw/configuration.csv #SHEET: application
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Application Identity
#------------------------------------------------------------------------------

app_name    = "sample-solution"         # Must match solution_name
app_version = "1.0.0"                   # Semantic versioning

#------------------------------------------------------------------------------
# Server Configuration
#------------------------------------------------------------------------------

app_port = 8080                         # Application server port

#------------------------------------------------------------------------------
# Logging & Debugging
#------------------------------------------------------------------------------

app_log_level    = "warn"               # Production: warn or error only
app_enable_debug = false                # Production: disabled

#------------------------------------------------------------------------------
# Endpoints
#------------------------------------------------------------------------------

app_health_path  = "/health"            # Health check endpoint
app_metrics_path = "/metrics"           # Prometheus metrics endpoint

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------

# CORS origins - restrict to known frontend domains
# app_cors_origins = ["https://app.example.com", "https://www.example.com"]

#------------------------------------------------------------------------------
# Rate Limiting
#------------------------------------------------------------------------------

app_rate_limit      = 1000              # Requests per minute per client
app_session_timeout = 3600              # Session timeout in seconds (1 hour)
