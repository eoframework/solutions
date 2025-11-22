# GitHub Actions Enterprise CI/CD - Architecture Diagrams

## Diagram Instructions

### Overview
This directory contains architecture diagrams for the GitHub Actions Enterprise CI/CD solution, showing the pipeline workflow and deployment architecture.

### Required Diagrams

#### 1. architecture-diagram.drawio
**Purpose:** Primary architecture diagram showing GitHub Actions CI/CD workflow with self-hosted runners

**Components to Include:**

**Developer Workflow (Left Side):**
- Developer workstation with code editor
- Git commit and push to GitHub
- Pull request creation

**GitHub Platform (Center-Left):**
- GitHub Enterprise Cloud logo/header
- Repository with code
- .github/workflows directory (YAML files)
- Pull request interface

**GitHub Actions Orchestration (Center):**
- **Workflow Trigger Box:**
  - Push events
  - Pull request events
  - Scheduled (cron)
  - Manual (workflow_dispatch)
- **Workflow Jobs Box:**
  - Build job
  - Test job
  - Security scan job
  - Deploy job
- **Matrix Strategy:**
  - Multiple OS (Linux, Windows, macOS)
  - Multiple versions (Node 16, 18, 20)

**Runner Infrastructure (Center-Right):**
- **Self-Hosted Runners in AWS VPC:**
  - EC2 Auto Scaling Group
  - 20x c5.2xlarge instances
  - Linux and Windows runners
  - Runner labels (self-hosted, linux, x64)
  - Health monitoring
- **GitHub-Hosted Runners (Alternate):**
  - ubuntu-latest
  - windows-latest
  - macos-latest

**Build and Test (Right Side):**
- **Build Steps:**
  - Checkout code
  - Setup environment (Node.js, Python, .NET)
  - Install dependencies
  - Compile/build
  - Run tests
  - Build artifacts
- **Quality Gates:**
  - Unit tests
  - Code coverage (Codecov)
  - SonarQube analysis
  - Security scanning (CodeQL)

**Artifact Storage (Bottom-Center):**
- GitHub Packages
- Docker images
- npm packages
- Maven JARs
- NuGet packages

**Deployment (Bottom-Right):**
- **OIDC Authentication:**
  - GitHub OIDC provider
  - AWS IAM role assumption
  - Azure workload identity
  - No static credentials
- **Deployment Targets:**
  - AWS EC2 instances
  - AWS ECS clusters
  - AWS EKS (Kubernetes)
  - AWS Lambda functions
  - S3 + CloudFront (static sites)
- **Environment Protection:**
  - Development (auto-deploy)
  - Staging (approval required)
  - Production (approval + change window)

**Monitoring and Notifications (Bottom):**
- Datadog/New Relic APM
- CloudWatch metrics
- Slack/Teams notifications
- PagerDuty alerts
- Deployment dashboard

**Data Flow Arrows:**
1. Developer pushes code → GitHub repository
2. Push event → Triggers workflow
3. Workflow → Assigns job to runner
4. Runner → Executes build/test/scan steps
5. Build artifacts → Push to GitHub Packages/ECR
6. Quality gates pass → Trigger deployment
7. OIDC authentication → AWS/Azure
8. Deployment → Target environment
9. Notifications → Slack/Teams
10. Metrics → Monitoring dashboard

**Color Scheme:**
- GitHub colors: Black (#24292e), Purple (#6f42c1), Blue (#0366d6)
- AWS: Orange (#FF9900) for AWS services
- Success: Green (#28a745) for passed builds
- Failure: Red (#d73a49) for failed builds
- Warning: Orange (#fb8532) for warnings

**Labels and Annotations:**
- "GitOps" badge
- "Infrastructure as Code" label
- "Keyless Authentication (OIDC)" callout
- "10x Faster Deployments" metric
- "60% Cost Reduction" badge

**Reusable Workflows (Callout Box):**
- .github/workflows/templates/
- dotnet-build.yml
- node-deploy.yml
- docker-build-push.yml
- terraform-apply.yml

#### 2. cicd-workflow.drawio (Optional - if time permits)
**Purpose:** Detailed CI/CD workflow from commit to production deployment

**Workflow Stages:**
1. Code Commit → Feature branch
2. Pull Request → Code review
3. Automated Checks → Build + Test + Scan
4. Merge to Main → Production pipeline triggered
5. Build Artifacts → Docker image + packages
6. Deploy to Dev → Automatic
7. Deploy to Staging → Approval required
8. Smoke Tests → Automated validation
9. Deploy to Production → Change window + approval
10. Health Check → Monitoring validation
11. Success/Rollback → Based on health metrics

### Diagram Creation Instructions

**Using draw.io:**
1. Open https://app.diagrams.net/
2. Create new diagram named `architecture-diagram.drawio`
3. Use AWS Architecture icons and GitHub-themed shapes
4. Follow the component layout described above
5. Use consistent colors per the color scheme
6. Add clear labels and data flow arrows
7. Save as `architecture-diagram.drawio` in this directory
8. Export as `architecture-diagram.png` (300 DPI, transparent background)

**Style Guidelines:**
- Use rounded rectangles for services/components
- Use cylinders for artifact storage
- Use cloud shapes for AWS/Azure services
- Use arrows with labels for data flow
- Use dashed lines for OIDC federation
- Use different colors to distinguish component types
- Include GitHub and AWS logos
- Keep text readable (minimum 12pt font)
- Maintain consistent spacing and alignment

**Technical Accuracy:**
- Show GitHub Actions as YAML-based workflow orchestration
- Differentiate between GitHub-hosted and self-hosted runners
- Show OIDC as federated authentication (not static credentials)
- Include environment protection rules and approval gates
- Display matrix builds for multi-platform testing
- Show reusable workflows as centralized templates
- Include monitoring and notification integration points

**Reference Examples:**
- AWS IDP architecture diagrams in `/solutions/aws/ai/intelligent-document-processing/assets/diagrams/`
- GitHub Actions documentation: https://docs.github.com/en/actions
- Self-hosted runners: https://docs.github.com/en/actions/hosting-your-own-runners
- OIDC with AWS: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

### Files in This Directory

After creation, this directory should contain:
- `README.md` (this file)
- `architecture-diagram.drawio` - Editable draw.io source
- `architecture-diagram.png` - Exported PNG for documentation
- `cicd-workflow.drawio` (optional) - Detailed workflow diagram
- `cicd-workflow.png` (optional) - Exported PNG

### Usage in Documentation

The architecture diagram is referenced in:
- `presales/raw/solution-briefing.md` - Slide 4 (Solution Overview)
- `presales/README.md` - Solution overview section
- `README.md` - Main solution documentation

**Markdown Reference:**
```markdown
![Architecture Diagram](assets/diagrams/architecture-diagram.png)
```

**Relative Path from presales/raw/:**
```markdown
![Architecture Diagram](../../assets/diagrams/architecture-diagram.png)
```

---

**Last Updated:** 2025-11-22
**Solution:** GitHub Actions Enterprise CI/CD
**Status:** Architecture diagrams pending creation
