# IBM OpenShift Container Platform - Testing Procedures

This document outlines comprehensive testing procedures for validating IBM Red Hat OpenShift Container Platform deployment and functionality.

## Pre-Deployment Testing

### Infrastructure Validation

#### Network Connectivity Testing
```bash
# Test DNS resolution for OpenShift endpoints
nslookup api.openshift.company.com
nslookup *.apps.openshift.company.com
nslookup bootstrap.openshift.company.com

# Test network connectivity between nodes
for node in master-{0..2} worker-{0..2}; do
    ping -c 3 ${node}.openshift.company.com
done

# Test load balancer connectivity
curl -k https://api.openshift.company.com:6443/version
```

#### Storage Performance Testing
```bash
# Test storage IOPS and throughput
fio --name=test --ioengine=libaio --rw=randwrite --bs=4k --size=1G --iodepth=32 --runtime=60 --filename=/mnt/test-storage/testfile

# Test persistent volume provisioning
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ibm-block-gold
  resources:
    requests:
      storage: 10Gi
EOF

# Verify PVC binding
oc get pvc test-pvc
```

## Installation Testing

### Cluster Installation Validation

#### Bootstrap Process Testing
```bash
# Monitor bootstrap progress
tail -f /var/log/openshift-install.log

# Check bootstrap services
ssh core@bootstrap.openshift.company.com 'sudo journalctl -u bootkube.service -f'

# Validate bootstrap API availability
curl -k https://bootstrap.openshift.company.com:6443/api/v1
```

#### Master Node Validation
```bash
# Verify master node joining
export KUBECONFIG=auth/kubeconfig
oc get nodes -l node-role.kubernetes.io/master=

# Check etcd cluster health
oc get pods -n openshift-etcd
oc exec -n openshift-etcd etcd-master-0 -- etcdctl endpoint health

# Verify cluster operators
oc get co
oc get co --no-headers | awk '{print $1, $4, $5}'
```

## Post-Installation Testing

### Core Services Testing

#### API Server Testing
```bash
# Test Kubernetes API functionality
oc version
oc get nodes
oc get namespaces
oc get pods --all-namespaces

# Test authentication
oc whoami
oc auth can-i create pods
oc auth can-i '*' '*'
```

#### Container Runtime Testing
```yaml
# Test pod creation and execution
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: registry.redhat.io/ubi8/ubi:latest
    command: ['sh', '-c', 'echo "Test successful" && sleep 30']
  restartPolicy: Never
```

```bash
# Deploy and test the pod
oc apply -f test-pod.yaml
oc wait --for=condition=Ready pod/test-pod --timeout=60s
oc logs test-pod
oc delete pod test-pod
```

### Networking Testing

#### Service Discovery Testing
```yaml
# Create test service and deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ['sh', '-c', 'while true; do echo "Hello from $(hostname)" | nc -l -p 8080; done']
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

```bash
# Test service connectivity
oc apply -f test-app.yaml
oc get svc test-service
oc run test-client --image=registry.redhat.io/ubi8/ubi:latest --rm -it --restart=Never -- curl test-service
```

#### Ingress Testing
```yaml
# Create route for external access
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: test-route
spec:
  to:
    kind: Service
    name: test-service
  port:
    targetPort: 8080
```

```bash
# Test external access
oc apply -f test-route.yaml
ROUTE_URL=$(oc get route test-route -o jsonpath='{.spec.host}')
curl http://$ROUTE_URL
```

## Storage Testing

### Persistent Volume Testing

#### Dynamic Provisioning Test
```yaml
# Test dynamic storage provisioning
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ibm-file-bronze
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: storage-test-pod
spec:
  containers:
  - name: storage-test
    image: registry.redhat.io/ubi8/ubi:latest
    command: ['sh', '-c', 'echo "Testing storage" > /mnt/test.txt && cat /mnt/test.txt && sleep 60']
    volumeMounts:
    - name: test-volume
      mountPath: /mnt
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: dynamic-pvc-test
```

#### Backup and Recovery Testing
```bash
# Test volume snapshot functionality
oc create -f - <<EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
spec:
  volumeSnapshotClassName: ibm-vsc-block
  source:
    persistentVolumeClaimName: dynamic-pvc-test
