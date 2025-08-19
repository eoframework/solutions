# Configuration Templates - AWS Intelligent Document Processing

## Overview

This document provides comprehensive configuration templates for AWS Intelligent Document Processing solution, including service configurations, infrastructure templates, and integration specifications.

---

## AWS Service Configurations

### Amazon Textract Configuration

#### Document Analysis Configuration
```json
{
  "FeatureTypes": ["TABLES", "FORMS", "QUERIES"],
  "QueriesConfig": {
    "Queries": [
      {
        "Text": "What is the invoice number?",
        "Alias": "INVOICE_NUMBER"
      },
      {
        "Text": "What is the total amount?",
        "Alias": "TOTAL_AMOUNT"
      },
      {
        "Text": "What is the vendor name?",
        "Alias": "VENDOR_NAME"
      }
    ]
  },
  "AdaptersConfig": {
    "Adapters": [
      {
        "AdapterId": "custom-invoice-adapter",
        "Version": "1.0"
      }
    ]
  }
}
```

#### Textract Processing Lambda Function
```python
import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

textract = boto3.client('textract')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Process document with Amazon Textract
    """
    try:
        # Extract S3 bucket and key from event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        # Configure Textract analysis
        response = textract.analyze_document(
            Document={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            },
            FeatureTypes=['TABLES', 'FORMS'],
            HumanLoopConfig={
                'HumanLoopName': f'review-{key}',
                'FlowDefinitionArn': 'arn:aws:sagemaker:region:account:flow-definition/document-review',
                'DataAttributes': {
                    'ContentClassifiers': ['FreeOfPersonallyIdentifiableInformation']
                }
            }
        )
        
        # Store results in DynamoDB
        store_results(key, response)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Document processed successfully',
                'jobId': response.get('JobId'),
                'humanLoopActivationOutput': response.get('HumanLoopActivationOutput')
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing document: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def store_results(document_key, textract_response):
    """Store Textract results in DynamoDB"""
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('DocumentProcessingResults')
    
    table.put_item(
        Item={
            'DocumentId': document_key,
            'ProcessingResults': textract_response,
            'ProcessedAt': context.aws_request_id,
            'Status': 'COMPLETED'
        }
    )
```

### Amazon Comprehend Configuration

#### Entity Recognition Setup
```python
import boto3

def setup_custom_entity_recognizer():
    """Configure custom entity recognizer for document processing"""
    comprehend = boto3.client('comprehend')
    
    entity_recognizer_config = {
        'RecognizerName': 'DocumentEntityRecognizer',
        'LanguageCode': 'en',
        'DataAccessRoleArn': 'arn:aws:iam::account:role/ComprehendDataAccessRole',
        'InputDataConfig': {
            'EntityTypes': [
                {'Type': 'INVOICE_NUMBER'},
                {'Type': 'VENDOR_NAME'},
                {'Type': 'CUSTOMER_NAME'},
                {'Type': 'AMOUNT'},
                {'Type': 'DATE'},
                {'Type': 'ADDRESS'}
            ],
            'Documents': {
                'S3Uri': 's3://training-data-bucket/documents/',
                'InputFormat': 'ONE_DOC_PER_LINE'
            },
            'Annotations': {
                'S3Uri': 's3://training-data-bucket/annotations/'
            }
        },
        'Tags': [
            {'Key': 'Environment', 'Value': 'Production'},
            {'Key': 'Application', 'Value': 'DocumentProcessing'}
        ]
    }
    
    response = comprehend.create_entity_recognizer(**entity_recognizer_config)
    return response['EntityRecognizerArn']

def analyze_document_entities(text):
    """Analyze document text for entities"""
    comprehend = boto3.client('comprehend')
    
    response = comprehend.detect_entities(
        Text=text,
        LanguageCode='en',
        EndpointArn='arn:aws:comprehend:region:account:entity-recognizer-endpoint/document-entities'
    )
    
    return response['Entities']
```

### Amazon A2I (Augmented AI) Configuration

#### Human Review Workflow
```json
{
  "FlowDefinitionName": "document-review-workflow",
  "RoleArn": "arn:aws:iam::account:role/A2IExecutionRole",
  "HumanLoopConfig": {
    "WorkteamArn": "arn:aws:sagemaker:region:account:workteam/private-workforce/document-reviewers",
    "HumanTaskUiArn": "arn:aws:sagemaker:region:account:human-task-ui/document-review-ui",
    "TaskTitle": "Review Document Processing Results",
    "TaskDescription": "Please review and validate the extracted data from the document",
    "TaskCount": 1,
    "TaskAvailabilityLifetimeInSeconds": 3600,
    "TaskTimeLimitInSeconds": 1800,
    "TaskKeywords": ["document", "review", "validation"],
    "PublicWorkforceTaskPrice": {
      "AmountInUsd": {
        "Dollars": 0,
        "Cents": 30,
        "TenthFractionsOfACent": 0
      }
    }
  },
  "OutputConfig": {
    "S3OutputPath": "s3://a2i-results-bucket/document-reviews/"
  },
  "Tags": [
    {
      "Key": "Environment",
      "Value": "Production"
    }
  ]
}
```

