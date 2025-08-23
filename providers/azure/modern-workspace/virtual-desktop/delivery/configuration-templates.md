# Azure Virtual Desktop Configuration Templates

## Overview
This document provides standardized configuration templates for Azure Virtual Desktop deployment components.

## Azure Resource Templates

### Virtual Network Configuration
```json
{
  "vnetAddressSpace": "10.0.0.0/16",
  "subnets": {
    "avdHosts": {
      "addressPrefix": "10.0.1.0/24",
      "name": "snet-avd-hosts"
    },
    "management": {
      "addressPrefix": "10.0.2.0/24", 
      "name": "snet-management"
    },
    "storage": {
      "addressPrefix": "10.0.3.0/24",
      "name": "snet-storage"
    }
  }
}
```

### Host Pool Configuration
```json
{
  "hostPoolSettings": {
    "type": "Pooled",
    "loadBalancerType": "BreadthFirst",
    "maxSessionLimit": 10,
    "validationEnvironment": false,
    "preferredAppGroupType": "Desktop",
    "startVMOnConnect": true
  }
}
```

## FSLogix Configuration Templates

### Registry Settings
```powershell
# FSLogix Profile Container Settings
$fslogixSettings = @{
    "HKLM:\SOFTWARE\FSLogix\Profiles" = @{
        "Enabled" = 1
        "VHDLocations" = "\\storageaccount.file.core.windows.net\profiles"
        "SizeInMBs" = 10240
        "IsDynamic" = 1
        "VolumeType" = "VHDX"
        "FlipFlopProfileDirectoryName" = 1
        "DeleteLocalProfileWhenVHDShouldApply" = 1
    }
}
```

### FSLogix Group Policy Templates
```xml
<!-- Group Policy XML for FSLogix -->
<GroupPolicy>
    <Computer>
        <ExtensionData>
            <Extension type="Registry">
                <Registry>
                    <Key name="SOFTWARE\FSLogix\Profiles">
                        <Value name="Enabled" type="REG_DWORD" data="1"/>
                        <Value name="VHDLocations" type="REG_SZ" data="\\storageaccount.file.core.windows.net\profiles"/>
                    </Key>
                </Registry>
            </Extension>
        </ExtensionData>
    </Computer>
</GroupPolicy>
```

## Network Security Group Templates

### AVD Host Subnet NSG Rules
```json
{
  "securityRules": [
    {
      "name": "Allow-AVD-Broker",
      "priority": 100,
      "direction": "Outbound",
      "access": "Allow",
      "protocol": "Tcp",
      "sourcePortRange": "*",
      "destinationPortRange": "443",
      "sourceAddressPrefix": "*",
      "destinationAddressPrefix": "WindowsVirtualDesktop"
    },
    {
      "name": "Allow-Azure-KMS",
      "priority": 110,
      "direction": "Outbound", 
      "access": "Allow",
      "protocol": "Tcp",
      "sourcePortRange": "*",
      "destinationPortRange": "1688",
      "sourceAddressPrefix": "*",
      "destinationAddressPrefix": "23.102.135.246"
    },
    {
      "name": "Allow-RDP-Internal",
      "priority": 120,
      "direction": "Inbound",
      "access": "Allow", 
      "protocol": "Tcp",
      "sourcePortRange": "*",
      "destinationPortRange": "3389",
      "sourceAddressPrefix": "10.0.0.0/16",
      "destinationAddressPrefix": "*"
    }
  ]
}
```

## Azure Monitor and Diagnostics

### Log Analytics Queries
```kusto
// AVD Connection Performance
WVDConnections
| where TimeGenerated > ago(24h)
| where State == "Connected"
| summarize avg(EstablishmentTime) by bin(TimeGenerated, 1h)

// Session Host Performance
Perf
| where TimeGenerated > ago(1h)
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| where Computer startswith "vm-avd"
| summarize avg(CounterValue) by Computer
```

### Alert Rule Templates
```json
{
  "alertRules": [
    {
      "name": "AVD High CPU Usage",
      "description": "Alert when session host CPU exceeds 80%",
      "severity": 2,
      "evaluationFrequency": "PT5M",
      "windowSize": "PT15M",
      "criteria": {
        "allOf": [
          {
            "query": "Perf | where ObjectName == 'Processor' | where CounterName == '% Processor Time' | summarize avg(CounterValue) by Computer",
            "threshold": 80,
            "operator": "GreaterThan"
          }
        ]
      }
    }
  ]
}
```

## Conditional Access Policy Templates

### AVD Device Compliance Policy
```json
{
  "displayName": "AVD - Require Compliant Device",
  "state": "enabled",
  "conditions": {
    "applications": {
      "includeApplications": ["9cdead84-a844-4324-93f2-b2e6bb768d07"]
    },
    "users": {
      "includeGroups": ["AVD-Users-Group-ID"]
    }
  },
  "grantControls": {
    "operator": "AND",
    "builtInControls": ["compliantDevice", "mfa"]
  }
}
```

## Auto-scaling Configuration

