#------------------------------------------------------------------------------
# Compute Configuration
# Generated from configuration.csv - DR values
#------------------------------------------------------------------------------

compute = {
  # EKS Cluster Configuration
  eks_cluster_name       = "mcp-dr-cluster"
  eks_node_instance_type = "t3.xlarge"
  eks_node_count         = 3
  eks_node_min_count     = 2
  eks_node_max_count     = 6

  # Vault Instance Configuration
  vault_instance_type    = "t3.medium"
}
