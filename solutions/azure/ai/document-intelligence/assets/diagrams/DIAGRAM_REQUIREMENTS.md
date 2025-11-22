# Azure Document Intelligence - Architecture Diagram Requirements

## Overview
This document specifies the components and layout for the Azure Document Intelligence solution architecture diagram.

## Required Components

### 1. Document Ingestion Layer
- **Azure Blob Storage (Input Container)**
  - Raw document storage
  - Supported formats: PDF, JPEG, PNG, TIFF
  - Event triggers for processing workflow
  - Hot tier for active documents

### 2. Document Processing Layer
- **Azure Functions (Orchestration)**
  - Document workflow orchestration
  - Event-driven processing (Blob triggers)
  - Error handling and retries
  - Premium plan for VNet integration

- **Azure Document Intelligence (Form Recognizer)**
  - Layout API for OCR and structure extraction
  - Prebuilt models for invoices, receipts, ID documents
  - Custom models for specialized documents
  - Form and table extraction

- **Azure Text Analytics / Language Service**
  - Entity recognition (people, organizations, locations)
  - Key phrase extraction
  - Language detection

### 3. Data Layer
- **Azure Cosmos DB**
  - Document metadata storage
  - Job tracking and status
  - Extraction results index
  - Serverless or provisioned throughput

- **Azure Blob Storage (Output Container)**
  - Processed document archive
  - Extracted data (JSON/CSV)
  - Cool tier for archival

### 4. API & Integration Layer
- **Azure API Management**
  - RESTful API endpoints
  - Document submission endpoint
  - Results retrieval endpoint
  - Authentication and rate limiting

- **Azure Service Bus**
  - Asynchronous processing queue
  - Dead-letter queue for failed items

- **Azure Event Grid**
  - Event-driven architecture
  - Document processing events

### 5. Monitoring & Operations
- **Azure Monitor + Log Analytics**
  - Centralized logging
  - Custom metrics and dashboards

- **Azure Key Vault**
  - API keys and secrets
  - Certificate management

## Azure Icon Quick Reference

| Component | Azure Service | Color |
|-----------|--------------|-------|
| Blob Storage | Storage Accounts | Green |
| Functions | Function Apps | Blue |
| Document Intelligence | Form Recognizer | Purple |
| Cosmos DB | Cosmos DB | Orange |
| API Management | API Management | Red |
| Service Bus | Service Bus | Red |
| Key Vault | Key Vaults | Red |

## References
- **Azure Architecture Icons**: https://learn.microsoft.com/en-us/azure/architecture/icons/
- **Document Intelligence**: https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/
