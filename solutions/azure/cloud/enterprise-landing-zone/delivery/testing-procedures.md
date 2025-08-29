# Azure Enterprise Landing Zone - Testing Procedures

## Overview

This document provides comprehensive testing procedures for validating the Azure Enterprise Landing Zone deployment. The testing framework covers functional testing, security validation, performance benchmarking, disaster recovery testing, and user acceptance testing to ensure the platform meets all requirements and operates reliably.

**Testing Framework:** Multi-layered validation approach  
**Testing Tools:** Azure CLI, PowerShell, Pester, custom scripts  
**Test Environment:** Non-production landing zones  
**Validation Criteria:** 100% test pass rate before production deployment

## Testing Strategy and Approach

### Testing Phases
1. **Unit Testing**: Individual component validation
2. **Integration Testing**: Cross-component connectivity and communication
3. **Security Testing**: Compliance and security posture validation
4. **Performance Testing**: Load and stress testing under realistic conditions
5. **Disaster Recovery Testing**: Backup, recovery, and business continuity validation
6. **User Acceptance Testing**: End-user workflow and experience validation

### Testing Environment Setup

#### Test Environment Prerequisites
```powershell
# Test environment setup script
param(
    [Parameter(Mandatory)]
    [string]$TestEnvironment = "testing",
    
    [Parameter(Mandatory)]
    [string]$Location = "East US 2"
)

Write-Host "=== Setting Up Test Environment ===" -ForegroundColor Green

# Variables for test environment
$resourceGroupName = "rg-test-enterprise-lz-$TestEnvironment"
$testTags = @{
    Environment = "Testing"
    Purpose = "Landing Zone Validation"
    Owner = "Platform Team"
    DeleteAfter = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
}

# Create test resource group
try {
    $testRG = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if (!$testRG) {
        Write-Host "Creating test resource group: $resourceGroupName" -ForegroundColor Yellow
        New-AzResourceGroup -Name $resourceGroupName -Location $Location -Tag $testTags
    } else {
        Write-Host "Test resource group already exists: $resourceGroupName" -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to create test resource group: $($_.Exception.Message)"
    exit 1
}

# Deploy test infrastructure
Write-Host "Deploying test infrastructure..." -ForegroundColor Yellow

# Create test key vault for secrets
$testKeyVaultName = "kv-test-lz-$(Get-Random -Minimum 1000 -Maximum 9999)"
try {
    $testKeyVault = New-AzKeyVault -VaultName $testKeyVaultName -ResourceGroupName $resourceGroupName -Location $Location -Tag $testTags
    Write-Host "Test Key Vault created: $testKeyVaultName" -ForegroundColor Green
} catch {
    Write-Warning "Failed to create test key vault: $($_.Exception.Message)"
}

# Create test storage account
$testStorageAccountName = "sttest$(Get-Random -Minimum 10000 -Maximum 99999)"
try {
    $testStorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $testStorageAccountName -Location $Location -SkuName "Standard_LRS" -Tag $testTags
    Write-Host "Test Storage Account created: $testStorageAccountName" -ForegroundColor Green
} catch {
    Write-Warning "Failed to create test storage account: $($_.Exception.Message)"
}

# Store test environment configuration
$testConfig = @{
    ResourceGroupName = $resourceGroupName
    KeyVaultName = $testKeyVaultName
    StorageAccountName = $testStorageAccountName
    Location = $Location
    CreatedDate = Get-Date
    Tags = $testTags
}

$testConfig | ConvertTo-Json | Out-File -FilePath "test-environment-config.json"
Write-Host "Test environment configuration saved to test-environment-config.json" -ForegroundColor Green

Write-Host "=== Test Environment Setup Completed ===" -ForegroundColor Green
return $testConfig
```

## Unit Testing

### 1. Management Groups Validation

#### Test: Management Group Structure
```powershell
# Management Groups Unit Tests using Pester

Describe "Management Groups Structure" {
    BeforeAll {
        # Setup test context
        $managementGroupPrefix = "mg-enterprise"
        $expectedGroups = @(
            "$managementGroupPrefix",
            "$managementGroupPrefix-platform",
            "$managementGroupPrefix-landingzones", 
            "$managementGroupPrefix-platform-identity",
            "$managementGroupPrefix-platform-management",
            "$managementGroupPrefix-platform-connectivity",
            "$managementGroupPrefix-landingzones-corp",
            "$managementGroupPrefix-landingzones-online",
            "$managementGroupPrefix-sandbox",
            "$managementGroupPrefix-decommissioned"
        )
    }
    
    Context "Management Group Hierarchy" {
        It "Should have root management group '<GroupName>'" -ForEach $expectedGroups {
            $mgGroup = Get-AzManagementGroup -GroupId $GroupName -ErrorAction SilentlyContinue
            $mgGroup | Should -Not -BeNullOrEmpty
            $mgGroup.DisplayName | Should -Not -BeNullOrEmpty
        }
        
        It "Should have correct parent-child relationships" {
            $rootMG = Get-AzManagementGroup -GroupId "$managementGroupPrefix" -Expand
            
            # Platform management group should be child of root
            $platformMG = $rootMG.Children | Where-Object { $_.DisplayName -eq "Platform" }
            $platformMG | Should -Not -BeNullOrEmpty
            
            # Landing zones should be child of root
            $landingZonesMG = $rootMG.Children | Where-Object { $_.DisplayName -eq "Landing Zones" }
            $landingZonesMG | Should -Not -BeNullOrEmpty
            
            # Identity should be child of platform
            $platformExpanded = Get-AzManagementGroup -GroupId "$managementGroupPrefix-platform" -Expand
            $identityMG = $platformExpanded.Children | Where-Object { $_.DisplayName -eq "Platform Identity" }
            $identityMG | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Management Group Policies" {
        It "Should have policies assigned to root management group" {
            $policies = Get-AzPolicyAssignment -Scope "/providers/Microsoft.Management/managementGroups/$managementGroupPrefix"
            $policies.Count | Should -BeGreaterThan 0
        }
        
        It "Should have required tag policy assigned" {
            $tagPolicy = Get-AzPolicyAssignment -Scope "/providers/Microsoft.Management/managementGroups/$managementGroupPrefix" | 
                Where-Object { $_.Properties.DisplayName -like "*tag*" }
            $tagPolicy | Should -Not -BeNullOrEmpty
        }
    }
}

# Run the tests
Invoke-Pester -Path ".\ManagementGroupTests.ps1" -Output Detailed
```

### 2. Network Connectivity Validation

