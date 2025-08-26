# Microsoft 365 Deployment Scripts

This directory contains automation scripts for Microsoft 365 enterprise deployment, configuration, and management. The scripts are organized by technology and purpose to support all phases of the deployment lifecycle.

## Directory Structure

### [PowerShell Scripts](powershell/)
Core Microsoft 365 administration and automation scripts using native Microsoft PowerShell modules:
- **Identity Management**: User provisioning, group management, license assignment
- **Exchange Online**: Mailbox configuration, mail flow rules, migration automation
- **SharePoint Online**: Site provisioning, permission management, content migration
- **Microsoft Teams**: Team creation, policy application, meeting configuration
- **Security & Compliance**: Conditional access, DLP policies, audit reporting
- **Monitoring & Reporting**: Health checks, usage analytics, performance monitoring

### [Python Scripts](python/)
Data processing, integration, and advanced analytics scripts:
- **Data Migration**: Legacy system integration and data transformation
- **Reporting & Analytics**: Usage statistics, adoption metrics, custom dashboards
- **API Integration**: Microsoft Graph API automation and third-party integrations
- **Bulk Operations**: Large-scale user management and batch processing

### [Bash Scripts](bash/)
Cross-platform deployment and system administration scripts:
- **Environment Setup**: Prerequisites installation and system preparation
- **Certificate Management**: SSL certificate deployment and renewal
- **Network Configuration**: DNS updates and connectivity validation
- **Backup & Recovery**: Data backup automation and disaster recovery

### [Terraform](terraform/)
Infrastructure as Code for Azure and Microsoft 365 resource provisioning:
- **Azure Infrastructure**: Virtual networks, storage accounts, compute resources
- **Microsoft 365 Configuration**: Tenant settings, policies, and service configuration
- **Hybrid Connectivity**: Express Route and VPN gateway provisioning
- **Security Resources**: Key Vault, security policies, and compliance settings

### [Ansible](ansible/)
Configuration management and deployment automation playbooks:
- **Client Configuration**: Desktop and mobile device setup automation
- **Service Deployment**: Automated service rollout across environments
- **Compliance Enforcement**: Policy application and configuration standardization
- **Update Management**: Automated patching and maintenance procedures

## Script Usage Guidelines

### Prerequisites

#### PowerShell Requirements
```powershell
# Required PowerShell modules
$modules = @(
    "AzureAD",
    "ExchangeOnlineManagement", 
    "MicrosoftTeams",
    "PnP.PowerShell",
    "Microsoft.Graph",
    "MSOnline",
    "SharePointPnPPowerShellOnline"
)

# Install modules
foreach ($module in $modules) {
    Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
}
```

#### Python Requirements
```bash
# Install required Python packages
pip install -r requirements.txt

# Key packages included:
# - msal (Microsoft Authentication Library)
# - requests (HTTP library)
# - pandas (data manipulation)
# - openpyxl (Excel integration)
# - azure-identity
# - msgraph-core
```

#### Environment Variables
```bash
# Set required environment variables
export M365_TENANT_ID="your-tenant-id"
export M365_CLIENT_ID="your-app-registration-id" 
export M365_CLIENT_SECRET="your-client-secret"
export M365_TENANT_DOMAIN="company.onmicrosoft.com"
```

### Authentication and Security

#### Service Principal Setup
```powershell
# Create service principal for automation
$app = New-AzureADApplication -DisplayName "M365 Automation" -HomePage "https://localhost" -IdentifierUris "https://localhost"
$sp = New-AzureADServicePrincipal -AppId $app.AppId

# Assign necessary permissions
# Directory.ReadWrite.All
# User.ReadWrite.All
# Group.ReadWrite.All
# Mail.ReadWrite
# Sites.ReadWrite.All

# Generate client secret
$secret = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId -CustomKeyIdentifier "AutomationKey" -EndDate (Get-Date).AddYears(2)
```