### Scaling Plan Template
```json
{
  "scalingPlan": {
    "name": "sp-avd-production",
    "timeZone": "Eastern Standard Time",
    "schedules": [
      {
        "name": "Weekday Schedule",
        "daysOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
        "rampUpStartTime": "07:00",
        "peakStartTime": "09:00",
        "rampDownStartTime": "17:00",
        "offPeakStartTime": "20:00",
        "rampUpCapacityThresholdPct": 60,
        "rampUpMinimumHostsPct": 20,
        "peakCapacityThresholdPct": 80,
        "rampDownCapacityThresholdPct": 90,
        "rampDownMinimumHostsPct": 10,
        "offPeakCapacityThresholdPct": 90
      }
    ]
  }
}
```

## Session Host VM Configuration

### VM Extension Templates
```json
{
  "extensions": [
    {
      "name": "AVDAgent",
      "publisher": "Microsoft.Compute",
      "type": "CustomScriptExtension",
      "typeHandlerVersion": "1.10",
      "settings": {
        "fileUris": ["https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File AVDAgentBootLoaderInstall.ps1"
      }
    },
    {
      "name": "MMAExtension",
      "publisher": "Microsoft.EnterpriseCloud.Monitoring",
      "type": "MicrosoftMonitoringAgent",
      "settings": {
        "workspaceId": "WORKSPACE_ID"
      },
      "protectedSettings": {
        "workspaceKey": "WORKSPACE_KEY"
      }
    }
  ]
}
```

## Storage Account Configuration

### Azure Files Settings
```json
{
  "storageAccount": {
    "name": "stavdprofiles",
    "sku": "Premium_LRS",
    "kind": "FileStorage",
    "accessTier": "Hot",
    "minimumTlsVersion": "TLS1_2",
    "allowBlobPublicAccess": false,
    "networkRuleSet": {
      "defaultAction": "Deny",
      "virtualNetworkRules": [
        {
          "id": "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/snet-avd-hosts"
        }
      ]
    }
  },
  "fileShares": [
    {
      "name": "profiles",
      "quota": 1024,
      "accessTier": "Premium"
    }
  ]
}
```

## Image Configuration Templates

### Custom VM Image Settings
```json
{
  "imageDefinition": {
    "name": "Win11-AVD-Image",
    "osType": "Windows",
    "osState": "Generalized",
    "identifier": {
      "publisher": "CompanyName",
      "offer": "Windows11-AVD",
      "sku": "21H2-ENT-AVD"
    },
    "recommended": {
      "vCPUs": {
        "min": 2,
        "max": 32
      },
      "memory": {
        "min": 4,
        "max": 128
      }
    }
  }
}
```

### Application Installation Template
```powershell
# Application installation script template
$applications = @(
    @{
        Name = "Microsoft 365 Apps"
        InstallCommand = "setup.exe /configure configuration.xml"
        ConfigFile = "office365-config.xml"
    },
    @{
        Name = "Adobe Reader DC"
        InstallCommand = "AcroRdrDC2200120117_en_US.exe /sAll /rs /msi"
        ConfigFile = $null
    },
    @{
        Name = "Google Chrome"
        InstallCommand = "GoogleChromeStandaloneEnterprise64.msi /quiet"
        ConfigFile = $null
    }
)
```

## Backup and Recovery Configuration

### Azure Backup Policy Template
```json
{
  "backupPolicy": {
    "name": "policy-avd-profiles",
    "backupManagementType": "AzureStorage",
    "schedulePolicy": {
      "schedulePolicyType": "SimpleSchedulePolicy",
      "scheduleRunFrequency": "Daily",
      "scheduleRunTimes": ["2023-01-01T02:00:00Z"]
    },
    "retentionPolicy": {
      "retentionPolicyType": "LongTermRetentionPolicy",
      "dailySchedule": {
        "retentionTimes": ["2023-01-01T02:00:00Z"],
        "retentionDuration": {
          "count": 30,
          "durationType": "Days"
        }
      }
    }
  }
}
```

## Security Configuration Templates

### Windows Security Baseline
```powershell
# Windows Security Settings Template
$securitySettings = @{
    "Account Lockout Policy" = @{
        "Account lockout threshold" = 5
        "Account lockout duration" = 30
        "Reset account lockout counter after" = 30
    }
    "Password Policy" = @{
        "Minimum password length" = 14
        "Password must meet complexity requirements" = "Enabled"
        "Maximum password age" = 90
    }
    "Audit Policy" = @{
        "Audit logon events" = "Success, Failure"
        "Audit account management" = "Success, Failure"
        "Audit privilege use" = "Failure"
    }
}
```

## Performance Optimization Templates

### Registry Settings for Performance
```powershell
# Performance optimization registry settings
$performanceSettings = @{
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" = @{
        "fEnableTimeZoneRedirection" = 1
        "fDisableCpm" = 1
    }
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" = @{
        "fDisableLocationRedirection" = 1
        "fDisablePNPRedir" = 1
    }
}
```

## Monitoring Dashboard Templates

### Azure Monitor Workbook Template
```json
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "WVDConnections\n| where TimeGenerated > ago(24h)\n| summarize count() by State\n| render piechart",
        "size": 3,
        "title": "Connection State Distribution (24h)"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0", 
        "query": "Perf\n| where TimeGenerated > ago(1h)\n| where ObjectName == 'Processor'\n| where CounterName == '% Processor Time'\n| where Computer startswith 'vm-avd'\n| summarize avg(CounterValue) by Computer\n| render barchart",
        "title": "Session Host CPU Utilization"
      }
    }
  ]
}
```