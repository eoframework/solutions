#!/bin/bash

# NVIDIA Omniverse Enterprise Deployment Script
# Version: 1.0
# Description: Automated deployment and configuration of Omniverse Enterprise collaboration platform

set -euo pipefail

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/omniverse-enterprise"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/deployment_${TIMESTAMP}.log"

# Default configuration
OMNIVERSE_VERSION=${OMNIVERSE_VERSION:-"2023.2.1"}
NUCLEUS_SERVER_NAME=${NUCLEUS_SERVER_NAME:-"nucleus-server"}
DOMAIN_NAME=${DOMAIN_NAME:-"company.local"}
ADMIN_EMAIL=${ADMIN_EMAIL:-"admin@company.com"}
SSL_ENABLED=${SSL_ENABLED:-"true"}
BACKUP_ENABLED=${BACKUP_ENABLED:-"true"}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "$*"
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    log "WARN" "$*"
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    log "ERROR" "$*"
    echo -e "${RED}[ERROR]${NC} $*"
}

log_success() {
    log "SUCCESS" "$*"
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Deployment failed with exit code $exit_code"
        log_info "Check log file: $LOG_FILE"
    fi
    exit $exit_code
}

trap cleanup EXIT

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

wait_for_service() {
    local service=$1
    local timeout=${2:-300}
    local count=0
    
    log_info "Waiting for service $service to be ready..."
    while [ $count -lt $timeout ]; do
        if systemctl is-active --quiet "$service"; then
            log_success "Service $service is ready"
            return 0
        fi
        sleep 5
        count=$((count + 5))
    done
    error_exit "Service $service failed to start within $timeout seconds"
}

wait_for_port() {
    local host=$1
    local port=$2
    local timeout=${3:-300}
    local count=0
    
    log_info "Waiting for $host:$port to be available..."
    while [ $count -lt $timeout ]; do
        if nc -z "$host" "$port" 2>/dev/null; then
            log_success "Port $host:$port is available"
            return 0
        fi
        sleep 5
        count=$((count + 5))
    done
    error_exit "Port $host:$port not available within $timeout seconds"
}

# Prerequisites check
check_prerequisites() {
    log_info "Checking deployment prerequisites..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error_exit "This script must be run as root"
    fi
    
    # Check OS compatibility
    if ! grep -q "Ubuntu 20.04\|Ubuntu 22.04\|Red Hat Enterprise Linux 8\|CentOS Stream 8" /etc/os-release; then
        log_warn "OS may not be fully supported. Recommended: Ubuntu 20.04/22.04, RHEL 8"
    fi
    
    # Check hardware requirements
    local cpu_count=$(nproc)
    local memory_gb=$(free -g | awk '/^Mem:/{print $2}')
    
    if [ $cpu_count -lt 8 ]; then
        log_warn "CPU count ($cpu_count) below recommended minimum (8 cores)"
    fi
    
    if [ $memory_gb -lt 32 ]; then
        log_warn "Memory ($memory_gb GB) below recommended minimum (32 GB)"
    fi
    
    # Check for NVIDIA GPU
    if ! lspci | grep -i nvidia > /dev/null; then
        log_warn "No NVIDIA GPU detected - software rendering will be used"
    fi
    
    # Check disk space
    local disk_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$disk_space" -lt 52428800 ]; then  # 50GB in KB
        log_warn "Available disk space less than 50GB - may be insufficient for full deployment"
    fi
    
    # Check network connectivity
    if ! ping -c 3 8.8.8.8 > /dev/null 2>&1; then
        error_exit "No internet connectivity detected"
    fi
    
    # Check required ports are available
    local required_ports=(80 443 3009 3019 3020 3021)
    for port in "${required_ports[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            log_warn "Port $port is already in use - may cause conflicts"
        fi
    done
    
    log_success "Prerequisites check completed"
}

