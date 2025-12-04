#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alb_5xx_threshold = 20  # ALB 5xx error threshold
  alert_email = ""  # Alert notification email
  ec2_cpu_threshold = 90  # EC2 CPU alarm threshold %
  enable_cloudwatch_agent = true  # Enable CloudWatch agent
  log_retention_days = 30  # CloudWatch log retention
  rds_connections_threshold = 100  # RDS connections alarm threshold
  rds_cpu_threshold = 90  # RDS CPU alarm threshold %
}
