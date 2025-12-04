#------------------------------------------------------------------------------
# Azure Kubernetes Service Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Kubernetes admin configuration"
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive   = true
}

output "identity_principal_id" {
  description = "Identity principal ID"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Identity tenant ID"
  value       = azurerm_kubernetes_cluster.this.identity[0].tenant_id
}

output "kubelet_identity" {
  description = "Kubelet identity"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = var.oidc_issuer_enabled ? azurerm_kubernetes_cluster.this.oidc_issuer_url : null
}

output "node_resource_group" {
  description = "Node resource group"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "node_pool_ids" {
  description = "Map of node pool names to IDs"
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.this : k => v.id }
}
