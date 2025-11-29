#------------------------------------------------------------------------------
# Compute Configuration - DR Environment
#------------------------------------------------------------------------------
# DR compute settings. Same instance types as production for failover capability.
# Reduced capacity in standby mode to minimize costs.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# EC2 Instance Configuration (Match Production for Failover)
#------------------------------------------------------------------------------

instance_type  = "t3.medium"          # DR: Same as production
use_latest_ami = true                 # Use latest Amazon Linux 2023 AMI

# Root volume configuration (same as production)
root_volume_size       = 50           # GB
root_volume_type       = "gp3"
root_volume_iops       = 3000
root_volume_throughput = 125          # MB/s

# Monitoring
enable_detailed_monitoring = true     # DR: Enabled for visibility

#------------------------------------------------------------------------------
# Auto Scaling Group Configuration (Reduced Standby Capacity)
#------------------------------------------------------------------------------

enable_auto_scaling    = true
asg_min_size           = 1            # DR: Minimal standby capacity
asg_max_size           = 10           # DR: Same max as production for failover
asg_desired_capacity   = 1            # DR: Minimal until failover activated

# Health check
health_check_grace_period = 300       # seconds

# Scaling thresholds
scale_up_threshold   = 70             # CPU % to trigger scale up
scale_down_threshold = 30             # CPU % to trigger scale down

#------------------------------------------------------------------------------
# Application Load Balancer Configuration
#------------------------------------------------------------------------------

enable_alb                    = true
alb_internal                  = false # Internet-facing for failover
enable_lb_deletion_protection = true  # DR: Enabled for protection

# Health check settings
health_check_path     = "/health"
health_check_interval = 30            # seconds
health_check_timeout  = 5             # seconds
healthy_threshold     = 2             # consecutive checks
unhealthy_threshold   = 3             # consecutive checks

# Application port
app_port = 8080

# TLS Configuration (use DR region certificate)
# acm_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/xxxxx"
