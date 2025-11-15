#!/usr/bin/env python3
"""
Azure Sentinel SIEM Architecture Diagram Generator

This script generates an architecture diagram for Azure Sentinel SIEM solution
using the Python diagrams library.

Requirements:
    pip install diagrams

Usage:
    python3 generate_diagram.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import FunctionApps
from diagrams.azure.database import CosmosDb, DataLake
from diagrams.azure.storage import BlobStorage
from diagrams.azure.ml import MachineLearningServiceWorkspaces as CognitiveServices
from diagrams.azure.integration import APIManagement, LogicApps, EventGridTopics, ServiceBus
from diagrams.azure.security import KeyVaults
from diagrams.azure.devops import ApplicationInsights
from diagrams.azure.network import VirtualNetworks, Firewall, PrivateEndpoint
from diagrams.azure.identity import ActiveDirectory

# Diagram configuration
graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "12",
}

with Diagram(
    "Azure Sentinel SIEM - Enterprise Architecture",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # External users and SOC team
    soc_analysts = ActiveDirectory("SOC Analysts\n& Security Team")
    external_systems = APIManagement("External Systems\n(Ticketing, SOAR)")

    with Cluster("Azure Subscription - Security Operations"):

        with Cluster("Data Ingestion Layer"):
            with Cluster("Microsoft Sources"):
                defender = CognitiveServices("Microsoft 365\nDefender")
                azure_ad = ActiveDirectory("Azure AD\n(Identity Events)")
                defender_cloud = CognitiveServices("Defender for\nCloud")

            with Cluster("Network & Infrastructure"):
                firewall = Firewall("Azure Firewall\n& NSG Flow Logs")
                on_prem_fw = Firewall("On-Premises\nFirewall")

            with Cluster("Third-Party Sources"):
                edr = CognitiveServices("EDR/XDR\nEndpoint Detection")
                third_party = CognitiveServices("Third-Party SIEM\n(Splunk, ArcSight)")

        with Cluster("Log Analytics & Storage"):
            log_analytics = DataLake("Log Analytics\nWorkspace\n(300 GB/month)")
            blob_archive = BlobStorage("Blob Storage\nArchive")

        with Cluster("Analytics & Detection Engine"):
            kql_rules = CognitiveServices("KQL Detection Rules\n(50+ Rules)")
            ml_models = CognitiveServices("ML Anomaly\nDetection")
            threat_intel = CognitiveServices("Threat Intelligence\nIntegration")
            ueba = CognitiveServices("UEBA\n(Behavior Analytics)")

        with Cluster("Incident Management"):
            incidents = CognitiveServices("Azure Sentinel\nIncident Management")
            investigation = CognitiveServices("Investigation\nWorkbooks")
            hunting = CognitiveServices("Advanced\nHunting")

        with Cluster("SOAR & Automation"):
            playbooks = LogicApps("Logic Apps\nPlaybooks\n(50+ Automated)")
            auto_response = CognitiveServices("Auto-Remediation\n& Response")

        with Cluster("Integration Hub"):
            ticketing = APIManagement("Ticketing System\n(ServiceNow, Jira)")
            communication = CognitiveServices("Communication\n(Teams, Slack)")
            external_security = CognitiveServices("Security Tools\nIntegration")

        with Cluster("Compliance & Governance"):
            rbac = ActiveDirectory("RBAC &\nAccess Control")
            audit_log = CognitiveServices("Audit Logging\n& Trail")
            compliance = CognitiveServices("Compliance\nReporting")

        with Cluster("Monitoring & Operations"):
            monitor = ApplicationInsights("Azure Monitor\n& Health")
            keyvault = KeyVaults("Key Vault\n(Secrets & Keys)")

        with Cluster("Network Security"):
            vnet = VirtualNetworks("Virtual Network\n(Private Endpoints)")

    # Data flows - Ingestion
    defender >> Edge(label="1. Threat Data") >> log_analytics
    azure_ad >> Edge(label="2. Identity Events") >> log_analytics
    defender_cloud >> Edge(label="3. Infrastructure") >> log_analytics
    firewall >> Edge(label="4. Network Logs") >> log_analytics
    on_prem_fw >> Edge(label="5. On-Prem Logs") >> log_analytics
    edr >> Edge(label="6. Endpoint Events") >> log_analytics
    third_party >> Edge(label="7. Third-Party") >> log_analytics

    # Analytics flows
    log_analytics >> Edge(label="8. Ingest") >> kql_rules
    log_analytics >> Edge(label="9. Analyze") >> ml_models
    log_analytics >> Edge(label="10. Analyze") >> ueba
    threat_intel >> Edge(label="11. Enrich", style="dotted") >> kql_rules

    # Detection flows
    kql_rules >> Edge(label="12. Detections") >> incidents
    ml_models >> Edge(label="13. Anomalies") >> incidents
    ueba >> Edge(label="14. Behaviors") >> incidents

    # Investigation flows
    incidents >> Edge(label="15. Incident Data") >> investigation
    investigation >> Edge(label="16. Investigation") >> hunting
    log_analytics >> Edge(label="17. Historical Data") >> hunting

    # Automation flows
    incidents >> Edge(label="18. Trigger") >> playbooks
    playbooks >> Edge(label="19. Execute") >> auto_response

    # Integration flows
    playbooks >> Edge(label="20. Create Ticket") >> ticketing
    playbooks >> Edge(label="21. Notify") >> communication
    playbooks >> Edge(label="22. External Action") >> external_security

    # SOC team interaction
    soc_analysts >> Edge(label="23. Investigation") >> investigation
    soc_analysts >> Edge(label="24. Advanced Hunt") >> hunting
    incidents >> Edge(label="25. Alert") >> soc_analysts
    playbooks >> Edge(label="26. Auto Response") >> soc_analysts

    # External system integration
    external_systems >> Edge(label="27. API Call") >> incidents
    external_systems >> Edge(label="28. Request") >> playbooks

    # Security & governance flows
    kql_rules >> Edge(label="Security", style="dotted") >> rbac
    playbooks >> Edge(label="Audit", style="dotted") >> audit_log
    incidents >> Edge(label="Compliance", style="dotted") >> compliance

    # Archival flows
    log_analytics >> Edge(label="Archive", style="dashed") >> blob_archive

    # Network security
    vnet >> Edge(label="Private Access", style="dotted") >> log_analytics
    keyvault >> Edge(label="Secrets", style="dotted") >> playbooks
    keyvault >> Edge(label="Credentials", style="dotted") >> external_security

    # Monitoring flows
    log_analytics >> Edge(label="Metrics", style="dashed") >> monitor
    incidents >> Edge(label="Events", style="dashed") >> monitor
    playbooks >> Edge(label="Execution", style="dashed") >> monitor

print("Architecture diagram generated successfully: architecture-diagram.png")
