# 🤖 Paykari Bazar - Complete CI/CD Automation Guide

**Status:** ✅ Fully Automated  
**Platform:** GitHub Actions + Local Scripts  
**Last Updated:** March 25, 2026

---

## 🚀 Quick Start (60 seconds)

### Option 1: GitHub Actions (Recommended for Teams)

```bash
# 1. Push your code to GitHub
git add .
git commit -m "feat: new feature"
git push origin main

# ✅ Done! CI/CD starts automatically
# Monitor at: https://github.com/[repo]/actions
```

### Option 2: Local Build & Deploy (Single Developer)

**Windows:**
```batch
# Build everything
.\scripts\automate.bat build-and-test

# Full pipeline (test + build + deploy)
.\scripts\automate.bat full-pipeline
```

**macOS/Linux:**
```bash
# Build everything
./scripts/build.sh all release

# Run tests
./scripts/test.sh
```

---

## 📋 What's Automated (Complete List)

### ✅ Before Push
- [ ] Code analysis (`flutter analyze`)
- [ ] Unit tests
- [ ] Code coverage report

### ✅ On Every Push
- [ ] Automatic linting & analysis
- [ ] Automatic testing
- [ ] Automatic APK/AAB build (Android)
- [ ] Automatic Web build
- [ ] Automatic GitHub artifact creation

### ✅ On Tag Creation (`git tag v1.0.0`)
- [ ] All above + automatic deployment to:
  - [ ] Google Play Store
  - [ ] Firebase Hosting
  - [ ] Shorebird (OTA updates)
  - [ ] GitHub Releases

### ✅ Scheduled (Automatic)
- [ ] Daily security vulnerability scans
- [ ] Weekly dependency updates
- [ ] Code quality metrics

---

## 🔧 CI/CD Workflows

### 1. **Main Build & Deploy** (`auto-build-and-deploy.yml`)

**When:** Every push to main/develop/staging OR manual trigger  
**Time:** ~15-30 minutes  
**What it does:**

```
Setup & Validation
    ↓
Install Dependencies
    ↓
Test & Analyze
    ↓
┌─────────────────────────────┐
│ Build in Parallel           │
├─────────────────────────────┤
│ • Customer APK              │
│ • Admin APK                 │
│ • Customer AAB              │
│ • Admin AAB                 │
│ • Web (Customer)            │
│ • Web (Admin)               │
└─────────────────────────────┘
    ↓
Deploy to Firebase
Deploy to Google Play
Deploy to Shorebird (OTA)
    ↓
Create GitHub Release
Send Slack Notification
```

### 2. **Security Scan** (`security-scan.yml`)

**When:** Daily at 2 AM UTC  
**What it does:**
- ✅ Vulnerability scanning (Trivy)
- ✅ Secrets detection (TruffleHog)
- ✅ Dependency vulnerability check
- ✅ Code quality analysis
- ✅ SBOM generation

### 3. **Dependency Updates** (`auto-update-dependencies.yml`)

**When:** Weekly (Monday 3 AM UTC)  
**What it does:**
- ✅ Update Flutter packages
- ✅ Update npm packages
- ✅ Create pull requests
- ✅ Auto-merge if tests pass

---

## 🖥️ Local Commands (Windows)

### Quick Build
```batch
# Build everything in release mode
.\scripts\automate.bat build-and-test

# Build specific targets
.\scripts\build.bat all release      REM All platforms
.\scripts\build.bat android debug    REM Just Android (debug)
.\scripts\build.bat apk              REM Just APK
.\scripts\build.bat aab              REM Just AAB (for Play Store)
.\scripts\build.bat web              REM Just Web
```

### Run Tests
```batch
# Full test suite
.\scripts\test.bat
```

### Deploy
```batch
# Deploy to production
powershell -ExecutionPolicy Bypass -File .\scripts\deploy.ps1 -Environment production

# Deploy to staging
powershell -ExecutionPolicy Bypass -File .\scripts\deploy.ps1 -Environment staging
```

### Full Pipeline
```batch
# Complete: test + build + deploy
.\scripts\automate.bat full-pipeline
```

### Clean Build
```batch
# Remove all build artifacts and reinstall
.\scripts\automate.bat clean
```

---

