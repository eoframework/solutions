# HashiCorp Multi-Cloud Platform - Testing Procedures

## Overview
This document outlines comprehensive testing procedures for the HashiCorp Multi-Cloud Infrastructure Management Platform. These procedures ensure system reliability, security, and performance across AWS, Azure, and Google Cloud Platform before production deployment.

## Testing Framework Overview

### Test Categories
1. **Infrastructure Validation** - Cloud provider infrastructure and networking
2. **Kubernetes Cluster Validation** - Container orchestration platform testing
3. **HashiCorp Services Testing** - Individual product functionality validation
4. **Cross-Cloud Connectivity** - Multi-cloud communication and service mesh
5. **Security and Compliance** - Authentication, authorization, and policy enforcement
6. **Performance and Load Testing** - System performance under various conditions
7. **Disaster Recovery Testing** - Backup, recovery, and failover procedures
8. **Integration Testing** - External system integrations and workflows
9. **User Acceptance Testing** - End-user workflow validation

### Testing Environment Requirements
- Dedicated testing environment separate from production
- Access to all three cloud provider accounts (AWS, Azure, GCP)
- HashiCorp product licenses for enterprise features
- Monitoring and observability tools for test validation
- Load testing tools for performance validation

## Test 1: Multi-Cloud Infrastructure Validation

### Objective
Verify all cloud provider infrastructure components are deployed correctly across AWS, Azure, and Google Cloud Platform.

**Duration**: 2 hours  
**Prerequisites**: Terraform deployment completed for all cloud providers

### AWS Infrastructure Validation
```bash
# Test AWS VPC and networking
echo "Testing AWS infrastructure..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*hashicorp*" --query 'Vpcs[0].VpcId' --output text)
echo "VPC ID: $VPC_ID"

# Verify subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]' --output table

# Test EKS cluster
aws eks describe-cluster --name hashicorp-multicloud-eks-cluster --query 'cluster.[name,status,endpoint]' --output table

# Verify database connectivity
POSTGRES_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier hashicorp-multicloud-postgres --query 'DBInstances[0].Endpoint.Address' --output text)
psql -h $POSTGRES_ENDPOINT -U hashicorp -d hashicorp -c "SELECT version();"

# Test load balancer
aws elbv2 describe-load-balancers --names hashicorp-multicloud-alb
```

### Azure Infrastructure Validation
```bash
# Test Azure resource group and virtual network
echo "Testing Azure infrastructure..."
az network vnet list --resource-group hashicorp-multicloud-rg --query '[*].[name,addressSpace.addressPrefixes]' --output table

# Verify AKS cluster
az aks show --resource-group hashicorp-multicloud-rg --name hashicorp-multicloud-aks-cluster --query '[name,powerState.code,kubernetesVersion]' --output table

# Test database connectivity
POSTGRES_HOST=$(az postgres flexible-server show --resource-group hashicorp-multicloud-rg --name hashicorp-multicloud-postgres --query fullyQualifiedDomainName --output tsv)
psql -h $POSTGRES_HOST -U hashicorp -d hashicorp -c "SELECT version();"

# Check load balancer
az network lb list --resource-group hashicorp-multicloud-rg --query '[*].[name,provisioningState]' --output table
```

### GCP Infrastructure Validation
```bash
# Test GCP VPC and subnets
echo "Testing GCP infrastructure..."
gcloud compute networks list --filter="name:hashicorp-multicloud*"
gcloud compute networks subnets list --network=hashicorp-multicloud-vpc

# Verify GKE cluster
gcloud container clusters describe hashicorp-multicloud-gke-cluster --region=us-central1 --format="table(name,status,currentNodeVersion)"

# Test database connectivity
POSTGRES_IP=$(gcloud sql instances describe hashicorp-multicloud-postgres --format="value(ipAddresses[0].ipAddress)")
psql -h $POSTGRES_IP -U hashicorp -d hashicorp -c "SELECT version();"

# Check load balancer
gcloud compute forwarding-rules list --filter="name:hashicorp-multicloud*"
```

### Expected Results
- All infrastructure components created successfully in all three cloud providers
- Network connectivity established between components within each cloud
- Kubernetes clusters operational and accessible
- Databases accessible from respective Kubernetes clusters
- Load balancers configured and routing traffic correctly

**Pass Criteria**: All infrastructure validation checks pass across all cloud providers

