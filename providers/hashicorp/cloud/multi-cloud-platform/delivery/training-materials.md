# HashiCorp Multi-Cloud Platform - Training Materials

## Overview
This document provides comprehensive training materials for teams adopting the HashiCorp Multi-Cloud Infrastructure Management Platform. The training program covers all five HashiCorp products and multi-cloud operations across AWS, Azure, and Google Cloud Platform.

## Training Program Structure

### Executive Overview (2 hours)
**Target Audience**: Executives, Directors, and Senior Managers  
**Prerequisites**: None

#### Module 1: Multi-Cloud Strategy and Business Value
**Learning Objectives**:
- Understand multi-cloud market trends and drivers
- Learn business benefits of HashiCorp multi-cloud approach
- Review ROI and cost optimization opportunities
- Understand competitive advantages and strategic positioning

**Topics Covered**:
- Multi-cloud adoption statistics and market trends
- Vendor lock-in risks and mitigation strategies
- HashiCorp unified operations value proposition
- Cost optimization through multi-cloud arbitrage
- Risk management and business continuity benefits

**Business Case Examples**:
```
Real-world ROI Scenarios:
• Enterprise A: 45% infrastructure cost reduction
• Enterprise B: 60% operational efficiency improvement  
• Enterprise C: 300% faster deployment velocity
• Enterprise D: 80% reduction in security incidents
```

#### Module 2: Platform Overview and Architecture
**Learning Objectives**:
- Understand HashiCorp product suite integration
- Learn platform architecture and capabilities
- Review implementation approach and timeline
- Understand team requirements and skills needed

**Topics Covered**:
- HashiCorp product suite overview
- Multi-cloud architecture patterns
- Implementation phases and milestones
- Team structure and skill requirements
- Success metrics and measurement

### Foundation Training (Week 1)
**Target Audience**: All technical team members  
**Duration**: 40 hours (5 days)  
**Prerequisites**: Basic cloud computing knowledge

#### Module 3: Multi-Cloud Fundamentals
**Learning Objectives**:
- Understand multi-cloud concepts and challenges
- Learn cloud provider differences and similarities
- Master cross-cloud networking fundamentals
- Understand identity and access management across clouds

**Topics Covered**:
- Multi-cloud vs. hybrid cloud vs. single cloud
- AWS, Azure, and GCP service comparisons
- Cross-cloud networking and VPN connectivity
- Identity federation and access management
- Cost management and optimization strategies

**Hands-on Labs**:
```bash
# Lab 1: Cross-Cloud Connectivity Setup
# Deploy VPN connections between cloud providers

# AWS VPN Gateway
aws ec2 create-vpn-gateway --type ipsec.1

# Azure VPN Gateway  
az network vnet-gateway create \
  --name HashiCorpVPNGateway \
  --public-ip-address HashiCorpVPNGatewayIP \
  --resource-group HashiCorp-RG \
  --vnet HashiCorp-VNet \
  --gateway-type Vpn \
  --sku VpnGw1 \
  --vpn-type RouteBased

# GCP VPN Gateway
gcloud compute vpn-gateways create hashicorp-vpn-gateway \
  --network=hashicorp-vpc \
  --region=us-central1
```

#### Module 4: HashiCorp Product Suite Overview
**Learning Objectives**:
- Understand each HashiCorp product's purpose and capabilities
- Learn product integration patterns
- Practice basic operations for each product
- Understand enterprise vs. open source differences

**Topics Covered**:
- **Terraform Enterprise**: Infrastructure as Code management
- **Consul Enterprise**: Service discovery and service mesh
- **Vault Enterprise**: Secrets and identity management
- **Nomad Enterprise**: Workload orchestration
- **Boundary Enterprise**: Secure remote access
- Product integration and workflow patterns

