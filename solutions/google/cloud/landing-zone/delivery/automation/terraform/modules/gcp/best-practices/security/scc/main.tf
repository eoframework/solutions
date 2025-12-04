#------------------------------------------------------------------------------
# GCP Security Command Center Module
#------------------------------------------------------------------------------
# Creates SCC custom modules and configurations
# Well-Architected Framework: Security
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# SCC Custom Module - Critical Findings
#------------------------------------------------------------------------------
resource "google_scc_organization_custom_module" "critical_findings" {
  count = var.scc.tier == "Premium" ? 1 : 0

  organization     = var.org_id
  display_name     = "${var.name_prefix}-critical-findings"
  enablement_state = "ENABLED"

  custom_config {
    predicate {
      expression = "resource.type == \"compute.googleapis.com/Instance\" && resource.state == \"RUNNING\""
    }
    resource_selector {
      resource_types = ["compute.googleapis.com/Instance"]
    }
    severity       = "CRITICAL"
    description    = "Custom module for critical security findings on running instances"
    recommendation = "Review and remediate critical security findings immediately"
  }
}

#------------------------------------------------------------------------------
# SCC Custom Module - Public Resources
#------------------------------------------------------------------------------
resource "google_scc_organization_custom_module" "public_resources" {
  count = var.scc.tier == "Premium" && var.scc.enable_public_resource_detection ? 1 : 0

  organization     = var.org_id
  display_name     = "${var.name_prefix}-public-resources"
  enablement_state = "ENABLED"

  custom_config {
    predicate {
      expression = "resource.type == \"storage.googleapis.com/Bucket\" && resource.data.iamConfiguration.publicAccessPrevention != \"enforced\""
    }
    resource_selector {
      resource_types = ["storage.googleapis.com/Bucket"]
    }
    severity       = "HIGH"
    description    = "Detects storage buckets without public access prevention"
    recommendation = "Enable public access prevention on all storage buckets"
  }
}

#------------------------------------------------------------------------------
# SCC Notification Config (for SIEM integration)
#------------------------------------------------------------------------------
resource "google_scc_notification_config" "findings" {
  count = var.scc.tier == "Premium" && var.scc.enable_notifications ? 1 : 0

  config_id    = "${var.name_prefix}-findings"
  organization = var.org_id
  description  = "Notification config for security findings"
  pubsub_topic = var.pubsub_topic_id

  streaming_config {
    filter = "severity = \"CRITICAL\" OR severity = \"HIGH\""
  }
}
