# AWS Cloud Migration - Implementation Guide

## Document Information
**Solution**: AWS On-Premise to Cloud Migration  
**Version**: 1.0  
**Date**: January 2025  
**Audience**: Implementation Teams, Migration Engineers, Project Managers  

---

## Overview

This implementation guide provides comprehensive step-by-step instructions for executing an enterprise cloud migration to AWS. The guide follows a proven methodology that minimizes risk, ensures data integrity, and maximizes business value throughout the migration process.

### Implementation Phases
1. **Phase 1**: Discovery and Assessment (Weeks 1-4)
2. **Phase 2**: Foundation and Preparation (Weeks 5-8)  
3. **Phase 3**: Migration Wave Execution (Weeks 9-20)
4. **Phase 4**: Optimization and Closure (Weeks 21-24)

### Key Principles
- **Risk Minimization**: Phased approach with comprehensive testing
- **Zero Data Loss**: Multiple validation and backup procedures
- **Business Continuity**: Minimal disruption to business operations
- **Automation First**: Leverage AWS native migration tools
- **Continuous Validation**: Testing and verification at every step

---

## Prerequisites Verification

Before beginning implementation, ensure all prerequisites from the prerequisites document are satisfied:

### Organizational Readiness
- [ ] Executive sponsorship confirmed and communicated
- [ ] Migration team assembled with defined roles
- [ ] Budget approved and allocated
- [ ] Timeline agreed upon by all stakeholders
- [ ] Change management process established

### Technical Prerequisites  
- [ ] AWS accounts configured with appropriate permissions
- [ ] Network connectivity planned (Direct Connect or VPN)
- [ ] Source environment inventory completed
- [ ] Application dependencies mapped
- [ ] Performance baselines established

### Security and Compliance
- [ ] Security framework approved
- [ ] Compliance requirements documented
- [ ] Encryption strategy defined
- [ ] Access control procedures established
- [ ] Audit trail requirements confirmed

---

## Phase 1: Discovery and Assessment

### Step 1.1: Environment Discovery

#### Deploy AWS Application Discovery Service

```bash
# Set up environment variables
export PROJECT_NAME="cloud-migration"
export AWS_REGION="us-east-1"
export DISCOVERY_REGION="us-east-1"

# Create IAM role for Discovery Service
cat > discovery-service-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "discovery:*",
        "application-autoscaling:*",
        "ec2:Describe*",
        "iam:ListRoles",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create IAM user for Discovery Service
aws iam create-user --user-name discovery-service-user
aws iam create-access-key --user-name discovery-service-user

# Attach policy to user
aws iam put-user-policy \
  --user-name discovery-service-user \
  --policy-name DiscoveryServicePolicy \
  --policy-document file://discovery-service-policy.json
```

#### Install Discovery Agents

**For Linux Servers:**
```bash
# Download the Discovery Agent
wget https://s3-us-west-2.amazonaws.com/aws-discovery-agent.us-west-2/linux/latest/aws-discovery-agent.tar.gz

# Extract and install
tar -xzf aws-discovery-agent.tar.gz
sudo bash install

# Configure the agent
sudo /opt/aws/discovery/bin/aws-discovery-agent-config \
  --region=${DISCOVERY_REGION} \
  --access-key-id=${ACCESS_KEY_ID} \
  --secret-access-key=${SECRET_ACCESS_KEY}

# Start the agent
sudo systemctl start aws-discovery-daemon
sudo systemctl enable aws-discovery-daemon

# Verify agent status
sudo systemctl status aws-discovery-daemon
```

**For Windows Servers:**
```powershell
# Download and install the Discovery Agent
$downloadUrl = "https://s3-us-west-2.amazonaws.com/aws-discovery-agent.us-west-2/windows/latest/AWSDiscoveryAgent.msi"
$installerPath = "$env:TEMP\AWSDiscoveryAgent.msi"

Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet" -Wait

# Configure the agent
& "C:\Program Files\Amazon\Discovery\bin\aws-discovery-agent-config.exe" `
  --region=$env:DISCOVERY_REGION `
  --access-key-id=$env:ACCESS_KEY_ID `
  --secret-access-key=$env:SECRET_ACCESS_KEY

# Start the service
Start-Service AWSDiscoveryAgent
Set-Service AWSDiscoveryAgent -StartupType Automatic
```

#### Configure Agentless Discovery (VMware)

```bash
# For VMware environments, deploy the Discovery Connector OVA
# Download the OVA from AWS Console
# Deploy to vCenter with the following specifications:
# - CPU: 4 vCPUs
# - Memory: 8 GB RAM  
# - Storage: 60 GB
# - Network: Management network with internet access

# Configure connector via web interface at https://[connector-ip]:9443
# Enter AWS credentials and vCenter connection details
```

### Step 1.2: Data Collection and Analysis

#### Monitor Discovery Progress

```bash
# Check discovery progress
aws discovery describe-configurations --region ${DISCOVERY_REGION}

# Get list of discovered servers
aws discovery describe-configurations \
  --region ${DISCOVERY_REGION} \
  --configuration-type Server \
  --query 'configurations[*].{ServerName:serverName,ServerType:serverType,OS:osName}'

# Export data for analysis
aws discovery start-export-task \
  --region ${DISCOVERY_REGION} \
  --export-data-format CSV

# Check export status
aws discovery describe-export-tasks --region ${DISCOVERY_REGION}
```

#### Analyze Discovery Data

```python
# Create migration assessment script
cat > migration_assessment.py << 'EOF'
#!/usr/bin/env python3
import boto3
import pandas as pd
import json
from datetime import datetime

