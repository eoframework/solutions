# AWS Disaster Recovery for Web Applications - Architecture Diagram Requirements

## Overview
This document specifies the components and layout for the AWS DR solution architecture diagram showing multi-region disaster recovery setup.

## Required Components

### Primary Region (Production)
1. **Amazon EC2 (Web/App Tier)**
   - t3.large instances
   - Auto Scaling Group
   - Multiple Availability Zones

2. **Amazon RDS (Primary Database)**
   - db.r5.large Multi-AZ PostgreSQL
   - Automated backups
   - Read replicas within region

3. **Application Load Balancer**
   - Health checks
   - SSL/TLS termination
   - Multi-AZ distribution

4. **Amazon S3 (Primary Storage)**
   - Application data and static assets
   - Versioning enabled
   - Cross-region replication to DR

5. **Amazon EBS Volumes**
   - Application data storage
   - Automated snapshots

### DR Region (Secondary)
1. **Amazon EC2 (Standby)**
   - t3.medium instances (warm standby)
   - Smaller footprint than production
   - Auto Scaling (scaled to zero for pilot light)

2. **Amazon RDS (DR Database)**
   - Cross-region read replica
   - Promoted to primary during failover
   - Same configuration as primary

3. **Application Load Balancer (DR)**
   - Pre-configured for failover
   - Health checks ready
   - SSL certificates deployed

4. **Amazon S3 (DR Storage)**
   - Replicated from primary region
   - Same versioning configuration

### Global Services
1. **Amazon Route 53**
   - Hosted zones for both regions
   - Health checks on primary endpoints
   - Automated DNS failover
   - Weighted routing policies

2. **AWS Backup**
   - Centralized backup management
   - Cross-region backup vault
   - Compliance policies

3. **AWS CloudTrail**
   - Audit logging for both regions
   - Centralized trail

### Networking
1. **VPC (Primary & DR)**
   - Multi-AZ subnet architecture
   - Public subnets (ALB)
   - Private subnets (EC2, RDS)
   - Isolated data tier

2. **VPN Connection**
   - Site-to-site VPN between regions
   - Secure communication
   - Redundant tunnels

3. **NAT Gateway**
   - One per region
   - Outbound internet access

4. **Security Groups**
   - Application tier rules
   - Database tier rules
   - Least-privilege access

### Monitoring & Operations
1. **Amazon CloudWatch**
   - Metrics from both regions
   - Centralized dashboards
   - Failover alarms

2. **Amazon SNS**
   - DR event notifications
   - Health check alerts
   - Failover triggers

3. **AWS Systems Manager**
   - Configuration management
   - Patch automation
   - Session Manager

4. **AWS Secrets Manager**
   - Database credentials
   - API keys
   - Synchronized between regions

## Flow Description

### Normal Operations
1. User requests → Route 53 (primary) → Primary Region ALB
2. ALB distributes → EC2 instances → RDS Primary
3. Data writes → S3 Primary → Cross-region replication to DR
4. RDS → Continuous replication to DR read replica

### Failover Scenario
1. Primary region failure detected by Route 53 health checks
2. Route 53 automatically updates DNS to point to DR region
3. DR RDS read replica promoted to primary (write-capable)
4. DR EC2 Auto Scaling scales up to production capacity
5. Users redirected → DR Region ALB → DR EC2 → DR RDS

### Recovery Scenario
1. Primary region restored and validated
2. Data synchronized from DR back to Primary
3. Route 53 weighted routing gradually shifts traffic back
4. DR region scaled down to warm standby state

## Diagram Layout Recommendations

### Layout Type: Multi-Region Side-by-Side
- **Left Half**: Primary Region (Production)
- **Right Half**: DR Region (Standby/Recovery)
- **Top Center**: Global services (Route 53, Backup, CloudTrail)
- **Bottom**: Networking (VPN, connectivity)

### Suggested Layers (Top to Bottom within each region)
1. External Users / DNS Layer (Route 53)
2. Network Edge (ALB, public subnets)
3. Application Tier (EC2 instances, private subnets)
4. Data Tier (RDS, S3, data subnets)
5. Infrastructure (VPC, monitoring, backups)

### Visual Elements
- **Dashed line** between regions showing VPN connection
- **Arrow indicators** for data replication (S3 CRR, RDS replication)
- **Health check symbols** on Route 53 to primary region
- **Failover arrows** showing DR activation path
- **Color coding** to differentiate active vs standby resources

