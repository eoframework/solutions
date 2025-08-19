# Testing Procedures - AWS Intelligent Document Processing

## Overview

This document outlines comprehensive testing procedures for AWS Intelligent Document Processing solution to ensure AI accuracy, performance validation, and operational readiness.

---

## Pre-Implementation Testing

### 1. AI Model Validation Testing
```python
#!/usr/bin/env python3
# ai_model_validation.py

import boto3
import json
import pandas as pd
from datetime import datetime

class AIModelValidator:
    def __init__(self, region='us-east-1'):
        self.textract = boto3.client('textract', region_name=region)
        self.comprehend = boto3.client('comprehend', region_name=region)
        self.s3 = boto3.client('s3', region_name=region)
        
    def test_textract_accuracy(self, test_documents):
        """Test Textract OCR accuracy with known ground truth"""
        results = []
        
        for doc in test_documents:
            # Process document with Textract
            response = self.textract.analyze_document(
                Document={'S3Object': {'Bucket': doc['bucket'], 'Name': doc['key']}},
                FeatureTypes=['TABLES', 'FORMS']
            )
            
            # Extract text and compare with ground truth
            extracted_text = self.extract_text_from_response(response)
            accuracy = self.calculate_accuracy(extracted_text, doc['ground_truth'])
            
            results.append({
                'document': doc['name'],
                'accuracy': accuracy,
                'confidence': self.get_average_confidence(response),
                'processing_time': response['ResponseMetadata']['HTTPHeaders'].get('date')
            })
        
        return results
    
    def test_comprehend_entities(self, test_texts):
        """Test Comprehend entity recognition accuracy"""
        results = []
        
        for text_sample in test_texts:
            response = self.comprehend.detect_entities(
                Text=text_sample['text'],
                LanguageCode='en'
            )
            
            # Compare detected entities with expected entities
            detected_entities = [entity['Text'] for entity in response['Entities']]
            precision, recall = self.calculate_entity_metrics(
                detected_entities, 
                text_sample['expected_entities']
            )
            
            results.append({
                'sample': text_sample['name'],
                'precision': precision,
                'recall': recall,
                'entities_detected': len(detected_entities),
                'entities_expected': len(text_sample['expected_entities'])
            })
        
        return results
    
    def extract_text_from_response(self, response):
        """Extract text from Textract response"""
        text = ""
        for block in response['Blocks']:
            if block['BlockType'] == 'LINE':
                text += block['Text'] + '\n'
        return text
    
    def calculate_accuracy(self, extracted_text, ground_truth):
        """Calculate text extraction accuracy using edit distance"""
        # Implement edit distance calculation
        import difflib
        similarity = difflib.SequenceMatcher(None, extracted_text, ground_truth).ratio()
        return similarity * 100
    
    def get_average_confidence(self, response):
        """Calculate average confidence score from Textract response"""
        confidences = []
        for block in response['Blocks']:
            if 'Confidence' in block:
                confidences.append(block['Confidence'])
        return sum(confidences) / len(confidences) if confidences else 0

# Usage example
if __name__ == "__main__":
    validator = AIModelValidator()
    
    # Test documents with ground truth
    test_docs = [
        {
            'name': 'invoice_001.pdf',
            'bucket': 'test-documents',
            'key': 'invoices/invoice_001.pdf',
            'ground_truth': 'Expected invoice text content...'
        }
    ]
    
    textract_results = validator.test_textract_accuracy(test_docs)
    print("Textract Accuracy Results:")
    for result in textract_results:
        print(f"Document: {result['document']}, Accuracy: {result['accuracy']:.2f}%")
```

### 2. Document Format Compatibility Testing
```bash
#!/bin/bash
# document_format_test.sh

echo "Testing document format compatibility..."

# Test supported formats
FORMATS=("pdf" "png" "jpg" "jpeg" "tiff")
TEST_BUCKET="document-processing-test"

for format in "${FORMATS[@]}"; do
    echo "Testing format: $format"
    
    # Upload test document
    aws s3 cp "test_documents/sample.$format" "s3://$TEST_BUCKET/format_tests/"
    
    # Trigger processing
    python3 test_processing.py --document "sample.$format" --format "$format"
    
    # Check results
    if [ $? -eq 0 ]; then
        echo "✓ Format $format: PASS"
    else
        echo "✗ Format $format: FAIL"
    fi
done

echo "Format compatibility testing completed"
```

