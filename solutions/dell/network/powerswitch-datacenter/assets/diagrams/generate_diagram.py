#!/usr/bin/env python3
"""
Dell PowerSwitch Datacenter Networking - Architecture Diagram Generator

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.network import Internet
from diagrams.onprem.compute import Server
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

with Diagram(
    "Dell PowerSwitch Datacenter Networking",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Spine Layer
    with Cluster("Spine Layer (Core)"):
        spine1 = Internet("PowerSwitch S5232F\n32x 100GbE Ports\nOSPF/BGP Routing")
        spine2 = Internet("PowerSwitch S5232F\n32x 100GbE Ports\nOSPF/BGP Routing")
        spines = [spine1, spine2]

    # Leaf Layer
    with Cluster("Leaf Layer (Access)"):
        with Cluster("Leaf Pair 1 (VLT)"):
            leaf1 = Internet("PowerSwitch S5248F\n48x 25GbE + 6x 100GbE")
            leaf2 = Internet("PowerSwitch S5248F\n48x 25GbE + 6x 100GbE")

        with Cluster("Leaf Pair 2 (VLT)"):
            leaf3 = Internet("PowerSwitch S5248F\n48x 25GbE + 6x 100GbE")
            leaf4 = Internet("PowerSwitch S5248F\n48x 25GbE + 6x 100GbE")

        leafs = [leaf1, leaf2, leaf3, leaf4]

    # Server Layer
    with Cluster("Compute Rack 1"):
        srv1 = Server("Server 1\nDual 25GbE NICs\nLACP Bonding")
        srv2 = Server("Server 2\nDual 25GbE NICs\nLACP Bonding")
        srv3 = Server("Server 3\nDual 25GbE NICs\nLACP Bonding")

    with Cluster("Compute Rack 2"):
        srv4 = Server("Server 4\nDual 25GbE NICs")
        srv5 = Server("Server 5\nDual 25GbE NICs")

    with Cluster("Storage Systems"):
        storage1 = Storage("Storage Array\nDual 100GbE NICs")

    # Management
    with Cluster("Network Management"):
        openmanage = Server("OpenManage\nEnterprise\nCentralized Mgmt")
        monitoring = Prometheus("Network\nMonitoring\nsFlow/NetFlow")

    # Data Flow - Spine to Leaf (100GbE uplinks)
    for leaf in leafs:
        for spine in spines:
            leaf >> Edge(label="100GbE\nECMP", color="blue") >> spine

    # Data Flow - Leaf to Servers (25GbE)
    leaf1 >> Edge(label="25GbE") >> [srv1, srv2, srv3]
    leaf2 >> Edge(label="25GbE") >> [srv1, srv2, srv3]

    leaf3 >> Edge(label="25GbE") >> [srv4, srv5]
    leaf4 >> Edge(label="25GbE") >> [srv4, srv5]

    # Storage connectivity
    leaf1 >> Edge(label="100GbE") >> storage1
    leaf2 >> Edge(label="100GbE") >> storage1

    # Management
    openmanage >> Edge(label="Manage", style="dashed") >> leafs
    openmanage >> Edge(label="Manage", style="dashed") >> spines

    leafs[0] >> Edge(label="sFlow", style="dotted") >> monitoring
    spines[0] >> Edge(label="NetFlow", style="dotted") >> monitoring

print("✅ Diagram generated: architecture-diagram.png")
print("\nKey Features:")
print("  - Leaf-Spine (Clos) topology")
print("  - VLT pairs for high availability")
print("  - ECMP load balancing across spine uplinks")
print("  - 25GbE server connectivity, 100GbE spine fabric")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/network/powerswitch-datacenter --force")