## Test 2: Cross-Cloud Connectivity Validation

### Objective
Verify network connectivity and communication between all three cloud providers.

**Duration**: 1.5 hours

### VPN Connectivity Testing
```bash
# Test AWS to Azure VPN
echo "Testing cross-cloud VPN connectivity..."

# From AWS EKS cluster, test connectivity to Azure
kubectl --context=aws-prod run test-azure --image=busybox --restart=Never --rm -it -- ping 10.20.1.1

# From Azure AKS cluster, test connectivity to GCP
kubectl --context=azure-prod run test-gcp --image=busybox --restart=Never --rm -it -- ping 10.30.1.1

# From GCP GKE cluster, test connectivity to AWS
kubectl --context=gcp-prod run test-aws --image=busybox --restart=Never --rm -it -- ping 10.10.1.1

# Test bidirectional connectivity
for source in aws azure gcp; do
    for target in aws azure gcp; do
        if [ "$source" != "$target" ]; then
            echo "Testing $source to $target connectivity"
            kubectl --context=${source}-prod run test-${target} --image=busybox --restart=Never --rm -it -- nslookup consul-server.hashicorp-system.svc.cluster.local
        fi
    done
done
```

### Service Mesh Connectivity Testing
```bash
# Test Consul Connect service mesh across clouds
echo "Testing cross-cloud service mesh..."

# Deploy test services in each cloud
for cloud in aws azure gcp; do
    kubectl --context=${cloud}-prod apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: test-service-${cloud}
  namespace: hashicorp-system
  annotations:
    consul.hashicorp.com/connect-inject: "true"
spec:
  selector:
    app: test-service
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-service-${cloud}
  namespace: hashicorp-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-service
  template:
    metadata:
      labels:
        app: test-service
      annotations:
        consul.hashicorp.com/connect-inject: "true"
    spec:
      containers:
      - name: test-service
        image: nginx:alpine
        ports:
        - containerPort: 8080
EOF
done

# Test cross-cloud service discovery
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul catalog services

# Test service-to-service communication across clouds
kubectl --context=aws-prod run test-client --image=curlimages/curl --restart=Never --rm -it -- \
    curl -s http://test-service-azure.service.azure-dc.consul/
```

### Expected Results
- Successful ping connectivity between all cloud provider networks
- VPN tunnels established and operational
- Service mesh gateways routing traffic correctly
- Cross-cloud service discovery working
- Secure service-to-service communication established

## Test 3: HashiCorp Services Functionality Testing

### Objective
Validate core functionality of all HashiCorp products deployed across the multi-cloud platform.

**Duration**: 2.5 hours

### Consul Enterprise Testing
```bash
echo "Testing Consul Enterprise functionality..."

# Test cluster membership across all clouds
for cloud in aws azure gcp; do
    echo "Testing Consul in $cloud..."
    kubectl --context=${cloud}-prod exec -n hashicorp-system consul-server-0 -- \
        consul members
    
    # Test service discovery
    kubectl --context=${cloud}-prod exec -n hashicorp-system consul-server-0 -- \
        consul catalog services
    
    # Test key-value store
    kubectl --context=${cloud}-prod exec -n hashicorp-system consul-server-0 -- \
        consul kv put test/key-${cloud} "value-${cloud}"
    
    kubectl --context=${cloud}-prod exec -n hashicorp-system consul-server-0 -- \
        consul kv get test/key-${cloud}
done

# Test cross-datacenter replication
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul kv get test/key-azure

# Test mesh gateway functionality
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul catalog nodes -service mesh-gateway
```

### Vault Enterprise Testing
```bash
echo "Testing Vault Enterprise functionality..."

# Test Vault status across all clusters
for cloud in aws azure gcp; do
    echo "Testing Vault in $cloud..."
    kubectl --context=${cloud}-prod exec -n hashicorp-system vault-0 -- \
        vault status
    
    # Test secret storage and retrieval
    kubectl --context=${cloud}-prod exec -n hashicorp-system vault-0 -- \
        vault kv put secret/test-${cloud} username=admin password=secret123
    
    kubectl --context=${cloud}-prod exec -n hashicorp-system vault-0 -- \
        vault kv get secret/test-${cloud}
    
    # Test dynamic secrets
    kubectl --context=${cloud}-prod exec -n hashicorp-system vault-0 -- \
        vault write database/config/postgresql-${cloud} \
        plugin_name=postgresql-database-plugin \
        connection_url="postgresql://{{username}}:{{password}}@postgres:5432/hashicorp?sslmode=require" \
        allowed_roles="readonly"
done

# Test enterprise features
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault operator raft list-peers

# Test auto-unsealing
kubectl --context=aws-prod rollout restart statefulset/vault -n hashicorp-system
sleep 60
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- vault status
```