### 3. Load and Capacity Testing
```python
import concurrent.futures
import time
import boto3
import statistics

def load_test_document_processing():
    """Simulate high-volume document processing"""
    
    def process_single_document(doc_info):
        start_time = time.time()
        
        # Simulate document upload and processing
        s3 = boto3.client('s3')
        textract = boto3.client('textract')
        
        try:
            # Upload document
            s3.upload_file(doc_info['local_path'], doc_info['bucket'], doc_info['key'])
            
            # Process with Textract
            response = textract.analyze_document(
                Document={'S3Object': {'Bucket': doc_info['bucket'], 'Name': doc_info['key']}},
                FeatureTypes=['TABLES', 'FORMS']
            )
            
            end_time = time.time()
            return {
                'success': True,
                'processing_time': end_time - start_time,
                'document': doc_info['key']
            }
            
        except Exception as e:
            end_time = time.time()
            return {
                'success': False,
                'processing_time': end_time - start_time,
                'error': str(e),
                'document': doc_info['key']
            }
    
    # Generate test document list
    test_documents = []
    for i in range(100):  # Test with 100 documents
        test_documents.append({
            'local_path': f'test_docs/sample_{i % 10}.pdf',  # Rotate through 10 sample docs
            'bucket': 'load-test-bucket',
            'key': f'load_test/document_{i}.pdf'
        })
    
    # Execute load test with concurrent processing
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        results = list(executor.map(process_single_document, test_documents))
    
    end_time = time.time()
    
    # Analyze results
    successful_docs = [r for r in results if r['success']]
    failed_docs = [r for r in results if not r['success']]
    processing_times = [r['processing_time'] for r in successful_docs]
    
    print(f"Load Test Results:")
    print(f"Total Documents: {len(test_documents)}")
    print(f"Successful: {len(successful_docs)} ({len(successful_docs)/len(test_documents)*100:.1f}%)")
    print(f"Failed: {len(failed_docs)} ({len(failed_docs)/len(test_documents)*100:.1f}%)")
    print(f"Total Time: {end_time - start_time:.2f} seconds")
    print(f"Documents/Hour: {len(test_documents) / (end_time - start_time) * 3600:.0f}")
    
    if processing_times:
        print(f"Average Processing Time: {statistics.mean(processing_times):.2f} seconds")
        print(f"Median Processing Time: {statistics.median(processing_times):.2f} seconds")
        print(f"95th Percentile: {sorted(processing_times)[int(len(processing_times)*0.95)]:.2f} seconds")

if __name__ == "__main__":
    load_test_document_processing()
```

---

## AI Accuracy Testing

