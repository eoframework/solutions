# Configuration Templates - GitHub Actions Enterprise CI/CD Platform

## Overview
This document provides configuration templates and examples for deploying the GitHub Actions Enterprise CI/CD Platform across different environments and use cases.

## GitHub Actions Workflow Templates

### Basic CI/CD Workflow Template
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Run security scan
        uses: github/codeql-action/analyze@v2

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.meta.outputs.tags }}
      digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha
      
      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying ${{ needs.build.outputs.image }} to staging"
          # Add deployment commands here

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying ${{ needs.build.outputs.image }} to production"
          # Add deployment commands here
```

### Multi-Cloud Deployment Template
```yaml
name: Multi-Cloud Deployment
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image:
        required: true
        type: string

jobs:
  deploy-aws:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster ${{ inputs.environment }}-cluster \
            --service app-service \
            --force-new-deployment

  deploy-azure:
    runs-on: ubuntu-latest
    steps:
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Deploy to Azure Container Instances
        run: |
          az container create \
            --resource-group ${{ inputs.environment }}-rg \
            --name app-container \
            --image ${{ inputs.image }}

  deploy-gcp:
    runs-on: ubuntu-latest
    steps:
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy app-service \
            --image ${{ inputs.image }} \
            --region us-central1
```

## Self-Hosted Runner Configuration

### Linux Runner Setup
```bash
# Runner configuration script
#!/bin/bash
set -e

RUNNER_VERSION="2.311.0"
GITHUB_ORG="your-organization"
RUNNER_TOKEN="your-runner-token"

# Create runner user
sudo useradd -m -s /bin/bash github-runner

# Download and extract runner
cd /home/github-runner
sudo -u github-runner curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

sudo -u github-runner tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Configure runner
sudo -u github-runner ./config.sh \
  --url https://github.com/${GITHUB_ORG} \
  --token ${RUNNER_TOKEN} \
  --name $(hostname) \
  --labels "self-hosted,linux,x64" \
  --unattended

# Install as service
sudo ./svc.sh install github-runner
sudo ./svc.sh start
```

### Windows Runner Setup
```powershell
# PowerShell runner configuration
$RunnerVersion = "2.311.0"
$GitHubOrg = "your-organization"
$RunnerToken = "your-runner-token"

# Create directory and download runner
New-Item -ItemType Directory -Path "C:\actions-runner" -Force
Set-Location "C:\actions-runner"

Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$RunnerVersion/actions-runner-win-x64-$RunnerVersion.zip" -OutFile "actions-runner-win-x64-$RunnerVersion.zip"

Expand-Archive -Path "actions-runner-win-x64-$RunnerVersion.zip" -DestinationPath "."

# Configure runner
.\config.cmd --url "https://github.com/$GitHubOrg" --token "$RunnerToken" --name "$env:COMPUTERNAME" --labels "self-hosted,windows,x64" --unattended

# Install as service
.\svc.sh install
.\svc.sh start
```

## Organization Settings Templates

### Security Policy Configuration
```yaml
# Organization security settings
security:
  dependency_graph: enabled
  vulnerability_alerts: enabled
  security_advisories: enabled
  secret_scanning: enabled
  secret_scanning_push_protection: enabled
  
  branch_protection:
    enforce_admins: true
    required_status_checks:
      strict: true
      contexts:
        - "CI/CD Pipeline / test"
        - "CI/CD Pipeline / build"
    required_pull_request_reviews:
      required_approving_review_count: 2
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
```

### Runner Group Configuration
```yaml
# Runner group settings
runner_groups:
  production:
    name: "Production Runners"
    visibility: "selected"
    allows_public_repositories: false
    runners:
      - "prod-runner-01"
      - "prod-runner-02"
    
  development:
    name: "Development Runners"
    visibility: "all"
    allows_public_repositories: true
    runners:
      - "dev-runner-01"
      - "dev-runner-02"
