#!/bin/bash
# AAP Hub Node Bootstrap
set -e

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
dnf update -y

# Install required packages
dnf install -y python3 python3-pip podman

# Enable and start SSM agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Hub bootstrap complete"