### 4. Ground Truth Validation
```python
class AccuracyValidator:
    def __init__(self):
        self.textract = boto3.client('textract')
        
    def validate_invoice_extraction(self, test_invoices):
        """Validate invoice data extraction accuracy"""
        results = []
        
        for invoice in test_invoices:
            # Process invoice with Textract
            response = self.textract.analyze_expense(
                Document={'S3Object': {'Bucket': invoice['bucket'], 'Name': invoice['key']}}
            )
            
            # Extract key-value pairs
            extracted_data = self.extract_invoice_data(response)
            
            # Compare with ground truth
            accuracy_metrics = self.compare_with_ground_truth(
                extracted_data, 
                invoice['ground_truth']
            )
            
            results.append({
                'invoice': invoice['name'],
                'accuracy_metrics': accuracy_metrics,
                'extracted_data': extracted_data
            })
        
        return results
    
    def extract_invoice_data(self, response):
        """Extract structured data from Textract expense analysis"""
        extracted = {}
        
        for expense_document in response['ExpenseDocuments']:
            for summary_field in expense_document['SummaryFields']:
                field_type = summary_field['Type']['Text']
                field_value = summary_field['ValueDetection']['Text'] if summary_field['ValueDetection'] else None
                confidence = summary_field['ValueDetection']['Confidence'] if summary_field['ValueDetection'] else 0
                
                extracted[field_type] = {
                    'value': field_value,
                    'confidence': confidence
                }
        
        return extracted
    
    def compare_with_ground_truth(self, extracted, ground_truth):
        """Compare extracted data with ground truth"""
        metrics = {}
        
        for field, expected_value in ground_truth.items():
            if field in extracted and extracted[field]['value']:
                actual_value = extracted[field]['value']
                
                # Exact match
                exact_match = actual_value.strip() == expected_value.strip()
                
                # Fuzzy match for text fields
                fuzzy_score = self.calculate_fuzzy_match(actual_value, expected_value)
                
                metrics[field] = {
                    'expected': expected_value,
                    'actual': actual_value,
                    'exact_match': exact_match,
                    'fuzzy_score': fuzzy_score,
                    'confidence': extracted[field]['confidence']
                }
            else:
                metrics[field] = {
                    'expected': expected_value,
                    'actual': None,
                    'exact_match': False,
                    'fuzzy_score': 0,
                    'confidence': 0
                }
        
        return metrics
    
    def calculate_fuzzy_match(self, actual, expected):
        """Calculate fuzzy match score using difflib"""
        import difflib
        return difflib.SequenceMatcher(None, actual.lower(), expected.lower()).ratio()
```

### 5. Edge Case Testing
```python
def test_edge_cases():
    """Test AI models with challenging documents"""
    
    edge_cases = [
        {
            'type': 'low_quality_scan',
            'description': 'Poor quality scanned documents',
            'documents': ['blurry_invoice.pdf', 'faded_contract.pdf']
        },
        {
            'type': 'handwritten_text',
            'description': 'Documents with handwritten content',
            'documents': ['handwritten_form.pdf', 'mixed_content.pdf']
        },
        {
            'type': 'unusual_layouts',
            'description': 'Non-standard document layouts',
            'documents': ['rotated_document.pdf', 'multi_column.pdf']
        },
        {
            'type': 'multilingual',
            'description': 'Documents in multiple languages',
            'documents': ['spanish_invoice.pdf', 'french_contract.pdf']
        }
    ]
    
    textract = boto3.client('textract')
    results = {}
    
    for case in edge_cases:
        case_results = []
        
        for doc in case['documents']:
            try:
                response = textract.analyze_document(
                    Document={'S3Object': {'Bucket': 'edge-case-tests', 'Name': doc}},
                    FeatureTypes=['TABLES', 'FORMS']
                )
                
                # Calculate average confidence
                confidences = []
                for block in response['Blocks']:
                    if 'Confidence' in block:
                        confidences.append(block['Confidence'])
                
                avg_confidence = sum(confidences) / len(confidences) if confidences else 0
                
                case_results.append({
                    'document': doc,
                    'success': True,
                    'confidence': avg_confidence,
                    'blocks_detected': len(response['Blocks'])
                })
                
            except Exception as e:
                case_results.append({
                    'document': doc,
                    'success': False,
                    'error': str(e)
                })
        
        results[case['type']] = {
            'description': case['description'],
            'results': case_results
        }
    
    return results
```

---

## Integration Testing

