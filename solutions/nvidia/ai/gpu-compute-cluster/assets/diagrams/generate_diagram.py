#!/usr/bin/env python3
"""
NVIDIA GPU Compute Cluster - Architecture Diagram Generator

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
from diagrams.onprem.network import Nginx
from diagrams.generic.storage import Storage
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.client import Users
from diagrams.k8s.compute import Pod
from diagrams.k8s.controlplane import APIServer

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "11",
}

with Diagram(
    "NVIDIA GPU Compute Cluster",
    filename="architecture-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):

    # Data Science Team
    with Cluster("Data Science Team"):
        data_scientists = Users("Data Scientists\n20-30 Users")

    # Kubernetes Control Plane
    with Cluster("Kubernetes Control Plane"):
        k8s_api = APIServer("K8s API Server\nGPU Operator")
        gpu_scheduler = Pod("GPU Scheduler\nNVIDIA Device Plugin")

    # GPU Compute Nodes
    with Cluster("GPU Compute Nodes (32x A100 GPUs)"):
        with Cluster("Dell PowerEdge Servers (8 Nodes)"):
            node1 = Server("PowerEdge R750xa\n4x A100 40GB")
            node2 = Server("PowerEdge R750xa\n4x A100 40GB")
            node3 = Server("PowerEdge R750xa\n4x A100 40GB")
            gpu_nodes = [node1, node2, node3]

    # MLOps Platform
    with Cluster("MLOps Platform"):
        kubeflow = Pod("Kubeflow\nPipelines")
        triton = Pod("Triton\nInference Server")
        mlflow = Pod("MLflow\nExperiment Tracking")

    # Network Fabric
    with Cluster("High-Speed Network (100 GbE)"):
        switch1 = Nginx("Switch\n100 GbE RDMA")
        switch2 = Nginx("Switch\n100 GbE RDMA")
        network_switches = [switch1, switch2]

    # Storage Layer
    with Cluster("Shared Storage (200 TB)"):
        storage_data = Storage("NetApp AFF\n200 TB NVMe\n3-5 GB/s")

    # Monitoring
    with Cluster("Monitoring & Observability"):
        prometheus = Prometheus("Prometheus\nGPU Metrics")
        grafana = Grafana("Grafana\nDashboards")

    # Data Flow
    data_scientists >> Edge(label="Submit Jobs") >> k8s_api
    k8s_api >> Edge(label="Schedule") >> gpu_scheduler
    gpu_scheduler >> Edge(label="Assign GPUs") >> gpu_nodes

    k8s_api >> Edge(label="Deploy") >> [kubeflow, triton, mlflow]

    for node in gpu_nodes:
        node >> Edge(label="100 GbE", color="green") >> network_switches

    gpu_nodes >> Edge(label="Dataset Access\n3-5 GB/s") >> storage_data
    kubeflow >> Edge(label="Store Results") >> storage_data

    gpu_nodes >> Edge(label="Metrics", style="dashed") >> prometheus
    [kubeflow, triton] >> Edge(label="Logs", style="dashed") >> prometheus
    prometheus >> Edge(label="Visualize") >> grafana

print("✅ Diagram generated: architecture-diagram.png")
print("\nTo regenerate documents:")
print("  cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts")
print("  python3 solution-presales-converter.py --path /mnt/c/projects/wsl/solutions/solutions/nvidia/ai/gpu-compute-cluster --force")
