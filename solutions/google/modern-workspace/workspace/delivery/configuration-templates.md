# Google Workspace - Configuration Templates

This document provides standardized configuration templates and examples for Google Workspace deployment and management.

## Admin Console Configuration

### Organizational Unit Structure

```json
{
  "organizationalUnits": [
    {
      "name": "Corporate",
      "description": "Corporate departments and functions",
      "children": [
        {"name": "Executive", "description": "Executive leadership team"},
        {"name": "Finance", "description": "Finance and accounting"},
        {"name": "HR", "description": "Human resources"},
        {"name": "Legal", "description": "Legal department"}
      ]
    },
    {
      "name": "IT",
      "description": "Information technology division",
      "children": [
        {"name": "Development", "description": "Software development teams"},
        {"name": "Operations", "description": "IT operations and infrastructure"},
        {"name": "Security", "description": "Information security team"}
      ]
    }
  ]
}
```

### Security Policy Templates

#### Password Policy Configuration
```json
{
  "passwordPolicy": {
    "minimumLength": 12,
    "requireLowercase": true,
    "requireUppercase": true,
    "requireNumeric": true,
    "requireSpecialCharacter": true,
    "passwordReuse": {
      "preventReuse": true,
      "historySize": 24
    },
    "expiration": {
      "enabled": true,
      "maxAge": 90,
      "warningDays": 14
    }
  }
}
```

#### Two-Step Verification Template
```json
{
  "twoStepVerification": {
    "enforcement": "mandatory",
    "allowedMethods": [
      "authenticatorApp",
      "sms",
      "voiceCall",
      "backupCodes"
    ],
    "gracePeriod": 7,
    "exemptGroups": [],
    "requireStrongAuth": true
  }
}
```

## Gmail Configuration

### Email Routing Rules

```json
{
  "routingRules": [
    {
      "name": "External Email Warning",
      "condition": {
        "senderNotInDomain": true
      },
      "action": {
        "addHeader": "X-External-Email",
        "headerValue": "This email originated from outside the organization"
      }
    },
    {
      "name": "DLP Quarantine",
      "condition": {
        "containsSensitiveContent": true
      },
      "action": {
        "quarantine": true,
        "notifyAdmin": true
      }
    }
  ]
}
```

### Content Compliance Rules

```json
{
  "contentCompliance": [
    {
      "name": "SSN Detection",
      "description": "Detect Social Security Numbers",
      "conditions": [
        {
          "type": "content",
          "operator": "matches",
          "values": ["\\b\\d{3}-\\d{2}-\\d{4}\\b"]
        }
      ],
      "actions": [
        {
          "type": "modify",
          "action": "quarantine"
        },
        {
          "type": "notify",
          "recipients": ["compliance@company.com"]
        }
      ]
    }
  ]
}
```

## Google Drive Configuration

### Sharing Settings Template

```json
{
  "driveSharing": {
    "defaultVisibility": "domain",
    "externalSharing": {
      "enabled": false,
      "allowedDomains": ["partner.com", "vendor.com"],
      "requireWarning": true
    },
    "linkSharing": {
      "defaultAccess": "view",
      "allowAnonymous": false,
      "requireAuthentication": true
    },
    "downloadRestrictions": {
      "preventDownload": false,
      "preventPrint": false,
      "preventCopy": false
    }
  }
}
```

### Shared Drive Template

```json
{
  "sharedDrives": [
    {
      "name": "Finance Department",
      "restrictions": {
        "domainUsersOnly": true,
        "driveMembersOnly": true,
        "adminManagedRestrictions": true
      },
      "capabilities": {
        "canAddChildren": true,
        "canDeleteChildren": true,
        "canListChildren": true,
        "canReadRevisions": true
      },
      "members": [
        {
          "emailAddress": "finance-team@company.com",
          "role": "organizer"
        },
        {
          "emailAddress": "cfo@company.com",
          "role": "fileOrganizer"
        }
      ]
    }
  ]
}
```

## Calendar Configuration

### Resource Calendar Template