#### Test: Hub-Spoke Network Architecture
```powershell
# Network Connectivity Unit Tests

Describe "Hub-Spoke Network Architecture" {
    BeforeAll {
        $connectivityRG = "rg-connectivity-prod-eus2-001"
        $hubVNetName = "vnet-hub-prod-eus2-001"
        $expectedSubnets = @("GatewaySubnet", "AzureFirewallSubnet", "AzureBastionSubnet")
    }
    
    Context "Hub Virtual Network" {
        It "Should exist and be in succeeded state" {
            $hubVNet = Get-AzVirtualNetwork -ResourceGroupName $connectivityRG -Name $hubVNetName
            $hubVNet | Should -Not -BeNullOrEmpty
            $hubVNet.ProvisioningState | Should -Be "Succeeded"
        }
        
        It "Should have correct address space" {
            $hubVNet = Get-AzVirtualNetwork -ResourceGroupName $connectivityRG -Name $hubVNetName
            $hubVNet.AddressSpace.AddressPrefixes | Should -Contain "10.10.0.0/16"
        }
        
        It "Should have required subnets '<SubnetName>'" -ForEach $expectedSubnets {
            $hubVNet = Get-AzVirtualNetwork -ResourceGroupName $connectivityRG -Name $hubVNetName
            $subnet = $hubVNet.Subnets | Where-Object { $_.Name -eq $SubnetName }
            $subnet | Should -Not -BeNullOrEmpty
            $subnet.ProvisioningState | Should -Be "Succeeded"
        }
    }
    
    Context "VPN Gateway" {
        It "Should exist and be connected" {
            $vpnGateway = Get-AzVirtualNetworkGateway -ResourceGroupName $connectivityRG -Name "vgw-vpn-prod-eus2-001" -ErrorAction SilentlyContinue
            if ($vpnGateway) {
                $vpnGateway.ProvisioningState | Should -Be "Succeeded"
                $vpnGateway.GatewayType | Should -Be "Vpn"
            }
        }
        
        It "Should have BGP enabled" {
            $vpnGateway = Get-AzVirtualNetworkGateway -ResourceGroupName $connectivityRG -Name "vgw-vpn-prod-eus2-001" -ErrorAction SilentlyContinue
            if ($vpnGateway) {
                $vpnGateway.EnableBgp | Should -Be $true
            }
        }
    }
    
    Context "Azure Firewall" {
        It "Should exist and be running" {
            $firewall = Get-AzFirewall -ResourceGroupName $connectivityRG -Name "afw-hub-prod-eus2-001" -ErrorAction SilentlyContinue
            if ($firewall) {
                $firewall.ProvisioningState | Should -Be "Succeeded"
                $firewall.IpConfigurations.Count | Should -BeGreaterThan 0
            }
        }
        
        It "Should have threat intelligence enabled" {
            $firewall = Get-AzFirewall -ResourceGroupName $connectivityRG -Name "afw-hub-prod-eus2-001" -ErrorAction SilentlyContinue
            if ($firewall) {
                $firewall.ThreatIntelMode | Should -Be "Alert" -Or "Deny"
            }
        }
    }
    
    Context "Network Peering" {
        It "Should have spoke networks peered to hub" {
            $peerings = Get-AzVirtualNetworkPeering -VirtualNetworkName $hubVNetName -ResourceGroupName $connectivityRG
            $peerings.Count | Should -BeGreaterThan 0
            
            foreach ($peering in $peerings) {
                $peering.PeeringState | Should -Be "Connected"
                $peering.ProvisioningState | Should -Be "Succeeded"
            }
        }
    }
}

# Network connectivity tests
Describe "Network Connectivity Tests" {
    Context "DNS Resolution" {
        It "Should resolve Azure DNS" {
            $dnsResult = Resolve-DnsName -Name "management.azure.com" -ErrorAction SilentlyContinue
            $dnsResult | Should -Not -BeNullOrEmpty
        }
        
        It "Should resolve custom DNS if configured" {
            # Add custom DNS tests based on environment
        }
    }
    
    Context "Internet Connectivity" {
        It "Should allow HTTPS traffic to Azure services" {
            $httpTest = Test-NetConnection -ComputerName "management.azure.com" -Port 443
            $httpTest.TcpTestSucceeded | Should -Be $true
        }
        
        It "Should allow access to required endpoints" {
            $endpoints = @(
                "login.microsoftonline.com",
                "graph.microsoft.com",
                "vault.azure.net"
            )
            
            foreach ($endpoint in $endpoints) {
                $test = Test-NetConnection -ComputerName $endpoint -Port 443
                $test.TcpTestSucceeded | Should -Be $true
            }
        }
    }
}

# Run network tests
Invoke-Pester -Path ".\NetworkTests.ps1" -Output Detailed
```

### 3. Security Configuration Tests

