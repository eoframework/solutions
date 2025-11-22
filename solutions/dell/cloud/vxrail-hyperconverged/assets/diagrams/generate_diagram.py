#!/usr/bin/env python3
"""
Dell VxRail Hyperconverged Infrastructure - Architecture Diagram Generator

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
from diagrams.onprem.network import Internet
from diagrams.generic.virtualization import Virtualbox as Vmware
from diagrams.k8s.clusterconfig import HPA
from diagrams.generic.storage import Storage

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "Dell VxRail Hyperconverged Infrastructure",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Management
    with Cluster("Management & Orchestration"):
        vcenter = Vmware("vCenter\nServer")
        vxrail_mgr = Server("VxRail\nManager")
        k8s_mgmt = HPA("Kubernetes\nTanzu")

    # VxRail Cluster
    with Cluster("VxRail Cluster (4-32 Nodes)"):
        node1 = Server("VxRail Node\nESXi + vSAN")
        node2 = Server("VxRail Node\nESXi + vSAN")
        node3 = Server("VxRail Node\nESXi + vSAN")
        nodes = [node1, node2, node3]

    # Storage
    with Cluster("Software-Defined Storage"):
        vsan = Storage("vSAN Datastore\nMulti-Tier Policies\nFTT=0/1/2")

    # Network
    with Cluster("Network Fabric"):
        network = Internet("PowerSwitch\nLeaf-Spine\n25GbE/100GbE")

    # Workloads
    with Cluster("Traditional Workloads"):
        vm1 = Vmware("SQL Server")
        vm2 = Vmware("App Servers")

    with Cluster("Cloud-Native Workloads"):
        k8s = HPA("Kubernetes\nClusters")
        containers = HPA("Microservices")

    # Data Flow
    vcenter >> nodes
    vxrail_mgr >> nodes
    k8s_mgmt >> k8s

    for node in nodes:
        node >> vsan
        node >> network

    vsan >> [vm1, vm2, k8s, containers]

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/cloud/vxrail-hyperconverged --force")
