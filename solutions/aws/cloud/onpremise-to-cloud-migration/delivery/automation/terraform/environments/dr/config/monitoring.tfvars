#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alb_5xx_threshold = 10  # ALB 5xx error threshold
  alert_email = "ops-team@company.com"  # Alert notification email
  ec2_cpu_threshold = 80  # EC2 CPU alarm threshold %
  enable_cloudwatch_agent = true  # Enable CloudWatch agent
  log_retention_days = 90  # CloudWatch log retention
  rds_connections_threshold = 200  # RDS connections alarm threshold
  rds_cpu_threshold = 80  # RDS CPU alarm threshold %
}
