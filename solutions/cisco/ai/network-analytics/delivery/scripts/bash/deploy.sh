#!/bin/bash
# Copyright (c) 2025 EO Framework™
# Licensed under BSL 1.1 - see LICENSE file for details

# Cisco AI Network Analytics Platform Deployment Script
# Automated deployment and configuration of Cisco AI-powered network analytics

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/cisco-ai-analytics-deploy.log"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    echo -e "${level}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}" | tee -a "${LOG_FILE}"
}

log_info() { log "${BLUE}[INFO]${NC}" "$@"; }
log_warn() { log "${YELLOW}[WARN]${NC}" "$@"; }
log_error() { log "${RED}[ERROR]${NC}" "$@"; }
log_success() { log "${GREEN}[SUCCESS]${NC}" "$@"; }

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

# Load configuration
load_config() {
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        error_exit "Configuration file not found: ${CONFIG_FILE}"
    fi
    
    # Load configuration variables
    source "${CONFIG_FILE}"
    
    # Set default values if not provided
    ANALYTICS_VERSION="${ANALYTICS_VERSION:-latest}"
    INSTALL_DIR="${INSTALL_DIR:-/opt/cisco-ai-analytics}"
    DATA_DIR="${DATA_DIR:-/var/lib/cisco-ai-analytics}"
    LOG_DIR="${LOG_DIR:-/var/log/cisco-ai-analytics}"
    SERVICE_USER="${SERVICE_USER:-cisco-analytics}"
    
    log_info "Configuration loaded successfully"
}

# System requirements check
check_system_requirements() {
    log_info "Checking system requirements..."
    
    # Check OS compatibility
    if [[ ! -f /etc/redhat-release ]] && [[ ! -f /etc/debian_version ]]; then
        error_exit "Unsupported operating system. RHEL/CentOS or Ubuntu required."
    fi
    
    # Check memory (minimum 16GB)
    local total_mem=$(free -g | awk 'NR==2{print $2}')
    if [[ ${total_mem} -lt 16 ]]; then
        error_exit "Insufficient memory. Minimum 16GB required, found ${total_mem}GB"
    fi
    
    # Check disk space (minimum 100GB for /opt)
    local available_space=$(df -BG /opt | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ ${available_space} -lt 100 ]]; then
        error_exit "Insufficient disk space. Minimum 100GB required in /opt, found ${available_space}GB"
    fi
    
    # Check CPU cores (minimum 8)
    local cpu_cores=$(nproc)
    if [[ ${cpu_cores} -lt 8 ]]; then
        error_exit "Insufficient CPU cores. Minimum 8 required, found ${cpu_cores}"
    fi
    
    log_success "System requirements check passed"
}

# Install system dependencies
install_dependencies() {
    log_info "Installing system dependencies..."
    
    if [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS
        yum update -y
        yum install -y epel-release
        yum groupinstall -y "Development Tools"
        yum install -y \
            python3 python3-pip python3-dev \
            docker-ce docker-ce-cli containerd.io \
            postgresql postgresql-server postgresql-contrib \
            redis \
            nginx \
            supervisor \
            git curl wget unzip \
            htop iotop nethogs \
            tcpdump wireshark-cli \
            snmp snmp-utils \
            elasticsearch logstash kibana
            
    elif [[ -f /etc/debian_version ]]; then
        # Ubuntu/Debian
        apt-get update -y
        apt-get install -y \
            build-essential \
            python3 python3-pip python3-dev python3-venv \
            docker.io docker-compose \
            postgresql postgresql-contrib \
            redis-server \
            nginx \
            supervisor \
            git curl wget unzip \
            htop iotop nethogs \
            tcpdump wireshark \
            snmp snmp-mibs-downloader \
            elasticsearch logstash kibana
    fi
    
    # Start and enable services
    systemctl start docker postgresql redis nginx
    systemctl enable docker postgresql redis nginx
    
    log_success "System dependencies installed"
}

# Create service user
create_service_user() {
    log_info "Creating service user: ${SERVICE_USER}"
    
    if ! id "${SERVICE_USER}" &>/dev/null; then
        useradd -r -s /bin/bash -d "${INSTALL_DIR}" -m "${SERVICE_USER}"
        usermod -aG docker "${SERVICE_USER}"
        log_success "Service user created: ${SERVICE_USER}"
    else
        log_info "Service user already exists: ${SERVICE_USER}"
    fi
}

# Setup directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    # Create directories
    mkdir -p "${INSTALL_DIR}"/{bin,conf,lib,plugins,scripts}
    mkdir -p "${DATA_DIR}"/{models,datasets,outputs,cache}
    mkdir -p "${LOG_DIR}"
    mkdir -p /etc/cisco-ai-analytics
    
    # Set permissions
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}"
    chmod 755 "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}"
    
    log_success "Directory structure created"
}