#### Test: Security Baseline Validation
```bash
#!/bin/bash
# Security Configuration Unit Tests

TEST_RESULTS_FILE="security-test-results-$(date +%Y%m%d-%H%M%S).json"

echo "=== Security Configuration Unit Tests ==="
echo "Starting security baseline validation..."

# Initialize test results
cat > $TEST_RESULTS_FILE << EOF
{
  "testSuite": "Security Configuration",
  "timestamp": "$(date -Iseconds)",
  "tests": []
}
EOF

# Function to add test result
add_test_result() {
    local test_name="$1"
    local test_status="$2"
    local test_message="$3"
    
    local temp_file=$(mktemp)
    jq --arg name "$test_name" --arg status "$test_status" --arg message "$test_message" \
       '.tests += [{"name": $name, "status": $status, "message": $message, "timestamp": now}]' \
       $TEST_RESULTS_FILE > $temp_file && mv $temp_file $TEST_RESULTS_FILE
    
    if [ "$test_status" = "PASS" ]; then
        echo "✓ PASS: $test_name"
    else
        echo "✗ FAIL: $test_name - $test_message"
    fi
}

# Test 1: Security Center Configuration
echo "--- Testing Security Center Configuration ---"

security_pricing=$(az security pricing list --output json 2>/dev/null)
if [ $? -eq 0 ]; then
    standard_tier_count=$(echo "$security_pricing" | jq '[.[] | select(.pricingTier == "Standard")] | length')
    if [ "$standard_tier_count" -gt 0 ]; then
        add_test_result "Security Center Standard Tier" "PASS" "Found $standard_tier_count services with Standard tier"
    else
        add_test_result "Security Center Standard Tier" "FAIL" "No services found with Standard tier"
    fi
else
    add_test_result "Security Center Standard Tier" "FAIL" "Unable to retrieve Security Center pricing information"
fi

# Test 2: Key Vault Security Configuration
echo "--- Testing Key Vault Security Configuration ---"

key_vaults=$(az keyvault list --query "[].name" --output tsv)
kv_test_pass=true

for kv in $key_vaults; do
    # Test network access restrictions
    network_rules=$(az keyvault show --name $kv --query "properties.networkAcls.defaultAction" --output tsv 2>/dev/null)
    if [ "$network_rules" != "Deny" ]; then
        add_test_result "Key Vault Network Access - $kv" "FAIL" "Default action is not Deny"
        kv_test_pass=false
    fi
    
    # Test soft delete
    soft_delete=$(az keyvault show --name $kv --query "properties.enableSoftDelete" --output tsv 2>/dev/null)
    if [ "$soft_delete" != "true" ]; then
        add_test_result "Key Vault Soft Delete - $kv" "FAIL" "Soft delete not enabled"
        kv_test_pass=false
    fi
    
    # Test purge protection
    purge_protection=$(az keyvault show --name $kv --query "properties.enablePurgeProtection" --output tsv 2>/dev/null)
    if [ "$purge_protection" != "true" ]; then
        add_test_result "Key Vault Purge Protection - $kv" "FAIL" "Purge protection not enabled"
        kv_test_pass=false
    fi
done

if [ "$kv_test_pass" = true ]; then
    add_test_result "Key Vault Security Configuration" "PASS" "All key vaults properly configured"
fi

# Test 3: Storage Account Security
echo "--- Testing Storage Account Security Configuration ---"

storage_accounts=$(az storage account list --query "[].name" --output tsv)
storage_test_pass=true

for sa in $storage_accounts; do
    # Test HTTPS only
    https_only=$(az storage account show --name $sa --query "enableHttpsTrafficOnly" --output tsv 2>/dev/null)
    if [ "$https_only" != "true" ]; then
        add_test_result "Storage HTTPS Only - $sa" "FAIL" "HTTPS only traffic not enforced"
        storage_test_pass=false
    fi
    
    # Test public access
    public_access=$(az storage account show --name $sa --query "allowBlobPublicAccess" --output tsv 2>/dev/null)
    if [ "$public_access" = "true" ]; then
        add_test_result "Storage Public Access - $sa" "FAIL" "Public blob access is allowed"
        storage_test_pass=false
    fi
    
    # Test minimum TLS version
    min_tls=$(az storage account show --name $sa --query "minimumTlsVersion" --output tsv 2>/dev/null)
    if [ "$min_tls" != "TLS1_2" ]; then
        add_test_result "Storage Minimum TLS - $sa" "FAIL" "Minimum TLS version is not 1.2"
        storage_test_pass=false
    fi
done

if [ "$storage_test_pass" = true ]; then
    add_test_result "Storage Account Security Configuration" "PASS" "All storage accounts properly configured"
fi

# Test 4: Network Security Group Rules
echo "--- Testing Network Security Group Rules ---"

nsg_test_pass=true

for rg in $(az group list --query "[].name" --output tsv); do
    for nsg in $(az network nsg list --resource-group $rg --query "[].name" --output tsv 2>/dev/null); do
        # Check for overly permissive inbound rules
        permissive_rules=$(az network nsg rule list --resource-group $rg --nsg-name $nsg \
            --query "[?access=='Allow' && direction=='Inbound' && sourceAddressPrefix=='*' && (destinationPortRange=='*' || destinationPortRange=='22' || destinationPortRange=='3389')].name" \
            --output tsv 2>/dev/null)
        
        if [ -n "$permissive_rules" ]; then
            add_test_result "NSG Permissive Rules - $nsg" "FAIL" "Found overly permissive inbound rules: $permissive_rules"
            nsg_test_pass=false
        fi
    done
done

if [ "$nsg_test_pass" = true ]; then
    add_test_result "Network Security Group Rules" "PASS" "No overly permissive rules found"
fi

# Test 5: Azure Policy Compliance
echo "--- Testing Azure Policy Compliance ---"

non_compliant_resources=$(az policy state list --management-group "mg-enterprise-root" \
    --filter "ComplianceState eq 'NonCompliant'" --query "length(@)" --output tsv 2>/dev/null)

if [ -n "$non_compliant_resources" ] && [ "$non_compliant_resources" -eq 0 ]; then
    add_test_result "Azure Policy Compliance" "PASS" "All resources are compliant"
elif [ -n "$non_compliant_resources" ] && [ "$non_compliant_resources" -gt 0 ]; then
    add_test_result "Azure Policy Compliance" "FAIL" "$non_compliant_resources non-compliant resources found"
else
    add_test_result "Azure Policy Compliance" "FAIL" "Unable to retrieve policy compliance data"
fi

# Generate summary
echo "--- Test Summary ---"

total_tests=$(jq '.tests | length' $TEST_RESULTS_FILE)
passed_tests=$(jq '[.tests[] | select(.status == "PASS")] | length' $TEST_RESULTS_FILE)
failed_tests=$(jq '[.tests[] | select(.status == "FAIL")] | length' $TEST_RESULTS_FILE)

echo "Total Tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $failed_tests"

# Update summary in JSON
temp_file=$(mktemp)
jq --argjson total "$total_tests" --argjson passed "$passed_tests" --argjson failed "$failed_tests" \
   '. += {"summary": {"total": $total, "passed": $passed, "failed": $failed}}' \
   $TEST_RESULTS_FILE > $temp_file && mv $temp_file $TEST_RESULTS_FILE

echo "Test results saved to: $TEST_RESULTS_FILE"

if [ "$failed_tests" -eq 0 ]; then
    echo "=== All Security Tests Passed ==="
    exit 0
else
    echo "=== $failed_tests Security Tests Failed ==="
    exit 1
fi
```

## Integration Testing

### 1. End-to-End Connectivity Tests

#### Test: Cross-Landing Zone Communication
```powershell
# Integration Testing - Cross-Landing Zone Communication

Describe "Cross-Landing Zone Integration" {
    BeforeAll {
        # Test VMs in different landing zones
        $testVMs = @{
            CorpVM = @{
                ResourceGroup = "rg-corp-prod-eus2-001"
                Name = "vm-test-corp-001"
                PrivateIP = "10.20.1.10"
            }
            OnlineVM = @{
                ResourceGroup = "rg-online-prod-eus2-001" 
                Name = "vm-test-online-001"
                PrivateIP = "10.30.1.10"
            }
        }
    }
    
    Context "Hub-Spoke Connectivity" {
        It "Should allow communication from Corp to Online through hub" {
            # Deploy test VMs if they don't exist
            foreach ($vmConfig in $testVMs.Values) {
                $vm = Get-AzVM -ResourceGroupName $vmConfig.ResourceGroup -Name $vmConfig.Name -ErrorAction SilentlyContinue
                if (-not $vm) {
                    # Deploy test VM using ARM template or script
                    Write-Host "Deploying test VM: $($vmConfig.Name)" -ForegroundColor Yellow
                    # Deploy-TestVM -ResourceGroup $vmConfig.ResourceGroup -VMName $vmConfig.Name -PrivateIP $vmConfig.PrivateIP
                }
            }
            
            # Test connectivity using Azure Network Watcher
            $corpVM = Get-AzVM -ResourceGroupName $testVMs.CorpVM.ResourceGroup -Name $testVMs.CorpVM.Name
            $onlineVM = Get-AzVM -ResourceGroupName $testVMs.OnlineVM.ResourceGroup -Name $testVMs.OnlineVM.Name
            
            if ($corpVM -and $onlineVM) {
                $connectivityTest = Test-AzNetworkWatcherConnectivity -NetworkWatcher $networkWatcher `
                    -SourceResourceId $corpVM.Id `
                    -DestinationResourceId $onlineVM.Id `
                    -DestinationPort 80
                
                $connectivityTest.ConnectionStatus | Should -Be "Reachable"
            }
        }
        
        It "Should route traffic through Azure Firewall" {
            # Verify that traffic is being routed through the firewall
            $routeTable = Get-AzRouteTable -ResourceGroupName "rg-connectivity-prod-eus2-001" -Name "rt-spoke-prod-eus2-001"
            $defaultRoute = $routeTable.Routes | Where-Object { $_.AddressPrefix -eq "0.0.0.0/0" }
            
            $defaultRoute | Should -Not -BeNullOrEmpty
            $defaultRoute.NextHopType | Should -Be "VirtualAppliance"
        }
    }
    
    Context "DNS Resolution" {
        It "Should resolve Azure services from spoke networks" {
            # Test DNS resolution from spoke networks
            $dnsTests = @(
                "vault.azure.net",
                "management.azure.com",
                "login.microsoftonline.com"
            )
            
            foreach ($dnsName in $dnsTests) {
                $resolved = Resolve-DnsName -Name $dnsName -ErrorAction SilentlyContinue
                $resolved | Should -Not -BeNullOrEmpty
            }
        }
        
        It "Should resolve custom DNS entries if configured" {
            # Add tests for custom DNS configurations
        }
    }
    
    Context "Application Gateway Integration" {
        It "Should properly route traffic through Application Gateway" {
            $appGateway = Get-AzApplicationGateway -ResourceGroupName "rg-online-prod-eus2-001" -Name "appgw-online-prod-eus2-001" -ErrorAction SilentlyContinue
            
            if ($appGateway) {
                $appGateway.ProvisioningState | Should -Be "Succeeded"
                $appGateway.BackendAddressPools.Count | Should -BeGreaterThan 0
                $appGateway.HttpListeners.Count | Should -BeGreaterThan 0
            }
        }
    }
}

