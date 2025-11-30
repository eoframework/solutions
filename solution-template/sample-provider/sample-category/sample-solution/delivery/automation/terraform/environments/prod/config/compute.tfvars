#------------------------------------------------------------------------------
# Compute Configuration
#------------------------------------------------------------------------------
# Compute infrastructure settings including EC2, Auto Scaling, and Load Balancing.
# These values are typically derived from the delivery configuration.csv
# under the "Compute" or "Application" sections.
#------------------------------------------------------------------------------

compute = {
  #----------------------------------------------------------------------------
  # EC2 Instance Configuration
  #----------------------------------------------------------------------------
  instance_type  = "t3.medium"      # Production: appropriately sized
  use_latest_ami = true             # Use latest Amazon Linux 2023 AMI

  # Root volume configuration
  root_volume_size       = 50       # GB
  root_volume_type       = "gp3"
  root_volume_iops       = 3000
  root_volume_throughput = 125      # MB/s

  # Monitoring
  enable_detailed_monitoring = true # Production: detailed CloudWatch metrics

  #----------------------------------------------------------------------------
  # Auto Scaling Group Configuration
  #----------------------------------------------------------------------------
  enable_auto_scaling    = true
  asg_min_size           = 2        # Production: minimum 2 for HA
  asg_max_size           = 10
  asg_desired_capacity   = 3

  # Health check
  health_check_grace_period = 300   # seconds

  # Scaling thresholds
  scale_up_threshold   = 70         # CPU % to trigger scale up
  scale_down_threshold = 30         # CPU % to trigger scale down
}

alb = {
  #----------------------------------------------------------------------------
  # Application Load Balancer Configuration
  #----------------------------------------------------------------------------
  enabled                    = true
  internal                   = false    # Internet-facing
  enable_deletion_protection = true     # Production: enabled

  # TLS Configuration (uncomment and set for HTTPS)
  # acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"

  # Health check settings
  health_check_path     = "/health"
  health_check_interval = 30        # seconds
  health_check_timeout  = 5         # seconds
  healthy_threshold     = 2         # consecutive checks
  unhealthy_threshold   = 3         # consecutive checks
}
