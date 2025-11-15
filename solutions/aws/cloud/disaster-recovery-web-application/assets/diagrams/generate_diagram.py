#!/usr/bin/env python3
"""
AWS Disaster Recovery - Multi-Region Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional multi-region
DR architecture diagram with official AWS icons.

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz  # or brew install graphviz on macOS

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3, Backup
from diagrams.aws.network import ELB, Route53, VPC
from diagrams.aws.management import Cloudwatch
from diagrams.aws.integration import SNS

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
}

node_attr = {
    "fontsize": "12",
}

edge_attr = {
    "fontsize": "10",
}

with Diagram(
    "AWS Disaster Recovery - Multi-Region Architecture",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # Global Services
    route53 = Route53("Route 53\nDNS & Health Checks\n& Failover")

    # Primary Region (us-east-1) - ACTIVE
    with Cluster("PRIMARY REGION (us-east-1) - ACTIVE", graph_attr={"bgcolor": "#E8F5E9", "style": "solid", "penwidth": "3"}):
        with Cluster("VPC - Production"):
            # Application Load Balancer
            alb_primary = ELB("Application\nLoad Balancer")

            # Auto Scaling Group
            with Cluster("Auto Scaling Group"):
                ec2_primary = [
                    EC2("EC2 Instance\nt3.large (1)"),
                    EC2("EC2 Instance\nt3.large (2)")
                ]

            # Database Primary
            rds_primary = RDS("RDS Primary\ndb.r5.large\nMulti-AZ")

            # Storage
            s3_primary = S3("S3 Primary\nApplication Data")

            # Monitoring
            cloudwatch_primary = Cloudwatch("CloudWatch\nMonitoring")

        # Backup Service
        backup_primary = Backup("AWS Backup\nCross-Region")

    # DR Region (us-west-2) - STANDBY
    with Cluster("DR REGION (us-west-2) - STANDBY", graph_attr={"bgcolor": "#FFF9E6", "style": "dashed", "penwidth": "3"}):
        with Cluster("VPC - Disaster Recovery"):
            # Application Load Balancer (Pre-configured)
            alb_dr = ELB("Application\nLoad Balancer\n(Standby)")

            # Auto Scaling Group (Minimal)
            with Cluster("Auto Scaling Group (Scaled Down)"):
                ec2_dr = EC2("EC2 Instance\nt3.medium\n(Warm Standby)")

            # Database DR (Read Replica)
            rds_dr = RDS("RDS Read Replica\ndb.r5.large\n(Cross-Region)")

            # Storage DR
            s3_dr = S3("S3 DR Replica\n(Auto-Replicated)")

    # Notifications
    sns = SNS("SNS\nFailover Alerts")

    # Data Flow - Primary Region (Active Traffic)
    route53 >> Edge(label="Active Traffic", color="green", style="bold") >> alb_primary
    alb_primary >> ec2_primary
    ec2_primary >> rds_primary
    ec2_primary >> s3_primary

    # Data Flow - DR Region (Failover Path)
    route53 >> Edge(label="Failover Path\n(Health Check Failed)", color="red", style="dashed") >> alb_dr
    alb_dr >> Edge(style="dashed") >> ec2_dr
    ec2_dr >> Edge(style="dashed") >> rds_dr
    ec2_dr >> Edge(style="dashed") >> s3_dr

    # Replication
    rds_primary >> Edge(label="Continuous\nReplication", color="blue", style="dashed") >> rds_dr
    s3_primary >> Edge(label="Cross-Region\nReplication", color="blue", style="dashed") >> s3_dr

    # Backups
    rds_primary >> Edge(label="Automated\nBackups", style="dotted") >> backup_primary
    backup_primary >> Edge(label="Cross-Region\nBackup Vault", style="dotted") >> rds_dr

    # Monitoring & Alerts
    cloudwatch_primary >> Edge(label="Health Checks", style="dotted") >> route53
    route53 >> Edge(label="Failover Event", style="dotted") >> sns

print("✅ Diagram generated: architecture-diagram.png")
print("\nKey Features:")
print("  - Green border: Primary region (active)")
print("  - Yellow border: DR region (standby)")
print("  - Green arrows: Active traffic flow")
print("  - Red dashed arrows: Failover path")
print("  - Blue dashed arrows: Data replication")
print("\nRTO: 15 minutes | RPO: 5 minutes")
