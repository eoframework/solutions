# Configuration Templates - Cisco AI Network Analytics

## Overview

This document provides configuration templates and examples for deploying Cisco AI Network Analytics solutions. These templates cover DNA Center, Catalyst Center, ThousandEyes, and integration configurations.

## Template Structure

Each configuration template includes:
- **Purpose**: What the configuration accomplishes
- **Prerequisites**: Required setup steps
- **Configuration**: Step-by-step instructions
- **Validation**: How to verify successful deployment
- **Troubleshooting**: Common issues and solutions

## DNA Center Configuration Templates

### 1. Initial DNA Center Setup

**Purpose**: Basic DNA Center deployment with AI analytics enabled

**Prerequisites**:
- DNA Center 2.3.7+ installed
- Network devices discovered and managed
- Appropriate licensing (DNA Advantage)

**Configuration**:

```yaml
# DNA Center System Settings
system_settings:
  ai_analytics: 
    enabled: true
    data_retention_days: 90
    anomaly_detection: true
    predictive_analytics: true
  
  assurance_settings:
    network_insights: enabled
    wireless_health: enabled
    application_health: enabled
    client_health: enabled
  
  automation:
    eem_scripts: enabled
    python_scripts: enabled
    ansible_integration: enabled
```

**REST API Configuration**:

```bash
# Enable AI Network Analytics via API
curl -X POST "https://dnac.company.com/dna/intent/api/v1/ai-analytics/settings" \
  -H "X-Auth-Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "aiAnalytics": {
      "enabled": true,
      "anomalyDetection": true,
      "predictiveAnalytics": true,
      "dataRetentionDays": 90
    }
  }'
```

### 2. Assurance Policy Configuration

**Purpose**: Configure AI-driven assurance policies for network monitoring

```json
{
  "assurancePolicies": [
    {
      "name": "Critical Network Health",
      "description": "AI-powered monitoring for critical network infrastructure",
      "scope": "global",
      "rules": [
        {
          "metric": "interface_utilization",
          "threshold": 80,
          "action": "alert_and_analyze",
          "aiEnabled": true
        },
        {
          "metric": "cpu_utilization", 
          "threshold": 75,
          "action": "predictive_alert",
          "aiEnabled": true
        },
        {
          "metric": "memory_utilization",
          "threshold": 85,
          "action": "automated_remediation",
          "aiEnabled": true
        }
      ],
      "aiSettings": {
        "anomalyDetection": true,
        "baselineAdjustment": "automatic",
        "sensitivity": "medium"
      }
    }
  ]
}
```

### 3. AI Analytics Dashboard Configuration

**Purpose**: Custom dashboard for AI network insights

```yaml
dashboard_config:
  name: "AI Network Analytics Dashboard"
  widgets:
    - type: "ai_insights_summary"
      position: {row: 1, col: 1, width: 6, height: 3}
      settings:
        show_predictions: true
        show_anomalies: true
        time_range: "24h"
    
    - type: "predictive_alerts"
      position: {row: 1, col: 7, width: 6, height: 3}
      settings:
        severity_filter: ["high", "critical"]
        show_recommendations: true
    
    - type: "network_health_trends"
      position: {row: 4, col: 1, width: 12, height: 4}
      settings:
        ai_enhanced: true
        show_baseline: true
        prediction_window: "7d"
```

## Catalyst Center Configuration Templates

### 1. Cloud Analytics Setup

**Purpose**: Enable cloud-based AI analytics and insights

```yaml
catalyst_center_config:
  cloud_connection:
    enabled: true
    data_upload: true
    ai_insights: true
  
  analytics_settings:
    network_insights: 
      enabled: true
      ai_powered: true
      data_sources: ["wireless", "switching", "routing"]
    
    client_analytics:
      enabled: true
      behavior_analysis: true
      anomaly_detection: true
    
    application_analytics:
      enabled: true
      performance_optimization: true
      ai_recommendations: true
```

**API Configuration**:

```bash
# Configure Catalyst Center AI Analytics
curl -X PUT "https://catalyst-center.company.com/api/v1/analytics/config" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "aiAnalytics": {
      "enabled": true,
      "cloudInsights": true,
      "predictiveAnalytics": true,
      "anomalyDetection": {
        "enabled": true,
        "sensitivity": "medium",
        "learningPeriod": 30
      }
    }
  }'
```

