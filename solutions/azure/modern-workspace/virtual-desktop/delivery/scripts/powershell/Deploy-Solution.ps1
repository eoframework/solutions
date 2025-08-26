#Requires -Version 5.1
#Requires -Modules Az

<#
.SYNOPSIS
    Deploy Azure Virtual Desktop solution infrastructure and configuration.

.DESCRIPTION
    This script automates the deployment of Azure Virtual Desktop infrastructure including:
    - Resource group and networking
    - Host pools and session hosts
    - Storage accounts and file shares for FSLogix profiles
    - Monitoring and management configuration

.PARAMETER ResourceGroupName
    Name of the resource group to create or use.

.PARAMETER Location
    Azure region for resource deployment.

.PARAMETER HostPoolName
    Name of the AVD host pool to create.

.PARAMETER SessionHostCount
    Number of session host VMs to deploy.

.PARAMETER ConfigurationFile
    Path to JSON configuration file with deployment parameters.

.EXAMPLE
    .\Deploy-Solution.ps1 -ResourceGroupName "rg-avd-prod" -Location "East US" -HostPoolName "hp-prod" -SessionHostCount 3

.EXAMPLE
    .\Deploy-Solution.ps1 -ConfigurationFile ".\avd-config.json"
#>

[CmdletBinding()]
param(
    [Parameter(ParameterSetName='Direct')]
    [string]$ResourceGroupName = "rg-avd-prod",
    
    [Parameter(ParameterSetName='Direct')]
    [string]$Location = "East US",
    
    [Parameter(ParameterSetName='Direct')]
    [string]$HostPoolName = "hp-avd-prod",
    
    [Parameter(ParameterSetName='Direct')]
    [int]$SessionHostCount = 3,
    
    [Parameter(ParameterSetName='ConfigFile', Mandatory)]
    [string]$ConfigurationFile,
    
    [switch]$WhatIf
)

# Import required modules
$RequiredModules = @('Az.Accounts', 'Az.Resources', 'Az.Network', 'Az.Storage', 'Az.Compute', 'Az.DesktopVirtualization')
foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -Name $Module -ListAvailable)) {
        Write-Error "Required module $Module is not installed. Please install it using: Install-Module $Module"
        exit 1
    }
    Import-Module $Module -Force
}

# Configuration handling
if ($PSCmdlet.ParameterSetName -eq 'ConfigFile') {
    if (-not (Test-Path $ConfigurationFile)) {
        Write-Error "Configuration file not found: $ConfigurationFile"
        exit 1
    }
    
    $Config = Get-Content $ConfigurationFile | ConvertFrom-Json
    $ResourceGroupName = $Config.ResourceGroupName
    $Location = $Config.Location
    $HostPoolName = $Config.HostPoolName
    $SessionHostCount = $Config.SessionHostCount
} else {
    $Config = @{
        ResourceGroupName = $ResourceGroupName
        Location = $Location
        HostPoolName = $HostPoolName
        SessionHostCount = $SessionHostCount
        VNetName = "vnet-avd-$($ResourceGroupName.Split('-')[-1])"
        SubnetName = "snet-avd-hosts"
        StorageAccountName = "stavd$((Get-Random).ToString().Substring(0,8))"
        WorkspaceName = "ws-avd-prod"
        AppGroupName = "ag-desktop-prod"
    }
}

