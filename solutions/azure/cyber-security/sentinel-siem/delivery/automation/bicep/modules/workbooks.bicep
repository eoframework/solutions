// ============================================================================
// Workbooks Module
// ============================================================================
// Description: Deploys Sentinel workbooks for visualization and monitoring
// Version: 1.0.0
// ============================================================================

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Environment (prod, test, dr)')
param environment string

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// EXISTING WORKSPACE REFERENCE
// ============================================================================

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

// ============================================================================
// WORKBOOK 1: SECURITY OPERATIONS OVERVIEW
// ============================================================================

resource securityOverviewWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('security-overview-${environment}')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'Security Operations Overview - ${environment}'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## Security Operations Overview\n\nComprehensive view of security posture and incident response metrics.'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityIncident | where TimeGenerated > ago(24h) | summarize Count = count() by Severity | order by Count desc'
            size: 1
            title: 'Incidents by Severity (Last 24 Hours)'
            timeContext: {
              durationMs: 86400000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'piechart'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityIncident | where TimeGenerated > ago(7d) | make-series Count = count() default = 0 on TimeGenerated from ago(7d) to now() step 1d by Status'
            size: 1
            title: 'Incident Trend (Last 7 Days)'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'timechart'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityAlert | where TimeGenerated > ago(24h) | summarize Count = count() by AlertSeverity | order by Count desc'
            size: 1
            title: 'Alerts by Severity (Last 24 Hours)'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'barchart'
          }
        }
      ]
    })
    category: 'sentinel'
    sourceId: workspace.id
  }
}

// ============================================================================
// WORKBOOK 2: THREAT INTELLIGENCE
// ============================================================================

resource threatIntelWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('threat-intel-${environment}')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'Threat Intelligence Dashboard - ${environment}'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## Threat Intelligence Dashboard\n\nMonitor threat indicators and intelligence feeds.'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'ThreatIntelligenceIndicator | where TimeGenerated > ago(7d) | summarize Count = count() by ThreatType | order by Count desc'
            size: 1
            title: 'Threat Indicators by Type'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'piechart'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'ThreatIntelligenceIndicator | where TimeGenerated > ago(30d) | where ConfidenceScore > 70 | summarize Count = count() by Source | order by Count desc | take 10'
            size: 1
            title: 'Top Threat Intelligence Sources'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'table'
          }
        }
      ]
    })
    category: 'sentinel'
    sourceId: workspace.id
  }
}

// ============================================================================
// WORKBOOK 3: USER AND ENTITY BEHAVIOR ANALYTICS
// ============================================================================

resource uebaWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('ueba-${environment}')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'User and Entity Behavior Analytics - ${environment}'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## User and Entity Behavior Analytics\n\nMonitor anomalous user behavior and entity activities.'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'BehaviorAnalytics | where TimeGenerated > ago(24h) | summarize Count = count() by UserPrincipalName | order by Count desc | take 10'
            size: 1
            title: 'Top Users with Behavioral Anomalies'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'table'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SigninLogs | where TimeGenerated > ago(24h) | where ResultType != "0" | summarize FailedAttempts = count() by UserPrincipalName, IPAddress | where FailedAttempts > 5 | order by FailedAttempts desc'
            size: 1
            title: 'Users with Failed Login Attempts'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'table'
          }
        }
      ]
    })
    category: 'sentinel'
    sourceId: workspace.id
  }
}

// ============================================================================
// WORKBOOK 4: INCIDENT RESPONSE METRICS
// ============================================================================

resource incidentMetricsWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('incident-metrics-${environment}')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'Incident Response Metrics - ${environment}'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## Incident Response Metrics\n\nTrack MTTD, MTTR, and response efficiency.'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityIncident | where TimeGenerated > ago(30d) | extend DetectionTime = TimeGenerated | extend ResolutionTime = ClosedTime | extend ResponseTime = datetime_diff(\'minute\', ResolutionTime, DetectionTime) | where ResponseTime > 0 | summarize AvgMTTR = avg(ResponseTime), MedianMTTR = percentile(ResponseTime, 50) by bin(TimeGenerated, 1d)'
            size: 1
            title: 'Mean Time to Respond (MTTR) Trend'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'linechart'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityIncident | where TimeGenerated > ago(7d) | summarize Total = count(), Open = countif(Status == "New" or Status == "Active"), Closed = countif(Status == "Closed") by bin(TimeGenerated, 1d)'
            size: 1
            title: 'Incident Status Trend'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'linechart'
          }
        }
      ]
    })
    category: 'sentinel'
    sourceId: workspace.id
  }
}

// ============================================================================
// WORKBOOK 5: DATA CONNECTORS HEALTH
// ============================================================================

resource dataConnectorHealthWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('connector-health-${environment}')
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'Data Connectors Health - ${environment}'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '## Data Connectors Health\n\nMonitor data ingestion and connector status.'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'Usage | where TimeGenerated > ago(24h) | summarize DataVolume = sum(Quantity) by DataType | order by DataVolume desc | take 10'
            size: 1
            title: 'Top Data Sources by Volume (Last 24h)'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'barchart'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'Heartbeat | where TimeGenerated > ago(1h) | summarize LastHeartbeat = max(TimeGenerated) by Computer | where LastHeartbeat < ago(15m) | project Computer, LastHeartbeat, MinutesSinceLastHeartbeat = datetime_diff(\'minute\', now(), LastHeartbeat)'
            size: 1
            title: 'Agents with Delayed Heartbeat'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            visualization: 'table'
          }
        }
      ]
    })
    category: 'sentinel'
    sourceId: workspace.id
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Number of workbooks deployed')
output workbookCount int = 5

@description('Workbook names')
output workbookNames array = [
  securityOverviewWorkbook.name
  threatIntelWorkbook.name
  uebaWorkbook.name
  incidentMetricsWorkbook.name
  dataConnectorHealthWorkbook.name
]
