#!/usr/bin/env python3
"""
Azure Virtual WAN Global Network Architecture Diagram Generator

This script generates an architecture diagram for Azure Virtual WAN solution
using the Python diagrams library.

Requirements:
    pip install diagrams

Usage:
    python3 generate_diagram.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.azure.network import VirtualNetworks, VirtualWans, ExpressrouteCircuits, VirtualNetworkGateways, Firewall, DNSZones, ApplicationGateway
from diagrams.azure.security import KeyVaults
from diagrams.azure.devops import ApplicationInsights
from diagrams.azure.general import Usericon
from diagrams.azure.compute import VM

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
    "Azure Virtual WAN Global Network Architecture",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # On-premises locations
    with Cluster("On-Premises Locations"):
        hq = Usericon("Headquarters\n(Primary DC)")
        branch1 = Usericon("Branch Office 1\n(Regional)")
        branch2 = Usericon("Branch Office 2\n(Regional)")

    with Cluster("Azure Global Infrastructure"):

        # Virtual WAN Hub (Central)
        with Cluster("Virtual WAN - Global"):
            vwan = VirtualWans("Azure Virtual WAN\n(Standard Tier)")

            # Regional Hubs
            with Cluster("US East Hub"):
                hub_us = VirtualNetworkGateways("Virtual Hub\n(US East)")
                vpn_us = VirtualNetworkGateways("VPN Gateway\n(Site-to-Site)")
                er_us = ExpressrouteCircuits("ExpressRoute\n(Private Peering)")
                fw_us = Firewall("Azure Firewall\n(Security)")

            with Cluster("Europe Hub"):
                hub_eu = VirtualNetworkGateways("Virtual Hub\n(West Europe)")
                vpn_eu = VirtualNetworkGateways("VPN Gateway\n(Site-to-Site)")
                fw_eu = Firewall("Azure Firewall\n(Security)")

            with Cluster("Asia Pacific Hub"):
                hub_apac = VirtualNetworkGateways("Virtual Hub\n(Southeast Asia)")
                vpn_apac = VirtualNetworkGateways("VPN Gateway\n(Site-to-Site)")
                fw_apac = Firewall("Azure Firewall\n(Security)")

        # Spoke VNets
        with Cluster("Spoke VNets - Production"):
            vnet_prod1 = VirtualNetworks("Prod VNet 1\n(10.1.0.0/16)")
            vnet_prod2 = VirtualNetworks("Prod VNet 2\n(10.2.0.0/16)")
            workloads = VM("Application\nWorkloads")

        with Cluster("Spoke VNets - Dev/Test"):
            vnet_dev = VirtualNetworks("Dev VNet\n(10.10.0.0/16)")

        # Global Services
        with Cluster("Global Services"):
            dns = DNSZones("Azure DNS\n(Private Zones)")
            monitor = ApplicationInsights("Network Watcher\n(Global Monitoring)")
            keyvault = KeyVaults("Key Vault\n(Shared Secrets)")

    # On-premises connectivity
    hq >> Edge(label="ExpressRoute\n10 Gbps") >> er_us
    branch1 >> Edge(label="Site-to-Site VPN") >> vpn_eu
    branch2 >> Edge(label="Site-to-Site VPN") >> vpn_apac

    # Hub connectivity (Global transit)
    hub_us >> Edge(label="Hub-to-Hub\nGlobal Transit") >> hub_eu
    hub_eu >> Edge(label="Hub-to-Hub\nGlobal Transit") >> hub_apac
    hub_apac >> Edge(label="Hub-to-Hub\nGlobal Transit") >> hub_us

    # Spoke connections
    hub_us >> Edge(label="VNet Peering") >> vnet_prod1
    hub_us >> Edge(label="VNet Peering") >> vnet_prod2
    hub_eu >> Edge(label="VNet Peering") >> vnet_dev

    vnet_prod1 >> workloads
    vnet_prod2 >> workloads

    # Security flows (through hub firewall)
    vnet_prod1 >> Edge(label="Outbound Traffic", style="dotted") >> fw_us
    vnet_prod2 >> Edge(label="Outbound Traffic", style="dotted") >> fw_us
    vnet_dev >> Edge(label="Outbound Traffic", style="dotted") >> fw_eu

    # Global services
    workloads >> Edge(label="DNS Resolution", style="dashed") >> dns
    hub_us >> Edge(label="Metrics", style="dashed") >> monitor
    hub_eu >> Edge(label="Metrics", style="dashed") >> monitor
    hub_apac >> Edge(label="Metrics", style="dashed") >> monitor

print("Architecture diagram generated successfully: architecture-diagram.png")
