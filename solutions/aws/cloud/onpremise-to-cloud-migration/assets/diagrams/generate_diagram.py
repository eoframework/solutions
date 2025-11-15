#!/usr/bin/env python3
"""
AWS Cloud Migration - On-Premise to AWS Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional migration
journey diagram with official AWS icons.

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
from diagrams.aws.database import RDS, DatabaseMigrationService
from diagrams.aws.storage import S3, SimpleStorageServiceS3Bucket
from diagrams.aws.network import ELB, VPC, SiteToSiteVpn, CloudFront
from diagrams.aws.management import ManagedServices, SystemsManager, Cloudwatch
from diagrams.aws.migration import MigrationHub, ApplicationDiscoveryService, ServerMigrationService, Datasync
from diagrams.aws.security import IdentityAndAccessManagementIam, SecretsManager
from diagrams.onprem.compute import Server
from diagrams.onprem.database import Postgresql
from diagrams.onprem.network import Internet

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
    "rankdir": "LR",
}

node_attr = {
    "fontsize": "11",
}

edge_attr = {
    "fontsize": "9",
}

with Diagram(
    "AWS Cloud Migration Journey - On-Premise to AWS",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # ON-PREMISES INFRASTRUCTURE (LEFT)
    with Cluster("On-Premises Data Center", graph_attr={"bgcolor": "#E5E7EB", "style": "solid", "penwidth": "3"}):
        with Cluster("Legacy Infrastructure"):
            onprem_apps = Server("Application\nServers")
            onprem_db = Postgresql("Database\nServers")
            onprem_storage = Server("File\nServers")

    # MIGRATION SERVICES (CENTER)
    with Cluster("AWS Migration Services", graph_attr={"bgcolor": "#FFF4E6", "style": "solid", "penwidth": "2"}):
        migration_hub = MigrationHub("Migration Hub\nCentral Tracking")

        with Cluster("Discovery & Planning"):
            discovery = ApplicationDiscoveryService("Application\nDiscovery")

        with Cluster("Migration Tools"):
            dms = DatabaseMigrationService("Database\nMigration Service")
            sms = ServerMigrationService("Server\nMigration Service")
            datasync = Datasync("DataSync\nLarge Data Transfer")

    # AWS CLOUD (RIGHT)
    with Cluster("AWS Cloud Landing Zone", graph_attr={"bgcolor": "#ECFDF5", "style": "solid", "penwidth": "3"}):

        # Multi-Account Structure
        with Cluster("AWS Control Tower", graph_attr={"bgcolor": "#D1FAE5"}):
            iam = IdentityAndAccessManagementIam("IAM &\nOrganizations")

        # Production VPC
        with Cluster("Production VPC"):
            # Application Tier
            with Cluster("Application Tier"):
                alb = ELB("Application\nLoad Balancer")
                with Cluster("Auto Scaling"):
                    ec2_instances = [
                        EC2("EC2\nInstance"),
                        EC2("EC2\nInstance")
                    ]

            # Database Tier
            with Cluster("Data Tier"):
                rds = RDS("Amazon RDS\n(Migrated DBs)")
                s3 = S3("Amazon S3\n(Object Storage)")

            # CDN & Distribution
            cloudfront = CloudFront("CloudFront\nCDN")

        # Operations & Monitoring
        with Cluster("Operations"):
            cloudwatch = Cloudwatch("CloudWatch\nMonitoring")
            systems_mgr = SystemsManager("Systems Manager\nPatch & Config")
            secrets = SecretsManager("Secrets Manager\nCredentials")

    # VPN Connectivity
    vpn = SiteToSiteVpn("Site-to-Site VPN\n(Hybrid Connectivity)")

    # MIGRATION FLOW

    # Discovery Phase
    onprem_apps >> Edge(label="1. Discover\n& Map", color="orange", style="dashed") >> discovery
    onprem_db >> Edge(style="dashed", color="orange") >> discovery
    discovery >> Edge(label="Dependency Map", style="dotted") >> migration_hub

    # Migration Execution
    # Application Migration
    onprem_apps >> Edge(label="2. Server\nMigration", color="blue", style="bold") >> sms
    sms >> Edge(label="Replicate &\nCreate AMIs", color="blue") >> ec2_instances

    # Database Migration
    onprem_db >> Edge(label="3. Database\nMigration", color="blue", style="bold") >> dms
    dms >> Edge(label="Schema Conversion\n& Data Sync", color="blue") >> rds

    # Data Migration
    onprem_storage >> Edge(label="4. Data\nTransfer", color="blue", style="bold") >> datasync
    datasync >> Edge(label="Large File\nTransfer", color="blue") >> s3

    # All migration tracked
    sms >> Edge(label="Track Progress", style="dotted") >> migration_hub
    dms >> Edge(style="dotted") >> migration_hub
    datasync >> Edge(style="dotted") >> migration_hub

    # Hybrid Connectivity
    onprem_apps >> Edge(label="Hybrid Phase", color="purple", style="dashed") >> vpn
    vpn >> Edge(color="purple", style="dashed") >> ec2_instances

    # Production Flow (Post-Migration)
    cloudfront >> Edge(label="Production Traffic", color="green") >> alb
    alb >> ec2_instances
    ec2_instances >> rds
    ec2_instances >> s3

    # Security & Operations
    ec2_instances >> Edge(label="Logs", style="dotted") >> cloudwatch
    rds >> Edge(label="Metrics", style="dotted") >> cloudwatch
    systems_mgr >> Edge(label="Manage", style="dotted") >> ec2_instances

print("✅ Diagram generated: architecture-diagram.png")
print("\nMigration Journey:")
print("  Phase 1 (Orange): Discovery & Assessment")
print("  Phase 2 (Blue): Migration Execution (Apps, DBs, Data)")
print("  Phase 3 (Purple): Hybrid Connectivity")
print("  Phase 4 (Green): Production Operations")
print("\nEstimated Timeline: 6-9 months")
print("Migration Strategy: Lift-and-Shift → Replatform → Optimize")