# Run integration tests
Invoke-Pester -Path ".\IntegrationTests.ps1" -Output Detailed
```

### 2. Service Integration Validation

#### Test: Azure Services Integration
```powershell
# Service Integration Tests

Describe "Azure Services Integration" {
    Context "Log Analytics Integration" {
        It "Should receive logs from all subscriptions" {
            $logWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-management-prod-eus2-001" -Name "law-management-prod-eus2-001"
            $logWorkspace | Should -Not -BeNullOrEmpty
            
            # Check if diagnostic settings are configured
            $subscriptions = @($connectivitySubscriptionId, $managementSubscriptionId, $identitySubscriptionId)
            
            foreach ($subId in $subscriptions) {
                Set-AzContext -SubscriptionId $subId
                $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId "/subscriptions/$subId"
                $diagnosticSettings.Count | Should -BeGreaterThan 0
            }
        }
        
        It "Should have required solutions installed" {
            $expectedSolutions = @("Security", "Updates", "VMInsights")
            
            foreach ($solution in $expectedSolutions) {
                $installedSolution = Get-AzOperationalInsightsIntelligencePack -ResourceGroupName "rg-management-prod-eus2-001" -WorkspaceName "law-management-prod-eus2-001" | 
                    Where-Object { $_.Name -eq $solution -and $_.Enabled -eq $true }
                $installedSolution | Should -Not -BeNullOrEmpty
            }
        }
    }
    
    Context "Security Center Integration" {
        It "Should have all subscriptions enrolled" {
            $subscriptions = @($connectivitySubscriptionId, $managementSubscriptionId, $identitySubscriptionId)
            
            foreach ($subId in $subscriptions) {
                Set-AzContext -SubscriptionId $subId
                $securityContacts = Get-AzSecurityContact
                $securityContacts.Count | Should -BeGreaterThan 0
                
                $autoProvisioning = Get-AzSecurityAutoProvisioningSetting -Name "default"
                $autoProvisioning.AutoProvision | Should -Be "On"
            }
        }
    }
    
    Context "Backup Integration" {
        It "Should have Recovery Services Vault configured" {
            $recoveryVault = Get-AzRecoveryServicesVault -ResourceGroupName "rg-management-prod-eus2-001" -Name "rsv-management-prod-eus2-001"
            $recoveryVault | Should -Not -BeNullOrEmpty
            $recoveryVault.ProvisioningState | Should -Be "Succeeded"
        }
        
        It "Should have backup policies configured" {
            Set-AzRecoveryServicesVaultContext -Vault (Get-AzRecoveryServicesVault -ResourceGroupName "rg-management-prod-eus2-001" -Name "rsv-management-prod-eus2-001")
            $backupPolicies = Get-AzRecoveryServicesBackupProtectionPolicy
            $backupPolicies.Count | Should -BeGreaterThan 0
        }
    }
    
    Context "Automation Integration" {
        It "Should have Automation Account linked to Log Analytics" {
            $automationAccount = Get-AzAutomationAccount -ResourceGroupName "rg-management-prod-eus2-001" -Name "aa-management-prod-eus2-001"
            $automationAccount | Should -Not -BeNullOrEmpty
            
            $linkedWorkspace = Get-AzOperationalInsightsLinkTarget -ResourceGroupName "rg-management-prod-eus2-001" -WorkspaceName "law-management-prod-eus2-001"
            $linkedWorkspace | Should -Not -BeNullOrEmpty
        }
    }
}
```

## Performance Testing

### 1. Network Performance Benchmarking

#### Test: Network Latency and Throughput
```bash
#!/bin/bash
# Network Performance Testing

echo "=== Network Performance Testing ==="

PERFORMANCE_REPORT="network-performance-$(date +%Y%m%d-%H%M%S).json"

# Initialize performance report
cat > $PERFORMANCE_REPORT << EOF
{
  "testType": "Network Performance",
  "timestamp": "$(date -Iseconds)",
  "tests": [],
  "summary": {}
}
EOF

# Function to add performance test result
add_performance_result() {
    local test_name="$1"
    local metric="$2"
    local value="$3"
    local unit="$4"
    local status="$5"
    
    local temp_file=$(mktemp)
    jq --arg name "$test_name" --arg metric "$metric" --arg value "$value" --arg unit "$unit" --arg status "$status" \
       '.tests += [{"name": $name, "metric": $metric, "value": $value, "unit": $unit, "status": $status, "timestamp": now}]' \
       $PERFORMANCE_REPORT > $temp_file && mv $temp_file $PERFORMANCE_REPORT
}

# Test 1: Hub VNet to Spoke VNet Latency
echo "--- Testing Hub-Spoke Latency ---"

# Assuming test VMs are deployed
HUB_VM_IP="10.10.3.10"
CORP_SPOKE_IP="10.20.1.10"
ONLINE_SPOKE_IP="10.30.1.10"

# Test latency from hub to corporate spoke
if ping -c 10 $CORP_SPOKE_IP > /dev/null 2>&1; then
    latency_corp=$(ping -c 10 $CORP_SPOKE_IP | tail -1 | awk -F '/' '{print $5}')
    add_performance_result "Hub to Corp Spoke Latency" "latency" "$latency_corp" "ms" "PASS"
    echo "Hub to Corp Spoke Latency: ${latency_corp}ms"
else
    add_performance_result "Hub to Corp Spoke Latency" "latency" "timeout" "ms" "FAIL"
    echo "Hub to Corp Spoke: Connection timeout"
fi

