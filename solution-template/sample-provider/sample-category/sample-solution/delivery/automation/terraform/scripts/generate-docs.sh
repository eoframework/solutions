#!/bin/bash

# Generate Terraform Documentation
# This script generates documentation for all Terraform modules using terraform-docs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $BLUE "📚 Generating Terraform Documentation"

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    print_message $RED "❌ terraform-docs is not installed."
    print_message $YELLOW "Install it with:"
    echo "  # macOS"
    echo "  brew install terraform-docs"
    echo ""
    echo "  # Linux/Windows"
    echo "  curl -sSL https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz | tar -xz terraform-docs"
    echo "  sudo mv terraform-docs /usr/local/bin/"
    exit 1
fi

print_message $GREEN "✅ terraform-docs found"

# Navigate to terraform root directory
cd "$(dirname "$0")/.."

# Generate documentation for root module
print_message $BLUE "📖 Generating root module documentation..."
terraform-docs markdown table . > TERRAFORM_DOCS.md
print_message $GREEN "✅ Root documentation generated: TERRAFORM_DOCS.md"

# Generate documentation for each module
print_message $BLUE "📖 Generating module documentation..."

# AWS Module
if [ -d "modules/aws" ]; then
    terraform-docs markdown table modules/aws/ > modules/aws/README.md
    print_message $GREEN "✅ AWS module documentation generated"
fi

# Azure Module
if [ -d "modules/azure" ]; then
    terraform-docs markdown table modules/azure/ > modules/azure/README.md
    print_message $GREEN "✅ Azure module documentation generated"
fi

# GCP Module
if [ -d "modules/gcp" ]; then
    terraform-docs markdown table modules/gcp/ > modules/gcp/README.md
    print_message $GREEN "✅ GCP module documentation generated"
fi

# Common Modules
for common_module in modules/common/*/; do
    if [ -d "$common_module" ]; then
        module_name=$(basename "$common_module")
        terraform-docs markdown table "$common_module" > "${common_module}README.md"
        print_message $GREEN "✅ Common module documentation generated: $module_name"
    fi
done

# Generate environment-specific documentation
print_message $BLUE "📖 Generating environment documentation..."

for env in environments/*/; do
    if [ -d "$env" ]; then
        env_name=$(basename "$env")
        terraform-docs markdown table "$env" > "${env}README.md"
        print_message $GREEN "✅ Environment documentation generated: $env_name"
    fi
done

# Generate a summary document
print_message $BLUE "📋 Generating documentation summary..."

cat > docs/DOCUMENTATION_INDEX.md << EOF
# Terraform Documentation Index

This document provides an index of all generated Terraform documentation.

## Root Module
- [Main Documentation](../TERRAFORM_DOCS.md) - Complete root module documentation
- [Usage Guide](../README.md) - Comprehensive usage and setup guide

## Provider Modules

### AWS Module
- [AWS Module Documentation](../modules/aws/README.md)

### Azure Module
- [Azure Module Documentation](../modules/azure/README.md)

### Google Cloud Module
- [GCP Module Documentation](../modules/gcp/README.md)

## Common Modules

EOF

# Add common modules to index
for common_module in modules/common/*/; do
    if [ -d "$common_module" ]; then
        module_name=$(basename "$common_module")
        echo "- [${module_name^} Module](../modules/common/$module_name/README.md)" >> docs/DOCUMENTATION_INDEX.md
    fi
done

cat >> docs/DOCUMENTATION_INDEX.md << EOF

## Environment Documentation

EOF

# Add environments to index
for env in environments/*/; do
    if [ -d "$env" ]; then
        env_name=$(basename "$env")
        echo "- [${env_name^} Environment](../environments/$env_name/README.md)" >> docs/DOCUMENTATION_INDEX.md
    fi
done

cat >> docs/DOCUMENTATION_INDEX.md << EOF

## Configuration Examples

Configuration examples can be found in each environment's \`config/\` directory:

EOF

# Add config examples to index
for env in environments/*/; do
    if [ -d "$env/config" ]; then
        env_name=$(basename "$env")
        echo "- [${env_name^} Configuration Examples](../environments/$env_name/config/)" >> docs/DOCUMENTATION_INDEX.md
    fi
done

cat >> docs/DOCUMENTATION_INDEX.md << EOF

## Quick Links

- [Setup Scripts](../scripts/) - Backend initialization and utility scripts
- [Terraform Configuration](..) - Root Terraform configuration files
- [Module Source Code](../modules/) - All module source code

## Documentation Generation

This documentation is generated automatically using [terraform-docs](https://terraform-docs.io/).

To regenerate documentation:

\`\`\`bash
cd scripts/
./generate-docs.sh
\`\`\`

Last generated: $(date)
EOF

print_message $GREEN "✅ Documentation index generated"

# Create a simple script to validate all Terraform code
cat > validate-terraform.sh << 'EOF'
#!/bin/bash

# Validate all Terraform configurations
set -e

echo "🔍 Validating Terraform configurations..."

# Validate root module
echo "Validating root module..."
terraform validate

# Validate each environment
for env in environments/*/; do
    if [ -d "$env" ]; then
        env_name=$(basename "$env")
        echo "Validating $env_name environment..."
        (cd "$env" && terraform validate)
    fi
done

echo "✅ All Terraform configurations are valid"
EOF

chmod +x validate-terraform.sh

echo
print_message $GREEN "🎉 Documentation Generation Complete!"
print_message $BLUE "Generated files:"
echo "📖 Root documentation: TERRAFORM_DOCS.md"
echo "📚 Documentation index: docs/DOCUMENTATION_INDEX.md"
echo "🔍 Validation script: validate-terraform.sh"
echo "📁 Module documentation in each module directory"
echo
print_message $YELLOW "Next steps:"
echo "1. Review generated documentation"
echo "2. Run ./validate-terraform.sh to validate configurations"
echo "3. Commit documentation to version control"