### Terraform Enterprise Testing
```bash
echo "Testing Terraform Enterprise functionality..."

# Test API connectivity for each cloud instance
for cloud in aws azure gcp; do
    echo "Testing TFE in $cloud..."
    TFE_URL="https://tfe-${cloud}.company.com"
    
    # Health check
    curl -sf "${TFE_URL}/_health_check"
    
    # API authentication test
    curl -H "Authorization: Bearer $TFE_TOKEN" \
        "${TFE_URL}/api/v2/account/details"
    
    # Test workspace creation
    curl -X POST \
        -H "Authorization: Bearer $TFE_TOKEN" \
        -H "Content-Type: application/vnd.api+json" \
        -d '{
            "data": {
                "type": "workspaces",
                "attributes": {
                    "name": "test-workspace-'${cloud}'",
                    "terraform-version": "1.6.6"
                }
            }
        }' \
        "${TFE_URL}/api/v2/organizations/test-org/workspaces"
done

# Test workspace operations
TFE_URL="https://tfe-aws.company.com"
WORKSPACE_ID=$(curl -s -H "Authorization: Bearer $TFE_TOKEN" \
    "${TFE_URL}/api/v2/organizations/test-org/workspaces/test-workspace-aws" \
    | jq -r '.data.id')

# Upload configuration version
curl -X POST \
    -H "Authorization: Bearer $TFE_TOKEN" \
    -H "Content-Type: application/vnd.api+json" \
    -d '{
        "data": {
            "type": "configuration-versions",
            "attributes": {
                "auto-queue-runs": false
            }
        }
    }' \
    "${TFE_URL}/api/v2/workspaces/${WORKSPACE_ID}/configuration-versions"
```

### Nomad Enterprise Testing
```bash
echo "Testing Nomad Enterprise functionality..."

# Test Nomad cluster status across clouds
for cloud in aws azure gcp; do
    echo "Testing Nomad in $cloud..."
    kubectl --context=${cloud}-prod exec -n hashicorp-system nomad-server-0 -- \
        nomad server members
    
    kubectl --context=${cloud}-prod exec -n hashicorp-system nomad-server-0 -- \
        nomad node status
    
    # Test job submission
    kubectl --context=${cloud}-prod exec -n hashicorp-system nomad-server-0 -- \
        nomad job run - <<EOF
job "test-job-${cloud}" {
  datacenters = ["${cloud}-dc"]
  type = "service"
  
  group "web" {
    count = 1
    
    task "frontend" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
        ports = ["http"]
      }
      
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
EOF
    
    # Verify job status
    kubectl --context=${cloud}-prod exec -n hashicorp-system nomad-server-0 -- \
        nomad job status test-job-${cloud}
done

# Test multi-region job placement
kubectl --context=aws-prod exec -n hashicorp-system nomad-server-0 -- \
    nomad job run - <<EOF
job "multi-region-job" {
  datacenters = ["aws-dc", "azure-dc", "gcp-dc"]
  type = "service"
  
  group "web" {
    count = 3
    
    constraint {
      distinct_hosts = true
    }
    
    task "frontend" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
      }
      
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
EOF
```

### Boundary Enterprise Testing
```bash
echo "Testing Boundary Enterprise functionality..."

# Test Boundary controller status
for cloud in aws azure gcp; do
    echo "Testing Boundary in $cloud..."
    BOUNDARY_URL="https://boundary-${cloud}.company.com:9200"
    
    # Health check
    curl -sk "${BOUNDARY_URL}/v1/health"
    
    # Authentication test
    boundary authenticate password \
        -auth-method-id=ampw_1234567890 \
        -login-name=admin \
        -password=password
done

# Test target connectivity
boundary targets list

# Test session establishment
boundary connect ssh -target-id=ttcp_1234567890
```

### Expected Results
- All HashiCorp services operational across all cloud providers
- API endpoints responding correctly
- Cross-cloud functionality working (Consul federation, Vault replication)
- Enterprise features activated and functional
- Service mesh routing traffic correctly

