#!/usr/bin/env python3
"""Generate Cisco HyperFlex Hyperconverged Infrastructure Architecture Diagram"""
from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.onprem.compute import Server
from diagrams.onprem.network import Nginx
from diagrams.saas.cdn import Cloudflare
from diagrams.onprem.monitoring import Grafana

graph_attr = {"fontsize": "14", "bgcolor": "white", "pad": "0.5"}

with Diagram("Cisco HyperFlex Hyperconverged Infrastructure",
             filename="architecture-diagram", show=False, direction="TB", graph_attr=graph_attr, outformat="png"):

    with Cluster("Management"):
        intersight = Cloudflare("Cisco Intersight\n(Cloud)")
        vcenter = Grafana("vCenter Server")

    with Cluster("HyperFlex Cluster"):
        with Cluster("Fabric Interconnects (HA)"):
            fi1 = Nginx("UCS 6454 FI-A")
            fi2 = Nginx("UCS 6454 FI-B")

        with Cluster("HyperFlex Nodes (4-Node All-Flash)"):
            nodes = [Rack(f"HX240c M5\nNode {i}\n64 vCPU, 768GB RAM\n7.68TB NVMe") for i in range(1, 5)]

        with Cluster("Distributed Storage"):
            storage = Server("HyperFlex Data Platform\n20TB Usable\n(60TB with 3:1 dedup)")

    with Cluster("Virtual Machines"):
        vms = [Server(f"VM Pool\n(200-300 VMs)")]

    # Connections
    intersight >> Edge(label="Cloud Mgmt", style="dashed") >> nodes[0]
    vcenter >> Edge(label="VM Mgmt") >> nodes[0]
    for node in nodes:
        node >> Edge(label="25GbE") >> fi1
        node >> fi2
        node >> Edge(label="Storage") >> storage
    nodes[0] >> Edge(label="Host") >> vms

print("✅ HyperFlex HCI diagram generated")
