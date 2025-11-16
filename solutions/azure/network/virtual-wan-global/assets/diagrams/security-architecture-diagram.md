# Security Architecture Diagram
## Centralized Threat Protection & Policy Enforcement

```
                    SECURITY ARCHITECTURE
             Azure Firewall Premium Deployment

┌────────────────────────────────────────────────────────────────┐
│                    VIRTUAL WAN HUB (US)                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          AZURE FIREWALL PREMIUM (Instance 1)             │  │
│  │                                                           │  │
│  │  ◆ Threat Intelligence: Real-time threat feeds          │  │
│  │  ◆ IDPS: Intrusion detection & prevention system        │  │
│  │  ◆ TLS Inspection: Decrypt & inspect HTTPS traffic      │  │
│  │  ◆ Web Filtering: URL/domain-based blocking             │  │
│  │  ◆ IPS Signatures: 5000+ attack patterns                │  │
│  │                                                           │  │
│  │  Firewall Rules (Implicit Deny):                         │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Network Rules                    │ Priority        │  │  │
│  │  ├─────────────────────────────────┼─────────────────┤  │  │
│  │  │ Allow VNet-to-VNet              │ 100             │  │  │
│  │  │ Allow Branch-to-VNet            │ 110             │  │  │
│  │  │ Allow Data Center via ExpressRt │ 120             │  │  │
│  │  │ Allow Hub-to-Hub (inter-region) │ 130             │  │  │
│  │  │ Deny All Other                  │ 1000 (Default)  │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  Application Rules:                                      │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Allow Office 365 (Teams, Outlook)                 │  │  │
│  │  │ Allow Azure Services                              │  │  │
│  │  │ Allow Internal DNS (10.x.x.x queries)             │  │  │
│  │  │ Block Malware URLs (threat intel)                 │  │  │
│  │  │ Block P2P Apps (Torrent, etc)                     │  │  │
│  │  │ Log All Traffic (diagnostic)                      │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                           │ All Traffic Routes Through         │
│                           │ (Centralized Inspection)            │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         DIAGNOSTIC & LOGGING INFRASTRUCTURE              │  │
│  │                                                           │  │
│  │  ◆ Firewall Logs: JSON format, 30-day retention          │  │
│  │  ◆ Network Watcher: Flow logs, traffic analysis          │  │
│  │  ◆ Azure Monitor: Real-time alerts, metrics              │  │
│  │  ◆ Compliance Logs: HIPAA, PCI-DSS audit trails         │  │
│  │  ◆ Threat Analytics: Incident detection, trends         │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘

                           │
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼

┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ Branch Sites │   │ Azure VNets  │   │ Data Centers │
│              │   │              │   │ (ExpressRoute)
│ 10 Locations │   │ 3 VNets      │   │ 2 Locations  │
│              │   │              │   │              │
│ VPN Tunnels  │   │ Direct Links │   │ BGP Peering  │
│              │   │              │   │              │
└──────────────┘   └──────────────┘   └──────────────┘


SECONDARY HUB (EU) - IDENTICAL ARCHITECTURE:
──────────────────────────────────────────

┌────────────────────────────────────────────────────────────────┐
│                    VIRTUAL WAN HUB (EU)                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          AZURE FIREWALL PREMIUM (Instance 2)             │  │
│  │                                                           │  │
│  │  Same threat protection as US Hub                        │  │
│  │  Synchronized firewall policies (Azure Firewall Manager) │  │
│  │  Redundant IDPS, TLS inspection, threat intelligence    │  │
│  │                                                           │  │
│  │  Handles 4 EU branch sites + EU VNet traffic            │  │
│  │  Failover target for US branch sites (if US fails)      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         CENTRALIZED LOGGING (BOTH HUBS)                  │  │
│  │                                                           │  │
│  │  ◆ Azure Log Analytics: Unified firewall logs            │  │
│  │  ◆ Kusto Query Language: Custom compliance reports       │  │
│  │  ◆ Azure Sentinel: SIEM integration, threat hunting      │  │
│  │  ◆ Cost Analytics: Per-branch traffic attribution        │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘


TRAFFIC INSPECTION FLOWS:
─────────────────────────

Inbound (Internet to VNet):
  Internet ──► Firewall (ALLOW/DENY) ──► VNet
                    │
                    ├─ Check threat intelligence
                    ├─ Inspect URLs (HTTP/HTTPS)
                    ├─ Apply network rules
                    └─ Log decision + packet data

Outbound (VNet to Internet):
  VNet ──► Firewall (ALLOW/DENY) ──► Internet
                │
                ├─ TLS decryption (cert inspection)
                ├─ URL/domain filtering
                ├─ Threat intelligence lookup
                ├─ DLP policy enforcement (custom)
                └─ Log all traffic details

Internal (VNet-to-VNet or Branch-to-VNet):
  Source ──► Firewall (ALLOW/DENY) ──► Destination
                │
                ├─ Apply network rules
                ├─ No TLS inspection (internal)
                ├─ Layer 4 (TCP/UDP) inspection
                └─ Log traffic flow


COMPLIANCE & AUDIT:
───────────────────

Regulations Supported:
✓ HIPAA: Patient data encryption, audit trails
✓ PCI-DSS: Payment card data protection, firewall logging
✓ SOC 2: Security controls, incident response
✓ GDPR: Data residency (EU hub), retention policies
✓ HITRUST: Combined HIPAA/HIPAA standards

Audit Requirements:
────────────────────
┌─────────────────────────────────────────────┐
│ HIPAA/PCI-DSS Audit Requirements            │
├─────────────────────────────────────────────┤
│ ✓ All firewall decisions logged             │
│ ✓ 30-day log retention (configurable)       │
│ ✓ Firewall rule changes tracked             │
│ ✓ User access logs (who changed rules)      │
│ ✓ Threat detection logs                     │
│ ✓ IDPS signature updates logged             │
│ ✓ Network traffic analysis reports          │
│ ✓ Incident response playbooks documented   │
│ ✓ Annual penetration testing results        │
│ ✓ Policy effectiveness metrics              │
└─────────────────────────────────────────────┘


INCIDENT RESPONSE:
──────────────────

Detected Threat:
  Malware URL Request ──► Firewall Blocks ──► Alert Sent

Response Flow:
1. Detection: IDPS triggers on suspicious pattern
2. Logging: Attack details logged with source/destination
3. Alerting: Azure Monitor sends alert to Security Team
4. Analysis: Sentinel correlates with threat intelligence
5. Response: Auto-block IP/domain (configurable)
6. Investigation: Log analytics used for root cause analysis
7. Escalation: Critical alerts page on-call engineer
```

