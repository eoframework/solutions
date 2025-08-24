# HashiCorp Multi-Cloud Platform - Configuration Templates

## Overview
This document provides standardized configuration templates for deploying and managing the HashiCorp Multi-Cloud Infrastructure Management Platform. These templates ensure consistency, security, and best practices across AWS, Azure, and Google Cloud Platform deployments.

## Platform Configuration Overview

### HashiCorp Product Suite Configuration
The multi-cloud platform integrates five core HashiCorp products:
- **Terraform Enterprise**: Infrastructure as Code management
- **Consul Enterprise**: Service discovery and service mesh
- **Vault Enterprise**: Secrets and identity management
- **Nomad Enterprise**: Workload orchestration
- **Boundary Enterprise**: Secure remote access

## Terraform Configuration Templates

### Multi-Cloud Terraform Variables
```hcl
# terraform.tfvars - Multi-Cloud Configuration
project_name = "hashicorp-multicloud"
environment  = "prod"
owner        = "platform-team"
cost_center  = "infrastructure"

# Global Configuration
enable_multi_cloud    = true
enable_cross_cloud_vpn = true
enable_monitoring     = true
enable_backup        = true

# AWS Configuration
aws_region = "us-east-1"
aws_vpc_cidr = "10.10.0.0/16"
aws_public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24", 
  "10.10.3.0/24"
]
aws_private_subnet_cidrs = [
  "10.10.10.0/24",
  "10.10.11.0/24",
  "10.10.12.0/24"
]

# Azure Configuration  
azure_location = "East US 2"
azure_vnet_cidr = "10.20.0.0/16"
azure_public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24",
  "10.20.3.0/24"
]
azure_private_subnet_cidrs = [
  "10.20.10.0/24",
  "10.20.11.0/24", 
  "10.20.12.0/24"
]

# GCP Configuration
gcp_region = "us-central1"
gcp_vpc_cidr = "10.30.0.0/16"
gcp_public_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24",
  "10.30.3.0/24"
]
gcp_private_subnet_cidrs = [
  "10.30.10.0/24",
  "10.30.11.0/24",
  "10.30.12.0/24"
]

# Kubernetes Cluster Configuration
kubernetes_version = "1.28"
node_count = 6
min_node_count = 3
max_node_count = 20

# AWS EKS Nodes
aws_node_instance_types = ["m5.xlarge", "m5.2xlarge"]

# Azure AKS Nodes
azure_node_vm_size = "Standard_D4s_v3"

# GCP GKE Nodes  
gcp_node_machine_type = "n1-standard-4"

# HashiCorp Configuration
consul_datacenter_aws = "aws-dc"
consul_datacenter_azure = "azure-dc" 
consul_datacenter_gcp = "gcp-dc"

vault_cluster_name = "multi-cloud-vault"
nomad_region = "global"
boundary_scope = "global"

# Security Configuration
enable_encryption = true
enable_network_policies = true
enable_pod_security_policies = true
enable_rbac = true

# Domain and SSL
domain_name = "hashicorp.company.com"
enable_ssl = true
ssl_cert_source = "acm" # or "lets-encrypt" or "custom"

# Backup Configuration
backup_retention_days = 90
enable_cross_region_backup = true
backup_schedule = "0 2 * * *" # Daily at 2 AM

# Monitoring Configuration
enable_prometheus = true
enable_grafana = true
enable_alerting = true
metrics_retention_days = 30
```

