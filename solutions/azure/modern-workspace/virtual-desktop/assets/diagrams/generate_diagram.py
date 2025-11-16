#!/usr/bin/env python3
"""
Azure Virtual Desktop Architecture Diagram Generator

This script generates an architecture diagram for Azure Virtual Desktop solution
using the Python diagrams library.

Requirements:
    pip install diagrams

Usage:
    python3 generate_diagram.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import VM, VMLinux
from diagrams.azure.storage import StorageAccounts, BlobStorage
from diagrams.azure.network import VirtualNetworks, LoadBalancers, Firewall, ApplicationGateway
from diagrams.azure.identity import ActiveDirectory, ActiveDirectoryConnectHealth
from diagrams.azure.security import KeyVaults
from diagrams.azure.devops import ApplicationInsights
from diagrams.azure.general import Usericon
from diagrams.azure.integration import LogicApps

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
    "Azure Virtual Desktop Architecture",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # External users
    remote_users = Usericon("Remote Users\n(Web/Client)")
    corp_users = Usericon("Corporate Users\n(On-Premises)")

    with Cluster("Azure Subscription"):

        with Cluster("Resource Group - AVD Infrastructure"):

            # Identity & Access Management
            with Cluster("Identity & Access"):
                azure_ad = ActiveDirectory("Azure AD\n(Identity Provider)")
                conditional_access = ActiveDirectoryConnectHealth("Conditional Access\n(MFA/Policies)")

            # Network Infrastructure
            with Cluster("Network Layer"):
                vnet = VirtualNetworks("VNet\n(Hub-Spoke)")
                firewall = Firewall("Azure Firewall\n(Network Security)")
                gateway = ApplicationGateway("Application Gateway\n(WAF)")

            # AVD Control Plane (Microsoft-managed)
            with Cluster("AVD Control Plane (Microsoft)"):
                avd_broker = LoadBalancers("Connection Broker\n(Load Balancing)")
                avd_gateway = LoadBalancers("AVD Gateway\n(RDP Reverse Connect)")

            # Session Hosts
            with Cluster("Session Host Pool"):
                session_host1 = VM("D4s_v5\n(Windows 11 Multi)")
                session_host2 = VM("D4s_v5\n(Windows 11 Multi)")
                session_host3 = VM("D4s_v5\n(Windows 11 Multi)")

            # Storage & Profile Management
            with Cluster("User Profile Storage"):
                fslogix = BlobStorage("Azure Files Premium\n(FSLogix Containers)")
                storage = StorageAccounts("Storage Account\n(User Data)")

            # Security
            with Cluster("Security"):
                keyvault = KeyVaults("Key Vault\n(Secrets)")

            # Monitoring
            with Cluster("Monitoring"):
                log_analytics = ApplicationInsights("Log Analytics\n(AVD Insights)")
                app_insights = ApplicationInsights("Application Insights\n(Performance)")

    # Connection flows
    remote_users >> Edge(label="1. Authenticate") >> azure_ad
    corp_users >> Edge(label="1. Authenticate") >> azure_ad

    azure_ad >> Edge(label="2. Apply Policies") >> conditional_access
    conditional_access >> Edge(label="3. Connect") >> avd_gateway

    avd_gateway >> Edge(label="4. Broker Session") >> avd_broker
    avd_broker >> Edge(label="5. Assign Host") >> session_host1
    avd_broker >> Edge(label="5. Assign Host") >> session_host2
    avd_broker >> Edge(label="5. Assign Host") >> session_host3

    # Profile Management
    session_host1 >> Edge(label="Load Profile") >> fslogix
    session_host2 >> Edge(label="Load Profile") >> fslogix
    session_host3 >> Edge(label="Load Profile") >> fslogix

    # Network Security
    avd_gateway >> Edge(label="Secure Tunnel", style="dotted") >> firewall
    firewall >> Edge(label="Allow Traffic") >> vnet

    # Security flows
    session_host1 >> Edge(label="Get Secrets", style="dotted") >> keyvault

    # Monitoring flows
    session_host1 >> Edge(label="Metrics & Logs", style="dashed") >> log_analytics
    session_host2 >> Edge(label="Metrics & Logs", style="dashed") >> log_analytics
    session_host3 >> Edge(label="Metrics & Logs", style="dashed") >> log_analytics
    fslogix >> Edge(label="Storage Metrics", style="dashed") >> app_insights

print("Architecture diagram generated successfully: architecture-diagram.png")
