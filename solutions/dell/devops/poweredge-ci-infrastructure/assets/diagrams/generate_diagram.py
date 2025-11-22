#!/usr/bin/env python3
"""
Dell PowerEdge CI/CD Infrastructure - Architecture Diagram Generator

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
from diagrams.onprem.client import Users
from diagrams.onprem.ci import Jenkins, GitlabCI as Gitlab
from diagrams.onprem.vcs import Github
from diagrams.onprem.container import Docker
from diagrams.generic.storage import Storage
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.programming.language import Java, Python, NodeJS

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "Dell PowerEdge CI/CD Infrastructure",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Developers
    with Cluster("Development Team"):
        devs = Users("Developers\n10-50 Users")

    # Source Control
    with Cluster("Source Control"):
        git = Github("Git Repository\nGitHub Enterprise")

    # CI/CD Platform
    with Cluster("CI/CD Platform (Dell PowerEdge)"):
        jenkins_master = Jenkins("Jenkins Master\nPowerEdge R750\n256GB RAM")

        with Cluster("Build Agent Pool (10-20 Servers)"):
            agent1 = Server("Build Agent\nPowerEdge R650")
            agent2 = Server("Build Agent\nPowerEdge R650")
            agent3 = Server("Build Agent\nPowerEdge R650")
            agents = [agent1, agent2, agent3]

    # Container Platform
    with Cluster("Container Platform"):
        docker_registry = Docker("Docker Registry\nHarbor")
        docker_builds = Docker("Docker Builds\nContainerized")

    # Artifact Storage
    with Cluster("Artifact & Package Management"):
        artifactory = Storage("Artifactory\nMaven/npm/PyPI")
        dell_storage = Storage("Dell PowerStore\nNFS Shares")

    # Testing & Security
    with Cluster("Testing & Security"):
        sonarqube = Server("SonarQube\nCode Quality")
        snyk = Server("Snyk\nDependency Scan")

    # Deployment
    with Cluster("Deployment Targets"):
        dev_env = Server("Dev\nEnvironment")
        staging = Server("Staging\nEnvironment")
        prod = Server("Production\nEnvironment")

    # Monitoring
    with Cluster("Monitoring"):
        prometheus = Prometheus("Prometheus\nMetrics")
        grafana = Grafana("Grafana\nDashboards")

    # Data Flow
    devs >> Edge(label="Git Push") >> git
    git >> Edge(label="Webhook") >> jenkins_master
    jenkins_master >> Edge(label="Schedule Build") >> agents

    for agent in agents:
        agent >> Edge(label="Build Artifacts") >> artifactory
        agent >> Edge(label="Docker Build") >> docker_registry
        agent >> Edge(label="Code Scan") >> sonarqube

    docker_registry >> Edge(label="Deploy") >> [dev_env, staging]
    staging >> Edge(label="Promote") >> prod

    agents >> Edge(label="Metrics", style="dashed") >> prometheus
    prometheus >> Edge(label="Visualize") >> grafana

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/dell/devops/poweredge-ci-infrastructure --force")
