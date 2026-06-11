# 🔐 Firebase Rules Deployment & Verification Guide

**Status:** ✅ Enhanced CI/CD with Deployment Verification  
**Last Updated:** March 25, 2026

---

## 📋 Overview

The **Security workflow** (`security.yml`) now includes:

✅ **Firestore Rules** - Validation → Deployment → Verification  
✅ **Storage Rules** - Validation → Deployment → Verification  
✅ **Secrets Check** - Validates all required GitHub secrets exist  
✅ **Deployment Report** - Summary posted to GitHub Actions

---

## 🎯 Current Workflow Status

### Pipeline Stages

```
1️⃣ Validate Rules (Firestore + Storage format check)
   ↓
2️⃣ Check Required Secrets (FIREBASE_PROJECT_ID + FIREBASE_TOKEN)
   ↓
3️⃣ Deploy Firestore Rules
   ↓
4️⃣ Verify Firestore Rules (Compare deployed vs. local)
   ↓
5️⃣ Deploy Storage Rules
   ↓
6️⃣ Verify Storage Rules (Compare deployed vs. local)
   ↓
7️⃣ Generate Deployment Report (Posted to GitHub Actions summary)
```

### What Triggers This Workflow

The workflow runs automatically when:
- 🔄 **Push** to `main` branch AND files changed:
  - `firestore.rules`
  - `storage.rules`
  - `firebase.json`
- 🎮 **Manual Trigger** via GitHub Actions "Run workflow" button
- 📝 **Pull Request** to validate rules (no deployment)

---

## ✅ Required GitHub Secrets

### Mandatory Setup (One-Time)

Go to: **GitHub Repository → Settings → Secrets and variables → Actions**

Create these **2 secrets**:

| Secret Name | Value | Source |
|---|---|---|
| `FIREBASE_PROJECT_ID` | Your Firebase project ID (e.g., `paykari-bazar-12345`) | Firebase Console → Project Settings |
| `FIREBASE_TOKEN` | Firebase CLI service account token | Firebase Console → Service Accounts → Generate Key |

### ⚠️ If Secrets Are Missing

The workflow will **FAIL** with this error:
```
❌ Missing required GitHub secrets:
  - FIREBASE_PROJECT_ID
  - FIREBASE_TOKEN

⚙️  Add these secrets in GitHub:
  Settings → Secrets and variables → Actions → New repository secret
```

---

## 🚀 How to Generate Firebase Service Account Token

### Step 1: Go to Firebase Project Settings