### AWS-Specific Configuration
```hcl
# AWS provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "terraform"
      MultiCloud  = "true"
    }
  }
}

# AWS EKS Cluster Configuration
resource "aws_eks_cluster" "hashicorp_cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.allowed_cidr_blocks
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-eks-cluster"
    Type = "kubernetes-cluster"
  })
}

# AWS RDS for HashiCorp backends
resource "aws_db_instance" "hashicorp_postgres" {
  identifier = "${var.project_name}-postgres"
  
  engine         = "postgres"
  engine_version = "14.9"
  instance_class = "db.r5.xlarge"
  
  allocated_storage     = 500
  max_allocated_storage = 2000
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.rds.arn
  
  db_name  = "hashicorp"
  username = "hashicorp"
  password = random_password.db_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.hashicorp.name
  
  multi_az               = true
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-postgres-final-snapshot"
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-postgres"
    Type = "database"
  })
}
```

### Azure-Specific Configuration
```hcl
# Azure provider configuration
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Azure AKS Cluster Configuration
resource "azurerm_kubernetes_cluster" "hashicorp_cluster" {
  name                = "${var.project_name}-aks-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.azure_node_vm_size
    vnet_subnet_id  = azurerm_subnet.private[0].id
    
    enable_auto_scaling = true
    min_count          = var.min_node_count
    max_count          = var.max_node_count
    
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  azure_policy_enabled = true
  
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-aks-cluster"
    Type = "kubernetes-cluster"
  })
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_flexible_server" "hashicorp" {
  name                = "${var.project_name}-postgres"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  version        = "14"
  administrator_login    = "hashicorp"
  administrator_password = random_password.db_password.result
  
  sku_name   = "GP_Standard_D4s_v3"
  storage_mb = 32768
  
  backup_retention_days        = 30
  geo_redundant_backup_enabled = true
  
  high_availability {
    mode = "ZoneRedundant"
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-postgres"
    Type = "database"
  })
}
```

### GCP-Specific Configuration
```hcl
# GCP provider configuration
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# GCP GKE Cluster Configuration
resource "google_container_cluster" "hashicorp_cluster" {
  name     = "${var.project_name}-gke-cluster"
  location = var.gcp_region
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  min_master_version = var.kubernetes_version
  
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.private[0].name
  
  networking_mode = "VPC_NATIVE"
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  network_policy {
    enabled = true
  }
  
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }
  
  resource_labels = merge(local.common_tags, {
    name = "${replace(var.project_name, "-", "_")}_gke_cluster"
    type = "kubernetes_cluster"
  })
}

# GCP node pool
resource "google_container_node_pool" "hashicorp_nodes" {
  name       = "${var.project_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.hashicorp_cluster.name
  
  node_count = var.node_count
  
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  
  node_config {
    preemptible  = false
    machine_type = var.gcp_node_machine_type
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  
  upgrade_settings {
    max_surge       = 2
    max_unavailable = 1
  }
}

# Cloud SQL for PostgreSQL
resource "google_sql_database_instance" "hashicorp" {
  name             = "${var.project_name}-postgres"
  database_version = "POSTGRES_14"
  region           = var.gcp_region
  
  settings {
    tier              = "db-standard-4"
    availability_type = "REGIONAL"
    disk_size         = 100
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      location                       = var.gcp_region
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 30
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }
    
    database_flags {
      name  = "log_statement"
      value = "all"
    }
  }
  
  deletion_protection = false
}
```

## Kubernetes Configuration Templates

### HashiCorp Namespace and RBAC
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hashicorp-system
  labels:
    name: hashicorp-system
    platform: hashicorp-multicloud
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: hashicorp-operator
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hashicorp-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: hashicorp-operator
subjects:
- kind: ServiceAccount
  name: hashicorp-operator
  namespace: hashicorp-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: hashicorp-operator
  namespace: hashicorp-system
```

### Consul Enterprise Configuration
```yaml
# consul-values.yaml
global:
  name: consul
  datacenter: "${DATACENTER_NAME}"
  image: "hashicorp/consul-enterprise:1.16.1-ent"
  imageK8S: "hashicorp/consul-k8s-control-plane:1.2.1"
  
  tls:
    enabled: true
    enableAutoEncrypt: true
    
  acls:
    manageSystemACLs: true
    
  federation:
    enabled: true
    primaryDatacenter: "aws-dc"
    
  meshGateway:
    enabled: true
    replicas: 2

