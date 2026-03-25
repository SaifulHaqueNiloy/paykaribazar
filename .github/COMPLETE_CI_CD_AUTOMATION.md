# 🚀 Paykari Bazar - Complete CI/CD Automation Guide

**Status:** Fully Automated (All work from root)  
**Last Updated:** March 25, 2026

---

## 📌 Overview

Your project now has **fully automatic CI/CD** that handles:

✅ **Automatic Testing & Analysis** - On every push/PR  
✅ **Automatic Build** - All platforms (Android APK/AAB, iOS, Web)  
✅ **Automatic Deployment** - Firebase, Google Play Store, Shorebird (OTA)  
✅ **Automatic Security Scanning** - Daily vulnerability checks  
✅ **Automatic Dependency Updates** - Weekly dependency refresh  
✅ **Automatic Release Creation** - GitHub releases with artifacts  
✅ **Automatic Notifications** - Slack alerts on build status  

---

## 🎯 Quick Start

### 1. Run Setup Script

```bash
# Make script executable
chmod +x .github/scripts/setup-ci-cd.sh

# Run setup (guides you through configuration)
.github/scripts/setup-ci-cd.sh
```

### 2. Add GitHub Secrets

Go to: **Settings → Secrets and variables → Actions**

Add these **required** secrets:

```
ANDROID_KEYSTORE_PASSWORD = [Your keystore password]
ANDROID_KEY_PASSWORD      = [Your key password]
ANDROID_KEY_ALIAS         = [Your key alias - usually 'upload']
KEYSTORE_BASE64           = [Base64-encoded .jks file]
FIREBASE_TOKEN            = [Firebase CLI token]
FIREBASE_PROJECT_ID       = paykari-bazar (or your project ID)
```

Add these **optional** secrets for full automation:

```
SHOREBIRD_AUTH_TOKEN      = [Shorebird credentials]
SLACK_WEBHOOK             = [Slack webhook URL for notifications]
```

### 3. Test Locally First

```bash
# Build locally before pushing
./scripts/build.sh

# Run tests locally
./scripts/test.sh
```

---

## 🔄 Automated Workflows

### Workflow 1: Main Build & Deploy (`auto-build-and-deploy.yml`)

**Triggers:**
- Every push to `main`, `develop`, `staging`
- Manual trigger (`workflow_dispatch`)

**What it does:**

```
1. 🔍 Setup & Validation (auto-versioning)
2. 📦 Install Dependencies
3. 🧪 Test & Analyze (unit tests, coverage)
4. 🏗️ Build Customer App (APK + AAB)
5. 🏗️ Build Admin App (APK + AAB)
6. 🌐 Build Web (Customer + Admin)
7. 🔥 Deploy to Firebase (Hosting + Rules)
8. 📱 Deploy to Google Play Store
9. 🐦 Deploy via Shorebird (OTA)
10. 📦 Create GitHub Release
```

**Auto-Versioning:**
- Automatic `build_number` based on commit count
- Automatic `version` from tags (falls back to 0.0.0)

**Conditional Deployment:**
- Only deploys from `main` branch by default
- Manual `deploy_to` input: `all`, `firebase-only`, `play-store-only`, `shorebird-only`

### Workflow 2: Security Scanning (`security-scan.yml`)

**Triggers:**
- Every push to `main`, `develop`
- Daily at 2 AM UTC
- Manual trigger

**What it does:**

```
1. 🔐 Trivy Vulnerability Scan (OS/dependencies)
2. 🔑 Secrets & Credentials Check (no leaked API keys)
3. 📦 Dependency Vulnerability Check (pub.dev + npm)
4. 📋 Generate SBOM (Software Bill of Materials)
5. 📊 Code Quality Analysis (dart metrics)
```

### Workflow 3: Auto Dependency Updates (`auto-update-dependencies.yml`)

**Triggers:**
- Every Monday at 3 AM UTC
- Manual trigger

**What it does:**

```
1. 🆙 Update Flutter dependencies (flutter pub upgrade)
2. 🆙 Update npm dependencies (npm update)
3. 📝 Create PR if updates found (auto-labeled)
4. ✅ Auto-merge if CI passes
```

---

## 📊 Deployment Strategies

### Strategy 1: Continuous Deployment (Hot Deployment)

**Best for:** Active development, frequent updates

```
Any push to 'main' → Automatic deployment to all platforms
```

**Workflow:**

```bash
# Just push code
git add .
git commit -m "feat: new feature"
git push origin main

# ⏱️ ~15 minutes later: Updated in Google Play Store + Firebase + Shorebird
```

**Risks:** Requires excellent test coverage and staging environment

### Strategy 2: Tag-Based Deployment (Recommended)

**Best for:** Stable releases, production deployments

```
Create git tag → Automatic deployment
```

**Workflow:**

```bash
# Push code
git add .
git commit -m "feat: new feature"
git push

# When ready to release
git tag v1.0.1
git push origin v1.0.1

# ⏱️ Automatically builds and deploys as v1.0.1
```

**Advantages:**
- ✅ Explicit version control
- ✅ Easy to track releases
- ✅ Can deploy from any branch
- ✅ GitHub Release automatically created

### Strategy 3: Manual Workflow Dispatch

**Best for:** Emergency hotfixes, testing

```
1. Go to GitHub Actions tab
2. Select "Auto Build & Deploy"
3. Click "Run workflow"
4. Choose branch and deployment targets
```

---

## 🔐 Required GitHub Secrets

### Android Signing

**Option A: Using Existing Keystore**

```bash
# Convert your keystore to base64
base64 -i android/app/upload-keystore.jks -o keystore.txt

# Copy entire content to KEYSTORE_BASE64 secret
```