```json
{
  "calendarResources": [
    {
      "resourceId": "conference-room-a",
      "resourceName": "Conference Room A",
      "capacity": 12,
      "features": ["video-conferencing", "projector", "whiteboard"],
      "floorName": "2nd Floor",
      "buildingId": "main-office",
      "resourceCategory": "CONFERENCE_ROOM",
      "bookingWindow": {
        "advanceBookingDays": 90,
        "minimumNoticeDays": 0
      },
      "autoAccept": true
    },
    {
      "resourceId": "company-car-01",
      "resourceName": "Company Vehicle 01",
      "resourceDescription": "Honda Accord - License: ABC123",
      "resourceCategory": "OTHER",
      "bookingWindow": {
        "advanceBookingDays": 30,
        "minimumNoticeDays": 1
      },
      "autoAccept": false,
      "approverEmail": "fleet-manager@company.com"
    }
  ]
}
```

### Calendar Sharing Policies

```json
{
  "calendarSharing": {
    "defaultSharingScope": "domain",
    "externalSharing": {
      "enabled": true,
      "requireApproval": true,
      "allowedDomains": ["partner.com"]
    },
    "resourceBooking": {
      "requireApproval": false,
      "allowConflicts": false,
      "autoDeclineConflicts": true
    }
  }
}
```

## Mobile Device Management

### Android Device Policy

```json
{
  "androidPolicy": {
    "deviceOwnerMode": false,
    "workProfileMode": true,
    "passwordRequirements": {
      "minimumLength": 8,
      "requireNumeric": true,
      "requireUppercase": true,
      "maxInactivityTimeSeconds": 900
    },
    "applications": {
      "installUnknownSources": false,
      "allowedApplications": [
        "com.google.android.gm",
        "com.google.android.calendar",
        "com.google.android.apps.docs"
      ]
    },
    "security": {
      "encryptionRequired": true,
      "screenLockRequired": true,
      "biometricAuthentication": "allowed"
    }
  }
}
```

### iOS Device Policy

```json
{
  "iosPolicy": {
    "supervisionRequired": false,
    "restrictions": {
      "allowAppInstallation": true,
      "allowCamera": true,
      "allowCloudBackup": false,
      "allowScreenshot": true
    },
    "passwordPolicy": {
      "minimumLength": 8,
      "requireAlphanumeric": true,
      "maxInactivityMinutes": 15,
      "maxFailedAttempts": 10
    },
    "managedApps": [
      {
        "bundleId": "com.google.Gmail",
        "required": true
      },
      {
        "bundleId": "com.google.calendar",
        "required": true
      }
    ]
  }
}
```

## Data Loss Prevention (DLP)

### Content Inspection Rules

```json
{
  "dlpRules": [
    {
      "name": "Credit Card Detection",
      "description": "Detect credit card numbers in content",
      "trigger": {
        "contentConditions": [
          {
            "type": "creditCardNumber",
            "minCount": 1
          }
        ]
      },
      "actions": [
        {
          "type": "restrict",
          "restriction": "externalSharing"
        },
        {
          "type": "notify",
          "recipients": ["dlp-team@company.com"]
        }
      ],
      "scope": {
        "applications": ["gmail", "drive", "sites"]
      }
    },
    {
      "name": "Confidential Document Protection",
      "description": "Protect documents marked as confidential",
      "trigger": {
        "contentConditions": [
          {
            "type": "textMatch",
            "operator": "contains",
            "values": ["CONFIDENTIAL", "RESTRICTED"]
          }
        ]
      },
      "actions": [
        {
          "type": "restrict",
          "restriction": "externalSharing"
        },
        {
          "type": "watermark",
          "text": "Confidential - Internal Use Only"
        }
      ]
    }
  ]
}
```

## Groups and Group Settings

### Google Groups Configuration

```json
{
  "groups": [
    {
      "email": "all-company@company.com",
      "name": "All Company",
      "description": "All company employees",
      "settings": {
        "whoCanJoin": "INVITED_CAN_JOIN",
        "whoCanViewMembership": "ALL_MEMBERS_CAN_VIEW",
        "whoCanPostMessage": "ALL_MANAGERS_CAN_POST",
        "archiveOnly": false,
        "allowExternalMembers": false
      }
    },
    {
      "email": "it-support@company.com",
      "name": "IT Support",
      "description": "IT Support team distribution list",
      "settings": {
        "whoCanJoin": "CAN_REQUEST_TO_JOIN",
        "whoCanViewMembership": "ALL_MEMBERS_CAN_VIEW",
        "whoCanPostMessage": "ANYONE_CAN_POST",
        "replyTo": "REPLY_TO_MANAGERS",
        "messageModerationLevel": "MODERATE_NON_MEMBERS"
      }
    }
  ]
}
```

