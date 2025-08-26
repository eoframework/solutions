# HashiCorp Multi-Cloud Platform - Troubleshooting Guide

## Overview
This guide provides comprehensive troubleshooting procedures for the HashiCorp Multi-Cloud Infrastructure Management Platform. It covers common issues, diagnostic procedures, and resolution strategies across all HashiCorp products and cloud providers.

## General Troubleshooting Methodology

### Problem Identification Process
1. **Identify Symptoms**: Document exact error messages and behavior
2. **Check System Status**: Verify overall platform health
3. **Isolate Components**: Determine which HashiCorp service is affected
4. **Check Dependencies**: Verify upstream and downstream services
5. **Review Logs**: Analyze relevant log files and metrics
6. **Apply Solutions**: Implement targeted fixes
7. **Verify Resolution**: Confirm issue is resolved
8. **Document**: Update troubleshooting knowledge base

### Diagnostic Commands
```bash
# System health check script
#!/bin/bash
echo "=== HashiCorp Multi-Cloud Platform Health Check ==="

# Check Terraform Enterprise
echo "Checking Terraform Enterprise..."
curl -sf https://terraform.company.com/_health_check || echo "TFE: FAILED"

# Check Consul cluster
echo "Checking Consul cluster..."
consul members || echo "Consul: FAILED"

# Check Vault cluster
echo "Checking Vault cluster..."
vault status || echo "Vault: FAILED"

# Check Nomad cluster
echo "Checking Nomad cluster..."
nomad node status || echo "Nomad: FAILED"

# Check Boundary
echo "Checking Boundary..."
boundary authenticate || echo "Boundary: FAILED"

# Check Kubernetes clusters
for context in aws-prod azure-prod gcp-prod; do
  echo "Checking Kubernetes context: $context"
  kubectl --context=$context get nodes || echo "$context: FAILED"
done
```

## Terraform Enterprise Issues

### Issue: Terraform Enterprise Login Failures
**Symptoms**:
- Users cannot log in to TFE web interface
- API authentication failures
- SAML/OIDC authentication errors

**Diagnostic Steps**:
```bash
# Check TFE pod status
kubectl get pods -n terraform-enterprise
kubectl describe pod terraform-enterprise-xxx -n terraform-enterprise

# Check TFE logs
kubectl logs terraform-enterprise-xxx -n terraform-enterprise

# Check identity provider configuration
kubectl get secret tfe-saml-config -n terraform-enterprise -o yaml

# Test SAML/OIDC endpoint
curl -I https://terraform.company.com/session
```

**Common Causes and Solutions**:

1. **SAML Certificate Expired**
   ```bash
   # Check certificate expiration
   openssl x509 -in saml-cert.pem -text -noout | grep "Not After"
   
   # Update certificate in Kubernetes secret
   kubectl create secret generic tfe-saml-config \
     --from-file=certificate=new-saml-cert.pem \
     --dry-run=client -o yaml | kubectl apply -f -
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connectivity
   kubectl exec -it terraform-enterprise-xxx -n terraform-enterprise -- \
     psql $TFE_DATABASE_URL -c "SELECT version();"
   
   # Check database connection pool
   kubectl exec -it terraform-enterprise-xxx -n terraform-enterprise -- \
     psql $TFE_DATABASE_URL -c "SELECT count(*) FROM pg_stat_activity;"
   ```

### Issue: Workspace Runs Failing
**Symptoms**:
- Terraform plans or applies failing unexpectedly
- Workspace runs stuck in pending state
- Resource creation timeouts

**Diagnostic Steps**:
```bash
# Check workspace run details via API
curl -H "Authorization: Bearer $TFE_TOKEN" \
  https://terraform.company.com/api/v2/runs/$RUN_ID

# Check worker capacity
kubectl top pods -n terraform-enterprise
kubectl describe nodes

# Check Terraform runner logs
kubectl logs terraform-enterprise-xxx -n terraform-enterprise | grep "run-$RUN_ID"
```

**Solutions**:
1. **Insufficient Worker Resources**
   ```bash
   # Scale up worker nodes
   kubectl patch deployment terraform-enterprise -n terraform-enterprise \
     -p '{"spec":{"replicas":5}}'
   
   # Check auto-scaling configuration
   kubectl get hpa terraform-enterprise -n terraform-enterprise
   ```

2. **Cloud Provider API Limits**
   ```bash
   # Check AWS API throttling
   aws logs filter-log-events \
     --log-group-name /aws/terraform-enterprise \
     --filter-pattern "throttling"
   
   # Implement exponential backoff in Terraform configuration
   terraform {
     provider "aws" {
       retry_mode      = "adaptive"
       max_retries     = 10
     }
   }
   ```

## Consul Cluster Issues

### Issue: Consul Cluster Split-Brain
**Symptoms**:
- Multiple Consul leaders elected
- Service discovery inconsistencies
- Data inconsistencies across nodes

