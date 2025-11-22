#!/usr/bin/env python3
"""
NVIDIA Omniverse Enterprise Collaboration Platform - Architecture Diagram Generator

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.compute import Server
from diagrams.onprem.network import Nginx
from diagrams.generic.storage import Storage
from diagrams.onprem.client import Users, Client
from diagrams.onprem.vcs import Git

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "NVIDIA Omniverse Enterprise Collaboration Platform",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Design Team
    with Cluster("Design Team (50 Users)"):
        designers = Users("Designers\nEngineers\nArtists")

    # Workstation Layer
    with Cluster("RTX Workstations (50 Units)"):
        ws1 = Client("Dell Precision\nRTX A6000 48GB")
        ws2 = Client("Dell Precision\nRTX A6000 48GB")
        ws3 = Client("Dell Precision\nRTX A6000 48GB")
        workstations = [ws1, ws2, ws3]

    # Collaboration Infrastructure
    with Cluster("Omniverse Collaboration Infrastructure"):
        with Cluster("Nucleus Servers (HA)"):
            nucleus_primary = Git("Nucleus Primary\nUSD Scene Control")
            nucleus_replica = Git("Nucleus Replica\nHA Failover")

    # CAD/DCC Tool Connectors
    with Cluster("Native Tool Connectors"):
        revit = Server("Revit\nConnector")
        solidworks = Server("SolidWorks\nConnector")
        rhino = Server("Rhino/Blender\nConnectors")
        connectors = [revit, solidworks, rhino]

    # Rendering Infrastructure
    with Cluster("Rendering Infrastructure"):
        farm_manager = Server("Omniverse Farm\nManager")
        with Cluster("Render Nodes (10 Nodes)"):
            render1 = Server("Render Node\nRTX A6000")
            render2 = Server("Render Node\nRTX A6000")
            render3 = Server("Render Node\nRTX A6000")
            render_nodes = [render1, render2, render3]

    # Network Fabric
    with Cluster("High-Speed Network"):
        network = Nginx("100 GbE Switch\nFast File Transfers")

    # Storage Layer
    with Cluster("USD Scene Storage (100 TB)"):
        storage = Storage("NetApp AFF\n100 TB NVMe\n3-5 GB/s")

    # Data Flow
    designers >> Edge(label="Use Native Tools") >> connectors
    connectors >> Edge(label="USD Sync") >> nucleus_primary
    nucleus_primary >> Edge(label="Replicate", style="dashed") >> nucleus_replica

    workstations >> Edge(label="Real-Time\nCollaboration") >> nucleus_primary
    workstations >> Edge(label="100 GbE", color="green") >> network

    nucleus_primary >> Edge(label="Store USD\nScenes") >> storage

    designers >> Edge(label="Submit Renders") >> farm_manager
    farm_manager >> Edge(label="Distribute Jobs") >> render_nodes
    render_nodes >> Edge(label="Read Scenes") >> storage

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/nvidia/modern-workspace/omniverse-enterprise --force")
