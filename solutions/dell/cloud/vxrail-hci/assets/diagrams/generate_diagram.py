#!/usr/bin/env python3
"""
Dell VxRail HCI Platform - Architecture Diagram Generator

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
from diagrams.generic.storage import Storage
from diagrams.onprem.monitoring import Prometheus

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
    "Dell VxRail HCI Platform",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # Management Layer
    with Cluster("Management Layer"):
        vcenter = Vmware("vCenter Server\nCluster Management")
        vxrail_mgr = Server("VxRail Manager\nLifecycle Management")

    # VxRail Cluster
    with Cluster("VxRail E560 Cluster (4-16 Nodes)"):
        with Cluster("Node Specs"):
            node1 = Server("VxRail E560\nDual Xeon Gold\n768GB RAM")
            node2 = Server("VxRail E560\nDual Xeon Gold\n768GB RAM")
            node3 = Server("VxRail E560\nDual Xeon Gold\n768GB RAM")
            node4 = Server("VxRail E560\nDual Xeon Gold\n768GB RAM")

        nodes = [node1, node2, node3, node4]

    # vSAN Storage
    with Cluster("VMware vSAN Storage"):
        vsan = Storage("Distributed vSAN\nFTT=1 RAID-5\n80TB Usable")

    # Network
    with Cluster("Network Infrastructure"):
        switches = Internet("Dell PowerSwitch\n25GbE ToR Switches")

    # VM Workloads
    with Cluster("VM Workloads"):
        vm_db = Vmware("Database\nServers")
        vm_app = Vmware("Application\nServers")
        vm_web = Vmware("Web\nServers")

    # Data Flow
    vcenter >> Edge(label="Manage") >> nodes
    vxrail_mgr >> Edge(label="Health Monitoring") >> nodes

    # vSAN connectivity
    for node in nodes:
        node >> Edge(label="vSAN Traffic") >> vsan

    # Network connectivity
    for node in nodes:
        node >> Edge(label="25GbE") >> switches

    # VM placement
    vsan >> Edge(label="Storage") >> [vm_db, vm_app, vm_web]

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/cloud/vxrail-hci --force")