### 6. End-to-End Workflow Testing
```python
import requests
import time

class WorkflowTester:
    def __init__(self, api_base_url):
        self.api_base_url = api_base_url
        
    def test_complete_workflow(self, test_document):
        """Test complete document processing workflow"""
        
        # Step 1: Upload document
        upload_response = self.upload_document(test_document)
        assert upload_response.status_code == 200
        
        document_id = upload_response.json()['document_id']
        print(f"Document uploaded: {document_id}")
        
        # Step 2: Monitor processing status
        processing_complete = False
        timeout = 300  # 5 minutes
        start_time = time.time()
        
        while not processing_complete and (time.time() - start_time) < timeout:
            status_response = self.get_processing_status(document_id)
            status = status_response.json()['status']
            
            print(f"Processing status: {status}")
            
            if status == 'COMPLETED':
                processing_complete = True
            elif status == 'FAILED':
                raise Exception(f"Document processing failed: {status_response.json()}")
            
            time.sleep(10)  # Wait 10 seconds before checking again
        
        if not processing_complete:
            raise Exception("Processing timeout exceeded")
        
        # Step 3: Retrieve results
        results_response = self.get_processing_results(document_id)
        assert results_response.status_code == 200
        
        results = results_response.json()
        print(f"Processing completed successfully")
        
        # Step 4: Validate results structure
        self.validate_results_structure(results)
        
        return results
    
    def upload_document(self, document_path):
        """Upload document via API"""
        with open(document_path, 'rb') as f:
            files = {'file': f}
            data = {'document_type': 'invoice', 'priority': 'normal'}
            
            response = requests.post(
                f"{self.api_base_url}/documents",
                files=files,
                data=data
            )
        
        return response
    
    def get_processing_status(self, document_id):
        """Get document processing status"""
        response = requests.get(f"{self.api_base_url}/documents/{document_id}")
        return response
    
    def get_processing_results(self, document_id):
        """Get document processing results"""
        response = requests.get(f"{self.api_base_url}/documents/{document_id}/results")
        return response
    
    def validate_results_structure(self, results):
        """Validate that results have expected structure"""
        required_fields = ['document_id', 'extracted_data', 'confidence_scores', 'processing_time']
        
        for field in required_fields:
            assert field in results, f"Missing required field: {field}"
        
        # Validate extracted data structure
        extracted_data = results['extracted_data']
        assert isinstance(extracted_data, dict), "extracted_data must be a dictionary"
        
        # Validate confidence scores
        confidence_scores = results['confidence_scores']
        assert isinstance(confidence_scores, dict), "confidence_scores must be a dictionary"
        
        print("Results structure validation passed")

# Usage
if __name__ == "__main__":
    tester = WorkflowTester("https://api.documentprocessing.company.com")
    
    test_documents = [
        'test_invoice.pdf',
        'test_contract.pdf',
        'test_form.pdf'
    ]
    
    for doc in test_documents:
        print(f"\nTesting workflow with {doc}")
        try:
            results = tester.test_complete_workflow(doc)
            print(f"✓ Workflow test passed for {doc}")
        except Exception as e:
            print(f"✗ Workflow test failed for {doc}: {str(e)}")
```

### 7. API Integration Testing
```bash
#!/bin/bash
# api_integration_test.sh

API_BASE="https://api.documentprocessing.company.com"
TEST_DOC="test_invoice.pdf"

echo "Testing API Integration..."

# Test 1: Health check
echo "Testing health endpoint..."
curl -f "$API_BASE/health" || { echo "Health check failed"; exit 1; }
echo "✓ Health check passed"

# Test 2: Authentication
echo "Testing authentication..."
AUTH_RESPONSE=$(curl -s -X POST "$API_BASE/auth" \
  -H "Content-Type: application/json" \
  -d '{"api_key": "'$API_KEY'"}')

TOKEN=$(echo $AUTH_RESPONSE | jq -r '.token')
if [ "$TOKEN" = "null" ]; then
    echo "✗ Authentication failed"
    exit 1
fi
echo "✓ Authentication successful"

# Test 3: Document upload
echo "Testing document upload..."
UPLOAD_RESPONSE=$(curl -s -X POST "$API_BASE/documents" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@$TEST_DOC" \
  -F "document_type=invoice")

DOCUMENT_ID=$(echo $UPLOAD_RESPONSE | jq -r '.document_id')
if [ "$DOCUMENT_ID" = "null" ]; then
    echo "✗ Document upload failed"
    exit 1
fi
echo "✓ Document uploaded: $DOCUMENT_ID"

# Test 4: Status monitoring
echo "Monitoring processing status..."
while true; do
    STATUS_RESPONSE=$(curl -s "$API_BASE/documents/$DOCUMENT_ID" \
      -H "Authorization: Bearer $TOKEN")
    
    STATUS=$(echo $STATUS_RESPONSE | jq -r '.status')
    echo "Status: $STATUS"
    
    if [ "$STATUS" = "COMPLETED" ]; then
        echo "✓ Processing completed"
        break
    elif [ "$STATUS" = "FAILED" ]; then
        echo "✗ Processing failed"
        exit 1
    fi
    
    sleep 10
done

# Test 5: Results retrieval
echo "Testing results retrieval..."
RESULTS_RESPONSE=$(curl -s "$API_BASE/documents/$DOCUMENT_ID/results" \
  -H "Authorization: Bearer $TOKEN")

if echo $RESULTS_RESPONSE | jq -e '.extracted_data' > /dev/null; then
    echo "✓ Results retrieved successfully"
else
    echo "✗ Results retrieval failed"
    exit 1
fi

echo "All API integration tests passed!"
```