## Test 4: Security and Compliance Validation

### Objective
Validate security controls, authentication, authorization, and compliance features.

**Duration**: 2 hours

### Authentication and Authorization Testing
```bash
echo "Testing authentication and authorization..."

# Test SSO integration
for cloud in aws azure gcp; do
    TFE_URL="https://tfe-${cloud}.company.com"
    
    # Test SAML authentication flow
    curl -c cookies.txt -b cookies.txt -L "${TFE_URL}/session"
    
    # Test API token authentication
    curl -H "Authorization: Bearer $TFE_TOKEN" \
        "${TFE_URL}/api/v2/organizations"
    
    # Test unauthorized access (should fail)
    curl -H "Authorization: Bearer invalid-token" \
        "${TFE_URL}/api/v2/organizations"
done

# Test Vault authentication methods
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault auth list

# Test RBAC in Kubernetes
kubectl --context=aws-prod auth can-i create pods --as=system:serviceaccount:hashicorp-system:test-user
kubectl --context=aws-prod auth can-i delete secrets --as=system:serviceaccount:hashicorp-system:test-user
```

### Network Security Testing
```bash
echo "Testing network security controls..."

# Test security group rules
for cloud in aws azure gcp; do
    echo "Testing network security in $cloud..."
    
    case $cloud in
        aws)
            # Test allowed connections
            nc -zv $(kubectl --context=aws-prod get svc consul-ui -n hashicorp-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') 80
            
            # Test blocked connections (should fail)
            nc -zv $(kubectl --context=aws-prod get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') 22
            ;;
        azure)
            # Test NSG rules
            nc -zv $(kubectl --context=azure-prod get svc consul-ui -n hashicorp-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}') 80
            ;;
        gcp)
            # Test firewall rules
            nc -zv $(kubectl --context=gcp-prod get svc consul-ui -n hashicorp-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}') 80
            ;;
    esac
done

# Test TLS encryption
for cloud in aws azure gcp; do
    openssl s_client -connect tfe-${cloud}.company.com:443 -servername tfe-${cloud}.company.com
done
```

### Policy Enforcement Testing
```bash
echo "Testing policy enforcement..."

# Test Terraform Enterprise Sentinel policies
TFE_URL="https://tfe-aws.company.com"

# Create a policy that restricts instance types
curl -X POST \
    -H "Authorization: Bearer $TFE_TOKEN" \
    -H "Content-Type: application/vnd.api+json" \
    -d '{
        "data": {
            "type": "policies",
            "attributes": {
                "name": "restrict-instance-types",
                "policy": "import \"tfplan/v2\" as tfplan\n\nallowed_types = [\"t3.micro\", \"t3.small\"]\n\nmain = rule {\n  all tfplan.resource_changes as _, rc {\n    rc.type is \"aws_instance\" implies rc.change.after.instance_type in allowed_types\n  }\n}",
                "enforcement-level": "hard-mandatory"
            }
        }
    }' \
    "${TFE_URL}/api/v2/organizations/test-org/policies"

# Test policy violation with larger instance
# (This should be blocked by the policy)

# Test Consul service intentions
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul intention create -allow frontend backend

kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul intention create -deny untrusted-service backend
```

### Expected Results
- Authentication systems working correctly across all platforms
- Unauthorized access properly blocked
- Network security controls preventing unauthorized connections
- TLS encryption enforced for all communications
- Policy enforcement blocking non-compliant configurations
- RBAC properly restricting user permissions

## Test 5: Performance and Load Testing

### Objective
Validate system performance under load and ensure scalability requirements are met.

**Duration**: 3 hours

### Infrastructure Load Testing
```bash
echo "Starting infrastructure load testing..."

# Test Kubernetes cluster scaling
for cloud in aws azure gcp; do
    echo "Testing cluster scaling in $cloud..."
    
    # Deploy a resource-intensive workload
    kubectl --context=${cloud}-prod apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-test-${cloud}
  namespace: default
spec:
  replicas: 10
  selector:
    matchLabels:
      app: load-test
  template:
    metadata:
      labels:
        app: load-test
    spec:
      containers:
      - name: stress
        image: progrium/stress
        args: ["--cpu", "2", "--timeout", "300s"]
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
          limits:
            cpu: "2"
            memory: "2Gi"
EOF
    
    # Monitor cluster autoscaling
    kubectl --context=${cloud}-prod get nodes -w &
    sleep 300
    kill $!
    
    # Clean up
    kubectl --context=${cloud}-prod delete deployment load-test-${cloud} -n default
done
```

