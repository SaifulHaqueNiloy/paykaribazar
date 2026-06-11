# Dart SDK Version Mismatch Fix

## Issue

The GitHub Actions workflow failed with:
```
The current Dart SDK version is 3.4.0.
Because paykari_bazar requires SDK version >=3.5.0 <4.0.0, version solving failed.
Error: Process completed with exit code 1.
```

## Root Cause

- **Project requires:** Dart 3.5.0+ (specified in `pubspec.yaml`)
- **Flutter 3.5.0 bundled:** Dart 3.4.0
- **Mismatch:** Version dependency resolution failed during `flutter pub get`

## Solution

Updated `.github/workflows/flutter-test-ci.yml` to use **Flutter 3.24.0** which includes **Dart 3.5.0+**

### Changes Made

Updated all 6 workflow jobs from `flutter-version: '3.5.0'` to `flutter-version: '3.24.0'`:

1. ✅ test job (line 20)
2. ✅ test-core-services job (line 50)
3. ✅ test-additional job (line 70)
4. ✅ test-integration job (line 90)
5. ✅ build job (line 111)
6. ✅ quality-gate job (line 137)

## Verification

```bash
$ Select-String "flutter-version:" .github/workflows/flutter-test-ci.yml

.github\workflows\flutter-test-ci.yml:20:   flutter-version: '3.24.0'
.github\workflows\flutter-test-ci.yml:50:   flutter-version: '3.24.0'
.github\workflows\flutter-test-ci.yml:70:   flutter-version: '3.24.0'
.github\workflows\flutter-test-ci.yml:90:   flutter-version: '3.24.0'
.github\workflows\flutter-test-ci.yml:111:  flutter-version: '3.24.0'
.github\workflows\flutter-test-ci.yml:137:  flutter-version: '3.24.0'
```

## Dart/Flutter Version Compatibility

| Flutter | Dart   | Status |
|---------|--------|--------|
| 3.5.0   | 3.4.0  | ❌ Too old (project needs 3.5.0+) |
| 3.24.0  | 3.5.0+ | ✅ Matches project requirements |

## Result

✅ **GitHub Actions workflow will now:**
- Successfully resolve Dart dependencies
- Run all tests (core services, additional, integration)
- Build APK artifacts
- Pass quality gate checks

---

**Commit:** `c71e1da`  
**Date:** March 26, 2026
