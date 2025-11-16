#!/usr/bin/env python3
"""
Sample Solution - Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional architecture
diagram. Customize this for your specific solution and cloud provider.

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz  # or brew install graphviz on macOS

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.generic.network import Firewall, Router
from diagrams.generic.storage import Storage
from diagrams.generic.database import SQL
from diagrams.generic.os import Windows, LinuxGeneral
from diagrams.onprem.client import Users
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.security import Vault

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "12",
}

edge_attr = {
    "fontsize": "10",
}

with Diagram(
    "Enterprise Cloud Migration Architecture",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # Users/Clients
    users = Users("End Users")

    # Presentation Tier
    with Cluster("Presentation Tier"):
        firewall = Firewall("WAF/Firewall")
        load_balancer = Router("Load Balancer")

    # Application Tier
    with Cluster("Application Tier"):
        app_server1 = Rack("App Server 1")
        app_server2 = Rack("App Server 2")

    # Data Tier
    with Cluster("Data Tier"):
        database = SQL("Primary Database")
        storage = Storage("File Storage")

    # Infrastructure Services
    with Cluster("Infrastructure Services"):
        monitoring = Grafana("Monitoring\n& Logging")
        secrets = Vault("Secrets\nManagement")

    # Data Flow
    # 1. User requests through firewall
    users >> Edge(label="HTTPS") >> firewall

    # 2. Firewall to load balancer
    firewall >> Edge(label="Filter") >> load_balancer

    # 3. Load balancer distributes to app servers
    load_balancer >> Edge(label="Round Robin") >> app_server1
    load_balancer >> Edge(label="Round Robin") >> app_server2

    # 4. App servers connect to data layer
    app_server1 >> Edge(label="Query") >> database
    app_server2 >> Edge(label="Query") >> database
    app_server1 >> Edge(label="Files") >> storage
    app_server2 >> Edge(label="Files") >> storage

    # 5. Monitoring connections
    app_server1 >> Edge(label="Metrics", style="dashed") >> monitoring
    app_server2 >> Edge(label="Metrics", style="dashed") >> monitoring
    database >> Edge(label="Logs", style="dashed") >> monitoring

    # 6. Secrets management
    app_server1 >> Edge(label="Credentials", style="dotted") >> secrets
    app_server2 >> Edge(label="Credentials", style="dotted") >> secrets

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo view the diagram:")
print("  - Open architecture-diagram.png")
print("  - Or regenerate documents: solution-doc-builder.py --path solution-template/.../sample-solution --force")