### HashiCorp Services Load Testing
```bash
echo "Testing HashiCorp services under load..."

# Consul load testing
for cloud in aws azure gcp; do
    echo "Load testing Consul in $cloud..."
    
    # Test key-value store performance
    kubectl --context=${cloud}-prod run consul-load-test --image=alpine/curl --restart=Never --rm -it -- \
        sh -c '
        for i in $(seq 1 1000); do
            kubectl exec consul-server-0 -n hashicorp-system -- consul kv put load-test/key-$i "value-$i"
        done
        '
    
    # Test service discovery performance
    kubectl --context=${cloud}-prod exec -n hashicorp-system consul-server-0 -- \
        consul watch -type=services echo "Service change detected"
done

# Vault load testing
echo "Load testing Vault..."
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault write -f auth/userpass/users/loadtest password=test

# Concurrent secret operations
for i in {1..100}; do
    kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
        vault kv put secret/load-test-$i key=value &
done
wait

# Terraform Enterprise load testing
echo "Load testing Terraform Enterprise..."
TFE_URL="https://tfe-aws.company.com"

# Create multiple concurrent workspaces
for i in {1..10}; do
    curl -X POST \
        -H "Authorization: Bearer $TFE_TOKEN" \
        -H "Content-Type: application/vnd.api+json" \
        -d '{
            "data": {
                "type": "workspaces",
                "attributes": {
                    "name": "load-test-workspace-'$i'",
                    "auto-apply": false
                }
            }
        }' \
        "${TFE_URL}/api/v2/organizations/test-org/workspaces" &
done
wait
```

### Database Performance Testing
```bash
echo "Testing database performance..."

# Test PostgreSQL performance across all clouds
for cloud in aws azure gcp; do
    echo "Testing database performance in $cloud..."
    
    case $cloud in
        aws)
            POSTGRES_HOST=$(aws rds describe-db-instances --db-instance-identifier hashicorp-multicloud-postgres --query 'DBInstances[0].Endpoint.Address' --output text)
            ;;
        azure)
            POSTGRES_HOST=$(az postgres flexible-server show --resource-group hashicorp-multicloud-rg --name hashicorp-multicloud-postgres --query fullyQualifiedDomainName --output tsv)
            ;;
        gcp)
            POSTGRES_HOST=$(gcloud sql instances describe hashicorp-multicloud-postgres --format="value(ipAddresses[0].ipAddress)")
            ;;
    esac
    
    # Run pgbench for performance testing
    pgbench -h $POSTGRES_HOST -U hashicorp -d hashicorp -i
    pgbench -h $POSTGRES_HOST -U hashicorp -d hashicorp -c 10 -j 2 -T 60
done
```

### Expected Results
- Kubernetes clusters auto-scale correctly under load
- HashiCorp services maintain performance under concurrent operations
- Database performance meets SLA requirements
- No service degradation during load testing
- System recovery after load testing completes

## Test 6: Disaster Recovery Validation

### Objective
Validate backup and recovery procedures across all cloud providers and services.

**Duration**: 4 hours

