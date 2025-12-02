#------------------------------------------------------------------------------
# Compute Configuration - EC2, ASG - DR Environment
#------------------------------------------------------------------------------
# DR DIFFERENCES:
# - ASG min/desired: 1 (minimal standby capacity)
# - ASG max: Same as production (for failover)
# - Instance type: Same as production (failover capability)
#------------------------------------------------------------------------------

compute = {
  # EC2 Instance Configuration
  ami_filter_name    = "al2023-ami-*-x86_64"
  ami_owner          = "amazon"
  ami_virtualization = "hvm"
  instance_type      = "t3.medium"
  use_latest_ami     = true

  # Root Volume Configuration
  root_volume_size       = 50
  root_volume_type       = "gp3"
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true
  root_volume_device     = "/dev/xvda"
  delete_on_termination  = true

  # Instance Monitoring & Network
  enable_detailed_monitoring = true
  associate_public_ip        = false

  # Instance Metadata Service
  metadata_http_endpoint = "enabled"
  metadata_http_tokens   = "required"
  metadata_hop_limit     = 1
  metadata_tags_enabled  = "enabled"

  # Auto Scaling Group (DR STANDBY MODE)
  enable_auto_scaling       = true
  asg_min_size              = 1
  asg_max_size              = 10
  asg_desired_capacity      = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  default_cooldown          = 300
  termination_policies      = ["Default"]
  suspended_processes       = []

  # Instance Refresh
  instance_refresh_strategy    = "Rolling"
  instance_refresh_min_healthy = 50
  instance_refresh_warmup      = 300
  launch_template_version      = "$Latest"

  # Scaling Policies
  scale_up_threshold    = 70
  scale_down_threshold  = 30
  scale_up_adjustment   = 2
  scale_down_adjustment = -1
  scaling_cooldown      = 300

  # Tags
  propagate_tags_at_launch = true
}
