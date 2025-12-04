#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  database_subnet_cidrs = ["10.100.20.0/24", "10.100.21.0/24"]  # Database subnet CIDRs
  direct_connect_bandwidth = ""  # Direct Connect bandwidth
  enable_direct_connect = false  # Enable Direct Connect
  enable_flow_logs = false  # Enable VPC Flow Logs
  enable_nat_gateway = true  # Enable NAT Gateway for private subnets
  enable_site_to_site_vpn = true  # Enable Site-to-Site VPN (backup)
  on_prem_cidr = "192.168.0.0/16"  # On-premises CIDR block
  private_subnet_cidrs = ["10.100.10.0/24", "10.100.11.0/24"]  # Private subnet CIDRs
  public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]  # Public subnet CIDRs
  transit_gateway_enabled = false  # Enable Transit Gateway
  vpc_cidr = "10.100.0.0/16"  # VPC CIDR block
}
