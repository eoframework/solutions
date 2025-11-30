#------------------------------------------------------------------------------
# Application Configuration - DR Environment
#------------------------------------------------------------------------------
# Application-specific settings for disaster recovery.
# Generated from: delivery/raw/configuration.csv #SHEET: application
#
# DR configuration matches production for failover compatibility.
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

app_log_level    = "warn"               # DR: same as production
app_enable_debug = false                # DR: disabled (matches prod)

#------------------------------------------------------------------------------
# Endpoints
#------------------------------------------------------------------------------

app_health_path  = "/health"            # Health check endpoint
app_metrics_path = "/metrics"           # Prometheus metrics endpoint

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------

# CORS origins - must match production for seamless failover
# app_cors_origins = ["https://app.example.com", "https://www.example.com"]

#------------------------------------------------------------------------------
# Rate Limiting
#------------------------------------------------------------------------------

app_rate_limit      = 1000              # Requests per minute per client
app_session_timeout = 3600              # Session timeout in seconds (1 hour)
