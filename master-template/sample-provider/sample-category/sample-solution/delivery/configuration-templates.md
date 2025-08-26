# Configuration Templates

## Overview
This document provides standard configuration templates and settings for the solution implementation. All configurations should be customized for specific environments and requirements.

---

## Infrastructure Configuration

### Environment Variables Template
```bash
# Application Configuration
APP_NAME="[Solution Name]"
APP_VERSION="1.0.0"
APP_ENVIRONMENT="[development|staging|production]"
APP_PORT="8080"
APP_LOG_LEVEL="[debug|info|warn|error]"

# Database Configuration
DB_HOST="[database-host]"
DB_PORT="5432"
DB_NAME="[database-name]"
DB_USERNAME="[username]"
DB_PASSWORD="[password]"
DB_SSL_MODE="require"
DB_POOL_MIN="5"
DB_POOL_MAX="20"

# Cache Configuration
CACHE_HOST="[cache-host]"
CACHE_PORT="6379"
CACHE_PASSWORD="[password]"
CACHE_TTL="3600"

# Security Configuration
JWT_SECRET="[jwt-secret-key]"
ENCRYPTION_KEY="[encryption-key]"
API_KEY="[api-key]"
CORS_ORIGINS="[allowed-origins]"

# External Service Configuration
SERVICE_ENDPOINT="[external-service-url]"
SERVICE_API_KEY="[service-api-key]"
SERVICE_TIMEOUT="30000"

# Monitoring Configuration
METRICS_ENABLED="true"
HEALTH_CHECK_PATH="/health"
PROMETHEUS_PORT="9090"
```

### Network Configuration Template
```yaml
# network-config.yml
network:
  vpc:
    cidr: "10.0.0.0/16"
    enable_dns_hostnames: true
    enable_dns_support: true
    
  subnets:
    public:
      - cidr: "10.0.1.0/24"
        availability_zone: "us-east-1a"
      - cidr: "10.0.2.0/24"
        availability_zone: "us-east-1b"
    
    private:
      - cidr: "10.0.10.0/24"
        availability_zone: "us-east-1a"
      - cidr: "10.0.11.0/24"
        availability_zone: "us-east-1b"
    
    database:
      - cidr: "10.0.20.0/24"
        availability_zone: "us-east-1a"
      - cidr: "10.0.21.0/24"
        availability_zone: "us-east-1b"

  security_groups:
    web_tier:
      ingress:
        - port: 80
          protocol: "tcp"
          source: "0.0.0.0/0"
        - port: 443
          protocol: "tcp"
          source: "0.0.0.0/0"
      egress:
        - port: 0
          protocol: "-1"
          destination: "0.0.0.0/0"
    
    app_tier:
      ingress:
        - port: 8080
          protocol: "tcp"
          source_security_group: "web_tier"
      egress:
        - port: 0
          protocol: "-1"
          destination: "0.0.0.0/0"
    
    database_tier:
      ingress:
        - port: 5432
          protocol: "tcp"
          source_security_group: "app_tier"
```

### Load Balancer Configuration
```yaml
# load-balancer-config.yml
load_balancer:
  type: "application"
  scheme: "internet-facing"
  
  listeners:
    - port: 80
      protocol: "HTTP"
      default_actions:
        - type: "redirect"
          redirect:
            protocol: "HTTPS"
            port: "443"
            status_code: "HTTP_301"
    
    - port: 443
      protocol: "HTTPS"
      ssl_policy: "ELBSecurityPolicy-TLS-1-2-2017-01"
      certificate_arn: "[certificate-arn]"
      default_actions:
        - type: "forward"
          target_group_arn: "[target-group-arn]"

  target_group:
    protocol: "HTTP"
    port: 8080
    health_check:
      path: "/health"
      interval: 30
      timeout: 5
      healthy_threshold: 2
      unhealthy_threshold: 5
      matcher: "200"
```

---

## Application Configuration

