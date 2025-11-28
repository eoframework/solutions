#!/usr/bin/env python3
"""
GitHub Actions Enterprise CI/CD - Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional architecture
diagram with official GitHub, AWS, and cloud provider icons.

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
from diagrams.aws.compute import EC2AutoScaling, EC2, EKS, ECR
from diagrams.aws.network import VPC, ELB
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SQS
from diagrams.saas.alerting import Pagerduty
from diagrams.saas.logging import Datadog
from diagrams.saas.chat import Slack
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
    "GitHub Actions Enterprise CI/CD Architecture",
    filename=os.path.join(script_dir, "architecture-diagram"),
    show=False,
    direction="TB",
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
        with Cluster("Organization"):
            repos = Github("50 Application\nRepositories")
            dot_github = Github(".github\nWorkflow Templates")

        with Cluster("GitHub Actions"):
            workflows = GithubActions("Reusable\nWorkflows (15)")
            environments = GithubActions("Environments\n(dev/staging/prod)")
            secrets = GithubActions("Organization\nSecrets")

        with Cluster("Container Registry"):
            ghcr = Github("GitHub\nPackages (GHCR)")

    # AWS Infrastructure
    with Cluster("AWS Cloud (us-east-1)"):
        with Cluster("VPC - Runner Infrastructure"):
            vpc = VPC("Private VPC\n10.0.0.0/16")

            with Cluster("Auto Scaling Groups"):
                linux_asg = EC2AutoScaling("Linux Runners\n(16 x c5.2xlarge)")
                windows_asg = EC2AutoScaling("Windows Runners\n(4 x c5.2xlarge)")

            with Cluster("Runner Instances"):
                linux_runners = [EC2("Linux\nRunner") for _ in range(3)]
                windows_runner = EC2("Windows\nRunner")

        with Cluster("Security & Identity"):
            oidc = IAM("OIDC Provider\n(GitHub)")
            iam_roles = IAM("IAM Roles\n(per environment)")

        with Cluster("Container Services"):
            ecr = ECR("ECR Registry\n(Production)")
            eks = EKS("EKS Clusters\n(dev/staging/prod)")

        with Cluster("Monitoring"):
            cloudwatch = Cloudwatch("CloudWatch\nDashboards")

    # External Integrations
    with Cluster("Integrations"):
        datadog = Datadog("Datadog\nMetrics")
        slack = Slack("Slack\nNotifications")
        pagerduty = Pagerduty("PagerDuty\nAlerts")

    # Data Flow
    # 1. Developer workflow
    developer >> Edge(label="git push") >> repos
    developer >> Edge(label="open PR") >> pr

    # 2. PR triggers workflow
    pr >> Edge(label="triggers") >> workflows
    workflows >> Edge(label="uses") >> dot_github

    # 3. Jobs run on self-hosted runners
    workflows >> Edge(label="runs-on:\nself-hosted") >> linux_asg
    workflows >> Edge(label="runs-on:\nwindows") >> windows_asg

    # 4. ASG manages runners
    linux_asg >> Edge(label="scales") >> linux_runners
    windows_asg >> Edge(label="scales") >> windows_runner

    # 5. OIDC authentication
    workflows >> Edge(label="OIDC token") >> oidc
    oidc >> Edge(label="assume role") >> iam_roles

    # 6. Container workflow
    workflows >> Edge(label="docker push") >> ghcr
    workflows >> Edge(label="docker push\n(prod)") >> ecr

    # 7. Deployment
    iam_roles >> Edge(label="kubectl") >> eks
    workflows >> Edge(label="deploy") >> environments

    # 8. Monitoring
    linux_asg >> Edge(label="metrics", style="dashed") >> cloudwatch
    workflows >> Edge(label="metrics", style="dashed") >> datadog

    # 9. Notifications
    workflows >> Edge(label="success/failure") >> slack
    cloudwatch >> Edge(label="alarms") >> pagerduty

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo view the diagram:")
print("  - Open architecture-diagram.png in the assets/diagrams folder")
