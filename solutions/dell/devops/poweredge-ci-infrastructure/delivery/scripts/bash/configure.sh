#!/bin/bash
# Dell PowerEdge CI Infrastructure - Configuration Script
# Post-deployment configuration for CI/CD infrastructure

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.yml"
LOG_FILE="/var/log/poweredge-ci-config.log"

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
}

# Update system packages
update_system() {
    log "INFO" "Updating system packages..."
    
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get upgrade -y
        apt-get install -y curl wget git jq unzip software-properties-common
    elif command -v yum &> /dev/null; then
        yum update -y
        yum install -y curl wget git jq unzip
    else
        error_exit "Unsupported package manager"
    fi
    
    log "INFO" "System packages updated successfully"
}

# Install Docker
install_docker() {
    log "INFO" "Installing Docker..."
    
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
        usermod -aG docker $SUDO_USER 2>/dev/null || true
        rm get-docker.sh
    fi
    
    log "INFO" "Docker installed successfully"
}

# Install Jenkins
install_jenkins() {
    log "INFO" "Installing Jenkins..."
    
    if command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
        sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        apt-get update
        apt-get install -y openjdk-11-jdk jenkins
    elif command -v yum &> /dev/null; then
        # RHEL/CentOS
        yum install -y java-11-openjdk-devel
        wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        yum install -y jenkins
    fi
    
    systemctl enable jenkins
    systemctl start jenkins
    
    # Wait for Jenkins to start
    sleep 30
    
    log "INFO" "Jenkins installed successfully"
}

# Configure Jenkins
configure_jenkins() {
    log "INFO" "Configuring Jenkins..."
    
    # Get initial admin password
    local admin_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "")
    
    if [[ -n "$admin_password" ]]; then
        log "INFO" "Jenkins initial admin password: $admin_password"
        
        # Install recommended plugins
        java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:$admin_password install-plugin \
            ant build-timeout credentials-binding timestamper ws-cleanup \
            github-branch-source pipeline-github-lib workflow-aggregator \
            docker-workflow blueocean kubernetes kubernetes-cli \
            2>/dev/null || log "WARN" "Some Jenkins plugins failed to install"
    fi
    
    # Create Jenkins service user
    useradd -r -s /bin/false jenkins-service 2>/dev/null || true
    
    log "INFO" "Jenkins configured successfully"
}

# Install GitLab Runner
install_gitlab_runner() {
    log "INFO" "Installing GitLab Runner..."
    
    if command -v apt-get &> /dev/null; then
        curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
        apt-get install -y gitlab-runner
    elif command -v yum &> /dev/null; then
        curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
        yum install -y gitlab-runner
    fi
    
    systemctl enable gitlab-runner
    systemctl start gitlab-runner
    
    log "INFO" "GitLab Runner installed successfully"
}

# Install SonarQube
install_sonarqube() {
    log "INFO" "Installing SonarQube..."
    
    # Create SonarQube user
    useradd -r -s /bin/false sonarqube 2>/dev/null || true
    
    # Download and install SonarQube
    cd /opt
    wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
    unzip -q sonarqube-9.9.0.65466.zip
    mv sonarqube-9.9.0.65466 sonarqube
    chown -R sonarqube:sonarqube sonarqube
    rm sonarqube-9.9.0.65466.zip
    
    # Create systemd service
    cat > /etc/systemd/system/sonarqube.service << EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable sonarqube
    systemctl start sonarqube
    
    log "INFO" "SonarQube installed successfully"
}

# Install Nexus Repository
install_nexus() {
    log "INFO" "Installing Nexus Repository Manager..."
    
    # Create Nexus user
    useradd -r -s /bin/false nexus 2>/dev/null || true
    
    # Download and install Nexus
    cd /opt
    wget -q https://download.sonatype.com/nexus/3/nexus-3.42.0-01-unix.tar.gz
    tar -xzf nexus-3.42.0-01-unix.tar.gz
    mv nexus-3.42.0-01 nexus
    chown -R nexus:nexus nexus sonatype-work
    rm nexus-3.42.0-01-unix.tar.gz
    
    # Configure Nexus to run as nexus user
    echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc
    
    # Create systemd service
    cat > /etc/systemd/system/nexus.service << EOF
[Unit]
Description=Nexus Repository Manager
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Group=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable nexus
    systemctl start nexus
    
    log "INFO" "Nexus Repository Manager installed successfully"
}

