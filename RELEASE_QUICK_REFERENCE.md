# ⚡ GitHub Release - Quick Reference Card

## 🎯 One-Command Release

```powershell
.\scripts\release.bat 1.0.0
```

Done! GitHub Actions builds APKs automatically.

---

## 📊 What Gets Built

| App | File |
|-----|------|
| 🛍️ Customer | `paykari_bazar_customer_v1.0.0.apk` |
| 🏢 Admin | `paykari_bazar_admin_v1.0.0.apk` |

---

## ⏱️ Timeline

| Step | Time | Status |
|------|------|--------|
| Push tag | 1 sec | ✅ |
| GitHub receives | 2-5 sec | ✅ |
| Pre-checks | 2-3 min | ⏳ |
| Build Customer APK | 5-10 min | ⏳ |
| Build Admin APK | 5-10 min | ⏳ |
| Create Release | 1-2 min | ⏳ |
| **Total** | **15-25 min** | ✅ Done |

---

## 🔗 Where to Find Downloads

After build completes:

```
https://github.com/YOUR_USERNAME/paykari_bazar/releases/v1.0.0
```

Both APK files will be there as attachments.

---

## 📱 Install on Phone

1. Download APK to phone
2. Settings → Security → Unknown Sources
3. Open Downloads → Tap APK
4. Install
5. Open app

---

## 🆚 Version Numbers

```
0.1.0  ← First test release
1.0.0  ← First production
1.0.1  ← Bug fix
1.1.0  ← New feature
2.0.0  ← Major version
```

---

## 🔍 Check Status

**GitHub Actions:** 
```
https://github.com/YOUR_USERNAME/paykari_bazar/actions
```

Look for green ✅ checkmark = Success

---

## 🆘 Troubleshoot

| Problem | Solution |
|---------|----------|
| Tag error | Make sure code is committed first |
| Build fails | Check GitHub Actions log for error |
| APK not found | Wait 30 sec, refresh page |
| Can't install APK | Enable "Unknown Sources" in phone settings |

---

## 📝 Commit Before Release

```powershell
git status
git add .
git commit -m "Ready for v1.0.0"
```

---

## ✅ Steps checklist

```
[ ] All code committed
[ ] Run: .\scripts\release.bat 1.0.0
[ ] Type 'y' to confirm
[ ] Wait for GitHub Actions (15-25 min)
[ ] Download APKs from release page
[ ] Test on phone
[ ] Share release link with team
```

---

## 🎉 That's It!

Your releases are now fully automated!

**Questions?** See full docs: `GITHUB_RELEASE_GUIDE.md`