#### Certificate-Based Authentication
```bash
# Generate certificate for authentication
openssl req -x509 -newkey rsa:2048 -keyout private.key -out certificate.crt -days 365 -nodes

# Upload certificate to app registration
# Use certificate thumbprint in scripts
```

### Script Categories and Use Cases

#### Deployment Scripts
**Purpose**: Initial environment setup and service deployment
- Tenant configuration and branding
- Core service activation and setup
- Security baseline implementation
- Initial user and group provisioning

#### Migration Scripts  
**Purpose**: Data and configuration migration from legacy systems
- Email migration automation
- File and document migration
- User data transformation
- Configuration export/import

#### Management Scripts
**Purpose**: Ongoing administration and maintenance
- User lifecycle management
- License optimization
- Performance monitoring
- Compliance reporting

#### Integration Scripts
**Purpose**: Third-party system integration and data synchronization
- HR system integration
- CRM system connectivity
- ERP data synchronization
- Custom application integration

### Error Handling and Logging

#### Standard Error Handling Pattern
```powershell
# PowerShell error handling template
try {
    # Script operations
    Write-Log "Starting operation: $OperationName" -Level Info
    
    # Your code here
    
    Write-Log "Operation completed successfully: $OperationName" -Level Success
}
catch {
    Write-Log "Error in operation: $OperationName - $($_.Exception.Message)" -Level Error
    
    # Cleanup operations if needed
    
    throw $_
}
finally {
    # Cleanup code
    Write-Log "Cleanup completed for: $OperationName" -Level Info
}
```

#### Logging Framework
```powershell
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info",
        [string]$LogFile = "M365Deployment.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Write to console with color coding
    $color = switch ($Level) {
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Success" { "Green" }
        default { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logEntry
}
```

### Performance and Optimization

#### Bulk Operations Best Practices
```powershell
# Efficient bulk processing pattern
function Process-BulkOperation {
    param(
        [array]$Items,
        [scriptblock]$Operation,
        [int]$BatchSize = 100
    )
    
    $batches = @{}
    for ($i = 0; $i -lt $Items.Count; $i += $BatchSize) {
        $batch = $Items[$i..([Math]::Min($i + $BatchSize - 1, $Items.Count - 1))]
        $batches["Batch_$($i/$BatchSize + 1)"] = $batch
    }
    
    foreach ($batchKey in $batches.Keys) {
        Write-Log "Processing $batchKey with $($batches[$batchKey].Count) items"
        
        try {
            # Process batch
            $batches[$batchKey] | ForEach-Object $Operation
            
            # Add delay to avoid throttling
            Start-Sleep -Seconds 2
        }
        catch {
            Write-Log "Error processing $batchKey : $($_.Exception.Message)" -Level Error
        }
    }
}
```

#### Throttling and Rate Limiting
```powershell
# Handle Microsoft Graph API throttling
function Invoke-GraphApiWithRetry {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [hashtable]$Headers,
        [int]$MaxRetries = 3
    )
    
    $retryCount = 0
    do {
        try {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
            return $response
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 429) {
                $retryAfter = $_.Exception.Response.Headers["Retry-After"]
                if ($retryAfter) {
                    $waitTime = [int]$retryAfter + 1
                } else {
                    $waitTime = [Math]::Pow(2, $retryCount) * 60 # Exponential backoff
                }
                
                Write-Log "Rate limited. Waiting $waitTime seconds before retry." -Level Warning
                Start-Sleep -Seconds $waitTime
                $retryCount++
            } else {
                throw $_
            }
        }
    } while ($retryCount -lt $MaxRetries)
    
    throw "Max retries exceeded for API call: $Uri"
}
```

### Testing and Validation