# Configure monitoring
configure_monitoring() {
    log "INFO" "Configuring monitoring..."
    
    # Install Prometheus Node Exporter
    wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
    tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz
    mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
    rm -rf node_exporter-1.6.1.linux-amd64*
    
    # Create node_exporter user
    useradd -r -s /bin/false node_exporter 2>/dev/null || true
    
    # Create systemd service
    cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter
    
    log "INFO" "Monitoring configured successfully"
}

# Setup firewall rules
configure_firewall() {
    log "INFO" "Configuring firewall..."
    
    if command -v ufw &> /dev/null; then
        # Ubuntu/Debian
        ufw allow 22/tcp      # SSH
        ufw allow 8080/tcp    # Jenkins
        ufw allow 9000/tcp    # SonarQube
        ufw allow 8081/tcp    # Nexus
        ufw allow 9100/tcp    # Node Exporter
        echo "y" | ufw enable
    elif command -v firewall-cmd &> /dev/null; then
        # RHEL/CentOS
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --permanent --add-port=9000/tcp
        firewall-cmd --permanent --add-port=8081/tcp
        firewall-cmd --permanent --add-port=9100/tcp
        firewall-cmd --reload
    fi
    
    log "INFO" "Firewall configured successfully"
}

# Generate configuration summary
generate_summary() {
    log "INFO" "Generating configuration summary..."
    
    # Get service status
    local jenkins_status=$(systemctl is-active jenkins || echo "inactive")
    local sonarqube_status=$(systemctl is-active sonarqube || echo "inactive")
    local nexus_status=$(systemctl is-active nexus || echo "inactive")
    local docker_status=$(systemctl is-active docker || echo "inactive")
    
    cat << EOF | tee -a "$LOG_FILE"

================================================================================
DELL POWEREDGE CI INFRASTRUCTURE CONFIGURATION SUMMARY
================================================================================

Configuration Status: COMPLETED
Configuration Date: $(date)

Services Status:
- Docker: $docker_status
- Jenkins: $jenkins_status (http://$(hostname -I | awk '{print $1}'):8080)
- SonarQube: $sonarqube_status (http://$(hostname -I | awk '{print $1}'):9000)
- Nexus: $nexus_status (http://$(hostname -I | awk '{print $1}'):8081)
- GitLab Runner: $(systemctl is-active gitlab-runner || echo "inactive")
- Node Exporter: $(systemctl is-active node_exporter || echo "inactive")

Default Credentials:
- Jenkins: admin / $(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not found")
- SonarQube: admin / admin
- Nexus: admin / (Check /opt/sonatype-work/nexus3/admin.password)

Network Ports:
- SSH: 22
- Jenkins: 8080
- SonarQube: 9000
- Nexus: 8081
- Prometheus Node Exporter: 9100

Next Steps:
1. Complete initial setup for each service
2. Configure CI/CD pipelines
3. Set up backup procedures
4. Configure SSL certificates
5. Integrate with monitoring system

Documentation:
- Configuration: $CONFIG_FILE
- Logs: $LOG_FILE

================================================================================
EOF
}

# Main configuration function
main() {
    log "INFO" "Starting Dell PowerEdge CI Infrastructure configuration..."
    
    # Execute configuration steps
    check_root
    update_system
    install_docker
    install_jenkins
    configure_jenkins
    install_gitlab_runner
    install_sonarqube
    install_nexus
    configure_monitoring
    configure_firewall
    generate_summary
    
    log "INFO" "Dell PowerEdge CI Infrastructure configuration completed successfully!"
}

# Execute main function
main "$@"