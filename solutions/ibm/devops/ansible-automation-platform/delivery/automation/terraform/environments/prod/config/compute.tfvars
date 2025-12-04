#------------------------------------------------------------------------------
# Compute Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Number of controller nodes in HA cluster
  controller_count = 2
  controller_cpu = 8  # vCPU cores per controller node
  controller_instance_type = "m5.2xlarge"  # AWS instance type for controller nodes
  controller_memory_gb = 16  # Memory (GB) per controller node
  # Number of execution nodes for job processing
  execution_count = 4
  execution_cpu = 8  # vCPU cores per execution node
  execution_instance_type = "m5.2xlarge"  # AWS instance type for execution nodes
  execution_memory_gb = 16  # Memory (GB) per execution node
  hub_instance_type = "m5.xlarge"  # AWS instance type for hub node
}