**Product Introduction Labs**:
```hcl
# Lab 2: Basic HashiCorp Product Usage

# Terraform - Infrastructure as Code
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = {
    Name = "HashiCorp-Training-Web"
  }
}

# Consul - Service Discovery
consul services register web-service.json
consul catalog services

# Vault - Secret Management
vault kv put secret/web database_password="secure123"
vault kv get secret/web

# Nomad - Workload Orchestration
job "training-web" {
  datacenters = ["dc1"]
  
  group "web" {
    count = 1
    
    task "frontend" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
      }
    }
  }
}

# Boundary - Secure Access
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=training-user
```

#### Module 5: Kubernetes Fundamentals
**Learning Objectives**:
- Understand Kubernetes concepts and architecture
- Learn EKS, AKS, and GKE differences
- Practice kubectl commands and YAML configurations
- Understand Helm package management

**Topics Covered**:
- Kubernetes architecture (pods, services, deployments)
- Managed Kubernetes services comparison
- kubectl command-line operations
- Helm charts and package management
- YAML configuration best practices

**Kubernetes Labs**:
```yaml
# Lab 3: Multi-Cloud Kubernetes Deployment
# Deploy same application across all three cloud providers

apiVersion: apps/v1
kind: Deployment
metadata:
  name: training-app
  namespace: hashicorp-training
spec:
  replicas: 3
  selector:
    matchLabels:
      app: training-app
  template:
    metadata:
      labels:
        app: training-app
      annotations:
        consul.hashicorp.com/connect-inject: "true"
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: VAULT_ADDR
          value: "https://vault.hashicorp-system.svc.cluster.local:8200"
---
apiVersion: v1
kind: Service
metadata:
  name: training-app-service
  namespace: hashicorp-training
spec:
  selector:
    app: training-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

### Intermediate Training (Week 2)
**Target Audience**: Platform Engineers and DevOps Engineers  
**Duration**: 50 hours (6.25 days)  
**Prerequisites**: Completion of Foundation Training

#### Module 6: Terraform Enterprise Multi-Cloud Operations
**Learning Objectives**:
- Master Terraform Enterprise workspace management
- Implement policy as code with Sentinel
- Create and manage private module registry
- Understand cost estimation and analysis

**Topics Covered**:
- Multi-cloud workspace strategies
- Sentinel policy language and enforcement
- Private module registry organization
- VCS integration patterns
- Cost estimation and budget management
- API-driven workspace automation

**Advanced Terraform Labs**:
```hcl
# Lab 4: Multi-Cloud Module Development
# Create reusable modules for all three cloud providers

# modules/compute/aws/main.tf
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  tags = merge(var.common_tags, {
    Name = var.name
  })
}

# modules/compute/azure/main.tf  
resource "azurerm_virtual_machine" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  vm_size            = var.vm_size
  
  tags = var.common_tags
}

# modules/compute/gcp/main.tf
resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  
  labels = var.common_labels
  
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
}

# Sentinel Policy Example
import "tfplan/v2" as tfplan

# Multi-cloud instance type restrictions
allowed_aws_types = ["t3.micro", "t3.small", "t3.medium"]
allowed_azure_sizes = ["Standard_B1s", "Standard_B1ms", "Standard_B2s"]
allowed_gcp_types = ["f1-micro", "g1-small", "n1-standard-1"]

