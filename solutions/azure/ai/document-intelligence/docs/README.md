# Azure AI Document Intelligence - Documentation

This directory contains technical documentation for the Azure AI Document Intelligence solution.

## Documentation Structure

- **[Architecture](architecture.md)** - Solution architecture and AI service integration
- **[Prerequisites](prerequisites.md)** - System requirements and dependencies
- **[Troubleshooting](troubleshooting.md)** - Common issues and resolution steps

## Solution Overview

This solution leverages Azure AI Document Intelligence (formerly Form Recognizer) to extract text, key-value pairs, tables, and structures from documents, enabling automated document processing workflows.

## Key Components

- **Document Intelligence Service**: Pre-built and custom model capabilities
- **Storage Account**: Blob storage for document ingestion and processing
- **Logic Apps**: Workflow orchestration and business process automation
- **Cognitive Search**: Intelligent document search and indexing
- **Event Grid**: Event-driven processing triggers

## Architecture Highlights

- Serverless design with Azure Functions and Logic Apps
- Support for 100+ document types and languages
- Custom model training for specialized document types
- Real-time and batch processing capabilities
- Enterprise security with managed identities and Key Vault

## Supported Document Types

- **Pre-built Models**: Invoices, receipts, business cards, tax documents
- **Layout Model**: General document structure extraction
- **Custom Models**: Training for specialized document types
- **Read Model**: OCR for handwritten and printed text

## Getting Started

1. Review the [Prerequisites](prerequisites.md) for system requirements
2. Follow the implementation guide in the delivery folder
3. Use the provided automation scripts for deployment
4. Refer to [Troubleshooting](troubleshooting.md) for common issues

For implementation details, see the delivery documentation in the parent directory.