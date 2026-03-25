#!/bin/bash

# ===================================================================
# 🚀 Paykari Bazar - Complete CI/CD Setup Script
# ===================================================================
# This script sets up your GitHub repository for fully automatic
# CI/CD with building, testing, and deployment.
# ===================================================================

set -e  # Exit on error

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPTS_DIR/../.." && pwd)"

echo "════════════════════════════════════════════════════════════"
echo "  🚀 Paykari Bazar CI/CD Setup"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ===================================================================
# Step 1: Check Prerequisites
# ===================================================================
echo ""
print_status "Step 1: Checking prerequisites..."
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    exit 1
fi
print_success "Git is installed"

# Check if repository is linked to GitHub
if git config --get remote.origin.url | grep -q "github.com"; then
    REPO_URL=$(git config --get remote.origin.url)
    print_success "GitHub repository found: $REPO_URL"
else
    print_error "This doesn't appear to be a GitHub repository"
    exit 1
fi

# Extract owner/repo
REPO_INFO=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
REPO_OWNER=$(echo $REPO_INFO | cut -d'/' -f1)
REPO_NAME=$(echo $REPO_INFO | cut -d'/' -f2)

print_success "Repository: $REPO_OWNER/$REPO_NAME"

# ===================================================================
# Step 2: Check GitHub CLI
# ===================================================================
echo ""
print_status "Step 2: Checking GitHub CLI..."
echo ""

if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    echo "Or install with: brew install gh (macOS), choco install gh (Windows), apt-get install gh (Linux)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "GitHub CLI is installed"
fi

# ===================================================================
# Step 3: Validate Secrets
# ===================================================================
echo ""
print_status "Step 3: Checking GitHub Secrets..."
echo ""

REQUIRED_SECRETS=(
    "ANDROID_KEYSTORE_PASSWORD"
    "ANDROID_KEY_PASSWORD"
    "ANDROID_KEY_ALIAS"
    "KEYSTORE_BASE64"
    "FIREBASE_TOKEN"
    "FIREBASE_PROJECT_ID"
)

OPTIONAL_SECRETS=(
    "SHOREBIRD_AUTH_TOKEN"
    "SLACK_WEBHOOK"
)

print_warning "Make sure these secrets are set in GitHub:"
echo ""
echo "  📋 REQUIRED Secrets:"
for secret in "${REQUIRED_SECRETS[@]}"; do
    echo "     ☐ $secret"
done

echo ""
echo "  📋 OPTIONAL Secrets (for full automation):"
for secret in "${OPTIONAL_SECRETS[@]}"; do
    echo "     ☐ $secret"
done

echo ""
echo "To add secrets, visit:"
echo "https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo ""

read -p "Have you added all required secrets? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Please add the required secrets and run this script again"
    exit 0
fi

# ===================================================================
# Step 4: Create Local Build & Deploy Scripts
# ===================================================================
echo ""
print_status "Step 4: Creating local automation scripts..."
echo ""

# Create build script
cat > "$PROJECT_ROOT/scripts/build.sh" << 'EOF'
#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🏗️  Building Paykari Bazar..."

# Setup
echo "📦 Installing dependencies..."
flutter pub get

echo "🔨 Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Test
echo "🧪 Running tests..."
flutter test --coverage || true

# Build
echo "📱 Building Customer App..."
flutter build apk -t lib/main_customer.dart --release 2>&1 | tail -20

echo "📱 Building Admin App..."
flutter build apk -t lib/main_admin.dart --release 2>&1 | tail -20

echo "🌐 Building Web..."
flutter build web -t lib/main_customer.dart --release 2>&1 | tail -10
flutter build web -t lib/main_admin.dart --release 2>&1 | tail -10

echo "✅ Build complete!"
EOF

chmod +x "$PROJECT_ROOT/scripts/build.sh"
print_success "Created scripts/build.sh"

