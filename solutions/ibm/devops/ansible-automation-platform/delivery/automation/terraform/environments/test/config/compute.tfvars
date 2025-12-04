#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Number of controller nodes in HA cluster
  controller_count = 1
  controller_cpu = 4  # vCPU cores per controller node
  controller_instance_type = "m5.xlarge"  # AWS instance type for controller nodes
  controller_memory_gb = 8  # Memory (GB) per controller node
  # Number of execution nodes for job processing
  execution_count = 2
  execution_cpu = 4  # vCPU cores per execution node
  execution_instance_type = "m5.xlarge"  # AWS instance type for execution nodes
  execution_memory_gb = 8  # Memory (GB) per execution node
  hub_instance_type = "m5.large"  # AWS instance type for hub node
}