## 🖥️ Local Commands (macOS/Linux)

### Quick Build
```bash
# Build everything in release mode
./scripts/build.sh all release

# Build specific targets
./scripts/build.sh android apk       # Just APK
./scripts/build.sh android aab       # Just AAB
./scripts/build.sh web               # Just Web
```

### Run Tests
```bash
# Full test suite
./scripts/test.sh
```

---

## 📊 GitHub Actions Setup

### 1. Add Required Secrets

Go to: **Repository → Settings → Secrets and variables → Actions**

```
ANDROID_KEYSTORE_PASSWORD = [keystore password]
ANDROID_KEY_PASSWORD      = [key password]
ANDROID_KEY_ALIAS         = upload
KEYSTORE_BASE64          = [base64-encoded keystore]
FIREBASE_TOKEN           = [Firebase CLI token]
FIREBASE_PROJECT_ID      = paykari-bazar
SHOREBIRD_AUTH_TOKEN     = [Shorebird token]  (optional)
SLACK_WEBHOOK            = [Slack webhook]    (optional)
```

### 2. Generate Required Secrets

#### Android Keystore (KEYSTORE_BASE64)
```bash
# Convert existing keystore to base64
base64 -i android/app/upload-keystore.jks > keystore.txt

# Copy entire content to KEYSTORE_BASE64 secret
```

#### Firebase Token
```bash
firebase login:ci
# Copy output to FIREBASE_TOKEN secret
```

#### Shorebird Token (Optional)
```bash
shorebird auth login
# Content from ~/.shorebird/credentials.json
```

### 3. Configure Branch Protection

**Repository → Settings → Branches → Add rule**

For `main` branch:
- ✓ Require status checks to pass
- ✓ Require branches up to date
- ✓ Select: "Setup & Validation", "Test & Analyze", "Build Customer App", "Build Admin App"

---

## 🚀 Deployment Strategies

### Strategy 1: Automatic on Push (Hot Deploy)

```bash
# Just push to main
git add .
git commit -m "feature: xyz"
git push

# ⏱️ ~15 minutes later: Live on all platforms
```

**Risks:** Requires excellent test coverage  
**Best for:** Continuous deployment environments

### Strategy 2: Tag-Based Deployment (Recommended)

```bash
# Push code
git add .
git commit -m "Release v1.0.1"
git push

# When ready to release
git tag v1.0.1
git push origin v1.0.1

# ⏱️ Build starts automatically →
#   Google Play Store + Firebase + Shorebird
```

**Advantages:**
- ✅ Explicit version control
- ✅ Single source of truth for releases
- ✅ Can deploy from any branch
- ✅ GitHub Release auto-created

### Strategy 3: Manual Dispatch

```
GitHub UI → Actions → "Auto Build & Deploy" → Run workflow
```

**Best for:** Emergency hotfixes, specific deployments

---

## 📈 Monitoring & Debugging

### View Build Status

**GitHub Actions Dashboard:**
```
https://github.com/[owner]/[repo]/actions
```

**Per-Workflow Details:**
```
https://github.com/[owner]/[repo]/actions/workflows/auto-build-and-deploy.yml
```

### View Deployments

```
https://github.com/[owner]/[repo]/deployments
```

### View Releases

```
https://github.com/[owner]/[repo]/releases
```

### Common Issues

#### Build Failed: Secret Not Found
```
❌ Error: KEYSTORE_BASE64 secret not found
✅ Fix: Add to Repository Secrets (Settings → Secrets)
```

#### Build Failed: Compilation Error
```
✅ Solution: Run locally first
  ./scripts/build.bat
  Check error logs for details
```

#### Tests Timeout
```
✅ Solution: Increase timeout in workflow
  timeout-minutes: 60  (in auto-build-and-deploy.yml)
```

#### Artifacts Not Found
```
✅ Solution: Check build logs for compilation errors
  View full logs in GitHub Actions UI
```

---

## 🎯 Best Practices

### 1. Always Test Locally First
```batch
# Before pushing
.\scripts\build.bat
.\scripts\test.bat
```

### 2. Use Meaningful Commits
```bash
git commit -m "feat: add payment integration"
git commit -m "fix: resolve AI cache issue"
git commit -m "perf: optimize image loading"
```

