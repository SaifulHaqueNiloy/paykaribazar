# 📦 GitHub Release Automation - Complete Setup

## ✅ What's Been Configured

### 1. **GitHub Actions Workflow** (`.github/workflows/release.yml`)
- **Trigger:** When you push a Git tag like `v1.0.0`
- **Builds:** Customer APK + Admin APK
- **Uploads:** Both APKs to GitHub Releases
- **Time:** ~15-25 minutes per build
- **No secrets required** ✅

### 2. **Release Script** (`scripts/release.bat`)
- Easy Windows PowerShell command
- Creates Git tags automatically
- Pushes to GitHub to trigger workflow
- Shows progress and next steps

### 3. **Automated Main Script** (`scripts/automate.bat`)
- Now includes `release` command
- Integrated into CI/CD pipeline
- One command to create releases

### 4. **Documentation** (`GITHUB_RELEASE_GUIDE.md`)
- Complete usage guide
- Step-by-step instructions
- Troubleshooting tips
- Download instructions

---

## 🚀 How to Create a Release

### **Fastest Way (Recommended)**

#### **Method 1: Using the Release Script (Windows)**
```powershell
# Open PowerShell in project directory
cd C:\Users\Nazifa\paykari_bazar

# Create release v1.0.0
.\scripts\release.bat 1.0.0
```

**Then:**
1. Answer `y` to confirm
2. Wait for tag to push
3. Go to GitHub Actions to watch build
4. Download APKs when complete

---

#### **Method 2: Using Main Automation Script**
```powershell
# Create release v1.0.0
.\scripts\automate.bat release 1.0.0
```

---

#### **Method 3: Direct Git Commands** (PowerShell)
```powershell
# Create tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0
```

---

## 📥 What Happens Automatically

When you push a tag:

```
STEP 1: GitHub receives the tag
         ↓
STEP 2: GitHub Actions triggers
         ↓
STEP 3: Checks everything (2-3 min)
         ├─ Tests code
         ├─ Analyzes for errors
         └─ Verifies setup
         ↓
STEP 4: Builds Customer APK (5-10 min)
         └─ Result: paykari_bazar_customer_v1.0.0.apk
         ↓
STEP 5: Builds Admin APK (5-10 min)
         └─ Result: paykari_bazar_admin_v1.0.0.apk
         ↓
STEP 6: Creates GitHub Release
         └─ Both APKs automatically attached
         └─ Release notes auto-generated
         ↓
STEP 7: ✅ Done! Download APKs
```

---

## 🔗 Key Links

| What | Where |
|-----|-------|
| **GitHub Actions** | https://github.com/YOUR_USERNAME/paykari_bazar/actions |
| **Releases** | https://github.com/YOUR_USERNAME/paykari_bazar/releases |
| **Download APKs** | https://github.com/YOUR_USERNAME/paykari_bazar/releases/v1.0.0 |
| **Release Workflow** | `.github/workflows/release.yml` |

---

## 📝 Version Numbering Guide

```
v1.0.0 = Initial Release
v1.0.1 = Bug fix
v1.1.0 = New feature
v2.0.0 = Major release

Pattern: vMAJOR.MINOR.PATCH

Examples:
  First release:        git tag -a v1.0.0
  Bug fix release:      git tag -a v1.0.1
  New feature release:  git tag -a v1.1.0
  Major release:        git tag -a v2.0.0
```

---

## 💾 All Files Added/Modified

| File | Purpose |
|------|---------|
| `.github/workflows/release.yml` | **Modified** - GitHub Actions workflow |
| `scripts/release.bat` | **New** - Easy release script |
| `scripts/automate.bat` | **Modified** - Added release command |
| `GITHUB_RELEASE_GUIDE.md` | **New** - Complete user guide |
| `GITHUB_RELEASE_AUTOMATION_SETUP.md` | **New** - This file |

---

## 🎯 Quick Start (30 seconds)

1. **Make sure code is committed:**
   ```powershell
   git status
   git add .
   git commit -m "Ready for v1.0.0"
   ```

2. **Create release:**
   ```powershell
   .\scripts\release.bat 1.0.0
   ```

3. **Answer the prompt:** Type `y` and press Enter

4. **Watch build progress:**
   - Go to: https://github.com/YOUR_USERNAME/paykari_bazar/actions
   - Click the running workflow
   - Watch the build complete (15-25 min)

5. **Download APKs:**
   - Go to: https://github.com/YOUR_USERNAME/paykari_bazar/releases
   - Click `v1.0.0`
   - Download both APK files

---

## 📱 Install on Phone

After downloading:

1. **Transfer to phone:**
   - Email APK to yourself
   - Or use USB cable to copy file
   - Or use cloud storage (Google Drive, etc.)

2. **Install on Android:**
   - Open Settings → Security
   - Enable "Install from Unknown Sources"
   - Open Downloads folder
   - Tap APK file
   - Install
   - Open app

---

## 🔄 Latest Release Processes

### Process 1: Quick Daily Build
```powershell
.\scripts\release.bat 1.0.0-beta1    # For testing
```

### Process 2: Weekly Production Release
```powershell
.\scripts\release.bat 1.1.0           # New features
.\scripts\release.bat 1.0.1           # Bug fixes
```

### Process 3: Major Release
```powershell
.\scripts\release.bat 2.0.0           # Breaking changes
```

---

## ❓ FAQ

### Q: How often can I create releases?
**A:** As often as you want! No limits. Just use a new version number each time.

### Q: Does it cost money?
**A:** No! GitHub Actions is free for public repos (2000 min/month).

### Q: What if the build fails?
**A:** Check GitHub Actions log for error. Common issues:
- Missing Flutter dependencies (run `flutter pub get`)
- Compilation errors (check `flutter analyze`)
- Java not installed (need Java 17)

### Q: Can I create releases without using the script?
**A:** Yes! Use method 3 (direct Git commands) or GitHub web interface.

### Q: How do I delete a wrong release?
**A:** 
```powershell
git tag -d v1.0.0                    # Delete locally
git push origin --delete v1.0.0      # Delete from GitHub
# Then manually delete from GitHub Releases page
```

---

## 🎯 Next Steps

1. ✅ **Try it now:**
   ```powershell
   .\scripts\release.bat 0.1.0
   ```

2. ✅ **Wait for build** (~20 min)

3. ✅ **Download APKs** from GitHub Releases

4. ✅ **Test both apps** on your phone

5. ✅ **Share with your team** - provide GitHub release link

---

## 📚 See Also

- **Complete CI/CD Setup:** `START_HERE_CI_CD.md`
- **Release Workflow Details:** `.github/workflows/release.yml`
- **Installation Guide:** `GITHUB_RELEASE_GUIDE.md`
- **Full Documentation:** `CI_CD_SETUP_GUIDE.md`

---

## ⚡ Commands Summary

```powershell
# Create release (main way)
.\scripts\release.bat 1.0.0

# Alternative using automate script
.\scripts\automate.bat release 1.0.0

# Direct Git method
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

# List all releases
git tag -l

# View specific release
git show v1.0.0

# Delete tag (undo)
git tag -d v1.0.0
git push origin --delete v1.0.0
```

---

**🎉 Setup Complete! Ready to Build and Share Releases!** 🎉
