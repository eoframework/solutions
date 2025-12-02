#------------------------------------------------------------------------------
# Networking Configuration - VPC, Subnets, ALB - DR Environment
#------------------------------------------------------------------------------
# Same topology as production for failover compatibility.
# Uses different CIDRs for VPC peering compatibility.
#------------------------------------------------------------------------------

alb = {
  deregistration_delay       = 300
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  enabled                    = true
  health_check_interval      = 30
  health_check_matcher       = "200-299"
  health_check_path          = "/health"
  health_check_timeout       = 5
  healthy_threshold          = 2
  idle_timeout_seconds       = 60
  internal                   = false
  redirect_http_to_https     = true
  redirect_status_code       = "HTTP_301"
  ssl_policy                 = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  unhealthy_threshold        = 3
}

network = {
  database_subnet_cidrs         = ["10.1.100.0/24", "10.1.110.0/24", "10.1.120.0/24"]
  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_flow_logs              = true
  enable_nat_gateway            = true
  flow_log_aggregation_interval = 60
  flow_log_destination_type     = "cloud-watch-logs"
  flow_log_retention_days       = 90
  flow_log_traffic_type         = "ALL"
  http_port                     = 80
  https_port                    = 443
  map_public_ip_on_launch       = true
  private_subnet_cidrs          = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
  public_subnet_cidrs           = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  single_nat_gateway            = false
  ssh_port                      = 22
  vpc_cidr                      = "10.1.0.0/16"  # Different CIDR for VPC peering
}
