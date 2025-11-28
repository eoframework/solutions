---
document_title: Detailed Design Document
solution_name: Azure Sentinel SIEM
document_version: "2.0"
author: "[ARCHITECT]"
last_updated: "[DATE]"
technology_provider: azure
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This document provides the comprehensive technical design for the Azure Sentinel SIEM solution. It covers the target-state architecture leveraging Microsoft Sentinel for cloud-native security information and event management, Azure Log Analytics for data ingestion and analysis, and Azure Logic Apps for security orchestration and automated response (SOAR). The design delivers AI-powered threat detection, unified security visibility, and automated incident response capabilities.

## Purpose

Define the technical architecture and design specifications that will guide the implementation team through deployment, configuration, and validation of the enterprise SIEM/SOAR solution on Microsoft Azure.

## Scope

**In-scope:**
- Azure Sentinel workspace deployment and configuration
- Data connector integration for 15+ security sources
- Analytics rules deployment (50+ built-in and custom rules)
- SOAR playbook development (12 Logic App workflows)
- Threat intelligence feed integration
- Security operations center (SOC) workflow enablement
- Compliance monitoring and reporting dashboards

**Out-of-scope:**
- End-user training (covered in Implementation Guide)
- Ongoing managed security services (separate engagement)
- Custom machine learning model development
- Third-party SIEM replacement (parallel operation)

## Assumptions & Constraints

The following assumptions underpin the design and must be validated during implementation.

- Azure subscription with appropriate service quotas established
- Azure AD tenant configured with appropriate licensing (E5 or equivalent)
- Network connectivity for data source integration available
- Security team has approved the proposed detection rules and playbooks
- SOC team available for training and knowledge transfer
- Data ingestion volume estimate: 500GB/day (scalable to 2TB/day)

## References

This document should be read in conjunction with the following related materials.

- Statement of Work (SOW)
- Discovery Questionnaire responses
- Microsoft Security Best Practices documentation
- MITRE ATT&CK Framework mapping

# Business Context

This section establishes the business drivers, success criteria, and compliance requirements that shape the technical design decisions.

## Business Drivers

The solution addresses the following key business objectives identified during discovery.

- **Threat Detection:** Reduce mean time to detect (MTTD) from hours to minutes using AI-powered analytics
- **Incident Response:** Reduce mean time to respond (MTTR) by 90% through automated playbooks
- **Unified Visibility:** Consolidate security monitoring across cloud, on-premises, and hybrid environments
- **Cost Optimization:** Reduce security tool sprawl through platform consolidation
- **Compliance:** Meet regulatory requirements for security monitoring and audit trails

## Workload Criticality & SLA Expectations

The following service level targets define the operational requirements for the production environment and guide infrastructure sizing decisions.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Availability | 99.9% | Azure Service Health | Critical |
| MTTD | < 15 minutes | Custom KPI dashboard | Critical |
| MTTR | < 60 minutes | Incident tracking | High |
| Detection Accuracy | > 95% | Validation testing | Critical |
| False Positive Rate | < 50% | Alert analysis | High |
| Query Response | < 30 seconds | Log Analytics metrics | Medium |

## Compliance & Regulatory Factors

The solution must adhere to the following regulatory and compliance requirements.

- SOC 2 Type II compliance required for all security operations
- Data encryption at rest (AES-256) and in transit (TLS 1.2+) mandatory
- Audit logging required for all administrative and investigative activities
- Data retention policies: 90 days hot, 2 years archive (configurable per regulation)
- GDPR, HIPAA, PCI DSS compliance controls as applicable

## Success Criteria

Project success will be measured against the following criteria at go-live.

- 15+ data connectors configured and ingesting data
- 50+ analytics rules deployed and generating alerts
- 12 SOAR playbooks operational with automated response
- MTTD below 15-minute target validated through testing
- SOC team trained and operational on platform

# Current-State Assessment

This section documents the existing security monitoring environment and identifies gaps addressed by the solution.

## Existing Security Tools

### N/A - Greenfield Implementation

This implementation represents a new security monitoring capability. The following legacy tools may operate in parallel during transition:

- On-premises SIEM (if applicable): Parallel operation during 30-day hypercare
- Endpoint protection: Integration via Defender for Endpoint connector
- Network security: Firewall log forwarding via CEF/Syslog
- Identity: Azure AD sign-in and audit log integration

## Gap Analysis

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Capability | Current State | Target State |
|------------|---------------|--------------|
| Threat Detection | Manual analysis, 4+ hour MTTD | AI-powered, <15 minute MTTD |
| Incident Response | Manual procedures, 4+ hour MTTR | Automated playbooks, <60 minute MTTR |
| Visibility | Fragmented tools, limited correlation | Unified platform, cross-source correlation |
| Compliance | Manual reporting | Automated compliance dashboards |
| Threat Intelligence | Limited integration | 10+ TI feeds integrated |

# Solution Architecture

This section provides the comprehensive technical architecture for the Azure Sentinel SIEM solution.