```

## Environment Configuration Templates

### Development Environment
```yaml
# Development environment settings
environment:
  name: "development"
  protection_rules:
    wait_timer: 0
    reviewers: []
  variables:
    ENVIRONMENT: "dev"
    LOG_LEVEL: "debug"
    DATABASE_URL: "postgres://dev-db:5432/app"
  secrets:
    API_KEY: "${{ secrets.DEV_API_KEY }}"
    DATABASE_PASSWORD: "${{ secrets.DEV_DB_PASSWORD }}"
```

### Production Environment
```yaml
# Production environment settings
environment:
  name: "production"
  protection_rules:
    wait_timer: 30
    reviewers:
      - type: "user"
        id: "admin-user"
      - type: "team"
        id: "release-team"
  variables:
    ENVIRONMENT: "prod"
    LOG_LEVEL: "info"
    DATABASE_URL: "postgres://prod-db:5432/app"
  secrets:
    API_KEY: "${{ secrets.PROD_API_KEY }}"
    DATABASE_PASSWORD: "${{ secrets.PROD_DB_PASSWORD }}"
```

## Integration Templates

### OIDC Provider Configuration
```yaml
# OIDC configuration for cloud providers
aws:
  role_arn: "arn:aws:iam::123456789012:role/GitHubActions"
  role_session_name: "GitHubActions"
  audience: "sts.amazonaws.com"

azure:
  client_id: "12345678-1234-1234-1234-123456789012"
  tenant_id: "87654321-4321-4321-4321-210987654321"
  subscription_id: "11111111-2222-3333-4444-555555555555"

gcp:
  service_account: "github-actions@project-id.iam.gserviceaccount.com"
  workload_identity_provider: "projects/123456789/locations/global/workloadIdentityPools/github/providers/github"
```

### Package Registry Configuration
```yaml
# Package publishing configuration
packages:
  npm:
    registry: "https://npm.pkg.github.com"
    scope: "@your-organization"
    
  docker:
    registry: "ghcr.io"
    namespace: "your-organization"
    
  maven:
    repository: "https://maven.pkg.github.com/your-organization"
    group_id: "com.yourorganization"
```

## Monitoring and Alerting Templates

### Workflow Monitoring
```yaml
# Monitoring workflow template
name: Workflow Monitoring
on:
  schedule:
    - cron: '*/15 * * * *'  # Every 15 minutes

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - name: Check workflow status
        run: |
          # Check for failed workflows in last hour
          gh api "/repos/${{ github.repository }}/actions/runs" \
            --jq '.workflow_runs[] | select(.created_at > (now - 3600) and .conclusion == "failure")' \
            > failed_workflows.json
          
          if [ -s failed_workflows.json ]; then
            echo "Failed workflows detected"
            # Send alert
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Performance Metrics
```yaml
# Performance monitoring
name: Performance Metrics
on:
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types: [completed]

jobs:
  metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Collect metrics
        run: |
          # Calculate workflow duration
          duration=$(( ${{ github.event.workflow_run.updated_at }} - ${{ github.event.workflow_run.created_at }} ))
          
          # Send metrics to monitoring system
          curl -X POST "${{ secrets.METRICS_ENDPOINT }}" \
            -H "Content-Type: application/json" \
            -d "{\"workflow\": \"${{ github.event.workflow_run.name }}\", \"duration\": $duration}"
```

## Customization Guidelines

### Environment-Specific Configuration
- Development: Relaxed security policies, verbose logging
- Staging: Production-like environment with testing data
- Production: Strict security policies, minimal logging

### Organization-Specific Settings
- Runner labels should reflect infrastructure capabilities
- Environment protection rules should align with change management processes
- Secret management should integrate with enterprise key management systems

### Scaling Considerations
- Use runner groups to organize runners by purpose or team
- Implement auto-scaling for cloud-based runners
- Configure appropriate resource limits and quotas

## Best Practices

### Security
- Use OIDC providers instead of long-lived credentials
- Implement least-privilege access for service accounts
- Regular rotation of secrets and tokens

### Performance
- Use dependency caching to reduce build times
- Implement parallel job execution where possible
- Optimize Docker builds with multi-stage builds

### Reliability
- Implement retry logic for flaky tests
- Use matrix builds for cross-platform compatibility
- Configure appropriate timeout values for jobs