server:
  replicas: 5
  bootstrapExpect: 5
  
  enterprise:
    enabled: true
    
  connect:
    enabled: true
    
  storage: "10Gi"
  storageClass: "ssd"
  
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"

client:
  enabled: true
  
connectInject:
  enabled: true
  default: false
  
controller:
  enabled: true

meshGateway:
  enabled: true
  replicas: 2
  
  service:
    type: LoadBalancer
    ports:
    - port: 443
      nodePort: null
      
ui:
  enabled: true
  service:
    type: LoadBalancer
    
ingressGateways:
  enabled: true
  defaults:
    replicas: 2
  gateways:
  - name: ingress-gateway
    service:
      type: LoadBalancer
      ports:
      - port: 80
      - port: 443
```

### Vault Enterprise Configuration
```yaml
# vault-values.yaml
global:
  enabled: true
  namespace: "hashicorp-system"

server:
  image:
    repository: "hashicorp/vault-enterprise"
    tag: "1.14.8-ent"
  
  enterpriseLicense:
    secretName: vault-ent-license
    secretKey: license
    
  extraSecretEnvironmentVars:
  - envName: VAULT_LICENSE
    secretName: vault-ent-license
    secretKey: license
    
  ha:
    enabled: true
    replicas: 5
    
    config: |
      ui = true
      
      listener "tcp" {
        tls_disable = 0
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/vault/userconfig/vault-tls/tls.crt"
        tls_key_file  = "/vault/userconfig/vault-tls/tls.key"
      }
      
      storage "consul" {
        path = "vault/"
        address = "HOST_IP:8500"
        scheme = "https"
        tls_ca_file = "/vault/userconfig/consul-ca/ca.crt"
      }
      
      service_registration "kubernetes" {}
      
      seal "awskms" {
        region = "us-east-1"
        kms_key_id = "alias/vault-seal-key"
      }
      
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"
      
  volumes:
  - name: vault-tls
    secret:
      secretName: vault-tls
  - name: consul-ca
    secret:
      secretName: consul-ca
      
  volumeMounts:
  - mountPath: /vault/userconfig/vault-tls
    name: vault-tls
    readOnly: true
  - mountPath: /vault/userconfig/consul-ca
    name: consul-ca
    readOnly: true

ui:
  enabled: true
  serviceType: "LoadBalancer"
  
injector:
  enabled: true
  
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Terraform Enterprise Configuration
```yaml
# terraform-enterprise-values.yaml
replicaCount: 3

image:
  repository: hashicorp/terraform-enterprise
  tag: "v202401-1"
  pullPolicy: Always

tfe:
  hostname: "${TFE_HOSTNAME}"
  
  tls:
    certificateSecret: "tfe-tls"
    
  database:
    host: "${DATABASE_HOST}"
    name: "terraform_enterprise"
    username: "terraform"
    passwordSecret: "tfe-database-password"
    
  object_storage:
    type: "s3"
    bucket: "${TFE_OBJECT_STORAGE_BUCKET}"
    region: "${AWS_REGION}"
    
  redis:
    host: "${REDIS_HOST}"
    port: 6379
    passwordSecret: "tfe-redis-password"
    
  capacity:
    concurrency: 20
    memory: 512
    
  operational_mode: "active-active"
  
  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"

service:
  type: LoadBalancer
  port: 443
  targetPort: 8443

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
  - host: "${TFE_HOSTNAME}"
    paths:
    - path: /
      pathType: Prefix
  tls:
  - secretName: tfe-tls
    hosts:
    - "${TFE_HOSTNAME}"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

podDisruptionBudget:
  enabled: true
  minAvailable: 2
```

