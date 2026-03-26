# 🚀 Paykari Bazar - Deployment Scripts

Automated deployment scripts for the dual-app architecture (Customer + Admin).

## Quick Start

**Simply double-click:**
```
DEPLOY.bat
```

This opens an interactive menu with all deployment options.

---

## 📋 Deployment Options

### 1. **DEPLOY.bat** (Master Menu)
Interactive menu to choose deployment type. **Start here.**

### 2. **deploy_web_all.bat**
Deploy both apps to **Firebase Hosting**
- Builds customer web app → Firebase `hosting:customer`
- Builds admin web app → Firebase `hosting:admin`
- Requires Firebase CLI configured

**Use when:** Updating the web dashboard or customer portal

---

### 3. **deploy_shorebird_patch.bat**
Deploy an **OTA patch** via Shorebird
- Patches existing release without app store resubmission
- Users get update on app restart
- Enter version (e.g., `1.0.0+2`)

**Use when:** Fixing bugs in production quickly (hotfix)

**Process:**
1. Prompts for patch version
2. Builds customer patch
3. Builds admin patch
4. Auto-restores default config

---

### 4. **deploy_shorebird_release.bat**
Full app release via **Shorebird + APK**
- Creates release-ready APK artifacts
- Can generate preview builds
- Requires submission to Play Store

**Use when:** Shipping a new feature release

**Artifacts:**
- `build/app/outputs/flutter-apk/customer-release.apk`
- `build/app/outputs/flutter-apk/admin-release.apk`

---

### 5. **build_apk_local.bat**
Build APKs for **local device testing**
- Split per ABI (arm64, armv7, x86_64)
- No Shorebird upload
- Quick testing and iteration

**Use when:** Testing locally before submission

**Output:**
```
app-armeabi-v7a-release.apk (33.1 MB)
app-arm64-v8a-release.apk (34.5 MB)
app-x86_64-release.apk (36.0 MB)
```

**Install:** `adb install -r <apk-file>`

---

### 6. **build_appbundle.bat**
Build production **App Bundle** (.aab)
- Optimized download size
- Dynamic feature delivery
- Required for Play Store

**Use when:** Submitting to Google Play Store

**Output:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

### 7. **clean_build.bat**
Full **clean rebuild** from scratch
- Deletes build/, pubspec.lock
- Regenerates all dependencies
- Rebuilds code generation

**Use when:** 
- Dependencies are corrupted
- After major package upgrades
- Troubleshooting build issues

**⚠️ WARNING:** Takes 5-10 minutes

---

## 🔧 Prerequisites

Before using any script, ensure:

### ✅ Flutter/Dart
```bash
flutter --version  # Should be 3.27.0+
dart --version
```

### ✅ Firebase CLI
```bash
firebase --version
npm install -g firebase-tools  # If not installed
firebase login
```

### ✅ Shorebird CLI
```bash
shorebird --version
shorebird login  # If not authenticated
```

### ✅ Android SDK / Java 17
```bash
java -version  # Should be 17+
echo %JAVA_HOME%  # Should be set
```

### ✅ Configuration Files Present
- `shorebird.yaml` (main config)
- `shorebird_customer.yaml` (customer override)
- `shorebird_admin.yaml` (admin override)
- `pubspec.yaml` (Flutter config)
- `firebase.json` (Firebase hosting config)

---

## 📱 App Structure

**Two separate entry points:**
- **Customer App:** `lib/main_customer.dart`
- **Admin App:** `lib/main_admin.dart`

**Web Deployment:**
- Customer → `firebase hosting:customer`
- Admin → `firebase hosting:admin`

**Mobile Deployment:**
- Both → Shorebird (OTA)
- Both → Google Play Store (via app bundles/APKs)

---

## 🔄 Release Workflow

### For Bug Fix (Hotfix)
```
1. Fix code
2. Test locally with: build_apk_local.bat
3. Deploy with: deploy_shorebird_patch.bat
   - Version: 1.0.0+2 (patch)
   - Users get instant update
```

### For Feature Release
```
1. Develop features
2. Test locally with: build_apk_local.bat
3. Deploy with: deploy_shorebird_release.bat
   - Version: 1.1.0+1 (minor version bump)
   - Generates APKs
4. Upload to Play Store
```

### For Web Update
```
1. Update code
2. Deploy with: deploy_web_all.bat
   - Updates customer portal
   - Updates admin dashboard
   - Live immediately
```

---

## ⚠️ Troubleshooting

### "Flutter not found"
- Add Flutter to PATH or run from `c:\flutter\bin\`

### "Firebase CLI not found"
- Install: `npm install -g firebase-tools`
- Login: `firebase login`

### "Shorebird not found"
- Install: `https://docs.shorebird.dev/install`
- Login: `shorebird login`

### "Version solving failed"
- Run: `clean_build.bat` first

### "Pub get timeout"
- Run again or check internet connection

---

## 📝 Script Features

✅ Error checking at each step
✅ Clear status messages
✅ Automatic config switching (shorebird.yaml)
✅ Pause before exit (for messages)
✅ Colorized output (blue headers)
✅ Interactive prompts for choices

---

## 🎯 Common Tasks

| Task | Script | Time |
|------|--------|------|
| Quick web update | `deploy_web_all.bat` | 15 min |
| Emergency hotfix | `deploy_shorebird_patch.bat` | 20 min |
| Feature release | `deploy_shorebird_release.bat` | 30 min |
| Local testing | `build_apk_local.bat` | 10 min |
| Play Store submit | `build_appbundle.bat` | 15 min |
| Full reset | `clean_build.bat` | 10 min |

---

## 🚀 Admin Quick Start

1. **Navigate to:** `C:\Users\Nazifa\paykari_bazar`
2. **Double-click:** `DEPLOY.bat`
3. **Choose option** from menu
4. **Follow prompts** and wait for completion

That's it! ✅

---

## 📞 Support

For issues:
- Check `TROUBLESHOOTING.md`
- Review script output for error messages
- Consult deployment logs: `*.log` (if enabled)

Last Updated: March 26, 2026
