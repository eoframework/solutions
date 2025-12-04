#------------------------------------------------------------------------------
# Network Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  availability_zones = ["us-east-1a"]  # Availability zones
  private_subnets = ["10.1.11.0/24"]  # Private subnet CIDRs
  public_subnets = ["10.1.1.0/24"]  # Public subnet CIDRs
  vpc_cidr = "10.1.0.0/16"  # VPC CIDR block
}
