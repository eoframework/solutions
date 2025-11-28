---
document_title: Detailed Design Document
solution_name: Juniper Mist AI Network
document_version: "1.0"
author: "[ARCHITECT]"
last_updated: "[DATE]"
technology_provider: Juniper
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This document provides the comprehensive technical design for the Juniper Mist AI Network implementation. The solution delivers AI-powered wireless infrastructure with 50 WiFi 6E access points, cloud-managed switching, and intelligent network analytics to achieve 99.9% uptime and 90% reduction in troubleshooting time.

## Purpose

Define the technical architecture and design specifications for deployment of Juniper Mist AI wireless network, including 50 AP45 WiFi 6E access points, 4 EX4400 PoE switches, Marvis virtual assistant, location services with vBLE, and unified cloud management through Mist dashboard.

## Scope

**In-scope:**

- 50 Juniper AP45 WiFi 6E access points (9.6 Gbps tri-band throughput)
- 4 EX4400 PoE switches with Wired Assurance
- Mist Cloud AI platform with predictive analytics
- Marvis Virtual Network Assistant for conversational troubleshooting
- Location services with virtual Bluetooth LE (vBLE)
- 802.1X RADIUS authentication with WPA3 encryption
- SSID configuration for 3-5 wireless networks
- SIEM integration for security event monitoring

**Out-of-scope:**

- Hardware procurement (client responsibility)
- Structured cabling installation for AP mounting
- Legacy wireless controller decommissioning
- Custom mobile application development beyond standard wayfinding

## Assumptions & Constraints

The following assumptions underpin the design and must be validated during implementation.

- Client provides building floor plans in CAD or PDF format for RF planning
- Structured cabling and PoE power available at AP mounting locations
- Network infrastructure (VLANs, DHCP, DNS) configured for wireless requirements
- RADIUS or Active Directory accessible for 802.1X authentication
- Internet connectivity available for Mist Cloud management and AI services

## References

This document should be read in conjunction with the following related materials.

- Statement of Work (SOW) - Project scope and investment
- Solution Briefing - Architecture overview and business case
- Juniper Mist AI Technical Documentation
- Client wireless policies and compliance requirements

# Business Context

This section establishes the business drivers, success criteria, and compliance requirements that shape the technical design decisions for the Mist AI Network implementation.

## Business Drivers

The solution addresses the following key business objectives identified during discovery.

- **Eliminate Manual Troubleshooting:** Replace hours of packet captures with AI-driven root cause analysis, achieving 90% reduction in troubleshooting time
- **Achieve 99.9% Uptime:** Deploy cloud-managed WiFi 6E with proactive anomaly detection before user impact
- **Enable Location Services:** Implement vBLE for indoor wayfinding and asset tracking without physical beacon hardware
- **Reduce Helpdesk Tickets:** Achieve 60% reduction in wireless helpdesk tickets through Marvis AI self-service

## Workload Criticality & SLA Expectations

The following service level targets define the operational requirements for the production environment.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Target | Measurement | Priority |
|--------|--------|-------------|----------|
| Wireless Uptime | 99.9% | Mist Cloud SLE | Critical |
| Successful Connections | 99% SLE | Mist analytics | Critical |
| RF Coverage | -67 dBm minimum | Heat mapping | Critical |
| Location Accuracy | 3-5 meters | vBLE positioning | High |
| Roaming Performance | < 150ms handoff | Client testing | High |

## Compliance & Regulatory Factors

The solution must adhere to the following regulatory and compliance requirements.

- SOC 2 Type II compliance for security controls and audit logging
- WPA3-Enterprise encryption for wireless data protection
- 802.1X authentication for user access control
- Comprehensive logging for security event correlation

## Success Criteria

Project success will be measured against the following criteria at go-live.

- 50 AP45 access points operational with complete building coverage
- 99% successful connection SLE achieved as measured by Mist Cloud
- Marvis AI operational with proactive anomaly detection
- Location services enabled with indoor positioning within 3-5 meters
- 802.1X authentication functional with RADIUS integration

# Current-State Assessment

This section documents the existing wireless infrastructure that the Mist AI platform will replace.

## Application Landscape

The current wireless infrastructure consists of legacy controller-based WiFi requiring modernization.

<!-- TABLE_CONFIG: widths=[25, 30, 25, 20] -->
| Component | Purpose | Technology | Status |
|-----------|---------|------------|--------|
| Wireless Controller | Central management | Legacy on-premises | To be replaced |
| Access Points | WiFi coverage | Mixed vendor 802.11ac | To be replaced |
| Guest Portal | Visitor access | Standalone appliance | To be consolidated |
| RF Management | Channel optimization | Manual tuning | To be automated |

## Infrastructure Inventory

The current infrastructure consists of the following components being replaced.

