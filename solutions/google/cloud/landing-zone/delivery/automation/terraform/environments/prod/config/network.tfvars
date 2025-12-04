#------------------------------------------------------------------------------
# Network Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_flow_logs = true  # Enable VPC Flow Logs
  enable_private_google_access = true  # Enable Private Google Access
  flow_log_aggregation_interval = "INTERVAL_5_SEC"  # Flow log aggregation interval
  flow_log_sampling = "1.0"  # Flow log sampling rate
  subnet_dev_cidr = "10.0.1.0/24"  # Development subnet CIDR
  subnet_prod_cidr = "10.0.3.0/24"  # Production subnet CIDR
  subnet_shared_cidr = "10.0.10.0/24"  # Shared services subnet CIDR
  subnet_staging_cidr = "10.0.2.0/24"  # Staging subnet CIDR
  vpc_name = "shared-vpc-prod"  # Shared VPC network name
  vpc_routing_mode = "GLOBAL"  # VPC routing mode
}
