#------------------------------------------------------------------------------
# Compute Configuration - PRODUCTION Environment
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

  # AMI Configuration (when use_latest_ami = true)
  ami_filter_name       = "al2023-ami-*-x86_64"  # Amazon Linux 2023
  ami_virtualization    = "hvm"
  ami_owner             = "amazon"

  # Custom AMI (when use_latest_ami = false)
  # ami_id = "ami-0123456789abcdef0"

  #----------------------------------------------------------------------------
  # Root Volume Configuration
  #----------------------------------------------------------------------------
  root_volume_size       = 50       # GB
  root_volume_type       = "gp3"
  root_volume_iops       = 3000
  root_volume_throughput = 125      # MB/s
  root_volume_encrypted  = true
  root_volume_device     = "/dev/xvda"
  delete_on_termination  = true

  #----------------------------------------------------------------------------
  # Instance Monitoring
  #----------------------------------------------------------------------------
  enable_detailed_monitoring = true # Production: detailed CloudWatch metrics

  #----------------------------------------------------------------------------
  # Instance Network
  #----------------------------------------------------------------------------
  associate_public_ip = false       # Private instances only

  #----------------------------------------------------------------------------
  # Instance Metadata Service
  #----------------------------------------------------------------------------
  metadata_http_endpoint = "enabled"
  metadata_http_tokens   = "required"  # IMDSv2 required
  metadata_hop_limit     = 1
  metadata_tags_enabled  = "enabled"

  #----------------------------------------------------------------------------
  # Auto Scaling Group Configuration
  #----------------------------------------------------------------------------
  enable_auto_scaling    = true
  asg_min_size           = 2        # Production: minimum 2 for HA
  asg_max_size           = 10
  asg_desired_capacity   = 3

  # Health check
  health_check_grace_period = 300   # seconds
  health_check_type         = "ELB" # EC2 or ELB

  # ASG Behavior
  default_cooldown       = 300      # seconds between scaling activities
  termination_policies   = ["Default"]  # OldestInstance, NewestInstance, etc.
  suspended_processes    = []       # Processes to suspend

  #----------------------------------------------------------------------------
  # Instance Refresh (Rolling Updates)
  #----------------------------------------------------------------------------
  instance_refresh_strategy     = "Rolling"  # Rolling or Blue/Green
  instance_refresh_min_healthy  = 50         # Minimum healthy percentage
  instance_refresh_warmup       = 300        # Instance warmup seconds

  #----------------------------------------------------------------------------
  # Launch Template
  #----------------------------------------------------------------------------
  launch_template_version = "$Latest"  # $Latest, $Default, or specific version

  #----------------------------------------------------------------------------
  # Scaling Policies
  #----------------------------------------------------------------------------
  scale_up_threshold   = 70         # CPU % to trigger scale up
  scale_down_threshold = 30         # CPU % to trigger scale down
  scale_up_adjustment  = 2          # Instances to add
  scale_down_adjustment = -1        # Instances to remove
  scaling_cooldown     = 300        # Cooldown between scaling actions

  #----------------------------------------------------------------------------
  # Resource Tags for Instances/Volumes
  #----------------------------------------------------------------------------
  propagate_tags_at_launch = true
}
