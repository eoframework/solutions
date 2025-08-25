# Microsoft CMMC Enclave - Configuration Templates

This document provides pre-configured templates and baseline settings for implementing CMMC Level 2 compliance in Azure Government. These templates ensure consistent, secure, and compliant configurations across all components of the CMMC Enclave.

## Azure Policy Templates

### CMMC Compliance Initiative

```json
{
  "name": "CMMC-Level-2-Compliance",
  "displayName": "CMMC Level 2 Compliance Initiative",
  "description": "Comprehensive policy initiative for CMMC Level 2 certification covering all 110 NIST SP 800-171 practices",
  "metadata": {
    "category": "CMMC",
    "version": "2.0",
    "nist_baseline": "SP 800-171 Rev 2"
  },
  "policyDefinitions": [
    {
      "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/mg/providers/Microsoft.Authorization/policyDefinitions/ac-1-001-limit-system-access",
      "parameters": {
        "effect": "Audit",
        "requireMFA": true,
        "allowedLocations": ["USGov Virginia", "USGov Texas"]
      }
    },
    {
      "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/mg/providers/Microsoft.Authorization/policyDefinitions/au-2-042-audit-logs",
      "parameters": {
        "effect": "AuditIfNotExists",
        "retentionDays": 365,
        "logCategories": ["AuditEvent", "Authentication", "Authorization"]
      }
    }
  ]
}
```

### Access Control (AC) Policies

#### AC.1.001 - Limit System Access to Authorized Users
```json
{
  "name": "AC-1-001-Limit-System-Access",
  "displayName": "CMMC AC.1.001 - Limit information system access to authorized users",
  "description": "Ensures only authorized users can access information systems through Azure AD controls",
  "mode": "All",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "field": "tags['Classification']",
          "equals": "CUI"
        }
      ]
    },
    "then": {
      "effect": "AuditIfNotExists",
      "details": {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "AADLoginForWindows"
      }
    }
  }
}
```

#### AC.2.007 - Employ Principle of Least Privilege
```json
{
  "name": "AC-2-007-Least-Privilege",
  "displayName": "CMMC AC.2.007 - Employ the principle of least privilege",
  "description": "Ensures least privilege access through RBAC assignments",
  "mode": "All",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Authorization/roleAssignments"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/roleDefinitionId",
          "contains": "Owner"
        }
      ]
    },
    "then": {
      "effect": "Audit",
      "details": {
        "message": "Owner role assignments should be minimized and reviewed regularly"
      }
    }
  }
}
```

### Audit and Accountability (AU) Policies

#### AU.2.042 - Create and Retain System Audit Logs
```json
{
  "name": "AU-2-042-Audit-Logs",
  "displayName": "CMMC AU.2.042 - Create and retain system audit logs and records",
  "description": "Ensures comprehensive audit logging is enabled with proper retention",
  "mode": "All",
  "policyRule": {
    "if": {
      "field": "type",
      "in": [
        "Microsoft.Storage/storageAccounts",
        "Microsoft.KeyVault/vaults",
        "Microsoft.Sql/servers/databases"
      ]
    },
    "then": {
      "effect": "AuditIfNotExists",
      "details": {
        "type": "Microsoft.Insights/diagnosticSettings",
        "existenceCondition": {
          "allOf": [
            {
              "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
              "equals": true
            },
            {
              "field": "Microsoft.Insights/diagnosticSettings/logs[*].retentionPolicy.days",
              "greaterOrEquals": 365
            }
          ]
        }
      }
    }
  }
}
```

## Conditional Access Policy Templates

### CMMC Multi-Factor Authentication Policy

```json
{
  "displayName": "CMMC - Require MFA for CUI System Access",
  "state": "enabled",
  "conditions": {
    "applications": {
      "includeApplications": ["All"],
      "excludeApplications": []
    },
    "users": {
      "includeUsers": ["All"],
      "excludeUsers": ["EmergencyAccess1", "EmergencyAccess2"]
    },
    "locations": {
      "includeLocations": ["All"],
      "excludeLocations": ["AllTrusted"]
    },
    "clientAppTypes": ["all"],
    "deviceStates": {
      "includeStates": ["All"],
      "excludeStates": ["domainJoined", "compliant"]
    }
  },
  "grantControls": {
    "operator": "AND",
    "builtInControls": [
      "mfa",
      "compliantDevice"
    ],
    "customAuthenticationFactors": []
  },
  "sessionControls": {
    "signInFrequency": {
      "value": 4,
      "type": "hours",
      "isEnabled": true
    },
    "persistentBrowser": {
      "mode": "never",
      "isEnabled": true
    }
  }
}
```

