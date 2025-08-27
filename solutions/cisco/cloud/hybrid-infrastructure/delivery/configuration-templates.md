# Cisco Hybrid Infrastructure Configuration Templates

## Overview

This document provides pre-configured templates and baseline configurations for deploying Cisco Hybrid Cloud Infrastructure components. These templates are designed to accelerate deployment while ensuring consistency and best practices.

## Template Categories

### 1. Cisco HyperFlex Templates

#### HyperFlex Cluster Profile Template
```yaml
# HyperFlex Cluster Configuration
cluster_profile:
  name: "HX-Cluster-{{ site_code }}"
  description: "Production HyperFlex cluster for {{ customer_name }}"
  
  # Hardware Configuration
  hardware:
    server_model: "HXAF220C-M5SX"
    node_count: 4
    compute_nodes: 2
    storage_nodes: 4
    
  # Network Configuration
  network:
    management_vlan: 100
    vmotion_vlan: 101
    storage_vlan: 102
    data_vlans: [200, 201, 202]
    
    mgmt_ip_pool:
      start: "192.168.100.10"
      end: "192.168.100.50"
      gateway: "192.168.100.1"
      netmask: "255.255.255.0"
      dns_servers: ["8.8.8.8", "8.8.4.4"]
      
  # Storage Configuration
  storage:
    datastore_policy: "Hybrid"
    compression: enabled
    deduplication: enabled
    encryption: enabled
    replication_factor: 3
    
  # VMware Configuration
  vmware:
    vcenter_integration: enabled
    cluster_name: "HX-Compute-Cluster"
    datacenter_name: "{{ customer_name }}-DC"
    distributed_switch: "HX-VDS"
```

#### HyperFlex Security Profile
```yaml
security_profile:
  name: "HX-Security-{{ environment }}"
  
  # Authentication
  authentication:
    local_auth: enabled
    ldap_integration:
      enabled: true
      server: "{{ ldap_server }}"
      base_dn: "{{ ldap_base_dn }}"
      
  # Encryption
  encryption:
    data_at_rest: enabled
    data_in_transit: enabled
    key_management: "local"  # or "kmip"
    
  # Access Control
  access_control:
    role_based_access: enabled
    audit_logging: enabled
    session_timeout: 30
```

### 2. Cisco ACI Templates

#### Tenant Configuration Template
```yaml
# ACI Tenant Configuration
tenant:
  name: "{{ customer_name }}-Prod"
  description: "Production tenant for {{ customer_name }}"
  
  # VRF Configuration
  vrfs:
    - name: "Prod-VRF"
      description: "Production VRF"
      enforcement: "enforced"
      
  # Bridge Domains
  bridge_domains:
    - name: "Web-BD"
      vrf: "Prod-VRF"
      subnet: "10.1.1.1/24"
      scope: ["public", "shared"]
      
    - name: "App-BD"
      vrf: "Prod-VRF"
      subnet: "10.1.2.1/24"
      scope: ["private"]
      
    - name: "DB-BD"
      vrf: "Prod-VRF"
      subnet: "10.1.3.1/24"
      scope: ["private"]
      
  # Application Profiles
  application_profiles:
    - name: "3Tier-App"
      description: "Three-tier application profile"
      
      epgs:
        - name: "Web-EPG"
          bridge_domain: "Web-BD"
          physical_domains: ["{{ phys_domain }}"]
          
        - name: "App-EPG"
          bridge_domain: "App-BD"
          physical_domains: ["{{ phys_domain }}"]
          
        - name: "DB-EPG"
          bridge_domain: "DB-BD"
          physical_domains: ["{{ phys_domain }}"]
```

