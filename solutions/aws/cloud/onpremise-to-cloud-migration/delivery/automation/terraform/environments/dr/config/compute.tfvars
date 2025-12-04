#------------------------------------------------------------------------------
# Compute Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Custom AMI ID (empty uses latest AL2023)
  ami_id = ""
  app_port = 443  # Application port
  asg_desired_capacity = 1  # Desired ASG capacity
  asg_max_size = 20  # Maximum ASG capacity
  asg_min_size = 0  # Minimum ASG capacity
  data_volume_size = 100  # Data EBS volume size in GB
  enable_deletion_protection = true  # Enable ALB deletion protection
  health_check_path = "/health"  # Health check endpoint
  instance_type = "m5.large"  # Default EC2 instance type
  root_volume_size = 50  # Root EBS volume size in GB
  ssl_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT-ID"  # ACM certificate ARN for HTTPS
}