# System preparation
prepare_system() {
    log_info "Preparing system for Omniverse Enterprise deployment..."
    
    # Create necessary directories
    mkdir -p "$LOG_DIR"
    mkdir -p /opt/omniverse
    mkdir -p /etc/omniverse
    mkdir -p /data/omniverse/{nucleus,cache,content}
    mkdir -p /data/backups/omniverse
    
    # Update system packages
    log_info "Updating system packages..."
    if command_exists apt; then
        apt update && apt upgrade -y
        apt install -y curl wget gnupg software-properties-common apt-transport-https ca-certificates
        apt install -y build-essential git vim htop iotop netstat-nat unzip zip
        apt install -y nginx postgresql-12 redis-server
    elif command_exists yum; then
        yum update -y
        yum install -y curl wget gnupg2 epel-release
        yum install -y gcc gcc-c++ make git vim htop iotop net-tools unzip zip
        yum install -y nginx postgresql12-server redis
    fi
    
    # Configure system settings
    log_info "Configuring system settings..."
    
    # Set system limits
    cat > /etc/security/limits.d/omniverse.conf << EOF
# Omniverse Enterprise system limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
* soft memlock unlimited
* hard memlock unlimited
EOF
    
    # Configure kernel parameters
    cat > /etc/sysctl.d/99-omniverse.conf << EOF
# Omniverse Enterprise kernel parameters
vm.max_map_count=262144
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_congestion_control=bbr
fs.file-max=2097152
EOF
    sysctl --system
    
    log_success "System preparation completed"
}

# Docker installation
install_docker() {
    log_info "Installing Docker container runtime..."
    
    if command_exists docker; then
        log_info "Docker already installed"
        return 0
    fi
    
    # Install Docker
    if command_exists apt; then
        # Ubuntu/Debian
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
    elif command_exists yum; then
        # RHEL/CentOS
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi
    
    # Start and enable Docker
    systemctl enable docker
    systemctl start docker
    wait_for_service docker
    
    # Configure Docker daemon
    cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "data-root": "/data/docker"
}
EOF
    
    mkdir -p /data/docker
    systemctl restart docker
    wait_for_service docker
    
    # Install NVIDIA Container Runtime (if GPU present)
    if lspci | grep -i nvidia > /dev/null; then
        log_info "Installing NVIDIA Container Runtime..."
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
        apt update
        apt install -y nvidia-container-runtime
        
        # Configure Docker for NVIDIA runtime
        cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m", 
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "data-root": "/data/docker",
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF
        systemctl restart docker
        wait_for_service docker
    fi
    
    log_success "Docker installed successfully"
}

# PostgreSQL setup
setup_postgresql() {
    log_info "Setting up PostgreSQL database..."
    
    # Initialize and start PostgreSQL
    if command_exists apt; then
        systemctl enable postgresql
        systemctl start postgresql
        wait_for_service postgresql
    elif command_exists yum; then
        /usr/pgsql-12/bin/postgresql-12-setup initdb
        systemctl enable postgresql-12
        systemctl start postgresql-12
        wait_for_service postgresql-12
    fi
    
    # Create database and user for Omniverse
    sudo -u postgres psql << EOF
CREATE DATABASE omniverse_db;
CREATE USER omniverse_user WITH ENCRYPTED PASSWORD 'omniverse_secure_password_123';
GRANT ALL PRIVILEGES ON DATABASE omniverse_db TO omniverse_user;
ALTER USER omniverse_user CREATEDB;
\q
EOF
    
    # Configure PostgreSQL for network connections
    local pg_config_dir="/etc/postgresql/12/main"
    if [ -d "/var/lib/pgsql/12/data" ]; then
        pg_config_dir="/var/lib/pgsql/12/data"
    fi
    
    # Update postgresql.conf
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$pg_config_dir/postgresql.conf"
    sed -i "s/#port = 5432/port = 5432/" "$pg_config_dir/postgresql.conf"
    
    # Update pg_hba.conf
    cat >> "$pg_config_dir/pg_hba.conf" << EOF
# Omniverse Enterprise connections
host    omniverse_db    omniverse_user    127.0.0.1/32    md5
host    omniverse_db    omniverse_user    ::1/128         md5
host    omniverse_db    omniverse_user    0.0.0.0/0       md5
EOF
    
    # Restart PostgreSQL
    systemctl restart postgresql
    wait_for_service postgresql
    
    log_success "PostgreSQL setup completed"
}