EOF

# Verify snapshot creation
oc get volumesnapshot test-snapshot
oc describe volumesnapshot test-snapshot
```

## Security Testing

### Authentication and Authorization Testing

#### RBAC Testing
```bash
# Create test user and service account
oc create serviceaccount test-sa
oc create clusterrolebinding test-sa-binding --clusterrole=view --serviceaccount=default:test-sa

# Test service account permissions
TOKEN=$(oc serviceaccounts get-token test-sa)
oc --token=$TOKEN get pods
oc --token=$TOKEN get secrets  # Should fail
```

#### Network Policy Testing
```yaml
# Create network policy for testing
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: test-namespace
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

```bash
# Test network isolation
oc create namespace test-namespace
oc apply -f networkpolicy.yaml -n test-namespace
# Deploy test pods and verify network restrictions
```

### Security Context Testing
```yaml
# Test pod security context
apiVersion: v1
kind: Pod
metadata:
  name: security-test-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 2001
  containers:
  - name: security-test
    image: registry.redhat.io/ubi8/ubi:latest
    command: ['sh', '-c', 'id && ls -la /tmp && sleep 60']
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

## Application Deployment Testing

### Container Image Testing

#### Registry Integration Testing
```bash
# Test internal registry
oc new-build --name=test-build --binary
echo 'FROM registry.redhat.io/ubi8/ubi:latest' > Dockerfile
oc start-build test-build --from-dir=. --follow

# Test image deployment
oc new-app test-build
oc get pods -l app=test-build
```

#### External Registry Testing
```bash
# Test pulling from external registry
oc create secret docker-registry external-registry-secret \
    --docker-server=registry.company.com \
    --docker-username=user \
    --docker-password=password \
    --docker-email=user@company.com

oc run external-image-test --image=registry.company.com/test-app:latest \
    --overrides='{
      "spec": {
        "imagePullSecrets": [{"name": "external-registry-secret"}]
      }
    }'
```

### CI/CD Pipeline Testing

#### Jenkins Pipeline Testing
```groovy
// Test Jenkins pipeline in OpenShift
pipeline {
    agent {
        node {
            label 'maven'
        }
    }
    
    stages {
        stage('Test Build') {
            steps {
                echo 'Testing build process'
                sh 'mvn --version'
                sh 'oc version'
            }
        }
        
        stage('Test Deploy') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject('test-project') {
                            echo "Testing deployment in ${openshift.project()}"
                            def result = openshift.newApp('registry.redhat.io/ubi8/ubi:latest')
                            echo "Created: ${result.names()}"
                        }
                    }
                }
            }
        }
    }
}
```

## Performance Testing

### Load Testing

#### API Server Load Testing
```bash
# Install hey load testing tool
go get -u github.com/rakyll/hey

# Test API server performance
hey -n 1000 -c 10 -H "Authorization: Bearer $(oc whoami -t)" \
    https://api.openshift.company.com:6443/api/v1/namespaces
```

#### Application Load Testing
```bash
# Deploy test application
oc new-app --name=load-test-app registry.redhat.io/ubi8/ubi:latest
oc expose svc/load-test-app

# Run load test
APP_URL=$(oc get route load-test-app -o jsonpath='{.spec.host}')
hey -n 10000 -c 50 -t 30 http://$APP_URL
```

### Resource Utilization Testing
```bash
# Monitor resource usage during testing
oc adm top nodes
oc adm top pods --all-namespaces

# Generate resource usage report
oc get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq '.items[] | {name: .metadata.name, cpu: .usage.cpu, memory: .usage.memory}'
```

## Monitoring and Logging Testing

### Prometheus Testing
```bash
# Test Prometheus metrics collection
oc get pods -n openshift-monitoring

