#------------------------------------------------------------------------------
# Networking Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:08
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_flow_logs = true  # Enable VPC Flow Logs
  enable_nat_gateway = true  # Enable NAT Gateway for private subnets
  flow_log_retention_days = 90  # Flow log retention period in days
  private_subnet_cidrs = ["10.52.10.0/24", "10.52.11.0/24", "10.52.12.0/24"]  # Private subnet CIDR blocks
  public_subnet_cidrs = ["10.52.1.0/24", "10.52.2.0/24", "10.52.3.0/24"]  # Public subnet CIDR blocks
  # Use single NAT (cost) vs HA NAT (reliability)
  single_nat_gateway = false
  vpc_cidr = "10.52.0.0/16"  # VPC CIDR block for platform
}
