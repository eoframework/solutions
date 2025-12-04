#------------------------------------------------------------------------------
# Network Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  availability_zones = ["us-west-2a", "us-west-2b"]  # Availability zones
  private_subnets = ["10.2.11.0/24", "10.2.12.0/24"]  # Private subnet CIDRs
  public_subnets = ["10.2.1.0/24", "10.2.2.0/24"]  # Public subnet CIDRs
  vpc_cidr = "10.2.0.0/16"  # VPC CIDR block
}
