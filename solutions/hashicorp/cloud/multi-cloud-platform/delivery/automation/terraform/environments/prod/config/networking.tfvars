#------------------------------------------------------------------------------
# Network Configuration
# Generated from configuration.csv - Production values
#------------------------------------------------------------------------------

network = {
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  private_subnet_cidrs = ["10.100.10.0/24", "10.100.11.0/24", "10.100.12.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_flow_logs     = true
  flow_log_retention_days = 90
}
