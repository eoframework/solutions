#!/usr/bin/env python3
"""
Dell SafeID Authentication Platform - Architecture Diagram Generator

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
from diagrams.onprem.client import Users, Client
from diagrams.onprem.security import Vault
from diagrams.onprem.network import Internet
from diagrams.saas.identity import Okta
from diagrams.generic.device import Mobile

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "Dell SafeID Authentication Platform",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Users
    with Cluster("End Users"):
        users = Users("Employees\nContractors\nPartners")
        desktop = Client("Desktop\nLogin")
        mobile = Mobile("Mobile\nApp")

    # SafeID Platform
    with Cluster("Dell SafeID Platform"):
        safeid_lb = Internet("Load\nBalancer")
        safeid1 = Server("SafeID Server\n(Primary)")
        safeid2 = Server("SafeID Server\n(Secondary)")

        with Cluster("Authentication Methods"):
            token = Mobile("Soft Token\nMobile App")
            biometric = Vault("Biometric\nFingerprint/Face")
            push = Client("Push\nNotification")

    # Identity Directory
    with Cluster("Identity Directory"):
        ad = Okta("Active Directory\nUser Accounts")
        azure_ad = Okta("Azure AD\nHybrid Identity")

    # Protected Resources
    with Cluster("Protected Resources"):
        saml_apps = Client("SAML Apps\nSalesforce\nOffice 365")
        vpn = Internet("VPN Gateway\nRADIUS")
        network = Internet("Network\n802.1X WiFi")

    # SIEM
    with Cluster("Security Monitoring"):
        siem = Server("SIEM\nSplunk/QRadar\nAudit Logs")

    # Data Flow
    users >> Edge(label="Login Attempt") >> desktop
    desktop >> Edge(label="Auth Request") >> safeid_lb
    safeid_lb >> [safeid1, safeid2]

    safeid1 >> Edge(label="Verify Credentials") >> ad
    safeid1 >> Edge(label="MFA Challenge") >> [token, biometric, push]

    token >> Edge(label="OTP") >> mobile
    mobile >> Edge(label="Approve") >> safeid1

    safeid1 >> Edge(label="SAML Assertion") >> saml_apps
    safeid1 >> Edge(label="RADIUS Accept") >> vpn
    safeid1 >> Edge(label="802.1X Auth") >> network

    safeid1 >> Edge(label="Auth Logs", style="dashed") >> siem
    safeid2 >> Edge(label="Auth Logs", style="dashed") >> siem

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/cyber-security/safeid-authentication --force")
