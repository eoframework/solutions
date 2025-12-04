#!/bin/bash
set -e

#------------------------------------------------------------------------------
# GitHub Actions Self-Hosted Runner Setup Script - Linux
#------------------------------------------------------------------------------
# This script:
# 1. Installs required dependencies
# 2. Retrieves GitHub token from Secrets Manager
# 3. Downloads and configures the GitHub Actions runner
# 4. Registers as an organization runner
#------------------------------------------------------------------------------

# Variables from Terraform
GITHUB_ORG="${github_organization}"
RUNNER_NAME_PREFIX="${runner_name_prefix}"
RUNNER_LABELS="${runner_labels}"
SECRET_ARN="${secret_arn}"
AWS_REGION="${aws_region}"

# Generate unique runner name
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
RUNNER_NAME="$${RUNNER_NAME_PREFIX}-$${INSTANCE_ID}"

# Install dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y \
    curl \
    jq \
    unzip \
    docker.io \
    git \
    build-essential \
    awscli

# Start Docker
systemctl enable docker
systemctl start docker

# Create runner user
useradd -m -s /bin/bash runner || true
usermod -aG docker runner

# Get GitHub token from Secrets Manager
echo "Retrieving GitHub token from Secrets Manager..."
GITHUB_TOKEN=$(aws secretsmanager get-secret-value \
    --secret-id "$${SECRET_ARN}" \
    --region "$${AWS_REGION}" \
    --query SecretString \
    --output text)

# Get runner registration token
echo "Getting runner registration token..."
REG_TOKEN=$(curl -s -X POST \
    -H "Authorization: token $${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$${GITHUB_ORG}/actions/runners/registration-token" \
    | jq -r .token)

# Create runner directory
RUNNER_DIR="/home/runner/actions-runner"
mkdir -p $${RUNNER_DIR}
cd $${RUNNER_DIR}

# Download latest runner
echo "Downloading GitHub Actions runner..."
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/v//')
curl -o actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz -L \
    "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"
tar xzf actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
rm actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz

# Set ownership
chown -R runner:runner $${RUNNER_DIR}

# Configure runner
echo "Configuring runner..."
sudo -u runner ./config.sh \
    --url "https://github.com/$${GITHUB_ORG}" \
    --token "$${REG_TOKEN}" \
    --name "$${RUNNER_NAME}" \
    --labels "$${RUNNER_LABELS}" \
    --unattended \
    --replace

# Install and start service
echo "Installing runner service..."
./svc.sh install runner
./svc.sh start

echo "GitHub Actions runner setup complete!"
