# Microsoft 365 Enterprise Deployment - Configuration Templates

This document provides pre-configured templates and baseline settings for Microsoft 365 enterprise deployment. These templates ensure consistent, secure, and optimized configurations across all Microsoft 365 services.

## Azure Active Directory Configuration Templates

### Tenant Configuration Template
```json
{
  "tenantSettings": {
    "companyName": "[COMPANY_NAME]",
    "technicalNotificationEmails": [
      "admin@[DOMAIN].com",
      "security@[DOMAIN].com"
    ],
    "privacyProfile": {
      "contactEmail": "privacy@[DOMAIN].com",
      "statementUrl": "https://[DOMAIN].com/privacy"
    },
    "securityDefaults": {
      "isEnabled": false
    }
  }
}
```

### Conditional Access Policy Templates

#### Baseline MFA Policy
```json
{
  "displayName": "Baseline: Require MFA for All Users",
  "state": "enabled",
  "conditions": {
    "users": {
      "includeUsers": ["All"],
      "excludeUsers": ["emergency-access-accounts"]
    },
    "applications": {
      "includeApplications": ["All"]
    },
    "locations": {
      "includeLocations": ["All"]
    }
  },
  "grantControls": {
    "operator": "OR",
    "builtInControls": ["mfa"]
  }
}
```

#### Block Legacy Authentication
```json
{
  "displayName": "Block Legacy Authentication",
  "state": "enabled",
  "conditions": {
    "users": {
      "includeUsers": ["All"],
      "excludeUsers": ["emergency-access-accounts"]
    },
    "applications": {
      "includeApplications": ["All"]
    },
    "clientAppTypes": [
      "exchangeActiveSync",
      "other"
    ]
  },
  "grantControls": {
    "operator": "OR",
    "builtInControls": ["block"]
  }
}
```

#### Require Compliant Devices
```json
{
  "displayName": "Require Compliant or Hybrid Azure AD Joined Device",
  "state": "enabled",
  "conditions": {
    "users": {
      "includeUsers": ["All"],
      "excludeUsers": ["emergency-access-accounts"]
    },
    "applications": {
      "includeApplications": ["All"]
    }
  },
  "grantControls": {
    "operator": "OR",
    "builtInControls": ["compliantDevice", "domainJoinedDevice"]
  }
}
```

## Exchange Online Configuration Templates

### Organization Configuration
```powershell
# Exchange Online Organization Settings
Set-OrganizationConfig -DefaultPublicFolderMailbox $null `
  -PublicFoldersEnabled Remote `
  -ActivityBasedAuthenticationTimeoutEnabled $true `
  -ActivityBasedAuthenticationTimeoutInterval 06:00:00 `
  -ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled $true

# Anti-spam settings
Set-HostedContentFilterPolicy "Default" -BulkThreshold 6 `
  -SpamAction MoveToJmf `
  -HighConfidenceSpamAction Quarantine `
  -PhishSpamAction Quarantine `
  -BulkSpamAction MoveToJmf `
  -QuarantineRetentionPeriod 30

# Anti-malware settings
Set-MalwareFilterPolicy "Default" -Action DeleteMessage `
  -EnableFileFilter $true `
  -FileTypes @("ace","ani","app","docm","exe","jar","reg","scr","vbe","vbs") `
  -ZapEnabled $true
```

### Mail Flow Rules Template
```powershell
# External email warning
New-TransportRule -Name "External Email Warning" `
  -FromScope NotInOrganization `
  -SetHeaderName "X-MS-Exchange-Organization-ExternalEmailWarning" `
  -SetHeaderValue "This email originated from outside the organization" `
  -ExceptIfFromAddressContainsWords @("@[TRUSTED_DOMAIN].com")

# Block executable attachments
New-TransportRule -Name "Block Dangerous Attachments" `
  -AttachmentExtensionMatchesWords @("exe","scr","bat","cmd","com","pif","scf","vbs","js","jar","reg") `
  -RejectMessageReasonText "Executable attachments are not allowed" `
  -DeleteMessage $true