### Color Coding
- **Green**: Active/production resources (primary region)
- **Yellow**: Warm standby resources (DR region)
- **Blue**: Storage services (S3, RDS, EBS)
- **Orange**: Compute services (EC2, Auto Scaling)
- **Red**: Global routing/failover (Route 53)
- **Gray**: Infrastructure (VPC, CloudWatch, backups)

## AWS Icon Guidelines
- Use official AWS Architecture Icons
- Maintain consistent icon sizing
- Include service names as labels
- Show data flow with directional arrows
- Indicate synchronous vs asynchronous replication

## Data Flow Arrows
- **Solid green arrows**: Active production traffic
- **Dashed red arrows**: DR failover path (inactive)
- **Blue arrows**: Data replication (S3 CRR, RDS replication)
- **Dotted arrows**: Health checks and monitoring
- **Bold arrows**: Primary user traffic flow

## Additional Notes
- Show VPC boundaries for both regions
- Indicate AZ distribution in primary region
- Include RTO/RPO callouts (e.g., "RTO: 15 minutes")
- Show replication lag indicators
- Add legends for arrow types and colors
- Indicate which resources scale during failover

## Export Requirements
- **Source File**: `architecture-diagram.drawio`
- **Output File**: `architecture-diagram.png`
- **Resolution**: 1920x1080 minimum
- **Format**: PNG with transparent background (optional)
- **DPI**: 300 for print quality

## References
- AWS Architecture Icons: https://aws.amazon.com/architecture/icons/
- AWS DR Whitepaper: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/
- Draw.io AWS shape library: Pre-installed in Draw.io desktop

## How to Replace with Official AWS Icons

### Quick Start Guide
1. **Download Draw.io Desktop**: https://github.com/jgraph/drawio-desktop/releases
2. **Open**: `architecture-diagram.drawio`
3. **Enable AWS Icons**: Click "More Shapes..." → Check "AWS 19" → Apply
4. **Replace Shapes**: Drag AWS icons from sidebar to replace colored rectangles
5. **Add Connections**: Use Connector tool (press 'C') to draw arrows between components
6. **Export PNG**: File > Export as > PNG (300 DPI) → Save to `../images/architecture-diagram.png`
7. **Regenerate Docs**: `python3 doc-tools/solution-doc-builder.py --path solutions/aws/cloud/disaster-recovery-web-application --force`

### AWS Icon Replacements for DR Solution

| Current Rectangle | Replace With | AWS Icon Name | Color |
|-------------------|--------------|---------------|-------|
| Blue EC2 boxes | EC2 instance icon | Amazon EC2 | Orange |
| Blue RDS boxes | RDS database icon | Amazon RDS | Blue |
| Blue S3 boxes | S3 bucket icon | Amazon S3 | Green/Orange |
| Blue ALB boxes | Load balancer icon | Elastic Load Balancing | Orange |
| Red Route 53 box | Route 53 icon | Amazon Route 53 | Purple |
| Gray CloudWatch box | CloudWatch icon | Amazon CloudWatch | Purple |
| Gray Backup box | Backup icon | AWS Backup | Purple |
| Purple VPN line | VPN icon/line | AWS VPN | Purple |

### Multi-Region Layout Tips
- **Primary Region** (left): Use green borders/backgrounds for active components
- **DR Region** (right): Use yellow/orange borders for standby components
- **Route 53** (top center): Position above both regions
- **Replication Arrows**: Use blue dashed arrows for data replication (RDS, S3)
- **Failover Path**: Use red dashed arrow from Route 53 to DR region
- **VPN Connection**: Use purple solid line between regions

### Connector Styles for DR
- **Green solid arrow**: Active traffic (Route 53 → Primary Region)
- **Blue dashed arrow**: Continuous replication (Primary RDS → DR RDS)
- **Red dashed arrow**: Failover path (Route 53 → DR Region - inactive)
- **Purple solid line**: VPN connection between regions

### References
- **AWS DR Patterns**: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/
- **AWS Architecture Icons**: https://aws.amazon.com/architecture/icons/
- **Multi-Region Reference**: https://aws.amazon.com/solutions/implementations/multi-region-infrastructure-deployment/
