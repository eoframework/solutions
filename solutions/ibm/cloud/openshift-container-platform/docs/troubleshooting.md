# IBM OpenShift Container Platform Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnose and resolve common issues encountered with Red Hat OpenShift Container Platform on IBM infrastructure.

## General Troubleshooting Methodology

### Systematic Approach

1. **Problem Identification**
   - Gather symptoms and error messages
   - Identify affected components or services
   - Determine timeline and scope of impact
   - Document recent changes or events

2. **Information Gathering**
   - Collect logs from relevant components
   - Check cluster and node status
   - Review resource utilization metrics
   - Analyze network connectivity

3. **Root Cause Analysis**
   - Correlate symptoms with known issues
   - Analyze log patterns and error messages
   - Test hypotheses systematically
   - Isolate variables when possible

4. **Resolution and Verification**
   - Apply appropriate fixes or workarounds
   - Verify resolution addresses root cause
   - Monitor for recurrence
   - Document resolution for future reference

## Cluster-Level Issues

### Cluster Installation Problems

**Issue: Cluster Installation Fails**

*Symptoms:*
- Installation process hangs or times out
- Bootstrap node fails to complete
- Control plane nodes not coming online

*Diagnostic Commands:*
```bash
# Check installation progress
oc adm must-gather --dest-dir=./must-gather

# Review bootstrap logs
ssh core@<bootstrap-ip> journalctl -f -u bootkube.service

# Check installer logs
tail -f .openshift_install.log

# Verify DNS resolution
nslookup api.<cluster-name>.<base-domain>
```

*Common Causes and Solutions:*
- **DNS Issues**: Verify DNS records for API and apps endpoints
- **Network Connectivity**: Check security groups and network ACLs
- **Resource Constraints**: Ensure adequate CPU/memory/storage
- **IBM Cloud Quotas**: Verify service quotas and limits

**Issue: Control Plane Nodes Unavailable**

*Symptoms:*
- API server not responding
- etcd cluster unhealthy
- Control plane pods in error states

*Diagnostic Commands:*
```bash
# Check node status
oc get nodes

# Check control plane pods
oc get pods -n openshift-kube-apiserver
oc get pods -n openshift-etcd

# Check etcd cluster health
oc rsh -n openshift-etcd etcd-<master-node>
etcdctl endpoint health --cluster

# Review control plane logs
oc logs -n openshift-kube-apiserver -l app=openshift-kube-apiserver
```

*Resolution Steps:*
1. Verify network connectivity between master nodes
2. Check etcd data consistency and repair if necessary
3. Restart affected control plane services
4. Replace unhealthy master nodes if required

### Node Management Issues

**Issue: Worker Nodes Not Ready**

*Symptoms:*
- Nodes in NotReady or SchedulingDisabled state
- Pods failing to schedule on specific nodes
- High resource utilization on remaining nodes

*Diagnostic Commands:*
```bash
# Check node conditions
oc describe node <node-name>

# Check kubelet status
oc debug node/<node-name>
chroot /host
systemctl status kubelet
journalctl -u kubelet

# Check container runtime
crictl info
crictl ps -a
```

*Common Solutions:*
- Restart kubelet service: `systemctl restart kubelet`
- Clean up container runtime: `crictl system prune`
- Address disk space issues: `df -h` and clean up as needed
- Update machine config if required

**Issue: Node Certificate Problems**

*Symptoms:*
- kubelet unable to connect to API server
- Certificate validation errors in logs
- Node authentication failures

*Resolution Steps:*
```bash
# Check certificate status
oc get csr

# Approve pending certificates
oc get csr -o name | xargs oc adm certificate approve

# Force certificate rotation
oc debug node/<node-name>
chroot /host
rm -rf /var/lib/kubelet/pki
systemctl restart kubelet
```

## Application and Workload Issues

### Pod Scheduling Problems

**Issue: Pods Stuck in Pending State**

*Symptoms:*
- Pods remain in Pending state indefinitely
- Insufficient resources for pod scheduling
- Node selector or affinity constraints not met

*Diagnostic Commands:*
```bash
# Check pod status and events
oc describe pod <pod-name>

# Check resource availability
oc describe nodes

# Check for resource quotas
oc describe quota -n <namespace>

# Check for limit ranges
oc describe limitrange -n <namespace>
```

*Common Causes and Solutions:*
- **Insufficient Resources**: Scale cluster or adjust resource requests
- **Node Selectors**: Verify node labels match pod requirements
- **Taints and Tolerations**: Check for node taints blocking scheduling
- **Resource Quotas**: Increase quotas or reduce resource requests