---

## Performance Testing

### 8. Concurrent Processing Testing
```python
import asyncio
import aiohttp
import time
from statistics import mean, median

async def concurrent_processing_test():
    """Test concurrent document processing"""
    
    async def process_document(session, doc_id):
        start_time = time.time()
        
        # Upload document
        with open(f'test_docs/doc_{doc_id}.pdf', 'rb') as f:
            data = aiohttp.FormData()
            data.add_field('file', f, filename=f'doc_{doc_id}.pdf')
            data.add_field('document_type', 'invoice')
            
            async with session.post(
                'https://api.documentprocessing.company.com/documents',
                data=data,
                headers={'Authorization': f'Bearer {API_TOKEN}'}
            ) as response:
                upload_result = await response.json()
                document_id = upload_result['document_id']
        
        # Monitor processing
        processing_complete = False
        while not processing_complete:
            async with session.get(
                f'https://api.documentprocessing.company.com/documents/{document_id}',
                headers={'Authorization': f'Bearer {API_TOKEN}'}
            ) as response:
                status_result = await response.json()
                
                if status_result['status'] == 'COMPLETED':
                    processing_complete = True
                elif status_result['status'] == 'FAILED':
                    raise Exception(f"Processing failed for doc_{doc_id}")
            
            await asyncio.sleep(5)
        
        end_time = time.time()
        return {
            'doc_id': doc_id,
            'processing_time': end_time - start_time,
            'success': True
        }
    
    # Test with varying levels of concurrency
    concurrency_levels = [1, 5, 10, 20, 50]
    results = {}
    
    for concurrency in concurrency_levels:
        print(f"Testing with {concurrency} concurrent documents...")
        
        async with aiohttp.ClientSession() as session:
            tasks = [
                process_document(session, i) 
                for i in range(concurrency)
            ]
            
            start_time = time.time()
            doc_results = await asyncio.gather(*tasks, return_exceptions=True)
            end_time = time.time()
            
            successful_results = [r for r in doc_results if isinstance(r, dict) and r['success']]
            processing_times = [r['processing_time'] for r in successful_results]
            
            results[concurrency] = {
                'total_time': end_time - start_time,
                'successful_docs': len(successful_results),
                'failed_docs': concurrency - len(successful_results),
                'avg_processing_time': mean(processing_times) if processing_times else 0,
                'median_processing_time': median(processing_times) if processing_times else 0,
                'throughput': concurrency / (end_time - start_time) * 3600  # docs per hour
            }
    
    return results

# Run the test
if __name__ == "__main__":
    API_TOKEN = "your-api-token"
    results = asyncio.run(concurrent_processing_test())
    
    print("\nConcurrency Test Results:")
    for concurrency, metrics in results.items():
        print(f"Concurrency {concurrency}:")
        print(f"  Throughput: {metrics['throughput']:.1f} docs/hour")
        print(f"  Success Rate: {metrics['successful_docs']}/{metrics['successful_docs'] + metrics['failed_docs']}")
        print(f"  Avg Processing Time: {metrics['avg_processing_time']:.2f}s")
```

---

## Security Testing

