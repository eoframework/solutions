#------------------------------------------------------------------------------
# Network Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

network = {
  vpc_cidr             = "10.101.0.0/16"
  public_subnet_cidrs  = ["10.101.1.0/24", "10.101.2.0/24"]
  private_subnet_cidrs = ["10.101.10.0/24", "10.101.11.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_flow_logs     = false
  flow_log_retention_days = 30
}
