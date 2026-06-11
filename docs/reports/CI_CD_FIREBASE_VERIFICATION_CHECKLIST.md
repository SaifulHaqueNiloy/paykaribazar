# ✅ CI/CD Firebase Rules Deployment - Verification Checklist

**Status:** Ready to Verify  
**Date:** March 25, 2026

---

## 🎯 Quick Setup Checklist

### Phase 1: GitHub Secrets Configuration

- [ ] **FIREBASE_PROJECT_ID** secret added
  - Go to: **Settings → Secrets and variables → Actions**
  - Value: Your Firebase project ID (e.g., `paykari-bazar-12345`)
  - ✓ Can be found in Firebase Console → Project Settings

- [ ] **FIREBASE_TOKEN** secret added
  - Generate: Run `firebase login:ci` locally
  - Paste entire token into GitHub secret
  - ✓ Token is valid for 1 year from generation

### Phase 2: Workflow File Verification

- [ ] `.github/workflows/security.yml` exists
  - Contains: Validate → Deploy → Verify stages
  - Triggers on: Push to main + `firestore.rules` or `storage.rules` changes

- [ ] Firebase rules files exist
  - [ ] `firestore.rules` - Present and valid
  - [ ] `storage.rules` - Present and valid
  - [ ] `firebase.json` - Configuration file

### Phase 3: Test Run

- [ ] Make a small change to `firestore.rules` or `storage.rules`
  - Example: Add a comment
  - ```
    # Test deployment - remove after verification
    ```

- [ ] Commit and push to `main` branch
  ```bash
  git add firestore.rules
  git commit -m "test: verify rules deployment"
  git push
  ```

- [ ] Check GitHub Actions
  - [ ] Go to Actions tab
  - [ ] Select **Security - Firebase Rules & Secrets**
  - [ ] Click the latest run
  - [ ] Watch for **✅ All steps passed**

- [ ] Verify in GitHub Actions Summary
  - [ ] Look for **Firebase Rules Deployment Report**
  - [ ] Firestore Rules: "PASSED"
  - [ ] Storage Rules: "PASSED"

---

## 🔍 Step-by-Step Verification Process

### Step 1: Generate Firebase Token

```bash
# Login interactively
firebase login

# Generate CI token
firebase login:ci

# Copy the entire token that appears
# Example: 1//0d...very...long...token...string
```

### Step 2: Add GitHub Secrets

```bash
# In browser:
# 1. Go to GitHub repo
# 2. Settings → Secrets and variables → Actions
# 3. New repository secret:
#    - Name: FIREBASE_PROJECT_ID
#    - Value: paykari-bazar-12345
# 4. New repository secret:
#    - Name: FIREBASE_TOKEN
#    - Value: 1//0d...very...long...token...string
```

### Step 3: Trigger Test Workflow

**Option A: Via GitHub UI**
1. Go to **Actions** tab
2. Select **Security - Firebase Rules & Secrets**
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow** button

**Option B: Via Local Push**
```bash
# Make a small change
echo "# Test" >> firestore.rules

# Commit and push
git add firestore.rules
git commit -m "test: verify deployment"
git push

# Watch in GitHub Actions
```

### Step 4: Monitor Workflow Execution

```
Expected Timeline:
- 0:00 - Workflow starts
- 0:15 - Secrets validated ✅
- 0:30 - Firestore rules validated ✅
- 0:45 - Firestore rules deployed ✅
- 1:00 - Firestore rules verified ✅
- 1:15 - Storage rules deployed ✅
- 1:30 - Storage rules verified ✅
- 1:45 - Deployment report generated ✅
- 2:00 - Workflow complete ✅
```

### Step 5: Interpret Results

**Success Output:**
```
✅ Validate Firestore Rules - PASSED
✅ Validate Storage Rules Format - PASSED
✅ Validate Required Secrets - PASSED
✅ Deploy Firestore Rules - PASSED
✅ Verify Firestore Rules Deployed - PASSED
✅ Deploy Storage Rules - PASSED
✅ Verify Storage Rules Deployed - PASSED
✅ Generate Deployment Report - PASSED
```

**In Deployment Report:**
```
📋 Firebase Rules Deployment Report

### Firestore Rules
- Deploy Status: success
- Verify Status: passed

### Storage Rules
- Deploy Status: success
- Verify Status: passed

Deploy Timestamp: 2026-03-25 18:30:45 UTC
```

---

## ⚠️ Common Issues & Fixes

### Issue 1: Workflow Doesn't Appear in Actions

**Problem:**
- "Security - Firebase Rules & Secrets" not visible in Actions tab

**Fix:**
```bash
# 1. Verify file exists
ls .github/workflows/security.yml

# 2. Push to main
git add .github/workflows/security.yml
git commit -m "ci: add firebase rules verification"
git push origin main

# 3. Wait 1-2 minutes
# 4. Hard refresh: Ctrl+Shift+R
# 5. Check Actions tab again
```

### Issue 2: "Missing required GitHub secrets"

**Problem:**
```
❌ Missing required GitHub secrets:
  - FIREBASE_PROJECT_ID
  - FIREBASE_TOKEN
```

