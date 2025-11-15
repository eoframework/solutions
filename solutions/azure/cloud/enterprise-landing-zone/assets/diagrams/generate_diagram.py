#!/usr/bin/env python3
"""
Azure Enterprise Landing Zone Architecture Diagram Generator

This script generates an architecture diagram for Azure Enterprise Landing Zone solution
using the Python diagrams library.

Requirements:
    pip install diagrams

Usage:
    python3 generate_diagram.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import VM
from diagrams.azure.network import VirtualNetworks, Firewall, VirtualNetworkGateways, ExpressrouteCircuits, ApplicationGateway, PrivateEndpoint, NetworkSecurityGroupsClassic
from diagrams.azure.security import KeyVaults, Sentinel
from diagrams.azure.identity import ActiveDirectory, ManagedIdentities
from diagrams.azure.devops import ApplicationInsights
from diagrams.azure.analytics import LogAnalyticsWorkspaces
from diagrams.azure.general import Subscriptions, Managementgroups
from diagrams.azure.integration import LogicApps

# Diagram configuration
graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
    "ranksep": "1.0",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "Azure Enterprise Landing Zone Architecture",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Identity & Governance Layer
    with Cluster("Identity & Governance"):
        aad = ActiveDirectory("Azure Active Directory\n(Conditional Access + PIM)")

        with Cluster("Management Groups Hierarchy"):
            tenant_root = Managementgroups("Tenant Root Group")

            with Cluster("Platform"):
                platform_mg = Managementgroups("Platform MG")
                mgmt_sub = Subscriptions("Management\nSubscription")
                connectivity_sub = Subscriptions("Connectivity\nSubscription")
                identity_sub = Subscriptions("Identity\nSubscription")

            with Cluster("Landing Zones"):
                landing_zones_mg = Managementgroups("Landing Zones MG")
                prod_sub = Subscriptions("Production\nSubscriptions")
                nonprod_sub = Subscriptions("Non-Production\nSubscriptions")
                sandbox_sub = Subscriptions("Sandbox\nSubscriptions")

    # Hub Network Layer
    with Cluster("Hub Network (Connectivity Subscription)"):
        with Cluster("Hub VNet (10.0.0.0/22)"):
            azure_firewall = Firewall("Azure Firewall\n(Premium)")
            vpn_gateway = VirtualNetworkGateways("VPN Gateway\n(S2S VPN)")
            expressroute = ExpressrouteCircuits("ExpressRoute\n(1 Gbps)")
            hub_vnet = VirtualNetworks("Hub VNet")

    # Security & Monitoring Layer
    with Cluster("Security & Monitoring (Management Subscription)"):
        log_analytics = LogAnalyticsWorkspaces("Log Analytics\nWorkspace")
        sentinel = Sentinel("Azure Sentinel\n(SIEM/SOAR)")
        app_insights = ApplicationInsights("Azure Monitor\n(Metrics & Alerts)")
        keyvault = KeyVaults("Key Vault\n(Secrets Management)")

    # Landing Zone - Production Spoke
    with Cluster("Production Landing Zone (Spoke VNet 10.1.0.0/24)"):
        with Cluster("Application Tier"):
            app_vms = VM("Application VMs")
            app_gateway = ApplicationGateway("App Gateway\n(WAF)")

        with Cluster("Data Tier"):
            private_endpoint_db = PrivateEndpoint("Private Endpoint\n(Azure SQL)")

        spoke_prod_vnet = VirtualNetworks("Prod Spoke VNet")
        nsg_prod = NetworkSecurityGroupsClassic("NSG\n(Security Rules)")

    # Landing Zone - Non-Production Spoke
    with Cluster("Non-Prod Landing Zone (Spoke VNet 10.1.1.0/24)"):
        nonprod_vms = VM("Dev/Test VMs")
        spoke_nonprod_vnet = VirtualNetworks("Non-Prod Spoke VNet")
        nsg_nonprod = NetworkSecurityGroupsClassic("NSG")

    # External Connectivity
    onprem = ExpressrouteCircuits("On-Premises\nData Center")

    # Management group hierarchy relationships
    tenant_root >> Edge(label="Policy Inheritance", style="dotted") >> platform_mg
    tenant_root >> Edge(label="Policy Inheritance", style="dotted") >> landing_zones_mg

    platform_mg >> Edge(label="Contains") >> mgmt_sub
    platform_mg >> Edge(label="Contains") >> connectivity_sub
    platform_mg >> Edge(label="Contains") >> identity_sub

    landing_zones_mg >> Edge(label="Contains") >> prod_sub
    landing_zones_mg >> Edge(label="Contains") >> nonprod_sub
    landing_zones_mg >> Edge(label="Contains") >> sandbox_sub

    # Network connectivity flows
    onprem >> Edge(label="1. Hybrid Connectivity") >> expressroute
    expressroute >> Edge(label="2. ER Gateway") >> hub_vnet
    hub_vnet >> Edge(label="3. Firewall Inspection") >> azure_firewall

    # Hub-spoke peering
    azure_firewall >> Edge(label="4. VNet Peering", color="#0078D4") >> spoke_prod_vnet
    azure_firewall >> Edge(label="VNet Peering", color="#0078D4") >> spoke_nonprod_vnet

    # Application flows
    spoke_prod_vnet >> Edge(label="5. App Traffic") >> app_gateway
    app_gateway >> Edge(label="6. Route to VMs") >> app_vms
    app_vms >> Edge(label="7. Private Endpoint") >> private_endpoint_db

    # Security and monitoring flows
    spoke_prod_vnet >> Edge(label="Diagnostic Logs", style="dashed", color="#7FBA00") >> log_analytics
    spoke_nonprod_vnet >> Edge(label="Diagnostic Logs", style="dashed", color="#7FBA00") >> log_analytics
    azure_firewall >> Edge(label="Firewall Logs", style="dashed", color="#7FBA00") >> log_analytics

    log_analytics >> Edge(label="SIEM Analytics") >> sentinel
    log_analytics >> Edge(label="Metrics") >> app_insights

    # Identity flows
    aad >> Edge(label="Authentication", style="dotted", color="#8B008B") >> app_vms
    aad >> Edge(label="RBAC", style="dotted", color="#8B008B") >> prod_sub

    # Secrets management
    app_vms >> Edge(label="Get Secrets", style="dotted") >> keyvault

print("Architecture diagram generated successfully: architecture-diagram.png")
