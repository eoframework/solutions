#------------------------------------------------------------------------------
# Networking Configuration
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
  # VPC Flow Logs (for security auditing)
  #----------------------------------------------------------------------------
  enable_flow_logs        = true
  flow_log_retention_days = 90    # Production: 90 days retention
}