### CMMC Privileged Access Policy

```json
{
  "displayName": "CMMC - Enhanced Controls for Privileged Accounts",
  "state": "enabled",
  "conditions": {
    "applications": {
      "includeApplications": ["All"]
    },
    "users": {
      "includeRoles": [
        "62e90394-69f5-4237-9190-012177145e10",
        "194ae4cb-b126-40b2-bd5b-6091b380977d"
      ]
    },
    "locations": {
      "includeLocations": ["All"]
    }
  },
  "grantControls": {
    "operator": "AND",
    "builtInControls": [
      "mfa",
      "compliantDevice",
      "approvedApplication"
    ]
  },
  "sessionControls": {
    "signInFrequency": {
      "value": 1,
      "type": "hours",
      "isEnabled": true
    },
    "cloudAppSecurity": {
      "mcasConfigurationType": "monitorOnly",
      "isEnabled": true
    }
  }
}
```

## Data Classification Templates

### Microsoft Purview Sensitivity Labels

#### CUI Basic Label Configuration
```json
{
  "name": "CUI",
  "displayName": "CUI - Controlled Unclassified Information",
  "description": "Information that requires safeguarding or dissemination controls pursuant to laws, regulations, or government policies",
  "priority": 90,
  "tooltip": "Apply to documents containing CUI data requiring NIST SP 800-171 protection",
  "settings": {
    "encryption": {
      "enabled": true,
      "keySource": "customerManaged",
      "doubleKeyEncryption": false,
      "contentExpirationEnabled": false
    },
    "contentMarkings": {
      "watermark": {
        "text": "CONTROLLED UNCLASSIFIED INFORMATION",
        "fontSize": 12,
        "fontColor": "Red",
        "layout": "diagonal"
      },
      "header": {
        "text": "CUI",
        "fontSize": 11,
        "fontColor": "Red",
        "alignment": "center"
      },
      "footer": {
        "text": "CUI",
        "fontSize": 11,
        "fontColor": "Red",
        "alignment": "center"
      }
    },
    "protectionSettings": {
      "allowOfflineAccess": "limited",
      "offlineAccessDays": 30,
      "allowMacros": false,
      "allowPrint": "limited",
      "allowExport": false,
      "allowForwarding": false,
      "allowEditDocument": true,
      "allowEditContent": true
    }
  },
  "autoLabelingRules": [
    {
      "name": "CUI Pattern Detection",
      "conditions": {
        "contentContains": [
          "CONTROLLED UNCLASSIFIED INFORMATION",
          "CUI//",
          "For Official Use Only",
          "FOUO"
        ],
        "documentProperties": {
          "classification": "CUI"
        }
      },
      "confidence": "high"
    }
  ]
}
```

#### CUI Specified Label Configuration
```json
{
  "name": "CUI//SP",
  "displayName": "CUI//SP - CUI with Specified Handling",
  "description": "CUI that requires specific handling controls beyond basic CUI requirements",
  "priority": 95,
  "tooltip": "Apply to documents with CUI requiring additional specified handling controls",
  "settings": {
    "encryption": {
      "enabled": true,
      "keySource": "customerManaged",
      "doubleKeyEncryption": true,
      "contentExpirationEnabled": true,
      "expirationDays": 2555
    },
    "contentMarkings": {
      "watermark": {
        "text": "CUI//SP - SPECIFIED HANDLING REQUIRED",
        "fontSize": 12,
        "fontColor": "DarkRed",
        "layout": "diagonal"
      },
      "header": {
        "text": "CUI//SP",
        "fontSize": 11,
        "fontColor": "DarkRed",
        "alignment": "center"
      }
    },
    "protectionSettings": {
      "allowOfflineAccess": "never",
      "allowMacros": false,
      "allowPrint": "never",
      "allowExport": "never",
      "allowForwarding": "never",
      "allowCopy": false,
      "requireUserAuthentication": true
    }
  }
}
```

## Data Loss Prevention (DLP) Policies

### CUI Protection Policy Template