1. Login to [Firebase Console](https://console.firebase.google.com)
2. Select your **Paykari Bazar project**
3. Click ⚙️ **Project Settings** (top-left)
4. Click **Service Accounts** tab

### Step 2: Generate Private Key

1. Click **Generate New Private Key** (blue button)
2. Download the JSON file (keep it secure!)

### Step 3: Create FIREBASE_TOKEN

```bash
# Option A: Use Firebase CLI (Recommended)
firebase login:ci

# This will generate a long token string
# Copy the entire token: (e.g., 1234567890abcdef...)

# Option B: Create from service account JSON (Advanced)
cat service-account-key.json | base64 -w 0
```

### Step 4: Add to GitHub Secrets

1. In your GitHub repo: **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name: `FIREBASE_TOKEN`
4. Paste the entire token/base64 string
5. Click **Add secret**

---

## 🔍 Verification Process

### What the Workflow Verifies

#### 1. **Firestore Rules Verification**
```bash
firebase firestore:rules:get --project=$PROJECT_ID > /tmp/deployed_firestore.txt
diff firestore.rules /tmp/deployed_firestore.txt
```
- ✅ If identical: "Firestore Rules verification: PASSED"
- ⚠️ If formatting differs: "Minor formatting differences (expected)"
- ❌ If content differs: Rules deploy failed

#### 2. **Storage Rules Verification**
```bash
firebase storage:rules:get --project=$PROJECT_ID > /tmp/deployed_storage.txt
diff storage.rules /tmp/deployed_storage.txt
```
- ✅ If identical: "Storage Rules verification: PASSED"
- ⚠️ If formatting differs: "Minor formatting differences (expected)"
- ❌ If content differs: Rules deploy failed

#### 3. **Deployment Report**
Check the workflow run summary for a report like:

```
📋 Firebase Rules Deployment Report

### Firestore Rules
- Deploy Status: success
- Verify Status: passed

### Storage Rules
- Deploy Status: success
- Verify Status: passed

Deploy Timestamp: 2026-03-25 10:15:30 UTC
```

---

## 🛠️ Manual Verification (Local)

Test the deployment verification locally:

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login and set project
firebase login
firebase use paykari-bazar-12345

# 3. Deploy and verify
firebase deploy --only firestore:rules,storage

# 4. Get deployed rules
firebase firestore:rules:get > /tmp/deployed_firestore.txt
firebase storage:rules:get > /tmp/deployed_storage.txt

# 5. Compare
diff firestore.rules /tmp/deployed_firestore.txt
diff storage.rules /tmp/deployed_storage.txt
```

---

## 🐛 Troubleshooting

### Problem: "Invalid Firebase Project ID"
```
Error: Invalid project ID "undefined"
```
**Solution:**
1. Go to GitHub repo → Settings → Secrets
2. Verify `FIREBASE_PROJECT_ID` is set (not empty)
3. Verify it matches your Firebase project ID exactly

### Problem: "Firebase token unauthorized"
```
Error: Command 'deploy' not permitted on this token
```
**Solution:**
1. Regenerate token: `firebase login:ci`
2. Update GitHub secret `FIREBASE_TOKEN`
3. Ensure token hasn't expired (valid for 1 year)

### Problem: "Rules differ / Verification failed"
```
❌ Firestore Rules differ
```
**Possible Causes:**
1. Firestore rules syntax error → Fix in `firestore.rules`
2. Deployment incomplete → Check Firebase Console manually
3. Service account permissions → Contact Firebase support

**Debug:**
```bash
firebase firestore:rules:get --project=paykari-bazar-12345
cat firestore.rules  # Compare the outputs manually
```

### Problem: "Run workflow" button missing

**Solution:**
1. Ensure workflow file exists: `.github/workflows/security.yml`
2. Commit and push to `main` branch
3. Wait 1-2 minutes for GitHub to register
4. Hard refresh GitHub (Ctrl+Shift+R)
5. Go to **Actions** tab → **Security - Firebase Rules & Secrets**

---

## 📊 Monitoring & Debugging

### Check Workflow Runs

1. Go to your GitHub repo
2. Click **Actions** tab
3. Select **Security - Firebase Rules & Secrets** workflow
4. Click the latest run
5. Expand each step to see logs

### View Deployment Report

1. Click **Security - Firebase Rules & Secrets** run
2. Scroll down to **Summary** section
3. Look for **Firebase Rules Deployment Report**

### Enable Debug Logging

Add to workflow step:
```yaml
- name: Deploy Firestore Rules
  env:
    DEBUG: 'firebase:*'  # Enable Firebase CLI debug logs
  run: firebase deploy --only firestore:rules
```

---

## ✨ Next Steps

1. **✅ Add GitHub Secrets** (FIREBASE_PROJECT_ID + FIREBASE_TOKEN)
2. **✅ Push a test change** to `firestore.rules` or `storage.rules`
3. **✅ Watch the workflow run** in GitHub Actions → Security workflow
4. **✅ Verify in deployment report** - Should show "PASSED" status

---

## 📞 Support

| Issue | Action |
|-------|--------|
| Workflow won't run | Check `.github/workflows/security.yml` exists |
| Secrets not found | Add via Settings → Secrets and variables → Actions |
| Token expired | Regenerate: `firebase login:ci` |
| Rules always differ | Check Firestore rules syntax with `prettier` |

---

## 📚 Related Docs

- [CI/CD Complete Summary](CI_CD_COMPLETE_SUMMARY.md)
- [Firebase Configuration](firebase.json)
- [Firestore Rules](firestore.rules)
- [Storage Rules](storage.rules)