# Install Python environment
install_python_environment() {
    log_info "Setting up Python environment..."
    
    # Create virtual environment
    sudo -u "${SERVICE_USER}" python3 -m venv "${INSTALL_DIR}/venv"
    
    # Install Python packages
    sudo -u "${SERVICE_USER}" "${INSTALL_DIR}/venv/bin/pip" install --upgrade pip
    sudo -u "${SERVICE_USER}" "${INSTALL_DIR}/venv/bin/pip" install -r "${SCRIPT_DIR}/../python/requirements.txt"
    
    log_success "Python environment configured"
}

# Configure PostgreSQL database
configure_database() {
    log_info "Configuring PostgreSQL database..."
    
    # Initialize database if needed
    if [[ -f /etc/redhat-release ]]; then
        postgresql-setup initdb || true
        systemctl start postgresql
        systemctl enable postgresql
    fi
    
    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE IF NOT EXISTS cisco_analytics;" || true
    sudo -u postgres psql -c "CREATE USER IF NOT EXISTS ${SERVICE_USER} WITH PASSWORD '${DB_PASSWORD}';" || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cisco_analytics TO ${SERVICE_USER};" || true
    
    # Configure PostgreSQL
    PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | awk '{print $2}' | cut -d. -f1,2)
    PG_CONFIG_DIR="/var/lib/pgsql/${PG_VERSION}/data"
    
    if [[ -f /etc/debian_version ]]; then
        PG_CONFIG_DIR="/etc/postgresql/${PG_VERSION}/main"
    fi
    
    # Update pg_hba.conf for local authentication
    sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" "${PG_CONFIG_DIR}/pg_hba.conf"
    
    systemctl restart postgresql
    
    log_success "Database configured"
}

