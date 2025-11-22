#!/usr/bin/env python3
"""Generate Cisco SD-WAN Enterprise Architecture Diagram"""
from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.generic.network import Router, Switch
from diagrams.saas.cdn import Cloudflare
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.network import Internet

graph_attr = {"fontsize": "14", "bgcolor": "white", "pad": "0.5"}

with Diagram("Cisco SD-WAN Enterprise Architecture",
             filename="architecture-diagram", show=False, direction="TB", graph_attr=graph_attr, outformat="png"):

    with Cluster("SD-WAN Controllers"):
        vmanage = Grafana("vManage\n(Orchestration)")
        vsmart = Rack("vSmart\n(Control)")
        vbond = Cloudflare("vBond\n(Zero-Touch)")

    with Cluster("Data Center Hubs"):
        hubs = [Router(f"ISR 4451\nHub {i}") for i in range(1, 3)]

    with Cluster("Branch Sites (25)"):
        with Cluster("Sites 1-5"):
            branches1 = [Router(f"ISR 4331\n#{i}\nDual WAN") for i in range(1, 3)]
        with Cluster("Sites 6-10"):
            branches2 = [Router(f"ISR 4331\n#{i}\nDual WAN") for i in range(1, 3)]
        with Cluster("Sites 11-25"):
            branches3 = Router("ISR 4331\n(15 more sites)")

    with Cluster("WAN Transport"):
        broadband = Internet("Broadband\n100 Mbps")
        lte = Switch("LTE Backup\n10 GB")

    # Management
    vmanage >> Edge(label="Mgmt") >> hubs[0]
    vmanage >> Edge(label="Mgmt") >> branches1[0]
    vmanage >> branches2[0]
    vmanage >> branches3
    vsmart >> Edge(label="Control") >> hubs[0]
    vbond >> Edge(label="ZTP") >> branches1[0]

    # WAN connectivity
    branches1[0] >> Edge(label="Primary") >> broadband
    branches1[0] >> Edge(label="Backup", style="dashed") >> lte
    hubs[0] >> Edge(label="IPsec Tunnels") >> branches1[0]

print("✅ SD-WAN Enterprise diagram generated")