**Fix:**
1. Go to GitHub repo settings
2. Click **Secrets and variables → Actions**
3. Verify both secrets exist (not empty)
4. Check spelling exactly:
   - `FIREBASE_PROJECT_ID` (not `FIREBASE_PROJECT_ID`)
   - `FIREBASE_TOKEN` (not `FIREBASE_TOKEN`)
5. Update or recreate if needed

### Issue 3: "Invalid project ID"

**Problem:**
```
Error: Invalid project ID "undefined"
```

**Fix:**
1. Verify secret value is not empty
2. Ensure it's your actual Firebase project ID
3. Example: `paykari-bazar-12345` (not just `paykari-bazar`)

### Issue 4: "ForbiddenError: Missing or insufficient permissions"

**Problem:**
```
Error: Firebase API request failed
ForbiddenError: Missing or insufficient permissions
```

**Fix:**
1. Token may be expired (valid 1 year)
2. Regenerate: `firebase login:ci`
3. Copy new token
4. Update GitHub secret `FIREBASE_TOKEN`
5. Re-run workflow

### Issue 5: "Rules differ" / Verification Failed

**Problem:**
```
❌ Firestore Rules differ (minification/formatting)
```

**Fix (if content differs, not just formatting):**
```bash
# Check local rules
cat firestore.rules

# Compare with deployed
firebase firestore:rules:get --project=paykari-bazar-12345

# If different, redeploy
firebase deploy --only firestore:rules

# Verify again
firebase firestore:rules:get --project=paykari-bazar-12345 > test.txt
diff firestore.rules test.txt
```

---

## 📊 Verification Commands (Local Testing)

```bash
# 1. Test Firebase project connection
firebase projects:list

# 2. Validate rules syntax
firebase validate --project=paykari-bazar-12345

# 3. Deploy rules (one-time)
firebase deploy --only firestore:rules,storage --project=paykari-bazar-12345

# 4. Verify deployment
firebase firestore:rules:get --project=paykari-bazar-12345
firebase storage:rules:get --project=paykari-bazar-12345

# 5. Compare (should be identical or only formatting differs)
firebase firestore:rules:get --project=paykari-bazar-12345 > deployed.txt
diff firestore.rules deployed.txt
```

---

## ✅ Final Verification

Run this command to generate a summary:

```bash
# Windows (PowerShell)
Write-Host "GitHub Secrets Status:"
Write-Host "- FIREBASE_PROJECT_ID: [Check in GitHub UI]"
Write-Host "- FIREBASE_TOKEN: [Check in GitHub UI]"
Write-Host ""
Write-Host "Local Rules Files:"
Test-Path "firestore.rules" | ForEach-Object { if($_) { Write-Host "✅ firestore.rules exists" } else { Write-Host "❌ firestore.rules missing" } }
Test-Path "storage.rules" | ForEach-Object { if($_) { Write-Host "✅ storage.rules exists" } else { Write-Host "❌ storage.rules missing" } }
Write-Host ""
Write-Host "Workflow File:"
Test-Path ".github/workflows/security.yml" | ForEach-Object { if($_) { Write-Host "✅ security.yml exists" } else { Write-Host "❌ security.yml missing" } }

# macOS/Linux (Bash)
echo "GitHub Secrets Status:"
echo "- FIREBASE_PROJECT_ID: [Check in GitHub UI]"
echo "- FIREBASE_TOKEN: [Check in GitHub UI]"
echo ""
echo "Local Rules Files:"
[ -f "firestore.rules" ] && echo "✅ firestore.rules exists" || echo "❌ firestore.rules missing"
[ -f "storage.rules" ] && echo "✅ storage.rules exists" || echo "❌ storage.rules missing"
echo ""
echo "Workflow File:"
[ -f ".github/workflows/security.yml" ] && echo "✅ security.yml exists" || echo "❌ security.yml missing"
```

---

## 🚀 Deployment Verification Flow

```
┌─────────────────────────────────────────┐
│  Changes to firestore/storage rules     │
│  or firebase.json                       │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  GitHub receives push                   │
│  Triggers: security.yml workflow        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Validate Secrets Exist                 │
│  ✅ FIREBASE_PROJECT_ID                 │
│  ✅ FIREBASE_TOKEN                      │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Validate Rules Syntax                  │
│  ✅ Firestore rules format              │
│  ✅ Storage rules format                │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Deploy to Firebase                     │
│  📤 Firestore rules → Firebase          │
│  📤 Storage rules → Firebase            │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Verify Deployment                      │
│  ✅ Get deployed Firestore rules        │
│  ✅ Compare with local version          │
│  ✅ Get deployed Storage rules          │
│  ✅ Compare with local version          │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Generate Report                        │
│  📋 Posted to GitHub Actions summary    │
│  ✅ All steps passed                    │
└─────────────────────────────────────────┘
```

---

## 📞 Quick Reference

| Task | Command |
|------|---------|
| Check secrets | GitHub → Settings → Secrets and variables |
| Generate token | `firebase login:ci` |
| Run workflow | GitHub → Actions → Run workflow |
| View logs | GitHub → Actions → [workflow name] → [run] |
| Test locally | `firebase deploy --only firestore:rules,storage` |
| Verify deployed | `firebase firestore:rules:get --project=PROJECT_ID` |

---

**Next:** Once verified, update [RELEASE_QUICK_REFERENCE.md](RELEASE_QUICK_REFERENCE.md) with status ✅
