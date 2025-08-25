# NVIDIA Omniverse Enterprise Configuration Templates

## Overview

This document provides comprehensive configuration templates for NVIDIA Omniverse Enterprise deployment. These templates cover system configuration, security settings, performance optimization, and integration parameters to ensure optimal platform deployment and operation.

---

## Nucleus Server Configuration Templates

### Core Server Configuration

**nucleus.toml - Main Configuration File**
```toml
# NVIDIA Omniverse Nucleus Server Configuration
# Production Environment Template

[server]
name = "Production Nucleus Server"
version = "2024.1.0"
port = 3009
bind_address = "0.0.0.0"
max_connections = 1000
timeout = 30

[database]
type = "postgresql"
host = "localhost"
port = 5432
database = "nucleus"
username = "nucleus_user"
password_file = "/opt/nucleus/config/db_password"
max_connections = 50
connection_timeout = 10

[storage]
root_path = "/data/nucleus"
temp_path = "/tmp/nucleus"
max_file_size = "10GB"
chunk_size = "64MB"
compression = true
deduplication = true

[security]
ssl_enabled = true
ssl_cert_path = "/opt/nucleus/ssl/server.crt"
ssl_key_path = "/opt/nucleus/ssl/server.key"
ssl_ca_path = "/opt/nucleus/ssl/ca.crt"
require_client_cert = false

[authentication]
ldap_enabled = true
ldap_server = "ldap://ad.company.com:389"
ldap_base_dn = "dc=company,dc=com"
ldap_bind_dn = "cn=nucleus,ou=service_accounts,dc=company,dc=com"
ldap_bind_password_file = "/opt/nucleus/config/ldap_password"
ldap_user_filter = "(&(objectClass=user)(sAMAccountName=%s))"
ldap_group_filter = "(&(objectClass=group)(member=%s))"

[logging]
level = "INFO"
file_path = "/var/log/nucleus/server.log"
max_file_size = "100MB"
max_files = 10
log_format = "json"

[performance]
worker_threads = 16
io_threads = 8
cache_size = "2GB"
preload_assets = true
parallel_uploads = 4
parallel_downloads = 8

[monitoring]
metrics_enabled = true
metrics_port = 9090
health_check_enabled = true
health_check_port = 8080
```

**PostgreSQL Database Configuration**
```sql
-- PostgreSQL optimization for Nucleus Server
-- /etc/postgresql/14/main/postgresql.conf

-- Connection Settings
max_connections = 200
superuser_reserved_connections = 3

-- Memory Settings
shared_buffers = 8GB
effective_cache_size = 24GB
work_mem = 256MB
maintenance_work_mem = 2GB
wal_buffers = 16MB

-- Checkpoint Settings
checkpoint_completion_target = 0.9
wal_compression = on
min_wal_size = 2GB
max_wal_size = 8GB

-- Query Planner Settings
random_page_cost = 1.1
effective_io_concurrency = 200

-- Logging Settings
log_destination = 'csvlog'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on

-- Replication Settings (for HA)
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 64
archive_mode = on
archive_command = '/opt/postgresql/backup/archive_wal.sh %f %p'
```

### High Availability Configuration

**HAProxy Load Balancer Configuration**
```
# /etc/haproxy/haproxy.cfg
# Nucleus Server Load Balancer Configuration

global
    daemon
    log 127.0.0.1:514 local0
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy

defaults
    mode http
    log global
    option httplog
    option dontlognull
    option http-server-close
    option forwardfor except 127.0.0.0/8
    option redispatch
    retries 3
    timeout http-request 10s
    timeout queue 1m
    timeout connect 10s
    timeout client 1m
    timeout server 1m
    timeout http-keep-alive 10s
    timeout check 10s
    maxconn 3000

# Nucleus Server Frontend
frontend nucleus_frontend
    bind *:3009 ssl crt /opt/haproxy/ssl/nucleus.pem
    redirect scheme https if !{ ssl_fc }
    default_backend nucleus_servers
    
    # Security headers
    http-response set-header Strict-Transport-Security max-age=31536000
    http-response set-header X-Frame-Options DENY
    http-response set-header X-Content-Type-Options nosniff

# Nucleus Server Backend
backend nucleus_servers
    balance roundrobin
    option httpchk GET /health
    server nucleus01 192.168.1.10:3009 check ssl verify none
    server nucleus02 192.168.1.11:3009 check ssl verify none backup

# Statistics Interface
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
```

