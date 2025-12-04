#------------------------------------------------------------------------------
# AVD Module
# Creates: Host Pool, Application Groups, Workspace, Session Hosts, Scaling Plan
# Uses: modules/azure/avd-host-pool, modules/azure/avd-workspace, modules/azure/avd-application-group
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# AVD Host Pool (via Azure module)
#------------------------------------------------------------------------------
module "host_pool" {
  source = "../../azure/avd-host-pool"

  name                             = "${var.name_prefix}-hostpool"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  host_pool_type                   = var.avd.host_pool_type
  load_balancer_type               = var.avd.host_pool_load_balancer
  maximum_sessions_allowed         = var.avd.max_session_limit
  start_vm_on_connect              = var.avd.start_vm_on_connect
  personal_desktop_assignment_type = var.avd.personal_desktop_assignment
  validate_environment             = var.avd.validate_environment
  friendly_name                    = "${var.name_prefix} Host Pool"
  description                      = "Managed by Terraform"
  registration_token_rotation_days = 27

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# AVD Workspace (via Azure module)
#------------------------------------------------------------------------------
module "workspace" {
  source = "../../azure/avd-workspace"

  name                = "${var.name_prefix}-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "${var.name_prefix} Workspace"
  description         = "Managed by Terraform"

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Desktop Application Group (via Azure module)
#------------------------------------------------------------------------------
module "desktop_app_group" {
  count  = var.app_groups.desktop_enabled ? 1 : 0
  source = "../../azure/avd-application-group"

  name                = "${var.name_prefix}-desktop-appgroup"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = module.host_pool.id
  workspace_id        = module.workspace.id
  friendly_name       = var.app_groups.desktop_friendly_name
  description         = "Desktop Application Group"

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# RemoteApp Application Group (via Azure module)
#------------------------------------------------------------------------------
module "remoteapp_app_group" {
  count  = var.app_groups.remoteapp_enabled ? 1 : 0
  source = "../../azure/avd-application-group"

  name                = "${var.name_prefix}-remoteapp-appgroup"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "RemoteApp"
  host_pool_id        = module.host_pool.id
  workspace_id        = module.workspace.id
  friendly_name       = "RemoteApp Applications"
  description         = "RemoteApp Application Group"

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Store Registration Token in Key Vault
#------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "registration_token" {
  name         = "avd-hostpool-registration-token"
  value        = module.host_pool.registration_token
  key_vault_id = var.key_vault_id

  expiration_date = module.host_pool.registration_expiration
}

#------------------------------------------------------------------------------
# Network Interface for Session Hosts
#------------------------------------------------------------------------------
resource "azurerm_network_interface" "session_host" {
  count               = var.session_hosts.vm_count
  name                = "${var.name_prefix}-sessionhost-${count.index + 1}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  enable_accelerated_networking = var.session_hosts.enable_accelerated_networking

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Session Host Virtual Machines
#------------------------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "session_host" {
  count               = var.session_hosts.vm_count
  name                = "${var.name_prefix}-sh-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.session_hosts.vm_size
  admin_username      = "avdadmin"
  admin_password      = random_password.vm_admin_password.result

  network_interface_ids = [
    azurerm_network_interface.session_host[count.index].id
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  os_disk {
    name                 = "${var.name_prefix}-sh-${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.session_hosts.os_disk_type
    disk_size_gb         = var.session_hosts.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.session_hosts.vm_image_publisher
    offer     = var.session_hosts.vm_image_offer
    sku       = var.session_hosts.vm_image_sku
    version   = var.session_hosts.vm_image_version
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Random Password for VM Admin
#------------------------------------------------------------------------------
resource "random_password" "vm_admin_password" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "avd-sessionhost-admin-password"
  value        = random_password.vm_admin_password.result
  key_vault_id = var.key_vault_id
}

#------------------------------------------------------------------------------
# AAD Join Extension
#------------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "aad_join" {
  count                      = var.session_hosts.vm_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

#------------------------------------------------------------------------------
# AVD Agent Extension
#------------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "avd_agent" {
  count                      = var.session_hosts.vm_count
  name                       = "AVDAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-Item -Path HKLM:\\SOFTWARE\\Microsoft\\RDInfraAgent\\Parameters -Force; New-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\RDInfraAgent\\Parameters -Name RegistrationToken -Value '${module.host_pool.registration_token}' -PropertyType String -Force; New-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\RDInfraAgent\\Parameters -Name HostPoolName -Value '${module.host_pool.name}' -PropertyType String -Force; Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv' -OutFile 'C:\\AVDAgent.msi'; Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\\AVDAgent.msi /quiet /qn /norestart REGISTRATIONTOKEN=${module.host_pool.registration_token}' -Wait\""
  })

  depends_on = [
    azurerm_virtual_machine_extension.aad_join
  ]
}

#------------------------------------------------------------------------------
# FSLogix Configuration Extension
#------------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "fslogix" {
  count                      = var.session_hosts.vm_count
  name                       = "FSLogixConfig"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Unrestricted -Command \"New-Item -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Force; New-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'Enabled' -Value 1 -PropertyType DWord -Force; New-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'VHDLocations' -Value '\\\\${var.storage_account_name}.file.core.windows.net\\${var.storage_share_name}' -PropertyType String -Force; New-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'SizeInMBs' -Value 30000 -PropertyType DWord -Force; New-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'IsDynamic' -Value 1 -PropertyType DWord -Force; New-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'VolumeType' -Value 'VHDX' -PropertyType String -Force\""
  })

  depends_on = [
    azurerm_virtual_machine_extension.avd_agent
  ]
}

#------------------------------------------------------------------------------
# Scaling Plan (Auto-scaling)
#------------------------------------------------------------------------------
resource "azurerm_virtual_desktop_scaling_plan" "main" {
  count               = var.autoscale.enabled ? 1 : 0
  name                = "${var.name_prefix}-scaling-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "Auto-scaling Plan"
  description         = "Managed by Terraform"
  time_zone           = var.autoscale.timezone

  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = var.autoscale.ramp_up_start_time
    ramp_up_load_balancing_algorithm     = "DepthFirst"
    ramp_up_minimum_hosts_percent        = var.autoscale.ramp_up_capacity_threshold
    ramp_up_capacity_threshold_percent   = var.autoscale.ramp_up_capacity_threshold
    peak_start_time                      = var.autoscale.peak_start_time
    peak_load_balancing_algorithm        = var.avd.host_pool_load_balancer
    ramp_down_start_time                 = var.autoscale.ramp_down_start_time
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = var.autoscale.ramp_down_capacity_threshold
    ramp_down_capacity_threshold_percent = var.autoscale.ramp_down_capacity_threshold
    ramp_down_force_logoff_users         = false
    ramp_down_stop_hosts_when            = "ZeroSessions"
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "You will be logged off in 30 minutes. Please save your work."
    off_peak_start_time                  = var.autoscale.off_peak_start_time
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  host_pool {
    hostpool_id          = module.host_pool.id
    scaling_plan_enabled = true
  }

  tags = var.common_tags
}
