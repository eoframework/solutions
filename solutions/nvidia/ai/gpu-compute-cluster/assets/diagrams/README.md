# NVIDIA GPU Compute Cluster Architecture Diagram

## Overview
This directory should contain the architecture diagram for the NVIDIA GPU Compute Cluster solution.

## Required Diagram: architecture-diagram

### Components to Include

#### GPU Compute Nodes
- **Dell PowerEdge R750xa Servers** (8 servers)
  - Label: "8x Dell R750xa GPU Servers"
  - Details: "32x NVIDIA A100 40GB GPUs (4 per server)"
  - Specs: Dual AMD EPYC 7763 (128 cores), 1 TB RAM per server

#### Container Orchestration
- **Kubernetes Cluster**
  - Label: "Kubernetes 1.28+ with NVIDIA GPU Operator"
  - Details: "GPU scheduling, time-slicing, multi-tenancy"
  - Components: Control plane nodes, worker nodes, GPU Operator

- **MLOps Platform**
  - Label: "Kubeflow ML Pipelines"
  - Details: "Experiment tracking, model registry, pipeline orchestration"
  - Integration: MLflow, Weights & Biases

#### High-Speed Networking
- **100 GbE Network**
  - Label: "100 GbE RDMA Network"
  - Details: "Mellanox ConnectX-6 NICs, 2 redundant switches"
  - Purpose: Distributed training with NCCL, fast dataset access

#### Storage Infrastructure
- **NetApp AFF A400**
  - Label: "NetApp 200 TB All-Flash Storage"
  - Details: "3-5 GB/s throughput, NFSv4 parallel file system"
  - Purpose: Training datasets, model checkpoints, shared volumes

#### Inference Platform
- **NVIDIA Triton Inference Server**
  - Label: "Triton Inference Server"
  - Details: "Multi-framework model serving, dynamic batching"
  - Deployment: Kubernetes pods with GPU allocation

#### Software Stack
- **NVIDIA AI Enterprise**
  - Label: "NVIDIA AI Enterprise Suite"
  - Details: "32 GPU licenses, NGC container catalog"
  - Components: CUDA, TensorRT, cuDNN, NCCL

- **AI Frameworks**
  - Label: "PyTorch, TensorFlow, JAX Containers"
  - Details: "NGC-optimized containers with GPU acceleration"

#### Monitoring & Observability
- **Prometheus + Grafana**
  - Label: "Monitoring Stack"
  - Details: "GPU utilization, job metrics, cluster health"
  - Dashboards: Per-user GPU usage, training performance, resource allocation

#### User Access
- **Jupyter Notebooks**
  - Label: "JupyterHub on Kubernetes"
  - Details: "Per-user notebook servers with GPU allocation"

- **Authentication**
  - Label: "LDAP/Active Directory"
  - Details: "SSO integration, role-based access control"

### Architecture Flow

1. **User Workflow**
   - Data scientist → JupyterHub → GPU-accelerated notebook
   - Job submission → Kubernetes → GPU scheduling → Training pod

2. **Distributed Training**
   - Multi-GPU training → NCCL communication → 100 GbE network
   - Dataset streaming → NetApp NFS → GPU memory

3. **Model Deployment**
   - Trained model → MLflow registry → Triton Inference Server
   - Production inference → API Gateway → Triton pods

### Visual Layout Recommendations

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Access Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐   │
│  │ JupyterHub   │  │ VS Code      │  │ SSH / kubectl            │   │
│  │ Notebooks    │  │ Remote       │  │ Direct Access            │   │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Control Plane                          │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  NVIDIA GPU Operator • GPU Scheduling • Resource Quotas      │   │
│  │  Kubeflow Pipelines • MLflow Model Registry                  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                   ┌───────────────┼───────────────┐
                   ▼                               ▼
