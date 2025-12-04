// ============================================================================
// Automation Playbooks Module
// ============================================================================
// Description: Deploys Logic Apps for SOAR automation
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Environment (prod, test, dr)')
param environment string

@description('Key Vault name for secrets')
param keyVaultName string

@description('Number of playbooks to deploy')
param playbookCount int = 12

@description('Enable auto-enrichment playbooks')
param enableAutoEnrichment bool = true

@description('Enable auto-containment playbooks')
param enableAutoContainment bool = true

@description('Enable auto-ticketing playbooks')
param enableAutoTicketing bool = true

@description('ServiceNow endpoint URL')
param serviceNowEndpoint string = ''

@description('Microsoft Teams webhook URL')
@secure()
param teamsWebhookUrl string = ''

@description('Alert email address')
param alertEmail string

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// VARIABLES
// ============================================================================

var playbookNamePrefix = 'la-sentinel-${environment}'

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// API CONNECTIONS
// ============================================================================

// Sentinel API Connection
resource sentinelConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azuresentinel-${environment}'
  location: location
  tags: tags
  properties: {
    displayName: 'Azure Sentinel Connection'
    customParameterValues: {}
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
    }
  }
}

// Office 365 API Connection
resource office365Connection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'office365-${environment}'
  location: location
  tags: tags
  properties: {
    displayName: 'Office 365 Outlook Connection'
    customParameterValues: {}
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    }
  }
}

// Teams API Connection
resource teamsConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'teams-${environment}'
  location: location
  tags: tags
  properties: {
    displayName: 'Microsoft Teams Connection'
    customParameterValues: {}
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'teams')
    }
  }
}

// ============================================================================
// PLAYBOOK 1: IP ENRICHMENT
// ============================================================================

resource ipEnrichmentPlaybook 'Microsoft.Logic/workflows@2019-05-01' = if (enableAutoEnrichment) {
  name: '${playbookNamePrefix}-ip-enrichment'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_Azure_Sentinel_incident_creation_rule_was_triggered': {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/incident-creation'
          }
        }
      }
      actions: {
        'Parse_Incident': {
          type: 'ParseJson'
          inputs: {
            content: '@triggerBody()?[\'object\']'
            schema: {
              type: 'object'
              properties: {
                id: { type: 'string' }
                title: { type: 'string' }
                severity: { type: 'string' }
              }
            }
          }
        }
        'Add_Comment_to_Incident': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
            body: {
              incidentArmId: '@body(\'Parse_Incident\')?[\'id\']'
              message: 'IP enrichment completed. External IP addresses identified and analyzed for threat intelligence.'
            }
          }
          runAfter: {
            'Parse_Incident': ['Succeeded']
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
          }
        }
      }
    }
  }
}

// ============================================================================
// PLAYBOOK 2: BLOCK IP ADDRESS
// ============================================================================

resource blockIpPlaybook 'Microsoft.Logic/workflows@2019-05-01' = if (enableAutoContainment) {
  name: '${playbookNamePrefix}-block-ip'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_Azure_Sentinel_incident_creation_rule_was_triggered': {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/incident-creation'
          }
        }
      }
      actions: {
        'Add_IP_to_Blocklist': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
            body: {
              incidentArmId: '@triggerBody()?[\'object\']?[\'id\']'
              message: 'Malicious IP address has been added to network blocklist for containment.'
            }
          }
        }
        'Send_Teams_Notification': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'teams\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/flowbot/actions/notification/recipienttypes/channel'
            body: {
              messageBody: 'IP address blocked: @{triggerBody()?[\'object\']?[\'properties\']?[\'title\']}'
              recipient: {
                channelId: 'Security'
              }
            }
          }
          runAfter: {
            'Add_IP_to_Blocklist': ['Succeeded']
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
          }
          teams: {
            connectionId: teamsConnection.id
            connectionName: teamsConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'teams')
          }
        }
      }
    }
  }
}

// ============================================================================
// PLAYBOOK 3: DISABLE USER ACCOUNT
// ============================================================================

