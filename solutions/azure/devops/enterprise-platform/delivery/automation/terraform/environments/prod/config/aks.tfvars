#------------------------------------------------------------------------------
# Aks Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:33
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aks = {
  autoscale_max = 10  # Maximum nodes for autoscaling
  autoscale_min = 3  # Minimum nodes for autoscaling
  kubernetes_version = "1.28"  # Kubernetes version
  node_count = 5  # Initial AKS node count
  node_size = "Standard_D4s_v3"  # AKS node VM size
}