main = rule {
  all tfplan.resource_changes as _, rc {
    (rc.type is "aws_instance" and 
     rc.mode is "managed" and
     (rc.change.actions contains "create" or rc.change.actions contains "update")) implies
     rc.change.after.instance_type in allowed_aws_types
  } and
  
  all tfplan.resource_changes as _, rc {
    (rc.type is "azurerm_virtual_machine" and
     rc.mode is "managed" and
     (rc.change.actions contains "create" or rc.change.actions contains "update")) implies
     rc.change.after.vm_size in allowed_azure_sizes
  } and
  
  all tfplan.resource_changes as _, rc {
    (rc.type is "google_compute_instance" and
     rc.mode is "managed" and  
     (rc.change.actions contains "create" or rc.change.actions contains "update")) implies
     rc.change.after.machine_type in allowed_gcp_types
  }
}
```

#### Module 7: Consul Enterprise Service Mesh
**Learning Objectives**:
- Deploy Consul across multiple cloud providers
- Configure service mesh with Connect
- Implement cross-datacenter federation
- Master service intentions and traffic management

**Topics Covered**:
- Multi-datacenter Consul deployment
- Consul Connect service mesh architecture
- Cross-cloud service discovery
- Traffic routing and load balancing
- Security policies and service intentions
- Observability and monitoring

**Consul Service Mesh Labs**:
```bash
# Lab 5: Cross-Cloud Service Mesh
# Deploy services across multiple clouds with mesh connectivity

# Deploy Consul in each cloud
helm install consul-aws hashicorp/consul \
  --namespace hashicorp-system \
  --kube-context=aws-prod \
  --values consul-aws-values.yaml

helm install consul-azure hashicorp/consul \
  --namespace hashicorp-system \
  --kube-context=azure-prod \
  --values consul-azure-values.yaml

helm install consul-gcp hashicorp/consul \
  --namespace hashicorp-system \
  --kube-context=gcp-prod \
  --values consul-gcp-values.yaml

# Configure federation
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
  consul connect ca get-config > consul-ca-config.json

# Set up service intentions
consul intention create -allow frontend backend
consul intention create -allow api database  
consul intention create -deny untrusted-service sensitive-service

# Deploy test services with Connect injection
kubectl apply --context=aws-prod -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
      annotations:
        consul.hashicorp.com/connect-inject: "true"
        consul.hashicorp.com/connect-service: "frontend"
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF
```

#### Module 8: Vault Enterprise Secrets Management
**Learning Objectives**:
- Deploy Vault in high-availability mode
- Configure dynamic secrets for cloud providers
- Implement encryption as a service
- Master certificate management and PKI

**Topics Covered**:
- Vault architecture and deployment patterns
- Cloud provider dynamic secrets
- Database dynamic credentials
- PKI and certificate management
- Encryption as a Service (EaaS)
- Vault agent and auto-authentication

**Vault Secrets Management Labs**:
```bash
# Lab 6: Multi-Cloud Dynamic Secrets
# Configure dynamic secrets for all cloud providers

# AWS dynamic secrets
vault auth enable aws
vault write auth/aws/config/client \
  secret_key=$AWS_SECRET_ACCESS_KEY \
  access_key=$AWS_ACCESS_KEY_ID

vault write auth/aws/role/ec2-role \
  auth_type=ec2 \
  policies=ec2-policy \
  bound_ami_id=ami-12345678

# Azure dynamic secrets
vault auth enable azure
vault write auth/azure/config \
  tenant_id=$AZURE_TENANT_ID \
  client_id=$AZURE_CLIENT_ID \
  client_secret=$AZURE_CLIENT_SECRET

# GCP dynamic secrets  
vault auth enable gcp
vault write auth/gcp/config \
  credentials=@/path/to/credentials.json

# Database dynamic secrets
vault secrets enable database
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  connection_url="postgresql://{{username}}:{{password}}@postgres:5432/hashicorp?sslmode=require" \
  allowed_roles="readonly,readwrite"

vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# PKI Certificate Authority
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal \
  common_name="HashiCorp Multi-Cloud CA" \
  ttl=87600h

vault write pki/config/urls \
  issuing_certificates="https://vault.company.com:8200/v1/pki/ca" \
  crl_distribution_points="https://vault.company.com:8200/v1/pki/crl"

vault write pki/roles/web-server \
  allowed_domains="company.com" \
  allow_subdomains=true \
  max_ttl="720h"
