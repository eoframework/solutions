#------------------------------------------------------------------------------
# Monitoring Configuration - CloudWatch, SNS - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

alarm_thresholds = {
  alb_4xx_count = 100  # Alb 4Xx Count
  alb_5xx_count = 10  # Alb 5Xx Count
  alb_response_time_seconds = "1.0"  # Alb Response Time Seconds
  alb_unhealthy_hosts = 1  # Alb Unhealthy Hosts
  cache_connections = 500  # Cache Connections
  cache_cpu_percent = 75  # Cache Cpu Percent
  cache_evictions = 1000  # Cache Evictions
  cache_memory_percent = 80  # Cache Memory Percent
  db_connections = 100  # Db Connections
  db_cpu_percent = 80  # Db Cpu Percent
  db_read_latency_seconds = "0.02"  # Db Read Latency Seconds
  db_storage_bytes = 10737418240  # Db Storage Bytes
  db_write_latency_seconds = "0.05"  # Db Write Latency Seconds
  ec2_cpu_percent = 80  # Ec2 Cpu Percent
  ec2_disk_percent = 80  # Ec2 Disk Percent
  ec2_memory_percent = 85  # Ec2 Memory Percent
}

monitoring = {
  alarm_evaluation_periods = 2  # Alarm Evaluation Periods
  alarm_period_seconds = 300  # Alarm Period Seconds
  alarm_treat_missing_data = "missing"  # Alarm Treat Missing Data
  dashboard_widget_height = 6  # Dashboard Widget Height
  dashboard_widget_width = 8  # Dashboard Widget Width
  enable_container_insights = true  # Enable Container Insights
  enable_dashboard = true  # Create CloudWatch dashboard
  enable_xray_tracing = true  # Enable AWS X-Ray tracing
  log_retention_days = 90  # CloudWatch log retention (days)
  xray_sampling = { priority = 1000, reservoir_size = 1, fixed_rate = 0.05, url_path = "*", http_method = "*", service_type = "*", host = "*" }  # Xray Sampling
}
