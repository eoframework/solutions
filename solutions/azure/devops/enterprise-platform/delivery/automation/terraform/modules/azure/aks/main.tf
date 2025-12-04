#------------------------------------------------------------------------------
# Azure Kubernetes Service Module
#------------------------------------------------------------------------------
# Creates:
# - AKS Cluster
# - Node Pools
# - Azure AD Integration
# - Network Profile
# - Monitoring Integration
#------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  sku_tier                      = var.sku_tier
  automatic_channel_upgrade     = var.automatic_channel_upgrade
  node_resource_group           = var.node_resource_group
  private_cluster_enabled       = var.private_cluster_enabled
  private_dns_zone_id           = var.private_dns_zone_id
  workload_identity_enabled     = var.workload_identity_enabled
  oidc_issuer_enabled           = var.oidc_issuer_enabled
  azure_policy_enabled          = var.azure_policy_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  # Default Node Pool
  default_node_pool {
    name                   = var.default_node_pool.name
    vm_size                = var.default_node_pool.vm_size
    node_count             = lookup(var.default_node_pool, "node_count", null)
    enable_auto_scaling    = lookup(var.default_node_pool, "enable_auto_scaling", false)
    min_count              = lookup(var.default_node_pool, "min_count", null)
    max_count              = lookup(var.default_node_pool, "max_count", null)
    max_pods               = lookup(var.default_node_pool, "max_pods", null)
    os_disk_size_gb        = lookup(var.default_node_pool, "os_disk_size_gb", null)
    os_disk_type           = lookup(var.default_node_pool, "os_disk_type", "Managed")
    vnet_subnet_id         = var.default_node_pool.vnet_subnet_id
    zones                  = lookup(var.default_node_pool, "zones", null)
    enable_node_public_ip  = lookup(var.default_node_pool, "enable_node_public_ip", false)
    node_labels            = lookup(var.default_node_pool, "node_labels", {})
    node_taints            = lookup(var.default_node_pool, "node_taints", [])
    only_critical_addons_enabled = lookup(var.default_node_pool, "only_critical_addons_enabled", false)

    upgrade_settings {
      max_surge = lookup(var.default_node_pool, "max_surge", "10%")
    }
  }

  # Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
  }

  # Network Profile
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    load_balancer_sku  = var.load_balancer_sku
    outbound_type      = var.outbound_type

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile != null ? [var.load_balancer_profile] : []
      content {
        managed_outbound_ip_count   = lookup(load_balancer_profile.value, "managed_outbound_ip_count", null)
        outbound_ip_address_ids     = lookup(load_balancer_profile.value, "outbound_ip_address_ids", null)
        outbound_ip_prefix_ids      = lookup(load_balancer_profile.value, "outbound_ip_prefix_ids", null)
        outbound_ports_allocated    = lookup(load_balancer_profile.value, "outbound_ports_allocated", null)
        idle_timeout_in_minutes     = lookup(load_balancer_profile.value, "idle_timeout_in_minutes", null)
      }
    }
  }

  # Azure AD Integration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_ad_rbac_enabled ? [1] : []
    content {
      managed                = var.azure_ad_rbac_managed
      tenant_id              = var.azure_ad_tenant_id
      admin_group_object_ids = var.azure_ad_admin_group_object_ids
      azure_rbac_enabled     = var.azure_rbac_enabled
    }
  }

  # OMS Agent (Azure Monitor)
  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Key Vault Secrets Provider
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []
    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  # Maintenance Window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = lookup(maintenance_window.value, "not_allowed", [])
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  # Auto Scaler Profile
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = lookup(auto_scaler_profile.value, "balance_similar_node_groups", false)
      expander                         = lookup(auto_scaler_profile.value, "expander", "random")
      max_graceful_termination_sec     = lookup(auto_scaler_profile.value, "max_graceful_termination_sec", 600)
      max_node_provisioning_time       = lookup(auto_scaler_profile.value, "max_node_provisioning_time", "15m")
      max_unready_nodes                = lookup(auto_scaler_profile.value, "max_unready_nodes", 3)
      max_unready_percentage           = lookup(auto_scaler_profile.value, "max_unready_percentage", 45)
      new_pod_scale_up_delay           = lookup(auto_scaler_profile.value, "new_pod_scale_up_delay", "10s")
      scale_down_delay_after_add       = lookup(auto_scaler_profile.value, "scale_down_delay_after_add", "10m")
      scale_down_delay_after_delete    = lookup(auto_scaler_profile.value, "scale_down_delay_after_delete", "10s")
      scale_down_delay_after_failure   = lookup(auto_scaler_profile.value, "scale_down_delay_after_failure", "3m")
      scan_interval                    = lookup(auto_scaler_profile.value, "scan_interval", "10s")
      scale_down_unneeded              = lookup(auto_scaler_profile.value, "scale_down_unneeded", "10m")
      scale_down_unready               = lookup(auto_scaler_profile.value, "scale_down_unready", "20m")
      scale_down_utilization_threshold = lookup(auto_scaler_profile.value, "scale_down_utilization_threshold", 0.5)
      empty_bulk_delete_max            = lookup(auto_scaler_profile.value, "empty_bulk_delete_max", 10)
      skip_nodes_with_local_storage    = lookup(auto_scaler_profile.value, "skip_nodes_with_local_storage", true)
      skip_nodes_with_system_pods      = lookup(auto_scaler_profile.value, "skip_nodes_with_system_pods", true)
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Additional Node Pools
#------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = lookup(each.value, "node_count", null)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", false)
  min_count             = lookup(each.value, "min_count", null)
  max_count             = lookup(each.value, "max_count", null)
  max_pods              = lookup(each.value, "max_pods", null)
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", null)
  os_disk_type          = lookup(each.value, "os_disk_type", "Managed")
  os_type               = lookup(each.value, "os_type", "Linux")
  vnet_subnet_id        = lookup(each.value, "vnet_subnet_id", null)
  zones                 = lookup(each.value, "zones", null)
  enable_node_public_ip = lookup(each.value, "enable_node_public_ip", false)
  node_labels           = lookup(each.value, "node_labels", {})
  node_taints           = lookup(each.value, "node_taints", [])
  priority              = lookup(each.value, "priority", "Regular")
  eviction_policy       = lookup(each.value, "eviction_policy", null)
  spot_max_price        = lookup(each.value, "spot_max_price", null)
  mode                  = lookup(each.value, "mode", "User")

  upgrade_settings {
    max_surge = lookup(each.value, "max_surge", "10%")
  }

  tags = var.common_tags
}
