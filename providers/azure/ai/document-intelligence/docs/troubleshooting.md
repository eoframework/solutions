# Troubleshooting Guide - Azure Document Intelligence Solution

## Common Issues

### Issue 1: Document Intelligence API Rate Limiting
**Symptoms:**
- HTTP 429 "Too Many Requests" errors
- Processing delays or timeouts
- Intermittent failures during high-volume processing

**Causes:**
- Exceeding 15 requests per second default limit
- Burst processing without proper throttling
- Multiple concurrent applications using same service

**Solutions:**
1. Implement exponential backoff retry logic in application code
2. Request quota increase through Azure Support for higher limits
3. Distribute processing across multiple Document Intelligence instances
4. Implement queue-based processing with controlled throughput
5. Monitor request patterns and optimize batch sizes

### Issue 2: Low Confidence Scores in Document Extraction
**Symptoms:**
- Extracted data confidence scores below 0.8
- Inconsistent data extraction results
- High false positive/negative rates

**Causes:**
- Poor document image quality (low resolution, skewed, blurry)
- Document format not supported by prebuilt models
- Custom model not properly trained or insufficient training data

**Solutions:**
1. Improve document quality through preprocessing (deskew, enhance, resize)
2. Train custom models with domain-specific document samples
3. Use appropriate prebuilt model for document type
4. Implement human-in-the-loop validation for low-confidence results
5. Fine-tune confidence thresholds based on business requirements

### Issue 3: Azure Storage Access Denied Errors
**Symptoms:**
- "Forbidden" or "Access Denied" errors when accessing blob storage
- Unable to upload or download documents
- Function apps cannot access storage containers

**Causes:**
- Incorrect storage account permissions or RBAC roles
- Managed identity not properly configured
- Storage account firewall blocking requests
- Expired SAS tokens or connection strings

**Solutions:**
1. Verify managed identity has "Storage Blob Data Contributor" role
2. Update storage account firewall rules to allow Azure services
3. Regenerate storage account access keys if compromised
4. Configure private endpoints for secure network access
5. Validate SAS token permissions and expiration dates

### Issue 4: Azure Functions Cold Start Performance
**Symptoms:**
- First request takes significantly longer (5-10 seconds)
- Intermittent timeout errors during low usage periods
- Inconsistent processing times

**Causes:**
- Function app running on Consumption plan with cold starts
- Large deployment package size
- Dependencies not optimized for cold start

**Solutions:**
1. Upgrade to Premium or Dedicated hosting plan for always-warm instances
2. Implement warm-up triggers to keep functions active
3. Optimize deployment package size and remove unused dependencies
4. Use application initialization for critical functions
5. Configure "Always On" setting for critical processing functions

### Issue 5: Custom Model Training Failures
**Symptoms:**
- Model training jobs fail or timeout
- Low model accuracy after training
- Unable to create custom models

**Causes:**
- Insufficient or poor-quality training documents
- Inconsistent document layouts in training set
- Training data not properly labeled or formatted

**Solutions:**
1. Ensure minimum 5 documents per model with consistent structure
2. Use high-quality scanned documents (300 DPI minimum)
3. Provide diverse examples covering all document variations
4. Validate document annotations and labeling accuracy
5. Use document analysis insights to improve training data

## Diagnostic Tools

### Built-in Azure Tools
- **Azure Monitor**: Comprehensive logging and metrics for all Azure services
- **Application Insights**: Real-time performance monitoring and dependency tracking
- **Azure Resource Health**: Service health status and maintenance notifications
- **Storage Analytics**: Detailed storage account usage and performance metrics
- **Document Intelligence Studio**: Visual tool for testing and model management

### Azure CLI Diagnostic Commands
```bash
# Check Document Intelligence service status
az cognitiveservices account show --name <service-name> --resource-group <rg-name>

# Monitor Function App logs
az functionapp log tail --name <function-app-name> --resource-group <rg-name>

# Check storage account access
az storage blob list --account-name <storage-name> --container-name <container>

# Validate Key Vault access
az keyvault secret show --vault-name <vault-name> --name <secret-name>
```

### External Tools
- **Postman**: API testing and debugging for Document Intelligence endpoints
- **Azure Storage Explorer**: Visual interface for blob storage management and debugging
- **Fiddler**: Network traffic analysis for API call debugging
- **Visual Studio Code**: Integrated debugging for Azure Functions
- **PowerBI Desktop**: Data visualization for processing analytics and monitoring

## Performance Optimization

### Document Processing Optimization
- **Image Preprocessing**: Implement deskewing, noise reduction, and contrast enhancement
- **Batch Processing**: Group documents for efficient processing (5-10 documents per batch)
- **Parallel Processing**: Use Azure Functions with queue triggers for concurrent processing
- **Caching**: Implement Redis cache for frequently accessed results
- **Content Delivery**: Use Azure CDN for faster document access

### Cost Optimization
- **Lifecycle Management**: Implement blob storage lifecycle policies for automatic archiving
- **Reserved Capacity**: Purchase reserved instances for predictable workloads
- **Monitoring**: Set up cost alerts and budgets to track spending
- **Optimization**: Regularly review and optimize resource sizing

## Support Escalation

### Level 1 Support
- **Documentation**: Azure Document Intelligence official documentation
- **Community Forums**: Microsoft Q&A and Stack Overflow
- **GitHub Issues**: Azure SDK and sample code repositories
- **Learning Resources**: Microsoft Learn modules and tutorials

### Level 2 Support
- **Azure Support Plans**: Professional Direct or Premier support
- **Microsoft FastTrack**: Architecture guidance and best practices
- **Partner Support**: Microsoft partner ecosystem for specialized assistance
- **Training**: Microsoft official training courses and certifications

### Emergency Support
- **Azure Support Center**: 24/7 technical support for production issues
- **Critical Issue Escalation**: Severity A support for business-critical problems
- **Premier Support**: Dedicated technical account manager and escalation procedures
- **Emergency Contacts**: Pre-configured contact lists for critical incidents

## Monitoring and Alerting

### Key Metrics to Monitor
- **Request Rate**: Document Intelligence API requests per second
- **Error Rate**: Failed requests and error response codes
- **Latency**: Average processing time per document
- **Confidence Scores**: Average extraction confidence levels
- **Storage Usage**: Blob storage capacity and transaction costs

### Alert Configuration
```json
{
  "alertName": "High Error Rate",
  "condition": "Error rate > 5% over 15 minutes",
  "action": "Email admin team and create incident"
}
```

### Dashboard Metrics
- Real-time processing volume and success rates
- Document type distribution and processing times
- Cost tracking and budget utilization
- Service health and availability status
- Custom model performance and accuracy trends

## Backup and Recovery

### Data Backup Strategy
- **Storage Replication**: Use geo-redundant storage (GRS) for critical documents
- **Database Backup**: Automated Cosmos DB backups with point-in-time recovery
- **Configuration Backup**: Export ARM templates and configuration settings
- **Secret Management**: Regular Key Vault backup and rotation procedures

### Disaster Recovery
- **Multi-Region Deployment**: Primary and secondary regions for high availability
- **Traffic Manager**: Automatic failover for web endpoints
- **Data Synchronization**: Real-time replication of critical data
- **Recovery Testing**: Regular disaster recovery drills and validation

### Incident Response
1. **Detection**: Automated alerting and monitoring systems
2. **Assessment**: Rapid triage and impact analysis
3. **Response**: Execute incident response playbooks
4. **Recovery**: Restore services and validate functionality
5. **Post-Incident**: Root cause analysis and prevention measures