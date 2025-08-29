# AWS Intelligent Document Processing - Troubleshooting

This document provides solutions for common issues encountered during deployment and operation of the AWS intelligent document processing solution.

## Common Deployment Issues

### Terraform Deployment Failures

#### Issue: S3 Bucket Already Exists
**Error**: `BucketAlreadyExists: The requested bucket name is not available`

**Solution**:
1. Update `terraform.tfvars` with a unique bucket name
2. Use company prefix and timestamp: `company-name-intelligent-docs-dev-20240315`
3. Re-run `terraform plan` and `terraform apply`

#### Issue: IAM Permission Denied
**Error**: `AccessDenied: User is not authorized to perform iam:CreateRole`

**Solution**:
1. Ensure AWS credentials have IAM permissions
2. Add the following policy to your user/role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:CreatePolicy",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Issue: Lambda Function Package Too Large
**Error**: `InvalidParameterValueException: Unzipped size must be smaller than 262144000 bytes`

**Solution**:
1. Reduce Lambda package size by removing unnecessary dependencies
2. Use Lambda Layers for large libraries
3. Store large files in S3 and download at runtime

## Runtime Processing Issues

### Document Processing Failures

#### Issue: Textract Processing Timeout
**Symptoms**: Documents not processed, Lambda timeout errors in CloudWatch

**Solution**:
1. Increase Lambda timeout in `terraform.tfvars`:
   ```hcl
   lambda_timeout = 900  # 15 minutes
   ```
2. For large documents, implement asynchronous Textract processing
3. Use Step Functions for complex workflows

#### Issue: Textract API Rate Limiting
**Error**: `ProvisionedThroughputExceededException: Rate exceeded`

**Solution**:
1. Implement exponential backoff in Lambda function
2. Use SQS with message delays for queue management
3. Request service limit increase through AWS Support
4. Process documents in smaller batches

#### Issue: Unsupported File Format
**Error**: `UnsupportedDocumentException: Document format not supported`

**Solution**:
1. Verify file extension matches content type
2. Convert unsupported formats before processing:
   - DOC/DOCX → PDF using conversion service
   - Images → Supported formats (PNG, JPEG, TIFF)
3. Add file validation in Lambda function

### Memory and Performance Issues

#### Issue: Lambda Out of Memory
**Error**: `Runtime.ExitError: RequestId: xxx-xxx Process exited before completing request`

**Solution**:
1. Increase Lambda memory allocation:
   ```hcl
   lambda_memory_size = 1024  # or higher
   ```
2. Process documents in chunks for large files
3. Monitor memory usage in CloudWatch

#### Issue: S3 Access Denied
**Error**: `AccessDenied: Access Denied`

**Solution**:
1. Verify IAM role has S3 permissions
2. Check bucket policy for cross-account access
3. Ensure bucket and object are in the same region
4. Verify encryption settings match IAM permissions

## Monitoring and Debugging

### CloudWatch Logs Analysis

#### Common Log Patterns to Monitor
```bash
# Lambda function errors
ERROR	RequestId: xxx-xxx	Task timed out after

# Textract API errors  
ERROR	RequestId: xxx-xxx	ProvisionedThroughputExceededException

# S3 access issues
ERROR	RequestId: xxx-xxx	AccessDenied
```

#### Log Analysis Commands
```bash
# Filter error logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/intelligent-doc-processor \
  --filter-pattern "ERROR"

# Get recent logs
aws logs get-log-events \
  --log-group-name /aws/lambda/intelligent-doc-processor \
  --log-stream-name "latest" \
  --start-time 1640995200000
```

### Performance Optimization

#### Slow Document Processing
**Symptoms**: Documents taking longer than expected to process

**Solutions**:
1. **Optimize Lambda Configuration**:
   - Increase memory (improves CPU allocation)
   - Use provisioned concurrency for consistent performance
   - Implement connection pooling for AWS services

2. **Document Preprocessing**:
   - Resize large images before processing
   - Split large PDFs into smaller chunks
   - Use image compression to reduce file size

3. **Parallel Processing**:
   - Process multiple pages concurrently
   - Use SQS for distributed processing
   - Implement batch processing for multiple documents

## Data Quality Issues

### Poor OCR Results
**Symptoms**: Inaccurate text extraction, missing content

**Solutions**:
1. **Document Quality**:
   - Ensure minimum 150 DPI resolution
   - Improve lighting and reduce shadows
   - Straighten skewed documents

2. **Textract Configuration**:
   - Use appropriate Textract features (tables, forms, queries)
   - Implement confidence score filtering
   - Combine multiple detection methods

### Entity Extraction Issues
**Symptoms**: Missing entities, incorrect classifications

**Solutions**:
1. **Comprehend Optimization**:
   - Use custom entity recognition models
   - Implement confidence thresholds
   - Preprocess text to improve accuracy

2. **Text Preprocessing**:
   - Clean extracted text (remove artifacts)
   - Implement spell checking
   - Use domain-specific vocabularies

## Security and Compliance

### Data Privacy Concerns
**Issue**: Sensitive data exposure in logs or temporary storage

**Solutions**:
1. **Log Sanitization**:
   - Remove PII from CloudWatch logs
   - Implement log filtering
   - Use structured logging with field masking

2. **Data Encryption**:
   - Enable S3 bucket encryption
   - Use KMS keys for additional security
   - Implement in-transit encryption

## Emergency Procedures

### System Recovery

#### Complete Service Outage
1. Check AWS service health dashboard
2. Verify IAM permissions and credentials
3. Review recent deployments for breaking changes
4. Implement circuit breaker pattern for external dependencies

#### Data Loss Prevention
1. Enable S3 versioning for all buckets
2. Implement cross-region replication for critical data
3. Regular backup testing and validation
4. Document recovery procedures

## Getting Help

### Internal Resources
1. Check CloudWatch dashboards and alarms
2. Review deployment logs and documentation
3. Consult team knowledge base and runbooks

### AWS Support
1. AWS Support Center (for technical issues)
2. AWS Forums for community support
3. AWS Documentation and troubleshooting guides

### Escalation Procedures
1. Document the issue with logs and error messages
2. Identify business impact and urgency
3. Follow internal escalation procedures
4. Engage AWS Support if needed (based on support plan)

---

**For additional support**, refer to the [architecture documentation](architecture.md) for system design details or the [implementation guide](../delivery/implementation-guide.md) for deployment procedures.