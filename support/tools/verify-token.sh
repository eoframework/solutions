#!/bin/bash
#
# Verify PUBLIC_ASSETS_TOKEN has correct permissions
#
# Usage: PUBLIC_ASSETS_TOKEN=ghp_xxx ./verify-token.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo "========================================="
echo "PUBLIC_ASSETS_TOKEN Verification"
echo "========================================="
echo ""

# Check if token is provided
if [ -z "$PUBLIC_ASSETS_TOKEN" ]; then
    print_error "PUBLIC_ASSETS_TOKEN environment variable not set"
    echo ""
    echo "Usage:"
    echo "  export PUBLIC_ASSETS_TOKEN=ghp_xxxxxxxxxxxx"
    echo "  ./verify-token.sh"
    echo ""
    echo "Or:"
    echo "  PUBLIC_ASSETS_TOKEN=ghp_xxxxxxxxxxxx ./verify-token.sh"
    exit 1
fi

print_info "Token provided (length: ${#PUBLIC_ASSETS_TOKEN} characters)"

# Check token format
if [[ ! "$PUBLIC_ASSETS_TOKEN" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
    print_warning "Token format looks unusual (expected ghp_xxx format)"
fi

echo ""
print_info "Testing GitHub API access..."

# Test 1: Check authentication
print_info "Test 1: Verifying token authentication..."
USER_RESPONSE=$(curl -s -H "Authorization: Bearer $PUBLIC_ASSETS_TOKEN" \
    https://api.github.com/user)

if echo "$USER_RESPONSE" | grep -q "login"; then
    USERNAME=$(echo "$USER_RESPONSE" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
    print_success "Token authenticated as: $USERNAME"
else
    print_error "Token authentication failed"
    echo "Response: $USER_RESPONSE"
    exit 1
fi

echo ""

# Test 2: Check public-assets repository access
print_info "Test 2: Checking access to eoframework/public-assets..."
REPO_RESPONSE=$(curl -s -H "Authorization: Bearer $PUBLIC_ASSETS_TOKEN" \
    https://api.github.com/repos/eoframework/public-assets)

if echo "$REPO_RESPONSE" | grep -q "full_name"; then
    print_success "Repository access confirmed"

    # Check permissions
    PERMISSIONS=$(echo "$REPO_RESPONSE" | grep -A5 '"permissions"')
    if echo "$PERMISSIONS" | grep -q '"push": true'; then
        print_success "Push permission: Enabled ✓"
    else
        print_error "Push permission: Disabled ✗"
        echo "The token needs write/push access to eoframework/public-assets"
        exit 1
    fi
else
    print_error "Cannot access eoframework/public-assets repository"
    echo "Response: $REPO_RESPONSE"
    echo ""
    echo "Possible issues:"
    echo "  1. Repository doesn't exist"
    echo "  2. Token doesn't have access to the repository"
    echo "  3. Token doesn't have 'repo' scope"
    exit 1
fi

echo ""

# Test 3: Test write access by getting default branch
print_info "Test 3: Checking repository write capabilities..."
BRANCH_RESPONSE=$(curl -s -H "Authorization: Bearer $PUBLIC_ASSETS_TOKEN" \
    https://api.github.com/repos/eoframework/public-assets/branches/main)

if echo "$BRANCH_RESPONSE" | grep -q "commit"; then
    print_success "Branch access confirmed (main branch)"
else
    print_warning "Could not access main branch (may not exist yet)"
fi

echo ""

# Test 4: Check workflow scope
print_info "Test 4: Verifying token scopes..."
SCOPES=$(curl -s -I -H "Authorization: Bearer $PUBLIC_ASSETS_TOKEN" \
    https://api.github.com/user | grep -i "x-oauth-scopes" | cut -d':' -f2- | tr -d ' \r')

echo "Token scopes: $SCOPES"

if echo "$SCOPES" | grep -q "repo"; then
    print_success "Scope 'repo': Present ✓"
else
    print_error "Scope 'repo': Missing ✗"
    echo "Token needs 'repo' scope for full repository access"
    exit 1
fi

if echo "$SCOPES" | grep -q "workflow"; then
    print_success "Scope 'workflow': Present ✓"
else
    print_warning "Scope 'workflow': Missing (may be needed for workflow updates)"
fi

echo ""
echo "========================================="
print_success "All checks passed!"
echo "========================================="
echo ""
print_info "Token is ready to use as PUBLIC_ASSETS_TOKEN"
echo ""
echo "Next steps:"
echo "  1. Add this token as a GitHub Actions secret"
echo "     Repository: eoframework/solutions"
echo "     Settings → Secrets and variables → Actions"
echo "     Name: PUBLIC_ASSETS_TOKEN"
echo "     Value: (your token)"
echo ""
echo "  2. Test the workflow:"
echo "     gh workflow run publish-solutions-folders.yml \\"
echo "       -f publish_mode=single \\"
echo "       -f solution_path=solutions/aws/ai/intelligent-document-processing"
