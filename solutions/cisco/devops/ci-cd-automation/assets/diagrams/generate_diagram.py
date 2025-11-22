#!/usr/bin/env python3
"""Generate Cisco Network CI/CD Automation Architecture Diagram"""
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.vcs import Gitlab
from diagrams.onprem.ci import Jenkins
from diagrams.programming.framework import React
from diagrams.generic.network import Switch, Router
from diagrams.generic.database import SQL
from diagrams.onprem.security import Vault

graph_attr = {"fontsize": "14", "bgcolor": "white", "pad": "0.5"}

with Diagram("Cisco Network CI/CD Automation Architecture",
             filename="architecture-diagram", show=False, direction="LR", graph_attr=graph_attr, outformat="png"):

    with Cluster("GitOps Platform"):
        gitlab = Gitlab("GitLab Premium\n(Self-Hosted)")
        runners = [Jenkins("CI/CD Runner") for _ in range(2)]
        gitlab >> Edge(label="Trigger") >> runners

    with Cluster("Automation Tools"):
        ansible = React("Ansible\nPlaybooks")
        terraform = React("Terraform\nModules")
        vault_sec = Vault("Vault\n(Secrets)")

    with Cluster("Source of Truth"):
        netbox = SQL("NetBox IPAM\n(Inventory)")

    with Cluster("Network Devices (100)"):
        with Cluster("IOS-XE"):
            ios_devices = [Switch("Catalyst") for _ in range(2)]
        with Cluster("NX-OS"):
            nxos_devices = [Switch("Nexus") for _ in range(2)]
        with Cluster("ASA"):
            asa = Router("Firewall")

    # Workflows
    runners[0] >> Edge(label="Execute") >> ansible
    runners[0] >> terraform
    ansible >> Edge(label="Get Inventory") >> netbox
    ansible >> Edge(label="Get Creds") >> vault_sec
    ansible >> Edge(label="Configure") >> ios_devices
    ansible >> nxos_devices
    ansible >> asa

print("✅ Network CI/CD Automation diagram generated")
