# IBM OpenShift Container Platform - Configuration Templates

## Document Information
**Solution**: IBM OpenShift Container Platform  
**Version**: 4.14  
**Date**: January 2025  
**Audience**: Platform Engineers, DevOps Teams, System Administrators  

---

## Overview

This document provides comprehensive configuration templates for IBM OpenShift Container Platform deployments. These templates serve as starting points for common configurations and can be customized based on specific requirements.

### Template Categories
- **Cluster Configuration**: Core cluster settings and parameters
- **Infrastructure Configuration**: Node, storage, and network configurations
- **Security Configuration**: Authentication, authorization, and security policies
- **Application Configuration**: Application deployment and service templates
- **Monitoring and Logging**: Observability stack configurations
- **Integration Configuration**: External system integration templates

---

## Cluster Configuration Templates

### Install Configuration (install-config.yaml)

#### Basic AWS Cluster Configuration
```yaml
# install-config.yaml - AWS Deployment
apiVersion: v1
baseDomain: company.com
metadata:
  name: openshift-prod
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 4000
        size: 500
        type: io1
      type: m5.4xlarge
      zones:
      - us-east-1a
      - us-east-1b
      - us-east-1c
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 4000
        size: 200
        type: io1
      type: m5.2xlarge
      zones:
      - us-east-1a
      - us-east-1b
      - us-east-1c
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: us-east-1
    userTags:
      Department: IT
      Environment: Production
      Project: OpenShift
pullSecret: |
  {"auths":{"cloud.openshift.com":{"auth":"TOKEN"}}}
sshKey: |
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... admin@company.com
```

#### Azure Cluster Configuration
```yaml
# install-config.yaml - Azure Deployment
apiVersion: v1
baseDomain: company.com
metadata:
  name: openshift-prod
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
  platform:
    azure:
      osDisk:
        diskSizeGB: 500
        diskType: Premium_LRS
      type: Standard_D8s_v3
      zones:
      - "1"
      - "2"
      - "3"
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    azure:
      osDisk:
        diskSizeGB: 200
        diskType: Premium_LRS
      type: Standard_D4s_v3
      zones:
      - "1"
      - "2"
      - "3"
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  azure:
    baseDomainResourceGroupName: openshift-dns-rg
    region: eastus
    resourceGroupName: openshift-cluster-rg
    outboundType: Loadbalancer
pullSecret: |
  {"auths":{"cloud.openshift.com":{"auth":"TOKEN"}}}
sshKey: |
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... admin@company.com
```

#### VMware vSphere Configuration
```yaml
# install-config.yaml - vSphere Deployment
apiVersion: v1
baseDomain: company.local
metadata:
  name: openshift-prod
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
  platform:
    vsphere:
      cpus: 8
      coresPerSocket: 4
      memoryMB: 32768
      osDisk:
        diskSizeGB: 500
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    vsphere:
      cpus: 4
      coresPerSocket: 2
      memoryMB: 16384
      osDisk:
        diskSizeGB: 200
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  vsphere:
    vCenter: vcenter.company.local
    username: administrator@vsphere.local
    password: VMware123!
    datacenter: Company-DC
    defaultDatastore: Company-Datastore
    folder: "/Company-DC/vm/OpenShift"
    network: VM-Network
    cluster: Company-Cluster
    apiVIP: 192.168.100.10
    ingressVIP: 192.168.100.11
pullSecret: |
  {"auths":{"cloud.openshift.com":{"auth":"TOKEN"}}}
sshKey: |
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... admin@company.com
```

---

## Infrastructure Configuration Templates

### MachineSet Configuration

#### Additional Worker Nodes
```yaml
# machineset-workers.yaml
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
  name: openshift-prod-worker-us-east-1d
  namespace: openshift-machine-api
spec:
  replicas: 2
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
      machine.openshift.io/cluster-api-machineset: openshift-prod-worker-us-east-1d
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: openshift-prod-worker-us-east-1d
    spec:
      metadata:
        labels:
          node-role.kubernetes.io/worker: ""
      providerSpec:
        value:
          ami:
            id: ami-0123456789abcdef0
          apiVersion: awsproviderconfig.openshift.io/v1beta1
          blockDevices:
          - ebs:
              iops: 3000
              volumeSize: 500
              volumeType: gp3
          credentialsSecret:
            name: aws-cloud-credentials
          deviceIndex: 0
          iamInstanceProfile:
            id: openshift-prod-abc123-worker-profile
          instanceType: m5.4xlarge
          kind: AWSMachineProviderConfig
          placement:
            availabilityZone: us-east-1d
            region: us-east-1
          securityGroups:
          - filters:
            - name: tag:Name
              values:
              - openshift-prod-abc123-worker-sg
          subnet:
            filters:
            - name: tag:Name
              values:
              - openshift-prod-abc123-private-us-east-1d
          tags:
          - name: kubernetes.io/cluster/openshift-prod-abc123
            value: owned
          - name: Name
            value: openshift-prod-abc123-worker
          userDataSecret:
            name: worker-user-data
```

