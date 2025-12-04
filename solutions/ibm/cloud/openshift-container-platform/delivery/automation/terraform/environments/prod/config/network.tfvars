#------------------------------------------------------------------------------
# Network Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  cluster_mtu = 1400  # Maximum transmission unit for cluster
  pod_cidr = "10.128.0.0/14"  # CIDR block for pod networking
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]  # Private subnet CIDRs
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Public subnet CIDRs
  service_cidr = "172.30.0.0/16"  # CIDR block for service networking
  type = "OVNKubernetes"  # OpenShift network plugin type
  vpc_cidr = "10.0.0.0/16"  # VPC CIDR block for cluster
}
