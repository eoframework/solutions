#------------------------------------------------------------------------------
# GCP Organization Module Outputs
#------------------------------------------------------------------------------

output "org_id" {
  description = "Organization ID"
  value       = var.org_id
}

output "domain" {
  description = "Organization domain"
  value       = var.domain
}

output "billing_account_id" {
  description = "Billing account ID"
  value       = var.billing_account_id
}

output "policies_applied" {
  description = "List of organization policies applied"
  value = compact([
    var.require_shielded_vm ? "compute.requireShieldedVm" : "",
    var.disable_serial_port_access ? "compute.disableSerialPortAccess" : "",
    var.disable_sa_key_creation ? "iam.disableServiceAccountKeyCreation" : "",
    var.disable_vm_external_ip ? "compute.vmExternalIpAccess" : "",
    length(var.allowed_locations) > 0 ? "gcp.resourceLocations" : "",
    "storage.uniformBucketLevelAccess",
    var.require_os_login ? "compute.requireOsLogin" : "",
  ])
}