#### A2I Custom UI Template
```html
<!DOCTYPE html>
<html>
<head>
    <title>Document Review Interface</title>
    <script src="https://assets.crowd.aws/crowd-html-elements.js"></script>
    <style>
        .review-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .document-preview {
            width: 50%;
            float: left;
            padding-right: 20px;
        }
        .extracted-data {
            width: 50%;
            float: right;
        }
        .data-field {
            margin-bottom: 15px;
        }
        .confidence-score {
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <crowd-form>
        <div class="review-container">
            <h2>Document Processing Review</h2>
            
            <div class="document-preview">
                <h3>Original Document</h3>
                <img src="{{ task.input.documentUrl }}" style="max-width: 100%; height: auto;">
            </div>
            
            <div class="extracted-data">
                <h3>Extracted Data - Please Verify</h3>
                
                <div class="data-field">
                    <label>Invoice Number:</label>
                    <crowd-input name="invoice_number" value="{{ task.input.extractedData.invoiceNumber }}" required></crowd-input>
                    <span class="confidence-score">Confidence: {{ task.input.confidence.invoiceNumber }}%</span>
                </div>
                
                <div class="data-field">
                    <label>Vendor Name:</label>
                    <crowd-input name="vendor_name" value="{{ task.input.extractedData.vendorName }}" required></crowd-input>
                    <span class="confidence-score">Confidence: {{ task.input.confidence.vendorName }}%</span>
                </div>
                
                <div class="data-field">
                    <label>Total Amount:</label>
                    <crowd-input name="total_amount" value="{{ task.input.extractedData.totalAmount }}" required></crowd-input>
                    <span class="confidence-score">Confidence: {{ task.input.confidence.totalAmount }}%</span>
                </div>
                
                <div class="data-field">
                    <label>Date:</label>
                    <crowd-input name="document_date" value="{{ task.input.extractedData.date }}" required></crowd-input>
                    <span class="confidence-score">Confidence: {{ task.input.confidence.date }}%</span>
                </div>
                
                <div class="data-field">
                    <label>Comments (if any corrections needed):</label>
                    <crowd-text-area name="review_comments" placeholder="Enter any comments or corrections"></crowd-text-area>
                </div>
                
                <div class="data-field">
                    <crowd-radio-group>
                        <crowd-radio-button name="review_decision" value="approve">Approve - Data is correct</crowd-radio-button>
                        <crowd-radio-button name="review_decision" value="correct">Needs Correction - I've made changes</crowd-radio-button>
                        <crowd-radio-button name="review_decision" value="reject">Reject - Document cannot be processed</crowd-radio-button>
                    </crowd-radio-group>
                </div>
            </div>
        </div>
    </crowd-form>
</body>
</html>
```

---

## Infrastructure Configuration Templates

### CloudFormation Template
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS Intelligent Document Processing Infrastructure'

Parameters:
  Environment:
    Type: String
    Default: production
    AllowedValues: [development, staging, production]
  
  DocumentBucketName:
    Type: String
    Description: S3 bucket for document storage

Resources:
  # S3 Buckets
  DocumentStorageBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${DocumentBucketName}-${Environment}'
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      LifecycleConfiguration:
        Rules:
          - Id: DocumentLifecycle
            Status: Enabled
            Transitions:
              - TransitionInDays: 30
                StorageClass: STANDARD_IA
              - TransitionInDays: 90
                StorageClass: GLACIER
      NotificationConfiguration:
        LambdaConfigurations:
          - Event: s3:ObjectCreated:*
            Function: !GetAtt DocumentProcessingFunction.Arn

  # DynamoDB Table
  DocumentMetadataTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub 'DocumentProcessing-${Environment}'
      BillingMode: ON_DEMAND
      AttributeDefinitions:
        - AttributeName: DocumentId
          AttributeType: S
        - AttributeName: ProcessedAt
          AttributeType: S
      KeySchema:
        - AttributeName: DocumentId
          KeyType: HASH
        - AttributeName: ProcessedAt
          KeyType: RANGE
      StreamSpecification:
        StreamViewType: NEW_AND_OLD_IMAGES
      SSESpecification:
        SSEEnabled: true
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Lambda Function
  DocumentProcessingFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub 'document-processing-${Environment}'
      Runtime: python3.9
      Handler: lambda_function.lambda_handler
      Code:
        ZipFile: |
          def lambda_handler(event, context):
              return {'statusCode': 200, 'body': 'Function created'}
      Role: !GetAtt LambdaExecutionRole.Arn
      Timeout: 300
      MemorySize: 1024
      Environment:
        Variables:
          DYNAMODB_TABLE: !Ref DocumentMetadataTable
          S3_BUCKET: !Ref DocumentStorageBucket

  # IAM Roles
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: TextractAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - textract:*
                  - comprehend:*
                  - sagemaker:*
                Resource: '*'
        - PolicyName: S3Access
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                Resource: !Sub '${DocumentStorageBucket}/*'
        - PolicyName: DynamoDBAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:PutItem
                  - dynamodb:GetItem
                  - dynamodb:UpdateItem
                  - dynamodb:Query
                Resource: !GetAtt DocumentMetadataTable.Arn

  # API Gateway
  DocumentProcessingAPI:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: !Sub 'document-processing-api-${Environment}'
      Description: 'API for document processing operations'
      EndpointConfiguration:
        Types:
          - REGIONAL

