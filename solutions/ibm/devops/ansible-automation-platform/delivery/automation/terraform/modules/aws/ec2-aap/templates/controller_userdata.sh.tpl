#!/bin/bash
# AAP Controller Node Bootstrap
set -e

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
dnf update -y

# Install required packages
dnf install -y python3 python3-pip

# Enable and start SSM agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Controller bootstrap complete"
