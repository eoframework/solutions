#!/usr/bin/env python3
"""
AWS Intelligent Document Processing - Deployment Script

This script automates the deployment of AWS intelligent document processing solution
using boto3 SDK for AWS service configuration and Lambda function deployment.
"""

import os
import sys
import json
import boto3
import zipfile
import logging
from typing import Dict, List, Optional
from botocore.exceptions import ClientError, BotoCoreError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class IntelligentDocumentProcessingDeployment:
    """AWS Intelligent Document Processing deployment manager"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.session = boto3.Session(
            region_name=config.get('aws_region', 'us-east-1')
        )
        
        # Initialize AWS clients
        self.s3_client = self.session.client('s3')
        self.lambda_client = self.session.client('lambda')
        self.sqs_client = self.session.client('sqs')
        self.iam_client = self.session.client('iam')
        self.textract_client = self.session.client('textract')
        self.comprehend_client = self.session.client('comprehend')
        
        logger.info(f"Initialized deployment for region: {config.get('aws_region')}")
    
    def validate_configuration(self) -> bool:
        """Validate deployment configuration"""
        required_keys = [
            'project_name', 'document_bucket_name', 'aws_region'
        ]
        
        for key in required_keys:
            if key not in self.config:
                logger.error(f"Missing required configuration key: {key}")
                return False
        
        logger.info("Configuration validation successful")
        return True
    
    def create_s3_bucket(self) -> bool:
        """Create S3 bucket for document storage"""
        bucket_name = self.config['document_bucket_name']
        
        try:
            # Check if bucket already exists
            self.s3_client.head_bucket(Bucket=bucket_name)
            logger.info(f"S3 bucket {bucket_name} already exists")
            return True
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == '404':
                # Bucket doesn't exist, create it
                try:
                    if self.config['aws_region'] == 'us-east-1':
                        self.s3_client.create_bucket(Bucket=bucket_name)
                    else:
                        self.s3_client.create_bucket(
                            Bucket=bucket_name,
                            CreateBucketConfiguration={
                                'LocationConstraint': self.config['aws_region']
                            }
                        )
                    
                    # Enable versioning
                    self.s3_client.put_bucket_versioning(
                        Bucket=bucket_name,
                        VersioningConfiguration={'Status': 'Enabled'}
                    )
                    
                    # Enable encryption
                    self.s3_client.put_bucket_encryption(
                        Bucket=bucket_name,
                        ServerSideEncryptionConfiguration={
                            'Rules': [{
                                'ApplyServerSideEncryptionByDefault': {
                                    'SSEAlgorithm': 'AES256'
                                }
                            }]
                        }
                    )
                    
                    logger.info(f"Created S3 bucket: {bucket_name}")
                    return True
                    
                except ClientError as create_error:
                    logger.error(f"Failed to create S3 bucket: {create_error}")
                    return False
            else:
                logger.error(f"Error checking S3 bucket: {e}")
                return False
    
    def create_sqs_queue(self) -> Optional[str]:
        """Create SQS queue for document processing"""
        queue_name = f"{self.config['project_name']}-document-processing"
        
        try:
            response = self.sqs_client.create_queue(
                QueueName=queue_name,
                Attributes={
                    'DelaySeconds': '90',
                    'MaxMessageSize': '262144',
                    'MessageRetentionPeriod': str(self.config.get('sqs_message_retention_seconds', 86400)),
                    'ReceiveMessageWaitTimeSeconds': '10'
                }
            )
            
            queue_url = response['QueueUrl']
            logger.info(f"Created SQS queue: {queue_name}")
            return queue_url
            
        except ClientError as e:
            if 'QueueAlreadyExists' in str(e):
                # Queue exists, get URL
                response = self.sqs_client.get_queue_url(QueueName=queue_name)
                logger.info(f"SQS queue {queue_name} already exists")
                return response['QueueUrl']
            else:
                logger.error(f"Failed to create SQS queue: {e}")
                return None
    
    def create_iam_roles(self) -> Dict[str, str]:
        """Create IAM roles for Lambda and services"""
        roles = {}
        
        # Lambda execution role
        lambda_role_name = f"{self.config['project_name']}-lambda-execution-role"
        lambda_assume_policy = {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "lambda.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }]
        }
        
        try:
            response = self.iam_client.create_role(
                RoleName=lambda_role_name,
                AssumeRolePolicyDocument=json.dumps(lambda_assume_policy),
                Description="Execution role for document processing Lambda"
            )
            roles['lambda_role_arn'] = response['Role']['Arn']
            logger.info(f"Created Lambda execution role: {lambda_role_name}")
            
        except ClientError as e:
            if 'EntityAlreadyExists' in str(e):
                response = self.iam_client.get_role(RoleName=lambda_role_name)
                roles['lambda_role_arn'] = response['Role']['Arn']
                logger.info(f"Lambda execution role {lambda_role_name} already exists")
            else:
                logger.error(f"Failed to create Lambda execution role: {e}")
                return {}
        
        return roles
    
    def package_lambda_function(self) -> Optional[str]:
        """Package Lambda function code"""
        lambda_code = '''
import json
import boto3
import logging
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)

textract = boto3.client('textract')
comprehend = boto3.client('comprehend')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """Process documents using AWS AI services"""
    
    try:
        # Parse S3 event
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = unquote_plus(record['s3']['object']['key'])
            
            logger.info(f"Processing document: {key} from bucket: {bucket}")
            
            # Extract text using Textract
            textract_response = textract.detect_document_text(
                Document={
                    'S3Object': {
                        'Bucket': bucket,
                        'Name': key
                    }
                }
            )
            
            # Extract text content
            extracted_text = ""
            for block in textract_response['Blocks']:
                if block['BlockType'] == 'LINE':
                    extracted_text += block['Text'] + "\n"
            
            logger.info(f"Extracted {len(extracted_text)} characters from document")
            
            # Analyze with Comprehend if text is long enough
            if len(extracted_text) > 10:
                comprehend_response = comprehend.detect_entities(
                    Text=extracted_text[:5000],  # Limit text length
                    LanguageCode='en'
                )
                
                entities = comprehend_response['Entities']
                logger.info(f"Detected {len(entities)} entities")
            
            # Store results back to S3
            result_key = f"processed/{key}.json"
            result_data = {
                'original_document': key,
                'extracted_text': extracted_text,
                'entities': entities if 'entities' in locals() else [],
                'processing_timestamp': context.aws_request_id
            }
            
            s3.put_object(
                Bucket=bucket,
                Key=result_key,
                Body=json.dumps(result_data),
                ContentType='application/json'
            )
            
            logger.info(f"Processing completed for {key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Document processing completed successfully')
        }
        
    except Exception as e:
        logger.error(f"Error processing document: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
'''
        
        zip_filename = '/tmp/document_processor.zip'
        
        try:
            with zipfile.ZipFile(zip_filename, 'w') as zip_file:
                zip_file.writestr('lambda_function.py', lambda_code)
            
            logger.info(f"Created Lambda package: {zip_filename}")
            return zip_filename
            
        except Exception as e:
            logger.error(f"Failed to package Lambda function: {e}")
            return None
    
    def deploy_lambda_function(self, role_arn: str, queue_url: str) -> bool:
        """Deploy Lambda function"""
        function_name = f"{self.config['project_name']}-document-processor"
        
        # Package function code
        zip_path = self.package_lambda_function()
        if not zip_path:
            return False
        
        try:
            with open(zip_path, 'rb') as zip_file:
                zip_content = zip_file.read()
            
            # Create or update Lambda function
            try:
                response = self.lambda_client.create_function(
                    FunctionName=function_name,
                    Runtime='python3.9',
                    Role=role_arn,
                    Handler='lambda_function.lambda_handler',
                    Code={'ZipFile': zip_content},
                    Timeout=self.config.get('lambda_timeout', 300),
                    MemorySize=self.config.get('lambda_memory_size', 512),
                    Environment={
                        'Variables': {
                            'DOCUMENT_BUCKET': self.config['document_bucket_name'],
                            'PROCESSING_QUEUE': queue_url
                        }
                    },
                    Description='Document processing using AWS AI services'
                )
                logger.info(f"Created Lambda function: {function_name}")
                
            except ClientError as e:
                if 'ResourceConflictException' in str(e):
                    # Function exists, update code
                    self.lambda_client.update_function_code(
                        FunctionName=function_name,
                        ZipFile=zip_content
                    )
                    logger.info(f"Updated Lambda function: {function_name}")
                else:
                    raise e
            
            # Clean up zip file
            os.remove(zip_path)
            return True
            
        except Exception as e:
            logger.error(f"Failed to deploy Lambda function: {e}")
            return False
    
    def configure_s3_trigger(self) -> bool:
        """Configure S3 bucket to trigger Lambda function"""
        bucket_name = self.config['document_bucket_name']
        function_name = f"{self.config['project_name']}-document-processor"
        
        try:
            # Add permission for S3 to invoke Lambda
            try:
                self.lambda_client.add_permission(
                    FunctionName=function_name,
                    StatementId='AllowExecutionFromS3Bucket',
                    Action='lambda:InvokeFunction',
                    Principal='s3.amazonaws.com',
                    SourceArn=f"arn:aws:s3:::{bucket_name}"
                )
                logger.info("Added S3 invoke permission to Lambda")
            except ClientError as e:
                if 'ResourceConflictException' in str(e):
                    logger.info("S3 invoke permission already exists")
                else:
                    raise e
            
            # Configure S3 bucket notification
            notification_config = {
                'LambdaConfigurations': [{
                    'Id': 'DocumentProcessingTrigger',
                    'LambdaFunctionArn': f"arn:aws:lambda:{self.config['aws_region']}:{self.session.client('sts').get_caller_identity()['Account']}:function:{function_name}",
                    'Events': ['s3:ObjectCreated:*']
                }]
            }
            
            self.s3_client.put_bucket_notification_configuration(
                Bucket=bucket_name,
                NotificationConfiguration=notification_config
            )
            
            logger.info("Configured S3 bucket notification")
            return True
            
        except Exception as e:
            logger.error(f"Failed to configure S3 trigger: {e}")
            return False
    
    def deploy(self) -> bool:
        """Execute full deployment"""
        logger.info("Starting AWS Intelligent Document Processing deployment")
        
        if not self.validate_configuration():
            return False
        
        # Create S3 bucket
        if not self.create_s3_bucket():
            logger.error("Failed to create S3 bucket")
            return False
        
        # Create SQS queue
        queue_url = self.create_sqs_queue()
        if not queue_url:
            logger.error("Failed to create SQS queue")
            return False
        
        # Create IAM roles
        roles = self.create_iam_roles()
        if not roles:
            logger.error("Failed to create IAM roles")
            return False
        
        # Deploy Lambda function
        if not self.deploy_lambda_function(roles['lambda_role_arn'], queue_url):
            logger.error("Failed to deploy Lambda function")
            return False
        
        # Configure S3 trigger
        if not self.configure_s3_trigger():
            logger.error("Failed to configure S3 trigger")
            return False
        
        logger.info("AWS Intelligent Document Processing deployment completed successfully")
        return True

def main():
    """Main deployment function"""
    
    # Load configuration
    config = {
        'project_name': os.getenv('PROJECT_NAME', 'intelligent-doc-processing'),
        'document_bucket_name': os.getenv('DOCUMENT_BUCKET_NAME'),
        'aws_region': os.getenv('AWS_REGION', 'us-east-1'),
        'lambda_memory_size': int(os.getenv('LAMBDA_MEMORY_SIZE', '512')),
        'lambda_timeout': int(os.getenv('LAMBDA_TIMEOUT', '300')),
        'sqs_message_retention_seconds': int(os.getenv('SQS_MESSAGE_RETENTION_SECONDS', '86400'))
    }
    
    if not config['document_bucket_name']:
        logger.error("DOCUMENT_BUCKET_NAME environment variable is required")
        sys.exit(1)
    
    # Initialize deployment
    deployment = IntelligentDocumentProcessingDeployment(config)
    
    # Execute deployment
    if deployment.deploy():
        logger.info("Deployment completed successfully")
        sys.exit(0)
    else:
        logger.error("Deployment failed")
        sys.exit(1)

if __name__ == '__main__':
    main()