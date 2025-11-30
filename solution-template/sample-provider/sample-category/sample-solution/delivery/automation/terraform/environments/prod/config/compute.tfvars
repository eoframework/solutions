#------------------------------------------------------------------------------
# Compute Configuration - EC2, ASG - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  ami_filter_name = "al2023-ami-*-x86_64"  # Ami Filter Name
  ami_owner = "amazon"  # AMI owner (amazon/self)
  ami_virtualization = "hvm"  # Ami Virtualization
  asg_desired_capacity = 3  # ASG desired instance count
  asg_max_size = 10  # ASG maximum instance count
  asg_min_size = 2  # ASG minimum instance count
  associate_public_ip = false  # Associate Public Ip
  default_cooldown = 300  # Default Cooldown
  delete_on_termination = true  # Delete On Termination
  enable_auto_scaling = true  # Enable Auto Scaling Group
  enable_detailed_monitoring = true  # Enable detailed CloudWatch monitoring
  health_check_grace_period = 300  # Health Check Grace Period
  health_check_type = "ELB"  # Health Check Type
  instance_refresh_min_healthy = 50  # Instance Refresh Min Healthy
  instance_refresh_strategy = "Rolling"  # Instance Refresh Strategy
  instance_refresh_warmup = 300  # Instance Refresh Warmup
  instance_type = "t3.medium"  # EC2 instance type
  launch_template_version = "$Latest"  # Launch Template Version
  metadata_hop_limit = 1  # IMDS hop limit
  metadata_http_endpoint = "enabled"  # Metadata Http Endpoint
  metadata_http_tokens = "required"  # Metadata Http Tokens
  metadata_tags_enabled = "enabled"  # Metadata Tags Enabled
  propagate_tags_at_launch = true  # Propagate Tags At Launch
  root_volume_device = "/dev/xvda"  # Root Volume Device
  root_volume_encrypted = true  # Encrypt root volume
  root_volume_iops = 3000  # Root volume IOPS (io1/io2)
  root_volume_size = 50  # Root volume size (GB)
  root_volume_throughput = 125  # Root volume throughput (gp3)
  root_volume_type = "gp3"  # Root volume type (gp3/gp2/io1)
  scale_down_adjustment = -1  # Instances to remove on scale down
  scale_down_threshold = 30  # CPU threshold for scale down (%)
  scale_up_adjustment = 2  # Instances to add on scale up
  scale_up_threshold = 70  # CPU threshold for scale up (%)
  scaling_cooldown = 300  # Scaling Cooldown
  suspended_processes = []  # Suspended Processes
  termination_policies = ["Default"]  # Termination Policies
  use_latest_ami = true  # Use latest Amazon Linux 2023 AMI
}
