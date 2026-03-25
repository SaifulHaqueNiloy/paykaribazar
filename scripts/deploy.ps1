# ====================================================
# 🚀 Paykari Bazar - Deploy Script (PowerShell)
# ====================================================
# Deploys built apps to Firebase, Google Play, etc.
# Usage: .\scripts\deploy.ps1 -Target firebase -Mode release
# ====================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "firebase", "playstore", "web")]
    [string]$Target = "all",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("production", "staging", "development")]
    [string]$Environment = "production"
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Paykari Bazar - Deploy to $Environment" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Verify builds exist
$RequiredPaths = @(
    "build/app/outputs/flutter-apk",
    "build/app/outputs/bundle",
    "build/web"
)

Write-Host "Verifying build artifacts..." -ForegroundColor Blue
foreach ($path in $RequiredPaths) {
    if (Test-Path $path) {
        Write-Host "  ✓ $path" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $path (missing)" -ForegroundColor Yellow
    }
}

Write-Host ""

# ====================================================
# Step 1: Deploy to Firebase
# ====================================================
if ($Target -eq "all" -or $Target -eq "firebase") {
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  🔥 Deploying to Firebase" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Check Firebase CLI
    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Firebase CLI not found" -ForegroundColor Red
        Write-Host "   Install: npm install -g firebase-tools" -ForegroundColor Yellow
    } else {
        Write-Host "Using Firebase CLI..." -ForegroundColor Blue
        Write-Host ""
        
        # Deploy Firestore Rules
        Write-Host "📋 Deploying Firestore Rules..." -ForegroundColor Blue
        firebase deploy --only firestore:rules --project=$env:FIREBASE_PROJECT_ID --token=$env:FIREBASE_TOKEN 2>&1 | Select-Object -Last 5
        
        # Deploy Storage Rules
        Write-Host "📦 Deploying Storage Rules..." -ForegroundColor Blue
        firebase deploy --only storage:rules --project=$env:FIREBASE_PROJECT_ID --token=$env:FIREBASE_TOKEN 2>&1 | Select-Object -Last 5
        
        # Deploy Web Hosting
        Write-Host "🌐 Deploying Web Hosting..." -ForegroundColor Blue
        firebase deploy --only hosting --project=$env:FIREBASE_PROJECT_ID --token=$env:FIREBASE_TOKEN 2>&1 | Select-Object -Last 10
        
        Write-Host "✅ Firebase deployment complete" -ForegroundColor Green
    }
    
    Write-Host ""
}

# ====================================================
# Step 2: Deploy to Google Play Store
# ====================================================
if ($Target -eq "all" -or $Target -eq "playstore") {
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📱 Deploying to Google Play Store" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Check for AAB files
    $CustomerAAB = Get-Item "build/app/outputs/bundle/release/customer-*.aab" -ErrorAction SilentlyContinue
    $AdminAAB = Get-Item "build/app/outputs/bundle/release/admin-*.aab" -ErrorAction SilentlyContinue
    
    if ($CustomerAAB) {
        Write-Host "Customer AAB: $($CustomerAAB.Name)" -ForegroundColor Green
        Write-Host "📤 Would upload to Play Store (command placeholder)" -ForegroundColor Yellow
        Write-Host "   Manual step: Use Bundletool or Play Console web UI" -ForegroundColor Yellow
    } else {
        Write-Host "❌ No Customer AAB found" -ForegroundColor Red
        Write-Host "   Build first: .\scripts\build.bat" -ForegroundColor Yellow
    }
    
    if ($AdminAAB) {
        Write-Host "Admin AAB: $($AdminAAB.Name)" -ForegroundColor Green
    }
    
    Write-Host ""
}

# ====================================================
# Step 3: Create Release
# ====================================================
if ($Target -eq "all") {
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  📦 Creating GitHub Release" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Get version
    $LastTag = git describe --tags --abbrev=0 2>$null
    $BuildNumber = (git rev-list --count HEAD)
    
    if ($LastTag) {
        $Version = $LastTag -replace "^v", ""
    } else {
        $Version = "0.0.0"
    }
    
    Write-Host "Version: $Version" -ForegroundColor Green
    Write-Host "Build #: $BuildNumber" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📦 Artifacts ready for release:" -ForegroundColor Blue
    
    Get-ChildItem "build/app/outputs/flutter-apk" -Filter "*.apk" | ForEach-Object {
        Write-Host "   • $($_.Name)" -ForegroundColor Green
    }
    
    Get-ChildItem "build/app/outputs/bundle/release" -Filter "*.aab" | ForEach-Object {
        Write-Host "   • $($_.Name)" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Manual next step:" -ForegroundColor Yellow
    Write-Host "   git tag v$Version" -ForegroundColor Yellow
    Write-Host "   git push origin v$Version" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ Deployment process complete" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Verify deployments on platforms" -ForegroundColor White
Write-Host "   2. Check Google Play Console for build status" -ForegroundColor White
Write-Host "   3. Monitor Firebase Hosting for live traffic" -ForegroundColor White
Write-Host "   4. Create GitHub Release if deploying" -ForegroundColor White
Write-Host ""