### Nomad Enterprise Configuration
```yaml
# nomad-values.yaml
global:
  name: nomad
  image: "hashicorp/nomad-enterprise:1.6.6-ent"

server:
  enabled: true
  replicas: 3
  
  enterpriseLicense:
    secretName: nomad-ent-license
    secretKey: license
    
  extraSecretEnvironmentVars:
  - envName: NOMAD_LICENSE
    secretName: nomad-ent-license
    secretKey: license
  
  config: |
    datacenter = "${DATACENTER_NAME}"
    region = "global"
    
    server {
      enabled = true
      bootstrap_expect = 3
      
      encrypt = "${NOMAD_GOSSIP_KEY}"
    }
    
    acl {
      enabled = true
    }
    
    consul {
      address = "consul-server:8500"
      ssl = true
      ca_file = "/consul/tls/ca/tls.crt"
      cert_file = "/consul/tls/client/tls.crt"
      key_file = "/consul/tls/client/tls.key"
    }
    
    vault {
      enabled = true
      address = "https://vault:8200"
      ca_file = "/vault/tls/ca/tls.crt"
      create_from_role = "nomad-cluster"
    }
    
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

client:
  enabled: true
  
  config: |
    datacenter = "${DATACENTER_NAME}"
    region = "global"
    
    client {
      enabled = true
    }
    
    consul {
      address = "consul-client:8500"
    }
    
    vault {
      enabled = true
      address = "https://vault:8200"
    }
    
ui:
  enabled: true
  service:
    type: LoadBalancer
```

### Boundary Enterprise Configuration
```yaml
# boundary-values.yaml
controller:
  enabled: true
  replicas: 3
  
  image:
    repository: "hashicorp/boundary-enterprise"
    tag: "0.13.2-ent"
    
  config: |
    disable_mlock = true
    
    controller {
      name = "boundary-controller"
      description = "Boundary controller"
      database {
        url = "postgresql://${BOUNDARY_DB_USERNAME}:${BOUNDARY_DB_PASSWORD}@${BOUNDARY_DB_HOST}:5432/${BOUNDARY_DB_NAME}?sslmode=require"
      }
    }
    
    listener "tcp" {
      address = "0.0.0.0:9200"
      purpose = "api"
      tls_disable = false
      tls_cert_file = "/boundary/tls/tls.crt"
      tls_key_file = "/boundary/tls/tls.key"
    }
    
    listener "tcp" {
      address = "0.0.0.0:9201"
      purpose = "cluster"
      tls_disable = false
      tls_cert_file = "/boundary/tls/tls.crt"
      tls_key_file = "/boundary/tls/tls.key"
    }
    
    kms "aead" {
      purpose = "root"
      aead_type = "aes-gcm"
      key = "${BOUNDARY_ROOT_KEY}"
      key_id = "global_root"
    }
    
    kms "aead" {
      purpose = "worker-auth"
      aead_type = "aes-gcm" 
      key = "${BOUNDARY_WORKER_KEY}"
      key_id = "global_worker-auth"
    }
    
    kms "aead" {
      purpose = "recovery"
      aead_type = "aes-gcm"
      key = "${BOUNDARY_RECOVERY_KEY}"
      key_id = "global_recovery"
    }

worker:
  enabled: true
  replicas: 2
  
  config: |
    disable_mlock = true
    
    worker {
      name = "boundary-worker"
      description = "Boundary worker"
      controllers = ["boundary-controller:9201"]
      public_addr = "${WORKER_PUBLIC_ADDRESS}"
    }
    
    listener "tcp" {
      address = "0.0.0.0:9202"
      purpose = "proxy"
      tls_disable = false
      tls_cert_file = "/boundary/tls/tls.crt"
      tls_key_file = "/boundary/tls/tls.key"
    }
    
    kms "aead" {
      purpose = "worker-auth"
      aead_type = "aes-gcm"
      key = "${BOUNDARY_WORKER_KEY}"
      key_id = "global_worker-auth"
    }

service:
  type: LoadBalancer
  
ui:
  enabled: true
```

