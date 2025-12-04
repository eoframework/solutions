#!/bin/bash
# AAP Execution Node Bootstrap
set -e

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
dnf update -y

# Install required packages for Ansible execution
dnf install -y python3 python3-pip git

# Enable and start SSM agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Execution node bootstrap complete"