# Create test script
cat > "$PROJECT_ROOT/scripts/test.sh" << 'EOF'
#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running tests..."

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage

echo "✅ Tests complete!"
EOF

chmod +x "$PROJECT_ROOT/scripts/test.sh"
print_success "Created scripts/test.sh"

# ===================================================================
# Step 5: Configure Branch Protection Rules
# ===================================================================
echo ""
print_status "Step 5: Configuring GitHub branch protection rules..."
echo ""

echo "To require CI checks before merging:"
echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/branches"
echo "2. Click 'Add rule' under 'Branch protection rules'"
echo "3. Enter 'main' as the branch pattern"
echo "4. Enable the following:"
echo "   ✓ Require a pull request before merging"
echo "   ✓ Require status checks to pass before merging"
echo "   ✓ Require branches to be up to date before merging"
echo "5. Select required status checks:"
echo "   ✓ 🔍 Setup & Validation"
echo "   ✓ 📦 Install Dependencies"
echo "   ✓ 🧪 Test & Analyze"
echo "   ✓ 🏗️ Build Customer App"
echo "   ✓ 🏗️ Build Admin App"
echo ""

# ===================================================================
# Step 6: Configure GitHub Actions Permissions
# ===================================================================
echo ""
print_status "Step 6: Configuring GitHub Actions permissions..."
echo ""

echo "For automatic deployments:"
echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/actions"
echo "2. Scroll to 'Workflow permissions'"
echo "3. Select: 'Read and write permissions'"
echo "4. Check: 'Allow GitHub Actions to create and approve pull requests'"
echo ""

# ===================================================================
# Step 7: Setup Deployment Instructions
# ===================================================================
echo ""
print_status "Step 7: Deployment strategies..."
echo ""

echo "Choose your deployment method:"
echo ""
echo "  🌿 Option A: Automatic on Push (Continuous Deployment)"
echo "     - Every push to 'main' triggers deployment"
echo "     - Fast but risky - requires good test coverage"
echo "     - Already configured in auto-build-and-deploy.yml"
echo ""

echo "  📦 Option B: Manual on Tag (Recommended)"
echo "     - Create a tag to trigger deployment"
echo "     - Safer - you control release timing"
echo "     Commands:"
echo "       git tag v1.0.0"
echo "       git push origin v1.0.0"
echo ""

echo "  🔀 Option C: Manual via Workflow Dispatch"
echo "     - Trigger from GitHub UI or CLI"
echo "     - Go to: Actions → Auto Build & Deploy → Run workflow"
echo ""

# ===================================================================
# Step 8: Summary
# ===================================================================
echo ""
echo "════════════════════════════════════════════════════════════"
print_success "CI/CD Setup Complete! 🎉"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "📋 Next Steps:"
echo ""
echo "1. ✅ Add all required secrets to GitHub"
echo "2. ✅ Configure branch protection rules"
echo "3. ✅ Set GitHub Actions permissions"
echo "4. ✅ Make a test commit to trigger CI"
echo ""

echo "📚 Key Files:"
echo "   • .github/workflows/auto-build-and-deploy.yml (Main pipeline)"
echo "   • .github/workflows/security-scan.yml (Daily security)"
echo "   • .github/workflows/auto-update-dependencies.yml (Weekly updates)"
echo "   • scripts/build.sh (Local build)"
echo "   • scripts/test.sh (Local test)"
echo ""

echo "🔗 Useful Links:"
echo "   • Repository: https://github.com/$REPO_OWNER/$REPO_NAME"
echo "   • Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "   • Secrets: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo "   • Deployment status: https://github.com/$REPO_OWNER/$REPO_NAME/deployments"
echo ""

echo "💡 Tips:"
echo "   • Monitor builds at: Actions tab in your repository"
echo "   • Configure Slack notifications for real-time alerts"
echo "   • Set up email notifications in GitHub Settings"
echo "   • Run './scripts/build.sh' locally to test before pushing"
echo ""
