# AWS Intelligent Document Processing - Architecture Diagram Requirements

## Overview
This document specifies the components and layout for the AWS IDP solution architecture diagram.

## Required Components

### 1. Document Ingestion Layer
- **Amazon S3 (Input Bucket)**
  - Raw document storage
  - Supported formats: PDF, JPEG, PNG, TIFF
  - Event triggers for processing workflow

### 2. Document Processing Layer
- **AWS Lambda (Orchestration)**
  - Document workflow orchestration
  - Event-driven processing
  - Error handling and retries

- **AWS Step Functions**
  - Multi-step workflow coordination
  - State management
  - Conditional processing logic

- **Amazon Textract**
  - Document text extraction
  - Form data extraction
  - Table data extraction

- **Amazon Comprehend**
  - Entity recognition (people, organizations, locations)
  - Sentiment analysis (optional)
  - Key phrase extraction

### 3. Data Layer
- **Amazon DynamoDB**
  - Document metadata storage
  - Job tracking and status
  - Extraction results index

- **Amazon S3 (Output Bucket)**
  - Processed document archive
  - Extracted data (JSON/CSV)
  - Audit logs

### 4. API & Integration Layer
- **Amazon API Gateway**
  - RESTful API endpoints
  - Document submission endpoint
  - Results retrieval endpoint
  - Webhook callbacks

- **Amazon SQS**
  - Asynchronous processing queue
  - Message-based workflow coordination
  - Dead-letter queue for failed items

- **Amazon SNS**
  - Processing notifications
  - Status updates
  - Error alerts

### 5. Caching & Performance
- **Amazon ElastiCache (Redis)**
  - Document metadata caching
  - Session state management
  - Frequently accessed data

### 6. Human Review (Optional)
- **Amazon Augmented AI (A2I)**
  - Human-in-the-loop review
  - Low-confidence predictions
  - Quality assurance workflow

### 7. Monitoring & Operations
- **Amazon CloudWatch**
  - Centralized logging
  - Custom metrics
  - Dashboards and alarms

- **AWS Secrets Manager**
  - API keys and credentials
  - Database connection strings
  - Third-party service credentials

### 8. Security & Networking
- **Amazon VPC**
  - Network isolation
  - Private subnets for Lambda/DynamoDB
  - Public subnets for API Gateway

- **NAT Gateway**
  - Outbound internet access from private subnets

- **Security Groups**
  - Inbound/outbound traffic control
  - Least-privilege access

## Flow Description

### Processing Workflow
1. **Document Upload** → S3 (Input) triggers Lambda
2. **Workflow Initiation** → Step Functions starts state machine
3. **Text Extraction** → Textract processes document
4. **Entity Recognition** → Comprehend analyzes extracted text
5. **Data Storage** → Results stored in DynamoDB + S3 (Output)
6. **Optional Human Review** → Low-confidence items routed to A2I
7. **API Response** → Results available via API Gateway
8. **Notifications** → SNS sends completion alerts

## Diagram Layout Recommendations

### Layout Type: Hierarchical / Left-to-Right Flow
- **Left Side**: External systems / users
- **Center**: AWS services (layered)
- **Right Side**: Data storage / outputs

### Suggested Layers (Top to Bottom)
1. External Users / Systems
2. API & Ingestion (API Gateway, S3 Input)
3. Processing (Lambda, Step Functions, Textract, Comprehend)
4. Data & Storage (DynamoDB, S3 Output, ElastiCache)
5. Infrastructure (VPC, Security, Monitoring)

### Color Coding
- **Orange**: Compute services (Lambda, Step Functions)
- **Blue**: Storage services (S3, DynamoDB)
- **Purple**: AI/ML services (Textract, Comprehend, A2I)
- **Red**: Integration services (API Gateway, SQS, SNS)
- **Green**: Caching/Performance (ElastiCache)
- **Gray**: Infrastructure (VPC, CloudWatch, Secrets Manager)

## AWS Icon Guidelines
- Use official AWS Architecture Icons
- Maintain consistent icon sizing
- Include service names as labels
- Show data flow with directional arrows
- Indicate synchronous vs asynchronous flows

## Data Flow Arrows
- **Solid arrows**: Synchronous API calls
- **Dashed arrows**: Asynchronous messages (SQS/SNS)
- **Dotted arrows**: Event triggers (S3 → Lambda)
- **Bold arrows**: Primary data flow
- **Thin arrows**: Secondary/optional flows

## Additional Notes
- Show VPC boundary as dashed rectangle
- Indicate public vs private subnets
- Include availability zone representation
- Show encryption at rest/in transit icons
- Add legends for arrow types and color coding

## Export Requirements
- **Source File**: `architecture-diagram.drawio`
- **Output File**: `architecture-diagram.png`
- **Resolution**: 1920x1080 minimum
- **Format**: PNG with transparent background (optional)
- **DPI**: 300 for print quality

