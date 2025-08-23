# Azure Virtual Desktop Prerequisites

## Azure Subscription Requirements
- Active Azure subscription with sufficient credits/billing
- Appropriate permissions to create and manage resources
- Virtual Desktop Administrator role or equivalent permissions

## Identity and Directory Services
- Azure Active Directory tenant configured
- User accounts synchronized or created in Azure AD
- Groups configured for AVD access management
- Conditional Access policies (if required)

## Networking Infrastructure
- Virtual Network (VNet) with appropriate address space
- Subnets for session hosts and supporting services
- Network Security Groups (NSGs) configured
- DNS resolution configured
- Outbound internet connectivity for session hosts

## Windows Licensing
- Windows 10/11 Enterprise or Windows Server licenses
- Multi-tenant hosting rights for shared environments
- Microsoft 365 licenses (optional but recommended)
- Remote Desktop Services (RDS) Client Access Licenses

## Storage Requirements
- Azure Files or Azure NetApp Files for FSLogix profiles
- Storage accounts with appropriate performance tiers
- File shares configured with proper permissions
- Sufficient storage capacity for user profiles

## Network Connectivity
- Express Route or VPN connectivity (for hybrid scenarios)
- Bandwidth requirements: minimum 1.5 Mbps per user
- Network latency under 150ms for optimal performance
- Quality of Service (QoS) policies configured

## Management and Monitoring
- Azure Log Analytics workspace
- Azure Monitor configured
- PowerShell execution policy configured
- Remote management tools and access

## Security Prerequisites
- Certificate management for secure connections
- Multi-factor authentication configured
- Security baselines and compliance requirements
- Antivirus and endpoint protection solutions

## Resource Capacity Planning
- VM sizing and performance requirements
- Storage IOPS and throughput calculations
- Network bandwidth and concurrent user planning
- Regional availability and disaster recovery considerations