#### ACI Contract Template
```yaml
# Security Contracts
contracts:
  - name: "Web-to-App-Contract"
    description: "Allow web tier to app tier communication"
    scope: "tenant"
    
    subjects:
      - name: "HTTP-Subject"
        filters:
          - name: "HTTP-Filter"
            entries:
              - name: "HTTP-80"
                ether_type: "ip"
                protocol: "tcp"
                destination_port: "80"
                
              - name: "HTTPS-443"
                ether_type: "ip"
                protocol: "tcp"
                destination_port: "443"
                
  - name: "App-to-DB-Contract"
    description: "Allow app tier to database communication"
    scope: "tenant"
    
    subjects:
      - name: "DB-Subject"
        filters:
          - name: "MySQL-Filter"
            entries:
              - name: "MySQL-3306"
                ether_type: "ip"
                protocol: "tcp"
                destination_port: "3306"
```

### 3. Cisco Intersight Templates

#### Server Profile Template
```yaml
# Intersight Server Profile
server_profile:
  name: "HX-Node-{{ node_number }}"
  description: "HyperFlex node server profile"
  
  # BIOS Policy
  bios_policy:
    name: "HX-BIOS-Policy"
    settings:
      intel_vt: "enabled"
      intel_vtd: "enabled"
      sr_iov: "enabled"
      cpu_performance: "HPC"
      
  # Boot Policy
  boot_policy:
    name: "HX-Boot-Policy"
    boot_mode: "Uefi"
    boot_devices:
      - device_type: "virtual_media"
        name: "CIMC-DVD"
        
      - device_type: "local_disk"
        name: "Boot-SSD"
        slot: "MRAID"
        
  # Network Configuration
  lan_connectivity:
    name: "HX-LAN-Policy"
    vnics:
      - name: "eth0"
        placement:
          id: "MLOM"
          slot_id: 1
        fabric_failover: enabled
        
      - name: "eth1"
        placement:
          id: "MLOM"
          slot_id: 2
        fabric_failover: enabled
```

#### Infrastructure Service Profile
```yaml
# Infrastructure Service Profile
infra_service_profile:
  name: "HX-Infra-{{ cluster_name }}"
  
  # Network Time Protocol
  ntp_policy:
    enabled: true
    ntp_servers:
      - "pool.ntp.org"
      - "time.cisco.com"
      
  # DNS Configuration
  dns_policy:
    dns_servers:
      - "8.8.8.8"
      - "8.8.4.4"
    search_domains:
      - "{{ customer_domain }}"
      
  # SNMP Configuration
  snmp_policy:
    enabled: true
    version: "v3"
    community: "{{ snmp_community }}"
    trap_destinations:
      - host: "{{ monitoring_server }}"
        port: 162
```

### 4. VMware vSphere Templates

#### vCenter Deployment Template
```yaml
# vCenter Server Appliance Configuration
vcenter_deployment:
  appliance:
    name: "vcsa-{{ site_code }}"
    deployment_size: "medium"  # tiny, small, medium, large
    storage_size: "default"   # default, lstorage, xlstorage
    
  network:
    ip_family: "ipv4"
    mode: "static"
    ip: "{{ vcenter_ip }}"
    dns_servers: ["{{ primary_dns }}", "{{ secondary_dns }}"]
    prefix: "24"
    gateway: "{{ default_gateway }}"
    
  sso:
    domain_name: "{{ sso_domain }}"
    password: "{{ sso_password }}"
    site_name: "{{ site_name }}"
    
  ceip: false  # Customer Experience Improvement Program
```

#### Distributed Switch Template
```yaml
# vSphere Distributed Switch Configuration
distributed_switch:
  name: "HX-VDS-{{ cluster_name }}"
  version: "7.0.0"
  
  uplinks:
    - name: "Uplink1"
    - name: "Uplink2"
    
  port_groups:
    - name: "VM-Network-{{ vlan_id }}"
      vlan_type: "vlan"
      vlan_id: "{{ vlan_id }}"
      ports: 128
      
    - name: "vMotion"
      vlan_type: "vlan"
      vlan_id: 101
      ports: 32
      
    - name: "Storage"
      vlan_type: "vlan"
      vlan_id: 102
      ports: 32
      
  advanced_settings:
    max_mtu: 9000
    multicast_filtering: "basic"
    load_balancing: "loadbalance_srcid"
```