**Diagnostic Steps**:
```bash
# Check cluster membership
consul members

# Check leader election
consul operator raft list-peers

# Check cluster health
consul monitor
```

**Resolution**:
```bash
# Stop minority partition nodes
consul leave

# Force remove dead nodes from majority partition
consul force-leave <node-name>

# Restart affected services
kubectl rollout restart deployment consul-server -n consul
```

### Issue: Service Discovery Failures
**Symptoms**:
- Services cannot discover each other
- DNS resolution failures
- Health check failures

**Diagnostic Steps**:
```bash
# Check service registration
consul catalog services

# Check service health
consul health service <service-name>

# Test DNS resolution
dig @consul.service.consul <service-name>.service.consul

# Check Consul Connect proxy status
consul connect proxy-config <service-name>
```

**Solutions**:
```bash
# Re-register services
consul services register service-definition.json

# Reset service mesh configuration
consul config write proxy-defaults.hcl
consul config write service-defaults.hcl
```

## Vault Cluster Issues

### Issue: Vault Sealed State
**Symptoms**:
- Vault API returns 503 Service Unavailable
- Applications cannot retrieve secrets
- Vault UI shows sealed state

**Diagnostic Steps**:
```bash
# Check Vault status
vault status

# Check seal configuration
vault operator key-status

# Check Vault logs
kubectl logs vault-0 -n vault
```

**Resolution**:
```bash
# Unseal Vault cluster
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# Verify unsealed status
vault status

# Check cluster raft status
vault operator raft list-peers
```

### Issue: Secret Retrieval Failures
**Symptoms**:
- Applications cannot retrieve secrets
- Authentication failures
- Permission denied errors

**Diagnostic Steps**:
```bash
# Test secret retrieval
vault kv get secret/myapp/config

# Check authentication method
vault auth list

# Verify policy assignments
vault token lookup

# Check audit logs
vault audit list
```

**Solutions**:
```bash
# Renew authentication token
vault auth -method=aws

# Update policy assignments
vault write auth/aws/role/my-role \
  bound_iam_instance_profile_arn="arn:aws:iam::123456789012:instance-profile/my-role" \
  policies="my-policy"

# Test policy permissions
vault policy read my-policy
```

## Nomad Cluster Issues

### Issue: Job Allocation Failures
**Symptoms**:
- Jobs stuck in pending state
- Allocation placement failures
- Resource constraint errors

**Diagnostic Steps**:
```bash
# Check job status
nomad job status <job-name>

# Check node status and resources
nomad node status
nomad node status -stats <node-id>

# Check allocation details
nomad alloc status <alloc-id>

# Review job specification
nomad job plan <job-file>
```

**Solutions**:
```bash
# Scale up Nomad cluster
nomad node drain -disable <node-id>
nomad node drain -enable <node-id>

# Update job resource requirements
nomad job run updated-job.hcl

# Check and resolve placement constraints
nomad job validate <job-file>
```

### Issue: Service Mesh Connectivity Problems
**Symptoms**:
- Services cannot communicate through Connect
- Proxy connection failures
- Certificate validation errors

**Diagnostic Steps**:
```bash
# Check Connect proxy status
nomad alloc exec <alloc-id> consul connect proxy-config <service>

# Verify service intentions
consul intention list

# Check certificate validity
nomad alloc exec <alloc-id> consul connect ca get-config
```

**Solutions**:
```bash
# Update service intentions
consul intention create -allow web database

# Restart Connect proxies
nomad job stop <job-name>
nomad job run <job-file>

# Rotate Connect certificates
consul connect ca set-config <ca-config>
```

## Boundary Access Issues

### Issue: Connection Authentication Failures
**Symptoms**:
- Users cannot connect to targets
- Authentication method failures
- Session establishment errors

**Diagnostic Steps**:
```bash
# Check authentication methods
boundary auth-methods list

# Test authentication
boundary authenticate password \
  -auth-method-id=<auth-method-id> \
  -login-name=<username>

# Check target connectivity
boundary targets list
boundary targets read -id=<target-id>
```

**Solutions**:
```bash
# Update authentication configuration
boundary auth-methods update password \
  -id=<auth-method-id> \
  -name="Updated Password Auth"

# Test target connectivity
boundary connect ssh -target-id=<target-id>

# Check and update host catalogs
boundary host-catalogs update static \
  -id=<catalog-id>
```

## Cross-Cloud Networking Issues

### Issue: VPN Connectivity Problems
**Symptoms**:
- Inter-cloud communication failures
- VPN tunnel down status
- Routing table inconsistencies

**Diagnostic Steps**:
```bash
# Check VPN tunnel status
aws ec2 describe-vpn-connections
az network vpn-connection show
gcloud compute vpn-tunnels list

# Test inter-cloud connectivity
ping 10.20.0.1  # Azure from AWS
ping 10.30.0.1  # GCP from AWS

# Check routing tables
aws ec2 describe-route-tables
az network route-table route list
gcloud compute routes list
```

