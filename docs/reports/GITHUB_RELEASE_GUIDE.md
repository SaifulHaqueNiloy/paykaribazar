# 📦 GitHub Release & Download APK Guide

## 🎯 How It Works

When you push a tag like `v1.0.0`, GitHub Actions automatically:
1. ✅ Checks everything is working
2. 🏗️ Builds Customer APK
3. 🏗️ Builds Admin APK
4. 📝 Creates release notes from Git commits
5. 🎉 Creates GitHub Release with both APKs ready to download

---

## 🚀 How to Create a Release

### **Step 1: Make sure your code is ready**
```bash
git status
# Make sure everything is committed
git add .
git commit -m "Ready for release v1.0.0"
```

### **Step 2: Create and push a tag**

**Option A: Command line (Windows PowerShell) - Recommended**
```powershell
# Create a tag
git tag -a v1.0.0 -m "Release version 1.0.0 - Customer and Admin apps"

# Push the tag (this triggers GitHub Actions)
git push origin v1.0.0

# Verify
git tag -l
```

**Option B: Via GitHub Web**
1. Go to: `https://github.com/YOUR_USERNAME/paykari_bazar/releases`
2. Click "Create a new release"
3. Enter tag: `v1.0.0`
4. Title: "Release 1.0.0"
5. Click "Publish release"

### **Step 3: Wait for build to complete**

Go to: `https://github.com/YOUR_USERNAME/paykari_bazar/actions`

Watch the workflow run:
```
📦 GitHub Release - Build APKs
  ├─ ✅ Pre-Release Checks (2-3 min)
  ├─ 🏗️ Build Release APKs (15-20 min)
  │   ├─ 🛍️ Build Customer APK
  │   ├─ 🏢 Build Admin APK
  │   └─ 🎉 Create GitHub Release
  └─ ✅ Done
```

---

## 📥 Download the APKs

### **After build completes:**

1. Go to: `https://github.com/YOUR_USERNAME/paykari_bazar/releases`
2. Click on the latest release (e.g., `v1.0.0`)
3. Scroll down to see attachments:
   - `paykari_bazar_customer_v1.0.0.apk` (🛍️ Customer App)
   - `paykari_bazar_admin_v1.0.0.apk` (🏢 Admin App)

4. Click download link for each APK

---

## 📱 Install APK on Your Phone

### **Customer App:**
1. Download: `paykari_bazar_customer_v1.0.0.apk`
2. Transfer to phone via USB or email
3. Open Settings → Security → Enable "Unknown Sources"
4. Navigate to Downloads folder
5. Tap the APK file and install
6. Open "Paykari Bazar" app

### **Admin App:**
1. Download: `paykari_bazar_admin_v1.0.0.apk`
2. Follow same steps as above
3. Open "Paykari Bazar Admin" app

---

## 📋 Release Notes Structure

Each release automatically includes:

```
🚀 Release: v1.0.0

📝 Changes:
  a1b2c3d - Add new feature X
  d4e5f6g - Fix bug in payment flow
  h7i8j9k - Update AI service
  ...

📥 Downloads:
  🛍️ Customer App: (see attachments)
  🏢 Admin App: (see attachments)

📱 How to Install:
  1. Download the APK file
  2. Transfer to Android phone
  3. Enable Unknown Sources
  4. Install and open app

🔢 Build Info:
  Version: v1.0.0
  Commit: abc123def456
  Build Time: 2026-03-25 10:30:00 UTC
```

---

## 🆚 Version Bump Examples

```bash
# From v1.0.0 to:

v1.0.1    # Bug fix (patch)
v1.1.0    # New feature (minor)
v2.0.0    # Breaking change (major)

# Example:
git tag -a v1.0.1 -m "Minor bug fixes"
git push origin v1.0.1
```

---

## 🔄 Workflow File Location

The automation lives here:
```
.github/workflows/release.yml
```

Configuration:
- Triggers on: Tags like `v1.0.0`, `v1.0.1`, `v2.0.0`
- Builds: Both Customer and Admin APKs
- Platform: Ubuntu (Linux) - same as most developers
- Time: ~20-25 minutes total

---

## ❌ Troubleshooting

### **"Build failed"**
Check the GitHub Actions log:
1. Go to: https://github.com/YOUR_USERNAME/paykari_bazar/actions
2. Click the failed workflow
3. Scroll to find error message
4. Common issues:
   - Missing dependencies → Run `flutter pub get`
   - Compilation errors → Check `flutter analyze`
   - Java version issue → Needs Java 17

### **"APK not found in release"**
1. Check workflow completed successfully (✅ green checkmark)
2. Wait 30 seconds for files to be uploaded
3. Refresh the release page

### **"Can't install APK on phone"**
1. Enable "Unknown Sources" in Settings
2. Make sure phone has ~100MB free space
3. Try installing on different phone if possible

---

## 📚 Related Files

- Automated build workflow: `.github/workflows/release.yml`
- CI/CD setup: `.github/workflows/auto-build-and-deploy.yml`
- Documentation: `START_HERE_CI_CD.md`

---

## 🎯 Quick Command Reference

```powershell
# Create release
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

# List all releases
git tag -l

# Delete local tag (if needed)
git tag -d v1.0.0

# Delete remote tag (if needed)
git push origin --delete v1.0.0

# View specific release
git show v1.0.0
```

---

## ✅ What to Do Now

1. ✅ Make final commit to your code
2. ✅ Test locally (optional)
3. ✅ Create a tag: `git tag -a v1.0.0 -m "First release"`
4. ✅ Push tag: `git push origin v1.0.0`
5. ✅ Wait for GitHub Actions (15-20 min)
6. ✅ Download APKs from GitHub Releases
7. ✅ Share with team / Install on phones

**That's it!** 🎉
