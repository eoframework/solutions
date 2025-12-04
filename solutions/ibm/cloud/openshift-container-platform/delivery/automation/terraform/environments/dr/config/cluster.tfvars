#------------------------------------------------------------------------------
# Cluster Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cluster = {
  api_endpoint = "https://api.ocp-dr.example.com:6443"  # OpenShift API server endpoint URL
  base_domain = "example.com"  # Base domain for cluster DNS and routing
  console_url = "https://console-openshift-console.apps.ocp-dr.example.com"  # OpenShift web console URL
  install_type = "ipi"  # Installation type (IPI or UPI)
  name = "ocp-dr"  # OpenShift cluster identifier
  platform = "aws"  # Target platform for cluster deployment
  # Red Hat OpenShift Container Platform version
  version = "4.14.10"
}