---

## Security Configuration Templates

### SSL/TLS Configuration

**SSL Certificate Configuration**
```bash
#!/bin/bash
# SSL certificate generation and configuration

# Generate CA private key
openssl genrsa -out ca-key.pem 4096

# Generate CA certificate
openssl req -new -x509 -days 3650 -key ca-key.pem -out ca.pem \
    -subj "/C=US/ST=State/L=City/O=Company/OU=IT/CN=Nucleus-CA"

# Generate server private key
openssl genrsa -out server-key.pem 4096

# Generate server certificate signing request
openssl req -subj "/C=US/ST=State/L=City/O=Company/OU=IT/CN=nucleus.company.com" \
    -new -key server-key.pem -out server.csr

# Generate server certificate
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem \
    -out server-cert.pem -CAcreateserial \
    -extensions v3_req -extfile <(cat <<EOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = nucleus.company.com
DNS.2 = nucleus-server.company.com
IP.1 = 192.168.1.10
IP.2 = 192.168.1.11
EOF
)

# Set proper permissions
chmod 400 *-key.pem
chmod 444 *.pem
```

**Nginx SSL Configuration**
```nginx
# /etc/nginx/sites-available/nucleus
server {
    listen 443 ssl http2;
    server_name nucleus.company.com;
    
    # SSL Configuration
    ssl_certificate /opt/nucleus/ssl/server-cert.pem;
    ssl_certificate_key /opt/nucleus/ssl/server-key.pem;
    ssl_trusted_certificate /opt/nucleus/ssl/ca.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Proxy Configuration
    location / {
        proxy_pass https://127.0.0.1:3009;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name nucleus.company.com;
    return 301 https://$server_name$request_uri;
}
```

### Active Directory Integration

**LDAP Configuration Template**
```yaml
# LDAP Configuration for Active Directory Integration
ldap_config:
  server:
    host: "ad.company.com"
    port: 636  # LDAPS
    use_ssl: true
    verify_cert: true
    ca_cert_file: "/opt/nucleus/ssl/ad-ca.crt"
  
  bind_credentials:
    bind_dn: "cn=nucleus-service,ou=Service Accounts,dc=company,dc=com"
    bind_password_file: "/opt/nucleus/config/.ldap_password"
  
  user_search:
    base_dn: "ou=Users,dc=company,dc=com"
    filter: "(&(objectClass=user)(sAMAccountName={username}))"
    attributes:
      username: "sAMAccountName"
      display_name: "displayName"
      email: "mail"
      department: "department"
      title: "title"
  
  group_search:
    base_dn: "ou=Groups,dc=company,dc=com"
    filter: "(&(objectClass=group)(member={user_dn}))"
    attributes:
      name: "cn"
      description: "description"
  
  role_mapping:
    "CN=Omniverse-Admins,OU=Groups,DC=company,DC=com": "administrator"
    "CN=Omniverse-CreativeDirectors,OU=Groups,DC=company,DC=com": "creative_director"
    "CN=Omniverse-SeniorArtists,OU=Groups,DC=company,DC=com": "senior_artist"
    "CN=Omniverse-Artists,OU=Groups,DC=company,DC=com": "artist"
    "CN=Omniverse-Reviewers,OU=Groups,DC=company,DC=com": "reviewer"
```

---

## Performance Optimization Templates

### System Performance Configuration

**Linux Kernel Optimization**
```bash
#!/bin/bash
# /etc/sysctl.d/99-nucleus-performance.conf
# Linux kernel optimization for Nucleus Server

# Network Performance
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = cubic
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1

# File System Performance
fs.file-max = 65536
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# Memory Management
vm.overcommit_memory = 1
vm.overcommit_ratio = 50
kernel.shmmax = 17179869184
kernel.shmall = 4194304

# Security
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
```

