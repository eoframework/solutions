#------------------------------------------------------------------------------
# Platform Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

platform = {
  # Automation Controller web UI and API URL
  controller_url = "https://aap-test.example.com"
  eda_enabled = false  # Enable Event-Driven Ansible
  hub_url = "https://hub-test.example.com"  # Private Automation Hub URL
  version = "2.4"  # Ansible Automation Platform version
}
