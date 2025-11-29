#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
# Monitoring and observability settings including CloudWatch and X-Ray.
# These values are typically derived from the delivery configuration.csv
# under the "Monitoring" or "Observability" sections.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudWatch Logs
#------------------------------------------------------------------------------

log_retention_days = 90              # Production: 90 days retention

#------------------------------------------------------------------------------
# CloudWatch Dashboard & Insights
#------------------------------------------------------------------------------

enable_dashboard          = true     # Production: enabled
enable_container_insights = true     # Production: enabled (for ECS/EKS)

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

# Alert notifications (set email for alarm notifications)
# alarm_email = "ops-team@example.com"

#------------------------------------------------------------------------------
# X-Ray Tracing
#------------------------------------------------------------------------------

enable_xray_tracing = true           # Production: enabled for debugging
