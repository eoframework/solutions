#!/usr/bin/env python3
"""Generate Cisco ISE Secure Network Access Architecture Diagram"""
from diagrams import Diagram, Cluster, Edge
from diagrams.generic.compute import Rack
from diagrams.generic.network import Switch, Subnet
from diagrams.generic.database import SQL
from diagrams.onprem.security import Vault
from diagrams.generic.device import Mobile, Tablet

graph_attr = {"fontsize": "14", "bgcolor": "white", "pad": "0.5"}

with Diagram("Cisco ISE Secure Network Access Architecture",
             filename="architecture-diagram", show=False, direction="TB", graph_attr=graph_attr, outformat="png"):

    with Cluster("ISE Infrastructure (HA)"):
        ise_primary = Rack("ISE 3615\nPrimary PSN")
        ise_secondary = Rack("ISE 3615\nSecondary PSN")
        ise_primary - Edge(label="HA Sync") - ise_secondary

    ad = SQL("Active Directory\n(Identity Source)")

    with Cluster("Network Infrastructure"):
        with Cluster("Wired"):
            switches = [Switch(f"Catalyst 9k\n802.1X") for _ in range(2)]
        with Cluster("Wireless"):
            wlc = Subnet("WLC 9800\n802.1X")

    with Cluster("User Devices (2000 Endpoints)"):
        corporate = [Mobile("Corporate\nLaptops") for _ in range(2)]
        byod = [Tablet("BYOD\n(iOS/Android)") for _ in range(2)]
        iot = Mobile("IoT/Printers\n(MAB)")

    with Cluster("TrustSec"):
        sgt = Vault("Security Groups\n(SGT Tags)")

    # Auth flows
    switches[0] >> Edge(label="RADIUS") >> ise_primary
    wlc >> Edge(label="RADIUS") >> ise_primary
    ise_primary >> Edge(label="LDAP") >> ad
    ise_primary >> Edge(label="Assign SGT") >> sgt

    corporate[0] >> Edge(label="802.1X") >> switches[0]
    byod[0] >> Edge(label="802.1X + Portal") >> wlc
    iot >> Edge(label="MAB") >> switches[1]

print("✅ ISE Secure Access diagram generated")