**Storage Performance Configuration**
```bash
#!/bin/bash
# Storage optimization for Nucleus Server

# XFS filesystem optimization for large files
mkfs.xfs -f -d su=64k,sw=1 -l su=64k /dev/sdb1

# Mount options for performance
echo "/dev/sdb1 /data/nucleus xfs defaults,noatime,nobarrier,logbufs=8,logbsize=256k,largeio,inode64 0 0" >> /etc/fstab

# I/O scheduler optimization for SSDs
echo 'noop' > /sys/block/sdb/queue/scheduler

# Read-ahead optimization
blockdev --setra 4096 /dev/sdb1

# Create performance monitoring script
cat > /opt/nucleus/scripts/monitor_storage.sh << 'EOF'
#!/bin/bash
while true; do
    iostat -x 1 1 | grep -E "(Device|sdb)" >> /var/log/nucleus/storage_performance.log
    sleep 60
done
EOF

chmod +x /opt/nucleus/scripts/monitor_storage.sh
```

### Network Performance Configuration

**Network Interface Optimization**
```bash
#!/bin/bash
# Network interface optimization for high-performance

# Increase network buffer sizes
echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf

# Enable TCP window scaling
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf

# Optimize TCP congestion control
echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf

# Network interface optimization
ethtool -G eth0 rx 4096 tx 4096
ethtool -K eth0 tso on gso on gro on
ethtool -C eth0 rx-usecs 20 rx-frames 20

# Apply settings
sysctl -p
```

---

## DCC Connector Configuration Templates

### Maya Connector Configuration

**Maya Connector Settings**
```python
# Maya Omniverse Connector Configuration
# userSetup.py additions

import maya.cmds as cmds
import omni.kit.app

def configure_omniverse_maya():
    """Configure Maya for optimal Omniverse integration"""
    
    # Nucleus server configuration
    nucleus_config = {
        "server_url": "nucleus://nucleus.company.com",
        "auto_login": True,
        "sync_frequency": 1.0,  # seconds
        "conflict_resolution": "manual",
        "asset_validation": True
    }
    
    # Performance settings
    performance_config = {
        "parallel_evaluation": True,
        "cached_playback": True,
        "gpu_override": True,
        "viewport_2_0": True
    }
    
    # Apply configurations
    for key, value in nucleus_config.items():
        cmds.optionVar(sv=(f"omniverse_{key}", str(value)))
    
    for key, value in performance_config.items():
        cmds.optionVar(iv=(f"maya_{key}", int(value)))
    
    # Enable required plugins
    required_plugins = [
        "mtoa",  # Arnold renderer
        "AbcExport",  # Alembic export
        "AbcImport",  # Alembic import
        "fbxmaya",  # FBX import/export
        "objExport",  # OBJ export
        "mayaUsdPlugin"  # USD plugin
    ]
    
    for plugin in required_plugins:
        try:
            cmds.loadPlugin(plugin, quiet=True)
        except:
            print(f"Warning: Could not load plugin {plugin}")

# Auto-configure on Maya startup
cmds.evalDeferred(configure_omniverse_maya)
```

### 3ds Max Connector Configuration

**3ds Max Connector Settings**
```maxscript
-- 3ds Max Omniverse Connector Configuration
-- startup/omniverse_config.ms

struct OmniverseConfig (
    -- Server configuration
    nucleus_server = "nucleus://nucleus.company.com",
    auto_connect = true,
    sync_interval = 1000, -- milliseconds
    
    -- Performance settings
    enable_gpu_rendering = true,
    viewport_quality = "high",
    auto_backup = true,
    
    fn configure = (
        -- Set Nucleus server
        OmniverseConnector.setServer nucleus_server
        
        -- Configure auto-connect
        if auto_connect then (
            OmniverseConnector.autoConnect = true
        )
        
        -- Set sync interval
        OmniverseConnector.syncInterval = sync_interval
        
        -- Performance optimizations
        if enable_gpu_rendering then (
            renderers.current = renderers.getRendererClass #Arnold
            viewport.setRenderLevel #smoothhighlights
        )
        
        -- Auto-save configuration
        if auto_backup then (
            autosave.Enable = true
            autosave.time = 10 -- 10 minutes
        )
        
        print "Omniverse configuration applied successfully"
    )
)

-- Apply configuration on startup
global omni_config = OmniverseConfig()
omni_config.configure()
```

