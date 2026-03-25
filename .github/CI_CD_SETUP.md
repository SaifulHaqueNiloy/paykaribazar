# CI/CD Pipeline Setup Guide

## 📋 Overview

Paykari Bazar now has a complete GitHub Actions CI/CD pipeline with:

- ✅ **Automated testing & linting** on every push/PR
- ✅ **Release builds** for Android APK/AAB, web, and OTA
- ✅ **Multi-platform deployment** (Shorebird, Firebase, Google Play)
- ✅ **Security scanning** for secrets and Firebase rules
- ✅ **Automated GitHub releases** with artifacts

---

## 🔐 Required GitHub Secrets

Add these secrets to your GitHub repository (**Settings → Secrets → Actions**):

### Android Build Secrets
```
ANDROID_KEYSTORE_PASSWORD      = njel.com.bd (or your keystore password)
ANDROID_KEY_PASSWORD           = njel.com.bd (or your key password)
ANDROID_KEY_ALIAS              = upload (or your key alias)
KEYSTORE_BASE64                = (base64-encoded keystore file)
```

**Generate keystore base64:**
```bash
# Convert your keystore to base64
base64 -i android/app/upload-keystore.jks -o keystore.txt
# Copy the entire content to KEYSTORE_BASE64 secret
```

### Firebase Secrets
```
FIREBASE_PROJECT_ID            = paykari-bazar (or your project ID)
FIREBASE_TOKEN                 = (Firebase CLI token)
```

**Generate Firebase token:**
```bash
firebase login:ci
# Copy the token output
```

### Shorebird Secrets
```
SHOREBIRD_AUTH_TOKEN           = (Shorebird credentials.json content)
```

**Get Shorebird auth token:**
```bash
shorebird auth:firebase
# Creates ~/.shorebird/credentials.json
cat ~/.shorebird/credentials.json
```

### Google Play Secrets
```
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = (service account JSON for Play Store)
```

**Create Google Play service account:**
1. Go to Google Cloud Console
2. Create service account → Download JSON
3. Add Editor role for Play Store API
4. Base64 encode and add to secrets

### Slack Notifications (Optional)
```
SLACK_WEBHOOK                 = (Slack incoming webhook URL)
```

**Get Slack webhook:**
1. Create Slack App at api.slack.com
2. Enable Incoming Webhooks
3. Create a webhook URL for your channel

---

## 🚀 Workflows Explained

### 1. **CI Workflow** (`.github/workflows/ci.yml`)

**Triggers:** Every push/PR to main/develop

**Steps:**
- ✅ Flutter analyze & lint
- ✅ Run tests with coverage
- ✅ Build APKs (customer + admin)
- ✅ Build web apps
- ✅ Upload coverage to Codecov

**Status checks:** Must pass before merging PRs

---

### 2. **Release Workflow** (`.github/workflows/release.yml`)

**Triggers:** Tag push (v1.0.0) or manual workflow dispatch

**Steps:**
1. Pre-release validation (no errors, tests pass)
2. Build release APKs and AABs
3. Deploy via Shorebird (OTA updates)
4. Deploy web to Firebase Hosting
5. Deploy to Google Play (beta/internal track)
6. Create GitHub Release with artifacts
7. Notify Slack

**Usage:**
```bash
# Create release tag to trigger deployment
git tag v1.0.0
git push origin v1.0.0

# Or manually trigger via GitHub UI
# Actions → Release → Run workflow
```

---

### 3. **Security Workflow** (`.github/workflows/security.yml`)

**Triggers:** Changes to firestore.rules, storage.rules, or firebase.json

**Steps:**
- ✅ Validate Firebase rules syntax
- ✅ Deploy rules to production (main only)
- ✅ Scan for exposed secrets

---

### 4. **Docs Workflow** (`.github/workflows/docs.yml`)

**Triggers:** On release published

**Steps:**
- ✅ Generate release notes
- ✅ Update CHANGELOG.md
- ✅ Update README version
- ✅ Auto-commit to repo

---

## 📱 Release Process (Step-by-Step)

### Option 1: Automated Tag-Based Release (Recommended)

```bash
# 1. Pull latest code
git checkout main
git pull origin main

# 2. Create version tag
git tag v1.0.0

# 3. Push tag to trigger CI/CD
git push origin v1.0.0

# That's it! Workflow will:
# - Run all tests
# - Build APKs/AABs
# - Deploy to Shorebird, Firebase, Google Play
# - Create GitHub release
# - Notify Slack
```

### Option 2: Manual Workflow Dispatch

1. Go to GitHub → Actions
2. Select "Release - Build & Deploy"
3. Click "Run workflow"
4. Enter version (e.g., v1.0.0)
5. Click "Run workflow"

---

## 📊 Deployment Destinations

