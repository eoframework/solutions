# IBM Ansible Automation Platform - Configuration Templates

## Overview

This document provides comprehensive configuration templates for IBM Ansible Automation Platform deployment and management. These templates support various deployment scenarios and integration requirements.

## Platform Configuration Templates

### 1. Automation Controller Configuration

#### Basic Controller Configuration
```yaml
apiVersion: automationcontroller.ansible.com/v1beta1
kind: AutomationController
metadata:
  name: automation-controller
  namespace: ansible-automation
spec:
  # Basic Configuration
  replicas: 3
  admin_user: admin
  admin_password_secret: automation-controller-admin-password
  
  # License Configuration
  license_secret: automation-controller-license
  create_preload_data: true
  
  # Network Configuration
  route_tls_termination_mechanism: Edge
  route_host: "controller.automation.company.com"
  loadbalancer_protocol: https
  loadbalancer_port: 443
  
  # Database Configuration
  postgres_configuration_secret: postgres-admin-password
  postgres_data_path: /var/lib/postgresql/data/pgdata
  postgres_image: "registry.redhat.io/rhel8/postgresql-13:latest"
  postgres_storage_class: "gp3-csi"
  postgres_storage_requirements:
    requests:
      storage: 100Gi
  
  # Resource Configuration
  web_replicas: 3
  task_replicas: 3
  web_resource_requirements:
    requests:
      cpu: 2
      memory: 8Gi
    limits:
      cpu: 4
      memory: 16Gi
  task_resource_requirements:
    requests:
      cpu: 2
      memory: 8Gi
    limits:
      cpu: 4
      memory: 16Gi
  
  # Storage Configuration
  projects_persistence: true
  projects_storage_class: "gp3-csi"
  projects_storage_size: 50Gi
  projects_storage_access_mode: ReadWriteOnce
  
  # Security Configuration
  service_account_annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/automation-controller-role"
```

#### High Availability Controller Configuration
```yaml
apiVersion: automationcontroller.ansible.com/v1beta1
kind: AutomationController
metadata:
  name: automation-controller-ha
  namespace: ansible-automation
spec:
  # HA Configuration
  replicas: 5
  web_replicas: 5
  task_replicas: 5
  
  # Database HA
  postgres_configuration_secret: postgres-ha-config
  postgres_storage_requirements:
    requests:
      storage: 200Gi
  
  # Load Balancer Configuration
  loadbalancer_annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  
  # Anti-affinity Rules
  node_selector:
    kubernetes.io/os: linux
  
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "automation"
      effect: "NoSchedule"
  
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: "app.kubernetes.io/name"
                operator: In
                values: ["automation-controller"]
          topologyKey: "kubernetes.io/hostname"
```

### 2. Automation Hub Configuration

#### Basic Hub Configuration
```yaml
apiVersion: automationhub.ansible.com/v1beta1
kind: AutomationHub
metadata:
  name: automation-hub
  namespace: ansible-automation
spec:
  # Basic Configuration
  replicas: 2
  route_tls_termination_mechanism: Edge
  route_host: "hub.automation.company.com"
  loadbalancer_protocol: https
  loadbalancer_port: 443
  
  # Authentication
  admin_password_secret: automation-controller-admin-password
  
  # Database Configuration
  postgres_configuration_secret: postgres-admin-password
  postgres_storage_class: "gp3-csi"
  postgres_storage_requirements:
    requests:
      storage: 50Gi
  
  # File Storage Configuration
  file_storage_size: 100Gi
  file_storage_access_mode: ReadWriteMany
  file_storage_storage_class: "efs-csi"
  
  # Resource Configuration
  web_resource_requirements:
    requests:
      cpu: 1
      memory: 4Gi
    limits:
      cpu: 2
      memory: 8Gi
  
  # Content Configuration
  pulp_settings:
    content_origin: "https://hub.automation.company.com"
    ansible_api_hostname: "https://hub.automation.company.com"
    ansible_content_hostname: "https://hub.automation.company.com"
```

### 3. Event-Driven Ansible Configuration

