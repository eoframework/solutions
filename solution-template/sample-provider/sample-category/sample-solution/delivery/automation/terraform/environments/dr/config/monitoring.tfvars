#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# DR monitoring settings. Critical for visibility during failover operations.
# All monitoring features should be enabled for DR.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudWatch Logs
#------------------------------------------------------------------------------

log_retention_days = 90               # DR: Match production retention

#------------------------------------------------------------------------------
# CloudWatch Dashboard & Insights
#------------------------------------------------------------------------------

enable_dashboard          = true      # DR: Enabled for visibility
enable_container_insights = true      # DR: Enabled (for ECS/EKS)

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

# Alert notifications (CRITICAL for DR)
# alarm_email = "ops-team@example.com"

#------------------------------------------------------------------------------
# X-Ray Tracing
#------------------------------------------------------------------------------

enable_xray_tracing = true            # DR: Enabled for debugging failover issues
