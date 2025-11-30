#------------------------------------------------------------------------------
# Monitoring Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# Monitoring and observability settings including CloudWatch and X-Ray.
# These values are typically derived from the delivery configuration.csv
# under the "Monitoring" or "Observability" sections.
#------------------------------------------------------------------------------

monitoring = {
  #----------------------------------------------------------------------------
  # CloudWatch Logs
  #----------------------------------------------------------------------------
  log_retention_days = 90              # Production: 90 days retention

  #----------------------------------------------------------------------------
  # CloudWatch Dashboard & Insights
  #----------------------------------------------------------------------------
  enable_dashboard          = true     # Production: enabled
  enable_container_insights = true     # Production: enabled (for ECS/EKS)

  #----------------------------------------------------------------------------
  # CloudWatch Alarm Defaults
  #----------------------------------------------------------------------------
  alarm_evaluation_periods = 2         # Number of periods to evaluate
  alarm_period_seconds     = 300       # Period duration (5 minutes)
  alarm_treat_missing_data = "missing" # missing, notBreaching, breaching

  #----------------------------------------------------------------------------
  # Dashboard Widget Settings
  #----------------------------------------------------------------------------
  dashboard_widget_width  = 8
  dashboard_widget_height = 6

  #----------------------------------------------------------------------------
  # Alert Notifications
  #----------------------------------------------------------------------------
  # alarm_email = "ops-team@example.com"

  #----------------------------------------------------------------------------
  # X-Ray Tracing Configuration
  #----------------------------------------------------------------------------
  enable_xray_tracing = true           # Production: enabled for debugging

  xray_sampling = {
    priority       = 1000              # Rule priority (lower = higher priority)
    reservoir_size = 1                 # Fixed requests per second to sample
    fixed_rate     = 0.05              # 5% sampling rate
    url_path       = "*"               # URL path pattern to match
    http_method    = "*"               # HTTP method to match
    service_type   = "*"               # Service type to match
    host           = "*"               # Host pattern to match
  }
}

#------------------------------------------------------------------------------
# Resource-Specific Alarm Thresholds
#------------------------------------------------------------------------------
# These thresholds can be tuned per environment (test: relaxed, prod: strict)

alarm_thresholds = {
  #----------------------------------------------------------------------------
  # Database (RDS) Alarms
  #----------------------------------------------------------------------------
  db_cpu_percent            = 80       # CPU utilization threshold
  db_storage_bytes          = 10737418240  # 10 GB free storage threshold
  db_connections            = 100      # Max connections threshold
  db_read_latency_seconds   = 0.02     # 20ms read latency threshold
  db_write_latency_seconds  = 0.05     # 50ms write latency threshold

  #----------------------------------------------------------------------------
  # Cache (ElastiCache) Alarms
  #----------------------------------------------------------------------------
  cache_cpu_percent         = 75       # CPU utilization threshold
  cache_memory_percent      = 80       # Memory utilization threshold
  cache_evictions           = 1000     # Evictions threshold
  cache_connections         = 500      # Current connections threshold

  #----------------------------------------------------------------------------
  # Compute (EC2/ASG) Alarms
  #----------------------------------------------------------------------------
  ec2_cpu_percent           = 80       # CPU utilization threshold
  ec2_memory_percent        = 85       # Memory utilization threshold (requires agent)
  ec2_disk_percent          = 80       # Disk utilization threshold (requires agent)

  #----------------------------------------------------------------------------
  # ALB Alarms
  #----------------------------------------------------------------------------
  alb_5xx_count             = 10       # 5xx errors threshold
  alb_4xx_count             = 100      # 4xx errors threshold
  alb_response_time_seconds = 1.0      # Target response time threshold
  alb_unhealthy_hosts       = 1        # Unhealthy host count threshold
}