# Encrypt sensitive emails
New-TransportRule -Name "Encrypt Sensitive Emails" `
  -SubjectOrBodyContainsWords @("Confidential","SSN","Credit Card","Social Security") `
  -ApplyOME $true
```

### Retention Policy Template
```powershell
# Create retention policy
New-RetentionPolicy -Name "Corporate Retention Policy" `
  -RetentionPolicyTagLinks @(
    "Default 2 year move to archive",
    "Personal 1 year move to archive", 
    "1 Month Delete",
    "6 Month Delete",
    "1 Year Delete",
    "5 Year Delete",
    "Never Delete"
  )

# Apply to all mailboxes
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetentionPolicy "Corporate Retention Policy"
```

## Microsoft Teams Configuration Templates

### Teams Policies Template
```powershell
# Meeting policy
New-CsTeamsMeetingPolicy -Identity "StandardMeetingPolicy" `
  -AllowCloudRecording $true `
  -RecordingStorageMode OneDriveForBusiness `
  -AllowTranscription $true `
  -AllowPrivateMeetingScheduling $true `
  -AllowChannelMeetingScheduling $true `
  -AllowAnonymousUsersToStartMeeting $false `
  -AutoAdmittedUsers EveryoneInCompanyExcludingGuests

# Messaging policy
New-CsTeamsMessagingPolicy -Identity "StandardMessagingPolicy" `
  -AllowUserEditMessage $true `
  -AllowUserDeleteMessage $true `
  -AllowOwnerDeleteMessage $true `
  -AllowUserChat $true `
  -AllowRemoveUser $true `
  -ChannelsInChatListEnabledType DisabledUserOverride

# App setup policy
New-CsTeamsAppSetupPolicy -Identity "StandardAppSetupPolicy" `
  -AllowUserPinning $true `
  -AllowSideLoading $false `
  -PinnedApps @(
    @{Id="14d6962d-6eeb-4f48-8890-de55454bb136"}, # Tasks
    @{Id="com.microsoft.teamspace.tab.wiki"}, # Wiki
    @{Id="2a527703-1f6f-4559-a332-d8a7d288cd88"} # SharePoint
  )
```

### Teams Creation Template
```powershell
# Department teams template
$teamTemplate = @{
  "DisplayName" = "[DEPARTMENT] Team"
  "Description" = "Collaboration space for [DEPARTMENT] department"
  "Template" = "standard"
  "Visibility" = "Private"
  "Channels" = @(
    @{
      "DisplayName" = "General"
      "Description" = "General discussion and announcements"
    },
    @{
      "DisplayName" = "Projects"
      "Description" = "Project collaboration and updates"
    },
    @{
      "DisplayName" = "Resources"
      "Description" = "Shared resources and documentation"
    }
  )
}
```

## SharePoint Online Configuration Templates

### Tenant Configuration
```powershell
# SharePoint tenant settings
Set-SPOTenant -RequireAcceptingAccountMatchInvitedAccount $true `
  -SharingCapability ExternalUserAndGuestSharing `
  -DefaultSharingLinkType Internal `
  -DefaultLinkPermission Edit `
  -RequireAnonymousLinksExpireInDays 30 `
  -FileAnonymousLinkType Edit `
  -FolderAnonymousLinkType Edit `
  -NotifyOwnersWhenItemsReshared $true `
  -ShowPeoplePickerSuggestionsForGuestUsers $false

# Information Rights Management
Set-SPOTenant -IRMEnabled $true
```