```

#### Module 9: Nomad Enterprise Workload Orchestration
**Learning Objectives**:
- Deploy Nomad clusters across multiple clouds
- Understand job scheduling and placement
- Configure multi-region job deployment
- Implement resource allocation and constraints

**Topics Covered**:
- Nomad architecture and clustering
- Job specification and scheduling
- Multi-region and multi-cloud deployment
- Resource allocation and constraints
- Service discovery integration with Consul
- Vault integration for secrets

**Nomad Orchestration Labs**:
```hcl
# Lab 7: Multi-Cloud Workload Orchestration
# Deploy applications across all three cloud providers

job "multi-cloud-web" {
  datacenters = ["aws-dc", "azure-dc", "gcp-dc"]
  type = "service"
  
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }
  
  group "web" {
    count = 6
    
    # Spread across all datacenters
    spread {
      attribute = "${node.datacenter}"
      target "aws-dc" {
        percent = 34
      }
      target "azure-dc" {
        percent = 33
      }
      target "gcp-dc" {
        percent = 33
      }
    }
    
    task "frontend" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
        ports = ["http"]
      }
      
      env {
        DATACENTER = "${node.datacenter}"
        CLOUD_PROVIDER = "${meta.cloud_provider}"
      }
      
      resources {
        cpu    = 500
        memory = 512
        
        network {
          port "http" {
            static = 80
          }
        }
      }
      
      service {
        name = "web-frontend"
        port = "http"
        
        connect {
          sidecar_service {
            proxy {
              upstreams {
                destination_name = "api-backend"
                local_bind_port  = 8080
              }
            }
          }
        }
        
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "3s"
        }
      }
      
      vault {
        policies = ["web-policy"]
      }
      
      template {
        data = <<EOH
DATABASE_URL="{{ with secret "database/creds/readonly" }}postgres://{{ .Data.username }}:{{ .Data.password }}@postgres:5432/app{{ end }}"
API_KEY="{{ with secret "secret/data/api" }}{{ .Data.data.key }}{{ end }}"
EOH
        destination = "local/app.env"
        env         = true
      }
    }
  }
}

