#!/usr/bin/env python3
"""
Generate Cisco DNA Center Network Analytics Architecture Diagram
Uses the Python diagrams library with generic icons (Cisco icons not available in diagrams library)
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.generic.network import Router, Switch
from diagrams.generic.compute import Rack
from diagrams.generic.database import SQL
from diagrams.onprem.network import Nginx
from diagrams.onprem.monitoring import Grafana
from diagrams.saas.chat import Slack

# Diagram configuration
graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
}

with Diagram("Cisco DNA Center Network Analytics Architecture",
             filename="architecture-diagram",
             show=False,
             direction="TB",
             graph_attr=graph_attr,
             outformat="png"):

    # Management Layer
    with Cluster("Management & Orchestration"):
        dna_primary = Rack("DNA Center\nPrimary")
        dna_secondary = Rack("DNA Center\nSecondary (HA)")
        intersight = Grafana("Cisco Intersight\n(Cloud)")

        dna_primary - Edge(label="HA Sync") - dna_secondary

    # Integration Layer
    with Cluster("External Integrations"):
        ad = SQL("Active Directory\n(LDAP)")
        servicenow = Slack("ServiceNow\n(ITSM)")
        netbox = SQL("NetBox\n(IPAM)")

    # Network Infrastructure
    with Cluster("Network Infrastructure (200 Devices)"):
        with Cluster("Campus Core"):
            core1 = Switch("Core Switch 1\n(Catalyst 9500)")
            core2 = Switch("Core Switch 2\n(Catalyst 9500)")

        with Cluster("Distribution Layer"):
            dist_switches = [Switch(f"Catalyst 9300\n#{i}") for i in range(1, 4)]

        with Cluster("Access Layer"):
            access_switches = [Switch("Catalyst 9200") for _ in range(3)]

        with Cluster("Branch Sites"):
            branch_routers = [Router(f"ISR 4000\n#{i}") for i in range(1, 3)]

        with Cluster("Wireless"):
            wlc = Router("WLC 9800")

    # Analytics Layer
    with Cluster("AI Analytics & Monitoring"):
        analytics = Grafana("AI Network\nAnalytics")
        app_mon = Grafana("Application\nExperience")

    # Connections - Management
    dna_primary >> Edge(label="NETCONF/RESTCONF") >> [core1, core2]
    dna_primary >> Edge(label="Device Management") >> dist_switches
    dna_primary >> Edge(label="Telemetry") >> access_switches
    dna_primary >> Edge(label="Config") >> branch_routers
    dna_primary >> wlc

    # Analytics
    dna_primary >> Edge(label="Telemetry Data") >> analytics
    dna_primary >> app_mon

    # Integrations
    dna_primary >> Edge(label="LDAP Auth") >> ad
    dna_primary >> Edge(label="Ticket API") >> servicenow
    dna_primary >> Edge(label="IPAM API") >> netbox

    # Cloud Management
    dna_primary >> Edge(label="Cloud API", style="dashed") >> intersight

    # Network hierarchy
    core1 >> dist_switches
    core2 >> dist_switches
    dist_switches[0] >> access_switches

print("✅ DNA Center Network Analytics diagram generated: architecture-diagram.png")