┌───────────────────────────────────┐  ┌──────────────────────────────┐
│     GPU Worker Nodes              │  │    Storage Infrastructure    │
│  ┌──────────┐  ┌──────────┐      │  │   NetApp AFF A400            │
│  │ R750xa   │  │ R750xa   │ (x8) │  │   200 TB NVMe All-Flash      │
│  │ 4x A100  │  │ 4x A100  │      │  │   3-5 GB/s Throughput        │
│  └──────────┘  └──────────┘      │  │   NFSv4 Shared Volumes       │
│  32 GPUs • 1.28 TB GPU Memory    │  └──────────────────────────────┘
└───────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   100 GbE RDMA Network Fabric                        │
│  Mellanox ConnectX-6 NICs • Redundant Switches                      │
│  Multi-GPU Training (NCCL) • Fast Dataset Access                    │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                   ┌───────────────┼───────────────┐
                   ▼                               ▼
┌───────────────────────────────────┐  ┌──────────────────────────────┐
│     Training Workloads            │  │   Inference Workloads        │
│  • PyTorch Distributed Training   │  │   • Triton Inference Server  │
│  • TensorFlow Multi-Worker        │  │   • Dynamic Batching         │
│  • JAX Parallel Training          │  │   • Multi-Model Serving      │
│  • Experiment Tracking (MLflow)   │  │   • REST/gRPC APIs           │
└───────────────────────────────────┘  └──────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 Monitoring & Observability                           │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────────┐   │
│  │ Prometheus   │  │ Grafana      │  │ GPU Utilization         │   │
│  │ Metrics      │  │ Dashboards   │  │ Training Performance    │   │
│  └──────────────┘  └──────────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      External Integrations                           │
│  • LDAP/AD (Authentication) • Cloud Storage (S3/Azure Blob)          │
│  • MLOps Platforms • CI/CD Pipelines • Data Lakes                    │
└─────────────────────────────────────────────────────────────────────┘
```

### NVIDIA Icon Requirements

When creating the diagram in Draw.io or similar tools:

1. **Use NVIDIA Brand Colors:**
   - NVIDIA Green: #76B900
   - Kubernetes Blue: #326CE5
   - Black: #000000
   - White: #FFFFFF
   - Gray: #808080

2. **Component Representations:**
   - GPU Servers: Use server/rack icons with GPU symbols
   - Kubernetes: Use container orchestration icons
   - Storage: Use storage array icons
   - Networking: Use network topology icons

3. **Typography:**
   - Font: Arial or Helvetica (sans-serif)
   - Component labels: Bold, 14-16pt
   - Details: Regular, 10-12pt

### Export Settings

When exporting the diagram to PNG:
- **Resolution:** 300 DPI minimum
- **Format:** PNG with transparent background
- **Dimensions:** Minimum 2400x1600 pixels
- **File name:** `architecture-diagram.png`
- **Border:** 10px padding around diagram

### Files to Create

1. **architecture-diagram.drawio** - Source file for manual editing
2. **architecture-diagram.png** - Exported PNG for documentation

### Integration with Documentation

The architecture diagram is referenced in:
- `presales/raw/solution-briefing.md` (Slide 4: Solution Overview)
- Solution README files
- Technical documentation

Path in markdown:
```markdown
![Architecture Diagram](../../assets/diagrams/architecture-diagram.png)
```

## Creating the Diagram

### Option 1: Draw.io Desktop (Recommended)

1. **Download Draw.io:**
   - https://github.com/jgraph/drawio-desktop/releases

2. **Enable Kubernetes Icons:**
   - More Shapes → Search "Kubernetes"
   - Enable Kubernetes icon set

3. **Create Diagram:**
   - Add GPU server nodes
   - Add Kubernetes control plane
   - Add storage and network components
   - Connect with labeled arrows

4. **Save and Export:**
   - Save as `architecture-diagram.drawio`
   - Export as PNG (300 DPI)
   - Save PNG as `architecture-diagram.png`

### Option 2: Other Tools

- **Lucidchart:** Professional diagramming with Kubernetes shapes
- **Microsoft Visio:** Enterprise diagramming tool
- **diagrams.net:** Web-based alternative to Draw.io desktop

## Notes

- Emphasize Kubernetes orchestration and GPU scheduling
- Highlight multi-tenancy and resource isolation
- Show training and inference workloads separately
- Include MLOps platform integration (Kubeflow)
- Demonstrate 100 GbE network for distributed training
- Show monitoring and observability stack
