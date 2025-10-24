#!/bin/bash
#
# EO Framework™ Solution Download Helper
# Simple script to download solutions without full Git workflow knowledge
#
# Usage:
#   ./download-solution.sh PROVIDER/CATEGORY/SOLUTION [VERSION]
#
# Examples:
#   ./download-solution.sh aws/ai/intelligent-document-processing
#   ./download-solution.sh aws/ai/intelligent-document-processing v1.1.0
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/eoframework/public-assets.git"
TEMP_DIR="/tmp/eof-download-$$"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
EO Framework™ Solution Download Helper

Usage:
    $0 <solution-path> [version]

Arguments:
    solution-path   Path to solution (e.g., aws/ai/intelligent-document-processing)
    version         Optional version tag (e.g., v1.1.0). Default: latest

Examples:
    # Download latest version
    $0 aws/ai/intelligent-document-processing

    # Download specific version
    $0 aws/ai/intelligent-document-processing v1.1.0

    # List available solutions
    $0 --list

Options:
    --help, -h      Show this help message
    --list, -l      List all available solutions

EOF
}

# Function to list available solutions
list_solutions() {
    print_info "Fetching solution catalog..."

    CATALOG_URL="https://raw.githubusercontent.com/eoframework/public-assets/main/catalog/solutions.csv"

    if command -v curl &> /dev/null; then
        curl -s "$CATALOG_URL" | column -t -s ','
    elif command -v wget &> /dev/null; then
        wget -q -O - "$CATALOG_URL" | column -t -s ','
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Function to clean up temp directory
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Parse arguments
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_usage
    exit 0
fi

if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
    list_solutions
    exit 0
fi

SOLUTION_PATH="$1"
VERSION="${2:-latest}"

# Validate solution path format
if [[ ! "$SOLUTION_PATH" =~ ^[a-z0-9-]+/[a-z0-9-]+/[a-z0-9-]+$ ]]; then
    print_error "Invalid solution path format"
    echo "Expected format: provider/category/solution"
    echo "Example: aws/ai/intelligent-document-processing"
    exit 1
fi

# Extract components
PROVIDER=$(echo "$SOLUTION_PATH" | cut -d'/' -f1)
CATEGORY=$(echo "$SOLUTION_PATH" | cut -d'/' -f2)
SOLUTION_NAME=$(echo "$SOLUTION_PATH" | cut -d'/' -f3)

print_info "Downloading EO Framework™ Solution"
echo "  Provider: $PROVIDER"
echo "  Category: $CATEGORY"
echo "  Solution: $SOLUTION_NAME"
echo "  Version:  $VERSION"
echo ""

# Check for git
if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    echo "Please install Git:"
    echo "  Ubuntu/Debian: sudo apt-get install git"
    echo "  macOS:         brew install git"
    echo "  Windows:       Download from https://git-scm.com/"
    exit 1
fi

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

print_info "Cloning repository (this may take a moment)..."

# Clone with sparse checkout
if ! git clone --filter=blob:none --sparse --quiet "$REPO_URL" repo 2>/dev/null; then
    print_error "Failed to clone repository"
    echo "Please check your internet connection and try again"
    exit 1
fi

cd repo

# Checkout specific version if not latest
if [ "$VERSION" != "latest" ]; then
    print_info "Checking out version $VERSION..."

    # Build tag name
    TAG_NAME="$PROVIDER/$CATEGORY/$SOLUTION_NAME-$VERSION"

    if ! git checkout "tags/$TAG_NAME" --quiet 2>/dev/null; then
        print_error "Version $VERSION not found"
        echo ""
        print_info "Available versions for this solution:"
        git tag | grep "^$PROVIDER/$CATEGORY/$SOLUTION_NAME" || echo "No tags found"
        exit 1
    fi
fi

# Sparse checkout the specific solution
print_info "Downloading solution files..."
git sparse-checkout set "solutions/$SOLUTION_PATH" --quiet

# Check if solution exists
SOLUTION_DIR="solutions/$SOLUTION_PATH"
if [ ! -d "$SOLUTION_DIR" ]; then
    print_error "Solution not found: $SOLUTION_PATH"
    echo ""
    print_info "Available solutions can be listed with:"
    echo "  $0 --list"
    exit 1
fi

# Read version from metadata if available
ACTUAL_VERSION="unknown"
if [ -f "$SOLUTION_DIR/metadata.yml" ]; then
    if command -v python3 &> /dev/null; then
        ACTUAL_VERSION=$(python3 -c "import yaml; print(yaml.safe_load(open('$SOLUTION_DIR/metadata.yml'))['version'])" 2>/dev/null || echo "unknown")
    fi
fi

# Copy to user's current directory
TARGET_DIR="$OLDPWD/$SOLUTION_NAME"

if [ -d "$TARGET_DIR" ]; then
    print_warning "Directory $SOLUTION_NAME already exists"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Download cancelled"
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

print_info "Copying files to $SOLUTION_NAME/..."
cp -r "$SOLUTION_DIR" "$TARGET_DIR"

# Show summary
echo ""
print_success "Download complete!"
echo ""
echo "Solution downloaded to: $SOLUTION_NAME/"
echo "Version: $ACTUAL_VERSION"
echo ""
print_info "Next steps:"
echo "  cd $SOLUTION_NAME"
echo "  cat README.md           # Read solution overview"
echo "  cat CHANGELOG.md        # View version history"
echo "  ls presales/            # Browse presales materials"
echo "  ls delivery/            # Browse delivery materials"
echo ""
print_info "For full Git integration:"
echo "  git clone --sparse $REPO_URL"
echo "  cd public-assets"
echo "  git sparse-checkout set solutions/$SOLUTION_PATH"
echo ""
print_info "Documentation: https://docs.eoframework.com"
print_info "Support: support@eoframework.com"
