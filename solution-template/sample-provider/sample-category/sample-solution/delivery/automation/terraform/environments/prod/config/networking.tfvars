#------------------------------------------------------------------------------
# Networking Configuration - VPC, Subnets, ALB - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

alb = {
  deregistration_delay = 300  # Target deregistration delay (seconds)
  drop_invalid_header_fields = true  # Drop invalid HTTP headers
  enable_deletion_protection = true  # Enable deletion protection
  enabled = true  # Enable this resource
  health_check_interval = 30  # Health check interval (seconds)
  health_check_matcher = "200-299"  # HTTP status codes for healthy response
  health_check_path = "/health"  # Health check endpoint path
  health_check_timeout = 5  # Health check timeout (seconds)
  healthy_threshold = 2  # Consecutive healthy checks required
  idle_timeout_seconds = 60  # Connection idle timeout (seconds)
  # Internal load balancer (not internet-facing)
  internal = false
  redirect_http_to_https = true  # Redirect HTTP to HTTPS
  redirect_status_code = "HTTP_301"  # HTTP redirect status code
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # SSL/TLS security policy
  unhealthy_threshold = 3  # Consecutive unhealthy checks required
}

network = {
  database_subnet_cidrs = ["10.0.100.0/24", "10.0.110.0/24", "10.0.120.0/24"]  # Database subnet CIDR blocks
  enable_dns_hostnames = true  # Enable DNS hostnames in VPC
  enable_dns_support = true  # Enable DNS support in VPC
  enable_flow_logs = true  # Enable VPC Flow Logs
  enable_nat_gateway = true  # Enable NAT Gateway for private subnets
  flow_log_aggregation_interval = 60  # Flow log aggregation interval (seconds)
  # Flow log destination (cloud-watch-logs/s3)
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_retention_days = 90  # Flow log retention period in days
  # Flow log traffic type (ALL/ACCEPT/REJECT)
  flow_log_traffic_type = "ALL"
  http_port = 80  # HTTP port number
  https_port = 443  # HTTPS port number
  # Auto-assign public IPs in public subnets
  map_public_ip_on_launch = true
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]  # Private subnet CIDR blocks
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Public subnet CIDR blocks
  # Use single NAT (cost) vs HA NAT (reliability)
  single_nat_gateway = false
  ssh_port = 22  # SSH port number
  vpc_cidr = "10.0.0.0/16"  # VPC CIDR block
}
