#------------------------------------------------------------------------------
# Platform Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

platform = {
  # Automation Controller web UI and API URL
  controller_url = "https://aap-dr.example.com"
  eda_enabled = true  # Enable Event-Driven Ansible
  hub_url = "https://hub.example.com"  # Private Automation Hub URL
  version = "2.4"  # Ansible Automation Platform version
}
