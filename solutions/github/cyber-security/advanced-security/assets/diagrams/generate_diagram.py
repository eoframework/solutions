#!/usr/bin/env python3
"""
GitHub Advanced Security - Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional architecture
diagram with official GitHub and cloud provider icons.

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz  # or brew install graphviz on macOS

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.saas.alerting import Pagerduty
from diagrams.saas.logging import Datadog
from diagrams.generic.database import SQL
from diagrams.generic.network import Firewall
from diagrams.programming.language import Python, Javascript, Java, Go
from diagrams.custom import Custom
import os

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
}

node_attr = {
    "fontsize": "11",
}

edge_attr = {
    "fontsize": "9",
}

with Diagram(
    "GitHub Advanced Security Architecture",
    filename=os.path.join(script_dir, "architecture-diagram"),
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # Developer Workflow
    with Cluster("Developer Workflow"):
        developer = Github("Developer\nWorkstation")
        pr = Github("Pull Request")

    # GitHub Platform
    with Cluster("GitHub Enterprise Cloud"):
        with Cluster("Repository Layer"):
            repos = Github("200 Repositories")
            branches = Github("Branch\nProtection")

        with Cluster("GitHub Advanced Security"):
            codeql = GithubActions("CodeQL\nScanning")
            secret_scan = Firewall("Secret\nScanning")
            dependabot = GithubActions("Dependabot\nAlerts")
            push_protect = Firewall("Push\nProtection")

        with Cluster("Actions Infrastructure"):
            workflows = GithubActions("CodeQL\nWorkflows")
            runners = GithubActions("GitHub-Hosted\nRunners")

    # Language Support
    with Cluster("Language Analysis"):
        js = Javascript("JavaScript\nTypeScript")
        python = Python("Python")
        java = Java("Java")
        go = Go("Go")

    # Security Operations
    with Cluster("Security Operations"):
        with Cluster("Alert Management"):
            alerts = Firewall("Security\nAlerts")
            dashboard = Datadog("Security\nOverview")

        with Cluster("Integration"):
            siem = SQL("SIEM\n(Splunk/Sentinel)")
            jira = SQL("JIRA\nTickets")
            pagerduty = Pagerduty("PagerDuty\nAlerts")

    # Data Flow
    # 1. Developer pushes code
    developer >> Edge(label="git push") >> repos
    developer >> Edge(label="open PR") >> pr

    # 2. PR triggers scanning
    pr >> Edge(label="triggers") >> workflows
    workflows >> Edge(label="runs on") >> runners

    # 3. CodeQL analysis
    runners >> Edge(label="analyze") >> codeql
    codeql >> Edge(label="scan") >> js
    codeql >> Edge(label="scan") >> python
    codeql >> Edge(label="scan") >> java
    codeql >> Edge(label="scan") >> go

    # 4. Security features
    repos >> Edge(label="monitors") >> secret_scan
    repos >> Edge(label="checks") >> dependabot
    developer >> Edge(label="blocked") >> push_protect

    # 5. Branch protection
    codeql >> Edge(label="status check") >> branches
    branches >> Edge(label="protects") >> repos

    # 6. Alerts and integration
    codeql >> Edge(label="creates") >> alerts
    secret_scan >> Edge(label="creates") >> alerts
    dependabot >> Edge(label="creates") >> alerts

    alerts >> Edge(label="webhook") >> siem
    alerts >> Edge(label="webhook") >> jira
    alerts >> Edge(label="critical") >> pagerduty

    # 7. Dashboard
    alerts >> Edge(label="aggregates") >> dashboard

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo view the diagram:")
print("  - Open architecture-diagram.png in the assets/diagrams folder")