### Backup Validation Testing
```bash
echo "Testing backup procedures..."

# Test database backups
for cloud in aws azure gcp; do
    echo "Testing database backup in $cloud..."
    
    case $cloud in
        aws)
            # Test RDS backup
            aws rds create-db-snapshot \
                --db-instance-identifier hashicorp-multicloud-postgres \
                --db-snapshot-identifier test-backup-$(date +%Y%m%d)
            ;;
        azure)
            # Azure automatically handles backups, test restore capability
            BACKUP_TIME=$(az postgres flexible-server show \
                --resource-group hashicorp-multicloud-rg \
                --name hashicorp-multicloud-postgres \
                --query earliestRestoreDate --output tsv)
            echo "Earliest restore time: $BACKUP_TIME"
            ;;
        gcp)
            # Test Cloud SQL backup
            gcloud sql backups create \
                --instance=hashicorp-multicloud-postgres \
                --description="Test backup $(date)"
            ;;
    esac
done

# Test HashiCorp service backups
echo "Testing HashiCorp service backups..."

# Consul snapshot
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul snapshot save /tmp/consul-backup.snap

# Vault snapshot
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault operator raft snapshot save /tmp/vault-backup.snap

# Test backup upload to object storage
for cloud in aws azure gcp; do
    case $cloud in
        aws)
            aws s3 cp /tmp/consul-backup.snap s3://hashicorp-backups-${cloud}/consul/
            aws s3 cp /tmp/vault-backup.snap s3://hashicorp-backups-${cloud}/vault/
            ;;
        azure)
            az storage blob upload \
                --account-name hashicorpbackups${cloud} \
                --container-name consul \
                --name consul-backup.snap \
                --file /tmp/consul-backup.snap
            ;;
        gcp)
            gsutil cp /tmp/consul-backup.snap gs://hashicorp-backups-${cloud}/consul/
            gsutil cp /tmp/vault-backup.snap gs://hashicorp-backups-${cloud}/vault/
            ;;
    esac
done
```

### Recovery Testing
```bash
echo "Testing recovery procedures..."

# Test Consul recovery
echo "Testing Consul cluster recovery..."
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul snapshot restore /tmp/consul-backup.snap

# Test Vault recovery
echo "Testing Vault cluster recovery..."
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault operator raft snapshot restore /tmp/vault-backup.snap

# Test cross-region failover
echo "Testing cross-region failover..."

# Simulate AWS region failure by scaling down resources
kubectl --context=aws-prod scale deployment consul-server --replicas=0 -n hashicorp-system
kubectl --context=aws-prod scale deployment vault --replicas=0 -n hashicorp-system

# Verify services continue operating in other regions
kubectl --context=azure-prod get pods -n hashicorp-system
kubectl --context=gcp-prod get pods -n hashicorp-system

# Test service recovery
kubectl --context=azure-prod exec -n hashicorp-system consul-server-0 -- \
    consul members

# Restore AWS services
kubectl --context=aws-prod scale deployment consul-server --replicas=3 -n hashicorp-system
kubectl --context=aws-prod scale deployment vault --replicas=3 -n hashicorp-system
```

### Expected Results
- Backup procedures complete successfully for all services
- Recovery procedures restore services to operational state
- Cross-region failover maintains service availability
- Data consistency maintained during recovery operations
- RTO and RPO objectives met

## Test 7: Integration Testing

### Objective
Validate integration with external systems and end-to-end workflows.

**Duration**: 2 hours

### CI/CD Pipeline Integration
```bash
echo "Testing CI/CD integration..."

# Test GitHub Actions integration with TFE
# Create a test repository with Terraform configuration
git clone https://github.com/company/terraform-test.git
cd terraform-test

# Create a simple Terraform configuration
cat > main.tf <<EOF
resource "random_pet" "example" {
  length = 2
}

output "pet_name" {
  value = random_pet.example.id
}
EOF

# Push to trigger TFE run
git add .
git commit -m "Test TFE integration"
git push origin main

# Monitor TFE run via API
TFE_URL="https://tfe-aws.company.com"
RUN_ID=$(curl -s -H "Authorization: Bearer $TFE_TOKEN" \
    "${TFE_URL}/api/v2/organizations/test-org/workspaces/test-workspace/runs" \
    | jq -r '.data[0].id')

# Poll run status
while true; do
    STATUS=$(curl -s -H "Authorization: Bearer $TFE_TOKEN" \
        "${TFE_URL}/api/v2/runs/$RUN_ID" \
        | jq -r '.data.attributes.status')
    
    echo "Run status: $STATUS"
    
    if [[ "$STATUS" == "applied" || "$STATUS" == "errored" ]]; then
        break
    fi
    
    sleep 30
done
```

### Monitoring Integration Testing
```bash
echo "Testing monitoring integration..."

# Test Prometheus scraping HashiCorp metrics
kubectl --context=aws-prod exec -n monitoring prometheus-server-0 -- \
    curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job | contains("consul"))'

# Test Grafana dashboard access
GRAFANA_URL=$(kubectl --context=aws-prod get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s http://admin:admin@${GRAFANA_URL}/api/health

# Test AlertManager rules
kubectl --context=aws-prod exec -n monitoring alertmanager-0 -- \
    curl -s http://localhost:9093/api/v1/alerts
```