<!-- TABLE_CONFIG: widths=[20, 15, 35, 30] -->
| Component | Quantity | Specifications | Notes |
|-----------|----------|----------------|-------|
| Legacy APs | ~40 | 802.11ac Wave 2 | End of support approaching |
| Controller | 1 | On-premises appliance | Single point of failure |
| Guest Portal | 1 | Standalone server | Manual management |
| RF Tools | Various | Manual site survey | No AI optimization |

## Dependencies & Integration Points

The current environment has the following external dependencies.

- Active Directory for user authentication
- RADIUS server for 802.1X integration
- DHCP servers for IP address allocation
- DNS servers for name resolution
- Splunk SIEM for security logging

## Network Topology

Current network uses hub-and-spoke wireless topology with:

- Controller-based architecture with centralized data plane
- Limited visibility into client experience
- Manual RF channel and power configuration
- No location services capability

## Performance Baseline

Current system performance metrics establish the baseline for improvement.

- Wireless coverage: 85% of building area (gaps in conference rooms)
- Connection success rate: ~92% (manual measurement)
- RF optimization: Manual (quarterly at best)
- Troubleshooting time: 2-4 hours per incident
- Helpdesk tickets: 50+ wireless tickets per month

# Solution Architecture

The target architecture deploys Juniper Mist AI wireless platform with cloud-managed intelligence, automated RF optimization, and comprehensive analytics.

![Solution Architecture](../../assets/diagrams/architecture-diagram.png)

## Architecture Principles

The following principles guide all architectural decisions.

- **AI-First Design:** Leverage machine learning for anomaly detection and optimization
- **Cloud-Native Management:** Eliminate on-premises controllers for simplified operations
- **Zero-Touch Provisioning:** Automated AP configuration via Mist Cloud
- **Client Experience Focus:** SLE-based monitoring for proactive issue detection
- **Location Awareness:** Built-in vBLE for indoor positioning without hardware beacons

## Architecture Patterns

The solution implements the following architectural patterns.

- **Cloud-Managed Pattern:** All management and analytics via Mist Cloud
- **Distributed Data Plane:** Traffic forwarding at AP level (no controller hairpin)
- **AI Analytics Pattern:** Machine learning for RF optimization and anomaly detection
- **Microservices Integration:** RESTful APIs for external system integration

## Component Design

The solution comprises the following logical components.

<!-- TABLE_CONFIG: widths=[18, 25, 22, 18, 17] -->
| Component | Purpose | Technology | Dependencies | Scaling |
|-----------|---------|------------|--------------|---------|
| Access Points | WiFi 6E coverage, 9.6 Gbps | AP45 (50 units) | PoE switches | Per-area |
| PoE Switches | Power and connectivity | EX4400 (4 units) | Uplinks | Per-closet |
| Mist Cloud | Management and AI | SaaS platform | Internet | Elastic |
| Marvis VNA | Conversational troubleshooting | AI assistant | Mist Cloud | Included |
| Location Services | Indoor positioning | vBLE (built-in) | AP45 vBLE | Per-AP |

## Technology Stack

The technology stack has been selected based on performance, AI capabilities, and alignment with organizational standards.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Access Points | Juniper AP45 WiFi 6E | 9.6 Gbps tri-band, vBLE integrated |
| Switching | EX4400-48P-POE | Full PoE++, Wired Assurance enabled |
| Cloud Platform | Mist Cloud AI | ML-driven analytics, zero controllers |
| AI Assistant | Marvis VNA | Natural language troubleshooting |
| Authentication | 802.1X with RADIUS | Enterprise security, WPA3 encryption |

# Security & Compliance

This section details the security controls, compliance mappings, and governance mechanisms.

## Identity & Access Management

Access control follows enterprise standards with centralized authentication.

- **User Authentication:** 802.1X with RADIUS server integration
- **Admin Authentication:** SSO with role-based access control
- **Encryption:** WPA3-Enterprise with AES-256-GCM
- **Guest Access:** Captive portal with terms acceptance

### Role Definitions

The following roles define access levels within Mist Cloud.

<!-- TABLE_CONFIG: widths=[20, 40, 40] -->
| Role | Permissions | Scope |
|------|-------------|-------|
| Super User | Full system access, all configuration | Organization-wide |
| Network Admin | Site configuration, AP management | Assigned sites |
| Helpdesk | Read-only, basic troubleshooting | All sites |
| Observer | Dashboard viewing only | Assigned sites |

## Network Security

Network security implements multiple layers of wireless protection.

- **SSID Segmentation:** Separate networks for corporate, guest, IoT
- **VLAN Isolation:** Traffic separation between user groups
- **Rogue AP Detection:** Automatic identification of unauthorized APs
- **WPA3 Encryption:** Latest WiFi security standard

## Data Protection

Data protection controls ensure confidentiality for wireless traffic.

