#------------------------------------------------------------------------------
# Compute Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:08
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  eks_cluster_name = "tfe-dr-cluster"  # EKS cluster name for TFE
  eks_node_count = 3  # Number of EKS worker nodes
  eks_node_instance_type = "t3.large"  # EKS worker node instance type
  # Maximum EKS worker nodes for autoscaling
  eks_node_max_count = 6
  # Minimum EKS worker nodes for autoscaling
  eks_node_min_count = 2
}