class MigrationAssessment:
    def __init__(self, region='us-east-1'):
        self.discovery = boto3.client('discovery', region_name=region)
        self.servers = []
        self.applications = []
        
    def collect_server_data(self):
        """Collect server configuration data"""
        try:
            response = self.discovery.describe_configurations(
                configurationType='Server'
            )
            self.servers = response['configurations']
            print(f"Collected data for {len(self.servers)} servers")
        except Exception as e:
            print(f"Error collecting server data: {e}")
    
    def analyze_migration_patterns(self):
        """Analyze and recommend migration patterns for each server"""
        recommendations = []
        
        for server in self.servers:
            rec = {
                'server_name': server.get('serverName', 'Unknown'),
                'os_name': server.get('osName', 'Unknown'),
                'cpu_count': server.get('cpuType', 'Unknown'),
                'memory_mb': server.get('totalRamInMB', 0),
                'disk_size_gb': server.get('totalDiskSizeInGB', 0)
            }
            
            # Determine migration pattern based on characteristics
            rec['migration_pattern'] = self._determine_migration_pattern(server)
            rec['target_instance_type'] = self._recommend_instance_type(server)
            rec['estimated_effort'] = self._estimate_effort(rec['migration_pattern'])
            rec['priority'] = self._calculate_priority(server)
            
            recommendations.append(rec)
        
        return recommendations
    
    def _determine_migration_pattern(self, server):
        """Determine the best migration pattern for a server"""
        os_name = server.get('osName', '').lower()
        
        # Simple logic for pattern determination
        if 'windows' in os_name and 'server 2003' in os_name:
            return 'Replatform'  # Upgrade older OS
        elif 'linux' in os_name:
            return 'Rehost'  # Most Linux can be lifted and shifted
        elif 'windows' in os_name:
            return 'Rehost'  # Modern Windows can be rehosted
        else:
            return 'Assess'  # Needs manual assessment
    
    def _recommend_instance_type(self, server):
        """Recommend AWS instance type based on server specs"""
        memory_mb = server.get('totalRamInMB', 0)
        memory_gb = memory_mb / 1024 if memory_mb else 0
        
        if memory_gb <= 4:
            return 't3.medium'
        elif memory_gb <= 8:
            return 't3.large'
        elif memory_gb <= 16:
            return 'm5.xlarge'
        elif memory_gb <= 32:
            return 'm5.2xlarge'
        else:
            return 'm5.4xlarge'
    
    def _estimate_effort(self, pattern):
        """Estimate effort level for migration pattern"""
        effort_map = {
            'Rehost': 'Low',
            'Replatform': 'Medium',
            'Refactor': 'High',
            'Replace': 'Medium',
            'Retire': 'Low',
            'Retain': 'None'
        }
        return effort_map.get(pattern, 'Medium')
    
    def _calculate_priority(self, server):
        """Calculate migration priority"""
        # Simple priority based on OS age and criticality
        os_name = server.get('osName', '').lower()
        
        if '2003' in os_name or '2008' in os_name:
            return 'High'  # End of life OS
        elif 'production' in server.get('serverName', '').lower():
            return 'Medium'  # Production systems
        else:
            return 'Low'  # Development/test systems
    
    def generate_migration_waves(self, recommendations):
        """Generate migration waves based on dependencies and priorities"""
        waves = {
            'Wave 1 - Foundation': [],
            'Wave 2 - Supporting': [],
            'Wave 3 - Applications': [],
            'Wave 4 - Complex': []
        }
        
        for rec in recommendations:
            server_name = rec['server_name'].lower()
            
            if any(keyword in server_name for keyword in ['dns', 'ad', 'ldap', 'ntp']):
                waves['Wave 1 - Foundation'].append(rec)
            elif any(keyword in server_name for keyword in ['db', 'database', 'sql']):
                waves['Wave 2 - Supporting'].append(rec)
            elif rec['migration_pattern'] in ['Rehost', 'Replatform']:
                waves['Wave 3 - Applications'].append(rec)
            else:
                waves['Wave 4 - Complex'].append(rec)
        
        return waves
    
    def calculate_tco_analysis(self, recommendations):
        """Calculate Total Cost of Ownership analysis"""
        # Simplified TCO calculation
        total_current_cost = 0
        total_aws_cost = 0
        
        for rec in recommendations:
            # Estimated current monthly cost per server
            current_monthly = 500  # Base estimate
            
            # AWS monthly cost based on instance type
            aws_cost_map = {
                't3.medium': 50,
                't3.large': 100,
                'm5.xlarge': 200,
                'm5.2xlarge': 400,
                'm5.4xlarge': 800
            }
            
            aws_monthly = aws_cost_map.get(rec['target_instance_type'], 200)
            
            total_current_cost += current_monthly
            total_aws_cost += aws_monthly
        
        savings = total_current_cost - total_aws_cost
        savings_percent = (savings / total_current_cost) * 100 if total_current_cost > 0 else 0
        
        return {
            'current_monthly_cost': total_current_cost,
            'aws_monthly_cost': total_aws_cost,
            'monthly_savings': savings,
            'savings_percentage': savings_percent,
            'annual_savings': savings * 12
        }
    
    def generate_report(self):
        """Generate comprehensive migration assessment report"""
        self.collect_server_data()
        recommendations = self.analyze_migration_patterns()
        waves = self.generate_migration_waves(recommendations)
        tco = self.calculate_tco_analysis(recommendations)
        
        report = {
            'assessment_date': datetime.now().isoformat(),
            'total_servers': len(self.servers),
            'recommendations': recommendations,
            'migration_waves': waves,
            'tco_analysis': tco
        }
        
        # Save to files
        with open('migration_assessment_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        # Create CSV for easy analysis
        df = pd.DataFrame(recommendations)
        df.to_csv('server_recommendations.csv', index=False)
        
        return report

if __name__ == "__main__":
    assessment = MigrationAssessment()
    report = assessment.generate_report()
    print(f"Assessment complete. Found {report['total_servers']} servers.")
    print(f"Potential annual savings: ${report['tco_analysis']['annual_savings']:,.2f}")
EOF

# Run the assessment
python3 migration_assessment.py
```

### Step 1.3: Application Portfolio Analysis

#### Analyze Application Dependencies

```bash
# Create application dependency mapping script
cat > dependency_mapper.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
import networkx as nx
import matplotlib.pyplot as plt

class DependencyMapper:
    def __init__(self, region='us-east-1'):
        self.discovery = boto3.client('discovery', region_name=region)
        self.graph = nx.DiGraph()
    
    def map_network_connections(self):
        """Map network connections between servers"""
        try:
            # Get network connections
            response = self.discovery.list_configurations(
                configurationType='Connection'
            )
            
            connections = response.get('configurations', [])
            
            for conn in connections:
                source = conn.get('sourceServerId')
                dest = conn.get('destinationServerId')
                port = conn.get('destinationPort')
                
                if source and dest:
                    self.graph.add_edge(source, dest, port=port)
            
            print(f"Mapped {len(connections)} network connections")
            
        except Exception as e:
            print(f"Error mapping connections: {e}")
    
    def identify_application_groups(self):
        """Identify application groups based on connectivity"""
        # Find strongly connected components
        components = list(nx.strongly_connected_components(self.graph))
        
        application_groups = []
        for i, component in enumerate(components):
            if len(component) > 1:  # Only groups with multiple servers
                group = {
                    'group_id': f"AppGroup_{i+1}",
                    'servers': list(component),
                    'server_count': len(component),
                    'migration_complexity': 'High' if len(component) > 5 else 'Medium'
                }
                application_groups.append(group)
        
        return application_groups
    
    def analyze_critical_dependencies(self):
        """Identify critical dependencies that affect migration order"""
        critical_deps = []
        
        # Find nodes with high in-degree (many dependencies)
        in_degrees = dict(self.graph.in_degree())
        
        for node, degree in in_degrees.items():
            if degree > 3:  # Threshold for critical dependency
                critical_deps.append({
                    'server_id': node,
                    'dependency_count': degree,
                    'migration_priority': 'Early' if degree > 5 else 'Medium'
                })
        
        return sorted(critical_deps, key=lambda x: x['dependency_count'], reverse=True)
    
    def generate_dependency_report(self):
        """Generate comprehensive dependency analysis report"""
        self.map_network_connections()
        
        app_groups = self.identify_application_groups()
        critical_deps = self.analyze_critical_dependencies()
        
        report = {
            'total_connections': self.graph.number_of_edges(),
            'total_servers': self.graph.number_of_nodes(),
            'application_groups': app_groups,
            'critical_dependencies': critical_deps,
            'migration_recommendations': self._generate_migration_recommendations(app_groups, critical_deps)
        }
        
        # Save report
        with open('dependency_analysis_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        return report
    
    def _generate_migration_recommendations(self, app_groups, critical_deps):
        """Generate migration order recommendations"""
        recommendations = []
        
        # Servers with no dependencies should migrate first
        independent_servers = [node for node in self.graph.nodes() 
                             if self.graph.in_degree(node) == 0]
        
        if independent_servers:
            recommendations.append({
                'wave': 'Wave 1',
                'description': 'Independent servers with no dependencies',
                'servers': independent_servers
            })
        
        # Application groups should migrate together
        for group in app_groups:
            recommendations.append({
                'wave': f"Wave {len(recommendations) + 1}",
                'description': f"Application group with {group['server_count']} servers",
                'servers': group['servers'],
                'complexity': group['migration_complexity']
            })
        
        return recommendations

if __name__ == "__main__":
    mapper = DependencyMapper()
    report = mapper.generate_dependency_report()
    print(f"Dependency analysis complete. Found {len(report['application_groups'])} application groups.")
EOF

# Run dependency analysis
python3 dependency_mapper.py
```

---

## Phase 2: Foundation and Preparation

### Step 2.1: AWS Landing Zone Setup

#### Deploy AWS Control Tower

```bash
# Set up Control Tower via AWS Console or CLI
# Note: Control Tower setup requires manual configuration through console

# Verify Control Tower setup
aws organizations describe-organization
aws controltower list-enabled-baselines

# Get account IDs for different environments
MANAGEMENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "Management Account: ${MANAGEMENT_ACCOUNT}"
```

#### Create Migration-Specific Accounts

```bash
# Create migration execution account
aws organizations create-account \
  --email migration-execution@company.com \
  --account-name "Migration Execution Account"

# Create staging account  
aws organizations create-account \
  --email migration-staging@company.com \
  --account-name "Migration Staging Account"

# Get account IDs
MIGRATION_ACCOUNT=$(aws organizations list-accounts \
  --query 'Accounts[?Name==`Migration Execution Account`].Id' \
  --output text)

STAGING_ACCOUNT=$(aws organizations list-accounts \
  --query 'Accounts[?Name==`Migration Staging Account`].Id' \
  --output text)

echo "Migration Account: ${MIGRATION_ACCOUNT}"
echo "Staging Account: ${STAGING_ACCOUNT}"
```

### Step 2.2: Network Infrastructure Setup

#### Deploy VPC and Networking

```bash
# Create VPC for migration workloads
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

# Tag VPC
aws ec2 create-tags \
  --resources ${VPC_ID} \
  --tags Key=Name,Value=${PROJECT_NAME}-migration-vpc Key=Project,Value=${PROJECT_NAME}

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
  --vpc-id ${VPC_ID} \
  --enable-dns-hostnames

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --vpc-id ${VPC_ID} \
  --internet-gateway-id ${IGW_ID}

# Create subnets across multiple AZs
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${AWS_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${AWS_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.10.0/24 \
  --availability-zone ${AWS_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.11.0/24 \
  --availability-zone ${AWS_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

MIGRATION_SUBNET_1=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.20.0/24 \
  --availability-zone ${AWS_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

MIGRATION_SUBNET_2=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.0.21.0/24 \
  --availability-zone ${AWS_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

# Tag all subnets
aws ec2 create-tags --resources ${PUBLIC_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-public-1a
aws ec2 create-tags --resources ${PUBLIC_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-public-1b
aws ec2 create-tags --resources ${PRIVATE_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-private-1a
aws ec2 create-tags --resources ${PRIVATE_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-private-1b
aws ec2 create-tags --resources ${MIGRATION_SUBNET_1} --tags Key=Name,Value=${PROJECT_NAME}-migration-1a
aws ec2 create-tags --resources ${MIGRATION_SUBNET_2} --tags Key=Name,Value=${PROJECT_NAME}-migration-1b
```

#### Configure NAT Gateways and Routing

```bash
# Allocate Elastic IPs for NAT Gateways
EIP_1=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

EIP_2=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

# Create NAT Gateways
NAT_GW_1=$(aws ec2 create-nat-gateway \
  --subnet-id ${PUBLIC_SUBNET_1} \
  --allocation-id ${EIP_1} \
  --query 'NatGateway.NatGatewayId' \
  --output text)

NAT_GW_2=$(aws ec2 create-nat-gateway \
  --subnet-id ${PUBLIC_SUBNET_2} \
  --allocation-id ${EIP_2} \
  --query 'NatGateway.NatGatewayId' \
  --output text)

# Wait for NAT Gateways to be available
aws ec2 wait nat-gateway-available --nat-gateway-ids ${NAT_GW_1} ${NAT_GW_2}

# Create route tables
PUBLIC_RT=$(aws ec2 create-route-table \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

PRIVATE_RT_1=$(aws ec2 create-route-table \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

PRIVATE_RT_2=$(aws ec2 create-route-table \
  --vpc-id ${VPC_ID} \
  --query 'RouteTable.RouteTableId' \
  --output text)

# Configure routes
aws ec2 create-route --route-table-id ${PUBLIC_RT} --destination-cidr-block 0.0.0.0/0 --gateway-id ${IGW_ID}
aws ec2 create-route --route-table-id ${PRIVATE_RT_1} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${NAT_GW_1}
aws ec2 create-route --route-table-id ${PRIVATE_RT_2} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${NAT_GW_2}

# Associate subnets with route tables
aws ec2 associate-route-table --subnet-id ${PUBLIC_SUBNET_1} --route-table-id ${PUBLIC_RT}
aws ec2 associate-route-table --subnet-id ${PUBLIC_SUBNET_2} --route-table-id ${PUBLIC_RT}
aws ec2 associate-route-table --subnet-id ${PRIVATE_SUBNET_1} --route-table-id ${PRIVATE_RT_1}
aws ec2 associate-route-table --subnet-id ${PRIVATE_SUBNET_2} --route-table-id ${PRIVATE_RT_2}
aws ec2 associate-route-table --subnet-id ${MIGRATION_SUBNET_1} --route-table-id ${PRIVATE_RT_1}
aws ec2 associate-route-table --subnet-id ${MIGRATION_SUBNET_2} --route-table-id ${PRIVATE_RT_2}
```

### Step 2.3: Security Infrastructure

#### Create Security Groups

```bash
# Create migration security groups
MGN_SG=$(aws ec2 create-security-group \
  --group-name ${PROJECT_NAME}-mgn-sg \
  --description "Security group for MGN replication" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

DMS_SG=$(aws ec2 create-security-group \
  --group-name ${PROJECT_NAME}-dms-sg \
  --description "Security group for DMS replication" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

MIGRATED_APPS_SG=$(aws ec2 create-security-group \
  --group-name ${PROJECT_NAME}-migrated-apps-sg \
  --description "Security group for migrated applications" \
  --vpc-id ${VPC_ID} \
  --query 'GroupId' \
  --output text)

# Configure MGN security group rules
aws ec2 authorize-security-group-ingress \
  --group-id ${MGN_SG} \
  --protocol tcp \
  --port 1500 \
  --cidr 0.0.0.0/0  # MGN replication traffic

aws ec2 authorize-security-group-ingress \
  --group-id ${MGN_SG} \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0  # HTTPS for API calls

# Configure DMS security group rules
aws ec2 authorize-security-group-ingress \
  --group-id ${DMS_SG} \
  --protocol tcp \
  --port 3306 \
  --cidr 10.0.0.0/8  # MySQL

aws ec2 authorize-security-group-ingress \
  --group-id ${DMS_SG} \
  --protocol tcp \
  --port 5432 \
  --cidr 10.0.0.0/8  # PostgreSQL

aws ec2 authorize-security-group-ingress \
  --group-id ${DMS_SG} \
  --protocol tcp \
  --port 1433 \
  --cidr 10.0.0.0/8  # SQL Server

# Configure application security group rules
aws ec2 authorize-security-group-ingress \
  --group-id ${MIGRATED_APPS_SG} \
  --protocol tcp \
  --port 80 \
  --cidr 10.0.0.0/16

aws ec2 authorize-security-group-ingress \
  --group-id ${MIGRATED_APPS_SG} \
  --protocol tcp \
  --port 443 \
  --cidr 10.0.0.0/16

aws ec2 authorize-security-group-ingress \
  --group-id ${MIGRATED_APPS_SG} \
  --protocol tcp \
  --port 22 \
  --cidr 10.0.0.0/16  # SSH

aws ec2 authorize-security-group-ingress \
  --group-id ${MIGRATED_APPS_SG} \
  --protocol tcp \
  --port 3389 \
  --cidr 10.0.0.0/16  # RDP
```

#### Set Up KMS Encryption

```bash
# Create customer-managed KMS keys
MIGRATION_KEY_ID=$(aws kms create-key \
  --description "Migration encryption key" \
  --query 'KeyMetadata.KeyId' \
  --output text)

# Create alias
aws kms create-alias \
  --alias-name alias/${PROJECT_NAME}-migration \
  --target-key-id ${MIGRATION_KEY_ID}

# Create key policy for migration services
cat > migration-key-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${MANAGEMENT_ACCOUNT}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key for migration services",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "mgn.amazonaws.com",
          "dms.amazonaws.com",
          "sms.amazonaws.com"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Apply key policy
aws kms put-key-policy \
  --key-id ${MIGRATION_KEY_ID} \
  --policy-name default \
  --policy file://migration-key-policy.json
```

### Step 2.4: Migration Services Setup

#### Initialize AWS Application Migration Service (MGN)

```bash
# Initialize MGN service
aws mgn initialize-service --region ${AWS_REGION}

# Create replication configuration template
aws mgn create-replication-configuration-template \
  --region ${AWS_REGION} \
  --associate-default-security-group false \
  --bandwidth-throttling 50 \
  --create-public-ip false \
  --data-plane-routing PRIVATE_IP \
  --default-large-staging-disk-type GP3 \
  --ebs-encryption ENCRYPTED \
  --ebs-encryption-key-arn arn:aws:kms:${AWS_REGION}:${MANAGEMENT_ACCOUNT}:alias/${PROJECT_NAME}-migration \
  --replication-server-instance-type m5.large \
  --replication-servers-security-groups-i-ds ${MGN_SG} \
  --staging-area-subnet-id ${MIGRATION_SUBNET_1} \
  --staging-area-tags Key=Project,Value=${PROJECT_NAME} \
  --use-dedicated-replication-server false

# Create launch template for converted instances
cat > mgn-launch-template.json << EOF
{
  "copyPrivateIp": false,
  "copyTags": true,
  "launchDisposition": "STARTED",
  "licensing": {
    "osByol": false
  },
  "targetInstanceTypeRightSizingMethod": "BASIC",
  "postLaunchActions": {
    "deployment": "TEST_AND_CUTOVER",
    "s3LogBucket": "${PROJECT_NAME}-mgn-logs-${MANAGEMENT_ACCOUNT}",
    "s3OutputKeyPrefix": "migration-logs/",
    "cloudWatchLogGroupName": "/aws/mgn/postlaunch",
    "ssmDocuments": [
      {
        "actionName": "InstallCloudWatchAgent",
        "ssmDocumentName": "AmazonCloudWatch-ManageAgent",
        "timeoutSeconds": 3600,
        "parameters": {
          "action": "configure",
          "mode": "ec2",
          "optionalConfigurationSource": "ssm",
          "optionalConfigurationLocation": "cloudwatch-config"
        }
      }
    ]
  }
}
EOF
```

#### Set Up AWS Database Migration Service (DMS)

```bash
# Create DMS subnet group
aws dms create-replication-subnet-group \
  --replication-subnet-group-identifier ${PROJECT_NAME}-dms-subnet-group \
  --replication-subnet-group-description "DMS subnet group for migration" \
  --subnet-ids ${MIGRATION_SUBNET_1} ${MIGRATION_SUBNET_2}

# Create DMS replication instance
aws dms create-replication-instance \
  --replication-instance-identifier ${PROJECT_NAME}-dms-instance \
  --replication-instance-class dms.t3.medium \
  --allocated-storage 100 \
  --replication-subnet-group-identifier ${PROJECT_NAME}-dms-subnet-group \
  --vpc-security-group-ids ${DMS_SG} \
  --multi-az false \
  --publicly-accessible false \
  --storage-encrypted \
  --kms-key-id alias/${PROJECT_NAME}-migration

# Wait for replication instance to be available
aws dms wait replication-instance-available \
  --filters Name=replication-instance-id,Values=${PROJECT_NAME}-dms-instance
```

#### Configure AWS Server Migration Service (SMS)

```bash
# Create IAM role for SMS
cat > sms-service-role-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name ${PROJECT_NAME}-sms-service-role \
  --assume-role-policy-document file://sms-service-role-policy.json

# Attach SMS service policy
aws iam attach-role-policy \
  --role-name ${PROJECT_NAME}-sms-service-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/SMSServiceRole

# Create S3 bucket for SMS artifacts
aws s3 mb s3://${PROJECT_NAME}-sms-artifacts-${MANAGEMENT_ACCOUNT}-${AWS_REGION}

# Configure bucket encryption
aws s3api put-bucket-encryption \
  --bucket ${PROJECT_NAME}-sms-artifacts-${MANAGEMENT_ACCOUNT}-${AWS_REGION} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "aws:kms",
          "KMSMasterKeyID": "alias/'${PROJECT_NAME}'-migration"
        }
      }
    ]
  }'
```

---

## Phase 3: Migration Wave Execution

### Step 3.1: Wave 1 - Foundation Services Migration

#### Migrate DNS and Directory Services

```bash
# Example: Migrate Windows Active Directory
# First, set up AWS Managed Microsoft AD or AD Connector

# Create AWS Managed Microsoft AD
aws ds create-microsoft-ad \
  --name corp.company.com \
  --password ${AD_PASSWORD} \
  --description "Managed AD for migration" \
  --vpc-settings VpcId=${VPC_ID},SubnetIds=${PRIVATE_SUBNET_1},${PRIVATE_SUBNET_2} \
  --edition Standard

# Configure DNS forwarding to on-premise
aws route53resolver create-resolver-rule \
  --creator-request-id $(date +%s) \
  --domain-name corp.company.com \
  --rule-type FORWARD \
  --resolver-endpoint-id ${RESOLVER_ENDPOINT_ID} \
  --target-ips Ip=10.0.0.100,Port=53 Ip=10.0.0.101,Port=53

# Install MGN agents on domain controllers
# (This would typically be done manually on each DC)
```

#### Set Up Monitoring Infrastructure

```bash
# Create CloudWatch Log Groups
aws logs create-log-group --log-group-name /aws/migration/mgn
aws logs create-log-group --log-group-name /aws/migration/dms  
aws logs create-log-group --log-group-name /aws/migration/applications

# Create SNS topic for migration alerts
MIGRATION_SNS_TOPIC=$(aws sns create-topic \
  --name ${PROJECT_NAME}-migration-alerts \
  --query 'TopicArn' \
  --output text)

# Subscribe email to alerts
aws sns subscribe \
  --topic-arn ${MIGRATION_SNS_TOPIC} \
  --protocol email \
  --notification-endpoint migration-team@company.com

# Create CloudWatch alarms for MGN
aws cloudwatch put-metric-alarm \
  --alarm-name "MGN-ReplicationLag" \
  --alarm-description "MGN replication lag too high" \
  --metric-name "ReplicationLag" \
  --namespace "AWS/MGN" \
  --statistic Average \
  --period 300 \
  --threshold 3600 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions ${MIGRATION_SNS_TOPIC}
```

### Step 3.2: Application Server Migration Process

#### Install and Configure MGN Agents

```bash
# Create agent installation script for Linux servers
cat > install_mgn_agent_linux.sh << 'EOF'
#!/bin/bash

# Download MGN agent
wget -O ./aws-replication-installer-init.py https://aws-application-migration-service-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/linux/aws-replication-installer-init.py

# Install agent with authentication
sudo python3 aws-replication-installer-init.py \
  --region ${AWS_REGION} \
  --aws-access-key-id ${AWS_ACCESS_KEY_ID} \
  --aws-secret-access-key ${AWS_SECRET_ACCESS_KEY} \
  --no-prompt

# Verify agent status
sudo systemctl status aws-replication-agent
EOF

# Create agent installation script for Windows servers
cat > install_mgn_agent_windows.ps1 << 'EOF'
# Download MGN agent
$downloadUrl = "https://aws-application-migration-service-${env:AWS_REGION}.s3.${env:AWS_REGION}.amazonaws.com/latest/windows/AwsReplicationWindowsInstaller.exe"
$installerPath = "$env:TEMP\AwsReplicationWindowsInstaller.exe"

Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Install agent
& $installerPath /S /region=${env:AWS_REGION} /aws_access_key_id=${env:AWS_ACCESS_KEY_ID} /aws_secret_access_key=${env:AWS_SECRET_ACCESS_KEY}

# Check service status
Get-Service -Name "AWS Replication Agent"
EOF

chmod +x install_mgn_agent_linux.sh
```

#### Monitor Replication Progress

```python
# Create replication monitoring script
cat > monitor_replication.py << 'EOF'
#!/usr/bin/env python3
import boto3
import time
import json
from datetime import datetime

class MGNMonitor:
    def __init__(self, region='us-east-1'):
        self.mgn = boto3.client('mgn', region_name=region)
        
    def get_source_servers(self):
        """Get all source servers"""
        try:
            response = self.mgn.describe_source_servers()
            return response['items']
        except Exception as e:
            print(f"Error getting source servers: {e}")
            return []
    
    def monitor_replication_status(self):
        """Monitor replication status for all servers"""
        servers = self.get_source_servers()
        
        status_summary = {
            'total_servers': len(servers),
            'replication_status': {},
            'servers_ready_for_testing': [],
            'servers_with_issues': []
        }
        
        for server in servers:
            server_id = server['sourceServerID']
            hostname = server.get('sourceProperties', {}).get('identificationHints', {}).get('hostname', 'Unknown')
            
            # Get replication status
            data_replication = server.get('dataReplicationInfo', {})
            replication_state = data_replication.get('dataReplicationState', 'Unknown')
            
            # Track status counts
            if replication_state in status_summary['replication_status']:
                status_summary['replication_status'][replication_state] += 1
            else:
                status_summary['replication_status'][replication_state] = 1
            
            # Check if ready for testing
            if replication_state == 'CONTINUOUS_REPLICATION':
                status_summary['servers_ready_for_testing'].append({
                    'server_id': server_id,
                    'hostname': hostname
                })
            elif replication_state in ['FAILED_TO_START_REPLICATION', 'FAILED_TO_CREATE_STAGING_DISKS']:
                status_summary['servers_with_issues'].append({
                    'server_id': server_id,
                    'hostname': hostname,
                    'status': replication_state
                })
            
            print(f"Server: {hostname} ({server_id}) - Status: {replication_state}")
            
            # Show replication lag if available
            if 'lag' in data_replication:
                lag_duration = data_replication['lag']['duration']
                print(f"  Replication lag: {lag_duration}")
        
        return status_summary
    
    def start_test_instances(self, server_ids):
        """Start test instances for specified servers"""
        for server_id in server_ids:
            try:
                response = self.mgn.start_test(sourceServerIDs=[server_id])
                job_id = response['job']['jobID']
                print(f"Started test for server {server_id}, Job ID: {job_id}")
            except Exception as e:
                print(f"Error starting test for server {server_id}: {e}")
    
    def monitor_test_jobs(self):
        """Monitor test job progress"""
        try:
            response = self.mgn.describe_jobs()
            jobs = response['items']
            
            for job in jobs:
                if job['type'] == 'LAUNCH':
                    job_id = job['jobID']
                    status = job['status']
                    print(f"Test Job {job_id}: {status}")
                    
                    if status == 'COMPLETED':
                        # Get launched instances
                        for server in job.get('participatingServers', []):
                            launched_instance = server.get('launchedInstance')
                            if launched_instance:
                                instance_id = launched_instance.get('ec2InstanceID')
                                print(f"  Launched instance: {instance_id}")
        except Exception as e:
            print(f"Error monitoring test jobs: {e}")
    
    def generate_migration_report(self):
        """Generate comprehensive migration status report"""
        status = self.monitor_replication_status()
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': status,
            'recommendations': self._generate_recommendations(status)
        }
        
        # Save report
        with open(f'migration_status_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        return report
    
    def _generate_recommendations(self, status):
        """Generate recommendations based on current status"""
        recommendations = []
        
        ready_count = len(status['servers_ready_for_testing'])
        if ready_count > 0:
            recommendations.append(f"Ready to start testing {ready_count} servers")
        
        issue_count = len(status['servers_with_issues'])
        if issue_count > 0:
            recommendations.append(f"Address issues with {issue_count} servers before proceeding")
        
        # Calculate overall progress
        total_servers = status['total_servers']
        completed = status['replication_status'].get('CONTINUOUS_REPLICATION', 0)
        progress = (completed / total_servers * 100) if total_servers > 0 else 0
        
        recommendations.append(f"Overall replication progress: {progress:.1f}%")
        
        return recommendations

if __name__ == "__main__":
    monitor = MGNMonitor()
    
    print("=== MGN Replication Status ===")
    report = monitor.generate_migration_report()
    
    print("\nRecommendations:")
    for rec in report['recommendations']:
        print(f"- {rec}")
EOF

# Run monitoring
python3 monitor_replication.py
```

### Step 3.3: Database Migration Process

#### Set Up Database Migration Tasks

```python
# Create database migration automation script
cat > database_migration.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
import time
from datetime import datetime

class DatabaseMigration:
    def __init__(self, region='us-east-1'):
        self.dms = boto3.client('dms', region_name=region)
        self.replication_instance_arn = None
        
    def create_source_endpoint(self, endpoint_id, engine, server_name, port, username, password, database_name=None):
        """Create source database endpoint"""
        endpoint_config = {
            'EndpointIdentifier': endpoint_id,
            'EndpointType': 'source',
            'EngineName': engine,
            'ServerName': server_name,
            'Port': port,
            'Username': username,
            'Password': password
        }
        
        if database_name:
            endpoint_config['DatabaseName'] = database_name
        
        try:
            response = self.dms.create_endpoint(**endpoint_config)
            print(f"Created source endpoint: {endpoint_id}")
            return response['Endpoint']['EndpointArn']
        except Exception as e:
            print(f"Error creating source endpoint: {e}")
            return None
    
    def create_target_endpoint(self, endpoint_id, engine, server_name, port, username, password, database_name=None):
        """Create target database endpoint"""
        endpoint_config = {
            'EndpointIdentifier': endpoint_id,
            'EndpointType': 'target',
            'EngineName': engine,
            'ServerName': server_name,
            'Port': port,
            'Username': username,
            'Password': password
        }
        
        if database_name:
            endpoint_config['DatabaseName'] = database_name
        
        # Add target-specific settings
        if engine == 'aurora-mysql':
            endpoint_config['MySQLSettings'] = {
                'ServerTimezone': 'UTC',
                'MaxFileSize': 32
            }
        elif engine == 'aurora-postgresql':
            endpoint_config['PostgreSQLSettings'] = {
                'DatabaseName': database_name or 'postgres'
            }
        
        try:
            response = self.dms.create_endpoint(**endpoint_config)
            print(f"Created target endpoint: {endpoint_id}")
            return response['Endpoint']['EndpointArn']
        except Exception as e:
            print(f"Error creating target endpoint: {e}")
            return None
    
    def test_connection(self, endpoint_arn, replication_instance_arn):
        """Test database connection"""
        try:
            response = self.dms.test_connection(
                ReplicationInstanceArn=replication_instance_arn,
                EndpointArn=endpoint_arn
            )
            
            # Wait for test to complete
            connection_arn = response['Connection']['ReplicationInstanceArn']
            
            while True:
                status_response = self.dms.describe_connections(
                    Filters=[
                        {
                            'Name': 'endpoint-arn',
                            'Values': [endpoint_arn]
                        },
                        {
                            'Name': 'replication-instance-arn', 
                            'Values': [replication_instance_arn]
                        }
                    ]
                )
                
                if status_response['Connections']:
                    status = status_response['Connections'][0]['Status']
                    if status == 'successful':
                        print(f"Connection test successful for {endpoint_arn}")
                        return True
                    elif status == 'failed':
                        print(f"Connection test failed for {endpoint_arn}")
                        return False
                
                time.sleep(10)
                
        except Exception as e:
            print(f"Error testing connection: {e}")
            return False
    
    def create_migration_task(self, task_id, source_arn, target_arn, replication_instance_arn, migration_type='full-load'):
        """Create database migration task"""
        
        # Define table mappings
        table_mappings = {
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "%",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }
        
        task_settings = {
            "TargetMetadata": {
                "TargetSchema": "",
                "SupportLobs": True,
                "FullLobMode": False,
                "LobChunkSize": 0,
                "LimitedSizeLobMode": True,
                "LobMaxSize": 32,
                "InlineLobMaxSize": 0,
                "LoadMaxFileSize": 0,
                "ParallelLoadThreads": 0,
                "ParallelLoadBufferSize": 0,
                "BatchApplyEnabled": False,
                "TaskRecoveryTableEnabled": False
            },
            "FullLoadSettings": {
                "TargetTablePrepMode": "DROP_AND_CREATE",
                "CreatePkAfterFullLoad": False,
                "StopTaskCachedChangesApplied": False,
                "StopTaskCachedChangesNotApplied": False,
                "MaxFullLoadSubTasks": 8,
                "TransactionConsistencyTimeout": 600,
                "CommitRate": 10000
            },
            "Logging": {
                "EnableLogging": True,
                "LogComponents": [
                    {
                        "Id": "TRANSFORMATION",
                        "Severity": "LOGGER_SEVERITY_DEFAULT"
                    },
                    {
                        "Id": "SOURCE_UNLOAD",
                        "Severity": "LOGGER_SEVERITY_DEFAULT"  
                    },
                    {
                        "Id": "TARGET_LOAD",
                        "Severity": "LOGGER_SEVERITY_DEFAULT"
                    }
                ]
            }
        }
        
        try:
            response = self.dms.create_replication_task(
                ReplicationTaskIdentifier=task_id,
                SourceEndpointArn=source_arn,
                TargetEndpointArn=target_arn,
                ReplicationInstanceArn=replication_instance_arn,
                MigrationType=migration_type,
                TableMappings=json.dumps(table_mappings),
                ReplicationTaskSettings=json.dumps(task_settings)
            )
            
            print(f"Created migration task: {task_id}")
            return response['ReplicationTask']['ReplicationTaskArn']
            
        except Exception as e:
            print(f"Error creating migration task: {e}")
            return None
    
    def start_migration_task(self, task_arn):
        """Start migration task"""
        try:
            response = self.dms.start_replication_task(
                ReplicationTaskArn=task_arn,
                StartReplicationTaskType='start-replication'
            )
            print(f"Started migration task: {task_arn}")
            return True
        except Exception as e:
            print(f"Error starting migration task: {e}")
            return False
    
    def monitor_migration_task(self, task_arn):
        """Monitor migration task progress"""
        while True:
            try:
                response = self.dms.describe_replication_tasks(
                    Filters=[
                        {
                            'Name': 'replication-task-arn',
                            'Values': [task_arn]
                        }
                    ]
                )
                
                if response['ReplicationTasks']:
                    task = response['ReplicationTasks'][0]
                    status = task['Status']
                    
                    print(f"Task status: {status}")
                    
                    if 'ReplicationTaskStats' in task:
                        stats = task['ReplicationTaskStats']
                        print(f"  Full load progress: {stats.get('FullLoadProgressPercent', 0)}%")
                        print(f"  Tables loaded: {stats.get('TablesLoaded', 0)}")
                        print(f"  Tables loading: {stats.get('TablesLoading', 0)}")
                        print(f"  Tables errored: {stats.get('TablesErrored', 0)}")
                    
                    if status in ['stopped', 'failed', 'ready']:
                        if status == 'ready':
                            print("Migration task completed successfully")
                        else:
                            print(f"Migration task ended with status: {status}")
                        break
                
                time.sleep(30)
                
            except Exception as e:
                print(f"Error monitoring task: {e}")
                break
    
    def migrate_database(self, source_config, target_config, migration_type='full-load'):
        """Complete database migration process"""
        print(f"Starting database migration from {source_config['engine']} to {target_config['engine']}")
        
        # Create endpoints
        source_arn = self.create_source_endpoint(
            f"source-{source_config['name']}", 
            source_config['engine'],
            source_config['host'],
            source_config['port'],
            source_config['username'],
            source_config['password'],
            source_config.get('database')
        )
        
        target_arn = self.create_target_endpoint(
            f"target-{target_config['name']}",
            target_config['engine'], 
            target_config['host'],
            target_config['port'],
            target_config['username'],
            target_config['password'],
            target_config.get('database')
        )
        
        if not source_arn or not target_arn:
            print("Failed to create endpoints")
            return False
        
        # Get replication instance ARN
        replication_instances = self.dms.describe_replication_instances()
        if not replication_instances['ReplicationInstances']:
            print("No replication instance found")
            return False
        
        replication_instance_arn = replication_instances['ReplicationInstances'][0]['ReplicationInstanceArn']
        
        # Test connections
        if not self.test_connection(source_arn, replication_instance_arn):
            print("Source connection test failed")
            return False
            
        if not self.test_connection(target_arn, replication_instance_arn):
            print("Target connection test failed") 
            return False
        
        # Create and start migration task
        task_arn = self.create_migration_task(
            f"migration-{source_config['name']}-to-{target_config['name']}",
            source_arn,
            target_arn,
            replication_instance_arn,
            migration_type
        )
        
        if not task_arn:
            print("Failed to create migration task")
            return False
        
        if not self.start_migration_task(task_arn):
            print("Failed to start migration task")
            return False
        
        # Monitor progress
        self.monitor_migration_task(task_arn)
        
        return True

# Example usage
if __name__ == "__main__":
    migrator = DatabaseMigration()
    
    # Example migration configuration
    source_db = {
        'name': 'legacy-mysql',
        'engine': 'mysql',
        'host': 'legacy-db.company.local',
        'port': 3306,
        'username': 'migration_user',
        'password': 'secure_password',
        'database': 'production_db'
    }
    
    target_db = {
        'name': 'aurora-mysql',
        'engine': 'aurora-mysql',
        'host': 'aurora-cluster.cluster-xyz.us-east-1.rds.amazonaws.com',
        'port': 3306,
        'username': 'admin',
        'password': 'secure_password',
        'database': 'production_db'
    }
    
    # Start migration
    success = migrator.migrate_database(source_db, target_db, 'full-load-and-cdc')
    
    if success:
        print("Database migration completed successfully")
    else:
        print("Database migration failed")
EOF
```

### Step 3.4: Testing and Validation

#### Create Automated Testing Framework

```bash
# Create comprehensive testing script
cat > migration_testing.py << 'EOF'
#!/usr/bin/env python3
import boto3
import subprocess
import requests
import time
import json
import mysql.connector
from datetime import datetime

class MigrationTesting:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.rds = boto3.client('rds', region_name=region)
        self.mgn = boto3.client('mgn', region_name=region)
        self.test_results = []
        
    def test_server_connectivity(self, instance_id):
        """Test basic connectivity to migrated server"""
        try:
            # Get instance details
            response = self.ec2.describe_instances(InstanceIds=[instance_id])
            instance = response['Reservations'][0]['Instances'][0]
            
            private_ip = instance['PrivateIpAddress']
            state = instance['State']['Name']
            
            result = {
                'test_type': 'connectivity',
                'instance_id': instance_id,
                'private_ip': private_ip,
                'state': state,
                'timestamp': datetime.now().isoformat()
            }
            
            if state == 'running':
                # Test basic network connectivity
                ping_result = subprocess.run(['ping', '-c', '3', private_ip], 
                                           capture_output=True, text=True)
                result['ping_success'] = ping_result.returncode == 0
                result['ping_output'] = ping_result.stdout
            else:
                result['ping_success'] = False
                result['error'] = f"Instance not running: {state}"
            
            self.test_results.append(result)
            return result['ping_success']
            
        except Exception as e:
            result = {
                'test_type': 'connectivity',
                'instance_id': instance_id,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.test_results.append(result)
            return False
    
    def test_application_health(self, instance_id, health_endpoint='/health', port=80):
        """Test application health endpoint"""
        try:
            # Get instance private IP
            response = self.ec2.describe_instances(InstanceIds=[instance_id])
            instance = response['Reservations'][0]['Instances'][0]
            private_ip = instance['PrivateIpAddress']
            
            # Test health endpoint
            url = f"http://{private_ip}:{port}{health_endpoint}"
            
            result = {
                'test_type': 'application_health',
                'instance_id': instance_id,
                'url': url,
                'timestamp': datetime.now().isoformat()
            }
            
            response = requests.get(url, timeout=10)
            result['status_code'] = response.status_code
            result['response_time'] = response.elapsed.total_seconds()
            result['success'] = response.status_code == 200
            
            if response.status_code == 200:
                try:
                    result['response_body'] = response.json()
                except:
                    result['response_body'] = response.text[:500]
            
            self.test_results.append(result)
            return result['success']
            
        except Exception as e:
            result = {
                'test_type': 'application_health',
                'instance_id': instance_id,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.test_results.append(result)
            return False
    
    def test_database_connectivity(self, endpoint, port, username, password, database):
        """Test database connectivity and basic operations"""
        result = {
            'test_type': 'database_connectivity',
            'endpoint': endpoint,
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            # Connect to database
            connection = mysql.connector.connect(
                host=endpoint,
                port=port,
                user=username,
                password=password,
                database=database,
                connection_timeout=10
            )
            
            cursor = connection.cursor()
            
            # Test basic query
            cursor.execute("SELECT 1 as test")
            test_result = cursor.fetchone()
            
            result['connection_success'] = True
            result['query_success'] = test_result[0] == 1
            
            # Test table count
            cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = %s", (database,))
            table_count = cursor.fetchone()[0]
            result['table_count'] = table_count
            
            # Test sample data
            cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = %s AND table_rows > 0", (database,))
            tables_with_data = cursor.fetchone()[0]
            result['tables_with_data'] = tables_with_data
            
            cursor.close()
            connection.close()
            
            result['success'] = True
            
        except Exception as e:
            result['connection_success'] = False
            result['error'] = str(e)
            result['success'] = False
        
        self.test_results.append(result)
        return result['success']
    
    def test_performance_baseline(self, instance_id, baseline_metrics):
        """Test performance against baseline metrics"""
        result = {
            'test_type': 'performance_baseline',
            'instance_id': instance_id,
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            # Get CloudWatch metrics for the instance
            cloudwatch = boto3.client('cloudwatch')
            
            end_time = datetime.now()
            start_time = datetime.now().replace(hour=end_time.hour-1)  # Last hour
            
            # Get CPU utilization
            cpu_response = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=300,
                Statistics=['Average']
            )
            
            if cpu_response['Datapoints']:
                avg_cpu = sum(dp['Average'] for dp in cpu_response['Datapoints']) / len(cpu_response['Datapoints'])
                result['avg_cpu_utilization'] = avg_cpu
                result['cpu_within_baseline'] = avg_cpu <= baseline_metrics.get('max_cpu', 80)
            
            # Check if performance is acceptable
            result['success'] = result.get('cpu_within_baseline', True)
            
        except Exception as e:
            result['error'] = str(e)
            result['success'] = False
        
        self.test_results.append(result)
        return result['success']
    
    def test_data_integrity(self, source_endpoint, target_endpoint, database, table_name):
        """Test data integrity between source and target databases"""
        result = {
            'test_type': 'data_integrity',
            'database': database,
            'table': table_name,
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            # Connect to both databases
            source_conn = mysql.connector.connect(**source_endpoint, database=database)
            target_conn = mysql.connector.connect(**target_endpoint, database=database)
            
            source_cursor = source_conn.cursor()
            target_cursor = target_conn.cursor()
            
            # Compare row counts
            source_cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            source_count = source_cursor.fetchone()[0]
            
            target_cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            target_count = target_cursor.fetchone()[0]
            
            result['source_count'] = source_count
            result['target_count'] = target_count
            result['count_match'] = source_count == target_count
            
            # Sample checksum comparison (if supported)
            try:
                source_cursor.execute(f"SELECT MD5(CONCAT_WS(',', *)) FROM {table_name} ORDER BY 1 LIMIT 10")
                source_checksums = [row[0] for row in source_cursor.fetchall()]
                
                target_cursor.execute(f"SELECT MD5(CONCAT_WS(',', *)) FROM {table_name} ORDER BY 1 LIMIT 10")
                target_checksums = [row[0] for row in target_cursor.fetchall()]
                
                result['sample_checksum_match'] = source_checksums == target_checksums
                
            except Exception as checksum_error:
                result['checksum_error'] = str(checksum_error)
                result['sample_checksum_match'] = None
            
            source_cursor.close()
            target_cursor.close()
            source_conn.close()
            target_conn.close()
            
            result['success'] = result['count_match'] and result.get('sample_checksum_match', True)
            
        except Exception as e:
            result['error'] = str(e)
            result['success'] = False
        
        self.test_results.append(result)
        return result['success']
    
    def run_comprehensive_test_suite(self, test_config):
        """Run comprehensive test suite for migration validation"""
        print("Starting comprehensive migration test suite...")
        
        total_tests = 0
        passed_tests = 0
        
        # Test migrated servers
        for server_config in test_config.get('servers', []):
            instance_id = server_config['instance_id']
            
            print(f"Testing server: {instance_id}")
            
            # Connectivity test
            total_tests += 1
            if self.test_server_connectivity(instance_id):
                print("  ✓ Connectivity test passed")
                passed_tests += 1
            else:
                print("  ✗ Connectivity test failed")
            
            # Application health test
            if 'health_endpoint' in server_config:
                total_tests += 1
                if self.test_application_health(instance_id, 
                                               server_config['health_endpoint'],
                                               server_config.get('port', 80)):
                    print("  ✓ Application health test passed")
                    passed_tests += 1
                else:
                    print("  ✗ Application health test failed")
            
            # Performance baseline test
            if 'baseline_metrics' in server_config:
                total_tests += 1
                if self.test_performance_baseline(instance_id, server_config['baseline_metrics']):
                    print("  ✓ Performance baseline test passed")
                    passed_tests += 1
                else:
                    print("  ✗ Performance baseline test failed")
        
        # Test migrated databases
        for db_config in test_config.get('databases', []):
            print(f"Testing database: {db_config['name']}")
            
            total_tests += 1
            if self.test_database_connectivity(
                db_config['endpoint'],
                db_config['port'],
                db_config['username'],
                db_config['password'],
                db_config['database']
            ):
                print("  ✓ Database connectivity test passed")
                passed_tests += 1
            else:
                print("  ✗ Database connectivity test failed")
            
            # Data integrity tests
            if 'integrity_tests' in db_config:
                for table_test in db_config['integrity_tests']:
                    total_tests += 1
                    if self.test_data_integrity(
                        db_config['source_endpoint'],
                        {
                            'host': db_config['endpoint'],
                            'port': db_config['port'],
                            'user': db_config['username'],
                            'password': db_config['password']
                        },
                        db_config['database'],
                        table_test['table_name']
                    ):
                        print(f"  ✓ Data integrity test passed for {table_test['table_name']}")
                        passed_tests += 1
                    else:
                        print(f"  ✗ Data integrity test failed for {table_test['table_name']}")
        
        # Generate test report
        test_summary = {
            'total_tests': total_tests,
            'passed_tests': passed_tests,
            'failed_tests': total_tests - passed_tests,
            'success_rate': (passed_tests / total_tests * 100) if total_tests > 0 else 0,
            'overall_success': passed_tests == total_tests,
            'timestamp': datetime.now().isoformat(),
            'detailed_results': self.test_results
        }
        
        # Save test report
        with open(f'migration_test_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json', 'w') as f:
            json.dump(test_summary, f, indent=2)
        
        print(f"\nTest Summary:")
        print(f"Total tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {total_tests - passed_tests}")
        print(f"Success rate: {test_summary['success_rate']:.1f}%")
        
        return test_summary

# Example test configuration
if __name__ == "__main__":
    test_config = {
        'servers': [
            {
                'instance_id': 'i-1234567890abcdef0',
                'health_endpoint': '/health',
                'port': 80,
                'baseline_metrics': {
                    'max_cpu': 80,
                    'max_memory': 85
                }
            }
        ],
        'databases': [
            {
                'name': 'production-db',
                'endpoint': 'aurora-cluster.cluster-xyz.us-east-1.rds.amazonaws.com',
                'port': 3306,
                'username': 'admin',
                'password': 'secure_password',
                'database': 'production_db',
                'source_endpoint': {
                    'host': 'legacy-db.company.local',
                    'port': 3306,
                    'user': 'migration_user',
                    'password': 'secure_password'
                },
                'integrity_tests': [
                    {'table_name': 'users'},
                    {'table_name': 'orders'},
                    {'table_name': 'products'}
                ]
            }
        ]
    }
    
    tester = MigrationTesting()
    results = tester.run_comprehensive_test_suite(test_config)
    
    if results['overall_success']:
        print("\n🎉 All migration tests passed!")
    else:
        print(f"\n⚠️  {results['failed_tests']} tests failed. Review detailed results.")
EOF
```

---

## Phase 4: Optimization and Closure

### Step 4.1: Performance Optimization

#### Right-sizing and Cost Optimization

```python
# Create optimization recommendations script
cat > optimization_analyzer.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
from datetime import datetime, timedelta

class OptimizationAnalyzer:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        self.ce = boto3.client('ce', region_name=region)  # Cost Explorer
        
    def analyze_instance_utilization(self, instance_id, days=7):
        """Analyze instance utilization over specified period"""
        end_time = datetime.now()
        start_time = end_time - timedelta(days=days)
        
        metrics_to_check = ['CPUUtilization', 'NetworkIn', 'NetworkOut']
        utilization_data = {}
        
        for metric in metrics_to_check:
            try:
                response = self.cloudwatch.get_metric_statistics(
                    Namespace='AWS/EC2',
                    MetricName=metric,
                    Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                    StartTime=start_time,
                    EndTime=end_time,
                    Period=3600,  # 1 hour periods
                    Statistics=['Average', 'Maximum']
                )
                
                datapoints = response['Datapoints']
                if datapoints:
                    avg_values = [dp['Average'] for dp in datapoints]
                    max_values = [dp['Maximum'] for dp in datapoints]
                    
                    utilization_data[metric] = {
                        'average': sum(avg_values) / len(avg_values),
                        'peak': max(max_values),
                        'datapoints_count': len(datapoints)
                    }
                    
            except Exception as e:
                print(f"Error getting metrics for {metric}: {e}")
        
        return utilization_data
    
    def get_instance_details(self, instance_id):
        """Get instance configuration details"""
        try:
            response = self.ec2.describe_instances(InstanceIds=[instance_id])
            instance = response['Reservations'][0]['Instances'][0]
            
            return {
                'instance_type': instance['InstanceType'],
                'state': instance['State']['Name'],
                'launch_time': instance['LaunchTime'].isoformat(),
                'platform': instance.get('Platform', 'linux'),
                'vpc_id': instance.get('VpcId'),
                'subnet_id': instance.get('SubnetId'),
                'security_groups': [sg['GroupId'] for sg in instance.get('SecurityGroups', [])]
            }
        except Exception as e:
            print(f"Error getting instance details: {e}")
            return None
    
    def recommend_instance_type(self, current_type, utilization_data):
        """Recommend optimal instance type based on utilization"""
        
        # Instance type families and their characteristics
        instance_specs = {
            't3.nano': {'vcpu': 2, 'memory': 0.5, 'cost_factor': 1},
            't3.micro': {'vcpu': 2, 'memory': 1, 'cost_factor': 2},
            't3.small': {'vcpu': 2, 'memory': 2, 'cost_factor': 4},
            't3.medium': {'vcpu': 2, 'memory': 4, 'cost_factor': 8},
            't3.large': {'vcpu': 2, 'memory': 8, 'cost_factor': 16},
            't3.xlarge': {'vcpu': 4, 'memory': 16, 'cost_factor': 32},
            'm5.large': {'vcpu': 2, 'memory': 8, 'cost_factor': 18},
            'm5.xlarge': {'vcpu': 4, 'memory': 16, 'cost_factor': 36},
            'm5.2xlarge': {'vcpu': 8, 'memory': 32, 'cost_factor': 72},
            'c5.large': {'vcpu': 2, 'memory': 4, 'cost_factor': 17},
            'c5.xlarge': {'vcpu': 4, 'memory': 8, 'cost_factor': 34},
            'r5.large': {'vcpu': 2, 'memory': 16, 'cost_factor': 25},
            'r5.xlarge': {'vcpu': 4, 'memory': 32, 'cost_factor': 50}
        }
        
        current_specs = instance_specs.get(current_type, {})
        cpu_util = utilization_data.get('CPUUtilization', {})
        
        recommendation = {
            'current_type': current_type,
            'current_specs': current_specs,
            'utilization_analysis': cpu_util
        }
        
        if cpu_util:
            avg_cpu = cpu_util.get('average', 0)
            peak_cpu = cpu_util.get('peak', 0)
            
            # Recommendation logic
            if avg_cpu < 10 and peak_cpu < 30:
                # Significantly underutilized
                recommended_type = 't3.small' if current_type not in ['t3.nano', 't3.micro'] else current_type
                recommendation['recommendation'] = 'downsize'
                recommendation['reason'] = 'Low CPU utilization indicates oversizing'
                
            elif avg_cpu < 25 and peak_cpu < 60:
                # Moderately underutilized
                if current_type.startswith('m5') or current_type.startswith('c5'):
                    recommended_type = current_type.replace('xlarge', 'large').replace('2xlarge', 'xlarge')
                else:
                    recommended_type = current_type
                recommendation['recommendation'] = 'minor_downsize'
                recommendation['reason'] = 'Moderate underutilization'
                
            elif avg_cpu > 70 or peak_cpu > 90:
                # Highly utilized
                if current_type.endswith('large'):
                    recommended_type = current_type.replace('large', 'xlarge')
                elif current_type.endswith('xlarge'):
                    recommended_type = current_type.replace('xlarge', '2xlarge')
                else:
                    recommended_type = current_type
                recommendation['recommendation'] = 'upsize'
                recommendation['reason'] = 'High CPU utilization indicates undersizing'
                
            else:
                # Appropriately sized
                recommended_type = current_type
                recommendation['recommendation'] = 'maintain'
                recommendation['reason'] = 'Current sizing appears appropriate'
            
            recommendation['recommended_type'] = recommended_type
            recommendation['recommended_specs'] = instance_specs.get(recommended_type, {})
            
            # Calculate potential cost impact
            current_cost = current_specs.get('cost_factor', 0)
            recommended_cost = instance_specs.get(recommended_type, {}).get('cost_factor', 0)
            
            if current_cost > 0:
                cost_change = ((recommended_cost - current_cost) / current_cost) * 100
                recommendation['cost_impact_percent'] = cost_change
        
        return recommendation
    
    def analyze_all_instances(self, tag_filters=None):
        """Analyze all instances and provide optimization recommendations"""
        filters = []
        if tag_filters:
            for key, value in tag_filters.items():
                filters.append({'Name': f'tag:{key}', 'Values': [value]})
        
        try:
            if filters:
                response = self.ec2.describe_instances(Filters=filters)
            else:
                response = self.ec2.describe_instances()
            
            all_recommendations = []
            
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    if instance['State']['Name'] == 'running':
                        instance_id = instance['InstanceId']
                        
                        print(f"Analyzing instance: {instance_id}")
                        
                        # Get utilization data
                        utilization = self.analyze_instance_utilization(instance_id)
                        
                        # Get instance details
                        details = self.get_instance_details(instance_id)
                        
                        # Get recommendation
                        recommendation = self.recommend_instance_type(
                            details['instance_type'], 
                            utilization
                        )
                        
                        analysis_result = {
                            'instance_id': instance_id,
                            'instance_details': details,
                            'utilization_data': utilization,
                            'recommendation': recommendation,
                            'analysis_timestamp': datetime.now().isoformat()
                        }
                        
                        all_recommendations.append(analysis_result)
            
            return all_recommendations
            
        except Exception as e:
            print(f"Error analyzing instances: {e}")
            return []
    
    def generate_optimization_report(self, tag_filters=None):
        """Generate comprehensive optimization report"""
        
        recommendations = self.analyze_all_instances(tag_filters)
        
        # Aggregate statistics
        total_instances = len(recommendations)
        downsize_candidates = sum(1 for r in recommendations 
                                 if r['recommendation']['recommendation'] in ['downsize', 'minor_downsize'])
        upsize_candidates = sum(1 for r in recommendations 
                               if r['recommendation']['recommendation'] == 'upsize')
        properly_sized = sum(1 for r in recommendations 
                            if r['recommendation']['recommendation'] == 'maintain')
        
        # Calculate potential savings
        total_cost_impact = sum(r['recommendation'].get('cost_impact_percent', 0) 
                               for r in recommendations)
        avg_cost_impact = total_cost_impact / total_instances if total_instances > 0 else 0
        
        report = {
            'analysis_timestamp': datetime.now().isoformat(),
            'summary': {
                'total_instances_analyzed': total_instances,
                'downsize_candidates': downsize_candidates,
                'upsize_candidates': upsize_candidates,
                'properly_sized': properly_sized,
                'average_cost_impact_percent': avg_cost_impact
            },
            'recommendations': recommendations,
            'action_items': self._generate_action_items(recommendations)
        }
        
        # Save report
        filename = f'optimization_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Optimization report saved: {filename}")
        return report
    
    def _generate_action_items(self, recommendations):
        """Generate prioritized action items"""
        action_items = []
        
        # High priority: significantly oversized instances
        for rec in recommendations:
            if rec['recommendation']['recommendation'] == 'downsize':
                cost_impact = rec['recommendation'].get('cost_impact_percent', 0)
                if cost_impact < -30:  # More than 30% cost reduction
                    action_items.append({
                        'priority': 'High',
                        'action': 'Downsize instance',
                        'instance_id': rec['instance_id'],
                        'current_type': rec['recommendation']['current_type'],
                        'recommended_type': rec['recommendation']['recommended_type'],
                        'estimated_savings_percent': abs(cost_impact),
                        'reason': rec['recommendation']['reason']
                    })
        
        # Medium priority: undersized instances
        for rec in recommendations:
            if rec['recommendation']['recommendation'] == 'upsize':
                action_items.append({
                    'priority': 'Medium',
                    'action': 'Upsize instance',
                    'instance_id': rec['instance_id'],
                    'current_type': rec['recommendation']['current_type'],
                    'recommended_type': rec['recommendation']['recommended_type'],
                    'reason': rec['recommendation']['reason']
                })
        
        # Low priority: minor optimizations
        for rec in recommendations:
            if rec['recommendation']['recommendation'] == 'minor_downsize':
                cost_impact = rec['recommendation'].get('cost_impact_percent', 0)
                if cost_impact < -10:  # More than 10% cost reduction
                    action_items.append({
                        'priority': 'Low',
                        'action': 'Minor downsize',
                        'instance_id': rec['instance_id'],
                        'current_type': rec['recommendation']['current_type'],
                        'recommended_type': rec['recommendation']['recommended_type'],
                        'estimated_savings_percent': abs(cost_impact),
                        'reason': rec['recommendation']['reason']
                    })
        
        return sorted(action_items, key=lambda x: {'High': 3, 'Medium': 2, 'Low': 1}[x['priority']], reverse=True)

if __name__ == "__main__":
    analyzer = OptimizationAnalyzer()
    
    # Analyze instances with migration tag
    report = analyzer.generate_optimization_report({'Project': 'cloud-migration'})
    
    print("\nOptimization Summary:")
    print(f"Total instances: {report['summary']['total_instances_analyzed']}")
    print(f"Downsize candidates: {report['summary']['downsize_candidates']}")
    print(f"Upsize candidates: {report['summary']['upsize_candidates']}")
    print(f"Properly sized: {report['summary']['properly_sized']}")
    print(f"Average cost impact: {report['summary']['average_cost_impact_percent']:.1f}%")
    
    print(f"\nHigh priority actions: {len([a for a in report['action_items'] if a['priority'] == 'High'])}")
EOF
```

### Step 4.2: Security Hardening

#### Implement Security Best Practices

```bash
# Create security hardening script
cat > security_hardening.sh << 'EOF'
#!/bin/bash

PROJECT_NAME="cloud-migration"
AWS_REGION="us-east-1"

echo "=== Starting Security Hardening ==="

# Enable VPC Flow Logs
echo "Enabling VPC Flow Logs..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${PROJECT_NAME}-migration-vpc" --query 'Vpcs[0].VpcId' --output text)

if [ "$VPC_ID" != "None" ]; then
    aws ec2 create-flow-logs \
        --resource-type VPC \
        --resource-ids $VPC_ID \
        --traffic-type ALL \
        --log-destination-type cloud-watch-logs \
        --log-group-name /aws/vpc/flowlogs \
        --deliver-logs-permission-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/flowlogsRole
    
    echo "VPC Flow Logs enabled for $VPC_ID"
fi

# Enable GuardDuty
echo "Enabling GuardDuty..."
aws guardduty create-detector --enable

# Enable Security Hub
echo "Enabling Security Hub..."
aws securityhub enable-security-hub --enable-default-standards

# Enable Config
echo "Enabling AWS Config..."
CONFIG_ROLE_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/aws-config-role"
CONFIG_BUCKET="${PROJECT_NAME}-config-$(aws sts get-caller-identity --query Account --output text)-${AWS_REGION}"

# Create Config bucket
aws s3 mb s3://$CONFIG_BUCKET
aws s3api put-bucket-encryption \
    --bucket $CONFIG_BUCKET \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Enable Config
aws configservice put-configuration-recorder \
    --configuration-recorder name=default,roleARN=$CONFIG_ROLE_ARN,recordingGroup='{
        "allSupported": true,
        "includeGlobalResourceTypes": true
    }'

aws configservice put-delivery-channel \
    --delivery-channel name=default,s3BucketName=$CONFIG_BUCKET

aws configservice start-configuration-recorder --configuration-recorder-name default

# Create CloudTrail
echo "Setting up CloudTrail..."
CLOUDTRAIL_BUCKET="${PROJECT_NAME}-cloudtrail-$(aws sts get-caller-identity --query Account --output text)-${AWS_REGION}"

aws s3 mb s3://$CLOUDTRAIL_BUCKET
aws s3api put-bucket-encryption \
    --bucket $CLOUDTRAIL_BUCKET \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Create CloudTrail
aws cloudtrail create-trail \
    --name ${PROJECT_NAME}-cloudtrail \
    --s3-bucket-name $CLOUDTRAIL_BUCKET \
    --include-global-service-events \
    --is-multi-region-trail \
    --enable-log-file-validation

aws cloudtrail start-logging --name ${PROJECT_NAME}-cloudtrail

# Set up Security Group compliance rules
echo "Creating Security Group compliance rules..."
aws configservice put-config-rule \
    --config-rule '{
        "ConfigRuleName": "sg-ssh-restricted",
        "Source": {
            "Owner": "AWS",
            "SourceIdentifier": "INCOMING_SSH_DISABLED"
        },
        "Scope": {
            "ComplianceResourceTypes": ["AWS::EC2::SecurityGroup"]
        }
    }'

aws configservice put-config-rule \
    --config-rule '{
        "ConfigRuleName": "sg-rdp-restricted", 
        "Source": {
            "Owner": "AWS",
            "SourceIdentifier": "INCOMING_RDP_DISABLED"
        },
        "Scope": {
            "ComplianceResourceTypes": ["AWS::EC2::SecurityGroup"]
        }
    }'

# Create IAM password policy
echo "Setting IAM password policy..."
aws iam update-account-password-policy \
    --minimum-password-length 14 \
    --require-symbols \
    --require-numbers \
    --require-uppercase-characters \
    --require-lowercase-characters \
    --allow-users-to-change-password \
    --max-password-age 90 \
    --password-reuse-prevention 12

# Enable EBS encryption by default
echo "Enabling EBS encryption by default..."
aws ec2 enable-ebs-encryption-by-default

echo "=== Security Hardening Complete ==="
EOF

chmod +x security_hardening.sh
./security_hardening.sh
```

### Step 4.3: Knowledge Transfer and Documentation

#### Create Migration Documentation

```bash
# Create comprehensive documentation script
cat > generate_migration_docs.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
import os
from datetime import datetime
import markdown

class MigrationDocumentation:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.rds = boto3.client('rds', region_name=region)
        self.s3 = boto3.client('s3', region_name=region)
        self.mgn = boto3.client('mgn', region_name=region)
        
    def document_infrastructure(self):
        """Document the migrated infrastructure"""
        docs = {
            'vpc_configuration': self._document_vpc(),
            'ec2_instances': self._document_ec2_instances(),
            'rds_databases': self._document_rds_databases(),
            's3_buckets': self._document_s3_buckets(),
            'security_groups': self._document_security_groups()
        }
        return docs
    
    def _document_vpc(self):
        """Document VPC configuration"""
        vpcs = self.ec2.describe_vpcs()['Vpcs']
        vpc_docs = []
        
        for vpc in vpcs:
            vpc_id = vpc['VpcId']
            
            # Get subnets
            subnets = self.ec2.describe_subnets(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )['Subnets']
            
            # Get route tables
            route_tables = self.ec2.describe_route_tables(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )['RouteTables']
            
            vpc_doc = {
                'vpc_id': vpc_id,
                'cidr_block': vpc['CidrBlock'],
                'state': vpc['State'],
                'tags': vpc.get('Tags', []),
                'subnets': [{
                    'subnet_id': subnet['SubnetId'],
                    'cidr_block': subnet['CidrBlock'],
                    'availability_zone': subnet['AvailabilityZone'],
                    'tags': subnet.get('Tags', [])
                } for subnet in subnets],
                'route_tables': [{
                    'route_table_id': rt['RouteTableId'],
                    'routes': rt['Routes'],
                    'associations': rt['Associations']
                } for rt in route_tables]
            }
            
            vpc_docs.append(vpc_doc)
        
        return vpc_docs
    
    def _document_ec2_instances(self):
        """Document EC2 instances"""
        instances = []
        
        response = self.ec2.describe_instances()
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] == 'running':
                    instance_doc = {
                        'instance_id': instance['InstanceId'],
                        'instance_type': instance['InstanceType'],
                        'ami_id': instance['ImageId'],
                        'launch_time': instance['LaunchTime'].isoformat(),
                        'availability_zone': instance['Placement']['AvailabilityZone'],
                        'private_ip': instance.get('PrivateIpAddress'),
                        'public_ip': instance.get('PublicIpAddress'),
                        'security_groups': [sg['GroupId'] for sg in instance['SecurityGroups']],
                        'tags': instance.get('Tags', []),
                        'key_name': instance.get('KeyName'),
                        'platform': instance.get('Platform', 'linux')
                    }
                    instances.append(instance_doc)
        
        return instances
    
    def _document_rds_databases(self):
        """Document RDS databases"""
        databases = []
        
        try:
            response = self.rds.describe_db_instances()
            for db in response['DBInstances']:
                db_doc = {
                    'db_identifier': db['DBInstanceIdentifier'],
                    'engine': db['Engine'],
                    'engine_version': db['EngineVersion'],
                    'instance_class': db['DBInstanceClass'],
                    'allocated_storage': db['AllocatedStorage'],
                    'storage_type': db['StorageType'],
                    'endpoint': db.get('Endpoint', {}).get('Address'),
                    'port': db.get('Endpoint', {}).get('Port'),
                    'master_username': db['MasterUsername'],
                    'availability_zone': db.get('AvailabilityZone'),
                    'multi_az': db['MultiAZ'],
                    'backup_retention_period': db['BackupRetentionPeriod'],
                    'storage_encrypted': db['StorageEncrypted'],
                    'tags': self.rds.list_tags_for_resource(
                        ResourceName=db['DBInstanceArn']
                    ).get('TagList', [])
                }
                databases.append(db_doc)
        except Exception as e:
            print(f"Error documenting RDS: {e}")
        
        return databases
    
    def _document_s3_buckets(self):
        """Document S3 buckets"""
        buckets = []
        
        try:
            response = self.s3.list_buckets()
            for bucket in response['Buckets']:
                bucket_name = bucket['Name']
                
                # Get bucket location
                try:
                    location = self.s3.get_bucket_location(Bucket=bucket_name)
                    region = location['LocationConstraint'] or 'us-east-1'
                except:
                    region = 'unknown'
                
                # Get bucket encryption
                try:
                    encryption = self.s3.get_bucket_encryption(Bucket=bucket_name)
                    encryption_config = encryption['ServerSideEncryptionConfiguration']
                except:
                    encryption_config = None
                
                # Get bucket tags
                try:
                    tags = self.s3.get_bucket_tagging(Bucket=bucket_name)['TagSet']
                except:
                    tags = []
                
                bucket_doc = {
                    'bucket_name': bucket_name,
                    'creation_date': bucket['CreationDate'].isoformat(),
                    'region': region,
                    'encryption': encryption_config,
                    'tags': tags
                }
                buckets.append(bucket_doc)
        except Exception as e:
            print(f"Error documenting S3: {e}")
        
        return buckets
    
    def _document_security_groups(self):
        """Document security groups"""
        security_groups = []
        
        response = self.ec2.describe_security_groups()
        for sg in response['SecurityGroups']:
            sg_doc = {
                'group_id': sg['GroupId'],
                'group_name': sg['GroupName'],
                'description': sg['Description'],
                'vpc_id': sg.get('VpcId'),
                'inbound_rules': [{
                    'protocol': rule.get('IpProtocol'),
                    'from_port': rule.get('FromPort'),
                    'to_port': rule.get('ToPort'),
                    'cidr_blocks': [ip_range['CidrIp'] for ip_range in rule.get('IpRanges', [])],
                    'source_groups': [group['GroupId'] for group in rule.get('UserIdGroupPairs', [])]
                } for rule in sg['IpPermissions']],
                'outbound_rules': [{
                    'protocol': rule.get('IpProtocol'),
                    'from_port': rule.get('FromPort'),
                    'to_port': rule.get('ToPort'),
                    'cidr_blocks': [ip_range['CidrIp'] for ip_range in rule.get('IpRanges', [])],
                    'destination_groups': [group['GroupId'] for group in rule.get('UserIdGroupPairs', [])]
                } for rule in sg['IpPermissionsEgress']],
                'tags': sg.get('Tags', [])
            }
            security_groups.append(sg_doc)
        
        return security_groups
    
    def generate_migration_runbook(self):
        """Generate migration runbook"""
        runbook_content = """
# Migration Runbook

## Overview
This runbook contains procedures for managing the migrated infrastructure.

## Daily Operations

### Health Checks
1. Check CloudWatch dashboards
2. Verify application health endpoints
3. Review backup completion
4. Monitor cost and usage

### Monitoring
- CloudWatch alarms for critical metrics
- Application performance monitoring
- Security monitoring via GuardDuty
- Log analysis in CloudWatch Logs

## Troubleshooting

### Common Issues
1. **High CPU Usage**
   - Check CloudWatch metrics
   - Identify resource-intensive processes
   - Consider instance scaling

2. **Database Connection Issues**
   - Verify security group rules
   - Check database status
   - Review connection pool settings

3. **Application Errors**
   - Review application logs
   - Check dependent services
   - Verify configuration

### Emergency Procedures
1. **Service Outage**
   - Check AWS Service Health Dashboard
   - Review CloudWatch alarms
   - Implement failover procedures

2. **Security Incident**
   - Isolate affected resources
   - Review CloudTrail logs
   - Follow incident response plan

## Maintenance

### Weekly Tasks
- Review security group changes
- Check backup completion
- Monitor cost trends
- Update documentation

### Monthly Tasks
- Security patch updates
- Performance optimization review
- Cost optimization analysis
- Disaster recovery testing

## Contact Information
- Operations Team: ops@company.com
- Security Team: security@company.com
- AWS Support: [Support Case Portal]
"""
        return runbook_content
    
    def generate_complete_documentation(self):
        """Generate complete migration documentation"""
        print("Generating migration documentation...")
        
        # Create documentation directory
        os.makedirs('migration_docs', exist_ok=True)
        
        # Document infrastructure
        infrastructure_docs = self.document_infrastructure()
        
        # Save infrastructure documentation
        with open('migration_docs/infrastructure_inventory.json', 'w') as f:
            json.dump(infrastructure_docs, f, indent=2, default=str)
        
        # Generate runbook
        runbook = self.generate_migration_runbook()
        with open('migration_docs/migration_runbook.md', 'w') as f:
            f.write(runbook)
        
        # Generate summary report
        summary = {
            'migration_completion_date': datetime.now().isoformat(),
            'summary': {
                'total_vpcs': len(infrastructure_docs['vpc_configuration']),
                'total_instances': len(infrastructure_docs['ec2_instances']),
                'total_databases': len(infrastructure_docs['rds_databases']),
                'total_s3_buckets': len(infrastructure_docs['s3_buckets']),
                'total_security_groups': len(infrastructure_docs['security_groups'])
            },
            'migration_artifacts': {
                'infrastructure_inventory': 'infrastructure_inventory.json',
                'runbook': 'migration_runbook.md',
                'test_reports': 'Available in test_reports directory',
                'optimization_reports': 'Available in optimization_reports directory'
            }
        }
        
        with open('migration_docs/migration_summary.json', 'w') as f:
            json.dump(summary, f, indent=2)
        
        print("Documentation generated in migration_docs/ directory")
        print(f"Summary: {summary['summary']}")
        
        return summary

if __name__ == "__main__":
    documenter = MigrationDocumentation()
    summary = documenter.generate_complete_documentation()
    
    print("\n📚 Migration documentation complete!")
    print("Files generated:")
    print("- migration_docs/infrastructure_inventory.json")
    print("- migration_docs/migration_runbook.md")
    print("- migration_docs/migration_summary.json")
EOF

# Generate final documentation
python3 generate_migration_docs.py
```

---

## Project Closure and Handover

### Final Migration Report

```bash
# Create final migration report
cat > final_migration_report.py << 'EOF'
#!/usr/bin/env python3
import json
import os
from datetime import datetime

def generate_final_report():
    """Generate comprehensive final migration report"""
    
    # Collect all migration artifacts
    artifacts = {
        'assessment_reports': [],
        'test_reports': [],
        'optimization_reports': [],
        'documentation': []
    }
    
    # Scan for migration artifacts
    for root, dirs, files in os.walk('.'):
        for file in files:
            if 'migration_assessment' in file and file.endswith('.json'):
                artifacts['assessment_reports'].append(os.path.join(root, file))
            elif 'migration_test' in file and file.endswith('.json'):
                artifacts['test_reports'].append(os.path.join(root, file))
            elif 'optimization_report' in file and file.endswith('.json'):
                artifacts['optimization_reports'].append(os.path.join(root, file))
            elif file.endswith('.md') or file.endswith('.json'):
                if 'docs' in root or 'migration' in file:
                    artifacts['documentation'].append(os.path.join(root, file))
    
    # Create final report
    final_report = {
        'project_name': 'AWS Cloud Migration',
        'completion_date': datetime.now().isoformat(),
        'project_summary': {
            'status': 'Completed Successfully',
            'total_duration': 'X weeks',  # Update with actual duration
            'phases_completed': ['Discovery', 'Foundation', 'Migration', 'Optimization'],
            'success_criteria_met': True
        },
        'migration_statistics': {
            'servers_migrated': 'Update with actual count',
            'databases_migrated': 'Update with actual count',
            'data_transferred': 'Update with actual amount',
            'downtime_achieved': 'Update with actual downtime',
            'zero_data_loss': True
        },
        'business_outcomes': {
            'cost_reduction_achieved': 'Update with actual savings',
            'performance_improvement': 'Update with metrics',
            'availability_improvement': 'Update with uptime',
            'security_posture': 'Enhanced'
        },
        'lessons_learned': [
            'Thorough discovery phase critical for success',
            'Automated testing reduces risk significantly',
            'Regular communication prevents project delays',
            'Proper planning enables smooth execution'
        ],
        'recommendations': [
            'Implement regular optimization reviews',
            'Maintain comprehensive monitoring',
            'Continue security best practices',
            'Plan for ongoing skill development'
        ],
        'migration_artifacts': artifacts,
        'post_migration_support': {
            'operations_team': 'Trained and ready',
            'documentation': 'Complete and accessible',
            'monitoring': 'Fully implemented',
            'backup_procedures': 'Tested and verified'
        }
    }
    
    # Save final report
    with open('final_migration_report.json', 'w') as f:
        json.dump(final_report, f, indent=2)
    
    print("Final Migration Report Generated")
    print("=" * 50)
    print(f"Project Status: {final_report['project_summary']['status']}")
    print(f"Completion Date: {final_report['completion_date']}")
    print(f"Zero Data Loss: {final_report['migration_statistics']['zero_data_loss']}")
    print("\nDeliverables:")
    print(f"- Assessment Reports: {len(artifacts['assessment_reports'])}")
    print(f"- Test Reports: {len(artifacts['test_reports'])}")
    print(f"- Optimization Reports: {len(artifacts['optimization_reports'])}")
    print(f"- Documentation Files: {len(artifacts['documentation'])}")
    
    return final_report

if __name__ == "__main__":
    report = generate_final_report()
    print("\n🎉 Migration project successfully completed!")
    print("Final report saved as: final_migration_report.json")
EOF

python3 final_migration_report.py
```

---

## Summary

This implementation guide provides a comprehensive, step-by-step approach to executing an enterprise cloud migration to AWS. The guide includes:

### Key Deliverables
- **Automated Discovery**: Scripts for infrastructure and application discovery
- **Migration Tools Setup**: Complete configuration of MGN, DMS, and SMS services
- **Testing Framework**: Comprehensive validation and testing procedures
- **Optimization Tools**: Performance and cost optimization analysis
- **Security Hardening**: Implementation of security best practices
- **Documentation**: Complete operational runbooks and knowledge transfer

### Success Factors
- **Phased Approach**: Risk-managed execution across multiple waves
- **Automation First**: Leveraging AWS native tools for efficiency
- **Continuous Validation**: Testing at every stage to ensure quality
- **Comprehensive Monitoring**: Full visibility into migration progress
- **Knowledge Transfer**: Proper documentation and team training

### Next Steps
1. **Operations Handover**: Transition to operational support team
2. **Continuous Optimization**: Regular review and optimization cycles
3. **Skills Development**: Ongoing AWS training and certification
4. **Innovation Planning**: Leverage cloud capabilities for business innovation

---

## Implementation Troubleshooting

### Common Migration Issues and Solutions

#### AWS Migration Service (MGN) Issues
**Symptoms:** Agent installation failures, replication not starting, agent disconnected
**Quick Resolution:**
- Verify AWS credentials and IAM permissions for MGN service
- Check network connectivity to AWS MGN endpoints
- Validate source server requirements and compatibility
- Review agent installation logs: `sudo tail -f /var/log/aws-replication-agent.log`
- Reinstall agent with proper parameters if needed

#### Database Migration Service (DMS) Issues
**Symptoms:** Replication task failures, data inconsistencies, connection timeouts
**Quick Resolution:**
- Verify DMS replication instance capacity and configuration
- Check source and target database connectivity and permissions
- Review DMS task logs for specific error messages
- Validate network security groups and firewall rules
- Test database connections independently

#### Network Connectivity Issues
**Symptoms:** VPN connection failures, Direct Connect issues, routing problems
**Quick Resolution:**
- Test basic connectivity: `ping`, `telnet`, `nslookup`
- Verify security group rules and NACLs
- Check VPC endpoints and NAT Gateway configurations
- Validate DNS resolution and certificate chains
- Review CloudWatch VPC Flow Logs for traffic analysis

#### Performance and Capacity Issues
**Symptoms:** Slow migration performance, resource exhaustion, auto-scaling issues
**Quick Resolution:**
- Check CloudWatch metrics for CPU, memory, and network utilization
- Review auto-scaling policies and thresholds
- Validate resource quotas and service limits
- Optimize instance types and storage configurations
- Implement performance tuning recommendations

### Migration-Specific Diagnostics

#### MGN Agent Diagnostics
```bash
# Check MGN agent status
sudo systemctl status aws-replication-agent

# Verify network connectivity to MGN endpoints
curl -I https://mgn.region.amazonaws.com

# Review detailed agent logs
sudo tail -100 /var/log/aws-replication-agent.log

# Test MGN service connectivity
aws mgn describe-source-servers --region us-east-1
```

#### DMS Task Monitoring
```bash
# Check DMS task status
aws dms describe-replication-tasks --region us-east-1

# Review DMS task logs
aws logs get-log-events --log-group-name dms-tasks-replication-instance-id

# Monitor DMS metrics
aws cloudwatch get-metric-statistics --namespace AWS/DMS
```

#### Migration Wave Validation
- Verify all dependencies are resolved before proceeding
- Test application functionality in target environment
- Validate data integrity and consistency
- Check performance against baseline metrics
- Confirm backup and recovery procedures

### Escalation Procedures
- **Level 1 Issues** (< 4 hours): Configuration errors, permission issues, basic connectivity
- **Level 2 Issues** (4-8 hours): Complex network issues, performance optimization, data inconsistencies
- **Level 3 Issues** (> 8 hours): Architecture problems, security incidents, major data corruption

**Escalation Information Required:**
- Detailed error messages and logs
- Migration wave and server details
- Recent changes or modifications
- Current migration status and metrics
- Impact assessment and affected systems

---

**Document Version**: 1.0
**Last Updated**: January 2025
**Next Review**: April 2025
**Maintained By**: Migration Implementation Team