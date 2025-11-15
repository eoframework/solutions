#!/usr/bin/env python3
"""
Azure AI Document Intelligence Architecture Diagram Generator

This script generates an architecture diagram for Azure AI Document Intelligence solution
using the Python diagrams library.

Requirements:
    pip install diagrams

Usage:
    python3 generate_diagram.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import FunctionApps
from diagrams.azure.storage import BlobStorage
from diagrams.azure.database import CosmosDb
from diagrams.azure.ml import MachineLearningServiceWorkspaces as CognitiveServices
from diagrams.azure.integration import APIManagement, LogicApps, EventGridTopics, ServiceBus
from diagrams.azure.security import KeyVaults
from diagrams.azure.devops import ApplicationInsights
from diagrams.azure.network import VirtualNetworks, PrivateEndpoint
from diagrams.azure.identity import ActiveDirectory

# Diagram configuration
graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "12",
}

with Diagram(
    "Azure AI Document Intelligence Architecture",
    filename="architecture-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # External users/systems
    users = ActiveDirectory("Users\n(Azure AD)")
    external_systems = APIManagement("External Systems\n(via API Gateway)")

    with Cluster("Azure Subscription"):

        with Cluster("Resource Group - Document Intelligence"):

            # Security & Identity
            with Cluster("Security"):
                keyvault = KeyVaults("Key Vault\n(Secrets & Keys)")
                aad = ActiveDirectory("Managed\nIdentities")

            # Networking
            with Cluster("Virtual Network"):
                vnet = VirtualNetworks("VNet\n(10.0.0.0/16)")
                private_endpoints = PrivateEndpoint("Private\nEndpoints")

            # Data Ingestion Layer
            with Cluster("Ingestion Layer"):
                blob_storage = BlobStorage("Blob Storage\n(Hot/Cool Tiers)")
                event_grid = EventGridTopics("Event Grid\n(Upload Triggers)")

            # AI/ML Processing Layer
            with Cluster("AI Processing Layer"):
                doc_intelligence = CognitiveServices("AI Document Intelligence\n(Form Recognizer)")
                text_analytics = CognitiveServices("Text Analytics\n(Entity Recognition)")

            # Compute & Orchestration Layer
            with Cluster("Compute Layer"):
                functions = FunctionApps("Azure Functions\n(Premium Plan)")
                logic_apps = LogicApps("Logic Apps\n(Workflow Orchestration)")

            # Data Storage Layer
            with Cluster("Data Layer"):
                cosmos_db = CosmosDb("Cosmos DB\n(Serverless NoSQL)")

            # Integration Layer
            with Cluster("Integration Layer"):
                api_mgmt = APIManagement("API Management\n(REST API Gateway)")
                service_bus = ServiceBus("Service Bus\n(Message Queue)")

            # Monitoring Layer
            with Cluster("Monitoring"):
                app_insights = ApplicationInsights("Application Insights\n(APM + Logging)")

    # Data flows - Document Processing Workflow
    users >> Edge(label="1. Upload Document") >> blob_storage
    blob_storage >> Edge(label="2. Trigger Event") >> event_grid
    event_grid >> Edge(label="3. Invoke") >> functions
    functions >> Edge(label="4. Extract Data") >> doc_intelligence
    functions >> Edge(label="5. Classify") >> text_analytics
    functions >> Edge(label="6. Store Results") >> cosmos_db

    # Integration flows
    external_systems >> Edge(label="7. REST API Call") >> api_mgmt
    api_mgmt >> Edge(label="8. Query Data") >> functions
    functions >> Edge(label="9. Retrieve") >> cosmos_db

    # Orchestration flows
    logic_apps >> Edge(label="Complex Workflows") >> functions
    functions >> Edge(label="Queue Messages") >> service_bus

    # Security flows
    functions >> Edge(label="Get Secrets", style="dotted") >> keyvault
    functions >> Edge(label="Authenticate", style="dotted") >> aad

    # Monitoring flows
    functions >> Edge(label="Metrics & Logs", style="dashed") >> app_insights
    cosmos_db >> Edge(label="Metrics", style="dashed") >> app_insights
    doc_intelligence >> Edge(label="Metrics", style="dashed") >> app_insights

    # Network security
    private_endpoints >> Edge(label="Secure Access", style="dotted") >> blob_storage
    private_endpoints >> Edge(label="Secure Access", style="dotted") >> cosmos_db

print("Architecture diagram generated successfully: architecture-diagram.png")