| Platform | App | Track | Trigger | Status |
|----------|-----|-------|---------|--------|
| **Shorebird** | Customer & Admin | Production | Every release tag | ✅ OTA auto-update |
| **Firebase Hosting** | Web (Customer & Admin) | Production | Every release tag | ✅ CDN deployed |
| **Google Play** | Customer | Beta | Release tags | ✅ Manual review |
| **Google Play** | Admin | Internal | Release tags | ✅ Internal testing |
| **GitHub Releases** | APK, AAB | Production | Release tags | ✅ Download artifacts |

---

## 🔄 CI/CD Flow Diagram

```
┌─────────────────────────────────────────┐
│          Push to main/develop           │
└──────────────────┬──────────────────────┘
                   │
                   ▼
      ┌────────────────────────┐
      │  CI Workflow Triggered  │
      └────────┬───────────────┘
               │
         ┌─────┴─────┐
         │           │
         ▼           ▼
    ┌─────────┐  ┌──────────┐
    │ Analyze │  │Run Tests │
    └────┬────┘  └─────┬────┘
         │             │
         └─────┬───────┘
               │
         Pass? │
         ┌─────┴─────┐
         │           │
       Yes           No
         │            │
         ▼            ▼
    ┌─────────┐  ┌─────────┐
    │ Build   │  │   FAIL  │
    │ All     │  │  Email  │
    │ Apps    │  └─────────┘
    └────┬────┘
         │
         ▼
    ┌─────────────────┐
    │ Create Tag v1.0 │
    │ Push to GitHub  │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────────────┐
    │ Release Workflow Blocked │
    │ (Needs approval/manual)  │
    └────────┬────────────────┘
             │
        Approve?
        ┌──┴──┐
        │     │
       Yes    No
        │     └─→ Stop
        │
        ▼
    ┌──────────────────────┐
    │ Build Release APK/AAB│
    └─────────┬────────────┘
              │
        ┌─────┴─────────────┐
        │                   │
        ▼                   ▼
    ┌─────────┐        ┌──────────┐
    │ Shorebird│      │Firebase  │
    │  Deploy │      │ Deploy   │
    │(OTA)    │      │(Hosting) │
    └────┬────┘      └─────┬────┘
         │                 │
         └─────┬───────────┘
               │
         ┌─────┴─────┐
         │           │
         ▼           ▼
    ┌──────────┐ ┌────────────┐
    │ Notify   │ │ Create GH  │
    │  Slack   │ │ Release    │
    └──────────┘ └────────────┘
         │             │
         └──────┬──────┘
                │
                ▼
         ✅ Release Complete
```

---

## 🧪 Testing the Pipeline

### Test CI (Analyze & Tests)
```bash
# Push to develop branch
git checkout develop
git commit --allow-empty -m "test: CI pipeline"
git push origin develop

# Watch: GitHub → Actions → CI - Test & Analyze
```

### Test Release (Without Actually Deploying)
```bash
# Manually trigger on develop with test version
# GitHub → Actions → Release - Build & Deploy → Run workflow
# Enter: v0.0.1-test
```

---

## 📊 Monitoring & Troubleshooting

### View Workflow Runs
1. GitHub → Actions
2. Select workflow
3. Click latest run
4. Expand failed steps

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| **Auth failed** | Missing/wrong secrets | Verify secrets in Actions settings |
| **Build timeout** | Slow runner | Increase timeout in workflow, use self-hosted runner |
| **APK not found** | Build skipped | Check flutter version in workflow |
| **Deployment failed** | Token expired | Re-generate and update secrets |
| **Rules validation failed** | Syntax error in firestore.rules | Run `firebase validate` locally |

### Debug a Workflow

Enable debug logging:
```bash
# Set this environment variable for verbose output
ACTIONS_STEP_DEBUG=true
```

---

## 🔧 Customization

### Change Build Frequency

Edit `.github/workflows/ci.yml`:
```yaml
on:
  push:
    branches: [main, develop]  # Add more branches
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
```

### Add Matrix Builds (Multiple Flutter Versions)

```yaml
strategy:
  matrix:
    flutter-version: ['3.4.0', '3.5.0', '3.6.0']

steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

### Conditional Deployments

```yaml
if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')
# Only deploy on version tags
```

---

## 📞 Support

- **Logs:** GitHub Actions → Workflow → Failed step
- **Local testing:** Try commands manually before commit
- **Firebase CLI:** `firebase describe firestore`
- **Shorebird CLI:** `shorebird release --help`

---

## ✅ Deployment Checklist

Before first production release:

- [ ] All secrets added to GitHub
- [ ] Firebase project configured
- [ ] Shorebird app setup complete
- [ ] Google Play beta track ready
- [ ] Slack webhook (optional) configured
- [ ] Firestore rules validated
- [ ] Storage rules validated
- [ ] Local build tested: `flutter build apk -t lib/main_customer.dart`
- [ ] Tag created: `git tag v1.0.0`
- [ ] Release workflow passed