## Cross-Cloud Connectivity Configuration

### VPN Gateway Configuration
```hcl
# AWS VPN Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpn-gateway"
  })
}

# AWS Customer Gateways for Azure and GCP
resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.vpn_gateway.ip_address
  type       = "ipsec.1"
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-cgw-azure"
  })
}

resource "aws_customer_gateway" "gcp" {
  bgp_asn    = 65001  
  ip_address = google_compute_address.vpn_gateway.address
  type       = "ipsec.1"
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-cgw-gcp"
  })
}

# VPN Connections
resource "aws_vpn_connection" "azure" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = false
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpn-azure"
  })
}
```

### Cross-Cloud Service Mesh Configuration
```yaml
# consul-mesh-gateway.yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: MeshGateway
metadata:
  name: mesh-gateway
  namespace: hashicorp-system
spec:
  gatewayClassName: "consul-mesh-gateway"
  listeners:
  - name: wan
    port: 443
    protocol: TCP
    hostname: "mesh-gateway.${DATACENTER_NAME}.company.com"
---
apiVersion: consul.hashicorp.com/v1alpha1
kind: ExportedServices
metadata:
  name: default
  namespace: consul
spec:
  services:
  - name: "*"
    consumers:
    - partition: "aws"
    - partition: "azure"  
    - partition: "gcp"
```

## Security Configuration Templates

### Network Policies
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: hashicorp-system-netpol
  namespace: hashicorp-system
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - namespaceSelector:
        matchLabels:
          name: hashicorp-system
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: consul
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: vault
  egress:
  - {}
```

### Pod Security Policy
```yaml
# pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: hashicorp-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Monitoring Configuration Templates

### Prometheus Configuration
```yaml
# prometheus-config.yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "hashicorp-rules.yml"

scrape_configs:
  - job_name: 'consul'
    consul_sd_configs:
      - server: 'consul-server:8500'
        scheme: https
        tls_config:
          ca_file: /etc/ssl/certs/consul-ca.crt
          cert_file: /etc/ssl/certs/consul-client.crt
          key_file: /etc/ssl/private/consul-client.key
    relabel_configs:
      - source_labels: [__meta_consul_service]
        target_label: service
      - source_labels: [__meta_consul_node]
        target_label: node

  - job_name: 'vault'
    static_configs:
      - targets: ['vault:8200']
    scheme: https
    tls_config:
      ca_file: /etc/ssl/certs/vault-ca.crt
    metrics_path: /v1/sys/metrics
    params:
      format: ['prometheus']

  - job_name: 'nomad'
    static_configs:
      - targets: ['nomad-server:4646']
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'boundary'
    static_configs:
      - targets: ['boundary-controller:9203']
    metrics_path: /v1/sys/metrics

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

## Usage Instructions

### Environment Setup
1. **Configure Cloud Credentials**: Set up authentication for all three cloud providers
2. **Customize Templates**: Update variables and configurations for your environment
3. **Validate Syntax**: Run `terraform validate` for all provider configurations
4. **Plan Deployment**: Review changes with `terraform plan` before applying

### Multi-Cloud Deployment Process
1. **Deploy Infrastructure**: Apply Terraform configurations in sequence
2. **Configure Kubernetes**: Set up cluster access for all providers
3. **Install HashiCorp Services**: Deploy using Helm charts with custom values
4. **Configure Cross-Cloud Connectivity**: Establish VPN and service mesh connections
5. **Validate Deployment**: Test all components and cross-cloud communication

### Configuration Management Best Practices
- Use Terraform workspaces for environment isolation
- Store sensitive values in cloud-native secret managers
- Implement proper state file management and locking
- Regular backup of all configurations and state files
- Document all customizations and deviations from templates

---
**Configuration Templates Version**: 1.0  
**Last Updated**: 2024-01-15  
**Maintained by**: Platform Engineering Team