### Site Template Configuration
```json
{
  "siteTemplate": {
    "title": "[DEPARTMENT] Site",
    "description": "Collaboration site for [DEPARTMENT] department",
    "template": "STS#3",
    "lcid": 1033,
    "webTemplate": "SITEPAGEPUBLISHING#0",
    "features": [
      "87294c72-f260-42f3-a41b-981a2ffce37a", // Group Work Lists
      "00bfea71-5932-4f9c-ad71-1557e5751100", // Web Parts
      "22a9ef51-737b-4ff2-9346-694633fe4416"  // Metadata Navigation
    ],
    "navigation": {
      "quickLaunch": [
        {"title": "Documents", "url": "/Shared Documents"},
        {"title": "Lists", "url": "/Lists"},
        {"title": "Site Contents", "url": "/_layouts/15/viewlsts.aspx"}
      ]
    }
  }
}
```

### Document Library Settings
```powershell
# Configure document library
$library = Get-PnPList -Identity "Documents"
Set-PnPList -Identity $library -EnableVersioning $true -MajorVersions 50 -MinorVersions 10
Set-PnPList -Identity $library -EnableContentTypes $true
Set-PnPList -Identity $library -EnableModeration $false

# Add content types
Add-PnPContentTypeToList -List $library -ContentType "Document" -DefaultContentType
```

## Security and Compliance Templates

### Microsoft Defender for Office 365 Configuration
```powershell
# Safe Attachments Policy
New-SafeAttachmentPolicy -Name "Corporate Safe Attachments" `
  -Action Block `
  -Enable $true `
  -Redirect $false

New-SafeAttachmentRule -Name "Corporate Safe Attachments Rule" `
  -SafeAttachmentPolicy "Corporate Safe Attachments" `
  -RecipientDomainIs "[DOMAIN].com" `
  -Enabled $true

# Safe Links Policy
New-SafeLinksPolicy -Name "Corporate Safe Links" `
  -IsEnabled $true `
  -TrackClicks $true `
  -ScanUrls $true `
  -EnableForInternalSenders $true `
  -DeliverMessageAfterScan $true

New-SafeLinksRule -Name "Corporate Safe Links Rule" `
  -SafeLinksPolicy "Corporate Safe Links" `
  -RecipientDomainIs "[DOMAIN].com" `
  -Enabled $true
```

### Data Loss Prevention Policies
```json
{
  "dlpPolicy": {
    "name": "Corporate Data Protection",
    "description": "Protect sensitive corporate information",
    "mode": "Enable",
    "locations": [
      {
        "name": "ExchangeOnline",
        "enabled": true
      },
      {
        "name": "SharePointOnline", 
        "enabled": true
      },
      {
        "name": "OneDriveForBusiness",
        "enabled": true
      },
      {
        "name": "TeamsChat",
        "enabled": true
      }
    ],
    "rules": [
      {
        "name": "Credit Card Protection",
        "conditions": {
          "contentContainsSensitiveInformation": [
            {
              "name": "Credit Card Number",
              "minCount": 1,
              "maxCount": 500
            }
          ]
        },
        "actions": [
          {
            "type": "BlockAccess",
            "settings": {
              "restrictAccess": true
            }
          },
          {
            "type": "NotifyUser", 
            "settings": {
              "policyTip": "This content contains credit card information and cannot be shared."
            }
          }
        ]
      }
    ]
  }
}
```

### Sensitivity Labels Template
```json
{
  "sensitivityLabels": [
    {
      "name": "Internal",
      "description": "Information intended for internal use within the organization",
      "color": "#0078d4",
      "settings": {
        "contentMarkingEnabled": true,
        "watermarkText": "Internal Use Only",
        "encryption": {
          "enabled": false
        }
      }
    },
    {
      "name": "Confidential", 
      "description": "Sensitive information requiring protection",
      "color": "#ca5010",
      "settings": {
        "contentMarkingEnabled": true,
        "watermarkText": "Confidential",
        "encryption": {
          "enabled": true,
          "permissionType": "preset",
          "presetName": "restrictedAccess"
        }
      }
    },
    {
      "name": "Highly Confidential",
      "description": "Most sensitive information requiring strict controls",
      "color": "#d13438", 
      "settings": {
        "contentMarkingEnabled": true,
        "watermarkText": "Highly Confidential",
        "encryption": {
          "enabled": true,
          "permissionType": "custom",
          "customPermissions": {
            "viewRightsOnly": true,
            "allowMacros": false,
            "allowPrint": false
          }
        }
      }
    }
  ]
}
```