#### Infrastructure Nodes
```yaml
# machineset-infra.yaml
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
  name: openshift-prod-infra-us-east-1a
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
      machine.openshift.io/cluster-api-machineset: openshift-prod-infra-us-east-1a
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: openshift-prod-abc123
        machine.openshift.io/cluster-api-machine-role: infra
        machine.openshift.io/cluster-api-machine-type: infra
        machine.openshift.io/cluster-api-machineset: openshift-prod-infra-us-east-1a
    spec:
      metadata:
        labels:
          node-role.kubernetes.io/infra: ""
      taints:
      - key: node-role.kubernetes.io/infra
        effect: NoSchedule
      providerSpec:
        value:
          ami:
            id: ami-0123456789abcdef0
          apiVersion: awsproviderconfig.openshift.io/v1beta1
          blockDevices:
          - ebs:
              iops: 2000
              volumeSize: 200
              volumeType: gp3
          credentialsSecret:
            name: aws-cloud-credentials
          deviceIndex: 0
          iamInstanceProfile:
            id: openshift-prod-abc123-worker-profile
          instanceType: m5.2xlarge
          kind: AWSMachineProviderConfig
          placement:
            availabilityZone: us-east-1a
            region: us-east-1
          securityGroups:
          - filters:
            - name: tag:Name
              values:
              - openshift-prod-abc123-worker-sg
          subnet:
            filters:
            - name: tag:Name
              values:
              - openshift-prod-abc123-private-us-east-1a
          tags:
          - name: kubernetes.io/cluster/openshift-prod-abc123
            value: owned
          - name: Name
            value: openshift-prod-abc123-infra
          userDataSecret:
            name: worker-user-data
```

### Storage Configuration

#### AWS EBS StorageClass
```yaml
# storageclass-ebs-gp3.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

#### OpenShift Container Storage (OCS)
```yaml
# ocs-storagecluster.yaml
apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
  name: ocs-storagecluster
  namespace: openshift-storage
spec:
  arbiter: {}
  encryption:
    kms: {}
  externalStorage: {}
  managedResources:
    cephBlockPools:
      reconcileStrategy: manage
    cephConfig:
      reconcileStrategy: manage
    cephFilesystems:
      reconcileStrategy: manage
    cephObjectStoreUsers:
      reconcileStrategy: manage
    cephObjectStores:
      reconcileStrategy: manage
  mirroring: {}
  nodeTopologies: {}
  storageDeviceSets:
  - count: 1
    dataPVCTemplate:
      metadata:
        creationTimestamp: null
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 2Ti
        storageClassName: ebs-gp3
        volumeMode: Block
      status: {}
    name: ocs-deviceset-ebs-gp3
    placement: {}
    replica: 3
    resources:
      limits:
        cpu: "2"
        memory: 5Gi
      requests:
        cpu: "1"
        memory: 5Gi
```

---

## Security Configuration Templates

### Authentication Configuration

#### OAuth with LDAP Integration
```yaml
# oauth-ldap.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: company-ldap
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: cn=oauth,ou=service,dc=company,dc=com
      bindPassword:
        name: ldap-bind-password
      ca:
        name: ca-config-map
      insecure: false
      url: ldaps://ldap.company.com:636/ou=users,dc=company,dc=com?uid
  - name: company-ldap-groups
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: cn=oauth,ou=service,dc=company,dc=com
      bindPassword:
        name: ldap-bind-password
      ca:
        name: ca-config-map
      insecure: false
      url: ldaps://ldap.company.com:636/ou=groups,dc=company,dc=com?cn
```

#### RBAC Configuration
```yaml
# rbac-cluster-admin.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-openshift-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: openshift-admins

---
# rbac-project-admin.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: self-provisioner-developers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: self-provisioner
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: developers
```

### Security Context Constraints (SCC)
```yaml
# scc-restricted-v2.yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: restricted-v2
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1
    max: 65535
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1
    max: 65535
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

