# OpenShift Container Platform Automation

This automation deploys and configures Red Hat OpenShift Container Platform using a multi-tool approach:

- **Terraform**: Cluster infrastructure provisioning (AWS, Azure, or VMware)
- **Ansible**: Day 2 configuration (OAuth, logging, monitoring, operators)
- **Helm**: Application deployment (GitOps templates, operator configurations)

## Prerequisites

- Red Hat OpenShift subscription (entitlement pull secret)
- Target infrastructure access (AWS/Azure/VMware credentials)
- Ansible 2.14+ with kubernetes.core collection
- Terraform 1.6+ (for infrastructure provisioning)
- Helm 3.x (for application deployment)
- oc CLI (OpenShift client)

## Quick Start

### 1. Generate Configuration

```bash
# Generate Ansible group_vars from configuration.csv
python /mnt/c/projects/wsl/eof-tools/automation/scripts/generate-ansible-vars.py \
    /mnt/c/projects/wsl/solutions/solutions/ibm/cloud/openshift-container-platform prod
```

### 2. Deploy Infrastructure (Terraform)

```bash
cd terraform/environments/prod
terraform init
terraform plan -var-file=config/cluster.tfvars
terraform apply -var-file=config/cluster.tfvars
```

### 3. Configure Platform (Ansible)

```bash
cd ansible
ansible-playbook -i inventory/prod playbooks/ocp-post-install.yml
ansible-playbook -i inventory/prod playbooks/operators-install.yml
ansible-playbook -i inventory/prod playbooks/security-config.yml
```

### 4. Deploy Applications (Helm)

```bash
cd helm
helm upgrade --install app-template charts/app-template \
    --namespace default \
    --values values/prod.yaml
```

## Folder Structure

```
automation/
├── README.md                     # This file
├── terraform/                    # Cluster provisioning
│   ├── environments/
│   │   ├── prod/                 # Production cluster
│   │   ├── test/                 # Test cluster
│   │   └── dr/                   # DR cluster
│   └── modules/
│       ├── aws-ocp/              # OCP on AWS
│       ├── azure-ocp/            # OCP on Azure
│       └── vmware-ocp/           # OCP on vSphere
├── ansible/                      # Day 2 configuration
│   ├── playbooks/
│   │   ├── ocp-post-install.yml  # Post-installation config
│   │   ├── operators-install.yml # Operator deployment
│   │   └── security-config.yml   # Security hardening
│   ├── roles/
│   │   ├── ocp-oauth/            # OAuth/LDAP configuration
│   │   ├── ocp-logging/          # EFK stack setup
│   │   ├── ocp-monitoring/       # Prometheus/Grafana
│   │   └── ocp-operators/        # OperatorHub operators
│   └── inventory/
│       ├── prod/                 # Production inventory
│       ├── test/                 # Test inventory
│       └── dr/                   # DR inventory
└── helm/                         # Application deployment
    ├── charts/
    │   ├── app-template/         # Generic app template
    │   └── operators/            # Operator configurations
    └── values/
        ├── prod.yaml             # Production values
        ├── test.yaml             # Test values
        └── dr.yaml               # DR values
```

## Environment Differences

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Control Plane | 3 nodes | 3 nodes | 3 nodes |
| Worker Nodes | 3 nodes | 2 nodes | 3 nodes |
| LDAP Integration | Enabled | Disabled | Enabled |
| Service Mesh | Enabled | Disabled | Enabled |
| Quay Registry | Enabled | Disabled | Enabled |
| Backup | Daily, 30-day retention | Daily, 7-day | Daily, 30-day |

## Validation

```bash
# Verify cluster health
oc get nodes
oc get co  # Check cluster operators

# Verify Ansible playbook syntax
ansible-playbook --syntax-check playbooks/ocp-post-install.yml

# Validate Helm charts
helm lint charts/app-template
```

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Bootstrap fails | Check ignition config and network connectivity |
| OAuth not working | Verify LDAP credentials and bind DN |
| Operators pending | Check OperatorHub catalog source status |
| Pods not scheduling | Verify node taints and resource limits |