## Single Sign-On (SSO) Configuration

### SAML Configuration Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<md:EntityDescriptor
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    entityID="google.com/a/company.com">
  
  <md:SPSSODescriptor
      AuthnRequestsSigned="false"
      WantAssertionsSigned="true"
      protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    
    <md:NameIDFormat>
      urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
    </md:NameIDFormat>
    
    <md:AssertionConsumerService
        Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
        Location="https://www.google.com/a/company.com/acs"
        index="1" />
        
  </md:SPSSODescriptor>
</md:EntityDescriptor>
```

### OIDC Configuration

```json
{
  "oidcConfiguration": {
    "clientId": "your-client-id",
    "clientSecret": "your-client-secret",
    "issuer": "https://accounts.google.com",
    "authorizationEndpoint": "https://accounts.google.com/o/oauth2/v2/auth",
    "tokenEndpoint": "https://oauth2.googleapis.com/token",
    "userInfoEndpoint": "https://openidconnect.googleapis.com/v1/userinfo",
    "scopes": ["openid", "email", "profile"],
    "responseType": "code",
    "responseMode": "query"
  }
}
```

## Monitoring and Reporting

### Alert Configuration

```json
{
  "alerts": [
    {
      "name": "Suspicious Login Activity",
      "description": "Alert on suspicious login patterns",
      "conditions": [
        {
          "type": "login_failure_rate",
          "threshold": 10,
          "timeWindow": "5m"
        },
        {
          "type": "unusual_location",
          "enabled": true
        }
      ],
      "notifications": [
        {
          "type": "email",
          "recipients": ["security-team@company.com"]
        }
      ]
    },
    {
      "name": "Data Export Alert",
      "description": "Alert on large data exports",
      "conditions": [
        {
          "type": "data_export_volume",
          "threshold": "1GB",
          "timeWindow": "1h"
        }
      ],
      "notifications": [
        {
          "type": "email",
          "recipients": ["dlp-team@company.com"]
        }
      ]
    }
  ]
}
```

### Custom Reports

```json
{
  "customReports": [
    {
      "name": "Weekly Usage Summary",
      "schedule": "weekly",
      "applications": ["gmail", "drive", "calendar", "meet"],
      "metrics": [
        "active_users",
        "storage_usage",
        "collaboration_activity"
      ],
      "recipients": ["admin@company.com"]
    },
    {
      "name": "Security Incident Report",
      "schedule": "monthly",
      "content": [
        "security_alerts",
        "policy_violations",
        "access_reviews"
      ],
      "recipients": ["security-team@company.com"]
    }
  ]
}
```

## API Configuration

### Service Account Setup

```json
{
  "serviceAccounts": [
    {
      "name": "google-workspace-admin",
      "description": "Service account for administrative operations",
      "scopes": [
        "https://www.googleapis.com/auth/admin.directory.user",
        "https://www.googleapis.com/auth/admin.directory.group",
        "https://www.googleapis.com/auth/admin.directory.orgunit",
        "https://www.googleapis.com/auth/admin.reports.audit.readonly"
      ],
      "domainWideAuthorization": true,
      "impersonationEmail": "admin@company.com"
    }
  ]
}
```

### OAuth Configuration

```json
{
  "oauthConfiguration": {
    "allowedApplications": [
      {
        "clientId": "trusted-app-client-id",
        "name": "Trusted Business Application",
        "scopes": [
          "https://www.googleapis.com/auth/userinfo.email",
          "https://www.googleapis.com/auth/userinfo.profile"
        ],
        "trusted": true
      }
    ],
    "risky_apps_settings": {
      "access_to_risky_apps": "DISALLOW",
      "access_to_risky_apps_whitelist": []
    }
  }
}
```

---

**Note**: Replace placeholder values (company.com, email addresses, etc.) with actual organizational information before implementation. Always test configurations in a non-production environment first.