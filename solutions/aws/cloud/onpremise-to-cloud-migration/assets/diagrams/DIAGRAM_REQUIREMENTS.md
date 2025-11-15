# AWS On-Premise to Cloud Migration - Architecture Diagram Requirements

## Overview
This document specifies the components and layout for the AWS Cloud Migration architecture diagram showing the migration journey from on-premises to AWS cloud.

## Required Components

### On-Premises Environment (Source)
1. **Data Center**
   - Legacy application servers
   - On-premise databases
   - File servers and storage
   - Network infrastructure

2. **Connectivity**
   - AWS Site-to-Site VPN
   - Optional: AWS Direct Connect
   - Secure hybrid connectivity during migration

### AWS Migration Tools & Services
1. **AWS Migration Hub**
   - Centralized migration tracking
   - Progress monitoring
   - Dependency mapping

2. **AWS Application Discovery Service**
   - Automated application discovery
   - Dependency analysis
   - Migration readiness assessment

3. **AWS Database Migration Service (DMS)**
   - Schema conversion
   - Data replication
   - Minimal downtime migration

4. **AWS Server Migration Service (SMS)**
   - Server replication
   - Incremental sync
   - Automated AMI creation

5. **AWS DataSync / Snowball**
   - Large-scale data transfer
   - S3 data migration
   - Offline data transport (Snowball)

### AWS Landing Zone (Target)
1. **AWS Control Tower**
   - Multi-account structure
   - Organizational units (OUs)
   - Guardrails and policies

2. **Account Structure**
   - Management Account
   - Security Account
   - Log Archive Account
   - Production Workload Account
   - Development/Test Accounts

### AWS Cloud Infrastructure (Migrated Applications)
1. **Compute Tier**
   - Amazon EC2 instances (migrated workloads)
   - Auto Scaling Groups
   - Multiple Availability Zones

2. **Database Tier**
   - Amazon RDS (migrated databases)
   - Multi-AZ deployment
   - Read replicas

3. **Storage Tier**
   - Amazon S3 (object storage)
   - Amazon EBS (block storage)
   - Amazon EFS (shared file systems)

4. **Network Tier**
   - Amazon VPC
   - Public and private subnets
   - Application Load Balancer
   - NAT Gateway
   - VPN Gateway

5. **Content Delivery**
   - Amazon CloudFront CDN
   - Edge locations
   - Static content acceleration

6. **Caching**
   - Amazon ElastiCache Redis
   - Session state management
   - Application performance

### Security & Compliance
1. **Identity & Access**
   - AWS IAM roles and policies
   - AWS Organizations
   - AWS SSO integration

2. **Network Security**
   - Security Groups
   - Network ACLs
   - AWS WAF (Web Application Firewall)

3. **Encryption & Secrets**
   - AWS Secrets Manager
   - AWS KMS (Key Management Service)
   - Encryption at rest and in transit

### Operations & Monitoring
1. **Monitoring**
   - Amazon CloudWatch
   - Custom metrics and dashboards
   - Log aggregation

2. **Configuration Management**
   - AWS Systems Manager
   - Parameter Store
   - Patch Manager

3. **Backup & Recovery**
   - AWS Backup
   - Automated backup policies
   - Cross-region backup vaults

4. **Infrastructure as Code**
   - HashiCorp Terraform
   - AWS CloudFormation
   - Automated provisioning

### DNS & Traffic Management
1. **Amazon Route 53**
   - DNS management
   - Health checks
   - Traffic routing policies

## Migration Phases & Flow

### Phase 1: Assessment & Planning
1. On-premises discovery → AWS Application Discovery Service
2. Dependency mapping → AWS Migration Hub
3. TCO analysis and wave planning

### Phase 2: Landing Zone Setup
1. AWS Control Tower deployment
2. Multi-account structure creation
3. Network connectivity establishment (VPN/Direct Connect)
4. Security baseline configuration

### Phase 3: Migration Waves
1. **Wave 1**: Simple stateless applications (lift-and-shift)
2. **Wave 2**: Databases using AWS DMS
3. **Wave 3**: Complex applications with dependencies

### Phase 4: Data Transfer
1. Small datasets → AWS DataSync over VPN/Direct Connect
2. Large datasets → AWS Snowball physical appliance
3. Continuous sync during migration window

### Phase 5: Cutover & Go-Live
1. Final data synchronization
2. DNS cutover via Route 53
3. Decommission on-premises infrastructure

## Diagram Layout Recommendations

### Layout Type: Left-to-Right Migration Journey
- **Far Left**: On-premises data center
- **Center**: Migration tools and hybrid connectivity
- **Right**: AWS Cloud landing zone and infrastructure
- **Top**: AWS Migration Hub (orchestration layer)
- **Bottom**: Monitoring and operations

### Suggested Sections
1. **Section 1 (Left)**: On-Premises Environment
   - Data center building icon
   - Server racks
   - Databases
   - Storage systems

2. **Section 2 (Center)**: Migration Bridge
   - VPN/Direct Connect tunnel
   - AWS DMS
   - AWS SMS
   - AWS DataSync/Snowball
   - Bidirectional arrows showing data flow

3. **Section 3 (Right)**: AWS Cloud Environment
   - AWS Control Tower (top level)
   - Multiple AWS accounts
   - VPC with subnets
   - Migrated applications and databases

### Color Coding
- **Gray**: On-premises infrastructure
- **Blue**: AWS native services
- **Orange**: Migration tools (DMS, SMS, DataSync)
- **Green**: Migrated workloads (running in AWS)
- **Purple**: Security and governance (Control Tower, IAM)
- **Red**: Connectivity (VPN, Direct Connect)