### Expected Results
- CI/CD pipelines trigger Terraform runs successfully
- Monitoring systems collect HashiCorp service metrics
- Alerting rules trigger correctly for test scenarios
- Integration APIs respond within acceptable time limits

## Test 8: User Acceptance Testing

### Objective
Validate end-user workflows and system usability across all HashiCorp services.

**Duration**: 3 hours

### Developer Workflow Testing
```bash
echo "Testing developer workflows..."

# Test workspace creation and management
TFE_URL="https://tfe-aws.company.com"

# Create workspace via UI simulation
curl -X POST \
    -H "Authorization: Bearer $TFE_TOKEN" \
    -H "Content-Type: application/vnd.api+json" \
    -d '{
        "data": {
            "type": "workspaces",
            "attributes": {
                "name": "developer-test-workspace",
                "working-directory": "",
                "vcs-repo": {
                    "identifier": "company/terraform-modules",
                    "oauth-token-id": "ot-xxxxxxxxxxxx"
                }
            }
        }
    }' \
    "${TFE_URL}/api/v2/organizations/test-org/workspaces"

# Test variable management
curl -X POST \
    -H "Authorization: Bearer $TFE_TOKEN" \
    -H "Content-Type: application/vnd.api+json" \
    -d '{
        "data": {
            "type": "vars",
            "attributes": {
                "key": "environment",
                "value": "development",
                "category": "terraform",
                "hcl": false,
                "sensitive": false
            }
        }
    }' \
    "${TFE_URL}/api/v2/workspaces/ws-xxxxxxxx/vars"
```

### Operations Team Workflow Testing
```bash
echo "Testing operations team workflows..."

# Test Consul service discovery and health checking
kubectl --context=aws-prod exec -n hashicorp-system consul-server-0 -- \
    consul services register - <<EOF
{
  "Name": "test-service",
  "Port": 8080,
  "Check": {
    "HTTP": "http://localhost:8080/health",
    "Interval": "10s"
  }
}
EOF

# Test Vault secret management
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault kv put secret/app/config database_url="postgresql://user:pass@host:5432/db"

# Test Nomad job deployment
kubectl --context=aws-prod exec -n hashicorp-system nomad-server-0 -- \
    nomad job run - <<EOF
job "web-app" {
  datacenters = ["aws-dc"]
  
  group "web" {
    count = 2
    
    task "frontend" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
        ports = ["http"]
      }
      
      template {
        data = "DATABASE_URL={{ with secret \"secret/app/config\" }}{{ .Data.data.database_url }}{{ end }}"
        destination = "local/env"
        env = true
      }
      
      vault {
        policies = ["app-policy"]
      }
    }
  }
}
EOF
```

### Security Team Workflow Testing
```bash
echo "Testing security team workflows..."

# Test policy creation and enforcement
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault policy write app-policy - <<EOF
path "secret/data/app/*" {
  capabilities = ["read"]
}
EOF

# Test audit log review
kubectl --context=aws-prod exec -n hashicorp-system vault-0 -- \
    vault audit list

# Test Boundary access session
boundary authenticate password \
    -auth-method-id=ampw_1234567890 \
    -login-name=security-admin

boundary targets list
boundary connect ssh -target-id=ttcp_database_server
```

### Expected Results
- All user workflows complete successfully without errors
- UI responsiveness meets user expectations
- API responses complete within acceptable timeframes
- No critical usability issues identified
- User documentation accurate and complete

## Test Execution Summary

### Test Schedule
- **Phase 1** (Days 1-2): Infrastructure and connectivity testing
- **Phase 2** (Days 3-4): HashiCorp services and security testing  
- **Phase 3** (Days 5-6): Performance and disaster recovery testing
- **Phase 4** (Days 7-8): Integration and user acceptance testing

### Success Criteria
- All automated tests pass with >95% success rate
- Performance metrics meet or exceed SLA requirements
- Security controls validated and compliant
- User acceptance criteria met
- Recovery procedures validated and documented

### Test Reporting
Each test execution should document:
- Test execution timestamp and duration
- Pass/fail results with evidence
- Performance metrics captured
- Issues identified with severity levels
- Resolution actions taken
- Recommendations for production deployment

---
**Testing Procedures Version**: 1.0  
**Last Updated**: 2024-01-15  
**Document Owner**: Quality Assurance Team  
**Approved by**: Platform Architecture Team