### Network Policies
```yaml
# networkpolicy-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# networkpolicy-allow-frontend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: openshift-ingress
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3000
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

---

## Application Configuration Templates

### Deployment Configuration
```yaml
# deployment-webapp.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: production
  labels:
    app: webapp
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        version: v1.0.0
    spec:
      containers:
      - name: webapp
        image: registry.redhat.io/ubi8/nodejs-16:latest
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: connection-string
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: app-config
          mountPath: /opt/app-root/src/config
          readOnly: true
      volumes:
      - name: app-config
        configMap:
          name: webapp-config
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      tolerations:
      - key: "node.kubernetes.io/unreachable"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 6000
      - key: "node.kubernetes.io/not-ready"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 6000
```

### Service and Route Configuration
```yaml
# service-webapp.yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp
  namespace: production
  labels:
    app: webapp
spec:
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP

---
# route-webapp.yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: webapp
  namespace: production
  labels:
    app: webapp
spec:
  host: webapp.apps.openshift-prod.company.com
  to:
    kind: Service
    name: webapp
    weight: 100
  port:
    targetPort: http
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
  wildcardPolicy: None
```

### Persistent Volume Claim
```yaml
# pvc-webapp-data.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webapp-data
  namespace: production
  labels:
    app: webapp
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: ebs-gp3
```

---

## Monitoring Configuration Templates

### Prometheus ServiceMonitor
```yaml
# servicemonitor-webapp.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: webapp-metrics
  namespace: production
  labels:
    app: webapp
spec:
  selector:
    matchLabels:
      app: webapp
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
    scheme: http
```

### Prometheus Rules
```yaml
# prometheusrule-webapp.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: webapp-alerts
  namespace: production
  labels:
    app: webapp
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: webapp.rules
    rules:
    - alert: WebAppDown
      expr: up{job="webapp-metrics"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Web application is down"
        description: "Web application has been down for more than 5 minutes."
    
    - alert: WebAppHighLatency
      expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 0.5
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High latency on web application"
        description: "95th percentile latency is {{ $value }} seconds"
    
    - alert: WebAppHighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate on web application"
        description: "Error rate is {{ $value | humanizePercentage }}"
```

### Grafana Dashboard ConfigMap
```yaml
# configmap-grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-dashboard
  namespace: openshift-monitoring
  labels:
    grafana_dashboard: "1"
data:
  webapp-dashboard.json: |
    {
      "dashboard": {
        "id": null,
        "title": "Web Application Dashboard",
        "tags": ["webapp"],
        "timezone": "browser",
        "panels": [
          {
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])",
                "legendFormat": "{{ method }} {{ status }}"
              }
            ],
            "yAxes": [
              {
                "label": "requests/sec"
              }
            ]
          }
        ],
        "time": {
          "from": "now-1h",
          "to": "now"
        },
        "refresh": "10s"
      }
    }
```

---

## Logging Configuration Templates

### ClusterLogging Configuration
```yaml
# clusterlogging.yaml
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance"
  namespace: "openshift-logging"
spec:
  managementState: "Managed"
  logStore:
    type: "elasticsearch"
    retentionPolicy:
      application:
        maxAge: 7d
      infra:
        maxAge: 7d
      audit:
        maxAge: 7d
    elasticsearch:
      nodeCount: 3
      storage:
        storageClassName: "ebs-gp3"
        size: 200G
      resources:
        requests:
          memory: "8Gi"
          cpu: "1000m"
        limits:
          memory: "8Gi"
      proxy:
        resources:
          limits:
            memory: 256Mi
          requests:
            memory: 256Mi
      redundancyPolicy: "SingleRedundancy"
  visualization:
    type: "kibana"
    kibana:
      replicas: 1
      resources:
        requests:
          memory: "2Gi"
          cpu: "500m"
        limits:
          memory: "2Gi"
  collection:
    logs:
      type: "fluentd"
      fluentd:
        resources:
          requests:
            memory: "1Gi"
            cpu: "200m"
          limits:
            memory: "1Gi"
```

### Log Forwarding Configuration
```yaml
# clusterlogforwarder.yaml
apiVersion: "logging.openshift.io/v1"
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  outputs:
   - name: remote-elasticsearch
     type: "elasticsearch"
     url: https://elasticsearch.company.com:9200
     secret:
        name: elasticsearch-credentials
   - name: remote-syslog
     type: "syslog"
     syslog:
       facility: local0
       rfc: RFC3164
       payloadKey: message
       severity: informational
     url: tls://syslog.company.com:514
  pipelines:
   - name: application-logs
     inputRefs:
     - application
     outputRefs:
     - remote-elasticsearch
   - name: infrastructure-logs
     inputRefs:
     - infrastructure
     outputRefs:
     - remote-syslog
   - name: audit-logs
     inputRefs:
     - audit
     outputRefs:
     - remote-elasticsearch
     - remote-syslog