- **Encryption in Transit:** WPA3-Enterprise for client traffic
- **Management Security:** TLS 1.3 for cloud communication
- **Data Residency:** Mist Cloud data stored in US data centers
- **Privacy Controls:** MAC randomization support for client privacy

## Compliance Mappings

The following table maps compliance requirements to implementation controls.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Framework | Requirement | Implementation |
|-----------|-------------|----------------|
| SOC 2 | Access control | 802.1X with role-based authorization |
| SOC 2 | Audit logging | Comprehensive event logging to SIEM |
| SOC 2 | Encryption | WPA3-Enterprise with AES-256 |
| PCI DSS | Network segmentation | VLAN isolation for payment systems |

## Audit Logging & SIEM Integration

Comprehensive audit logging supports security monitoring and compliance.

- All authentication events logged with user identity
- Configuration changes captured with administrator audit trail
- Security events forwarded to Splunk SIEM via syslog
- Mist Cloud provides 30-day event retention
- SIEM retention per organizational policy

# Data Architecture

This section defines the data flow, analytics architecture, and RF data management.

## Data Model

### Conceptual Model

The solution manages the following core data elements:

- **Client Analytics:** Connection statistics, roaming events, throughput
- **RF Data:** Signal strength, interference, channel utilization
- **Location Data:** vBLE positioning, asset tracking, occupancy
- **Configuration Data:** SSID profiles, policies, AP settings

### Logical Model

The logical data model defines the primary entities.

<!-- TABLE_CONFIG: widths=[20, 25, 30, 25] -->
| Entity | Key Attributes | Relationships | Volume |
|--------|----------------|---------------|--------|
| Client Device | MAC, hostname, OS | Connects to SSID | 2,000 devices |
| Access Point | Serial, location, RF | Serves clients | 50 APs |
| SSID Profile | Name, security, VLAN | Applied to APs | 3-5 SSIDs |
| Location Event | Timestamp, coordinates | References device | 100K/day |

## Data Flow Design

1. **Client Connection:** Device associates with nearest AP based on RF signal
2. **Authentication:** 802.1X validates credentials against RADIUS
3. **Traffic Flow:** Data forwarded directly from AP (no controller tunnel)
4. **Analytics Collection:** Mist Cloud ingests telemetry every 60 seconds
5. **AI Processing:** Machine learning analyzes patterns for anomalies

## Data Governance

Data governance policies ensure proper handling of wireless analytics.

- **Classification:** Client MAC addresses treated as PII
- **Retention:** Mist Cloud retains 30 days; archive per policy
- **Privacy:** Support for MAC randomization and data anonymization
- **Access:** Role-based access to analytics dashboards

# Integration Design

This section documents the integration patterns and external system connections.

## External System Integrations

The solution integrates with the following external systems.

<!-- TABLE_CONFIG: widths=[18, 15, 15, 15, 22, 15] -->
| System | Type | Protocol | Format | Error Handling | SLA |
|--------|------|----------|--------|----------------|-----|
| RADIUS | Real-time | RADIUS | Native | Failover server | 99.9% |
| Active Directory | Real-time | LDAP | Native | Cache credentials | 99.9% |
| Splunk SIEM | Real-time | Syslog/TLS | CEF | Buffer and retry | 99.9% |
| ServiceNow | Webhook | HTTPS | JSON | Retry with backoff | 99.5% |

## API Design

Mist Cloud provides RESTful APIs for automation and integration.

- **Style:** RESTful with JSON payloads
- **Authentication:** API token with organization scope
- **Rate Limiting:** 5000 requests per hour
- **Documentation:** OpenAPI specification available

### API Endpoints

The following REST API endpoints provide programmatic access.

<!-- TABLE_CONFIG: widths=[15, 30, 20, 35] -->
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /api/v1/sites | API Token | List managed sites |
| GET | /api/v1/sites/{id}/stats/clients | API Token | Client statistics |
| POST | /api/v1/sites/{id}/wlans | API Token | Create SSID |
| GET | /api/v1/orgs/{id}/inventory | API Token | Device inventory |

## Authentication & SSO Flows

Single sign-on and authentication flows for administration.

- SSO integration with Okta, Azure AD, or Google Workspace
- SAML 2.0 for administrator authentication
- API tokens for automation and scripting
- MFA enforcement for privileged access

# Infrastructure & Operations

This section covers the infrastructure design and operational procedures.

## Network Design

The network architecture provides WiFi 6E coverage across the entire building.

- **Access Layer:** 50 AP45 access points across all floors
- **Distribution:** 4 EX4400-48P switches in IDF closets
- **Management:** Mist Cloud via internet connectivity
- **Redundancy:** Dual uplinks from each IDF to core

## Compute Sizing

Hardware sizing based on coverage requirements and user density.