### 2. AI Policy Templates

**Purpose**: AI-driven network policies for automated optimization

```json
{
  "aiPolicies": [
    {
      "name": "Intelligent QoS Optimization",
      "type": "qos_ai",
      "scope": "enterprise",
      "settings": {
        "autoAdjustment": true,
        "learningEnabled": true,
        "optimizationGoals": [
          "minimize_latency",
          "maximize_throughput",
          "ensure_sla_compliance"
        ]
      },
      "triggers": [
        {
          "condition": "application_performance_degradation",
          "action": "optimize_qos_policy",
          "aiDecision": true
        }
      ]
    },
    {
      "name": "Predictive Capacity Management",
      "type": "capacity_ai",
      "scope": "wireless",
      "settings": {
        "predictiveScaling": true,
        "capacityThresholds": {
          "warning": 70,
          "critical": 85,
          "predictive": 90
        },
        "autoProvisioning": true
      }
    }
  ]
}
```

## ThousandEyes Configuration Templates

### 1. Internet Intelligence Integration

**Purpose**: Integrate ThousandEyes with DNA Center for comprehensive visibility

```yaml
thousandeyes_integration:
  connection:
    api_endpoint: "https://api.thousandeyes.com/v6"
    oauth_token: "${THOUSANDEYES_TOKEN}"
    sync_interval: "5m"
  
  test_configurations:
    - name: "Critical Application Monitoring"
      type: "http-server"
      targets: 
        - "app1.company.com"
        - "app2.company.com" 
      interval: 60
      agents: ["cloud", "enterprise"]
      ai_analysis: true
    
    - name: "Network Path Analysis"
      type: "agent-to-agent"
      agents: ["branch_offices"]
      interval: 120
      ai_insights: true
      dnac_integration: true
```

### 2. AI-Enhanced Alerting

**Purpose**: Intelligent alerting based on ThousandEyes data and AI analysis

```json
{
  "alertRules": [
    {
      "name": "AI-Predicted Performance Degradation",
      "description": "ML-based prediction of application performance issues",
      "expression": "ai_prediction(http_response_time) > baseline * 1.5",
      "notifications": [
        {
          "type": "webhook",
          "url": "https://dnac.company.com/api/alerts",
          "method": "POST"
        }
      ],
      "aiSettings": {
        "predictionWindow": "15m",
        "confidence": 0.85,
        "includeRootCause": true
      }
    }
  ]
}
```

## Crosswork Integration Templates

### 1. Network Automation Configuration

**Purpose**: AI-driven network automation workflows

```yaml
crosswork_config:
  automation_workflows:
    - name: "Predictive Maintenance Workflow"
      trigger: "ai_anomaly_detected"
      actions:
        - collect_diagnostics
        - analyze_with_ai
        - recommend_actions
        - auto_remediate_if_safe
      
    - name: "Capacity Optimization Workflow"
      trigger: "capacity_prediction_alert"
      actions:
        - analyze_traffic_patterns
        - predict_growth_trends
        - recommend_upgrades
        - schedule_maintenance
  
  ai_services:
    enabled: true
    models:
      - anomaly_detection
      - capacity_prediction
      - root_cause_analysis
```

## Integration Configuration Templates

### 1. Multi-Platform Data Correlation

**Purpose**: Correlate data across DNA Center, Catalyst Center, and ThousandEyes

```yaml
data_correlation:
  sources:
    - name: "dna_center"
      endpoint: "https://dnac.company.com/api/v1"
      data_types: ["device_health", "interface_stats", "client_data"]
    
    - name: "catalyst_center"
      endpoint: "https://catalyst.company.com/api/v1"
      data_types: ["wireless_insights", "application_health"]
    
    - name: "thousandeyes"
      endpoint: "https://api.thousandeyes.com/v6"
      data_types: ["network_tests", "bgp_monitoring", "dns_monitoring"]
  
  correlation_rules:
    - name: "End-to-End Performance Correlation"
      sources: ["dna_center", "thousandeyes"]
      ai_analysis: true
      output: "unified_performance_view"
```

### 2. AI Model Configuration

**Purpose**: Configure and tune AI models for network analytics