Outputs:
  S3BucketName:
    Description: Name of the S3 bucket for documents
    Value: !Ref DocumentStorageBucket
    Export:
      Name: !Sub '${AWS::StackName}-S3Bucket'
  
  DynamoDBTableName:
    Description: Name of the DynamoDB table
    Value: !Ref DocumentMetadataTable
    Export:
      Name: !Sub '${AWS::StackName}-DynamoDBTable'
```

### Terraform Configuration
```hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for document storage
resource "aws_s3_bucket" "document_storage" {
  bucket = "${var.project_name}-documents-${var.environment}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "document_storage_versioning" {
  bucket = aws_s3_bucket.document_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "document_storage_encryption" {
  bucket = aws_s3_bucket.document_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for metadata
resource "aws_dynamodb_table" "document_metadata" {
  name           = "${var.project_name}-metadata-${var.environment}"
  billing_mode   = "ON_DEMAND"
  hash_key       = "DocumentId"
  range_key      = "ProcessedAt"

  attribute {
    name = "DocumentId"
    type = "S"
  }

  attribute {
    name = "ProcessedAt"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Lambda function for document processing
resource "aws_lambda_function" "document_processor" {
  filename         = "document_processor.zip"
  function_name    = "${var.project_name}-processor-${var.environment}"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 1024

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.document_metadata.name
      S3_BUCKET      = aws_s3_bucket.document_storage.bucket
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

---

## API Configuration

### REST API Specification
```yaml
openapi: 3.0.0
info:
  title: Document Processing API
  version: 1.0.0
  description: API for intelligent document processing

paths:
  /documents:
    post:
      summary: Submit document for processing
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                file:
                  type: string
                  format: binary
                document_type:
                  type: string
                  enum: [invoice, form, contract, receipt]
                priority:
                  type: string
                  enum: [low, normal, high, urgent]
      responses:
        '200':
          description: Document submitted successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  document_id:
                    type: string
                  status:
                    type: string
                  estimated_completion:
                    type: string

  /documents/{document_id}:
    get:
      summary: Get document processing status
      parameters:
        - name: document_id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Document status retrieved
          content:
            application/json:
              schema:
                type: object
                properties:
                  document_id:
                    type: string
                  status:
                    type: string
                  progress:
                    type: integer
                  results:
                    type: object

  /documents/{document_id}/results:
    get:
      summary: Get extracted document data
      parameters:
        - name: document_id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Extracted data retrieved
          content:
            application/json:
              schema:
                type: object
                properties:
                  document_id:
                    type: string
                  extracted_data:
                    type: object
                  confidence_scores:
                    type: object
```

---

## Monitoring Configuration

### CloudWatch Dashboards
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Duration", "FunctionName", "document-processing-production"],
          ["AWS/Lambda", "Errors", "FunctionName", "document-processing-production"],
          ["AWS/Lambda", "Invocations", "FunctionName", "document-processing-production"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Lambda Performance"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/S3", "BucketSizeBytes", "BucketName", "document-storage-production"],
          ["AWS/S3", "NumberOfObjects", "BucketName", "document-storage-production"]
        ],
        "period": 86400,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Document Storage"
      }
    }
  ]
}
```

### CloudWatch Alarms
```yaml
ProcessingErrorAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: DocumentProcessingErrors
    AlarmDescription: Alert when document processing errors exceed threshold
    MetricName: Errors
    Namespace: AWS/Lambda
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 2
    Threshold: 5
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: FunctionName
        Value: !Ref DocumentProcessingFunction
    AlarmActions:
      - !Ref SNSAlarmTopic

HighProcessingTimeAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: DocumentProcessingHighLatency
    AlarmDescription: Alert when processing time exceeds 60 seconds
    MetricName: Duration
    Namespace: AWS/Lambda
    Statistic: Average
    Period: 300
    EvaluationPeriods: 3
    Threshold: 60000
    ComparisonOperator: GreaterThanThreshold
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: AI Solutions Configuration Team