### Blender Connector Configuration

**Blender Connector Settings**
```python
# Blender Omniverse Connector Configuration
# startup.py

import bpy
import addon_utils

def configure_omniverse_blender():
    """Configure Blender for optimal Omniverse integration"""
    
    # Enable required add-ons
    required_addons = [
        'io_scene_usd',
        'io_scene_fbx',
        'io_scene_obj',
        'io_mesh_uv_layout',
        'cycles'
    ]
    
    for addon in required_addons:
        addon_utils.enable(addon, default_set=True)
    
    # Configure Omniverse preferences
    prefs = bpy.context.preferences
    
    # Omniverse connector preferences
    if hasattr(prefs, 'addons') and 'omniverse_connector' in prefs.addons:
        omni_prefs = prefs.addons['omniverse_connector'].preferences
        omni_prefs.nucleus_server = "nucleus://nucleus.company.com"
        omni_prefs.auto_connect = True
        omni_prefs.sync_frequency = 1.0
        omni_prefs.enable_live_sync = True
    
    # Performance settings
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'GPU'
    
    # Viewport settings for better performance
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    space.shading.type = 'MATERIAL'
                    space.shading.use_scene_lights_render = True
    
    print("Blender Omniverse configuration completed")

# Apply configuration
bpy.app.timers.register(configure_omniverse_blender, first_interval=1.0)
```

---

## Monitoring and Alerting Configuration

### Prometheus Configuration

**Prometheus Configuration File**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "nucleus_alerts.yml"

scrape_configs:
  - job_name: 'nucleus-server'
    static_configs:
      - targets: ['nucleus.company.com:9090']
    scrape_interval: 10s
    metrics_path: '/metrics'
    
  - job_name: 'system-metrics'
    static_configs:
      - targets: ['nucleus.company.com:9100']
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['nucleus.company.com:9187']
    
  - job_name: 'nginx'
    static_configs:
      - targets: ['nucleus.company.com:9113']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

**Nucleus Alerting Rules**
```yaml
# nucleus_alerts.yml
groups:
  - name: nucleus.rules
    rules:
      - alert: NucleusServerDown
        expr: up{job="nucleus-server"} == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          summary: "Nucleus server is down"
          description: "Nucleus server has been down for more than 30 seconds."
      
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 2 minutes."
      
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 2 minutes."
      
      - alert: DatabaseConnectionIssue
        expr: postgres_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection issue"
          description: "Cannot connect to PostgreSQL database."
      
      - alert: HighDiskUsage
        expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk usage critical"
          description: "Disk usage is above 90% for more than 5 minutes."
```

### Grafana Dashboard Configuration

**Nucleus Performance Dashboard**
```json
{
  "dashboard": {
    "id": null,
    "title": "NVIDIA Omniverse Nucleus Performance",
    "tags": ["omniverse", "nucleus", "performance"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "System Overview",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job='nucleus-server'}",
            "legendFormat": "Server Status"
          },
          {
            "expr": "nucleus_active_users",
            "legendFormat": "Active Users"
          },
          {
            "expr": "nucleus_active_sessions",
            "legendFormat": "Active Sessions"
          }
        ],
        "gridPos": {"h": 4, "w": 24, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 4}
      },
      {
        "id": 3,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 4}
      },
      {
        "id": 4,
        "title": "Collaboration Metrics",
        "type": "graph",
        "targets": [
          {
            "expr": "nucleus_collaboration_latency_ms",
            "legendFormat": "Collaboration Latency (ms)"
          },
          {
            "expr": "nucleus_sync_time_seconds",
            "legendFormat": "Sync Time (s)"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 12}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
```

---

