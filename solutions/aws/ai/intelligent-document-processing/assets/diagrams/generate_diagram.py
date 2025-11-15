#!/usr/bin/env python3
"""
AWS Intelligent Document Processing - Architecture Diagram Generator

This script uses the 'diagrams' library to create a professional architecture
diagram with official AWS icons.

Prerequisites:
    pip install diagrams
    sudo apt-get install graphviz  # or brew install graphviz on macOS

Usage:
    python3 generate_diagram.py

Output:
    architecture-diagram.png
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import StepFunctions, SQS, SNS
from diagrams.aws.ml import Textract, Comprehend, SagemakerGroundTruth
from diagrams.aws.storage import S3
from diagrams.aws.database import DynamodbTable
from diagrams.aws.network import VPC, CloudFront, APIGateway
from diagrams.aws.management import Cloudwatch
from diagrams.aws.security import SecretsManager

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "12",
}

edge_attr = {
    "fontsize": "10",
}

with Diagram(
    "AWS Intelligent Document Processing",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr,
):

    # Document Ingestion
    with Cluster("Document Ingestion"):
        s3_input = S3("Input Bucket\n(Document Upload)")

    # Processing Orchestration
    with Cluster("Processing Orchestration"):
        lambda_orchestrator = Lambda("Orchestration\nFunction")
        step_functions = StepFunctions("Workflow\nState Machine")

    # AI/ML Processing
    with Cluster("AI/ML Processing"):
        textract = Textract("Document\nExtraction")
        comprehend = Comprehend("Entity\nRecognition")

    # Data Storage
    with Cluster("Data Layer"):
        dynamodb = DynamodbTable("Metadata\n& Results")
        s3_output = S3("Output Bucket\n(Processed Data)")

    # API Layer
    with Cluster("API & Integration"):
        api_gateway = APIGateway("REST API\nEndpoints")
        sqs_queue = SQS("Processing\nQueue")
        sns_topic = SNS("Notifications")

    # Infrastructure Layer (VPC, Monitoring, etc.)
    with Cluster("Infrastructure & Operations"):
        cloudwatch = Cloudwatch("Monitoring\n& Logs")
        secrets = SecretsManager("Secrets\nManagement")

    # Data Flow
    # 1. Document Upload triggers processing
    s3_input >> Edge(label="S3 Event") >> lambda_orchestrator

    # 2. Orchestration triggers workflow
    lambda_orchestrator >> Edge(label="Start Execution") >> step_functions

    # 3. Workflow calls AI services
    step_functions >> Edge(label="Extract Text") >> textract
    step_functions >> Edge(label="Analyze Entities") >> comprehend

    # 4. AI results stored
    textract >> Edge(label="Store Results") >> dynamodb
    comprehend >> Edge(label="Store Analysis") >> dynamodb

    # 5. Processed data archived
    dynamodb >> Edge(label="Export") >> s3_output

    # 6. API Integration
    api_gateway >> Edge(label="Submit Doc") >> sqs_queue
    sqs_queue >> Edge(label="Trigger") >> lambda_orchestrator

    # 7. Notifications
    step_functions >> Edge(label="Completion") >> sns_topic

    # 8. Monitoring
    lambda_orchestrator >> Edge(label="Logs", style="dashed") >> cloudwatch
    step_functions >> Edge(label="Metrics", style="dashed") >> cloudwatch
    textract >> Edge(label="Logs", style="dashed") >> cloudwatch

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo view the diagram:")
print("  - Open architecture-diagram.png")
print("  - Or regenerate documents: solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing --force")
