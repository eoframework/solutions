#------------------------------------------------------------------------------
# Compute Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

compute = {
  # EKS Cluster Configuration
  eks_cluster_name       = "mcp-test-cluster"
  eks_node_instance_type = "t3.large"
  eks_node_count         = 2
  eks_node_min_count     = 1
  eks_node_max_count     = 3

  # Vault Instance Configuration
  vault_instance_type    = "t3.small"
}
