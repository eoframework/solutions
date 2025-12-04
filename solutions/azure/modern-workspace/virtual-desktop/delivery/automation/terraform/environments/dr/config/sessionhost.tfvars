#------------------------------------------------------------------------------
# Sessionhost Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

sessionhost = {
  accelerated_networking = true  # Enable accelerated networking
  image_offer = "Windows-11"  # VM image offer
  image_publisher = "MicrosoftWindowsDesktop"  # VM image publisher
  image_sku = "win11-22h2-avd"  # VM image SKU
  image_version = "latest"  # VM image version
  os_disk_size_gb = 128  # OS disk size in GB
  os_disk_type = "Premium_LRS"  # OS disk storage type
  vm_count = 2  # Number of session host VMs
  vm_size = "Standard_D4s_v5"  # Azure VM size for session hosts
}