## Architecture Diagram

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Design Principles

- **Security First:** Defense-in-depth architecture with zero-trust principles
- **Scalability:** Cloud-native design supporting petabyte-scale data ingestion
- **Reliability:** High availability with 99.9% SLA leveraging Azure platform
- **Performance:** Optimized for real-time threat detection and rapid query response
- **Compliance:** Built-in compliance controls and audit capabilities

## Core Components

### Azure Sentinel

Primary SIEM/SOAR service providing:
- Cloud-native security analytics platform
- AI-powered threat detection using Fusion ML
- Built-in SOAR capabilities via Logic Apps
- UEBA (User and Entity Behavior Analytics)
- Integration with Microsoft security ecosystem

### Log Analytics Workspace

Data ingestion and query engine providing:
- Centralized log collection and storage
- KQL (Kusto Query Language) analytics
- Configurable retention policies (90 days hot, 2 years archive)
- Performance tier: PerGB2018 with commitment tier pricing

### Azure Logic Apps

Security orchestration providing:
- Automated incident response playbooks
- Integration with external systems (ServiceNow, Teams)
- Custom workflow automation
- API-based security actions

## Data Sources Architecture

### Native Microsoft Connectors
- **Azure AD:** Sign-in logs, audit logs, risky sign-ins
- **Microsoft 365 Defender:** Endpoint, email, identity protection
- **Office 365:** Exchange, SharePoint, Teams activity
- **Defender for Cloud:** Security alerts, recommendations
- **Azure Activity:** Subscription-level operations

### Infrastructure Connectors
- **Azure Firewall:** Network traffic and threat logs
- **NSG Flow Logs:** Network security group traffic
- **Azure DNS:** DNS query logs
- **Key Vault:** Access and operations audit

### Third-Party Connectors
- **CEF/Syslog:** Firewall, proxy, network devices
- **REST API:** Custom application integration
- **Threat Intelligence:** STIX/TAXII feeds

## Analytics Architecture

### Detection Layers
1. **Scheduled Analytics Rules:** KQL-based pattern detection
2. **Fusion ML:** AI-powered multi-stage attack detection
3. **UEBA:** Behavioral anomaly detection for users/entities
4. **Threat Intelligence:** IoC matching across data sources

### Rule Categories
- Microsoft Security: 30 built-in high-fidelity rules
- Custom Rules: 20 organization-specific detections
- UEBA Rules: Behavioral analytics rules
- Threat Intelligence Rules: IoC-based detection

# Security & Compliance

This section details the security controls and compliance implementation.

## Identity & Access Management

### RBAC Configuration

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Role | Permissions | Assignment |
|------|-------------|------------|
| Microsoft Sentinel Contributor | Full Sentinel access | Security Admins |
| Microsoft Sentinel Reader | Read-only access | SOC Analysts |
| Logic App Contributor | Playbook management | Automation Engineers |
| Log Analytics Contributor | Workspace management | Platform Admins |

### Privileged Access
- Multi-factor authentication required for all admin access
- Just-in-time (JIT) access for elevated permissions
- Conditional Access policies enforcing device compliance
- Regular access reviews and certification

## Data Protection

### Encryption Standards
- **At Rest:** AES-256 encryption via Azure Storage Service Encryption
- **In Transit:** TLS 1.2+ for all data transmission
- **Key Management:** Azure Key Vault for customer-managed keys (optional)

### Data Retention
- Hot storage: 90 days (queryable, fast access)
- Archive storage: 2 years (compliance retention)
- Immutable storage available for legal hold requirements

## Audit & Monitoring

### Activity Logging
- All administrative actions logged to Azure Activity Log
- Sentinel workspace operations audited
- Playbook executions tracked in Logic Apps run history
- User investigation activities captured

### Compliance Dashboards
- Built-in compliance workbooks (CIS, NIST, ISO 27001)
- Custom compliance reporting
- Automated compliance scoring

# Data Architecture

This section documents the data flow, storage, and management design.

## Data Ingestion Pipeline

```
[Data Sources] → [Connectors] → [Log Analytics] → [Analytics Rules] → [Incidents]
                                      ↓
[Threat Intelligence] → [Enrichment] → [Correlation Engine] → [MITRE ATT&CK]
```

## Data Flow Design

### Ingestion Path
1. **Native Connectors:** Direct API integration (Office 365, Azure AD)
2. **Agent-Based:** Azure Monitor Agent for Windows/Linux servers
3. **CEF/Syslog:** Log forwarder for third-party devices
4. **REST API:** Custom integration for applications

### Processing Pipeline
1. **Normalization:** ASIM (Advanced Security Information Model)
2. **Enrichment:** Threat intelligence correlation
3. **Analytics:** Real-time rule evaluation
4. **Storage:** Log Analytics workspace retention

## Storage Tiers

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Tier | Retention | Use Case | Cost Model |
|------|-----------|----------|------------|
| Hot | 90 days | Active investigation | PerGB ingestion |
| Archive | 2 years | Compliance/forensics | Archive rates |
| Export | Custom | Long-term archive | Storage account |