```json
{
  "aiModels": {
    "anomalyDetection": {
      "type": "unsupervised_learning",
      "algorithm": "isolation_forest",
      "parameters": {
        "contamination": 0.1,
        "max_samples": "auto",
        "n_estimators": 100
      },
      "training": {
        "data_sources": ["dna_center", "catalyst_center"],
        "feature_selection": "auto",
        "validation_split": 0.2
      }
    },
    "capacityPrediction": {
      "type": "time_series_forecasting",
      "algorithm": "lstm",
      "parameters": {
        "sequence_length": 168,
        "prediction_horizon": 24,
        "hidden_units": 50
      },
      "training": {
        "historical_data_weeks": 12,
        "update_frequency": "weekly"
      }
    },
    "rootCauseAnalysis": {
      "type": "graph_neural_network",
      "algorithm": "gat",
      "parameters": {
        "attention_heads": 8,
        "hidden_dim": 64,
        "num_layers": 3
      }
    }
  }
}
```

## Security and Compliance Templates

### 1. Security Configuration

**Purpose**: Secure AI analytics deployment with proper access controls

```yaml
security_config:
  authentication:
    method: "oauth2"
    token_expiry: "24h"
    refresh_enabled: true
  
  authorization:
    rbac_enabled: true
    roles:
      - name: "ai_admin"
        permissions: ["configure_ai", "view_models", "manage_policies"]
      - name: "ai_operator" 
        permissions: ["view_insights", "acknowledge_alerts"]
      - name: "ai_viewer"
        permissions: ["view_dashboards", "export_reports"]
  
  data_protection:
    encryption_at_rest: true
    encryption_in_transit: true
    pii_anonymization: true
    data_retention_policy: "90_days"
```

### 2. Compliance Configuration

**Purpose**: Ensure compliance with regulatory requirements

```yaml
compliance_settings:
  frameworks:
    - name: "SOC2"
      controls:
        - audit_logging: enabled
        - access_reviews: quarterly
        - data_classification: automatic
    
    - name: "GDPR"
      controls:
        - data_anonymization: enabled
        - right_to_deletion: automated
        - consent_management: tracked
  
  audit_configuration:
    log_retention: "7_years"
    real_time_monitoring: true
    automated_reporting: true
```

## Validation Commands

### DNA Center Validation

```bash
# Verify AI Analytics Status
curl -X GET "https://dnac.company.com/dna/intent/api/v1/ai-analytics/status" \
  -H "X-Auth-Token: $TOKEN"

# Check Assurance Policies
curl -X GET "https://dnac.company.com/dna/intent/api/v1/assurance/policies" \
  -H "X-Auth-Token: $TOKEN"
```

### Catalyst Center Validation

```bash
# Verify Analytics Configuration
curl -X GET "https://catalyst-center.company.com/api/v1/analytics/status" \
  -H "Authorization: Bearer $TOKEN"

# Check AI Model Status
curl -X GET "https://catalyst-center.company.com/api/v1/ai/models/status" \
  -H "Authorization: Bearer $TOKEN"
```

### ThousandEyes Validation

```bash
# Verify Integration Status
curl -X GET "https://api.thousandeyes.com/v6/status.json" \
  -H "Authorization: Bearer $THOUSANDEYES_TOKEN"

# Check Test Configuration
curl -X GET "https://api.thousandeyes.com/v6/tests.json" \
  -H "Authorization: Bearer $THOUSANDEYES_TOKEN"
```

## Troubleshooting Quick Reference

### Common Configuration Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| AI Analytics Not Enabled | No AI insights in dashboard | Verify licensing and enable via System Settings |
| Data Not Flowing | Empty analytics dashboards | Check data collection and API connectivity |
| High False Positives | Too many anomaly alerts | Adjust AI model sensitivity settings |
| Performance Impact | System slowdown | Review data collection frequency and storage |

### Log File Locations

- **DNA Center**: `/opt/cisco/dnac/logs/ai-analytics/`
- **Catalyst Center**: `/var/log/catalyst/analytics/`
- **ThousandEyes**: Cloud-based logging via API

---

**Version**: 1.0  
**Last Updated**: 2025-01-27  
**Document Owner**: Cisco AI Network Analytics Team