#!/usr/bin/env python3
"""
NVIDIA DGX SuperPOD AI Infrastructure - Architecture Diagram Generator

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
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.client import Users
from diagrams.programming.framework import React

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "NVIDIA DGX SuperPOD AI Infrastructure",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # AI Research Team
    with Cluster("AI Research Team"):
        researchers = Users("Data Scientists\n50-75 Users")

    # DGX Compute Layer
    with Cluster("DGX H100 Compute Layer (64 GPUs)"):
        with Cluster("DGX Systems (8 Nodes)"):
            dgx1 = Server("DGX H100\n8x H100 80GB")
            dgx2 = Server("DGX H100\n8x H100 80GB")
            dgx3 = Server("DGX H100\n8x H100 80GB")
            dgx_nodes = [dgx1, dgx2, dgx3]

    # Network Fabric
    with Cluster("High-Speed Network Fabric"):
        ib_switch1 = Nginx("InfiniBand\nQuantum-2 400G")
        ib_switch2 = Nginx("InfiniBand\nQuantum-2 400G")
        ib_switches = [ib_switch1, ib_switch2]

    # Management & Orchestration
    with Cluster("Management & Orchestration"):
        base_command = Server("Base Command\nManager")
        scheduler = React("Job Scheduler\nSlurm/PBS")

    # Storage Layer
    with Cluster("High-Performance Storage (1 PB)"):
        storage_primary = Storage("Base Command\nStorage\n1 PB NVMe")
        storage_backup = Storage("Backup Storage\n500 TB")

    # Monitoring & Operations
    with Cluster("Monitoring & Operations"):
        prometheus = Prometheus("Prometheus\nGPU Metrics")
        grafana = Grafana("Grafana\nDashboards")

    # Data Flow
    researchers >> Edge(label="Submit Jobs") >> base_command
    base_command >> Edge(label="Schedule") >> scheduler
    scheduler >> Edge(label="Allocate GPUs") >> dgx_nodes

    for dgx in dgx_nodes:
        dgx >> Edge(label="400G IB", color="green") >> ib_switches

    dgx_nodes >> Edge(label="Read/Write\n14 GB/s") >> storage_primary
    storage_primary >> Edge(label="Backup", style="dashed") >> storage_backup

    dgx_nodes >> Edge(label="Metrics", style="dashed") >> prometheus
    base_command >> Edge(label="Logs", style="dashed") >> prometheus
    prometheus >> Edge(label="Visualize") >> grafana

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/nvidia/ai/dgx-superpod --force")