# Redis setup
setup_redis() {
    log_info "Setting up Redis cache server..."
    
    # Configure Redis
    cat > /etc/redis/redis.conf << EOF
# Omniverse Enterprise Redis Configuration
bind 127.0.0.1
port 6379
timeout 300
keepalive 60
maxmemory 2gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
dir /var/lib/redis
logfile /var/log/redis/redis-server.log
loglevel notice
databases 16
EOF
    
    # Start and enable Redis
    systemctl enable redis-server
    systemctl start redis-server
    wait_for_service redis-server
    
    log_success "Redis setup completed"
}

# SSL certificate setup
setup_ssl() {
    log_info "Setting up SSL certificates..."
    
    if [ "$SSL_ENABLED" != "true" ]; then
        log_info "SSL disabled, skipping certificate setup"
        return 0
    fi
    
    # Create self-signed certificate for testing
    mkdir -p /etc/ssl/omniverse
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/omniverse/server.key \
        -out /etc/ssl/omniverse/server.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$NUCLEUS_SERVER_NAME.$DOMAIN_NAME"
    
    # Set proper permissions
    chmod 600 /etc/ssl/omniverse/server.key
    chmod 644 /etc/ssl/omniverse/server.crt
    
    log_success "SSL certificates created"
    log_warn "Self-signed certificates are for testing only. Use proper CA certificates in production."
}

