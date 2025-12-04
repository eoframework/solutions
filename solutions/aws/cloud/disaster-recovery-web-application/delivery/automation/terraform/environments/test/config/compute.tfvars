#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Custom AMI ID (empty uses latest AL2023)
  ami_id = ""
  app_port = 80  # Application port
  asg_desired_capacity = 1  # Desired ASG capacity
  asg_max_size = 4  # Maximum ASG capacity
  asg_min_size = 1  # Minimum ASG capacity
  enable_deletion_protection = false  # Enable ALB deletion protection
  health_check_path = "/health"  # Health check endpoint
  instance_type = "t3.small"  # EC2 instance type
  root_volume_size = 20  # Root EBS volume size in GB
  ssl_certificate_arn = ""  # ACM certificate ARN for HTTPS
}