### Database Configuration Template
```yaml
# database-config.yml
database:
  primary:
    host: "[primary-db-host]"
    port: 5432
    database: "[database-name]"
    username: "[username]"
    password: "[password]"
    ssl_mode: "require"
    
  connection_pool:
    min_connections: 5
    max_connections: 20
    connection_timeout: 30
    idle_timeout: 600
    max_lifetime: 3600
    
  backup:
    enabled: true
    retention_days: 30
    backup_window: "03:00-04:00"
    maintenance_window: "Sun:04:00-Sun:05:00"
    
  monitoring:
    slow_query_log: true
    slow_query_threshold: 2.0
    log_statement: "all"
    log_min_duration: 1000

read_replicas:
  - host: "[replica-1-host]"
    port: 5432
    lag_threshold: 100
  - host: "[replica-2-host]"
    port: 5432
    lag_threshold: 100
```

### Application Server Configuration
```yaml
# app-server-config.yml
server:
  port: 8080
  address: "0.0.0.0"
  
  servlet:
    context-path: "/"
    session:
      timeout: 30m
      cookie:
        secure: true
        http-only: true
        same-site: "strict"

  ssl:
    enabled: true
    key-store: "[keystore-path]"
    key-store-password: "[password]"
    key-store-type: "JKS"
    trust-store: "[truststore-path]"
    trust-store-password: "[password]"

  compression:
    enabled: true
    mime-types: "text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json"
    min-response-size: 1024

management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,prometheus"
  endpoint:
    health:
      show-details: "when-authorized"
```

### Caching Configuration
```yaml
# cache-config.yml
redis:
  host: "[redis-host]"
  port: 6379
  password: "[password]"
  database: 0
  ssl: true
  
  pool:
    max-active: 20
    max-idle: 10
    min-idle: 5
    max-wait: 30000
    
  sentinel:
    master: "[master-name]"
    nodes:
      - "[sentinel-1]:26379"
      - "[sentinel-2]:26379"
      - "[sentinel-3]:26379"

cache_policies:
  user_sessions:
    ttl: 3600
    max_size: 10000
    eviction_policy: "LRU"
    
  application_data:
    ttl: 1800
    max_size: 5000
    eviction_policy: "LFU"
    
  static_content:
    ttl: 86400
    max_size: 1000
    eviction_policy: "FIFO"
```

---

## Security Configuration

### Authentication Configuration
```yaml
# auth-config.yml
authentication:
  jwt:
    secret: "[jwt-secret]"
    expiration: 3600
    refresh_expiration: 86400
    algorithm: "HS256"
    
  oauth2:
    client_id: "[client-id]"
    client_secret: "[client-secret]"
    redirect_uri: "[redirect-uri]"
    scope: "openid profile email"
    
  ldap:
    url: "[ldap-url]"
    base_dn: "[base-dn]"
    user_dn: "[user-dn]"
    password: "[password]"
    user_search_filter: "(uid={0})"
    group_search_base: "[group-base]"
    group_search_filter: "(member={0})"

password_policy:
  min_length: 8
  require_uppercase: true
  require_lowercase: true
  require_numbers: true
  require_special_chars: true
  max_age_days: 90
  history_count: 5
```

### Authorization Configuration
```yaml
# rbac-config.yml
roles:
  admin:
    permissions:
      - "users:read"
      - "users:write"
      - "users:delete"
      - "system:admin"
      - "reports:all"
      
  manager:
    permissions:
      - "users:read"
      - "users:write"
      - "reports:team"
      - "data:read"
      
  user:
    permissions:
      - "profile:read"
      - "profile:write"
      - "data:read"
      
  guest:
    permissions:
      - "public:read"

permission_matrix:
  endpoints:
    "/api/users":
      GET: ["admin", "manager"]
      POST: ["admin"]
      PUT: ["admin", "manager"]
      DELETE: ["admin"]
      
    "/api/reports":
      GET: ["admin", "manager", "user"]
      POST: ["admin", "manager"]
      
    "/api/profile":
      GET: ["admin", "manager", "user"]
      PUT: ["admin", "manager", "user"]
```