## How to Replace with Official AWS Icons

### Step 1: Open in Draw.io Desktop
```bash
# Download Draw.io desktop app
# https://github.com/jgraph/drawio-desktop/releases

# Open the file
drawio architecture-diagram.drawio
```

### Step 2: Access AWS Icon Library
1. In Draw.io, click **"More Shapes..."** in the left sidebar
2. Scroll to **"Networking"** section
3. Check **"AWS 19"** or **"AWS 17"** (latest AWS architecture icons)
4. Click **"Apply"**

Alternatively:
- Click **File > Open Library > AWS**
- Select the AWS icon library

### Step 3: Replace Basic Shapes with AWS Icons
The current diagram uses colored rectangles. Replace them with official AWS icons:

**For Each Component:**
1. Find the AWS icon in the left sidebar (e.g., "Amazon S3", "AWS Lambda")
2. Drag the AWS icon onto the canvas
3. Position it to replace the colored rectangle
4. Delete the old rectangle
5. Add text label below the icon using Draw.io's text tool

**Example Replacements:**
- Blue "Amazon S3" boxes → AWS S3 bucket icon (orange/green)
- Orange "AWS Lambda" boxes → AWS Lambda icon (orange)
- Purple "Amazon Textract" boxes → Amazon Textract icon (purple)
- Green "Amazon DynamoDB" boxes → DynamoDB icon (blue)
- Red "API Gateway" boxes → API Gateway icon (purple/red)

### Step 4: Use AWS Color Scheme
Official AWS Architecture Icons use standardized colors:
- **Compute**: Orange (EC2, Lambda, ECS)
- **Storage**: Green (S3, EBS, EFS)
- **Database**: Blue (RDS, DynamoDB, Redshift)
- **Analytics/AI/ML**: Purple (Textract, Comprehend, SageMaker)
- **Integration**: Pink/Red (SQS, SNS, EventBridge)
- **Security**: Red (IAM, Secrets Manager, KMS)
- **Management**: Purple (CloudWatch, Systems Manager)

### Step 5: Add Connections and Flows
1. Use **Connector** tool (or press 'C')
2. Click and drag from one icon to another
3. Choose arrow style:
   - **Solid line with arrow**: Synchronous/direct API calls
   - **Dashed line with arrow**: Asynchronous/event-driven
   - **Thick line**: Primary data flow
   - **Thin line**: Secondary flow

4. Add labels to arrows describing the flow:
   - "Document uploaded"
   - "Textract API call"
   - "Results stored"

### Step 6: Group Related Components
1. Draw **rectangles** to group related components (like VPC boundaries)
2. Right-click rectangle → **Send to Back**
3. Use light colors for grouping (e.g., light blue for VPC)
4. Add labels like "VPC", "Private Subnet", "Public Subnet"

### Step 7: Export as PNG
1. Select all (Ctrl+A / Cmd+A)
2. **File > Export as > PNG**
3. Settings:
   - Resolution: 300 DPI
   - Transparent background: Optional
   - Border width: 10px
4. Save to: `../images/architecture-diagram.png`

### Step 8: Regenerate Documents
After creating the diagram:
```bash
cd /path/to/eof-tools
python3 doc-tools/solution-doc-builder.py --path solutions/aws/ai/intelligent-document-processing --force
```

## AWS Icon Quick Reference

| Component | AWS Icon Name | Color | Category |
|-----------|--------------|-------|----------|
| Amazon S3 | AWS Simple Storage Service | Green/Orange | Storage |
| AWS Lambda | AWS Lambda | Orange | Compute |
| Amazon Textract | Amazon Textract | Purple | AI/ML |
| Amazon Comprehend | Amazon Comprehend | Purple | AI/ML |
| Amazon DynamoDB | Amazon DynamoDB | Blue | Database |
| API Gateway | Amazon API Gateway | Purple/Pink | Integration |
| Amazon SQS | Amazon Simple Queue Service | Pink | Integration |
| Amazon SNS | Amazon Simple Notification Service | Pink | Integration |
| AWS Step Functions | AWS Step Functions | Pink | Integration |
| ElastiCache | Amazon ElastiCache | Blue | Database |
| CloudWatch | Amazon CloudWatch | Purple | Management |
| VPC | Amazon VPC | Purple | Networking |
| Secrets Manager | AWS Secrets Manager | Red | Security |

## References
- **AWS Architecture Icons**: https://aws.amazon.com/architecture/icons/
- **AWS Icon Asset Package**: https://aws.amazon.com/architecture/icons/ (Download ZIP)
- **Draw.io AWS Library**: Pre-installed in Draw.io desktop
- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/
- **AWS Architecture Center**: https://aws.amazon.com/architecture/
- **Reference Architectures**: https://aws.amazon.com/architecture/reference-architecture-diagrams/
