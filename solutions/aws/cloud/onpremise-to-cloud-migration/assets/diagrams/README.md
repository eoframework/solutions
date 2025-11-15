# Architecture Diagram Generation

This directory contains **two approaches** for creating the AWS IDP architecture diagram:

## 🚀 **Recommended: Automated Generation (Python + Official AWS Icons)**

### Overview
Use the `generate_diagram.py` script to instantly create a professional diagram with **official AWS architecture icons**. This is the fastest and most professional approach.

### Prerequisites
```bash
# Install Python library
pip3 install diagrams

# Install Graphviz (required)
sudo apt-get install graphviz  # Ubuntu/Debian
# OR
brew install graphviz           # macOS
# OR
choco install graphviz          # Windows
```

### Usage
```bash
# Generate the diagram
python3 generate_diagram.py

# Output: ../images/architecture-diagram.png
# ✅ Professional diagram with official AWS icons created instantly!
```

### Features
- ✅ **Official AWS icons** from AWS Architecture Icon set
- ✅ **Instant generation** - no manual work needed
- ✅ **Version controlled** - diagram defined as code
- ✅ **Consistent styling** - professional layouts every time
- ✅ **Easy updates** - change Python code and regenerate

### Example Output
The script creates a diagram showing:
- Document Ingestion (S3 Input Bucket)
- Processing Orchestration (Lambda, Step Functions)
- AI/ML Processing (Textract, Comprehend)
- Data Layer (DynamoDB, S3 Output)
- API Integration (API Gateway, SQS, SNS)
- Infrastructure (CloudWatch, Secrets Manager)
- All connections and data flows with labeled arrows

### Regenerate Documents
After generating the diagram:
```bash
cd /path/to/eof-tools
python3 doc-tools/solution-doc-builder.py \
  --path solutions/aws/ai/intelligent-document-processing \
  --force
```

---

## ✏️ **Alternative: Manual Editing (Draw.io)**

### Overview
If you need to manually customize the diagram, use the `architecture-diagram.drawio` file in Draw.io Desktop.

### Prerequisites
- Download Draw.io Desktop: https://github.com/jgraph/drawio-desktop/releases

### Usage
```bash
# Open in Draw.io
drawio architecture-diagram.drawio

# OR double-click the file if Draw.io is installed
```

### Steps
1. **Enable AWS Icons:**
   - Click "More Shapes..." in left sidebar
   - Scroll to "Networking" section
   - Check "AWS 19" (latest AWS architecture icons)
   - Click "Apply"

2. **Build Your Diagram:**
   - Drag AWS service icons from the sidebar
   - Position them on the canvas
   - Use the Connector tool (press 'C') to draw arrows
   - Add labels and descriptions

3. **Export to PNG:**
   - Select all (Ctrl+A / Cmd+A)
   - File > Export as > PNG
   - Settings: 300 DPI, 10px border
   - Save to: `../images/architecture-diagram.png`

4. **Regenerate Documents:**
   ```bash
   cd /path/to/eof-tools
   python3 doc-tools/solution-doc-builder.py \
     --path solutions/aws/ai/intelligent-document-processing \
     --force
   ```

### Detailed Instructions
See `DIAGRAM_REQUIREMENTS.md` for:
- Complete list of required AWS components
- Layout recommendations
- AWS icon reference table
- Step-by-step Draw.io instructions

---

## 📊 **Comparison**

| Feature | Python Script | Draw.io Manual |
|---------|--------------|----------------|
| **Speed** | ⚡ Instant | 🐢 30-60 minutes |
| **AWS Icons** | ✅ Official icons | ✅ Official icons |
| **Quality** | 🏆 Professional | 🎨 Custom styling |
| **Editability** | Python code | Visual editor |
| **Version Control** | ✅ Code-based | ⚠️ Binary file |
| **Consistency** | ✅ Always consistent | ⚠️ Manual variations |
| **Learning Curve** | Python knowledge | Draw.io skills |

---

## 🎯 **Recommended Workflow**

### For New Diagrams:
1. **Start with Python script** - Get a professional baseline instantly
2. **Review the output** - Check if it meets your needs
3. **If customization needed** - Open in Draw.io and refine

### For Updates:
1. **Small changes:** Edit Python script and regenerate (fastest)
2. **Major redesign:** Edit in Draw.io manually (most flexible)

### For Production:
- Use **Python script** for consistency across all solutions
- Keep **Draw.io file** for one-off customizations

---

## 📁 **Files in This Directory**

- **`generate_diagram.py`** - Python script for automated generation (RECOMMENDED)
- **`architecture-diagram.drawio`** - Draw.io template for manual editing
- **`DIAGRAM_REQUIREMENTS.md`** - Detailed component specifications
- **`README.md`** - This file

---

## 🆘 **Troubleshooting**

### Python Script Issues

**Error: "dot: command not found"**
```bash
# Graphviz not installed
sudo apt-get install graphviz
```

**Error: "ModuleNotFoundError: No module named 'diagrams'"**
```bash
# Diagrams library not installed
pip3 install diagrams
```

### Draw.io Issues

**Can't find AWS icons:**
- Click "More Shapes..." → Check "AWS 19" → Apply
- Restart Draw.io if icons don't appear

**Export quality is poor:**
- Use 300 DPI setting in export
- Export PNG, not JPEG

---

## 📚 **References**

- **Diagrams Library:** https://diagrams.mingrammer.com/
- **AWS Architecture Icons:** https://aws.amazon.com/architecture/icons/
- **Draw.io Documentation:** https://www.diagrams.net/doc/
- **AWS Well-Architected:** https://aws.amazon.com/architecture/well-architected/