## Power Platform Configuration Templates

### Environment Configuration
```json
{
  "environment": {
    "displayName": "[DEPARTMENT] Environment",
    "description": "Power Platform environment for [DEPARTMENT]",
    "environmentSku": "Production",
    "region": "unitedstates",
    "settings": {
      "isDefault": false,
      "canvasAppSharingEnabled": true,
      "flowSharingEnabled": true,
      "dataLossPreventionPolicies": "Enabled"
    }
  }
}
```

### Data Loss Prevention for Power Platform
```json
{
  "powerPlatformDlpPolicy": {
    "displayName": "Corporate Power Platform DLP",
    "environments": ["[ENVIRONMENT_ID]"],
    "connectorGroups": {
      "business": [
        "shared_office365",
        "shared_sharepointonline", 
        "shared_teams",
        "shared_outlook"
      ],
      "nonBusiness": [
        "shared_twitter",
        "shared_facebook",
        "shared_instagram"
      ],
      "blocked": [
        "shared_survey123",
        "shared_microsoftforms"
      ]
    }
  }
}
```

## Microsoft Viva Configuration Templates

### Viva Insights Settings
```json
{
  "vivaInsights": {
    "privacySettings": {
      "isInsightsEnabled": true,
      "isDashboardOptedOut": false,
      "isDigestEmailOptedOut": false
    },
    "managerSettings": {
      "isEnabled": true,
      "minimumGroupSize": 5
    },
    "meetingEffectivenessSettings": {
      "surveyEnabled": true,
      "meetingEffectivenessSurveyEnabled": true
    }
  }
}
```

### Viva Learning Configuration
```json
{
  "vivaLearning": {
    "settings": {
      "isEnabled": true,
      "learningContentSources": [
        {
          "name": "Microsoft Learn",
          "enabled": true
        },
        {
          "name": "LinkedIn Learning",
          "enabled": true
        },
        {
          "name": "SharePoint",
          "enabled": true
        }
      ]
    },
    "policies": [
      {
        "name": "All Users Learning Policy",
        "assignedUsers": "All",
        "settings": {
          "learningAppEnabled": true,
          "searchEnabled": true,
          "courseRecommendationsEnabled": true
        }
      }
    ]
  }
}
```

## Device Management Templates (Intune)

### Device Compliance Policy
```json
{
  "deviceCompliancePolicy": {
    "displayName": "Windows 10/11 Compliance Policy",
    "description": "Baseline compliance requirements for Windows devices",
    "platforms": ["windows10AndLater"],
    "settings": {
      "passwordRequired": true,
      "passwordMinimumLength": 8,
      "passwordRequiredType": "alphanumeric",
      "passwordMinutesOfInactivityBeforeLock": 15,
      "passwordExpirationDays": 90,
      "passwordPreviousPasswordBlockCount": 5,
      "osMinimumVersion": "10.0.19041",
      "osMaximumVersion": null,
      "mobileOsMinimumVersion": null,
      "mobileOsMaximumVersion": null,
      "earlyLaunchAntiMalwareDriverEnabled": true,
      "bitLockerEnabled": true,
      "secureBootEnabled": true,
      "codeIntegrityEnabled": true,
      "storageRequireEncryption": true,
      "activeFirewallRequired": true,
      "defenderEnabled": true,
      "defenderVersion": null,
      "signatureOutOfDate": false,
      "rtpEnabled": true,
      "antivirusRequired": true,
      "antiSpywareRequired": true
    }
  }
}
```

