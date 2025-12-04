#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  control_plane_count = 3  # Number of control plane (master) nodes
  control_plane_cpu = 4  # vCPU cores per control plane node
  control_plane_instance_type = "m5.xlarge"  # AWS instance type for control plane
  control_plane_memory_gb = 16  # Memory (GB) per control plane node
  rhcos_ami = "ami-0123456789abcdef0"  # Red Hat CoreOS AMI ID
  worker_count = 2  # Number of worker nodes for workloads
  worker_cpu = 8  # vCPU cores per worker node
  worker_instance_type = "m5.2xlarge"  # AWS instance type for worker nodes
  worker_memory_gb = 32  # Memory (GB) per worker node
}