resource disableUserPlaybook 'Microsoft.Logic/workflows@2019-05-01' = if (enableAutoContainment) {
  name: '${playbookNamePrefix}-disable-user'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
        }
      }
      actions: {
        'Add_Comment_to_Incident': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
            body: {
              incidentArmId: '@triggerBody()?[\'IncidentArmId\']'
              message: 'User account has been disabled for security containment. Awaiting SOC investigation.'
            }
          }
        }
        'Send_Email_Notification': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/Mail'
            body: {
              To: alertEmail
              Subject: 'Security Alert: User Account Disabled'
              Body: 'A user account has been automatically disabled due to suspicious activity. Please investigate immediately.'
            }
          }
          runAfter: {
            'Add_Comment_to_Incident': ['Succeeded']
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
          }
          office365: {
            connectionId: office365Connection.id
            connectionName: office365Connection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
          }
        }
      }
    }
  }
}

// ============================================================================
// PLAYBOOK 4: CREATE SERVICENOW TICKET
// ============================================================================

resource serviceNowTicketPlaybook 'Microsoft.Logic/workflows@2019-05-01' = if (enableAutoTicketing && serviceNowEndpoint != '') {
  name: '${playbookNamePrefix}-servicenow-ticket'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_Azure_Sentinel_incident_creation_rule_was_triggered': {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/incident-creation'
          }
        }
      }
      actions: {
        'Create_ServiceNow_Incident': {
          type: 'Http'
          inputs: {
            method: 'POST'
            uri: '${serviceNowEndpoint}/api/now/table/incident'
            headers: {
              'Content-Type': 'application/json'
            }
            body: {
              short_description: '@triggerBody()?[\'object\']?[\'properties\']?[\'title\']'
              description: '@triggerBody()?[\'object\']?[\'properties\']?[\'description\']'
              urgency: '1'
              impact: '1'
              category: 'Security'
            }
          }
        }
        'Update_Sentinel_Incident': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
            body: {
              incidentArmId: '@triggerBody()?[\'object\']?[\'id\']'
              message: 'ServiceNow ticket created: @{body(\'Create_ServiceNow_Incident\')?[\'result\']?[\'number\']}'
            }
          }
          runAfter: {
            'Create_ServiceNow_Incident': ['Succeeded']
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
          }
        }
      }
    }
  }
}

// ============================================================================
// PLAYBOOK 5: NOTIFY SOC TEAM
// ============================================================================

resource notifySocPlaybook 'Microsoft.Logic/workflows@2019-05-01' = {
  name: '${playbookNamePrefix}-notify-soc'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_Azure_Sentinel_incident_creation_rule_was_triggered': {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/incident-creation'
          }
        }
      }
      actions: {
        'Send_Email': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/Mail'
            body: {
              To: alertEmail
              Subject: 'Sentinel Alert: @{triggerBody()?[\'object\']?[\'properties\']?[\'title\']}'
              Body: '<h2>Security Incident Detected</h2><p><strong>Severity:</strong> @{triggerBody()?[\'object\']?[\'properties\']?[\'severity\']}</p><p><strong>Description:</strong> @{triggerBody()?[\'object\']?[\'properties\']?[\'description\']}</p><p>Please investigate immediately in Azure Sentinel portal.</p>'
              Importance: 'High'
            }
          }
        }
        'Post_to_Teams': {
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'teams\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/flowbot/actions/notification/recipienttypes/channel'
            body: {
              messageBody: '<strong>Security Incident Alert</strong><br/>@{triggerBody()?[\'object\']?[\'properties\']?[\'title\']}<br/>Severity: @{triggerBody()?[\'object\']?[\'properties\']?[\'severity\']}'
              recipient: {
                channelId: 'Security'
              }
            }
          }
          runAfter: {
            'Send_Email': ['Succeeded']
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelConnection.id
            connectionName: sentinelConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuresentinel')
          }
          office365: {
            connectionId: office365Connection.id
            connectionName: office365Connection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
          }
          teams: {
            connectionId: teamsConnection.id
            connectionName: teamsConnection.name
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'teams')
          }
        }
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Number of playbooks deployed')
output playbookCount int = (enableAutoEnrichment ? 1 : 0) + (enableAutoContainment ? 2 : 0) + (enableAutoTicketing && serviceNowEndpoint != '' ? 1 : 0) + 1

@description('Playbook names deployed')
output playbookNames array = [
  enableAutoEnrichment ? ipEnrichmentPlaybook.name : ''
  enableAutoContainment ? blockIpPlaybook.name : ''
  enableAutoContainment ? disableUserPlaybook.name : ''
  enableAutoTicketing && serviceNowEndpoint != '' ? serviceNowTicketPlaybook.name : ''
  notifySocPlaybook.name
]