### 9. Security Validation
```python
import requests
import jwt
import time

class SecurityTester:
    def __init__(self, api_base_url):
        self.api_base_url = api_base_url
        
    def test_authentication_security(self):
        """Test authentication and authorization security"""
        
        # Test 1: Unauthenticated access
        response = requests.get(f"{self.api_base_url}/documents")
        assert response.status_code == 401, "Should require authentication"
        
        # Test 2: Invalid token
        headers = {'Authorization': 'Bearer invalid_token'}
        response = requests.get(f"{self.api_base_url}/documents", headers=headers)
        assert response.status_code == 401, "Should reject invalid token"
        
        # Test 3: Expired token
        expired_token = self.generate_expired_token()
        headers = {'Authorization': f'Bearer {expired_token}'}
        response = requests.get(f"{self.api_base_url}/documents", headers=headers)
        assert response.status_code == 401, "Should reject expired token"
        
        print("✓ Authentication security tests passed")
    
    def test_input_validation(self):
        """Test input validation and sanitization"""
        
        # Test 1: File type validation
        malicious_files = [
            'malware.exe',
            'script.js',
            'payload.html'
        ]
        
        for file_name in malicious_files:
            with open(f'test_files/{file_name}', 'rb') as f:
                files = {'file': f}
                response = requests.post(f"{self.api_base_url}/documents", files=files)
                assert response.status_code == 400, f"Should reject {file_name}"
        
        # Test 2: File size validation
        # Create oversized file
        large_file_content = b'A' * (100 * 1024 * 1024)  # 100MB
        with open('large_file.pdf', 'wb') as f:
            f.write(large_file_content)
        
        with open('large_file.pdf', 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{self.api_base_url}/documents", files=files)
            assert response.status_code == 413, "Should reject oversized files"
        
        # Test 3: SQL injection attempts
        malicious_inputs = [
            "'; DROP TABLE documents; --",
            "' OR '1'='1",
            "<script>alert('xss')</script>"
        ]
        
        for malicious_input in malicious_inputs:
            data = {'document_type': malicious_input}
            response = requests.post(f"{self.api_base_url}/documents", data=data)
            # Should either reject or sanitize the input
            assert response.status_code in [400, 422], f"Should handle malicious input: {malicious_input}"
        
        print("✓ Input validation tests passed")
    
    def test_data_encryption(self):
        """Test data encryption and secure transmission"""
        
        # Test 1: HTTPS enforcement
        http_url = self.api_base_url.replace('https://', 'http://')
        try:
            response = requests.get(http_url, timeout=5)
            # Should either redirect to HTTPS or refuse connection
            assert response.status_code == 301 or response.status_code == 308, "Should redirect to HTTPS"
        except requests.exceptions.ConnectionError:
            # Connection refused is also acceptable
            pass
        
        # Test 2: Sensitive data in responses
        valid_token = self.get_valid_token()
        headers = {'Authorization': f'Bearer {valid_token}'}
        
        response = requests.get(f"{self.api_base_url}/documents", headers=headers)
        response_text = response.text.lower()
        
        # Check that sensitive information is not exposed
        sensitive_patterns = ['password', 'secret', 'private_key', 'aws_access_key']
        for pattern in sensitive_patterns:
            assert pattern not in response_text, f"Response should not contain {pattern}"
        
        print("✓ Data encryption tests passed")
    
    def generate_expired_token(self):
        """Generate an expired JWT token for testing"""
        payload = {
            'user_id': 'test_user',
            'exp': int(time.time()) - 3600  # Expired 1 hour ago
        }
        return jwt.encode(payload, 'secret', algorithm='HS256')
    
    def get_valid_token(self):
        """Get a valid authentication token"""
        auth_response = requests.post(f"{self.api_base_url}/auth", json={
            'api_key': 'test_api_key'
        })
        return auth_response.json()['token']

# Usage
if __name__ == "__main__":
    tester = SecurityTester("https://api.documentprocessing.company.com")
    
    tester.test_authentication_security()
    tester.test_input_validation()
    tester.test_data_encryption()
    
    print("All security tests passed!")
```

---

## User Acceptance Testing