### Security Headers Configuration
```yaml
# security-headers.yml
security_headers:
  content_security_policy:
    default_src: "'self'"
    script_src: "'self' 'unsafe-inline'"
    style_src: "'self' 'unsafe-inline'"
    img_src: "'self' data: https:"
    connect_src: "'self'"
    font_src: "'self'"
    frame_ancestors: "'none'"
    
  strict_transport_security:
    max_age: 31536000
    include_subdomains: true
    preload: true
    
  x_frame_options: "DENY"
  x_content_type_options: "nosniff"
  x_xss_protection: "1; mode=block"
  referrer_policy: "strict-origin-when-cross-origin"
  
  cors:
    allowed_origins:
      - "[allowed-domain-1]"
      - "[allowed-domain-2]"
    allowed_methods:
      - "GET"
      - "POST"
      - "PUT"
      - "DELETE"
    allowed_headers:
      - "Content-Type"
      - "Authorization"
      - "X-Requested-With"
    max_age: 3600
```

---

## Monitoring Configuration

### Logging Configuration
```yaml
# logging-config.yml
logging:
  level:
    root: "INFO"
    com.company.app: "DEBUG"
    org.springframework: "WARN"
    org.hibernate: "WARN"
    
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    
  file:
    name: "/var/log/app/application.log"
    max-size: "100MB"
    max-history: 30
    total-size-cap: "1GB"
    
  loggers:
    security:
      name: "SECURITY"
      level: "INFO"
      additivity: false
      appenders: ["SECURITY_FILE"]
      
    audit:
      name: "AUDIT"
      level: "INFO"
      additivity: false
      appenders: ["AUDIT_FILE"]
      
    performance:
      name: "PERFORMANCE"
      level: "DEBUG"
      additivity: false
      appenders: ["PERFORMANCE_FILE"]
```

### Metrics Configuration
```yaml
# metrics-config.yml
metrics:
  export:
    prometheus:
      enabled: true
      port: 9090
      path: "/metrics"
      
    cloudwatch:
      enabled: true
      namespace: "[application-namespace]"
      batch_size: 20
      
  custom_metrics:
    business_metrics:
      - name: "orders_processed"
        type: "counter"
        description: "Total number of orders processed"
        
      - name: "order_processing_time"
        type: "timer"
        description: "Time taken to process orders"
        
      - name: "active_users"
        type: "gauge"
        description: "Number of active users"
        
    technical_metrics:
      - name: "database_connections"
        type: "gauge"
        description: "Active database connections"
        
      - name: "cache_hit_ratio"
        type: "gauge"
        description: "Cache hit ratio percentage"
        
      - name: "api_response_time"
        type: "timer"
        description: "API response time"
```

### Health Check Configuration
```yaml
# health-check-config.yml
health:
  indicators:
    database:
      enabled: true
      timeout: 10s
      query: "SELECT 1"
      
    redis:
      enabled: true
      timeout: 5s
      
    external_service:
      enabled: true
      url: "[external-service-health-url]"
      timeout: 10s
      
    disk_space:
      enabled: true
      threshold: 85
      path: "/"
      
    memory:
      enabled: true
      threshold: 90
      
  endpoint:
    path: "/health"
    show_details: "when_authorized"
    
  circuit_breaker:
    enabled: true
    failure_threshold: 5
    recovery_timeout: 30s
    monitor_interval: 10s
```

---

## Backup and Recovery Configuration

### Backup Configuration
```yaml
# backup-config.yml
backup:
  database:
    type: "automated"
    schedule: "0 3 * * *"  # Daily at 3 AM
    retention:
      daily: 7
      weekly: 4
      monthly: 12
      yearly: 7
    encryption: true
    compression: true
    
  application_data:
    type: "snapshot"
    schedule: "0 2 * * *"  # Daily at 2 AM
    retention: 30
    incremental: true
    
  configuration:
    type: "git"
    repository: "[config-repo-url]"
    branch: "main"
    schedule: "0 1 * * *"  # Daily at 1 AM
    
  logs:
    type: "archive"
    schedule: "0 4 * * *"  # Daily at 4 AM
    retention: 90
    compression: true
    destination: "[archive-location]"

recovery:
  rto: 4  # Recovery Time Objective in hours
  rpo: 1  # Recovery Point Objective in hours
  
  procedures:
    database:
      - "Stop application services"
      - "Restore database from backup"
      - "Verify data integrity"
      - "Start application services"
      - "Validate functionality"
      
    application:
      - "Deploy previous version"
      - "Restore configuration"
      - "Restart services"
      - "Verify connectivity"
      - "Test critical functions"
```