### 3. Create PRs for Review
```bash
# Create feature branch
git checkout -b feature/my-feature
git push -u origin feature/my-feature

# Create PR on GitHub
# Let CI checks pass
# Get approval before merge
```

### 4. Use Semantic Versioning for Releases
```bash
v1.0.0  # Major: Breaking changes
v1.1.0  # Minor: New features
v1.0.1  # Patch: Bug fixes

git tag v1.0.0
git push --tags
```

### 5. Monitor Deployments
- Check GitHub Actions after every push
- Review Slack notifications (if configured)
- Verify deployments on actual platforms

---

## 🔐 Security Best Practices

### ✅ Do
- [ ] Store secrets in GitHub Secrets (never in code)
- [ ] Rotate Firebase tokens regularly
- [ ] Keep keystore password secure
- [ ] Review security scan reports daily
- [ ] Update dependencies weekly

### ❌ Don't
- [ ] Commit `.env` files or keystore files
- [ ] Hardcode API keys or passwords
- [ ] Share Firebase tokens
- [ ] Use weak keystore passwords
- [ ] Skip security scans

---

## 📊 Performance Metrics

### Build Times
| Target | Time | Notes |
|--------|------|-------|
| APK (Debug) | 3-5 min | Fast, unoptimized |
| APK (Release) | 8-12 min | Optimized, smaller |
| AAB (Release) | 8-12 min | For Play Store |
| Web | 5-8 min | Dart-to-JS compilation |
| Full Pipeline | 20-30 min | All platforms + deploy |

### Artifact Sizes
| Type | Size |
|------|------|
| Customer APK | 40-60 MB |
| Admin APK | 35-55 MB |
| AAB | 25-35 MB |
| Web (optimized) | 15-25 MB |

---

## 🛠️ Advanced Configuration

### Add Custom Build Step
Edit `auto-build-and-deploy.yml`:
```yaml
- name: Custom Setup
  run: |
    echo "Custom command"
```

### Change Deployment Schedule
Edit `security-scan.yml`:
```yaml
schedule:
  - cron: '0 2 * * *'  # Change timing
```

### Configure Slack Notifications
1. Create Slack App
2. Enable Incoming Webhooks
3. Add `SLACK_WEBHOOK` secret
4. Workflows auto-notify

### Modify Build Settings
```yaml
flutter build apk \
  --build-number=123 \          # Custom build number
  --build-name=1.0.0 \          # Custom version
  --split-per-abi \             # Split by CPU architecture
  --obfuscate --split-debug-info # Security & size
```

---

## 📚 Related Documentation

- [COMPLETE_CI_CD_AUTOMATION.md](.github/COMPLETE_CI_CD_AUTOMATION.md) - Detailed guide
- [CI_CD_SETUP.md](.github/CI_CD_SETUP.md) - Original setup
- [SECRETS_SETUP.md](.github/SECRETS_SETUP.md) - Secret configuration

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Keystore not found" | Add KEYSTORE_BASE64 to secrets |
| "Firebase deployment failed" | Regenerate firebase token |
| "APK not generated" | Check build logs for errors |
| "Tests timeout" | Increase timeout-minutes value |
| "Workflow not running" | Check branch protection rules |
| "Deployment skipped" | Verify FIREBASE_TOKEN is set |

---

## ✅ Implementation Checklist

- [ ] Add all GitHub Secrets
- [ ] Test `./scripts/build.bat` locally
- [ ] Create test branch and push
- [ ] Verify GitHub Actions runs
- [ ] Configure branch protection rules
- [ ] Set up Slack notifications (optional)
- [ ] Test tag-based deployment (`git tag v0.0.1`)
- [ ] Verify deployments on platforms
- [ ] Document team deployment process
- [ ] Set up monitoring alerts

---

## 📞 Support

**Questions?** Check:
1. Workflow files in `.github/workflows/`
2. Script files in `./scripts/`
3. GitHub Actions documentation: https://docs.github.com/en/actions

**Issues?** Check:
1. GitHub Actions logs (most detailed)
2. Local build output (`./scripts/build.bat`)
3. Secret configuration

---

**Last Updated:** March 25, 2026  
**Maintainer:** AI Assistant  
**Status:** ✅ Production Ready