**Issue: Pods Failing to Start**

*Symptoms:*
- Pods in CrashLoopBackOff state
- Image pull errors
- Container startup failures

*Diagnostic Commands:*
```bash
# Check pod logs
oc logs <pod-name> --previous

# Check pod events
oc get events --sort-by='.lastTimestamp'

# Check image pull capability
oc debug node/<node-name>
chroot /host
crictl pull <image-name>

# Check security context constraints
oc describe scc
oc get pod <pod-name> -o yaml | grep securityContext
```

### Networking Issues

**Issue: Pod-to-Pod Communication Failures**

*Symptoms:*
- Services unreachable from other pods
- Network timeouts or connection refused errors
- DNS resolution problems

*Diagnostic Commands:*
```bash
# Test DNS resolution
oc run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check network policies
oc get networkpolicy -A

# Test connectivity
oc run debug-pod --image=nicolaka/netshoot --rm -it --restart=Never

# Check OpenShift SDN status
oc get clusternetwork
oc get netnamespace
```

*Resolution Steps:*
1. Verify network policies allow required traffic
2. Check OpenShift SDN configuration
3. Restart OpenShift SDN pods if necessary
4. Verify IBM Cloud security groups and ACLs

**Issue: Ingress/Route Problems**

*Symptoms:*
- External traffic cannot reach applications
- SSL certificate errors
- Load balancer configuration issues

*Diagnostic Commands:*
```bash
# Check router pods
oc get pods -n openshift-ingress

# Check route configuration
oc get routes -A
oc describe route <route-name>

# Check ingress controller status
oc get ingresscontroller -n openshift-ingress-operator

# Test external connectivity
curl -I http://<route-url>
```

## Storage Issues

### Persistent Volume Problems

**Issue: PVC Stuck in Pending State**

*Symptoms:*
- PersistentVolumeClaim remains in Pending status
- No suitable PersistentVolume available
- Storage class issues

*Diagnostic Commands:*
```bash
# Check PVC status
oc describe pvc <pvc-name>

# Check available PVs
oc get pv

# Check storage classes
oc get storageclass

# Check storage operator logs
oc logs -n openshift-cluster-storage-operator -l name=cluster-storage-operator
```

*Common Solutions:*
- Create appropriate PersistentVolume
- Configure storage class correctly
- Check IBM Cloud Block Storage quotas
- Verify storage provisioner is running

**Issue: Volume Mount Failures**

*Symptoms:*
- Pods failing to start due to volume mount errors
- Permission denied errors on mounted volumes
- Volume already mounted errors

*Resolution Steps:*
```bash
# Check volume attachment status
oc get volumeattachment

# Force unmount if necessary
oc debug node/<node-name>
chroot /host
umount /var/lib/kubelet/pods/<pod-uid>/volumes/<volume>

# Check file system integrity
fsck /dev/<block-device>
```

## IBM Cloud Integration Issues

### IBM Cloud Service Integration

**Issue: IBM Log Analysis Not Receiving Logs**

*Symptoms:*
- No logs appearing in IBM Log Analysis dashboard
- LogDNA agent pods in error state
- Log ingestion failures

*Diagnostic Commands:*
```bash
# Check LogDNA agent status
oc get pods -n ibm-observe

# Check agent configuration
oc get secret logdna-agent-key -n ibm-observe

# Review agent logs
oc logs -n ibm-observe -l app=logdna-agent
```

*Resolution Steps:*
1. Verify LogDNA ingestion key is correct
2. Check network connectivity to LogDNA endpoints
3. Restart LogDNA agent pods
4. Update agent configuration if required

**Issue: IBM Cloud Monitoring Problems**

*Symptoms:*
- Metrics not appearing in Sysdig dashboard
- Monitoring agent connectivity issues
- Alert rules not triggering

*Diagnostic Commands:*
```bash
# Check Sysdig agent status
oc get pods -n ibm-observe

# Verify agent configuration
oc describe daemonset sysdig-agent -n ibm-observe

# Check agent connectivity
oc logs -n ibm-observe -l app=sysdig-agent
```

### IBM Cloud Storage Integration

**Issue: IBM Block Storage Provisioning Failures**

*Symptoms:*
- PVC creation fails with storage provisioning errors
- IBM Cloud Block Storage volumes not attaching
- Storage quotas exceeded