# Install Cisco AI Analytics platform
install_analytics_platform() {
    log_info "Installing Cisco AI Analytics platform..."
    
    # Download and extract analytics platform
    cd /tmp
    wget "https://releases.cisco.com/ai-analytics/${ANALYTICS_VERSION}/cisco-ai-analytics-${ANALYTICS_VERSION}.tar.gz"
    tar -xzf "cisco-ai-analytics-${ANALYTICS_VERSION}.tar.gz"
    
    # Install platform components
    sudo -u "${SERVICE_USER}" cp -r cisco-ai-analytics-"${ANALYTICS_VERSION}"/* "${INSTALL_DIR}/"
    
    # Make scripts executable
    chmod +x "${INSTALL_DIR}/bin/"*
    
    # Install ML models
    sudo -u "${SERVICE_USER}" "${INSTALL_DIR}/scripts/download-models.sh"
    
    log_success "Analytics platform installed"
}

# Configure network data collectors
configure_collectors() {
    log_info "Configuring network data collectors..."
    
    # SNMP collector configuration
    cat > /etc/cisco-ai-analytics/snmp-collector.conf << EOF
[snmp]
community = ${SNMP_COMMUNITY:-public}
version = ${SNMP_VERSION:-2c}
timeout = 30
retries = 3

[devices]
EOF
    
    # Add device configurations
    if [[ -n "${NETWORK_DEVICES:-}" ]]; then
        echo "${NETWORK_DEVICES}" >> /etc/cisco-ai-analytics/snmp-collector.conf
    fi
    
    # NetFlow collector configuration
    cat > /etc/cisco-ai-analytics/netflow-collector.conf << EOF
[netflow]
listen_port = ${NETFLOW_PORT:-9995}
buffer_size = 65536
workers = 4

[storage]
backend = postgresql
connection_string = postgresql://${SERVICE_USER}:${DB_PASSWORD}@localhost/cisco_analytics
EOF
    
    # Syslog collector configuration
    cat > /etc/cisco-ai-analytics/syslog-collector.conf << EOF
[syslog]
listen_port = ${SYSLOG_PORT:-514}
protocol = udp
buffer_size = 8192

[processing]
parse_cisco_logs = true
extract_events = true
real_time_analysis = true
EOF
    
    log_success "Data collectors configured"
}

# Configure AI/ML pipeline
configure_ml_pipeline() {
    log_info "Configuring AI/ML processing pipeline..."
    
    # ML pipeline configuration
    cat > /etc/cisco-ai-analytics/ml-pipeline.conf << EOF
[models]
anomaly_detection = ${INSTALL_DIR}/data/models/anomaly-detection-v2.pkl
traffic_prediction = ${INSTALL_DIR}/data/models/traffic-prediction-v1.pkl
security_classification = ${INSTALL_DIR}/data/models/security-classifier-v3.pkl

[processing]
batch_size = 1000
prediction_interval = 300
anomaly_threshold = 0.95
retrain_interval = 86400

[features]
enable_traffic_analysis = true
enable_security_analysis = true
enable_performance_monitoring = true
enable_capacity_planning = true
EOF
    
    # Create ML processing service
    cat > /etc/systemd/system/cisco-ai-ml-processor.service << EOF
[Unit]
Description=Cisco AI Network Analytics ML Processor
After=postgresql.service redis.service
Requires=postgresql.service redis.service

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_USER}
WorkingDirectory=${INSTALL_DIR}
Environment=PYTHONPATH=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/scripts/ml-processor.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable cisco-ai-ml-processor
    
    log_success "ML pipeline configured"
}

# Configure web dashboard
configure_dashboard() {
    log_info "Configuring web dashboard..."
    
    # Nginx configuration for dashboard
    cat > /etc/nginx/sites-available/cisco-ai-analytics << EOF
server {
    listen 80;
    server_name ${DASHBOARD_HOSTNAME:-localhost};
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /static/ {
        alias ${INSTALL_DIR}/web/static/;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    
    # Enable site
    if [[ -f /etc/debian_version ]]; then
        ln -sf /etc/nginx/sites-available/cisco-ai-analytics /etc/nginx/sites-enabled/
        rm -f /etc/nginx/sites-enabled/default
    fi
    
    # Test and reload nginx
    nginx -t && systemctl reload nginx
    
    log_success "Web dashboard configured"
}

# Start services
start_services() {
    log_info "Starting Cisco AI Analytics services..."
    
    # Start core services
    systemctl start cisco-ai-ml-processor
    
    # Start collectors using supervisor
    cat > /etc/supervisor/conf.d/cisco-ai-collectors.conf << EOF
[group:cisco-ai-collectors]
programs=snmp-collector,netflow-collector,syslog-collector

[program:snmp-collector]
command=${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/scripts/snmp-collector.py
directory=${INSTALL_DIR}
user=${SERVICE_USER}
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=${LOG_DIR}/snmp-collector.log

[program:netflow-collector]
command=${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/scripts/netflow-collector.py
directory=${INSTALL_DIR}
user=${SERVICE_USER}
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=${LOG_DIR}/netflow-collector.log

[program:syslog-collector]
command=${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/scripts/syslog-collector.py
directory=${INSTALL_DIR}
user=${SERVICE_USER}
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=${LOG_DIR}/syslog-collector.log
EOF
    
    supervisorctl reread
    supervisorctl update
    supervisorctl start cisco-ai-collectors:*
    
    log_success "All services started"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check service status
    if systemctl is-active --quiet cisco-ai-ml-processor; then
        log_success "ML processor service is running"
    else
        log_error "ML processor service is not running"
        return 1
    fi
    
    # Check collectors
    if supervisorctl status cisco-ai-collectors:* | grep -q RUNNING; then
        log_success "Data collectors are running"
    else
        log_error "Some data collectors are not running"
        return 1
    fi
    
    # Check database connectivity
    if sudo -u "${SERVICE_USER}" "${INSTALL_DIR}/venv/bin/python" -c "
import psycopg2
conn = psycopg2.connect(
    host='localhost',
    database='cisco_analytics',
    user='${SERVICE_USER}',
    password='${DB_PASSWORD}'
)
conn.close()
print('Database connection successful')
"; then
        log_success "Database connection verified"
    else
        log_error "Database connection failed"
        return 1
    fi
    
    # Check web dashboard
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q 200; then
        log_success "Web dashboard is accessible"
    else
        log_warn "Web dashboard may not be fully ready"
    fi
    
    log_success "Installation verification completed"
}

# Display summary
display_summary() {
    log_info "Deployment Summary:"
    log_info "=================="
    log_info "Installation Directory: ${INSTALL_DIR}"
    log_info "Data Directory: ${DATA_DIR}"
    log_info "Log Directory: ${LOG_DIR}"
    log_info "Service User: ${SERVICE_USER}"
    log_info "Web Dashboard: http://${DASHBOARD_HOSTNAME:-localhost}"
    log_info "Configuration: /etc/cisco-ai-analytics/"
    log_info ""
    log_info "Management Commands:"
    log_info "- View logs: journalctl -u cisco-ai-ml-processor -f"
    log_info "- Restart services: systemctl restart cisco-ai-ml-processor"
    log_info "- Check collectors: supervisorctl status cisco-ai-collectors:*"
    log_info "- Monitor resources: ${INSTALL_DIR}/scripts/monitor.py"
    log_info ""
    log_success "Cisco AI Network Analytics deployment completed!"
}

# Main deployment function
main() {
    log_info "Starting Cisco AI Network Analytics deployment..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
    
    # Load configuration
    load_config
    
    # Execute deployment steps
    check_system_requirements
    install_dependencies
    create_service_user
    setup_directories
    install_python_environment
    configure_database
    install_analytics_platform
    configure_collectors
    configure_ml_pipeline
    configure_dashboard
    start_services
    verify_installation
    display_summary
    
    log_success "Deployment completed successfully!"
}

# Handle script interruption
trap 'log_error "Deployment interrupted!"; exit 1' INT TERM

# Execute main function
main "$@"