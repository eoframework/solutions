# EO Framework™ Templates Catalog System

This directory contains the distributed catalog system for the EO Framework™ Templates repository. The catalog provides a scalable, maintainable approach to indexing and discovering enterprise solutions across multiple providers and categories.

## Architecture Overview

```
catalog/
├── catalog.yml              # 📋 Master catalog index with statistics and references
├── solutions/               # 🏢 Provider-specific solution catalogs (11 files)
│   ├── aws.yml              #    Amazon Web Services solutions catalog
│   ├── azure.yml            #    Microsoft Azure solutions catalog  
│   ├── cisco.yml            #    Cisco Systems solutions catalog
│   ├── dell.yml             #    Dell Technologies solutions catalog
│   ├── github.yml           #    GitHub solutions catalog
│   ├── google.yml           #    Google Cloud solutions catalog
│   ├── hashicorp.yml        #    HashiCorp solutions catalog
│   ├── ibm.yml              #    IBM solutions catalog
│   ├── juniper.yml          #    Juniper Networks solutions catalog
│   ├── microsoft.yml        #    Microsoft 365 solutions catalog
│   └── nvidia.yml           #    NVIDIA solutions catalog
├── categories/              # 📂 Category-based solution indexes (6 files)
│   ├── ai.yml               #    Artificial Intelligence solutions across all providers
│   ├── cloud.yml            #    Cloud infrastructure solutions across all providers
│   ├── cyber-security.yml   #    Security and compliance solutions across all providers
│   ├── devops.yml           #    DevOps automation solutions across all providers
│   ├── modern-workspace.yml #    Digital workplace solutions across all providers
│   └── network.yml          #    Network infrastructure solutions across all providers
├── schemas/                 # 🔍 JSON validation schemas for catalog consistency
│   ├── master-catalog.schema.json    # Schema for master catalog validation
│   └── provider-catalog.schema.json  # Schema for provider catalog validation
├── tools/                   # 🛠️ Catalog management and discovery utilities
│   ├── aggregator.py        #    Combines distributed catalogs for unified search
│   ├── validator.py         #    Validates all catalogs against JSON schemas
│   └── generator.py         #    Auto-generates catalogs from solution metadata
├── solutions.json           # 📊 API-friendly JSON export for external integrations
└── validation-report.json   # ✅ Latest validation results and schema compliance status
```

## Key Benefits

- **🎯 Scalability**: Handles 1000+ solutions efficiently
- **🔄 Team Autonomy**: Provider teams manage their own catalogs
- **⚡ Performance**: Load only needed data
- **🛠️ Maintainability**: Smaller, focused files
- **🔍 Discoverability**: Master catalog provides unified search entry point
- **✅ Validation**: JSON schema validation ensures consistency

## Usage

### Searching Solutions

```python
from catalog.tools.aggregator import CatalogAggregator

aggregator = CatalogAggregator("/path/to/catalog")
aggregator.load_master_catalog()
aggregator.load_provider_catalogs()

# Search by provider
aws_solutions = aggregator.search_solutions(provider="aws")

# Search by category
ai_solutions = aggregator.search_solutions(category="ai")

# Search by tags
security_solutions = aggregator.search_solutions(tags=["security", "compliance"])

# Text search
vpn_solutions = aggregator.search_solutions(query="vpn")

# Complex search
enterprise_aws_solutions = aggregator.search_solutions(
    provider="aws",
    complexity="enterprise",
    tags=["cloud"]
)
```

### Validating Catalogs

```bash
# Validate all catalogs
python3 catalog/tools/validator.py

# Check validation report
cat catalog/validation-report.json
```

### Generating Catalogs from Metadata

```bash
# Auto-generate catalogs from solution metadata.yml files
python3 catalog/tools/generator.py
```

### Aggregating for API Consumption

```bash
# Generate API exports
python3 catalog/tools/aggregator.py

# Outputs:
# - catalog/solutions.json (API format)
```

## Catalog File Formats

### Master Catalog (`catalog.yml`)