---

## Performance Tuning Configuration

### JVM Configuration (Java Applications)
```bash
# jvm-config.sh
export JAVA_OPTS="
-Xms2g
-Xmx4g
-XX:NewRatio=3
-XX:SurvivorRatio=8
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
-XX:+UseStringDeduplication
-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=10M
-Xloggc:/var/log/app/gc.log
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/var/log/app/
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Duser.timezone=UTC
"
```

### Database Performance Configuration
```sql
-- Database performance settings
-- PostgreSQL configuration

-- Memory settings
shared_buffers = '1GB'
effective_cache_size = '3GB'
work_mem = '16MB'
maintenance_work_mem = '256MB'

-- Checkpoint settings
checkpoint_completion_target = 0.9
wal_buffers = '16MB'
default_statistics_target = 100

-- Connection settings
max_connections = 100
shared_preload_libraries = 'pg_stat_statements'

-- Logging settings
log_statement = 'all'
log_min_duration_statement = 1000
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
```

---

## Deployment Configuration

### CI/CD Pipeline Configuration
```yaml
# .github/workflows/deploy.yml
name: Deploy Application

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  APPLICATION_NAME: "[app-name]"

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up environment
        run: |
          # Setup commands
      - name: Run tests
        run: |
          # Test commands
          
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build application
        run: |
          # Build commands
      - name: Build Docker image
        run: |
          # Docker build commands
          
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
        run: |
          # Staging deployment
      - name: Run integration tests
        run: |
          # Integration tests
      - name: Deploy to production
        run: |
          # Production deployment
```

### Kubernetes Configuration
```yaml
# kubernetes-config.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "[app-name]"
  namespace: "[namespace]"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: "[app-name]"
  template:
    metadata:
      labels:
        app: "[app-name]"
    spec:
      containers:
      - name: "[app-name]"
        image: "[image-registry]/[app-name]:latest"
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: "[app-name]-service"
  namespace: "[namespace]"
spec:
  selector:
    app: "[app-name]"
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

---

## Configuration Management

### Environment-Specific Configurations

#### Development Environment
```yaml
# config/development.yml
environment: development
debug: true
database:
  host: "localhost"
  port: 5432
  name: "app_dev"
logging:
  level: DEBUG
security:
  strict: false
```

#### Staging Environment
```yaml
# config/staging.yml
environment: staging
debug: false
database:
  host: "[staging-db-host]"
  port: 5432
  name: "app_staging"
logging:
  level: INFO
security:
  strict: true
```

#### Production Environment
```yaml
# config/production.yml
environment: production
debug: false
database:
  host: "[production-db-host]"
  port: 5432
  name: "app_production"
logging:
  level: WARN
security:
  strict: true
```

### Configuration Validation Script
```bash
#!/bin/bash
# validate-config.sh

echo "Validating configuration..."

# Check required environment variables
required_vars=("DB_HOST" "DB_PASSWORD" "JWT_SECRET" "API_KEY")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# Validate configuration file syntax
if ! yaml_checker config/application.yml; then
    echo "ERROR: Invalid YAML syntax in configuration file"
    exit 1
fi

# Test database connectivity
if ! pg_isready -h "$DB_HOST" -p "$DB_PORT"; then
    echo "ERROR: Cannot connect to database"
    exit 1
fi

echo "Configuration validation successful"
```

---

**Usage Instructions:**

1. **Customize Values:** Replace all `[placeholder]` values with environment-specific settings
2. **Security:** Store sensitive values (passwords, keys) in secure configuration management systems
3. **Validation:** Use the validation scripts to verify configuration before deployment
4. **Version Control:** Track configuration changes in version control with proper access controls
5. **Documentation:** Maintain documentation for all configuration changes and their purposes

**File Formats:** These templates should be saved as:
- `.yml` or `.yaml` files for YAML configurations
- `.properties` files for Java properties
- `.env` files for environment variables
- `.sh` files for shell scripts