#### Basic EDA Configuration
```yaml
apiVersion: eda.ansible.com/v1alpha1
kind: EDA
metadata:
  name: eda-controller
  namespace: ansible-automation
spec:
  # Basic Configuration
  replicas: 2
  route_tls_termination_mechanism: Edge
  route_host: "eda.automation.company.com"
  loadbalancer_protocol: https
  loadbalancer_port: 443
  
  # Authentication
  admin_password_secret: automation-controller-admin-password
  
  # Database Configuration
  postgres_configuration_secret: postgres-admin-password
  postgres_storage_class: "gp3-csi"
  postgres_storage_requirements:
    requests:
      storage: 20Gi
  
  # Resource Configuration
  api_resource_requirements:
    requests:
      cpu: 1
      memory: 2Gi
    limits:
      cpu: 2
      memory: 4Gi
  
  worker_resource_requirements:
    requests:
      cpu: 1
      memory: 2Gi
    limits:
      cpu: 2
      memory: 4Gi
  
  # Event Processing Configuration
  default_worker_replicas: 2
  max_running_activations: 12
  activation_worker_image: "quay.io/ansible/eda-server:latest"
```

## Infrastructure Configuration Templates

### 4. PostgreSQL Database Configuration

#### Standalone Database
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: ansible-automation
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
        - name: postgresql
          image: "registry.redhat.io/rhel8/postgresql-13:latest"
          env:
            - name: POSTGRESQL_DATABASE
              value: "automation_controller"
            - name: POSTGRESQL_USER
              value: "awx"
            - name: POSTGRESQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-admin-password
                  key: password
          ports:
            - containerPort: 5432
          resources:
            requests:
              cpu: 2
              memory: 8Gi
            limits:
              cpu: 4
              memory: 16Gi
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/pgsql/data
      volumes:
        - name: postgresql-data
          persistentVolumeClaim:
            claimName: postgresql-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-data
  namespace: ansible-automation
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: gp3-csi
```

#### High Availability Database (PostgreSQL Cluster)
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-cluster
  namespace: ansible-automation
spec:
  instances: 3
  
  postgresql:
    parameters:
      max_connections: "200"
      shared_buffers: "256MB"
      effective_cache_size: "1GB"
      maintenance_work_mem: "64MB"
      checkpoint_completion_target: "0.9"
      wal_buffers: "16MB"
      default_statistics_target: "100"
      random_page_cost: "1.1"
      effective_io_concurrency: "200"
  
  bootstrap:
    initdb:
      database: automation_controller
      owner: awx
      secret:
        name: postgres-cluster-credentials
  
  storage:
    size: 200Gi
    storageClass: gp3-csi
  
  resources:
    requests:
      memory: "8Gi"
      cpu: 2
    limits:
      memory: "16Gi"
      cpu: 4
  
  monitoring:
    enabled: true
    podMonitorEnabled: true
  
  backup:
    barmanObjectStore:
      serverName: "postgres-cluster"
      wal:
        retention: "7d"
      data:
        retention: "30d"
      s3Credentials:
        accessKeyId:
          name: backup-credentials
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: backup-credentials
          key: SECRET_ACCESS_KEY
      destinationPath: "s3://automation-platform-backups/postgres"
      endpointURL: "https://s3.us-east-1.amazonaws.com"
```

### 5. Network Configuration Templates

#### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: automation-platform-network-policy
  namespace: ansible-automation
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/part-of: automation-controller
  policyTypes:
    - Ingress
    - Egress
  
  ingress:
    # Allow ingress from OpenShift router
    - from:
        - namespaceSelector:
            matchLabels:
              name: openshift-ingress
      ports:
        - protocol: TCP
          port: 8080
    
    # Allow database connections
    - from:
        - podSelector:
            matchLabels:
              app: postgresql
      ports:
        - protocol: TCP
          port: 5432
  
  egress:
    # Allow DNS resolution
    - to: []
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    
    # Allow HTTPS outbound
    - to: []
      ports:
        - protocol: TCP
          port: 443
    
    # Allow database connections
    - to:
        - podSelector:
            matchLabels:
              app: postgresql
      ports:
        - protocol: TCP
          port: 5432