**Solutions**:
```bash
# Reset VPN connections
aws ec2 reset-vpn-connection --vpn-connection-id vpn-xxx

# Update routing tables
aws ec2 create-route --route-table-id rtb-xxx \
  --destination-cidr-block 10.20.0.0/16 \
  --vpn-gateway-id vgw-xxx
```

### Issue: DNS Resolution Failures
**Symptoms**:
- Cross-cloud service discovery failures
- DNS timeouts
- Inconsistent DNS responses

**Diagnostic Steps**:
```bash
# Test DNS resolution
nslookup consul.service.consul
dig @8.8.8.8 vault.company.com

# Check DNS forwarder configuration
kubectl get configmap coredns -n kube-system -o yaml

# Check DNS server logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

**Solutions**:
```bash
# Update CoreDNS configuration
kubectl apply -f updated-coredns-config.yaml

# Restart DNS pods
kubectl rollout restart deployment/coredns -n kube-system

# Clear DNS cache
kubectl exec -n kube-system coredns-xxx -- \
  /bin/sh -c "rndc flush"
```

## Performance Issues

### Issue: High Resource Utilization
**Symptoms**:
- Slow response times
- High CPU/memory usage
- Database connection exhaustion

**Diagnostic Steps**:
```bash
# Check resource utilization
kubectl top nodes
kubectl top pods --all-namespaces

# Check database performance
psql -c "SELECT * FROM pg_stat_activity;"
psql -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Monitor HashiCorp service metrics
consul monitor
vault monitor
nomad monitor
```

**Solutions**:
```bash
# Scale up resources
kubectl patch deployment terraform-enterprise -n terraform-enterprise \
  -p '{"spec":{"replicas":5}}'

# Optimize database configuration
kubectl exec -it postgres-0 -n database -- \
  psql -c "ALTER SYSTEM SET shared_buffers = '256MB';"

# Enable connection pooling
kubectl apply -f pgbouncer-config.yaml
```

## Monitoring and Alerting Issues

### Issue: Missing Metrics or Logs
**Symptoms**:
- Gaps in monitoring data
- Missing log entries
- Alert fatigue or missed alerts

**Diagnostic Steps**:
```bash
# Check Prometheus scrape targets
curl http://prometheus:9090/api/v1/targets

# Verify log shipping
kubectl logs fluentd-xxx -n logging

# Check alert manager status
curl http://alertmanager:9093/api/v1/status
```

**Solutions**:
```bash
# Restart monitoring components
kubectl rollout restart daemonset/fluentd -n logging
kubectl rollout restart deployment/prometheus -n monitoring

# Update scrape configurations
kubectl apply -f updated-prometheus-config.yaml

# Test alert routing
amtool alert add alertname="test" severity="critical"
```

## Emergency Procedures

### Complete Platform Outage
**Immediate Actions**:
1. Execute incident response plan
2. Notify stakeholders via communication channels
3. Activate disaster recovery procedures
4. Engage HashiCorp support if needed

**Recovery Steps**:
```bash
# Check overall system status
kubectl get nodes --all-namespaces
kubectl get pods --all-namespaces

# Restart core services in order
kubectl rollout restart deployment/consul-server -n consul
kubectl rollout restart deployment/vault -n vault
kubectl rollout restart deployment/nomad-server -n nomad
kubectl rollout restart deployment/terraform-enterprise -n terraform-enterprise

# Verify service health
./health-check.sh
```

### Data Corruption
**Immediate Actions**:
1. Stop all write operations
2. Take snapshots of current state
3. Assess extent of corruption
4. Restore from last known good backup

**Recovery Steps**:
```bash
# Create emergency snapshots
consul snapshot save emergency-backup.snap
vault operator raft snapshot save emergency-vault-backup.snap

# Restore from backup
consul snapshot restore last-good-backup.snap
vault operator raft snapshot restore last-good-vault-backup.snap
```

## Escalation Procedures

### Internal Escalation
1. **Level 1**: Platform team engineers
2. **Level 2**: Senior platform architects
3. **Level 3**: Platform director and CTO

### External Escalation
1. **HashiCorp Support**: Enterprise support with 4-hour SLA
2. **Cloud Provider Support**: AWS/Azure/GCP enterprise support
3. **Partner Support**: Implementation partner support team

### Contact Information
```
HashiCorp Support: support@hashicorp.com
AWS Support: enterprise-support-case
Azure Support: azure-support-case
GCP Support: gcp-support-case

Internal Escalation:
- Platform Team: platform-team@company.com
- On-Call Engineer: +1-555-PLATFORM
- Emergency Escalation: +1-555-EMERGENCY
```

---
**Troubleshooting Guide Version**: 1.0  
**Last Updated**: 2024-01-15  
**Next Review Date**: 2024-04-15  
**Document Owner**: Platform Operations Team