```json
{
  "name": "CMMC-CUI-Protection-Policy",
  "displayName": "CMMC CUI Data Loss Prevention",
  "description": "Prevents unauthorized sharing and access to CUI data across Microsoft 365 services",
  "mode": "Block",
  "locations": [
    "ExchangeOnline",
    "SharePointOnline",
    "OneDriveForBusiness",
    "MicrosoftTeams",
    "PowerBI"
  ],
  "rules": [
    {
      "name": "Block External CUI Sharing",
      "priority": 1,
      "conditions": {
        "contentContainsSensitiveInformation": [
          {
            "sensitiveInformationTypeId": "CUI-Pattern",
            "minCount": 1,
            "maxCount": 100,
            "confidenceLevel": "High"
          }
        ],
        "contentIsSharedWith": "ExternalUsers",
        "documentIsPasswordProtected": false
      },
      "actions": {
        "blockAccess": true,
        "notifyUser": {
          "enabled": true,
          "message": "This content contains CUI and cannot be shared externally. Contact your security administrator for guidance."
        },
        "generateIncident": {
          "enabled": true,
          "severity": "High"
        },
        "auditEvent": {
          "enabled": true,
          "includeUserActivities": true
        }
      }
    },
    {
      "name": "Monitor CUI Internal Access",
      "priority": 2,
      "conditions": {
        "sensitivityLabel": "CUI",
        "contentIsAccessedBy": "InternalUsers"
      },
      "actions": {
        "auditEvent": {
          "enabled": true,
          "includeUserActivities": true,
          "includeContentDetails": true
        },
        "alertAdministrators": {
          "enabled": true,
          "emailAddresses": ["security@company.gov"]
        }
      }
    }
  ],
  "advancedSettings": {
    "scanCloudAttachments": true,
    "scanEmailAttachments": true,
    "enableOpticalCharacterRecognition": true,
    "machineLearningScanMode": "enabled"
  }
}
```

## Azure Security Center Compliance Configuration

### CMMC Security Initiative Template

```json
{
  "name": "CMMC-Level-2-Security-Initiative",
  "displayName": "CMMC Level 2 Security Initiative",
  "description": "Comprehensive security assessments for CMMC Level 2 compliance",
  "assessments": [
    {
      "assessmentKey": "ac-1-001",
      "displayName": "AC.1.001 - Limit information system access to authorized users",
      "policyDefinitionReferenceId": "ac-1-001-policy",
      "description": "Validates that system access is limited to authorized users through identity controls"
    },
    {
      "assessmentKey": "au-2-042", 
      "displayName": "AU.2.042 - Create and retain system audit logs",
      "policyDefinitionReferenceId": "au-2-042-policy",
      "description": "Ensures audit logs are created and retained for required periods"
    },
    {
      "assessmentKey": "sc-2-179",
      "displayName": "SC.2.179 - Protect the confidentiality of CUI at rest",
      "policyDefinitionReferenceId": "sc-2-179-policy", 
      "description": "Validates encryption of CUI data at rest using approved methods"
    }
  ],
  "metadata": {
    "version": "2.0",
    "category": "CMMC",
    "source": "Microsoft CMMC Enclave"
  }
}
```

## Azure Monitor Configuration Templates

### CMMC Monitoring Workspace Configuration

```json
{
  "workspaceName": "cmmc-log-analytics-workspace",
  "location": "USGov Virginia",
  "sku": "PerGB2018",
  "retentionInDays": 365,
  "dataRetention": {
    "immutableFor30Days": true,
    "workspaceCanBeRecovered": false
  },
  "dataSources": [
    {
      "kind": "AzureActivityLog",
      "name": "ActivityLogDataSource",
      "properties": {}
    },
    {
      "kind": "SecurityEvent",
      "name": "SecurityEventDataSource",
      "properties": {
        "eventLogName": "Security",
        "eventTypes": [
          {
            "eventType": "Error"
          },
          {
            "eventType": "Warning" 
          },
          {
            "eventType": "Information"
          }
        ]
      }
    },
    {
      "kind": "WindowsEvent",
      "name": "System",
      "properties": {
        "eventLogName": "System",
        "eventTypes": [
          {
            "eventType": "Error"
          },
          {
            "eventType": "Warning"
          }
        ]
      }
    }
  ],
  "solutions": [
    {
      "name": "SecurityCenterFree",
      "publisher": "Microsoft",
      "product": "OMSGallery/SecurityCenterFree"
    },
    {
      "name": "Security",
      "publisher": "Microsoft", 
      "product": "OMSGallery/Security"
    },
    {
      "name": "AzureActivity",
      "publisher": "Microsoft",
      "product": "OMSGallery/AzureActivity"
    }
  ]
}
```