```

#### Service Configuration
```yaml
apiVersion: v1
kind: Service
metadata:
  name: automation-controller-service
  namespace: ansible-automation
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:region:account:certificate/cert-id"
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: automation-controller
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 8080
      protocol: TCP
  loadBalancerSourceRanges:
    - 10.0.0.0/16
    - 192.168.0.0/16
```

## Security Configuration Templates

### 6. RBAC Configuration

#### Custom Roles
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ansible-automation
  name: automation-controller-operator
rules:
  - apiGroups: [""]
    resources: ["secrets", "configmaps", "services", "persistentvolumeclaims"]
    verbs: ["get", "list", "create", "update", "patch", "delete"]
  
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "create", "update", "patch", "delete"]
  
  - apiGroups: ["automationcontroller.ansible.com"]
    resources: ["automationcontrollers"]
    verbs: ["get", "list", "create", "update", "patch", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: automation-controller-operator
  namespace: ansible-automation
subjects:
  - kind: ServiceAccount
    name: automation-controller-operator
    namespace: ansible-automation
roleRef:
  kind: Role
  name: automation-controller-operator
  apiGroup: rbac.authorization.k8s.io
```

#### Security Context Constraints
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: automation-controller-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
defaultAddCapabilities: []
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - ALL
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
users:
  - system:serviceaccount:ansible-automation:automation-controller-operator
```

### 7. Secret Management Templates

#### TLS Certificate Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: automation-controller-tls
  namespace: ansible-automation
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # Base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # Base64 encoded private key
```

#### Database Credentials Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-admin-password
  namespace: ansible-automation
type: Opaque
stringData:
  password: "SecurePassword123!"
  host: "postgresql.ansible-automation.svc.cluster.local"
  port: "5432"
  database: "automation_controller"
  username: "awx"
  type: "managed"
  sslmode: "prefer"
```

#### License Manifest Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: automation-controller-license
  namespace: ansible-automation
type: Opaque
data:
  manifest.zip: UEsDBAoAAAAAAIdeuVQAAAAAAAAAAAAAAAAJAAAAbGljZW5zZXMvUEsDBAoAAAAAAIde...
```

## Integration Configuration Templates

### 8. SAML Authentication Configuration

#### SAML Identity Provider
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: saml-configuration
  namespace: ansible-automation
data:
  SOCIAL_AUTH_SAML_SP_ENTITY_ID: "https://controller.automation.company.com"
  SOCIAL_AUTH_SAML_SP_PUBLIC_CERT: |
    -----BEGIN CERTIFICATE-----
    MIIDXTCCAkWgAwIBAgIJAKoK/heBjcOuMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV
    ...
    -----END CERTIFICATE-----
  SOCIAL_AUTH_SAML_SP_PRIVATE_KEY: |
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDGGPF1p/5IYQDK
    ...
    -----END PRIVATE KEY-----
  SOCIAL_AUTH_SAML_ORG_INFO: |
    {
      "en-US": {
        "name": "Example Company",
        "displayname": "Example Company Authentication",
        "url": "https://automation.company.com"
      }
    }
  SOCIAL_AUTH_SAML_TECHNICAL_CONTACT: |
    {
      "givenName": "Tech Support",
      "emailAddress": "tech-support@company.com"
    }
  SOCIAL_AUTH_SAML_SUPPORT_CONTACT: |
    {
      "givenName": "Support Team",
      "emailAddress": "support@company.com"
    }
  SOCIAL_AUTH_SAML_ENABLED_IDPS: |
    {
      "example_idp": {
        "entity_id": "https://idp.company.com/metadata",
        "url": "https://idp.company.com/sso",
        "x509cert": "MIIC...",
        "attr_user_permanent_id": "name_id",
        "attr_first_name": "first_name",
        "attr_last_name": "last_name",
        "attr_username": "username",
        "attr_email": "email"
      }
    }
```

### 9. Monitoring Configuration Templates

#### ServiceMonitor for Prometheus
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: automation-controller-metrics
  namespace: ansible-automation
  labels:
    app: automation-controller
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: automation-controller
  endpoints:
    - port: http-metrics
      interval: 30s
      path: /metrics
      scheme: http
  namespaceSelector:
    matchNames:
      - ansible-automation
```