# Multi-cloud batch job example
job "data-processing" {
  datacenters = ["aws-dc", "azure-dc", "gcp-dc"]
  type = "batch"
  
  group "processors" {
    count = 9
    
    # Prefer cheaper regions
    affinity {
      attribute = "${meta.cloud_provider}"
      value     = "gcp"
      weight    = 50
    }
    
    affinity {
      attribute = "${meta.cloud_provider}" 
      value     = "aws"
      weight    = 30
    }
    
    task "processor" {
      driver = "docker"
      
      config {
        image = "alpine:latest"
        command = "/bin/sh"
        args = ["-c", "echo Processing data in ${NOMAD_DC} && sleep 300"]
      }
      
      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}
```

### Advanced Training (Week 3)
**Target Audience**: Platform Architects and Senior Engineers  
**Duration**: 50 hours (6.25 days)  
**Prerequisites**: Completion of Intermediate Training

#### Module 10: Boundary Enterprise Zero Trust Access
**Learning Objectives**:
- Understand zero trust network access principles
- Configure Boundary controllers and workers
- Implement dynamic host catalogs
- Master session recording and auditing

**Topics Covered**:
- Zero trust architecture principles
- Boundary architecture and components
- Host catalog and credential management
- Session management and recording
- Integration with identity providers
- Audit logging and compliance

**Boundary Zero Trust Labs**:
```bash
# Lab 8: Zero Trust Multi-Cloud Access
# Configure secure access to resources across all clouds

# Initialize Boundary
boundary database init -config /etc/boundary/boundary.hcl

# Authenticate as admin
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=password

# Create org and projects
ORG_ID=$(boundary scopes create -name="HashiCorp Multi-Cloud" \
  -description="Multi-cloud infrastructure access" \
  -format=json | jq -r '.item.id')

PROJECT_ID=$(boundary scopes create -scope-id=$ORG_ID \
  -name="Production Infrastructure" \
  -description="Production resources across AWS, Azure, GCP" \
  -format=json | jq -r '.item.id')

# Create host catalogs for each cloud
AWS_CATALOG_ID=$(boundary host-catalogs create static \
  -scope-id=$PROJECT_ID \
  -name="AWS Infrastructure" \
  -description="AWS production resources" \
  -format=json | jq -r '.item.id')

AZURE_CATALOG_ID=$(boundary host-catalogs create static \
  -scope-id=$PROJECT_ID \
  -name="Azure Infrastructure" \
  -description="Azure production resources" \
  -format=json | jq -r '.item.id')

GCP_CATALOG_ID=$(boundary host-catalogs create static \
  -scope-id=$PROJECT_ID \
  -name="GCP Infrastructure" \
  -description="GCP production resources" \
  -format=json | jq -r '.item.id')

# Create host sets and targets
boundary host-sets create static \
  -host-catalog-id=$AWS_CATALOG_ID \
  -name="AWS Database Servers" \
  -description="RDS and database instances in AWS"

boundary targets create tcp \
  -scope-id=$PROJECT_ID \
  -name="AWS PostgreSQL" \
  -description="Primary PostgreSQL database in AWS" \
  -default-port=5432 \
  -session-max-seconds=3600

# Test connection
boundary connect postgres \
  -target-id=ttcp_1234567890 \
  -host=postgres.aws.company.com \
  -dbname=hashicorp \
  -username=readonly
```

#### Module 11: Enterprise Architecture Patterns
**Learning Objectives**:
- Design scalable multi-cloud architectures
- Implement governance and compliance patterns
- Master disaster recovery strategies
- Understand performance optimization techniques

**Topics Covered**:
- Multi-cloud reference architectures
- Governance and policy frameworks
- Disaster recovery and business continuity
- Performance optimization strategies
- Cost management and optimization
- Compliance and security frameworks

**Architecture Pattern Labs**:
```hcl
# Lab 9: Enterprise Architecture Implementation
# Deploy comprehensive multi-cloud architecture

# Hub and spoke networking model
module "aws_hub" {
  source = "./modules/networking/aws-hub"
  
  region = "us-east-1"
  vpc_cidr = "10.10.0.0/16"
  
  spoke_networks = [
    "10.20.0.0/16",  # Azure
    "10.30.0.0/16"   # GCP
  ]
  
  tags = local.common_tags
}

module "azure_spoke" {
  source = "./modules/networking/azure-spoke"
  
  location = "East US 2"
  vnet_cidr = "10.20.0.0/16"
  
  hub_gateway_ip = module.aws_hub.vpn_gateway_ip
  
  tags = local.common_tags
}

module "gcp_spoke" {
  source = "./modules/networking/gcp-spoke"
  
  region = "us-central1"
  vpc_cidr = "10.30.0.0/16"
  
  hub_gateway_ip = module.aws_hub.vpn_gateway_ip
  
  labels = local.common_labels
}

# Multi-cloud Kubernetes clusters with HashiCorp integration
module "aws_k8s_cluster" {
  source = "./modules/kubernetes/aws-eks"
  
  cluster_name = "${var.project_name}-aws-cluster"
  vpc_id = module.aws_hub.vpc_id
  subnet_ids = module.aws_hub.private_subnet_ids
  
  # HashiCorp integration
  enable_consul = true
  enable_vault = true
  enable_nomad = true
  
  tags = local.common_tags
}

# Cross-cloud load balancing and traffic management
resource "consul_config_entry" "ingress_gateway" {
  kind = "ingress-gateway"
  name = "multi-cloud-gateway"
  
  config_json = jsonencode({
    listeners = [
      {
        port = 80
        protocol = "http"
        services = [
          {
            name = "web-frontend"
            hosts = ["app.company.com"]
          }
        ]
      },
      {
        port = 443
        protocol = "http"
        services = [
          {
            name = "web-frontend"
            hosts = ["app.company.com"]
            tls = {
              sds = {
                cluster_name = "sds-cluster"
                cert_resource = "web-cert"
              }
            }
          }
        ]
      }
    ]
  })
}
```

#### Module 12: API Integration and Automation
**Learning Objectives**:
- Master HashiCorp product APIs
- Build automation workflows
- Implement CI/CD integration
- Create custom tooling and scripts

**Topics Covered**:
- HashiCorp product API documentation
- Authentication and authorization for APIs
- Workflow automation patterns
- CI/CD pipeline integration
- Custom tooling development
- Monitoring and observability integration

**API Automation Labs**:
```python
# Lab 10: Multi-Cloud Automation Framework
# Build comprehensive automation using HashiCorp APIs

import requests
import json
import boto3
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from google.cloud import compute_v1

class HashiCorpMultiCloudManager:
    def __init__(self, config):
        self.config = config
        self.tfe_client = TerraformEnterpriseClient(config['tfe'])
        self.vault_client = VaultClient(config['vault'])
        self.consul_client = ConsulClient(config['consul'])
        self.nomad_client = NomadClient(config['nomad'])
        
    def deploy_infrastructure(self, cloud_provider, workspace_name):
        """Deploy infrastructure using Terraform Enterprise API"""
        
        # Create workspace
        workspace = self.tfe_client.create_workspace(
            organization=self.config['organization'],
            name=workspace_name,
            working_directory=f"clouds/{cloud_provider}",
            vcs_repo={
                "identifier": "company/infrastructure-modules",
                "oauth_token_id": self.config['vcs_oauth_token']
            }
        )
        
        # Set variables
        variables = self._get_cloud_variables(cloud_provider)
        for var_name, var_value in variables.items():
            self.tfe_client.create_variable(
                workspace_id=workspace['data']['id'],
                key=var_name,
                value=var_value,
                category="terraform"
            )
        
        # Queue run
        run = self.tfe_client.create_run(
            workspace_id=workspace['data']['id'],
            message=f"Deploy {cloud_provider} infrastructure"
        )
        
        return self._monitor_run(run['data']['id'])
    
    def setup_service_mesh(self, services):
        """Configure Consul service mesh across all clouds"""
        
        for service in services:
            # Register service in Consul
            self.consul_client.register_service(
                name=service['name'],
                port=service['port'],
                datacenter=service['datacenter'],
                connect=True,
                check={
                    "http": f"http://localhost:{service['port']}/health",
                    "interval": "10s"
                }
            )
            
            # Create service intentions
            for upstream in service.get('upstreams', []):
                self.consul_client.create_intention(
                    source=service['name'],
                    destination=upstream,
                    action="allow"
                )
    
    def manage_secrets(self, applications):
        """Manage secrets for applications across clouds"""
        
        for app in applications:
            # Create Vault policy
            policy = f"""
            path "secret/data/{app['name']}/*" {{
                capabilities = ["read"]
            }}
            path "database/creds/{app['name']}-readonly" {{
                capabilities = ["read"]
            }}
            """
            
            self.vault_client.create_policy(
                name=f"{app['name']}-policy",
                policy=policy
            )
            
            # Create Kubernetes auth role
            self.vault_client.create_k8s_auth_role(
                role_name=app['name'],
                bound_service_account_names=[app['service_account']],
                bound_service_account_namespaces=[app['namespace']],
                policies=[f"{app['name']}-policy"]
            )
            
            # Store application secrets
            secrets = self._generate_secrets(app)
            self.vault_client.write_secret(
                path=f"secret/{app['name']}/config",
                data=secrets
            )
    
    def deploy_workloads(self, jobs):
        """Deploy workloads using Nomad across multiple clouds"""
        
        for job in jobs:
            # Generate Nomad job specification
            job_spec = self._generate_nomad_job(job)
            
            # Submit job
            job_result = self.nomad_client.submit_job(job_spec)
            
            # Monitor deployment
            self._monitor_nomad_job(job_result['job_id'])
    
    def _get_cloud_variables(self, cloud_provider):
        """Get cloud-specific Terraform variables"""
        base_vars = {
            "project_name": self.config['project_name'],
            "environment": self.config['environment']
        }
        
        if cloud_provider == "aws":
            base_vars.update({
                "aws_region": self.config['aws']['region'],
                "vpc_cidr": self.config['aws']['vpc_cidr']
            })
        elif cloud_provider == "azure":
            base_vars.update({
                "azure_location": self.config['azure']['location'],
                "vnet_cidr": self.config['azure']['vnet_cidr']
            })
        elif cloud_provider == "gcp":
            base_vars.update({
                "gcp_region": self.config['gcp']['region'],
                "gcp_project": self.config['gcp']['project_id']
            })
        
        return base_vars

# Usage example
config = {
    "project_name": "hashicorp-multicloud",
    "environment": "production",
    "organization": "company-org",
    "tfe": {
        "url": "https://tfe-aws.company.com",
        "token": "your-tfe-token"
    },
    "vault": {
        "url": "https://vault-aws.company.com:8200",
        "token": "your-vault-token"
    },
    "consul": {
        "url": "https://consul-aws.company.com:8500",
        "token": "your-consul-token"
    }
}

manager = HashiCorpMultiCloudManager(config)

# Deploy infrastructure to all clouds
for cloud in ["aws", "azure", "gcp"]:
    workspace_name = f"infrastructure-{cloud}-prod"
    result = manager.deploy_infrastructure(cloud, workspace_name)
    print(f"Infrastructure deployment for {cloud}: {result['status']}")

# Configure service mesh
services = [
    {
        "name": "web-frontend",
        "port": 80,
        "datacenter": "aws-dc",
        "upstreams": ["api-backend"]
    },
    {
        "name": "api-backend", 
        "port": 8080,
        "datacenter": "azure-dc",
        "upstreams": ["database"]
    }
]

manager.setup_service_mesh(services)
print("Service mesh configured successfully")
```

## Role-Specific Training Tracks

### Cloud Architect Track
**Duration**: Foundation + Advanced + Architect-specific modules (80 hours)

**Additional Modules**:
- Multi-cloud architecture design patterns
- Enterprise governance and compliance frameworks
- Cost optimization and FinOps practices
- Disaster recovery and business continuity planning
- Performance optimization and capacity planning

### Platform Engineer Track
**Duration**: Foundation + Intermediate + Platform-specific modules (70 hours)

**Additional Modules**:
- Platform operations and maintenance
- Monitoring and observability implementation
- Incident response and troubleshooting
- Automation and CI/CD integration
- Security hardening and best practices

### Security Engineer Track
**Duration**: Foundation + Security-specific modules (60 hours)

**Additional Modules**:
- Zero trust architecture implementation
- Policy as code development and testing
- Compliance automation and auditing
- Vulnerability assessment and remediation
- Identity and access management across clouds

### Developer Track
**Duration**: Foundation + Developer-specific modules (50 hours)

**Additional Modules**:
- Application development on HashiCorp platform
- Service mesh integration for applications
- Secret management for applications
- CI/CD workflow integration
- Local development environment setup

## Certification Paths

### HashiCorp Certified: Multi-Cloud Practitioner
**Custom certification program for the platform**
**Preparation Time**: 100+ hours study and hands-on practice
**Prerequisites**: Completion of Foundation and Intermediate training

**Exam Domains**:
1. Multi-cloud fundamentals and architecture (20%)
2. Terraform Enterprise operations and governance (25%)
3. Consul service mesh and networking (20%)
4. Vault secrets and security management (20%)
5. Nomad workload orchestration (10%)
6. Boundary secure access (5%)

**Hands-on Lab Requirements**:
- Deploy infrastructure across all three cloud providers
- Configure cross-cloud service mesh
- Implement comprehensive secrets management
- Deploy and manage multi-cloud workloads
- Configure zero trust access controls

### Individual Product Certifications
**HashiCorp Terraform Associate** → **Professional**
**HashiCorp Vault Associate** → **Professional**
**HashiCorp Consul Associate**

## Training Resources

### Learning Management System
- **Platform**: Custom HashiCorp training portal
- **Content**: Interactive labs, video tutorials, documentation
- **Progress Tracking**: Individual and team progress monitoring
- **Assessments**: Knowledge checks, practical exercises, final exams

### Lab Environment
- **Cloud Sandboxes**: Dedicated AWS, Azure, and GCP accounts
- **Pre-configured Infrastructure**: Ready-to-use HashiCorp deployments  
- **Safe Learning Space**: Isolated from production systems
- **Reset Capability**: Fresh environment for each learning session

### Learning Resources
```bash
# Training environment access
export TRAINING_AWS_ACCOUNT="123456789012"
export TRAINING_AZURE_SUBSCRIPTION="subscription-id"
export TRAINING_GCP_PROJECT="hashicorp-training"

# HashiCorp product endpoints
export TFE_URL="https://tfe-training.company.com"
export VAULT_ADDR="https://vault-training.company.com:8200"  
export CONSUL_HTTP_ADDR="https://consul-training.company.com:8500"
export NOMAD_ADDR="https://nomad-training.company.com:4646"

# Training credentials (rotated daily)
export TFE_TOKEN="$(vault kv get -field=token secret/training/tfe)"
export VAULT_TOKEN="$(vault kv get -field=token secret/training/vault)"
export CONSUL_HTTP_TOKEN="$(vault kv get -field=token secret/training/consul)"
```

### Documentation Library
- **HashiCorp Official Documentation**: Product guides and references
- **Multi-Cloud Best Practices**: Curated recommendations and patterns
- **Troubleshooting Guides**: Common issues and solutions
- **Video Library**: Recorded sessions and demonstrations
- **Community Resources**: Forums, user groups, and external content

## Assessment and Certification

### Continuous Assessment
- **Module Quizzes**: Knowledge verification after each module
- **Hands-on Labs**: Practical skill demonstration
- **Peer Reviews**: Code review and architecture discussions
- **Progress Tracking**: Individual and team progress monitoring

### Final Certification Exam
- **Written Exam**: 75 multiple choice and scenario questions (90 minutes)
- **Practical Exam**: Hands-on deployment and configuration (4 hours)
- **Architecture Review**: Present and defend multi-cloud architecture design
- **Pass Requirements**: 80% minimum score on all components

### Continuing Education
- **Monthly Tech Talks**: New features and best practices
- **Quarterly Deep Dives**: Advanced topics and case studies
- **Annual Conference**: HashiConf attendance with knowledge sharing
- **Certification Renewal**: Annual exam and continuing education requirements

## Success Metrics and Outcomes

### Individual Learning Outcomes
- **Technical Proficiency**: Demonstrated ability to operate HashiCorp platform
- **Architecture Skills**: Ability to design multi-cloud solutions
- **Troubleshooting Capability**: Effective problem diagnosis and resolution
- **Best Practices Adoption**: Consistent application of platform standards

### Team Effectiveness Measures
- **Deployment Velocity**: Faster infrastructure provisioning and application deployment
- **Operational Excellence**: Reduced incidents and improved reliability
- **Security Posture**: Consistent security policy enforcement
- **Cost Optimization**: Improved resource utilization and cost management

### Organizational Benefits
- **Digital Transformation**: Accelerated cloud adoption and modernization
- **Innovation Enablement**: Faster time to market for new products and features
- **Risk Reduction**: Improved security, compliance, and disaster recovery
- **Competitive Advantage**: Enhanced technical capabilities and market position

---
**Training Materials Version**: 1.0  
**Last Updated**: 2024-01-15  
**Next Review Date**: 2024-04-15  
**Document Owner**: Learning and Development Team