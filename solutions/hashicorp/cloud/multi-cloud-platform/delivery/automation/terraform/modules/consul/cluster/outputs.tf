#------------------------------------------------------------------------------
# Consul Cluster Module Outputs
#------------------------------------------------------------------------------

output "consul_release_name" {
  description = "Consul Helm release name"
  value       = helm_release.consul.name
}

output "consul_namespace" {
  description = "Consul namespace"
  value       = var.consul.namespace
}

output "consul_ui_service" {
  description = "Consul UI service name"
  value       = "${var.name_prefix}-consul-ui"
}

output "consul_server_service" {
  description = "Consul server service name"
  value       = "${var.name_prefix}-consul-server"
}