### CMMC Alert Rules Template

```json
{
  "alertRules": [
    {
      "name": "CUI-Data-Access-Alert",
      "displayName": "CUI Data Unauthorized Access Attempt",
      "description": "Alerts when CUI data is accessed by unauthorized users or from untrusted locations",
      "severity": "High",
      "frequency": "PT5M",
      "timeWindow": "PT15M",
      "query": "SigninLogs | where TimeGenerated > ago(15m) | where RiskLevelDuringSignIn == 'high' or RiskLevelAggregated == 'high' | where AppDisplayName contains 'CUI' or ResourceDisplayName contains 'CUI'",
      "actionGroups": [
        {
          "actionGroupId": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Insights/actionGroups/CMMC-Security-Team",
          "emailSubject": "CMMC Alert: Unauthorized CUI Access Attempt"
        }
      ]
    },
    {
      "name": "Privileged-Account-Activity",
      "displayName": "Privileged Account Anomalous Activity",
      "description": "Monitors for unusual activity by privileged accounts",
      "severity": "Medium",
      "frequency": "PT10M",
      "timeWindow": "PT30M", 
      "query": "AuditLogs | where TimeGenerated > ago(30m) | where Category == 'RoleManagement' | where OperationName contains 'Add member to role' | where InitiatedBy.user.userPrincipalName != ''",
      "actionGroups": [
        {
          "actionGroupId": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Insights/actionGroups/CMMC-Security-Team"
        }
      ]
    }
  ]
}
```

## Network Security Configuration Templates

### Network Security Group (NSG) Rules for CMMC

```json
{
  "nsgName": "cmmc-workload-nsg",
  "location": "USGov Virginia",
  "securityRules": [
    {
      "name": "AllowHTTPS",
      "priority": 100,
      "direction": "Inbound",
      "access": "Allow",
      "protocol": "Tcp",
      "sourceAddressPrefix": "*",
      "sourcePortRange": "*",
      "destinationAddressPrefix": "*",
      "destinationPortRange": "443"
    },
    {
      "name": "AllowSSH",
      "priority": 110,
      "direction": "Inbound", 
      "access": "Allow",
      "protocol": "Tcp",
      "sourceAddressPrefix": "10.200.1.0/24",
      "sourcePortRange": "*",
      "destinationAddressPrefix": "10.200.2.0/24",
      "destinationPortRange": "22"
    },
    {
      "name": "AllowRDP",
      "priority": 120,
      "direction": "Inbound",
      "access": "Allow", 
      "protocol": "Tcp",
      "sourceAddressPrefix": "10.200.1.0/24",
      "sourcePortRange": "*",
      "destinationAddressPrefix": "10.200.2.0/24",
      "destinationPortRange": "3389"
    },
    {
      "name": "DenyAllInbound",
      "priority": 4000,
      "direction": "Inbound",
      "access": "Deny",
      "protocol": "*",
      "sourceAddressPrefix": "*",
      "sourcePortRange": "*", 
      "destinationAddressPrefix": "*",
      "destinationPortRange": "*"
    }
  ]
}
```

### Azure Firewall Policy Template

