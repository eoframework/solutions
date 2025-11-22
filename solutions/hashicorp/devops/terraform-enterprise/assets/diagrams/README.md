# Architecture Diagram Creation Guide

This directory contains instructions for creating the HashiCorp Terraform Enterprise architecture diagram.

## 📋 **Overview**

Create a professional architecture diagram showing Terraform Enterprise deployment with workspace management VCS integration policy enforcement and multi-cloud provisioning capabilities.

## 🎯 **Quick Start**

### Recommended Approach: Manual Creation with Draw.io
For Terraform Enterprise, manual diagram creation provides the best results for showcasing enterprise features and integration points.

### Prerequisites
1. **Download Draw.io Desktop**: https://github.com/jgraph/drawio-desktop/releases
2. **Download HashiCorp Logos**: https://www.hashicorp.com/brand
3. **Icon Libraries**: AWS 19, Azure, GCP, Kubernetes (available in Draw.io)

## 🚀 **Key Components to Include**

### Terraform Enterprise Platform
- Workspace management UI
- Remote state storage (PostgreSQL)
- Run execution environment
- Private module registry
- Sentinel policy engine
- API and webhooks

### VCS Integration
- GitHub/GitLab connection
- Webhook triggers
- Pull request workflows
- Branch-based workspaces

### Multi-Cloud Provisioning
- AWS resources
- Azure resources
- GCP resources
- Terraform providers

### Security & Secrets
- HashiCorp Vault integration
- Dynamic cloud credentials
- Secret injection into runs

### Governance
- Sentinel policy checks
- Cost estimation
- Approval workflows
- Audit logging

## 📚 **References**

- **HashiCorp Brand**: https://www.hashicorp.com/brand
- **Terraform Enterprise Docs**: https://www.terraform.io/enterprise
- **Reference Architectures**: https://www.hashicorp.com/resources?product=terraform&type=reference-architecture
- **AWS Icons**: https://aws.amazon.com/architecture/icons/

Refer to `/solutions/hashicorp/cloud/multi-cloud-platform/assets/diagrams/DIAGRAM_REQUIREMENTS.md` for detailed diagram creation instructions applicable to Terraform Enterprise.