### 10. Business Process Validation
```python
class BusinessProcessTester:
    """Test business-specific document processing workflows"""
    
    def test_invoice_processing_workflow(self):
        """Test complete invoice processing business workflow"""
        
        # Test invoice types
        invoice_types = [
            'standard_invoice.pdf',
            'credit_note.pdf',
            'purchase_order.pdf',
            'receipt.pdf'
        ]
        
        for invoice in invoice_types:
            print(f"Testing {invoice} processing...")
            
            # Process invoice
            results = self.process_document(invoice, 'invoice')
            
            # Validate required fields are extracted
            required_fields = [
                'invoice_number',
                'vendor_name',
                'total_amount',
                'invoice_date',
                'line_items'
            ]
            
            for field in required_fields:
                assert field in results['extracted_data'], f"Missing required field: {field}"
                assert results['confidence_scores'][field] > 80, f"Low confidence for {field}"
            
            # Validate business rules
            self.validate_invoice_business_rules(results['extracted_data'])
            
            print(f"✓ {invoice} processing validation passed")
    
    def validate_invoice_business_rules(self, extracted_data):
        """Validate business-specific rules for invoice data"""
        
        # Rule 1: Invoice amount should be positive
        total_amount = float(extracted_data['total_amount'].replace('$', '').replace(',', ''))
        assert total_amount > 0, "Invoice amount must be positive"
        
        # Rule 2: Invoice date should be within reasonable range
        from datetime import datetime, timedelta
        invoice_date = datetime.strptime(extracted_data['invoice_date'], '%Y-%m-%d')
        current_date = datetime.now()
        
        assert invoice_date <= current_date, "Invoice date cannot be in the future"
        assert invoice_date >= current_date - timedelta(days=365), "Invoice date too old"
        
        # Rule 3: Line items should sum to total (within tolerance)
        line_items_total = sum(float(item['amount'].replace('$', '').replace(',', '')) 
                              for item in extracted_data['line_items'])
        tolerance = 0.01  # $0.01 tolerance
        
        assert abs(line_items_total - total_amount) <= tolerance, "Line items don't sum to total"
        
        print("✓ Business rules validation passed")
```

---

## Test Automation and Reporting

### 11. Automated Test Suite
```python
import unittest
import json
from datetime import datetime

class DocumentProcessingTestSuite(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.api_base_url = "https://api.documentprocessing.company.com"
        cls.test_documents = [
            'test_invoice.pdf',
            'test_contract.pdf',
            'test_form.pdf'
        ]
    
    def test_ai_accuracy(self):
        """Test AI processing accuracy"""
        for doc in self.test_documents:
            with self.subTest(document=doc):
                results = self.process_document(doc)
                self.assertGreater(results['overall_confidence'], 95)
    
    def test_processing_speed(self):
        """Test processing speed requirements"""
        for doc in self.test_documents:
            with self.subTest(document=doc):
                start_time = time.time()
                results = self.process_document(doc)
                processing_time = time.time() - start_time
                self.assertLess(processing_time, 30)  # 30 second requirement
    
    def test_error_handling(self):
        """Test error handling for invalid inputs"""
        # Test with corrupted file
        with self.assertRaises(Exception):
            self.process_document('corrupted_file.pdf')
        
        # Test with unsupported format
        with self.assertRaises(Exception):
            self.process_document('document.txt')
    
    def generate_test_report(self, results):
        """Generate comprehensive test report"""
        report = {
            'test_date': datetime.now().isoformat(),
            'test_summary': {
                'total_tests': len(results),
                'passed_tests': len([t for t in results if t['status'] == 'PASS']),
                'failed_tests': len([t for t in results if t['status'] == 'FAIL']),
                'success_rate': 0
            },
            'detailed_results': results
        }
        
        if report['test_summary']['total_tests'] > 0:
            report['test_summary']['success_rate'] = (
                report['test_summary']['passed_tests'] / 
                report['test_summary']['total_tests']
            ) * 100
        
        # Save report
        with open(f"test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json", 'w') as f:
            json.dump(report, f, indent=2)
        
        return report

if __name__ == "__main__":
    unittest.main(verbosity=2)
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: AI Solutions Testing Team