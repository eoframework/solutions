#------------------------------------------------------------------------------
# Network Configuration
# Generated from configuration.csv - DR values
#------------------------------------------------------------------------------

network = {
  vpc_cidr             = "10.102.0.0/16"
  public_subnet_cidrs  = ["10.102.1.0/24", "10.102.2.0/24", "10.102.3.0/24"]
  private_subnet_cidrs = ["10.102.10.0/24", "10.102.11.0/24", "10.102.12.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_flow_logs     = true
  flow_log_retention_days = 90
}