```

---

## CI/CD Integration Templates

### Tekton Pipeline Configuration
```yaml
# tekton-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: webapp-build-deploy
  namespace: cicd
spec:
  params:
  - name: git-url
    type: string
    description: The git repository URL
  - name: git-revision
    type: string
    description: The git revision to build
    default: main
  - name: image-name
    type: string
    description: The name of the image to build
  - name: deployment-namespace
    type: string
    description: The namespace to deploy to
    default: production
  
  workspaces:
  - name: source
    description: The workspace containing the source code
  - name: dockerconfig
    description: Docker registry credentials
  
  tasks:
  - name: git-clone
    taskRef:
      name: git-clone
      kind: ClusterTask
    params:
    - name: url
      value: $(params.git-url)
    - name: revision
      value: $(params.git-revision)
    workspaces:
    - name: output
      workspace: source
  
  - name: build-image
    taskRef:
      name: buildah
      kind: ClusterTask
    runAfter:
    - git-clone
    params:
    - name: IMAGE
      value: $(params.image-name):$(params.git-revision)
    - name: DOCKERFILE
      value: ./Dockerfile
    - name: CONTEXT
      value: .
    workspaces:
    - name: source
      workspace: source
    - name: dockerconfig
      workspace: dockerconfig
  
  - name: deploy-app
    taskRef:
      name: openshift-client
      kind: ClusterTask
    runAfter:
    - build-image
    params:
    - name: SCRIPT
      value: |
        oc set image deployment/webapp webapp=$(params.image-name):$(params.git-revision) -n $(params.deployment-namespace)
        oc rollout status deployment/webapp -n $(params.deployment-namespace)
```

### GitOps ArgoCD Application
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: webapp
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/company/webapp-config.git
    targetRevision: HEAD
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ApplyOutOfSyncOnly=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m0s
```

---

## Integration Configuration Templates

### External DNS Configuration
```yaml
# externaldns.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: external-dns
spec:
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.13.1
        args:
        - --source=openshift-route
        - --source=service
        - --domain-filter=apps.company.com
        - --provider=aws
        - --aws-zone-type=public
        - --registry=txt
        - --txt-owner-id=openshift-prod
        - --interval=1m
        - --log-level=info
        env:
        - name: AWS_DEFAULT_REGION
          value: us-east-1
        securityContext:
          fsGroup: 65534
          runAsNonRoot: true
          runAsUser: 65534
```

### Cert-Manager Configuration
```yaml
# cert-manager-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@company.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: openshift-default

---
# certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: webapp-tls
  namespace: production
spec:
  secretName: webapp-tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - webapp.apps.company.com
```

---

## Custom Resource Definitions

### Custom Operator Configuration
```yaml
# custom-operator.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: strimzi-kafka-operator
  namespace: kafka
spec:
  channel: stable
  name: strimzi-kafka-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
  startingCSV: strimzi-cluster-operator.v0.32.0

---
# kafka-cluster.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: kafka-cluster
  namespace: kafka
spec:
  kafka:
    version: 3.3.1
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 2
      inter.broker.protocol.version: "3.3"
    storage:
      type: persistent-claim
      size: 100Gi
      class: ebs-gp3
      deleteClaim: false
    resources:
      requests:
        memory: 2Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: "1"
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 10Gi
      class: ebs-gp3
      deleteClaim: false
    resources:
      requests:
        memory: 1Gi
        cpu: 250m
      limits:
        memory: 1Gi
        cpu: 500m
  entityOperator:
    topicOperator: {}
    userOperator: {}
```

---

## Usage Instructions

### Template Customization
1. **Copy Templates**: Copy relevant templates to your configuration repository
2. **Update Parameters**: Modify cluster names, domains, and resource specifications
3. **Validate Configuration**: Use `oc apply --dry-run=client` to validate syntax
4. **Test in Development**: Deploy to non-production environment first
5. **Version Control**: Commit configurations to Git for tracking

### Configuration Management
```bash
# Apply configurations
oc apply -f cluster-config/
oc apply -k overlays/production/

# Validate configurations
oc apply --dry-run=client -f install-config.yaml
oc get pods -n openshift-config

# Monitor deployment
oc get clusterversion
oc get nodes
oc get co
```

### Best Practices
- **Use Kustomize**: Overlay configurations for different environments
- **Validate Resources**: Always dry-run before applying to production
- **Monitor Changes**: Use GitOps workflows for configuration changes
- **Document Customizations**: Maintain clear documentation of modifications
- **Test Thoroughly**: Validate configurations in staging environments

---

**Document Version**: 4.14  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: IBM Red Hat Services Platform Team