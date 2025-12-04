#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alertmanager_target = "pagerduty"  # Alertmanager notification target
  grafana_enabled = true  # Enable Grafana dashboards
  prometheus_enabled = true  # Enable Prometheus monitoring
  prometheus_retention_days = 15  # Prometheus metrics retention in days
}