## Security Policy Implementation

### Network Rules (Layer 3-4)
```
Rule 1: Allow VNet-to-VNet Traffic
  Source: 10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16
  Destination: 10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16
  Protocol: TCP, UDP
  Action: Allow

Rule 2: Allow Branch-to-Cloud
  Source: VPN Clients (variable)
  Destination: 10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16
  Protocol: TCP, UDP
  Ports: 443, 3389, 22
  Action: Allow

Rule 3: Allow Data Center (ExpressRoute)
  Source: 192.168.0.0/16
  Destination: 10.0.0.0/8
  Protocol: Any
  Action: Allow

Rule 4: Deny All Other
  Source: Any
  Destination: Any
  Protocol: Any
  Action: Deny
```

### Application Rules (Layer 7)
```
Rule 1: Allow Microsoft 365
  Source: Any (internal)
  Destination: *.office.com, *.outlook.com
  Action: Allow

Rule 2: Allow Azure Services
  Source: Any
  Destination: Azure Service Tags
  Action: Allow

Rule 3: Block Malware URLs
  Source: Any
  Destination: Threat Intelligence DB
  Action: Deny + Alert

Rule 4: Block P2P Applications
  Source: Any
  Destination: Known P2P networks
  Application Protocol: BitTorrent, etc.
  Action: Deny
```

## Security Benefits

1. **Centralized Enforcement:** All traffic inspected at hub (6-8 point architecture)
2. **Advanced Threats:** IDPS catches zero-day attacks, malware
3. **Insider Protection:** TLS inspection reveals internal threats
4. **Compliance:** Audit trails prove regulatory adherence
5. **Threat Intelligence:** Microsoft's global threat database
6. **Incident Response:** Automated blocking of detected threats
7. **Performance:** <10ms firewall processing per packet
8. **Cost:** Single firewall vs. distributed appliances ($15.3K/year)