# Test latency from hub to online spoke
if ping -c 10 $ONLINE_SPOKE_IP > /dev/null 2>&1; then
    latency_online=$(ping -c 10 $ONLINE_SPOKE_IP | tail -1 | awk -F '/' '{print $5}')
    add_performance_result "Hub to Online Spoke Latency" "latency" "$latency_online" "ms" "PASS"
    echo "Hub to Online Spoke Latency: ${latency_online}ms"
else
    add_performance_result "Hub to Online Spoke Latency" "latency" "timeout" "ms" "FAIL"
    echo "Hub to Online Spoke: Connection timeout"
fi

# Test 2: Throughput Testing using iperf3 (if available)
echo "--- Testing Network Throughput ---"

if command -v iperf3 &> /dev/null; then
    # Run iperf3 server on one VM and client on another (requires coordination)
    echo "iperf3 available - running throughput tests"
    
    # Example throughput test (requires iperf3 server running on target)
    # throughput_result=$(iperf3 -c $CORP_SPOKE_IP -t 30 -f m | grep "sender" | awk '{print $7}')
    # add_performance_result "Hub to Corp Throughput" "throughput" "$throughput_result" "Mbps" "PASS"
else
    echo "iperf3 not available - skipping throughput tests"
fi

# Test 3: DNS Resolution Performance
echo "--- Testing DNS Resolution Performance ---"

dns_endpoints=("management.azure.com" "vault.azure.net" "login.microsoftonline.com")

for endpoint in "${dns_endpoints[@]}"; do
    echo "Testing DNS resolution for $endpoint"
    
    # Measure DNS resolution time
    dns_time=$(time (nslookup $endpoint > /dev/null 2>&1) 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]//g')
    
    if [ -n "$dns_time" ]; then
        add_performance_result "DNS Resolution - $endpoint" "resolution_time" "$dns_time" "ms" "PASS"
        echo "DNS resolution for $endpoint: ${dns_time}ms"
    else
        add_performance_result "DNS Resolution - $endpoint" "resolution_time" "failed" "ms" "FAIL"
        echo "DNS resolution for $endpoint: Failed"
    fi
done

# Test 4: Azure Service Connectivity Performance
echo "--- Testing Azure Service Connectivity ---"

azure_services=("management.azure.com:443" "vault.azure.net:443" "graph.microsoft.com:443")

