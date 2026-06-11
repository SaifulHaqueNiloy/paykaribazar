# Flutter GitHub Actions - Version Fix Documentation

**Date:** March 26, 2026  
**Issue:** `Unable to determine Flutter version for channel: stable version: 3.25.0`  
**Solution:** Standardized all workflows to Flutter 3.41.4 with explicit channel specification

---

## 🔴 Problem Identified

### Root Cause
Your workflows had **3 different Flutter versions**, and version **3.25.0** doesn't exist on the stable channel:

```
❌ 3.25.0  - ci.yml, release.yml            (DOESN'T EXIST - causing error)
⚠️  3.24.0  - security-scan.yml             (Outdated)
✅ 3.41.4  - auto-build-and-deploy.yml      (Known working version)
```

### Error Details
```
Unable to determine Flutter version for channel: stable version: 3.25.0 architecture: x64
Error: Process completed with exit code 1.
```

The `subosito/flutter-action@v2` action tries to resolve the version from the stable channel, but 3.25.0 is not a valid release.

---

## ✅ Solution Applied

### Changes Made

**All workflows updated to:**
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.4'    # Known working version
    channel: 'stable'             # Explicit channel
    cache: true                   # Speed up CI/CD
```

### Files Updated

| File | Status | Changes |
|------|--------|---------|
| `ci.yml` | ✅ Fixed | 3.25.0 → 3.41.4 + channel specification |
| `release.yml` | ✅ Fixed | 3.25.0 → 3.41.4 + channel specification |
| `security-scan.yml` | ✅ Fixed | 3.24.0 → 3.41.4 + channel specification |
| `auto-build-and-deploy.yml` | ✅ Already using | 3.41.4 (no change needed) |
| `auto-update-dependencies.yml` | ✅ Already using | 3.41.4 (no change needed) |

### Why 3.41.4?

1. **Verified Working** - Already running successfully in auto-build-and-deploy.yml
2. **Latest Stable** - Supported by Flutter team as stable release
3. **Project Requirement** - Meets "Flutter 3.5.0+" requirement from codebass
4. **Available** - Officially released on stable channel

---

## 🧪 Verification Steps

### 1. Local Test (Optional)
```bash
# Check if Flutter 3.41.4 is available locally
flutter --version

# Should show:
# Flutter 3.41.4 • channel stable • https://github.com/flutter/flutter.git
# Framework • revision abc123...
# Engine • revision abc123...
# Dart • revision abc123...
# DevTools • revision abc123...
```

### 2. GitHub Actions Test
```bash
# Trigger a workflow to verify the fix
git add .github/workflows/
git commit -m "fix: standardize Flutter version to 3.41.4 with explicit channel"
git push
```

When you push, GitHub will run the workflows:
- Navigate to: **GitHub Repo > Actions**
- Look for the latest workflow run
- Verify: "Setup Flutter" step should now succeed
- Check for: "✅ Installed Flutter 3.41.4"

### 3. Expected Success Output
```
✅ Flutter version 3.41.4 found on stable channel
✅ Downloading Flutter SDK...
✅ Extracting Flutter SDK...
✅ Adding Flutter to PATH...
✅ Running "flutter doctor"...
✅ Saving cache...
```

---

## 📋 Complete Workflow Status

### After Fix

| Workflow | Flutter Version | Status | Runs On |
|----------|-----------------|--------|---------|
| **CI (Analyze + Build)** | 3.41.4 | ✅ Fixed | Main merge |
| **Release Pipeline** | 3.41.4 | ✅ Fixed | Release tags |
| **Security Scan** | 3.41.4 | ✅ Fixed | Daily + push to main/develop |
| **Auto Build & Deploy** | 3.41.4 | ✅ Already OK | Main/develop push |
| **Auto Update Dependencies** | 3.41.4 | ✅ Already OK | Weekly schedule |

---

## 🛠️ Additional Improvements

### Optional: Environment Variable Centralization
Current best practice:
```yaml
env:
  FLUTTER_VERSION: '3.41.4'
  JAVA_VERSION: '17'
```

Then use:
```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: ${{ env.FLUTTER_VERSION }}
    channel: 'stable'
    cache: true
```

This allows **single-point version updates** across all workflows.

---

## ❓ FAQ

**Q: Why not use `channel: stable` without specifying version?**  
A: Ambiguous - could change unexpectedly. Always pin versions in CI/CD for reproducibility.

**Q: Can I use a newer version like 3.43.0?**  
A: Yes, if available on stable channel. Check: `flutter releases`

**Q: Will this affect the Android/iOS builds?**  
A: No - just ensures consistent Flutter SDK across all CI/CD tasks.

**Q: What if 3.41.4 becomes outdated?**  
A: Update all occurrences to the new version (now consistent across workflows).

---

## 📞 Next Steps if Issues Persist

1. **Clear GitHub Actions Cache**
   - Settings > Actions > General > Remove all workflow caches

2. **Check Flutter Release Availability**
   ```bash
   curl https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_x64_3.41.4-stable.zip \
     -I | grep -E "HTTP|Content-Length"
   ```

3. **Monitor Workflow Action**
   - GitHub Actions > Latest Run > Setup Flutter step
   - Look for actual download URL being attempted

4. **Force Workflow Re-run**
   - GitHub: Re-run all jobs button to retry with current fix

---

## References

- **Flutter Releases**: [releases.flutter.dev](https://releases.flutter.dev)
- **subosito/flutter-action**: [GitHub Action Docs](https://github.com/subosito/flutter-action)
- **Project Requirement**: Flutter 3.5.0+ (satisfied by 3.41.4)

---

**Fix Applied:** March 26, 2026  
**Status:** ✅ Complete and Ready for Testing