# NGINX configuration
configure_nginx() {
    log_info "Configuring NGINX reverse proxy..."
    
    # Create Omniverse site configuration
    cat > /etc/nginx/sites-available/omniverse << EOF
# NVIDIA Omniverse Enterprise NGINX Configuration

upstream nucleus_backend {
    server 127.0.0.1:3009;
    keepalive 32;
}

upstream nucleus_discovery {
    server 127.0.0.1:3019;
    keepalive 16;
}

upstream nucleus_tagging {
    server 127.0.0.1:3020;
    keepalive 16;
}

upstream nucleus_auth {
    server 127.0.0.1:3021;
    keepalive 16;
}

server {
    listen 80;
    server_name $NUCLEUS_SERVER_NAME.$DOMAIN_NAME;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $NUCLEUS_SERVER_NAME.$DOMAIN_NAME;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/omniverse/server.crt;
    ssl_certificate_key /etc/ssl/omniverse/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    
    # Client upload size
    client_max_body_size 10G;
    
    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
    
    # Main Nucleus service
    location / {
        proxy_pass http://nucleus_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
    
    # Discovery service
    location /discovery/ {
        proxy_pass http://nucleus_discovery/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Tagging service
    location /tagging/ {
        proxy_pass http://nucleus_tagging/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Auth service
    location /auth/ {
        proxy_pass http://nucleus_auth/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # WebSocket support
    location /ws/ {
        proxy_pass http://nucleus_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Enable the site
    ln -sf /etc/nginx/sites-available/omniverse /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test NGINX configuration
    nginx -t || error_exit "NGINX configuration test failed"
    
    # Start and enable NGINX
    systemctl enable nginx
    systemctl restart nginx
    wait_for_service nginx
    
    log_success "NGINX configuration completed"
}

# Omniverse Nucleus installation
install_nucleus_server() {
    log_info "Installing NVIDIA Omniverse Nucleus Server..."
    
    # Download Nucleus Server (placeholder - actual download would require NGC access)
    # In production, this would download from NVIDIA's official repository
    
    # Create Nucleus configuration
    mkdir -p /opt/omniverse/nucleus
    
    # Create Docker Compose configuration for Nucleus
    cat > /opt/omniverse/nucleus/docker-compose.yml << EOF
version: '3.8'

services:
  nucleus-server:
    image: nvcr.io/nvidia/omniverse/nucleus-server:$OMNIVERSE_VERSION
    container_name: nucleus-server
    restart: unless-stopped
    ports:
      - "3009:3009"
    environment:
      - NUCLEUS_SERVER_NAME=$NUCLEUS_SERVER_NAME
      - NUCLEUS_DATA_PATH=/data/nucleus
      - DATABASE_URL=postgresql://omniverse_user:omniverse_secure_password_123@host.docker.internal:5432/omniverse_db
      - REDIS_URL=redis://host.docker.internal:6379/0
      - NUCLEUS_LOG_LEVEL=INFO
    volumes:
      - /data/omniverse/nucleus:/data/nucleus
      - /data/omniverse/cache:/data/cache
      - /etc/ssl/omniverse:/etc/ssl/nucleus:ro
    extra_hosts:
      - "host.docker.internal:host-gateway"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3009/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      
  discovery-service:
    image: nvcr.io/nvidia/omniverse/discovery-service:$OMNIVERSE_VERSION
    container_name: discovery-service
    restart: unless-stopped
    ports:
      - "3019:3019"
    environment:
      - DISCOVERY_SERVER_NAME=$NUCLEUS_SERVER_NAME
      - NUCLEUS_SERVER_URL=http://nucleus-server:3009
    depends_on:
      - nucleus-server
      
  tagging-service:
    image: nvcr.io/nvidia/omniverse/tagging-service:$OMNIVERSE_VERSION
    container_name: tagging-service
    restart: unless-stopped
    ports:
      - "3020:3020"
    environment:
      - TAGGING_SERVER_NAME=$NUCLEUS_SERVER_NAME
      - NUCLEUS_SERVER_URL=http://nucleus-server:3009
      - DATABASE_URL=postgresql://omniverse_user:omniverse_secure_password_123@host.docker.internal:5432/omniverse_db
    extra_hosts:
      - "host.docker.internal:host-gateway"
    depends_on:
      - nucleus-server
      
  auth-service:
    image: nvcr.io/nvidia/omniverse/auth-service:$OMNIVERSE_VERSION
    container_name: auth-service
    restart: unless-stopped
    ports:
      - "3021:3021"
    environment:
      - AUTH_SERVER_NAME=$NUCLEUS_SERVER_NAME
      - NUCLEUS_SERVER_URL=http://nucleus-server:3009
      - DATABASE_URL=postgresql://omniverse_user:omniverse_secure_password_123@host.docker.internal:5432/omniverse_db
    extra_hosts:
      - "host.docker.internal:host-gateway"
    depends_on:
      - nucleus-server

volumes:
  nucleus-data:
  nucleus-cache:
EOF
    
    # Set proper permissions
    chown -R 1000:1000 /data/omniverse
    
    # Start Nucleus services
    cd /opt/omniverse/nucleus
    docker compose pull
    docker compose up -d
    
    # Wait for services to be ready
    wait_for_port localhost 3009 600
    wait_for_port localhost 3019 300
    wait_for_port localhost 3020 300
    wait_for_port localhost 3021 300
    
    log_success "Nucleus Server installed and started"
}

# Backup configuration
configure_backups() {
    if [ "$BACKUP_ENABLED" != "true" ]; then
        log_info "Backups disabled, skipping backup configuration"
        return 0
    fi
    
    log_info "Configuring automated backups..."
    
    # Create backup script
    cat > /opt/omniverse/backup.sh << 'EOF'
#!/bin/bash

# Omniverse Enterprise Backup Script
BACKUP_DIR="/data/backups/omniverse"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="omniverse_backup_$TIMESTAMP"

# Create backup directory
mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

# Backup Nucleus data
echo "Backing up Nucleus data..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME/nucleus_data.tar.gz" -C /data/omniverse nucleus/

# Backup database
echo "Backing up PostgreSQL database..."
sudo -u postgres pg_dump omniverse_db > "$BACKUP_DIR/$BACKUP_NAME/database.sql"

# Backup configuration
echo "Backing up configuration files..."
cp -r /opt/omniverse/nucleus/docker-compose.yml "$BACKUP_DIR/$BACKUP_NAME/"
cp -r /etc/nginx/sites-available/omniverse "$BACKUP_DIR/$BACKUP_NAME/"
cp -r /etc/ssl/omniverse "$BACKUP_DIR/$BACKUP_NAME/"

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -type d -name "omniverse_backup_*" -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $BACKUP_DIR/$BACKUP_NAME"
EOF
    
    chmod +x /opt/omniverse/backup.sh
    
    # Create cron job for daily backups
    cat > /etc/cron.d/omniverse-backup << EOF
# Omniverse Enterprise daily backup
0 2 * * * root /opt/omniverse/backup.sh >> /var/log/omniverse-backup.log 2>&1
EOF
    
    log_success "Backup configuration completed"
}

# Monitoring setup
setup_monitoring() {
    log_info "Setting up monitoring and health checks..."
    
    # Create health check script
    cat > /opt/omniverse/health-check.sh << 'EOF'
#!/bin/bash

# Omniverse Enterprise Health Check Script
SERVICES=("nucleus-server" "discovery-service" "tagging-service" "auth-service")
HEALTHY=true

echo "=== Omniverse Enterprise Health Check ==="
echo "Timestamp: $(date)"
echo ""

# Check Docker services
for service in "${SERVICES[@]}"; do
    if docker compose -f /opt/omniverse/nucleus/docker-compose.yml ps "$service" | grep -q "Up"; then
        echo "✓ $service is running"
    else
        echo "✗ $service is not running"
        HEALTHY=false
    fi
done

# Check service endpoints
ENDPOINTS=(
    "http://localhost:3009/health:Nucleus Server"
    "http://localhost:3019/health:Discovery Service"
    "http://localhost:3020/health:Tagging Service"
    "http://localhost:3021/health:Auth Service"
)

echo ""
for endpoint in "${ENDPOINTS[@]}"; do
    url=$(echo "$endpoint" | cut -d':' -f1-2)
    name=$(echo "$endpoint" | cut -d':' -f3)
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo "✓ $name is responding"
    else
        echo "✗ $name is not responding"
        HEALTHY=false
    fi
done

# Check NGINX
echo ""
if systemctl is-active --quiet nginx; then
    echo "✓ NGINX is running"
else
    echo "✗ NGINX is not running"
    HEALTHY=false
fi

# Check database
if sudo -u postgres psql -d omniverse_db -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ PostgreSQL database is accessible"
else
    echo "✗ PostgreSQL database is not accessible"
    HEALTHY=false
fi

# Check Redis
if redis-cli ping | grep -q "PONG"; then
    echo "✓ Redis is responding"
else
    echo "✗ Redis is not responding"
    HEALTHY=false
fi

echo ""
if [ "$HEALTHY" = true ]; then
    echo "✓ All systems healthy"
    exit 0
else
    echo "✗ System health check failed"
    exit 1
fi
EOF
    
    chmod +x /opt/omniverse/health-check.sh
    
    # Create systemd timer for regular health checks
    cat > /etc/systemd/system/omniverse-health-check.service << EOF
[Unit]
Description=Omniverse Enterprise Health Check
After=docker.service

[Service]
Type=oneshot
ExecStart=/opt/omniverse/health-check.sh
User=root
StandardOutput=journal
StandardError=journal
EOF
    
    cat > /etc/systemd/system/omniverse-health-check.timer << EOF
[Unit]
Description=Run Omniverse health check every 10 minutes
Requires=omniverse-health-check.service

[Timer]
OnCalendar=*:0/10
Persistent=true

[Install]
WantedBy=timers.target
EOF
    
    systemctl daemon-reload
    systemctl enable omniverse-health-check.timer
    systemctl start omniverse-health-check.timer
    
    log_success "Monitoring setup completed"
}

# System optimization
optimize_system() {
    log_info "Optimizing system performance..."
    
    # Tune kernel parameters for Omniverse workloads
    cat > /etc/sysctl.d/99-omniverse-perf.conf << EOF
# Omniverse Enterprise performance tuning
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
net.core.netdev_max_backlog=5000
EOF
    sysctl --system
    
    # Configure I/O scheduler for SSDs
    if [ -b "/dev/sda" ]; then
        echo "mq-deadline" > /sys/block/sda/queue/scheduler
    fi
    
    # Optimize PostgreSQL configuration
    cat >> /etc/postgresql/12/main/postgresql.conf << EOF

# Omniverse Enterprise PostgreSQL optimizations
shared_buffers = 1GB
effective_cache_size = 4GB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
seq_page_cost = 1.0
EOF
    
    systemctl restart postgresql
    wait_for_service postgresql
    
    log_success "System optimization completed"
}

# Run health check
run_health_check() {
    log_info "Running deployment health check..."
    
    if /opt/omniverse/health-check.sh; then
        log_success "Health check passed - all services are working"
        return 0
    else
        log_error "Health check failed - some services may have issues"
        return 1
    fi
}

# Main deployment function
deploy_omniverse_enterprise() {
    log_info "Starting NVIDIA Omniverse Enterprise deployment..."
    log_info "Configuration: Server name: $NUCLEUS_SERVER_NAME, Domain: $DOMAIN_NAME"
    
    # Phase 1: System preparation
    log_info "=== Phase 1: System Preparation ==="
    check_prerequisites
    prepare_system
    
    # Phase 2: Infrastructure services
    log_info "=== Phase 2: Infrastructure Services ==="
    install_docker
    setup_postgresql
    setup_redis
    setup_ssl
    configure_nginx
    
    # Phase 3: Omniverse platform
    log_info "=== Phase 3: Omniverse Platform ==="
    install_nucleus_server
    
    # Phase 4: Operations and monitoring
    log_info "=== Phase 4: Operations and Monitoring ==="
    configure_backups
    setup_monitoring
    optimize_system
    
    # Final health check
    log_info "=== Final Health Check ==="
    if run_health_check; then
        log_success "NVIDIA Omniverse Enterprise deployment completed successfully!"
        log_info "Deployment log saved to: $LOG_FILE"
        
        # Display access information
        echo ""
        echo "=== Access Information ==="
        echo "Nucleus Server: https://$NUCLEUS_SERVER_NAME.$DOMAIN_NAME"
        if [ "$SSL_ENABLED" = "true" ]; then
            echo "SSL: Enabled (self-signed certificate for testing)"
        else
            echo "SSL: Disabled"
        fi
        echo ""
        echo "Services Status:"
        echo "  Nucleus Server: https://$NUCLEUS_SERVER_NAME.$DOMAIN_NAME"
        echo "  Discovery Service: Port 3019"  
        echo "  Tagging Service: Port 3020"
        echo "  Auth Service: Port 3021"
        echo ""
        echo "Administration:"
        echo "  Health Check: /opt/omniverse/health-check.sh"
        echo "  Backup: /opt/omniverse/backup.sh"
        echo "  Logs: docker logs nucleus-server"
        echo ""
        
    else
        error_exit "NVIDIA Omniverse Enterprise deployment completed with issues. Check logs for details."
    fi
}

# Script entry point
main() {
    # Load configuration if exists
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
    fi
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --server-name)
                NUCLEUS_SERVER_NAME="$2"
                shift 2
                ;;
            --domain)
                DOMAIN_NAME="$2"
                shift 2
                ;;
            --admin-email)
                ADMIN_EMAIL="$2"
                shift 2
                ;;
            --disable-ssl)
                SSL_ENABLED="false"
                shift
                ;;
            --disable-backups)
                BACKUP_ENABLED="false"
                shift
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --server-name NAME   Nucleus server name (default: nucleus-server)"
                echo "  --domain DOMAIN      Domain name (default: company.local)"
                echo "  --admin-email EMAIL  Administrator email"
                echo "  --disable-ssl        Disable SSL/TLS encryption"
                echo "  --disable-backups    Disable automated backups"
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
    
    # Start deployment
    deploy_omniverse_enterprise
}

# Run main function
main "$@"