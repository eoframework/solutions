#------------------------------------------------------------------------------
# Networking Configuration - DR Environment
#------------------------------------------------------------------------------
# DR network settings. Topology should mirror production for seamless failover.
# Use non-overlapping CIDRs if VPC peering is required.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VPC Configuration (Mirror Production Topology)
#------------------------------------------------------------------------------

vpc_cidr = "10.1.0.0/16"              # DR: Different CIDR for peering compatibility

# Subnet CIDR blocks (one per availability zone for HA)
public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs  = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
database_subnet_cidrs = ["10.1.100.0/24", "10.1.110.0/24", "10.1.120.0/24"]

#------------------------------------------------------------------------------
# DNS Configuration
#------------------------------------------------------------------------------

enable_dns_hostnames = true
enable_dns_support   = true

#------------------------------------------------------------------------------
# NAT Gateway Configuration
#------------------------------------------------------------------------------

enable_nat_gateway = true
single_nat_gateway = false            # DR: HA NAT for failover readiness

#------------------------------------------------------------------------------
# VPC Flow Logs (for security auditing)
#------------------------------------------------------------------------------

enable_flow_logs        = true
flow_log_retention_days = 90          # DR: Match production retention
