#!/bin/bash

# 🚀 PAYKARI BAZAR - COMPLETE CI/CD AUTOMATION SETUP
# ===================================================
# This script verifies all CI/CD files are in place
# and provides next steps for implementation

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  🚀 Paykari Bazar - CI/CD Setup Verification          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} $1"
        return 0
    else
        echo -e "${RED}❌${NC} $1 (MISSING)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅${NC} $1/"
        return 0
    else
        echo -e "${RED}❌${NC} $1/ (MISSING)"
        return 1
    fi
}

# Count checks
total=0
passed=0

# ====================================================
# Check Workflows
# ====================================================
echo -e "${BLUE}📋 Checking GitHub Actions Workflows:${NC}"
echo ""

files=(
    ".github/workflows/auto-build-and-deploy.yml"
    ".github/workflows/security-scan.yml"
    ".github/workflows/auto-update-dependencies.yml"
)

for file in "${files[@]}"; do
    ((total++))
    check_file "$file" && ((passed++))
done

echo ""

# ====================================================
# Check Scripts
# ====================================================
echo -e "${BLUE}🛠️  Checking Local Scripts:${NC}"
echo ""

scripts=(
    "scripts/build.sh"
    "scripts/build.bat"
    "scripts/test.bat"
    "scripts/deploy.ps1"
    "scripts/automate.bat"
    ".github/scripts/setup-ci-cd.sh"
)

for script in "${scripts[@]}"; do
    ((total++))
    check_file "$script" && ((passed++))
done

echo ""

# ====================================================
# Check Documentation
# ====================================================
echo -e "${BLUE}📚 Checking Documentation:${NC}"
echo ""

docs=(
    ".github/CI_CD_COMPLETE_SETUP.md"
    ".github/COMPLETE_CI_CD_AUTOMATION.md"
    "scripts/README_AUTOMATION.md"
    ".github/CI_CD_SETUP.md"
)

for doc in "${docs[@]}"; do
    ((total++))
    check_file "$doc" && ((passed++))
done

echo ""

# ====================================================
# Check Directories
# ====================================================
echo -e "${BLUE}📁 Checking Directory Structure:${NC}"
echo ""

dirs=(
    ".github/workflows"
    ".github/scripts"
    "scripts"
)

for dir in "${dirs[@]}"; do
    ((total++))
    check_dir "$dir" && ((passed++))
done

echo ""

# ====================================================
# Summary
# ====================================================
echo "════════════════════════════════════════════════════════"
echo -e "Setup Verification: ${GREEN}$passed/$total${NC} items ready"
echo "════════════════════════════════════════════════════════"
echo ""

if [ $passed -eq $total ]; then
    echo -e "${GREEN}✅ All CI/CD files are in place!${NC}"
    echo ""
    echo "🚀 Next Steps:"
    echo ""
    echo "1. Add GitHub Secrets:"
    echo "   Go to: Repository Settings → Secrets and variables → Actions"
    echo ""
    echo "   Add these secrets:"
    echo "   • ANDROID_KEYSTORE_PASSWORD"
    echo "   • ANDROID_KEY_PASSWORD"
    echo "   • ANDROID_KEY_ALIAS"
    echo "   • KEYSTORE_BASE64"
    echo "   • FIREBASE_TOKEN"
    echo "   • FIREBASE_PROJECT_ID"
    echo "   • SHOREBIRD_AUTH_TOKEN (optional)"
    echo "   • SLACK_WEBHOOK (optional)"
    echo ""
    
    echo "2. Test Locally:"
    echo "   Windows: .\\scripts\\automate.bat build-and-test"
    echo "   macOS/Linux: ./scripts/build.sh all release"
    echo ""
    
    echo "3. Push to GitHub:"
    echo "   git add ."
    echo "   git commit -m 'build: add CI/CD automation'"
    echo "   git push origin main"
    echo ""
    
    echo "4. Monitor:"
    echo "   GitHub Actions: https://github.com/[owner]/[repo]/actions"
    echo ""
    
    echo "📖 Documentation:"
    echo "   • Quick Start: scripts/README_AUTOMATION.md"
    echo "   • Full Guide: .github/COMPLETE_CI_CD_AUTOMATION.md"
    echo "   • Setup Details: .github/CI_CD_COMPLETE_SETUP.md"
else
    echo -e "${RED}⚠️  Some files are missing!${NC}"
    echo ""
    echo "Please ensure all files listed above are present before proceeding."
fi

echo ""
echo "For more information, read: .github/CI_CD_COMPLETE_SETUP.md"
echo ""