**Option B: Create New Keystore**

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias upload

# Convert to base64 (see Option A)
```

### Firebase Token

```bash
# Generate Firebase token
firebase login:ci

# Copy token to FIREBASE_TOKEN secret
```

### Shorebird Auth (Optional)

```bash
# Login to Shorebird
shorebird auth login

# Get credentials
cat ~/.shorebird/credentials.json

# Copy to SHOREBIRD_AUTH_TOKEN secret
```

---

## 📈 Monitoring & Debugging

### View Build Status

1. **GitHub Actions Dashboard:**
   - https://github.com/[owner]/[repo]/actions
   - Real-time logs for each job
   - Artifact downloads

2. **GitHub Deployments:**
   - https://github.com/[owner]/[repo]/deployments
   - Deployment history
   - Rollback options

3. **GitHub Releases:**
   - https://github.com/[owner]/[repo]/releases
   - Built artifacts
   - Release notes

### Common Issues & Fixes

#### Issue: "Build failed: Keystore not found"

```
✓ Solution: Ensure KEYSTORE_BASE64 secret is set correctly
  - Verify base64 encoding: base64 -d keystore.txt | file -
  - Should output: "Java KeyStore"
```

#### Issue: "Firebase deployment failed"

```
✓ Solution: Check Firebase token
  - Regenerate: firebase login:ci
  - Verify token has deployment permissions
  - Check FIREBASE_PROJECT_ID matches your project
```

#### Issue: "Tests timeout"

```
✓ Solution: Increase timeout in workflow
  - In auto-build-and-deploy.yml: timeout-minutes
  - Default is 30 min for builds, increase if needed
```

#### Issue: "Artifacts not found"

```
✓ Solution: Check build logs
  - View full logs in GitHub Actions
  - May indicate compilation errors
  - Run ./scripts/build.sh locally to reproduce
```

---

## 🎯 Best Practices

### 1. Always Test Locally First

```bash
# Before pushing
./scripts/build.sh
./scripts/test.sh
```

### 2. Use Meaningful Commit Messages

```bash
git commit -m "feat: add payment integration"
git commit -m "fix: resolve null pointer in AI service"
git commit -m "perf: optimize image caching"
```

### 3. Create PRs for review

```bash
# Instead of pushing directly to main
git checkout -b feature/new-feature
git push -u origin feature/new-feature
# Create PR on GitHub for review
```

### 4. Use Tags for Releases

```bash
# Semantic versioning
git tag v1.0.0  # Major release
git tag v1.0.1  # Patch fix
git tag v1.1.0  # Minor feature

git push --tags
```

### 5. Monitor Deployment Status

- Check Actions tab after every push
- Review Slack notifications (if configured)
- Verify deployments on actual platforms

---

## 🛠️ Advanced Configuration

### Modify Build Behavior

Edit `auto-build-and-deploy.yml`:

```yaml
# Skip tests for faster builds
skip_tests: true

# Deploy only to specific platforms
deploy_to: 'firebase-only'

# Change build timeout
timeout-minutes: 60
```

### Add Custom Steps

```yaml
- name: Custom Pre-Build Step
  run: |
    echo "Custom setup..."
    # Your commands here
```

### Configure Slack Notifications

1. Create Slack App: https://api.slack.com/apps
2. Enable "Incoming Webhooks"
3. Create Webhook → Copy URL
4. Add to GitHub Secrets as `SLACK_WEBHOOK`
5. Workflows will auto-notify your channel

### Schedule Additional Tasks

```yaml
# In any workflow file
schedule:
  - cron: '0 2 * * *'  # Daily at 2 AM UTC
  - cron: '0 3 * * 1'  # Every Monday at 3 AM UTC
```

---

## 📋 Checklist

- [ ] Add all required GitHub Secrets
- [ ] Test locally with `./scripts/build.sh`
- [ ] Make a test commit to verify CI works
- [ ] Configure branch protection rules (Settings → Branches)
- [ ] Set up Slack notifications (optional)
- [ ] Review initial build runs in Actions tab
- [ ] Test tag-based deployment: `git tag v0.0.1 && git push --tags`
- [ ] Verify deployments on Google Play Store / Firebase
- [ ] Set up monitoring/alerting
- [ ] Document deployment process for team

---

## 🆘 Support & Troubleshooting

### View Detailed Logs

1. Go to GitHub Actions tab
2. Click on failed workflow run
3. Expand each job to see detailed logs
4. Search for error messages

### Local Debugging

```bash
# Run build locally to reproduce errors
./scripts/build.sh

# Run tests
./scripts/test.sh

# Check code analysis
flutter analyze
```

### Reset Workflows

If workflows are stuck:

```bash
# Disable and re-enable workflow
gh workflow disable .github/workflows/auto-build-and-deploy.yml
gh workflow enable .github/workflows/auto-build-and-deploy.yml

# Or manually via GitHub UI
```

---

## 📚 Related Documentation

- [APP_STRUCTURE_EXPLORATION.md](../../APP_STRUCTURE_EXPLORATION.md) - App architecture
- [FEATURE_STATUS_CHECK.md](../../FEATURE_STATUS_CHECK.md) - Feature completeness
- [.github/SECRETS_SETUP.md](.github/SECRETS_SETUP.md) - Secret configuration details
- [.github/CI_CD_SETUP.md](.github/CI_CD_SETUP.md) - Original setup guide

---

**Questions?** Check the workflows in `.github/workflows/` or review GitHub Actions documentation.

**Last Updated:** March 25, 2026  
**Maintainer:** AI Assistant