## Backup and Recovery Configuration

### Automated Backup Configuration

**Backup Script Template**
```bash
#!/bin/bash
# /opt/nucleus/scripts/backup_nucleus.sh
# Automated backup script for Nucleus Server

# Configuration
BACKUP_DIR="/backup/nucleus"
S3_BUCKET="s3://company-nucleus-backups"
RETENTION_DAYS=30
LOG_FILE="/var/log/nucleus/backup.log"
NUCLEUS_DATA_DIR="/data/nucleus"
DB_NAME="nucleus"
DB_USER="nucleus_user"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Function to send notifications
send_notification() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" admin@company.com
}

# Create backup directory
mkdir -p "$BACKUP_DIR/$(date +%Y-%m-%d)"
BACKUP_DATE_DIR="$BACKUP_DIR/$(date +%Y-%m-%d)"

log_message "Starting Nucleus backup process"

# Stop Nucleus service for consistent backup
log_message "Stopping Nucleus service"
systemctl stop nucleus-server

# Database backup
log_message "Starting database backup"
pg_dump -U "$DB_USER" -h localhost "$DB_NAME" | gzip > "$BACKUP_DATE_DIR/nucleus_db_$(date +%Y%m%d_%H%M%S).sql.gz"

if [ $? -eq 0 ]; then
    log_message "Database backup completed successfully"
else
    log_message "ERROR: Database backup failed"
    send_notification "Nucleus Backup Failed" "Database backup failed on $(hostname)"
    exit 1
fi

# File system backup
log_message "Starting file system backup"
tar -czf "$BACKUP_DATE_DIR/nucleus_data_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$(dirname $NUCLEUS_DATA_DIR)" "$(basename $NUCLEUS_DATA_DIR)"

if [ $? -eq 0 ]; then
    log_message "File system backup completed successfully"
else
    log_message "ERROR: File system backup failed"
    send_notification "Nucleus Backup Failed" "File system backup failed on $(hostname)"
    exit 1
fi

# Configuration backup
log_message "Starting configuration backup"
tar -czf "$BACKUP_DATE_DIR/nucleus_config_$(date +%Y%m%d_%H%M%S).tar.gz" /opt/nucleus/config /etc/nginx /etc/ssl

# Start Nucleus service
log_message "Starting Nucleus service"
systemctl start nucleus-server

# Verify service started successfully
sleep 30
if systemctl is-active --quiet nucleus-server; then
    log_message "Nucleus service started successfully"
else
    log_message "ERROR: Nucleus service failed to start"
    send_notification "Nucleus Service Issue" "Nucleus service failed to start after backup on $(hostname)"
fi

# Upload to S3 (optional)
if command -v aws &> /dev/null; then
    log_message "Uploading backup to S3"
    aws s3 sync "$BACKUP_DATE_DIR" "$S3_BUCKET/$(date +%Y-%m-%d)/" --delete
    
    if [ $? -eq 0 ]; then
        log_message "S3 upload completed successfully"
        # Remove local backup after successful S3 upload
        rm -rf "$BACKUP_DATE_DIR"
    else
        log_message "ERROR: S3 upload failed, keeping local backup"
    fi
fi

# Cleanup old backups
log_message "Cleaning up old backups"
find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

# S3 lifecycle management
if command -v aws &> /dev/null; then
    aws s3 ls "$S3_BUCKET" --recursive | while read -r line; do
        createDate=$(echo $line | awk '{print $1" "$2}')
        createDateSec=$(date -d "$createDate" +%s)
        olderThan=$(date -d "$RETENTION_DAYS days ago" +%s)
        if [[ $createDateSec -lt $olderThan ]]; then
            fileName=$(echo $line | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//')
            if [[ $fileName != "" ]]; then
                aws s3 rm "$S3_BUCKET/$fileName"
            fi
        fi
    done
fi

log_message "Backup process completed"
send_notification "Nucleus Backup Completed" "Backup completed successfully on $(hostname) at $(date)"
```

