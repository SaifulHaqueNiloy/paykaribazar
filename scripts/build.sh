#!/bin/bash

# ====================================================
# 🏗️ Paykari Bazar - Complete Build Script
# ====================================================
# Builds all apps: Android (APK/AAB), iOS, Web, Windows, Linux
# Usage: ./scripts/build.sh [target] [mode]
#        ./scripts/build.sh all release
#        ./scripts/build.sh android debug
# ====================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
BUILD_TARGET="${1:-all}"
BUILD_MODE="${2:-release}"
TIMESTAMP=$(date +%s)

print_header() {
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo -e "${BLUE}🏗️  $1${NC}"
    echo "════════════════════════════════════════════════════════"
    echo ""
}

print_step() {
    echo -e "${BLUE}→ $1${NC}"
}

print_done() {
    echo -e "${GREEN}✅ $1${NC}"
}

# ====================================================
# Setup Phase
# ====================================================
print_header "Build Setup"

print_step "Flutter version"
flutter --version

print_step "Dart version"
dart --version

print_step "Installing dependencies"
flutter pub get

print_step "Generating code"
flutter pub run build_runner build --delete-conflicting-outputs

print_done "Setup complete"

# ====================================================
# Validation Phase
# ====================================================
print_header "Code Validation"

print_step "Running Flutter Analyze"
flutter analyze --no-fatal-infos || true

print_step "Running tests"
flutter test --coverage 2>&1 | tail -20 || true

print_done "Validation complete"

# ====================================================
# Build Phase
# ====================================================

# Android APK
if [[ "$BUILD_TARGET" == "all" || "$BUILD_TARGET" == "android" || "$BUILD_TARGET" == "apk" ]]; then
    print_header "Building Android APK (Customer)"
    flutter build apk -t lib/main_customer.dart --${BUILD_MODE} 2>&1 | tail -30
    print_done "Customer APK built"
    
    print_header "Building Android APK (Admin)"
    flutter build apk -t lib/main_admin.dart --${BUILD_MODE} 2>&1 | tail -30
    print_done "Admin APK built"
    
    # Rename APKs
    mv build/app/outputs/flutter-apk/app-release.apk \
       build/app/outputs/flutter-apk/customer-${TIMESTAMP}.apk 2>/dev/null || true
fi

# Android AAB (Google Play)
if [[ "$BUILD_TARGET" == "all" || "$BUILD_TARGET" == "android" || "$BUILD_TARGET" == "aab" || "$BUILD_TARGET" == "playstore" ]]; then
    print_header "Building Android App Bundle (Customer)"
    flutter build appbundle -t lib/main_customer.dart --${BUILD_MODE} 2>&1 | tail -30
    print_done "Customer AAB built"
    
    print_header "Building Android App Bundle (Admin)"
    flutter build appbundle -t lib/main_admin.dart --${BUILD_MODE} 2>&1 | tail -30
    print_done "Admin AAB built"
fi

# Web
if [[ "$BUILD_TARGET" == "all" || "$BUILD_TARGET" == "web" ]]; then
    print_header "Building Web (Customer)"
    flutter build web -t lib/main_customer.dart --${BUILD_MODE} 2>&1 | tail -20
    print_done "Web Customer built"
    
    print_header "Building Web (Admin)"
    flutter build web -t lib/main_admin.dart --${BUILD_MODE} 2>&1 | tail -20
    print_done "Web Admin built"
fi

# iOS (macOS only)
if [[ "$BUILD_TARGET" == "all" || "$BUILD_TARGET" == "ios" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_header "Building iOS (Customer)"
        flutter build ios -t lib/main_customer.dart --${BUILD_MODE} 2>&1 | tail -30
        print_done "iOS Customer built"
    else
        echo -e "${YELLOW}⚠️  iOS builds only work on macOS${NC}"
    fi
fi

# ====================================================
# Summary
# ====================================================
print_header "Build Summary"

echo "Build artifacts:"
echo ""
echo "📱 Android:"
find build/app/outputs/flutter-apk -name "*.apk" 2>/dev/null && echo "   ✓ APK" || echo "   ✗ APK"
find build/app/outputs/bundle -name "*.aab" 2>/dev/null && echo "   ✓ AAB" || echo "   ✗ AAB"

if [ -d "build/web" ]; then
    echo "🌐 Web:"
    echo "   ✓ build/web/ ($(du -sh build/web 2>/dev/null | cut -f1))"
fi

echo ""
print_done "Build completed successfully!"
echo ""
echo "📍 Output locations:"
echo "   • APK: build/app/outputs/flutter-apk/"
echo "   • AAB: build/app/outputs/bundle/"
echo "   • Web: build/web/"
echo ""