### App Protection Policy
```json
{
  "appProtectionPolicy": {
    "displayName": "Office 365 App Protection",
    "description": "Protect corporate data in Office mobile apps",
    "targetedAppManagementLevels": "unspecified",
    "apps": [
      "com.microsoft.office.outlook",
      "com.microsoft.office.word",
      "com.microsoft.office.excel",
      "com.microsoft.office.powerpoint",
      "com.microsoft.office.onenote",
      "com.microsoft.skydrive"
    ],
    "settings": {
      "dataBackup": "blocked",
      "dataCopyPaste": "blocked",
      "dataReceivedFromOtherApps": "managedAppsOnly",
      "dataSentToOtherApps": "managedAppsOnly",
      "saveAsBlocked": true,
      "allowedInboundDataTransferSources": "managedApps",
      "allowedOutboundDataTransferDestinations": "managedApps",
      "organizationalCredentialsRequired": true,
      "allowedOutboundClipboardSharingLevel": "managedAppsWithPasteIn",
      "allowedInboundClipboardSharingLevel": "managedApps",
      "dataEncryptionType": "whenDeviceLocked",
      "screenCaptureBlocked": true,
      "minimumRequiredAppVersion": null,
      "minimumWarningAppVersion": null,
      "minimumRequiredOsVersion": null,
      "minimumWarningOsVersion": null
    }
  }
}
```

## Automation and Scripting Templates

### PowerShell Module Installation Script
```powershell
# Install required PowerShell modules
$modules = @(
    "AzureAD",
    "ExchangeOnlineManagement", 
    "MicrosoftTeams",
    "PnP.PowerShell",
    "Microsoft.Graph",
    "MSOnline"
)

foreach ($module in $modules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    } else {
        Write-Host "$module already installed" -ForegroundColor Green
    }
}

Write-Host "All modules installed successfully!" -ForegroundColor Green
```

### Bulk User Creation Template
```powershell
# CSV template for bulk user creation
$csvTemplate = @"
DisplayName,UserPrincipalName,FirstName,LastName,Department,JobTitle,Office,Manager,License
John Smith,john.smith@company.com,John,Smith,IT,System Administrator,New York,jane.doe@company.com,SPE_E5
Jane Doe,jane.doe@company.com,Jane,Doe,IT,IT Manager,New York,,SPE_E5
"@

$csvTemplate | Out-File -FilePath "BulkUsers.csv" -Encoding UTF8

# Bulk user creation script
Import-Csv "BulkUsers.csv" | ForEach-Object {
    $passwordProfile = @{
        Password = "TempPassword123!"
        ForceChangePasswordNextSignIn = $true
    }
    
    New-AzureADUser -DisplayName $_.DisplayName `
        -UserPrincipalName $_.UserPrincipalName `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
        -Department $_.Department `
        -JobTitle $_.JobTitle `
        -PhysicalDeliveryOfficeName $_.Office `
        -AccountEnabled $true `
        -PasswordProfile $passwordProfile
}
```

## Deployment Checklist Templates

### Pre-Deployment Validation
```markdown
## Technical Prerequisites
- [ ] Azure AD tenant configured
- [ ] Custom domains added and verified  
- [ ] DNS records configured
- [ ] Network connectivity validated
- [ ] Firewall rules configured for Office 365 endpoints
- [ ] Client devices meet system requirements

## Administrative Setup
- [ ] Global administrator accounts created
- [ ] Emergency access accounts configured
- [ ] Administrative groups and roles assigned
- [ ] MFA enabled for all administrators
- [ ] Privileged Identity Management configured

## Security Baseline
- [ ] Conditional access policies created
- [ ] Baseline security policies applied
- [ ] Legacy authentication blocked
- [ ] Security defaults disabled (if using conditional access)
- [ ] Audit logging enabled

## Service Configuration  
- [ ] Exchange Online configured
- [ ] SharePoint Online settings applied
- [ ] Microsoft Teams policies created
- [ ] OneDrive for Business deployed
- [ ] Microsoft Defender for Office 365 enabled
```

These templates provide standardized, secure, and optimized configurations for Microsoft 365 enterprise deployments. Customize the placeholders and settings based on your organization's specific requirements and policies.