#### Grafana Dashboard ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: automation-controller-dashboard
  namespace: ansible-automation
  labels:
    grafana_dashboard: "1"
data:
  automation-controller.json: |
    {
      "dashboard": {
        "id": null,
        "title": "Ansible Automation Platform",
        "tags": ["ansible", "automation"],
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "Job Success Rate",
            "type": "stat",
            "targets": [
              {
                "expr": "ansible_automation_controller_job_success_total / ansible_automation_controller_job_total * 100",
                "legendFormat": "Success Rate %"
              }
            ],
            "fieldConfig": {
              "defaults": {
                "unit": "percent",
                "min": 0,
                "max": 100
              }
            }
          },
          {
            "id": 2,
            "title": "Active Jobs",
            "type": "graph",
            "targets": [
              {
                "expr": "ansible_automation_controller_jobs_running",
                "legendFormat": "Running Jobs"
              }
            ]
          },
          {
            "id": 3,
            "title": "Platform Health",
            "type": "table",
            "targets": [
              {
                "expr": "up{job='automation-controller'}",
                "legendFormat": "{{instance}}"
              }
            ]
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

### 10. Backup Configuration Templates

#### Database Backup CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: ansible-automation
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: pg-dump
              image: registry.redhat.io/rhel8/postgresql-13:latest
              env:
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: postgres-admin-password
                      key: password
                - name: PGHOST
                  valueFrom:
                    secretKeyRef:
                      name: postgres-admin-password
                      key: host
                - name: PGUSER
                  valueFrom:
                    secretKeyRef:
                      name: postgres-admin-password
                      key: username
                - name: PGDATABASE
                  valueFrom:
                    secretKeyRef:
                      name: postgres-admin-password
                      key: database
              command:
                - /bin/bash
                - -c
                - |
                  DATE=$(date +%Y%m%d_%H%M%S)
                  pg_dump --no-password --verbose --format=custom \
                    --file=/backup/automation_controller_backup_${DATE}.dump
                  
                  # Upload to S3
                  aws s3 cp /backup/automation_controller_backup_${DATE}.dump \
                    s3://automation-platform-backups/database/
                  
                  # Clean up local file
                  rm /backup/automation_controller_backup_${DATE}.dump
              volumeMounts:
                - name: backup-storage
                  mountPath: /backup
          volumes:
            - name: backup-storage
              emptyDir: {}
          restartPolicy: OnFailure
```

## Configuration Validation

### Health Check Templates
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: health-check-scripts
  namespace: ansible-automation
data:
  check-controller.sh: |
    #!/bin/bash
    # Health check script for Automation Controller
    
    CONTROLLER_URL="https://controller.automation.company.com"
    
    # Check API endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" \
      -k "${CONTROLLER_URL}/api/v2/ping/")
    
    if [ "$response" -eq 200 ]; then
      echo "Controller API: HEALTHY"
      exit 0
    else
      echo "Controller API: UNHEALTHY (HTTP $response)"
      exit 1
    fi
  
  check-hub.sh: |
    #!/bin/bash
    # Health check script for Automation Hub
    
    HUB_URL="https://hub.automation.company.com"
    
    # Check API endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" \
      -k "${HUB_URL}/pulp/api/v3/status/")
    
    if [ "$response" -eq 200 ]; then
      echo "Hub API: HEALTHY"
      exit 0
    else
      echo "Hub API: UNHEALTHY (HTTP $response)"
      exit 1
    fi
  
  check-database.sh: |
    #!/bin/bash
    # Health check script for PostgreSQL
    
    pg_isready -h postgresql.ansible-automation.svc.cluster.local -p 5432
    
    if [ $? -eq 0 ]; then
      echo "Database: HEALTHY"
      exit 0
    else
      echo "Database: UNHEALTHY"
      exit 1
    fi
```

---

These configuration templates provide a solid foundation for deploying and managing IBM Ansible Automation Platform in production environments. Customize the templates based on your specific requirements, security policies, and infrastructure constraints.