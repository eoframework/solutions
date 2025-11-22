# Azure Document Intelligence - Architecture Diagram

## Overview
This directory contains the architecture diagram for the Azure Document Intelligence solution using **official Azure Architecture Icons**.

## Files
- **`architecture-diagram.drawio`** - Editable diagram source (Draw.io format)
- **`architecture-diagram.png`** - Published diagram image (300 DPI)
- **`DIAGRAM_REQUIREMENTS.md`** - Detailed component specifications
- **`README.md`** - This file

## Quick Start: Editing the Diagram

### Prerequisites
- Download Draw.io Desktop: https://github.com/jgraph/drawio-desktop/releases
- Or use online: https://app.diagrams.net

### Steps

#### 1. Open the Diagram
```bash
# Open in Draw.io Desktop
drawio architecture-diagram.drawio

# Or double-click the file if Draw.io is installed
```

#### 2. Enable Azure Icons
1. In Draw.io, click **"More Shapes..."** in the left sidebar
2. Scroll to find **"Azure"** section
3. Check **"Azure (2023)"** or latest Azure icons
4. Click **"Apply"**

Alternatively:
- Download Azure icons: https://learn.microsoft.com/en-us/azure/architecture/icons/
- Import into Draw.io: File > Open Library > Select downloaded SVG files

#### 3. Edit the Diagram
The diagram contains placeholder shapes. Replace with official Azure icons:

**For Each Azure Service:**
1. Find the Azure service icon in the left sidebar (e.g., "Azure Functions", "Blob Storage")
2. Drag the icon onto the canvas
3. Position it to replace the placeholder shape
4. Delete the old placeholder
5. Add service name label below

**Key Azure Services to Replace:**
- 📦 **Azure Blob Storage** → Use "Storage Accounts" icon (green)
- ⚡ **Azure Functions** → Use "Function Apps" icon (blue)
- 🤖 **Document Intelligence** → Use "Form Recognizer" icon (purple)
- 🗄️ **Azure Cosmos DB** → Use "Cosmos DB" icon (orange)
- 🔌 **API Management** → Use "API Management services" icon (red)
- 📨 **Service Bus** → Use "Service Bus" icon (red)
- 🔑 **Key Vault** → Use "Key Vaults" icon (red)

#### 4. Update Connections
1. Use **Connector** tool (press 'C')
2. Draw arrows between services to show data flow
3. Label each arrow (e.g., "Document uploaded", "Extract text")
4. Use different line styles:
   - **Solid**: Synchronous calls
   - **Dashed**: Asynchronous/events
   - **Bold**: Primary flow

#### 5. Export to PNG
1. Select all (Ctrl+A / Cmd+A)
2. **File > Export as > PNG**
3. Settings:
   - Resolution: **300 DPI**
   - Border width: **10px**
   - Transparent background: Optional
4. Save as: `architecture-diagram.png`

#### 6. Regenerate Documents
After updating the diagram, regenerate Office documents:
```bash
cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts
python3 solution-presales-converter.py \
  --path /mnt/c/projects/wsl/solutions/solutions/azure/ai/document-intelligence \
  --force
```

## Azure Architecture Best Practices

### Layout Recommendations
- **Left to Right**: Show data flow from ingestion → processing → storage
- **Layered**: Group related services in visual layers
- **Clear Labels**: Include service names and brief descriptions

### Color Coding (Azure Standard)
- 🔵 **Blue**: Compute (Functions, Logic Apps)
- 🟢 **Green**: Storage (Blob Storage)
- 🟠 **Orange**: Database (Cosmos DB)
- 🟣 **Purple**: AI/ML (Document Intelligence, Text Analytics)
- 🔴 **Red**: Integration (API Management, Service Bus)
- ⚫ **Gray**: Infrastructure (Monitor, Key Vault)

### Data Flow Types
- **Solid arrow** →  Synchronous API call
- **Dashed arrow** ⤍  Asynchronous message
- **Dotted arrow** ⋯→ Event trigger
- **Bold arrow** ➜  Primary data path

## Key Components

### Document Ingestion
1. **Blob Storage (Input)** - Documents uploaded via API or direct upload
2. **Event trigger** - Blob creation triggers Azure Function

### Processing
3. **Azure Functions** - Orchestrates the document processing workflow
4. **Document Intelligence** - Extracts text, forms, and tables from documents
5. **Text Analytics** - Performs entity recognition and NLP analysis

### Data Storage
6. **Cosmos DB** - Stores metadata and extraction results (fast queries)
7. **Blob Storage (Output)** - Archives processed documents and JSON results

### API Access
8. **API Management** - Exposes REST APIs for document submission and results
9. **Service Bus** - Handles asynchronous processing queues

### Operations
10. **Monitor** - Logging, metrics, and alerting
11. **Key Vault** - Manages secrets and API keys securely

## Processing Flow

```
1. User uploads document → Blob Storage (Input Container)
2. Blob event triggers → Azure Function
3. Function calls → Document Intelligence API
4. Document Intelligence extracts → Text, forms, tables
5. Function calls → Text Analytics (optional NLP)
6. Results stored → Cosmos DB (metadata) + Blob Storage (JSON)
7. API Management exposes → Results via REST API
8. Event Grid publishes → Completion notification
```

## Detailed Requirements
See `DIAGRAM_REQUIREMENTS.md` for:
- Complete component list
- Azure service specifications
- Icon reference table
- Advanced layout guidelines

## Troubleshooting

### Can't find Azure icons in Draw.io
- Click "More Shapes..." → Search for "Azure"
- Check "Azure (2023)" → Apply
- Restart Draw.io if icons don't appear

### Export quality is poor
- Use **300 DPI** setting in PNG export
- Export as PNG (not JPEG)
- Ensure canvas size is adequate (1920x1080 minimum)

### Diagram doesn't update in documents
```bash
# Force regenerate all documents
python3 solution-presales-converter.py --path /path/to/solution --force
```

## References
- **Azure Architecture Icons**: https://learn.microsoft.com/en-us/azure/architecture/icons/
- **Azure Architecture Center**: https://learn.microsoft.com/en-us/azure/architecture/
- **Draw.io Documentation**: https://www.diagrams.net/doc/
- **Document Intelligence Docs**: https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/
