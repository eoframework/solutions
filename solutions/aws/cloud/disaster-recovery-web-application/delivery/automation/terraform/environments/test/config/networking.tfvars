#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  database_subnet_cidrs = ["10.100.20.0/24", "10.100.21.0/24"]  # Database subnet CIDRs
  enable_flow_logs = false  # Enable VPC Flow Logs
  enable_nat_gateway = true  # Enable NAT Gateway for private subnets
  private_subnet_cidrs = ["10.100.10.0/24", "10.100.11.0/24"]  # Private subnet CIDRs
  public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]  # Public subnet CIDRs
  vpc_cidr = "10.100.0.0/16"  # VPC CIDR block
}
