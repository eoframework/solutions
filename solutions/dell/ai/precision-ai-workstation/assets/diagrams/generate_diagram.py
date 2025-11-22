#!/usr/bin/env python3
"""
Dell Precision AI Workstation Infrastructure - Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional architecture
diagram for Dell Precision AI workstation infrastructure.

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz  # or brew install graphviz on macOS

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.compute import Server
from diagrams.onprem.client import Users, Client
from diagrams.onprem.network import Internet
from diagrams.onprem.monitoring import Datadog
from diagrams.generic.storage import Storage
from diagrams.programming.framework import React

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

edge_attr = {
    "fontsize": "9",
}

with Diagram(
    "Dell Precision AI Workstation Infrastructure",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # User Access Layer
    with Cluster("Data Scientists (10 Users)"):
        users = Users("Data Scientists")
        jupyter = Client("Jupyter Lab")
        vscode = Client("VS Code")
        pytorch = React("PyTorch/TensorFlow")

    # Workstation Cluster
    with Cluster("Dell Precision 7960 Workstations (10 Units)"):
        with Cluster("Per Workstation"):
            workstation = Server("Dual Xeon Gold 6430\n512GB RAM\n4TB NVMe SSD")
            gpu = Server("NVIDIA RTX A6000\n48GB GPU Memory\n10,752 CUDA Cores")

        workstation_cluster = [workstation >> gpu]

    # Shared Storage
    with Cluster("Shared Storage"):
        powerscale = Storage("Dell PowerScale F600\n100TB NAS\nNFS/SMB")

    # Network Infrastructure
    with Cluster("Network Infrastructure"):
        switch = Internet("10GbE Network Fabric\nDell PowerSwitch")

    # Monitoring
    with Cluster("Monitoring & Management"):
        monitoring = Datadog("Datadog Monitoring\nGPU Metrics")

    # Data Flow
    # Users access workstations
    users >> Edge(label="SSH/Remote Desktop") >> workstation
    jupyter >> Edge(label="Development") >> workstation
    vscode >> Edge(label="Development") >> workstation
    pytorch >> Edge(label="Training Workloads") >> gpu

    # Workstation to storage
    workstation >> Edge(label="Dataset Access\n10GbE") >> switch
    switch >> Edge(label="NFS Mount") >> powerscale

    # Monitoring
    workstation >> Edge(label="Metrics", style="dashed") >> monitoring
    gpu >> Edge(label="GPU Utilization", style="dashed") >> monitoring

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/ai/precision-ai-workstation --force")