function Write-DeploymentLog {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $(
        switch ($Level) {
            "INFO" { "White" }
            "WARN" { "Yellow" }
            "ERROR" { "Red" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
    )
}

function Test-AzureConnection {
    try {
        $Context = Get-AzContext
        if (-not $Context) {
            Write-DeploymentLog "Not connected to Azure. Please run Connect-AzAccount first." "ERROR"
            return $false
        }
        Write-DeploymentLog "Connected to Azure subscription: $($Context.Subscription.Name)" "SUCCESS"
        return $true
    }
    catch {
        Write-DeploymentLog "Error checking Azure connection: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function New-AVDResourceGroup {
    param($Name, $Location)
    
    Write-DeploymentLog "Creating resource group: $Name in $Location"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create resource group $Name" "WARN"
        return
    }
    
    try {
        $RG = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if (-not $RG) {
            $RG = New-AzResourceGroup -Name $Name -Location $Location
            Write-DeploymentLog "Resource group created successfully" "SUCCESS"
        } else {
            Write-DeploymentLog "Resource group already exists" "INFO"
        }
        return $RG
    }
    catch {
        Write-DeploymentLog "Error creating resource group: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-AVDNetworking {
    param($ResourceGroupName, $Location, $VNetName, $SubnetName)
    
    Write-DeploymentLog "Creating virtual network and subnet"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create VNet $VNetName with subnet $SubnetName" "WARN"
        return
    }
    
    try {
        # Create subnet configuration
        $SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.0.1.0/24"
        
        # Create virtual network
        $VNet = New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix "10.0.0.0/16" -Subnet $SubnetConfig
        
        # Create Network Security Group
        $NSGRule = New-AzNetworkSecurityRuleConfig -Name "Allow-AVD-Traffic" -Description "Allow AVD service traffic" -Access Allow -Protocol Tcp -Direction Outbound -Priority 100 -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix WindowsVirtualDesktop -DestinationPortRange 443
        
        $NSG = New-AzNetworkSecurityGroup -Name "nsg-avd-hosts" -ResourceGroupName $ResourceGroupName -Location $Location -SecurityRules $NSGRule
        
        # Associate NSG with subnet
        $VNet.Subnets[0].NetworkSecurityGroup = $NSG
        $VNet | Set-AzVirtualNetwork
        
        Write-DeploymentLog "Networking components created successfully" "SUCCESS"
        return $VNet
    }
    catch {
        Write-DeploymentLog "Error creating networking: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-AVDStorage {
    param($ResourceGroupName, $Location, $StorageAccountName)
    
    Write-DeploymentLog "Creating storage account for FSLogix profiles"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create storage account $StorageAccountName" "WARN"
        return
    }
    
    try {
        $StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName "Premium_LRS" -Kind "FileStorage"
        
        # Create file share for profiles
        $Ctx = $StorageAccount.Context
        $FileShare = New-AzStorageShare -Name "profiles" -Context $Ctx -Quota 1024
        
        Write-DeploymentLog "Storage account and file share created successfully" "SUCCESS"
        return $StorageAccount
    }
    catch {
        Write-DeploymentLog "Error creating storage: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-AVDHostPool {
    param($ResourceGroupName, $Location, $HostPoolName, $MaxSessionLimit = 10)
    
    Write-DeploymentLog "Creating AVD host pool: $HostPoolName"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create host pool $HostPoolName" "WARN"
        return
    }
    
    try {
        $HostPool = New-AzWvdHostPool -ResourceGroupName $ResourceGroupName -Name $HostPoolName -Location $Location -HostPoolType Pooled -LoadBalancerType BreadthFirst -MaxSessionLimit $MaxSessionLimit -PreferredAppGroupType Desktop
        
        Write-DeploymentLog "Host pool created successfully" "SUCCESS"
        return $HostPool
    }
    catch {
        Write-DeploymentLog "Error creating host pool: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-AVDWorkspaceAndAppGroup {
    param($ResourceGroupName, $Location, $WorkspaceName, $AppGroupName, $HostPoolId)
    
    Write-DeploymentLog "Creating workspace and application group"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create workspace $WorkspaceName and app group $AppGroupName" "WARN"
        return
    }
    
    try {
        # Create workspace
        $Workspace = New-AzWvdWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location
        
        # Create desktop application group
        $AppGroup = New-AzWvdApplicationGroup -ResourceGroupName $ResourceGroupName -Name $AppGroupName -Location $Location -ApplicationGroupType Desktop -HostPoolArmPath $HostPoolId
        
        # Associate application group with workspace
        Register-AzWvdApplicationGroup -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ApplicationGroupPath $AppGroup.Id
        
        Write-DeploymentLog "Workspace and application group created successfully" "SUCCESS"
        return @{
            Workspace = $Workspace
            ApplicationGroup = $AppGroup
        }
    }
    catch {
        Write-DeploymentLog "Error creating workspace and application group: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-AVDSessionHosts {
    param($ResourceGroupName, $Location, $Count, $SubnetId, $HostPoolToken)
    
    Write-DeploymentLog "Creating $Count session host VMs"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would create $Count session host VMs" "WARN"
        return
    }
    
    try {
        $Jobs = @()
        
        for ($i = 1; $i -le $Count; $i++) {
            $VMName = "vm-avd-sh-$("{0:D2}" -f $i)"
            $NICName = "nic-avd-sh-$("{0:D2}" -f $i)"
            
            Write-DeploymentLog "Creating session host $VMName"
            
            # Create network interface
            $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $SubnetId
            
            # Create VM configuration
            $VMConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_D4s_v4"
            $VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential (Get-Credential -UserName "avdadmin" -Message "Enter password for VM admin")
            $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-11" -Skus "win11-21h2-ent" -Version "latest"
            $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $NIC.Id
            $VMConfig = Set-AzVMOSDisk -VM $VMConfig -CreateOption FromImage -StorageAccountType Premium_LRS
            
            # Create VM asynchronously
            $Job = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig -AsJob
            $Jobs += $Job
        }
        
        # Wait for all VMs to be created
        Write-DeploymentLog "Waiting for session host VMs to be created..."
        $Jobs | Wait-Job
        
        Write-DeploymentLog "Session host VMs created successfully" "SUCCESS"
        return $Jobs
    }
    catch {
        Write-DeploymentLog "Error creating session hosts: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-AVDAgents {
    param($ResourceGroupName, $SessionHostNames, $HostPoolToken)
    
    Write-DeploymentLog "Installing AVD agents on session hosts"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would install AVD agents on session hosts" "WARN"
        return
    }
    
    try {
        foreach ($VMName in $SessionHostNames) {
            Write-DeploymentLog "Installing AVD agent on $VMName"
            
            # Create custom script extension to install AVD agent
            $Settings = @{
                fileUris = @("https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv")
                commandToExecute = "powershell -ExecutionPolicy Unrestricted -File AVDAgentBootLoaderInstall.ps1 -RegistrationToken '$HostPoolToken'"
            }
            
            Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "AVDAgent" -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" -Settings $Settings
        }
        
        Write-DeploymentLog "AVD agents installed successfully" "SUCCESS"
    }
    catch {
        Write-DeploymentLog "Error installing AVD agents: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Enable-AVDMonitoring {
    param($ResourceGroupName, $Location)
    
    Write-DeploymentLog "Enabling monitoring and diagnostics"
    
    if ($WhatIf) {
        Write-DeploymentLog "WHATIF: Would enable monitoring" "WARN"
        return
    }
    
    try {
        # Create Log Analytics workspace
        $WorkspaceName = "law-avd-$($ResourceGroupName.Split('-')[-1])"
        $Workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location -Sku PerGB2018
        
        Write-DeploymentLog "Monitoring enabled successfully" "SUCCESS"
        return $Workspace
    }
    catch {
        Write-DeploymentLog "Error enabling monitoring: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Main deployment logic
try {
    Write-DeploymentLog "Starting Azure Virtual Desktop deployment" "INFO"
    Write-DeploymentLog "Configuration: ResourceGroup=$ResourceGroupName, Location=$Location, HostPool=$HostPoolName, SessionHosts=$SessionHostCount" "INFO"
    
    # Check Azure connection
    if (-not (Test-AzureConnection)) {
        exit 1
    }
    
    # Create resource group
    $ResourceGroup = New-AVDResourceGroup -Name $ResourceGroupName -Location $Location
    
    # Create networking
    $VNet = New-AVDNetworking -ResourceGroupName $ResourceGroupName -Location $Location -VNetName $Config.VNetName -SubnetName $Config.SubnetName
    
    # Create storage
    $StorageAccount = New-AVDStorage -ResourceGroupName $ResourceGroupName -Location $Location -StorageAccountName $Config.StorageAccountName
    
    # Create host pool
    $HostPool = New-AVDHostPool -ResourceGroupName $ResourceGroupName -Location $Location -HostPoolName $HostPoolName
    
    # Create workspace and application group
    $WorkspaceAndAppGroup = New-AVDWorkspaceAndAppGroup -ResourceGroupName $ResourceGroupName -Location $Location -WorkspaceName $Config.WorkspaceName -AppGroupName $Config.AppGroupName -HostPoolId $HostPool.Id
    
    # Get host pool registration token
    $RegistrationInfo = Get-AzWvdRegistrationInfo -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName
    if (-not $RegistrationInfo.Token) {
        $RegistrationInfo = New-AzWvdRegistrationInfo -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName -ExpirationTime (Get-Date).AddHours(4)
    }
    
    # Create session hosts
    if (-not $WhatIf) {
        $SessionHostJobs = New-AVDSessionHosts -ResourceGroupName $ResourceGroupName -Location $Location -Count $SessionHostCount -SubnetId $VNet.Subnets[0].Id -HostPoolToken $RegistrationInfo.Token
        
        # Install AVD agents
        $SessionHostNames = @()
        for ($i = 1; $i -le $SessionHostCount; $i++) {
            $SessionHostNames += "vm-avd-sh-$("{0:D2}" -f $i)"
        }
        Install-AVDAgents -ResourceGroupName $ResourceGroupName -SessionHostNames $SessionHostNames -HostPoolToken $RegistrationInfo.Token
    }
    
    # Enable monitoring
    $Workspace = Enable-AVDMonitoring -ResourceGroupName $ResourceGroupName -Location $Location
    
    Write-DeploymentLog "Azure Virtual Desktop deployment completed successfully!" "SUCCESS"
    Write-DeploymentLog "Access your desktop at: https://rdweb.wvd.microsoft.com/arm/webclient" "INFO"
    
    # Output deployment summary
    $Summary = @{
        ResourceGroup = $ResourceGroupName
        HostPool = $HostPoolName
        Workspace = $Config.WorkspaceName
        SessionHosts = $SessionHostCount
        StorageAccount = $Config.StorageAccountName
        WebClientURL = "https://rdweb.wvd.microsoft.com/arm/webclient"
    }
    
    Write-DeploymentLog "Deployment Summary:" "INFO"
    $Summary | ConvertTo-Json -Depth 2 | Write-Host
}
catch {
    Write-DeploymentLog "Deployment failed: $($_.Exception.Message)" "ERROR"
    Write-DeploymentLog $_.ScriptStackTrace "ERROR"
    exit 1
}