### 5. Security Templates

#### Baseline Security Configuration
```yaml
# Baseline Security Settings
security_baseline:
  name: "Enterprise-Security-Baseline"
  
  # Password Policy
  password_policy:
    min_length: 12
    complexity: true
    expiration_days: 90
    history_count: 12
    lockout_threshold: 3
    lockout_duration: 15
    
  # Network Security
  network_security:
    firewall_rules:
      - name: "Allow-Management"
        source: "{{ management_network }}"
        destination: "any"
        ports: ["22", "80", "443"]
        action: "allow"
        
      - name: "Allow-vCenter"
        source: "{{ vcenter_network }}"
        destination: "{{ hx_mgmt_network }}"
        ports: ["443", "902", "903"]
        action: "allow"
        
    # SSL/TLS Configuration
    tls_settings:
      min_version: "1.2"
      cipher_suites: "strong"
      certificate_validation: true
      
  # Audit and Logging
  audit_policy:
    auth_events: enabled
    admin_actions: enabled
    config_changes: enabled
    performance_events: disabled
    retention_days: 365
```

### 6. Monitoring Templates

#### SNMP Configuration Template
```yaml
# SNMP Monitoring Configuration
snmp_config:
  version: "v3"
  
  # SNMPv3 Users
  users:
    - username: "{{ snmp_user }}"
      auth_protocol: "SHA"
      auth_password: "{{ snmp_auth_password }}"
      priv_protocol: "AES128"
      priv_password: "{{ snmp_priv_password }}"
      
  # Trap Destinations
  trap_destinations:
    - host: "{{ monitoring_server_1 }}"
      port: 162
      community: "{{ trap_community }}"
      
    - host: "{{ monitoring_server_2 }}"
      port: 162
      community: "{{ trap_community }}"
      
  # MIB Access
  access_control:
    - view: "system"
      oid: "1.3.6.1.2.1.1"
      access: "read"
      
    - view: "interfaces"
      oid: "1.3.6.1.2.1.2"
      access: "read"
```

## Template Usage Guidelines

### Variable Substitution
All templates use the following variable format: `{{ variable_name }}`

Common variables:
- `{{ customer_name }}` - Customer organization name
- `{{ site_code }}` - Site location code
- `{{ environment }}` - Environment type (prod, dev, test)
- `{{ cluster_name }}` - Cluster identifier
- `{{ vlan_id }}` - VLAN identifier
- `{{ ip_address }}` - IP address assignment

### Customization Process

1. **Template Selection** - Choose appropriate templates for deployment
2. **Variable Definition** - Define all required variables in variables file
3. **Template Validation** - Validate syntax and completeness
4. **Environment Testing** - Test templates in lab environment
5. **Production Deployment** - Deploy validated templates

### Best Practices

#### Template Management
- Version control all templates
- Document all customizations
- Test templates before production use
- Maintain template update procedures

#### Security Considerations
- Encrypt sensitive variables
- Use secure variable storage
- Implement access controls
- Regular security reviews

#### Validation Procedures
- Syntax validation
- Dependency checking
- Compatibility verification
- Performance impact assessment

## Template Maintenance

### Update Procedures
1. **Change Request** - Submit formal change request
2. **Impact Analysis** - Assess impact on existing deployments
3. **Testing** - Validate updates in test environment
4. **Documentation** - Update template documentation
5. **Deployment** - Roll out updated templates

### Version Control
- Major version: Breaking changes
- Minor version: New features
- Patch version: Bug fixes and minor updates

### Support Matrix
Templates are tested and supported with:
- Cisco HyperFlex 4.5+
- Cisco ACI 5.2+
- Cisco Intersight 1.0.11+
- VMware vSphere 7.0+

---

**Template Version**: 1.0  
**Last Updated**: [Date]  
**Compatibility**: See support matrix above