#### Script Testing Framework
```powershell
# Testing template for deployment scripts
function Test-ScriptFunction {
    param([string]$FunctionName)
    
    Write-Host "Testing function: $FunctionName" -ForegroundColor Yellow
    
    $testCases = @(
        @{ Name = "Valid Input"; Input = "valid-data"; Expected = $true },
        @{ Name = "Invalid Input"; Input = "invalid-data"; Expected = $false },
        @{ Name = "Empty Input"; Input = ""; Expected = $false }
    )
    
    foreach ($test in $testCases) {
        try {
            $result = & $FunctionName -Input $test.Input
            $passed = ($result -eq $test.Expected)
            
            $status = if ($passed) { "PASS" } else { "FAIL" }
            $color = if ($passed) { "Green" } else { "Red" }
            
            Write-Host "  $($test.Name): $status" -ForegroundColor $color
        }
        catch {
            Write-Host "  $($test.Name): ERROR - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
```

### Documentation Standards

#### Script Header Template
```powershell
<#
.SYNOPSIS
    Brief description of the script purpose

.DESCRIPTION
    Detailed description of what the script does, including:
    - Main functionality
    - Prerequisites
    - Expected outcomes
    - Any limitations or considerations

.PARAMETER ParameterName
    Description of each parameter

.EXAMPLE
    Example usage of the script with sample parameters

.NOTES
    Author: [Your Name]
    Date: [Creation Date]
    Version: 1.0
    Last Modified: [Date]
    
    Requirements:
    - PowerShell 5.1 or later
    - Required modules: AzureAD, ExchangeOnlineManagement
    - Appropriate permissions in Microsoft 365 tenant

.LINK
    https://docs.microsoft.com/relevant-documentation
#>
```

### Deployment Checklist

#### Pre-Deployment Validation
- [ ] All required modules installed and updated
- [ ] Service principal configured with appropriate permissions
- [ ] Environment variables set correctly
- [ ] Network connectivity to Microsoft 365 endpoints validated
- [ ] Backup of current configuration created

#### Script Execution
- [ ] Test scripts in development environment first
- [ ] Review all parameters and configuration values
- [ ] Execute scripts during maintenance windows when possible
- [ ] Monitor execution logs for errors or warnings
- [ ] Validate results against expected outcomes

#### Post-Deployment Verification
- [ ] Verify all objects created successfully
- [ ] Test functionality from end-user perspective
- [ ] Review audit logs for any security events
- [ ] Update documentation with any changes
- [ ] Schedule follow-up monitoring and maintenance

## Support and Troubleshooting

### Common Issues and Solutions

#### Authentication Failures
```powershell
# Test authentication connectivity
Test-MsolService -ErrorAction Stop
Test-ExchangeOnlineConnection -ErrorAction Stop
Test-AzureADConnection -ErrorAction Stop
```

#### Permission Issues
```powershell
# Check service principal permissions
$sp = Get-AzureADServicePrincipal -Filter "DisplayName eq 'M365 Automation'"
$permissions = Get-AzureADServiceAppRoleAssignment -ObjectId $sp.ObjectId
$permissions | Select-Object PrincipalDisplayName, ResourceDisplayName, PermissionDisplayName
```

#### Rate Limiting and Throttling
- Implement exponential backoff retry logic
- Use batch operations where available
- Monitor API usage and adjust script timing
- Consider using multiple service principals for high-volume operations

### Getting Help

#### Documentation Resources
- [Microsoft 365 PowerShell Documentation](https://docs.microsoft.com/powershell/microsoftgraph/)
- [Microsoft Graph API Reference](https://docs.microsoft.com/graph/api/overview)
- [Exchange Online PowerShell](https://docs.microsoft.com/powershell/exchange/exchange-online-powershell)

#### Community Support
- Microsoft Tech Community Forums
- PowerShell Gallery for module updates
- GitHub repositories for sample scripts
- Stack Overflow for specific coding questions

#### Professional Support
- Microsoft FastTrack services
- Microsoft Premier Support
- Certified Microsoft Partners
- Professional services consultants

---

These scripts are designed to support the complete Microsoft 365 deployment lifecycle. Always test in development environments before production use and ensure appropriate permissions and backups are in place.