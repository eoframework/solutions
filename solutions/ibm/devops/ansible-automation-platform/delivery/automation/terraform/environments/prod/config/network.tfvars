#------------------------------------------------------------------------------
# Network Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  availability_zones = ["us-east-1a", "us-east-1b"]  # Availability zones
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]  # Private subnet CIDRs
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]  # Public subnet CIDRs
  vpc_cidr = "10.0.0.0/16"  # VPC CIDR block
}
