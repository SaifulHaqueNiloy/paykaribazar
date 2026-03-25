# CI/CD Quick Reference Guide

**TL;DR for developers and release managers.**

---

## 🚀 Release (Fastest Way)

```bash
# Create release tag
git tag v1.0.0

# Push to trigger automation
git push origin v1.0.0

# Done! CI/CD handles:
# ✅ Tests + Analysis
# ✅ Build APKs/AABs
# ✅ Deploy to Shorebird
# ✅ Deploy to Firebase
# ✅ Deploy to Google Play
# ✅ Create GitHub Release
# ✅ Notify Slack
```

---

## 📱 Development Workflow

### Commit to develop → Automatic CI

```bash
git checkout develop
git commit -m "feat: Add new feature"
git push origin develop

# Automatically runs:
# - flutter analyze
# - flutter test
# - build APK (customer + admin)
# - build web
# Results: GitHub → Actions
```

### Pull Request → Automatic Checks

```bash
# Push to feature branch
git push origin feature/my-feature

# Create PR → Automatic CI runs
# GitHub will show ✅ or ❌ before merge

# Merge only when:
# ✅ All checks pass
# ✅ Code review approved
```

---

## 📊 View Build Status

1. Go to GitHub repository
2. Actions tab
3. Find your workflow
4. Click to see logs

Or view live:
```bash
# Watch CI in real-time (requires GitHub CLI)
gh run watch
```

---

## 🔴 If Build Fails

```bash
# 1. Check error message
GitHub → Actions → Failed Workflow → Expand step

# 2. Fix locally
flutter analyze  # See what failed
flutter test     # Run tests
flutter build apk -t lib/main_customer.dart

# 3. Commit and push
git push origin develop

# CI will retry automatically
```

---

## 🎯 Common Commands

| Goal | Command |
|------|---------|
| **Start release** | `git tag v1.0.0 && git push origin v1.0.0` |
| **Test locally before release** | `flutter test && flutter analyze && flutter build apk -t lib/main_customer.dart` |
| **Check CI status** | GitHub → Actions |
| **Manual retry** | GitHub → Actions → Workflow → Run workflow (button) |
| **Cancel running build** | GitHub → Actions → Workflow → Click X button |
| **View deployment logs** | GitHub → Actions → Release workflow → "Deploy to Firebase" step |

---

## 🔐 Secrets (Already Configured)

No action needed once set up. Secrets used automatically by workflows:
- ✅ Android signing
- ✅ Firebase deployment
- ✅ Shorebird OTA
- ✅ Google Play upload
- ✅ Slack notifications

---

## 📈 Deployment Timeline

```
Commit → CI (15 min) → Release Build (30 min) → Deploy (10 min) → Live!
```

**Total: ~55 minutes** from code commit to production

---

## 🆘 Emergency Hotfix Release

```bash
# 1. Get latest main (production)
git checkout main
git pull origin main

# 2. Make critical fix
git commit -am "fix: Critical bug"

# 3. Tag as hotfix
git tag v1.0.1-hotfix.1

# 4. Push immediately
git push origin v1.0.1-hotfix.1

# 5. Monitor: GitHub → Actions
```

---

## ✅ Pre-Release Checklist

Before creating release tag:

```bash
# 1. Update version in pubspec.yaml
nano pubspec.yaml
# Change: version: 1.0.0+1

# 2. Run all checks
flutter clean
flutter pub get
flutter analyze
flutter test

# 3. Build locally (sanity check)
flutter build apk -t lib/main_customer.dart
flutter build apk -t lib/main_admin.dart
flutter build web -t lib/main_customer.dart

# 4. Create tag
git tag v1.0.0

# 5. Push
git push origin v1.0.0

# 6. Watch CI/CD
gh run watch  # if GitHub CLI installed
```

---

## 📞 Get Help

| Issue | Where to Look |
|-------|---|
| Build error | GitHub → Actions → [Workflow] → Expand failed step |
| Deployment stuck | GitHub → Actions → [Workflow] → Check logs |
| Secret not working | .github/SECRETS_SETUP.md |
| Need manual deploy | GitHub → Actions → Release workflow → "Run workflow" button |
| CI won't trigger | Check: Did you push the tag? `git push origin v1.0.0` |

---

## 🎓 Full Documentation

- **Setup guide:** `.github/CI_CD_SETUP.md`
- **Secrets config:** `.github/SECRETS_SETUP.md`
- **Workflow details:** `.github/workflows/*.yml`

---

## 🚨 Important Notes

1. **Always test locally** before pushing:
   ```bash
   flutter analyze && flutter test
   ```

2. **Use semantic versioning** for tags:
   - `v1.0.0` - Major release
   - `v1.0.1` - Patch (bug fix)
   - `v1.1.0` - Minor (new feature)

3. **Don't create tags manually** unless you know what you're doing

4. **Check Slack** (if configured) for deployment notifications

5. **All secrets are environment-only**—never commit credentials

---

## 💡 Pro Tips

### Faster local builds with caching
```bash
flutter build apk --split-per-abi  # Smaller, faster
flutter build web --web-renderer=skia  # Use SkiaKit renderer
```

### Skip CI for minor commits
```bash
git commit -m "docs: Update README [skip ci]"
# CI won't run if commit message has [skip ci]
```

### Manual workflow trigger
1. GitHub → Actions
2. Select workflow
3. Click "Run workflow" dropdown
4. Fill in inputs (if any)
5. Click "Run workflow"

---

## 📊 What Each Workflow Does

| Workflow | Trigger | Time | Output |
|----------|---------|------|--------|
| **CI** | Push/PR to main/develop | 15 min | ✅/❌ checks |
| **Release** | Push tag v1.0.0 | 30 min | APK/web/GitHub Release |
| **Security** | Changes to rules files | 5 min | ✅/❌ validation |
| **Docs** | Release published | 5 min | Updated CHANGELOG.md |

---

## 🎉 Success Indicators

Release succeeded when:
- ✅ GitHub → Actions → Release workflow shows green ✅
- ✅ GitHub Releases → New version visible with artifacts
- ✅ Slack notification shows success (if configured)
- ✅ Google Play Console shows new version in beta/internal
- ✅ Firebase Hosting shows new version deployed

All done! 🚀