# Test metrics endpoint
PROM_TOKEN=$(oc create token prometheus-k8s -n openshift-monitoring)
curl -H "Authorization: Bearer $PROM_TOKEN" \
     -k "https://prometheus-k8s-openshift-monitoring.apps.openshift.company.com/api/v1/query?query=up"
```

### Logging Testing
```bash
# Test log collection and forwarding
oc get pods -n openshift-logging

# Generate test logs
oc run log-generator --image=registry.redhat.io/ubi8/ubi:latest \
    --command -- sh -c 'while true; do echo "Test log message $(date)"; sleep 1; done'

# Verify logs in Elasticsearch
oc exec -n openshift-logging elasticsearch-cd-0 -- \
    curl -s localhost:9200/_cat/indices
```

## Disaster Recovery Testing

### Backup Testing
```bash
# Test etcd backup
oc debug node/master-0 -- chroot /host sudo -E /usr/local/bin/cluster-backup.sh /tmp/backup

# Verify backup files
oc debug node/master-0 -- chroot /host ls -la /tmp/backup/
```

### Recovery Testing
```bash
# Test cluster recovery procedure (in test environment)
# Note: This should only be done in a test cluster
echo "Testing disaster recovery procedures..."
echo "1. Stop etcd on all master nodes"
echo "2. Restore from backup"
echo "3. Restart cluster services"
echo "4. Verify cluster functionality"
```

## Testing Automation

### Automated Test Suite
```python
#!/usr/bin/env python3

import subprocess
import json
import sys

def run_test(test_name, command):
    """Run a test command and return results"""
    print(f"Running test: {test_name}")
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {test_name}: PASSED")
            return True
        else:
            print(f"❌ {test_name}: FAILED")
            print(f"Error: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ {test_name}: ERROR - {e}")
        return False

def main():
    """Run comprehensive OpenShift test suite"""
    tests = [
        ("Cluster API Access", "oc version --client=false"),
        ("Node Status", "oc get nodes --no-headers | grep -v Ready && exit 1 || exit 0"),
        ("Cluster Operators", "oc get co --no-headers | grep -v Available && exit 1 || exit 0"),
        ("Pod Creation", "oc run test-pod --image=registry.redhat.io/ubi8/ubi:latest --restart=Never --rm -i --tty -- echo 'Test successful'"),
        ("Service Creation", "oc create service clusterip test-svc --tcp=80:8080 && oc delete service test-svc"),
        ("Route Creation", "oc create route edge test-route --service=test-svc --hostname=test.apps.openshift.company.com; oc delete route test-route || true"),
        ("Storage Provisioning", "oc apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolumeClaim\nmetadata:\n  name: test-pvc\nspec:\n  accessModes: [ReadWriteOnce]\n  resources:\n    requests:\n      storage: 1Gi\nEOF\n && sleep 10 && oc get pvc test-pvc -o jsonpath='{.status.phase}' | grep Bound && oc delete pvc test-pvc")
    ]
    
    passed = 0
    failed = 0
    
    for test_name, command in tests:
        if run_test(test_name, command):
            passed += 1
        else:
            failed += 1
    
    print(f"\n=== Test Results ===")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Total: {passed + failed}")
    
    if failed > 0:
        sys.exit(1)
    else:
        print("\n🎉 All tests passed!")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

### Test Reporting
```bash
# Generate comprehensive test report
cat <<EOF > test-report-template.json
{
  "testExecution": {
    "testDate": "$(date -Iseconds)",
    "cluster": "openshift.company.com",
    "version": "$(oc version -o json | jq -r '.openshiftVersion')",
    "nodeCount": $(oc get nodes --no-headers | wc -l),
    "testResults": {
      "totalTests": 0,
      "passedTests": 0,
      "failedTests": 0,
      "testDetails": []
    }
  }
}
EOF

echo "Test report template created: test-report-template.json"
```

---

**This comprehensive testing procedure ensures thorough validation of all OpenShift functionality and should be executed systematically during deployment and ongoing operations.**