**Backup Cron Configuration**
```bash
# /etc/cron.d/nucleus-backup
# Nucleus Server automated backup schedule

# Daily backup at 2 AM
0 2 * * * root /opt/nucleus/scripts/backup_nucleus.sh

# Weekly full backup on Sunday at 1 AM
0 1 * * 0 root /opt/nucleus/scripts/backup_nucleus_full.sh

# Monthly archive backup on 1st of each month at 11 PM
0 23 1 * * root /opt/nucleus/scripts/archive_nucleus_backup.sh
```

### Disaster Recovery Configuration

**Recovery Script Template**
```bash
#!/bin/bash
# /opt/nucleus/scripts/restore_nucleus.sh
# Disaster recovery script for Nucleus Server

# Configuration
BACKUP_DIR="/backup/nucleus"
S3_BUCKET="s3://company-nucleus-backups"
NUCLEUS_DATA_DIR="/data/nucleus"
DB_NAME="nucleus"
DB_USER="nucleus_user"
LOG_FILE="/var/log/nucleus/recovery.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Recovery function
recover_nucleus() {
    local backup_date="$1"
    
    if [ -z "$backup_date" ]; then
        echo "Usage: $0 <backup_date> (format: YYYY-MM-DD)"
        exit 1
    fi
    
    log_message "Starting Nucleus recovery from backup date: $backup_date"
    
    # Stop services
    log_message "Stopping Nucleus services"
    systemctl stop nucleus-server
    systemctl stop postgresql
    
    # Download backup from S3 if not present locally
    if [ ! -d "$BACKUP_DIR/$backup_date" ] && command -v aws &> /dev/null; then
        log_message "Downloading backup from S3"
        aws s3 sync "$S3_BUCKET/$backup_date/" "$BACKUP_DIR/$backup_date/"
    fi
    
    # Restore database
    log_message "Restoring database"
    systemctl start postgresql
    sleep 10
    
    dropdb -U postgres "$DB_NAME" 2>/dev/null
    createdb -U postgres "$DB_NAME"
    
    latest_db_backup=$(ls -t "$BACKUP_DIR/$backup_date"/nucleus_db_*.sql.gz 2>/dev/null | head -1)
    if [ -n "$latest_db_backup" ]; then
        gunzip -c "$latest_db_backup" | psql -U "$DB_USER" -d "$DB_NAME"
        log_message "Database restored from $latest_db_backup"
    else
        log_message "ERROR: No database backup found for $backup_date"
        exit 1
    fi
    
    # Restore file system
    log_message "Restoring file system"
    latest_data_backup=$(ls -t "$BACKUP_DIR/$backup_date"/nucleus_data_*.tar.gz 2>/dev/null | head -1)
    if [ -n "$latest_data_backup" ]; then
        rm -rf "$NUCLEUS_DATA_DIR"
        tar -xzf "$latest_data_backup" -C "$(dirname $NUCLEUS_DATA_DIR)"
        chown -R nucleus:nucleus "$NUCLEUS_DATA_DIR"
        log_message "File system restored from $latest_data_backup"
    else
        log_message "ERROR: No file system backup found for $backup_date"
        exit 1
    fi
    
    # Restore configuration
    log_message "Restoring configuration"
    latest_config_backup=$(ls -t "$BACKUP_DIR/$backup_date"/nucleus_config_*.tar.gz 2>/dev/null | head -1)
    if [ -n "$latest_config_backup" ]; then
        tar -xzf "$latest_config_backup" -C /
        log_message "Configuration restored from $latest_config_backup"
    fi
    
    # Start services
    log_message "Starting Nucleus services"
    systemctl start nucleus-server
    
    # Verify recovery
    sleep 30
    if systemctl is-active --quiet nucleus-server; then
        log_message "Recovery completed successfully"
        echo "Nucleus recovery completed successfully from backup: $backup_date"
    else
        log_message "ERROR: Recovery failed - service not running"
        exit 1
    fi
}

# Execute recovery
recover_nucleus "$1"
```

These configuration templates provide comprehensive setup instructions for all major components of the NVIDIA Omniverse Enterprise platform, ensuring optimal performance, security, and reliability in production environments.