```json
{
  "firewallPolicyName": "cmmc-firewall-policy",
  "location": "USGov Virginia",
  "threatIntelMode": "Alert",
  "threatIntelWhitelist": {
    "ipAddresses": [],
    "fqdns": []
  },
  "intrusionDetection": {
    "mode": "Alert",
    "configuration": {
      "signatureOverrides": [],
      "bypassTrafficSettings": []
    }
  },
  "ruleCollectionGroups": [
    {
      "name": "CMMC-Application-Rules",
      "priority": 1000,
      "ruleCollections": [
        {
          "name": "AllowHTTPS",
          "priority": 100,
          "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
          "action": {
            "type": "Allow"
          },
          "rules": [
            {
              "name": "AllowHTTPS",
              "ruleType": "ApplicationRule",
              "protocols": [
                {
                  "protocolType": "Https",
                  "port": 443
                }
              ],
              "targetFqdns": [
                "*.azure.us",
                "*.microsoft.com",
                "*.windows.net"
              ],
              "sourceAddresses": [
                "10.200.0.0/16"
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Key Vault Configuration Template

### CMMC Key Vault Template

```json
{
  "keyVaultName": "cmmc-keyvault-{uniqueId}",
  "location": "USGov Virginia",
  "properties": {
    "sku": {
      "family": "A",
      "name": "Premium"
    },
    "tenantId": "{tenantId}",
    "enabledForDeployment": false,
    "enabledForTemplateDeployment": true,
    "enabledForDiskEncryption": true,
    "enableSoftDelete": true,
    "softDeleteRetentionInDays": 90,
    "enablePurgeProtection": true,
    "enableRbacAuthorization": true,
    "networkAcls": {
      "bypass": "AzureServices",
      "defaultAction": "Deny",
      "ipRules": [],
      "virtualNetworkRules": [
        {
          "id": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/cmmc-vnet/subnets/data-subnet",
          "ignoreMissingVnetServiceEndpoint": false
        }
      ]
    }
  },
  "diagnosticSettings": {
    "name": "cmmc-keyvault-diagnostics",
    "logs": [
      {
        "category": "AuditEvent",
        "enabled": true,
        "retentionPolicy": {
          "enabled": true,
          "days": 365
        }
      }
    ],
    "metrics": [
      {
        "category": "AllMetrics",
        "enabled": true,
        "retentionPolicy": {
          "enabled": true,
          "days": 365
        }
      }
    ],
    "workspaceId": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/cmmc-log-analytics"
  }
}
```

## Backup Configuration Templates

### Azure Backup Policy for CMMC

```json
{
  "backupPolicyName": "CMMC-VM-Backup-Policy",
  "properties": {
    "backupManagementType": "AzureIaasVM",
    "schedulePolicy": {
      "schedulePolicyType": "SimpleSchedulePolicy",
      "scheduleRunFrequency": "Daily",
      "scheduleRunTimes": [
        "2023-01-01T02:00:00Z"
      ],
      "scheduleWeeklyFrequency": 0
    },
    "retentionPolicy": {
      "retentionPolicyType": "LongTermRetentionPolicy",
      "dailySchedule": {
        "retentionTimes": [
          "2023-01-01T02:00:00Z"
        ],
        "retentionDuration": {
          "count": 30,
          "durationType": "Days"
        }
      },
      "weeklySchedule": {
        "daysOfTheWeek": ["Sunday"],
        "retentionTimes": [
          "2023-01-01T02:00:00Z" 
        ],
        "retentionDuration": {
          "count": 52,
          "durationType": "Weeks"
        }
      },
      "monthlySchedule": {
        "retentionScheduleFormatType": "Weekly",
        "retentionScheduleWeekly": {
          "daysOfTheWeek": ["Sunday"],
          "weeksOfTheMonth": ["First"]
        },
        "retentionTimes": [
          "2023-01-01T02:00:00Z"
        ],
        "retentionDuration": {
          "count": 12,
          "durationType": "Months"
        }
      },
      "yearlySchedule": {
        "retentionScheduleFormatType": "Weekly",
        "monthsOfYear": ["January"],
        "retentionScheduleWeekly": {
          "daysOfTheWeek": ["Sunday"],
          "weeksOfTheMonth": ["First"]
        },
        "retentionTimes": [
          "2023-01-01T02:00:00Z"
        ],
        "retentionDuration": {
          "count": 7,
          "durationType": "Years"
        }
      }
    },
    "timeZone": "Eastern Standard Time"
  }
}
```

## Configuration Management

### Version Control and Updates

All configuration templates are maintained under version control with the following structure:

```
/configurations/
├── templates/
│   ├── v2.0/
│   │   ├── azure-policies/
│   │   ├── conditional-access/
│   │   ├── data-classification/
│   │   ├── network-security/
│   │   └── monitoring/
│   └── v2.1/ (future updates)
├── customizations/
│   ├── client-specific/
│   └── industry-vertical/
└── validation/
    ├── test-cases/
    └── compliance-checks/
```

### Template Customization Guidelines

1. **Never modify base templates directly**
2. **Create organization-specific overlays**
3. **Validate all customizations against CMMC requirements**
4. **Document all deviations from baseline**
5. **Test customizations in non-production environment first**

### Deployment Automation

All templates are designed for automated deployment using:
- **Azure Resource Manager (ARM) Templates**
- **Terraform Infrastructure as Code**
- **Azure PowerShell Scripts**
- **Azure CLI Commands**
- **Microsoft Graph API calls**

For specific implementation procedures, refer to the [Implementation Guide](implementation-guide.md) and [Scripts Directory](scripts/).