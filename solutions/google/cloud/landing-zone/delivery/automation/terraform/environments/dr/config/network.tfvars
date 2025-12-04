#------------------------------------------------------------------------------
# Network Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_flow_logs = true  # Enable VPC Flow Logs
  enable_private_google_access = true  # Enable Private Google Access
  flow_log_aggregation_interval = "INTERVAL_5_SEC"  # Flow log aggregation interval
  flow_log_sampling = "1.0"  # Flow log sampling rate
  subnet_dev_cidr = "10.1.1.0/24"  # Development subnet CIDR
  subnet_prod_cidr = "10.1.3.0/24"  # Production subnet CIDR
  subnet_shared_cidr = "10.1.10.0/24"  # Shared services subnet CIDR
  subnet_staging_cidr = "10.1.2.0/24"  # Staging subnet CIDR
  vpc_name = "shared-vpc-dr"  # Shared VPC network name
  vpc_routing_mode = "GLOBAL"  # VPC routing mode
}
