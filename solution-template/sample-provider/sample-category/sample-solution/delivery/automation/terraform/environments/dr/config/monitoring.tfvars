#------------------------------------------------------------------------------
# Monitoring Configuration - CloudWatch, SNS - DR Environment
#------------------------------------------------------------------------------
# Enabled for DR visibility and alerting.
#------------------------------------------------------------------------------

alarm_thresholds = {
  alb_4xx_count             = 100
  alb_5xx_count             = 10
  alb_response_time_seconds = 1.0
  alb_unhealthy_hosts       = 1
  cache_connections         = 500
  cache_cpu_percent         = 75
  cache_evictions           = 1000
  cache_memory_percent      = 80
  db_connections            = 100
  db_cpu_percent            = 80
  db_read_latency_seconds   = 0.02
  db_storage_bytes          = 10737418240
  db_write_latency_seconds  = 0.05
  ec2_cpu_percent           = 80
  ec2_disk_percent          = 80
  ec2_memory_percent        = 85
}

monitoring = {
  alarm_evaluation_periods  = 2
  alarm_period_seconds      = 300
  alarm_treat_missing_data  = "missing"
  dashboard_widget_height   = 6
  dashboard_widget_width    = 8
  enable_container_insights = true
  enable_dashboard          = true
  enable_xray_tracing       = true
  log_retention_days        = 90
  xray_sampling = {
    priority       = 1000
    reservoir_size = 1
    fixed_rate     = 0.05
    url_path       = "*"
    http_method    = "*"
    service_type   = "*"
    host           = "*"
  }
}