*Diagnostic Commands:*
```bash
# Check storage provisioner logs
oc logs -n kube-system -l app=ibm-vpc-block-csi-driver

# Verify storage class configuration
oc describe storageclass ibmc-block-vpc

# Check IBM Cloud resource quotas
ibmcloud is volume-profiles
ibmcloud is volumes
```

## Performance Issues

### Resource Constraint Problems

**Issue: High CPU or Memory Utilization**

*Symptoms:*
- Pods being killed due to resource limits
- Node resource exhaustion
- Application performance degradation

*Diagnostic Commands:*
```bash
# Check resource utilization
oc top nodes
oc top pods -A

# Check resource requests and limits
oc describe pod <pod-name> | grep -A 5 -B 5 resources

# Check node allocatable resources
oc describe node <node-name> | grep -A 10 Allocatable
```

*Resolution Strategies:*
- Adjust resource requests and limits
- Scale cluster horizontally
- Implement resource quotas and limits
- Monitor and optimize application performance

**Issue: Slow Application Response Times**

*Symptoms:*
- Application requests timing out
- High latency between services
- Database connection issues

*Investigation Steps:*
1. Monitor application metrics and traces
2. Check network latency between components
3. Analyze database performance and connections
4. Review resource allocation and utilization

## Security Issues

### Certificate and Authentication Problems

**Issue: Certificate Expiration**

*Symptoms:*
- API server authentication failures
- Service-to-service communication errors
- Certificate validation warnings

*Resolution Steps:*
```bash
# Check certificate expiration
oc get secrets -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.type}{"\n"}{end}' | grep tls

# Rotate certificates if necessary
oc delete secret <certificate-secret>
# Certificate will be automatically recreated

# Force certificate renewal
oc adm certificate approve $(oc get csr -o name)
```

**Issue: RBAC Permission Denied**

*Symptoms:*
- Users unable to access resources
- Service accounts lacking permissions
- Authorization errors in application logs

*Diagnostic Commands:*
```bash
# Check user permissions
oc auth can-i <verb> <resource> --as=<user>

# Review role bindings
oc describe rolebinding -n <namespace>
oc describe clusterrolebinding

# Check service account permissions
oc describe serviceaccount <sa-name> -n <namespace>
```

## Emergency Procedures

### Cluster Recovery

**Emergency Access to Cluster**
```bash
# Access via debug node if API unavailable
oc debug node/<master-node>
chroot /host
export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/localhost.kubeconfig

# Direct etcd access
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cert=/etc/kubernetes/static-pod-resources/etcd-certs/secrets/etcd-all-certs/etcd-peer-client.crt \
  --key=/etc/kubernetes/static-pod-resources/etcd-certs/secrets/etcd-all-certs/etcd-peer-client.key \
  --cacert=/etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-ca-bundle/ca-bundle.crt \
  member list
```

**Force Node Replacement**
```bash
# Drain node safely
oc adm drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Delete node from cluster
oc delete node <node-name>

# Replace with new IBM Cloud instance
ibmcloud is instance-create <instance-name> <profile> <subnet> --image <image-id>
```

## Escalation Procedures

### IBM Support Escalation

**When to Escalate:**
- Cluster-wide outages affecting production
- Data loss or corruption scenarios  
- Security breaches or compliance violations
- Performance issues impacting SLA

**Information to Gather:**
- Cluster ID and region
- Affected timeframe and scope
- Error messages and logs
- Steps already taken to resolve
- Business impact assessment

### Red Hat Support Escalation

**Required Information:**
- OpenShift cluster version and build
- Sosreport or must-gather data
- Specific error messages
- Reproduction steps
- Component or operator affected

## Monitoring and Alerting

### Key Metrics to Monitor

**Cluster Health:**
- Node availability and resource utilization
- Control plane component status
- etcd cluster health and performance
- Network connectivity and throughput

**Application Health:**
- Pod restart rates and failure patterns
- Resource consumption trends
- Service response times and error rates
- Storage utilization and performance

### Recommended Alerts

**Critical Alerts:**
- Control plane nodes unavailable
- etcd cluster unhealthy
- High node resource utilization (>90%)
- Certificate expiration warnings (<30 days)
- Storage capacity warnings (<20% free)

**Warning Alerts:**
- Pod restart rates increasing
- Network latency degradation
- Resource quota approaching limits
- Failed backup operations

This troubleshooting guide provides systematic approaches to diagnosing and resolving common issues with IBM OpenShift Container Platform deployments.