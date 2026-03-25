#!/bin/bash

# 🤖 MASTER CI/CD AUTOMATION SETUP SCRIPT
# ========================================
# Runs complete setup and verification

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🤖 Paykari Bazar - Complete CI/CD Setup Master         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Verify GitHub
echo "Step 1: Checking Git configuration..."
if ! git remote get-url origin | grep -q "github.com"; then
    echo "❌ Error: Not a GitHub repository"
    exit 1
fi

REPO_URL=$(git remote get-url origin)
echo "✅ GitHub repository: $REPO_URL"
echo ""

# Step 2: Verify files
echo "Step 2: Verifying CI/CD files..."
./scripts/verify-ci-cd.sh
echo ""

# Step 3: Show secrets needed
echo "Step 3: Required GitHub Secrets"
echo ""
echo "Go to: GitHub Repository → Settings → Secrets and variables → Actions"
echo ""
echo "Add these REQUIRED secrets:"
echo "  • ANDROID_KEYSTORE_PASSWORD"
echo "  • ANDROID_KEY_PASSWORD"
echo "  • ANDROID_KEY_ALIAS"
echo "  • KEYSTORE_BASE64"
echo "  • FIREBASE_TOKEN"
echo "  • FIREBASE_PROJECT_ID"
echo ""
echo "Add these OPTIONAL secrets:"
echo "  • SHOREBIRD_AUTH_TOKEN"
echo "  • SLACK_WEBHOOK"
echo ""

# Step 4: Make scripts executable
echo "Step 4: Making scripts executable..."
chmod +x scripts/*.sh scripts/*.ps1 2>/dev/null || true
chmod +x .github/scripts/*.sh 2>/dev/null || true
echo "✅ Scripts are executable"
echo ""

# Step 5: Summary
echo "════════════════════════════════════════════════════════════"
echo "✅ SETUP COMPLETE"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "🎯 Quick Start:"
echo ""
echo "1. Add GitHub Secrets (see above)"
echo ""
echo "2. Test locally (Windows):"
echo "   .\\scripts\\automate.bat build-and-test"
echo ""
echo "3. Test locally (macOS/Linux):"
echo "   ./scripts/build.sh all release"
echo "   ./scripts/test.sh"
echo ""
echo "4. Push to GitHub:"
echo "   git add ."
echo "   git commit -m 'build: add CI/CD automation'"
echo "   git push"
echo ""
echo "5. Watch GitHub Actions:"
echo "   https://github.com/[owner]/[repo]/actions"
echo ""

echo "📚 Documentation:"
echo "   • Quick Start: scripts/README_AUTOMATION.md"
echo "   • Full Guide: .github/COMPLETE_CI_CD_AUTOMATION.md"
echo ""

echo "✨ That's it! Your CI/CD is now fully automated!"
echo ""
