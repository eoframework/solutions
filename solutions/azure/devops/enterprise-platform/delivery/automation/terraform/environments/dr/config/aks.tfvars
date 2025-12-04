#------------------------------------------------------------------------------
# Aks Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:38
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aks = {
  autoscale_max = 5  # Maximum nodes for autoscaling
  autoscale_min = 2  # Minimum nodes for autoscaling
  kubernetes_version = "1.28"  # Kubernetes version
  node_count = 3  # Initial AKS node count
  node_size = "Standard_D4s_v3"  # AKS node VM size
}