# Integration Design

This section documents external system integrations.

## SOAR Integrations

### ServiceNow Integration
- Automated incident ticket creation
- Bi-directional status synchronization
- Priority mapping from Sentinel severity

### Microsoft Teams Integration
- Real-time alert notifications to SOC channel
- Adaptive cards for incident details
- Interactive approval workflows

### Email Integration
- Critical alert notifications
- Executive summary reports
- Escalation notifications

## API Integration

### Sentinel REST API
- Custom application integration
- Automated rule management
- Incident lifecycle automation

### Log Analytics Query API
- Programmatic data access
- Custom reporting integration
- External dashboard connectivity

# Infrastructure & Operations

This section documents operational architecture and management procedures.

## High Availability

### Platform Resilience
- Azure Sentinel: 99.9% SLA (Azure-managed)
- Log Analytics: Zone-redundant storage
- Logic Apps: Multi-zone deployment

### Disaster Recovery
- Data replicated across Azure storage redundancy
- Configuration exported as Infrastructure as Code
- Recovery procedures documented in runbook

## Monitoring & Alerting

### Platform Health
- Azure Service Health integration
- Ingestion lag monitoring
- Connector health alerts

### Key Metrics

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Ingestion Lag | > 15 minutes | Warning | Investigate connector |
| Query Latency | > 60 seconds | Warning | Review query efficiency |
| Playbook Failures | > 5% | Critical | Check Logic App logs |
| Daily Ingestion | > 90% cap | Warning | Increase commitment tier |

## Capacity Planning

### Current Sizing
- Estimated daily ingestion: 500GB/day
- Commitment tier: 500GB/day
- Projected growth: 20% annually

### Scaling Triggers
- Ingestion consistently >80% of commitment tier
- Query performance degradation
- New data source onboarding

# Implementation Approach

This section outlines the phased implementation methodology.

## Phase Overview

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Foundation & Workspace | Weeks 1-4 | Sentinel enabled, RBAC configured |
| 2 | Data Connectors | Weeks 5-8 | 15+ connectors ingesting |
| 3 | Analytics & Detection | Weeks 9-12 | 50+ rules deployed, tuned |
| 4 | Automation & SOAR | Weeks 13-16 | 12 playbooks operational |
| 5 | Testing & Validation | Weeks 17-18 | All tests passing |
| 6 | Go-Live & Hypercare | Weeks 19-22 | Production stable |

## Risk Mitigation

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Risk | Impact | Mitigation |
|------|--------|------------|
| Data ingestion delays | Detection gaps | Parallel connector testing |
| High false positive rate | SOC fatigue | Iterative rule tuning |
| Integration failures | Automation gaps | Staged playbook deployment |
| Performance issues | Query delays | Capacity planning validation |

# Appendices

## Appendix A: Analytics Rule Catalog

The complete analytics rule catalog is maintained in `/delivery/docs/analytics-rules.md` and includes:
- 30 Microsoft built-in rules (high-fidelity)
- 20 custom organization-specific rules
- MITRE ATT&CK mapping for all rules
- Tuning guidance and threshold recommendations

## Appendix B: Data Connector Reference

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Connector | Data Tables | Volume Est. | Priority |
|-----------|-------------|-------------|----------|
| Azure AD | SigninLogs, AuditLogs | 50GB/day | Critical |
| Office 365 | OfficeActivity | 100GB/day | Critical |
| Defender for Endpoint | DeviceEvents | 150GB/day | Critical |
| Defender for Cloud | SecurityAlert | 10GB/day | High |
| Azure Firewall | AzureDiagnostics | 100GB/day | High |
| CEF/Syslog | CommonSecurityLog | 90GB/day | Medium |

## Appendix C: SOAR Playbook Reference

<!-- TABLE_CONFIG: widths=[30, 40, 30] -->
| Playbook | Function | Trigger |
|----------|----------|---------|
| Enrich-IP-Address | IP reputation lookup | High severity alert |
| Enrich-User-Identity | User risk assessment | User-related incident |
| Block-IP-Firewall | Automated IP blocking | Confirmed malicious IP |
| Disable-User-Account | Account disable action | Confirmed compromise |
| Create-ServiceNow-Ticket | ITSM integration | All incidents |
| Notify-SOC-Teams | Teams notification | High/Critical severity |

## Appendix D: Compliance Mapping

The solution supports the following compliance frameworks with built-in workbooks:
- **SOC 2:** Security, availability, processing integrity controls
- **ISO 27001:** Information security management controls
- **NIST CSF:** Identify, Protect, Detect, Respond, Recover
- **CIS Controls:** Critical security controls mapping
- **MITRE ATT&CK:** Technique detection coverage

---

**Document Version**: 2.0
**Last Updated**: [DATE]
**Prepared By**: Solution Architecture Team
**Review Status**: Approved