### Visual Flow Indicators
- **Large arrows** from on-premises to AWS showing migration direction
- **Dashed lines** for hybrid connectivity during migration
- **Numbered phases** showing migration wave sequence
- **Progress indicators** showing migration status

## AWS Icon Guidelines
- Use official AWS Architecture Icons
- Use data center/building icons for on-premises
- Migration arrows should be prominent and directional
- Show before/after state clearly
- Include legends for migration waves

## Data Flow Arrows
- **Bold blue arrows**: Data migration flow (on-prem → AWS)
- **Dashed orange arrows**: Hybrid connectivity (VPN/Direct Connect)
- **Green arrows**: Replication and sync (DMS, SMS)
- **Dotted arrows**: Discovery and monitoring
- **Red arrows**: Cutover and DNS failover

## Additional Notes
- Show migration waves as numbered phases
- Indicate RTO/RPO requirements
- Include timeline (e.g., "6-month migration")
- Show parallel migration tracks (apps, databases, data)
- Highlight cutover window and rollback plan
- Include cost optimization callouts
- Show decommissioning of on-premises resources

## Export Requirements
- **Source File**: `architecture-diagram.drawio`
- **Output File**: `architecture-diagram.png`
- **Resolution**: 1920x1080 minimum (widescreen for migration journey)
- **Format**: PNG with transparent background (optional)
- **DPI**: 300 for print quality

## References
- AWS Architecture Icons: https://aws.amazon.com/architecture/icons/
- AWS Migration Hub Documentation: https://docs.aws.amazon.com/migrationhub/
- AWS Cloud Adoption Framework: https://aws.amazon.com/professional-services/CAF/
- Draw.io AWS shape library: Pre-installed in Draw.io desktop

## How to Replace with Official AWS Icons

### Quick Start Guide
1. **Download Draw.io Desktop**: https://github.com/jgraph/drawio-desktop/releases
2. **Open**: `architecture-diagram.drawio`
3. **Enable AWS Icons**: Click "More Shapes..." → Check "AWS 19" → Apply
4. **Replace Shapes**: Drag AWS icons from sidebar to replace colored rectangles
5. **Add Connections**: Use Connector tool (press 'C') to draw arrows between components
6. **Export PNG**: File > Export as > PNG (300 DPI) → Save to `../images/architecture-diagram.png`
7. **Regenerate Docs**: `python3 doc-tools/solution-doc-builder.py --path solutions/aws/cloud/onpremise-to-cloud-migration --force`

### AWS Icon Replacements for Migration Solution

| Current Rectangle | Replace With | AWS Icon Name | Color |
|-------------------|--------------|---------------|-------|
| Gray on-prem servers | Generic server icon | On-Premises | Gray |
| Orange Migration Hub | Migration Hub icon | AWS Migration Hub | Orange |
| Orange Discovery | Discovery icon | AWS Application Discovery Service | Orange |
| Blue DMS box | Database migration icon | AWS Database Migration Service | Blue |
| Blue SMS box | Server migration icon | AWS Server Migration Service | Blue |
| Blue DataSync box | DataSync icon | AWS DataSync | Blue |
| Green EC2 boxes | EC2 instance icon | Amazon EC2 | Orange |
| Blue RDS boxes | RDS database icon | Amazon RDS | Blue |
| Blue S3 boxes | S3 bucket icon | Amazon S3 | Green/Orange |
| Green Control Tower | Control Tower icon | AWS Control Tower | Orange |
| Purple VPN | VPN gateway icon | AWS Site-to-Site VPN | Purple |

### Migration Journey Layout Tips
- **Left (On-Premises)**: Use gray tones for legacy infrastructure
- **Center (Migration Tools)**: Use orange/blue for AWS migration services  
- **Right (AWS Cloud)**: Use green tones for modern AWS infrastructure
- **Migration Arrows**: Use thick orange arrows showing left-to-right flow
- **Connectivity**: Purple line at bottom showing VPN/Direct Connect
- **Phases**: Number the migration waves (1, 2, 3) with colored badges

### Connector Styles for Migration
- **Thick orange arrow**: Main migration flow (On-Prem → Migration Tools → AWS)
- **Blue dashed arrow**: Data replication/sync (DMS, DataSync)
- **Purple solid line**: Network connectivity (VPN/Direct Connect)
- **Dotted green arrow**: Discovery and assessment flows

### Icons for Migration Phases
Add these to show progression:
- **Phase 1 badge**: Circle with "1" - Discovery & Assessment
- **Phase 2 badge**: Circle with "2" - Landing Zone Setup
- **Phase 3 badge**: Circle with "3" - Migration Waves

### Non-AWS Elements
For on-premises infrastructure (left side), use:
- **Generic server icon**: For on-prem application servers
- **Database cylinder**: For on-prem databases
- **Building icon**: For data center
- Use gray/muted colors to contrast with bright AWS icons

### References
- **AWS Migration Hub**: https://aws.amazon.com/migration-hub/
- **AWS Cloud Adoption Framework**: https://aws.amazon.com/professional-services/CAF/
- **Migration Strategies (6 Rs)**: https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-readiness/migration-strategies.html
- **AWS Architecture Icons**: https://aws.amazon.com/architecture/icons/
- **AWS Migration Whitepaper**: https://docs.aws.amazon.com/whitepapers/latest/aws-overview/migration-services.html
