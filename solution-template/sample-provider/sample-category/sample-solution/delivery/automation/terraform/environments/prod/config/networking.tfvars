#------------------------------------------------------------------------------
# Networking Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# Network infrastructure settings including VPC, subnets, NAT gateways, and DNS.
# These values are typically derived from the delivery configuration.csv
# under the "Networking" or "Network" sections.
#------------------------------------------------------------------------------

network = {
  #----------------------------------------------------------------------------
  # VPC Configuration
  #----------------------------------------------------------------------------
  vpc_cidr = "10.0.0.0/16"

  # Subnet CIDR blocks (one per availability zone for HA)
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnet_cidrs = ["10.0.100.0/24", "10.0.110.0/24", "10.0.120.0/24"]

  #----------------------------------------------------------------------------
  # DNS Configuration
  #----------------------------------------------------------------------------
  enable_dns_hostnames = true
  enable_dns_support   = true

  #----------------------------------------------------------------------------
  # NAT Gateway Configuration
  #----------------------------------------------------------------------------
  enable_nat_gateway = true
  single_nat_gateway = false      # Production: HA NAT (one per AZ)

  #----------------------------------------------------------------------------
  # Public Subnet Settings
  #----------------------------------------------------------------------------
  map_public_ip_on_launch = true  # Auto-assign public IPs in public subnets

  #----------------------------------------------------------------------------
  # VPC Flow Logs (for security auditing)
  #----------------------------------------------------------------------------
  enable_flow_logs             = true
  flow_log_retention_days      = 90       # Production: 90 days retention
  flow_log_traffic_type        = "ALL"    # ALL, ACCEPT, or REJECT
  flow_log_destination_type    = "cloud-watch-logs"  # cloud-watch-logs or s3
  flow_log_aggregation_interval = 60      # 60 or 600 seconds

  #----------------------------------------------------------------------------
  # Standard Ports
  #----------------------------------------------------------------------------
  https_port = 443
  http_port  = 80
  ssh_port   = 22
}

alb = {
  #----------------------------------------------------------------------------
  # Application Load Balancer - Basic Configuration
  #----------------------------------------------------------------------------
  enabled                    = true
  internal                   = false    # Internet-facing
  enable_deletion_protection = true     # Production: enabled

  #----------------------------------------------------------------------------
  # TLS/SSL Configuration
  #----------------------------------------------------------------------------
  # acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # TLS 1.3 preferred

  #----------------------------------------------------------------------------
  # ALB Behavior Settings
  #----------------------------------------------------------------------------
  idle_timeout_seconds       = 60       # Connection idle timeout
  deregistration_delay       = 300      # Target deregistration delay
  drop_invalid_header_fields = true     # Security: drop invalid headers

  #----------------------------------------------------------------------------
  # HTTP to HTTPS Redirect
  #----------------------------------------------------------------------------
  redirect_http_to_https = true
  redirect_status_code   = "HTTP_301"   # HTTP_301 (permanent) or HTTP_302 (temporary)

  #----------------------------------------------------------------------------
  # Health Check Configuration
  #----------------------------------------------------------------------------
  health_check_path     = "/health"
  health_check_interval = 30            # seconds
  health_check_timeout  = 5             # seconds
  healthy_threshold     = 2             # consecutive checks
  unhealthy_threshold   = 3             # consecutive checks
  health_check_matcher  = "200-299"     # HTTP status codes for healthy
}
