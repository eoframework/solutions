#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------

vpc_cidr = "10.1.0.0/16"

public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.10.0/24", "10.1.20.0/24"]
database_subnet_cidrs = ["10.1.100.0/24", "10.1.110.0/24"]

enable_dns_hostnames = true
enable_dns_support   = true

enable_nat_gateway = true
single_nat_gateway = true             # Test: single NAT for cost savings

enable_flow_logs        = false       # Test: disabled
flow_log_retention_days = 7