```yaml
version: '2.0'
catalog_type: 'master'
generated_at: '2025-08-25T12:00:00Z'

metadata:
  total_providers: 12
  total_categories: 6
  total_solutions: 44

provider_catalogs:
  aws: './solutions/aws.yml'
  azure: './solutions/azure.yml'
  
category_catalogs:
  ai: './categories/ai.yml'
  cloud: './categories/cloud.yml'

quick_stats:
  providers_list: [aws, azure, cisco, ...]
  categories_list: [ai, cloud, cyber-security, ...]
  provider_solution_counts: {aws: 15, azure: 12, ...}
```

### Provider Catalog (`solutions/aws.yml`)

```yaml
version: '2.0'
provider: 'aws'
catalog_type: 'provider'
generated_at: '2025-08-25T12:00:00Z'

metadata:
  provider_name: "Amazon Web Services"
  total_solutions: 15

categories:
  ai:
    solutions:
      intelligent-document-processing:
        title: "AWS Intelligent Document Processing"
        description: "AI-powered document analysis"
        version: "1.0"
        complexity: "enterprise"
        deployment_time: "4-6 weeks"
        tags: ["ai", "document-processing"]
        solution_path: "../../solutions/aws/ai/intelligent-document-processing/"
```

### Category Catalog (`categories/ai.yml`)

```yaml
version: '2.0'
category: 'ai'
catalog_type: 'category'
generated_at: '2025-08-25T12:00:00Z'

metadata:
  category_name: "Artificial Intelligence"
  description: "AI and Machine Learning solutions"
  total_solutions: 8

providers:
  aws:
    solutions:
      - name: "intelligent-document-processing"
        title: "AWS Intelligent Document Processing"
        provider_catalog: "../solutions/aws.yml"
        solution_path: "../../solutions/aws/ai/intelligent-document-processing/"
  
  nvidia:
    solutions:
      - name: "dgx-superpod"
        title: "NVIDIA DGX SuperPOD AI Infrastructure"
        provider_catalog: "../solutions/nvidia.yml"
        solution_path: "../../solutions/nvidia/ai/dgx-superpod/"
```

## Management Workflows

### Adding a New Solution

1. **Create Solution Structure**:
   ```bash
   mkdir -p solutions/{provider}/{category}/{solution-name}/{presales,delivery,docs}
   ```

2. **Create metadata.yml**:
   ```yaml
   title: "Solution Title"
   description: "Solution description"
   version: "1.0"
   complexity: "intermediate"
   deployment_time: "2-4 weeks"
   tags: ["tag1", "tag2"]
   ```

3. **Regenerate Catalogs**:
   ```bash
   python3 catalog/tools/generator.py
   ```

4. **Validate**:
   ```bash
   python3 catalog/tools/validator.py
   ```

### Adding a New Provider

1. **Create Provider Directory Structure**:
   ```bash
   mkdir -p solutions/{new-provider}/{ai,cloud,cyber-security,devops,modern-workspace,network}
   ```

2. **Update Master Catalog** (or regenerate):
   ```bash
   python3 catalog/tools/generator.py
   ```

3. **Validate New Structure**:
   ```bash
   python3 catalog/tools/validator.py
   ```

### CI/CD Integration

```yaml
# .github/workflows/catalog-validation.yml
name: Catalog Validation
on: [push, pull_request]

jobs:
  validate-catalogs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install pyyaml jsonschema
      - name: Validate catalogs
        run: python3 catalog/tools/validator.py
      - name: Generate API exports
        run: python3 catalog/tools/aggregator.py
```

## Statistics (Current)

- **Total Solutions**: 34
- **Providers**: 11 (AWS, Azure, Cisco, Dell, GitHub, Google, HashiCorp, IBM, Juniper, Microsoft, NVIDIA)
- **Categories**: 6 (AI, Cloud, Cyber Security, DevOps, Modern Workspace, Network)
- **Catalog Files**: 18 (1 master + 11 provider + 6 category)
- **Validation Success Rate**: 66.7% (12/18 passing schema validation)

## Future Enhancements

- **Search API**: REST API for catalog search
- **Web Interface**: Browse solutions via web UI
- **Analytics Dashboard**: Usage metrics and trends
- **Auto-discovery**: Automatic solution detection
- **Dependency Mapping**: Solution interdependencies
- **Version Management**: Solution version tracking