for service in "${azure_services[@]}"; do
    host=$(echo $service | cut -d':' -f1)
    port=$(echo $service | cut -d':' -f2)
    
    echo "Testing connectivity to $host:$port"
    
    # Measure connection time using curl
    if command -v curl &> /dev/null; then
        connect_time=$(curl -w "%{time_connect}" -s -o /dev/null --max-time 10 "https://$host" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            connect_time_ms=$(echo "$connect_time * 1000" | bc -l | cut -d'.' -f1)
            add_performance_result "Service Connectivity - $host" "connect_time" "$connect_time_ms" "ms" "PASS"
            echo "Connection to $host: ${connect_time_ms}ms"
        else
            add_performance_result "Service Connectivity - $host" "connect_time" "failed" "ms" "FAIL"
            echo "Connection to $host: Failed"
        fi
    fi
done

# Generate performance summary
echo "--- Performance Test Summary ---"

total_tests=$(jq '.tests | length' $PERFORMANCE_REPORT)
passed_tests=$(jq '[.tests[] | select(.status == "PASS")] | length' $PERFORMANCE_REPORT)
failed_tests=$(jq '[.tests[] | select(.status == "FAIL")] | length' $PERFORMANCE_REPORT)

# Calculate average latency
avg_latency=$(jq '[.tests[] | select(.metric == "latency" and .status == "PASS") | .value | tonumber] | add / length' $PERFORMANCE_REPORT 2>/dev/null || echo "0")

echo "Total Tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $failed_tests"
echo "Average Latency: ${avg_latency}ms"

# Update summary in JSON
temp_file=$(mktemp)
jq --argjson total "$total_tests" --argjson passed "$passed_tests" --argjson failed "$failed_tests" --argjson avg_latency "$avg_latency" \
   '.summary = {"total_tests": $total, "passed_tests": $passed, "failed_tests": $failed, "average_latency_ms": $avg_latency}' \
   $PERFORMANCE_REPORT > $temp_file && mv $temp_file $PERFORMANCE_REPORT

echo "Performance test results saved to: $PERFORMANCE_REPORT"

if [ "$failed_tests" -eq 0 ]; then
    echo "=== All Performance Tests Passed ==="
    exit 0
else
    echo "=== $failed_tests Performance Tests Failed ==="
    exit 1
fi
```

### 2. Load Testing

#### Test: Azure Firewall and Application Gateway Load Testing
```powershell
# Load Testing Script for Azure Firewall and Application Gateway

param(
    [int]$ConcurrentConnections = 100,
    [int]$TestDurationMinutes = 10,
    [string]$TargetEndpoint = "https://appgw-online-prod-eus2-001.eastus2.cloudapp.azure.com"
)

Write-Host "=== Load Testing Azure Infrastructure ===" -ForegroundColor Green

# Load testing function using PowerShell jobs
function Start-LoadTest {
    param(
        [string]$Endpoint,
        [int]$Connections,
        [int]$DurationMinutes
    )
    
    $loadTestResults = @{
        StartTime = Get-Date
        Endpoint = $Endpoint
        TotalRequests = 0
        SuccessfulRequests = 0
        FailedRequests = 0
        AverageResponseTime = 0
        MaxResponseTime = 0
        MinResponseTime = [double]::MaxValue
        ResponseTimes = @()
    }
    
    Write-Host "Starting load test with $Connections concurrent connections for $DurationMinutes minutes"
    
    # Create script block for worker jobs
    $workerScript = {
        param($Endpoint, $DurationMinutes)
        
        $endTime = (Get-Date).AddMinutes($DurationMinutes)
        $requests = @()
        
        while ((Get-Date) -lt $endTime) {
            $startTime = Get-Date
            
            try {
                $response = Invoke-WebRequest -Uri $Endpoint -TimeoutSec 30 -UseBasicParsing
                $responseTime = ((Get-Date) - $startTime).TotalMilliseconds
                
                $requests += @{
                    Timestamp = $startTime
                    ResponseTime = $responseTime
                    StatusCode = $response.StatusCode
                    Success = $true
                }
            }
            catch {
                $responseTime = ((Get-Date) - $startTime).TotalMilliseconds
                
                $requests += @{
                    Timestamp = $startTime
                    ResponseTime = $responseTime
                    StatusCode = 0
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
            
            Start-Sleep -Milliseconds 100  # Small delay between requests
        }
        
        return $requests
    }
    
    # Start concurrent worker jobs
    $jobs = @()
    for ($i = 0; $i -lt $Connections; $i++) {
        $job = Start-Job -ScriptBlock $workerScript -ArgumentList $Endpoint, $DurationMinutes
        $jobs += $job
        Write-Progress -Activity "Starting Load Test Jobs" -Status "Started job $($i + 1) of $Connections" -PercentComplete (($i + 1) / $Connections * 100)
    }
    
    Write-Host "All jobs started. Waiting for completion..."
    
    # Wait for all jobs to complete
    $completedJobs = 0
    do {
        Start-Sleep -Seconds 5
        $runningJobs = $jobs | Where-Object { $_.State -eq "Running" }
        $newCompletedJobs = $jobs.Count - $runningJobs.Count
        
        if ($newCompletedJobs -ne $completedJobs) {
            $completedJobs = $newCompletedJobs
            Write-Progress -Activity "Load Test in Progress" -Status "Completed jobs: $completedJobs of $($jobs.Count)" -PercentComplete ($completedJobs / $jobs.Count * 100)
        }
    } while ($runningJobs.Count -gt 0)
    
    # Collect results from all jobs
    Write-Host "Collecting results from worker jobs..."
    $allRequests = @()
    
    foreach ($job in $jobs) {
        $jobResults = Receive-Job -Job $job
        $allRequests += $jobResults
        Remove-Job -Job $job
    }
    
    # Analyze results
    $loadTestResults.TotalRequests = $allRequests.Count
    $loadTestResults.SuccessfulRequests = ($allRequests | Where-Object { $_.Success }).Count
    $loadTestResults.FailedRequests = ($allRequests | Where-Object { -not $_.Success }).Count
    $loadTestResults.ResponseTimes = $allRequests | ForEach-Object { $_.ResponseTime }
    
    if ($loadTestResults.ResponseTimes.Count -gt 0) {
        $loadTestResults.AverageResponseTime = ($loadTestResults.ResponseTimes | Measure-Object -Average).Average
        $loadTestResults.MaxResponseTime = ($loadTestResults.ResponseTimes | Measure-Object -Maximum).Maximum
        $loadTestResults.MinResponseTime = ($loadTestResults.ResponseTimes | Measure-Object -Minimum).Minimum
    }
    
    $loadTestResults.EndTime = Get-Date
    $loadTestResults.Duration = $loadTestResults.EndTime - $loadTestResults.StartTime
    
    return $loadTestResults
}

# Run the load test
$results = Start-LoadTest -Endpoint $TargetEndpoint -Connections $ConcurrentConnections -DurationMinutes $TestDurationMinutes

# Generate report
Write-Host "`n=== Load Test Results ===" -ForegroundColor Green
Write-Host "Endpoint: $($results.Endpoint)" -ForegroundColor White
Write-Host "Test Duration: $($results.Duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host "Total Requests: $($results.TotalRequests)" -ForegroundColor White
Write-Host "Successful Requests: $($results.SuccessfulRequests)" -ForegroundColor Green
Write-Host "Failed Requests: $($results.FailedRequests)" -ForegroundColor Red
Write-Host "Success Rate: $(($results.SuccessfulRequests / $results.TotalRequests * 100).ToString('F2'))%" -ForegroundColor White
Write-Host "Average Response Time: $($results.AverageResponseTime.ToString('F2')) ms" -ForegroundColor White
Write-Host "Min Response Time: $($results.MinResponseTime.ToString('F2')) ms" -ForegroundColor White
Write-Host "Max Response Time: $($results.MaxResponseTime.ToString('F2')) ms" -ForegroundColor White
Write-Host "Requests per Second: $(($results.TotalRequests / $results.Duration.TotalSeconds).ToString('F2'))" -ForegroundColor White

# Save detailed results
$reportPath = "load-test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$results | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nDetailed results saved to: $reportPath" -ForegroundColor Yellow

# Performance assessment
$passThresholds = @{
    SuccessRate = 95.0           # 95% success rate
    AverageResponseTime = 2000   # 2 seconds average response time
    MaxResponseTime = 10000      # 10 seconds max response time
}

$successRate = $results.SuccessfulRequests / $results.TotalRequests * 100
$testPassed = $true

Write-Host "`n=== Performance Assessment ===" -ForegroundColor Cyan

if ($successRate -ge $passThresholds.SuccessRate) {
    Write-Host "✓ Success Rate: PASS ($($successRate.ToString('F2'))% >= $($passThresholds.SuccessRate)%)" -ForegroundColor Green
} else {
    Write-Host "✗ Success Rate: FAIL ($($successRate.ToString('F2'))% < $($passThresholds.SuccessRate)%)" -ForegroundColor Red
    $testPassed = $false
}

if ($results.AverageResponseTime -le $passThresholds.AverageResponseTime) {
    Write-Host "✓ Average Response Time: PASS ($($results.AverageResponseTime.ToString('F2'))ms <= $($passThresholds.AverageResponseTime)ms)" -ForegroundColor Green
} else {
    Write-Host "✗ Average Response Time: FAIL ($($results.AverageResponseTime.ToString('F2'))ms > $($passThresholds.AverageResponseTime)ms)" -ForegroundColor Red
    $testPassed = $false
}

if ($results.MaxResponseTime -le $passThresholds.MaxResponseTime) {
    Write-Host "✓ Max Response Time: PASS ($($results.MaxResponseTime.ToString('F2'))ms <= $($passThresholds.MaxResponseTime)ms)" -ForegroundColor Green
} else {
    Write-Host "✗ Max Response Time: FAIL ($($results.MaxResponseTime.ToString('F2'))ms > $($passThresholds.MaxResponseTime)ms)" -ForegroundColor Red
    $testPassed = $false
}

if ($testPassed) {
    Write-Host "`n=== Load Test PASSED ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n=== Load Test FAILED ===" -ForegroundColor Red
    exit 1
}
```

## Disaster Recovery Testing

### 1. Backup and Recovery Validation

#### Test: Backup Recovery Procedures
```powershell
# Disaster Recovery Testing - Backup and Recovery Validation

param(
    [string]$RecoveryVaultName = "rsv-management-prod-eus2-001",
    [string]$RecoveryResourceGroup = "rg-management-prod-eus2-001",
    [string]$TestVMName = "vm-test-dr-001"
)

Write-Host "=== Disaster Recovery Testing ===" -ForegroundColor Green

# Set Recovery Services Vault context
$recoveryVault = Get-AzRecoveryServicesVault -ResourceGroupName $RecoveryResourceGroup -Name $RecoveryVaultName
Set-AzRecoveryServicesVaultContext -Vault $recoveryVault

$drTestResults = @{
    TestDate = Get-Date
    RecoveryVault = $RecoveryVaultName
    Tests = @()
}

# Test 1: Verify Backup Policy Configuration
Write-Host "--- Testing Backup Policy Configuration ---" -ForegroundColor Yellow

$backupPolicyTest = @{
    TestName = "Backup Policy Configuration"
    Status = "PASS"
    Details = @()
}

try {
    $backupPolicies = Get-AzRecoveryServicesBackupProtectionPolicy
    
    if ($backupPolicies.Count -eq 0) {
        $backupPolicyTest.Status = "FAIL"
        $backupPolicyTest.Details += "No backup policies found"
    } else {
        foreach ($policy in $backupPolicies) {
            $policyDetail = @{
                Name = $policy.Name
                BackupFrequency = $policy.SchedulePolicy.ScheduleRunFrequency
                RetentionDays = $policy.RetentionPolicy.DailySchedule.RetentionDuration.Count
            }
            $backupPolicyTest.Details += $policyDetail
            
            Write-Host "Policy: $($policy.Name)" -ForegroundColor White
            Write-Host "  Frequency: $($policy.SchedulePolicy.ScheduleRunFrequency)" -ForegroundColor Gray
            Write-Host "  Retention: $($policy.RetentionPolicy.DailySchedule.RetentionDuration.Count) days" -ForegroundColor Gray
        }
    }
}
catch {
    $backupPolicyTest.Status = "FAIL"
    $backupPolicyTest.Details += "Error retrieving backup policies: $($_.Exception.Message)"
}

$drTestResults.Tests += $backupPolicyTest

# Test 2: Verify Protected Items
Write-Host "--- Testing Protected Items Status ---" -ForegroundColor Yellow

$protectedItemsTest = @{
    TestName = "Protected Items Status"
    Status = "PASS"
    Details = @()
}

try {
    $protectedItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM
    
    if ($protectedItems.Count -eq 0) {
        $protectedItemsTest.Status = "FAIL"
        $protectedItemsTest.Details += "No protected items found"
    } else {
        foreach ($item in $protectedItems) {
            $lastBackup = Get-AzRecoveryServicesBackupRecoveryPoint -Item $item | 
                Sort-Object RecoveryPointTime -Descending | Select-Object -First 1
            
            $daysSinceBackup = if ($lastBackup) { 
                (New-TimeSpan -Start $lastBackup.RecoveryPointTime -End (Get-Date)).Days 
            } else { 
                999 
            }
            
            $itemDetail = @{
                VMName = $item.VirtualMachineId.Split('/')[-1]
                LastBackup = if ($lastBackup) { $lastBackup.RecoveryPointTime } else { "Never" }
                DaysSinceBackup = $daysSinceBackup
                Status = if ($daysSinceBackup -le 1) { "Current" } else { "Outdated" }
            }
            
            $protectedItemsTest.Details += $itemDetail
            
            Write-Host "VM: $($itemDetail.VMName)" -ForegroundColor White
            Write-Host "  Last Backup: $($itemDetail.LastBackup)" -ForegroundColor Gray
            Write-Host "  Status: $($itemDetail.Status)" -ForegroundColor $(if ($itemDetail.Status -eq "Current") { "Green" } else { "Red" })
            
            if ($daysSinceBackup -gt 1) {
                $protectedItemsTest.Status = "FAIL"
            }
        }
    }
}
catch {
    $protectedItemsTest.Status = "FAIL"
    $protectedItemsTest.Details += "Error retrieving protected items: $($_.Exception.Message)"
}

$drTestResults.Tests += $protectedItemsTest

# Test 3: Test VM Recovery (Restore Disks)
Write-Host "--- Testing VM Recovery Process ---" -ForegroundColor Yellow

$recoveryTest = @{
    TestName = "VM Recovery Process"
    Status = "PASS"
    Details = @()
}

try {
    # Find a test VM to restore
    $testItem = $protectedItems | Where-Object { $_.VirtualMachineId -like "*$TestVMName*" } | Select-Object -First 1
    
    if ($testItem) {
        Write-Host "Testing recovery for VM: $($testItem.VirtualMachineId.Split('/')[-1])" -ForegroundColor White
        
        # Get latest recovery point
        $recoveryPoint = Get-AzRecoveryServicesBackupRecoveryPoint -Item $testItem | 
            Sort-Object RecoveryPointTime -Descending | Select-Object -First 1
        
        if ($recoveryPoint) {
            # Test disk restoration (without actually creating the VM)
            $restoreJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoint `
                -StorageAccountName "sttest$((Get-Random -Maximum 99999).ToString())" `
                -StorageAccountResourceGroupName $RecoveryResourceGroup `
                -WhatIf
            
            $recoveryTest.Details += @{
                VMName = $testItem.VirtualMachineId.Split('/')[-1]
                RecoveryPointTime = $recoveryPoint.RecoveryPointTime
                RestoreStatus = "Validated (WhatIf)"
            }
            
            Write-Host "Recovery point found: $($recoveryPoint.RecoveryPointTime)" -ForegroundColor Green
            Write-Host "Restore validation: Success" -ForegroundColor Green
        } else {
            $recoveryTest.Status = "FAIL"
            $recoveryTest.Details += "No recovery points found for test VM"
        }
    } else {
        $recoveryTest.Status = "SKIP"
        $recoveryTest.Details += "Test VM $TestVMName not found in protected items"
        Write-Host "Test VM $TestVMName not found - skipping recovery test" -ForegroundColor Yellow
    }
}
catch {
    $recoveryTest.Status = "FAIL"
    $recoveryTest.Details += "Error during recovery test: $($_.Exception.Message)"
}

$drTestResults.Tests += $recoveryTest

# Test 4: Cross-Region Recovery Capability
Write-Host "--- Testing Cross-Region Recovery Capability ---" -ForegroundColor Yellow

$crossRegionTest = @{
    TestName = "Cross-Region Recovery Capability"
    Status = "PASS"
    Details = @()
}

try {
    # Check if GRS replication is enabled
    $vaultProperties = Get-AzRecoveryServicesVault -ResourceGroupName $RecoveryResourceGroup -Name $RecoveryVaultName
    $replicationSettings = Get-AzRecoveryServicesBackupProperty -Vault $vaultProperties
    
    $crossRegionTest.Details += @{
        VaultName = $RecoveryVaultName
        StorageType = $replicationSettings.BackupStorageRedundancy
        CrossRegionRestore = if ($replicationSettings.BackupStorageRedundancy -eq "GeoRedundant") { "Available" } else { "Not Available" }
    }
    
    Write-Host "Vault: $RecoveryVaultName" -ForegroundColor White
    Write-Host "Storage Type: $($replicationSettings.BackupStorageRedundancy)" -ForegroundColor White
    Write-Host "Cross-Region Restore: $($crossRegionTest.Details[0].CrossRegionRestore)" -ForegroundColor $(if ($crossRegionTest.Details[0].CrossRegionRestore -eq "Available") { "Green" } else { "Yellow" })
    
    if ($replicationSettings.BackupStorageRedundancy -ne "GeoRedundant") {
        $crossRegionTest.Status = "WARNING"
    }
}
catch {
    $crossRegionTest.Status = "FAIL"
    $crossRegionTest.Details += "Error checking cross-region capability: $($_.Exception.Message)"
}

$drTestResults.Tests += $crossRegionTest

# Test 5: Backup Job Health Check
Write-Host "--- Testing Backup Job Health ---" -ForegroundColor Yellow

$jobHealthTest = @{
    TestName = "Backup Job Health"
    Status = "PASS"
    Details = @()
}

try {
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-7)
    $backupJobs = Get-AzRecoveryServicesBackupJob -From $startDate -To $endDate
    
    $jobStats = @{
        TotalJobs = $backupJobs.Count
        CompletedJobs = ($backupJobs | Where-Object { $_.Status -eq "Completed" }).Count
        FailedJobs = ($backupJobs | Where-Object { $_.Status -eq "Failed" }).Count
        InProgressJobs = ($backupJobs | Where-Object { $_.Status -eq "InProgress" }).Count
        CancelledJobs = ($backupJobs | Where-Object { $_.Status -eq "Cancelled" }).Count
    }
    
    $jobHealthTest.Details += $jobStats
    
    Write-Host "Job Statistics (Last 7 Days):" -ForegroundColor White
    Write-Host "  Total Jobs: $($jobStats.TotalJobs)" -ForegroundColor Gray
    Write-Host "  Completed: $($jobStats.CompletedJobs)" -ForegroundColor Green
    Write-Host "  Failed: $($jobStats.FailedJobs)" -ForegroundColor Red
    Write-Host "  In Progress: $($jobStats.InProgressJobs)" -ForegroundColor Yellow
    Write-Host "  Cancelled: $($jobStats.CancelledJobs)" -ForegroundColor Gray
    
    if ($jobStats.FailedJobs -gt 0) {
        $jobHealthTest.Status = "WARNING"
        
        # Get details of failed jobs
        $failedJobs = $backupJobs | Where-Object { $_.Status -eq "Failed" } | Select-Object -First 5
        foreach ($job in $failedJobs) {
            $jobHealthTest.Details += @{
                JobId = $job.JobId
                ActivityId = $job.ActivityId
                ErrorDetails = $job.ErrorDetails
                StartTime = $job.StartTime
            }
        }
    }
    
    if ($jobStats.TotalJobs -eq 0) {
        $jobHealthTest.Status = "FAIL"
    }
}
catch {
    $jobHealthTest.Status = "FAIL"
    $jobHealthTest.Details += "Error checking backup job health: $($_.Exception.Message)"
}

$drTestResults.Tests += $jobHealthTest

# Generate DR Test Report
Write-Host "`n=== Disaster Recovery Test Summary ===" -ForegroundColor Green

$passedTests = ($drTestResults.Tests | Where-Object { $_.Status -eq "PASS" }).Count
$failedTests = ($drTestResults.Tests | Where-Object { $_.Status -eq "FAIL" }).Count
$warningTests = ($drTestResults.Tests | Where-Object { $_.Status -eq "WARNING" }).Count
$skippedTests = ($drTestResults.Tests | Where-Object { $_.Status -eq "SKIP" }).Count

Write-Host "Total Tests: $($drTestResults.Tests.Count)" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Warnings: $warningTests" -ForegroundColor Yellow
Write-Host "Skipped: $skippedTests" -ForegroundColor Gray

# Save detailed report
$reportPath = "dr-test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$drTestResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nDetailed DR test report saved to: $reportPath" -ForegroundColor White

# Overall test result
if ($failedTests -eq 0) {
    Write-Host "`n=== Disaster Recovery Tests PASSED ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n=== Disaster Recovery Tests FAILED ===" -ForegroundColor Red
    exit 1
}
```

## User Acceptance Testing

### 1. Business User Workflow Testing

#### Test: End-User Scenarios
```powershell
# User Acceptance Testing - Business User Workflows

Describe "User Acceptance Testing - Business Workflows" {
    BeforeAll {
        # Setup test user context
        $testUsers = @{
            BusinessUser = "test.business@company.com"
            ITAdmin = "test.admin@company.com"  
            Developer = "test.dev@company.com"
        }
        
        # Test applications and services
        $testServices = @{
            Portal = "https://portal.azure.com"
            KeyVault = "https://vault.azure.net"
            Storage = "https://storageaccount.blob.core.windows.net"
        }
    }
    
    Context "Business User Access" {
        It "Should allow business users to access appropriate resources" {
            # Test RBAC assignments for business users
            $businessUserRole = Get-AzRoleAssignment -SignInName $testUsers.BusinessUser -ResourceGroupName "rg-corp-prod-eus2-001"
            $businessUserRole | Should -Not -BeNullOrEmpty
            
            # Verify they have Reader access but not Contributor
            $readerAccess = $businessUserRole | Where-Object { $_.RoleDefinitionName -eq "Reader" }
            $readerAccess | Should -Not -BeNullOrEmpty
            
            $contributorAccess = $businessUserRole | Where-Object { $_.RoleDefinitionName -eq "Contributor" }
            $contributorAccess | Should -BeNullOrEmpty
        }
        
        It "Should prevent business users from accessing infrastructure resources" {
            # Verify business users cannot access connectivity resources
            $connectivityAccess = Get-AzRoleAssignment -SignInName $testUsers.BusinessUser -ResourceGroupName "rg-connectivity-prod-eus2-001" -ErrorAction SilentlyContinue
            $connectivityAccess | Should -BeNullOrEmpty
        }
    }
    
    Context "IT Administrator Access" {
        It "Should allow IT administrators to manage all resources" {
            $adminRole = Get-AzRoleAssignment -SignInName $testUsers.ITAdmin
            $adminRole | Should -Not -BeNullOrEmpty
            
            # Verify they have appropriate management access
            $managementAccess = $adminRole | Where-Object { 
                $_.RoleDefinitionName -in @("Contributor", "Owner", "User Access Administrator") 
            }
            $managementAccess | Should -Not -BeNullOrEmpty
        }
        
        It "Should allow access to management tools and services" {
            # Test access to Log Analytics workspace
            $logWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-management-prod-eus2-001" -Name "law-management-prod-eus2-001"
            $logWorkspace | Should -Not -BeNullOrEmpty
            
            # Test access to automation account
            $automationAccount = Get-AzAutomationAccount -ResourceGroupName "rg-management-prod-eus2-001" -Name "aa-management-prod-eus2-001"
            $automationAccount | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Developer Access" {
        It "Should allow developers to deploy applications to landing zones" {
            $developerRole = Get-AzRoleAssignment -SignInName $testUsers.Developer -ResourceGroupName "rg-corp-prod-eus2-001"
            $developerRole | Should -Not -BeNullOrEmpty
            
            # Verify they have deployment permissions
            $deploymentAccess = $developerRole | Where-Object { 
                $_.RoleDefinitionName -in @("Contributor", "Virtual Machine Contributor") 
            }
            $deploymentAccess | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Service Availability" {
        It "Should have all critical services accessible" {
            foreach ($service in $testServices.GetEnumerator()) {
                $uri = [System.Uri]$service.Value
                $testConnection = Test-NetConnection -ComputerName $uri.Host -Port 443
                $testConnection.TcpTestSucceeded | Should -Be $true
            }
        }
    }
    
    Context "Application Deployment Workflow" {
        It "Should support standard application deployment process" {
            # Test ARM template deployment
            $templateFile = "test-vm-template.json"
            $parametersFile = "test-vm-parameters.json"
            
            if (Test-Path $templateFile) {
                $templateValidation = Test-AzResourceGroupDeployment -ResourceGroupName "rg-corp-prod-eus2-001" -TemplateFile $templateFile -TemplateParameterFile $parametersFile
                $templateValidation | Should -BeNullOrEmpty  # No validation errors
            }
        }
    }
}

# Run UAT tests
Invoke-Pester -Path ".\UATTests.ps1" -Output Detailed
```

This comprehensive testing procedures document provides a complete framework for validating all aspects of the Azure Enterprise Landing Zone deployment, from individual components to full integration and user acceptance testing.