<!-- TABLE_CONFIG: widths=[25, 20, 20, 20, 15] -->
| Component | Model | Capacity | Coverage | Count |
|-----------|-------|----------|----------|-------|
| Access Point | AP45 | 9.6 Gbps, 500 clients | 5,000 sq ft | 50 |
| PoE Switch | EX4400-48P | 48 ports, 1440W PoE | 12 APs each | 4 |
| Mist Cloud | SaaS | Unlimited | N/A | 1 org |

## High Availability Design

The solution provides resilience through distributed architecture.

- No single point of failure (no central controller)
- AP operates independently if cloud connectivity lost
- Dual power supplies on EX4400 switches
- Geographic redundancy in Mist Cloud

## Monitoring & Alerting

Comprehensive monitoring provides visibility across wireless infrastructure.

- **SLE Monitoring:** Successful connects, coverage, capacity, roaming
- **RF Analytics:** Channel utilization, interference, RSSI distribution
- **Client Experience:** Throughput, latency, application performance
- **Alerting:** Webhook, email, and Slack integration

### Alert Definitions

The following alerts are configured for proactive monitoring.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Alert | Condition | Severity | Response |
|-------|-----------|----------|----------|
| AP Offline | No heartbeat 5 min | Critical | Check power/network |
| SLE Below Target | < 95% success | Warning | Investigate RF |
| High Interference | Channel busy > 50% | Warning | Adjust RF policy |
| Rogue AP Detected | Unknown BSSID | High | Security review |

## Cost Model

The infrastructure costs align with the project investment summary.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Category | Year 1 Investment | Annual Recurring | Notes |
|----------|-------------------|------------------|-------|
| Hardware | $116,600 | $0 | 50 AP45, 4 EX4400 |
| Software Licenses | $31,400 | $31,400 | Mist subscriptions |
| Support | $9,720 | $9,720 | 24x7 JTAC |
| Professional Services | $81,000 | $0 | Implementation |

# Implementation Approach

This section outlines the deployment strategy and sequencing.

## Migration/Deployment Strategy

The deployment strategy phases AP installation with legacy cutover.

- **Approach:** Parallel deployment with phased legacy AP removal
- **Pattern:** Floor-by-floor rollout with RF validation
- **Validation:** SLE monitoring before each floor cutover
- **Rollback:** Legacy APs remain operational until validation complete

## Sequencing & Wave Planning

The implementation follows an 8-week phased approach.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| Phase 1 | Discovery & Planning | Weeks 1-2 | RF design approved |
| Phase 2 | Infrastructure Deployment | Weeks 3-5 | All APs operational |
| Phase 3 | AI Services Enablement | Week 6 | Marvis AI active |
| Phase 4 | Testing & Handover | Weeks 7-8 | 99% SLE validated |

## Tooling & Automation

The following tools provide the automation foundation.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Category | Tool | Purpose |
|----------|------|---------|
| Cloud Management | Mist Dashboard | Configuration and monitoring |
| RF Planning | Mist AI Planner | Predictive coverage modeling |
| Troubleshooting | Marvis VNA | Conversational diagnostics |
| API Automation | Mist REST API | Scripted configuration |

## Cutover Approach

The cutover strategy minimizes user impact through phased migration.

- **Type:** Phased floor-by-floor cutover
- **Duration:** 2-3 days per floor during Phase 2
- **Validation:** SLE confirmation before legacy AP removal
- **Rollback:** Re-enable legacy AP if issues detected

# Appendices

## Naming Conventions

All Mist resources follow standardized naming conventions.

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Site | `{building}-{location}` | `hq-newyork` |
| Access Point | `{floor}-ap-{sequence}` | `f1-ap-001` |
| SSID | `{company}-{purpose}` | `acme-corp`, `acme-guest` |
| RF Template | `{density}-{band}` | `high-density-6ghz` |

## Risk Register

The following risks have been identified with mitigation strategies.

<!-- TABLE_CONFIG: widths=[25, 15, 15, 45] -->
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RF coverage gaps | Medium | High | Predictive site survey, post-deploy validation |
| Hardware delivery delays | Low | Medium | Order immediately upon SOW execution |
| RADIUS integration issues | Low | Medium | Early authentication testing |
| User adoption challenges | Low | Low | Comprehensive training program |

## Glossary

The following terms are used throughout this document.

<!-- TABLE_CONFIG: widths=[25, 75] -->
| Term | Definition |
|------|------------|
| AP45 | Juniper WiFi 6E access point with 9.6 Gbps throughput |
| EX4400 | Juniper PoE switch with Wired Assurance support |
| Marvis | AI virtual network assistant for troubleshooting |
| SLE | Service Level Expectation - Mist success metrics |
| vBLE | Virtual Bluetooth LE for location without beacons |
| WiFi 6E | 802.11ax with 6 GHz band support |
