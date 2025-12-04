#------------------------------------------------------------------------------
# Integration Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  monitoring_webhook_url = "https://monitoring.example.com/webhook"  # Monitoring webhook endpoint
  servicenow_enabled = true  # Enable ServiceNow integration
  servicenow_instance = "company.service-now.com"  # ServiceNow instance hostname
  servicenow_username = "aap_integration"  # ServiceNow integration user
}
