# Local Development Checklist & Pre-Commit Validation

## Quick Reference

Before pushing code, run these checks to ensure CI/CD passes:

### ⚡ 30-Second Check
```bash
# Run all tests
flutter test test/

# Check code quality
flutter analyze
```

### ☑️ Full Pre-Commit Checklist
```bash
# 1. Get dependencies
flutter pub get

# 2. Generate code (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run all tests
flutter test test/ --coverage

# 4. Check code quality
flutter analyze

# 5. Format code
dart format lib/ test/

# 6. Push to GitHub
git push
```

---

## Detailed Validation Steps

### 1️⃣ Dependency Check

**Why:** Missing or outdated dependencies cause build failures

```bash
# Get all dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Fix security vulnerabilities
flutter pub upgrade
```

**Expected Output:**
```
Running "flutter pub get" in paykari_bazar...
Running pub upgrade...
Got dependencies!
```

---

### 2️⃣ Code Generation

**Why:** `build_runner` generates code for Freezed, Riverpod, JSON serialization

```bash
# Full clean build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (useful during development)
flutter pub run build_runner watch
```

**Expected Output:**
```
[INFO] Building executable...
[INFO] Precompiling executable...
[INFO] Succeeded after...
```

**Common Issues:**
- ❌ `Could not find target "main"` → Use `-t lib/main_customer.dart`
- ❌ `Time out` → Already running in another terminal, kill it first
- ❌ `Conflicting outputs` → Use `--delete-conflicting-outputs` flag

---

### 3️⃣ Test Suite Validation

**Why:** GitHub Actions runs tests; ensure they pass locally first

```bash
# Run entire test suite (all 398 tests)
flutter test test/ --coverage

# Run specific test suites
flutter test test/core_services/          # 52 tests
flutter test test/additional/             # 39 tests
flutter test test/integration/            # 30 tests
flutter test test/core_services/ai_service_test.dart  # Single file

# Run with verbose output
flutter test test/ -v

# Run with machine-readable output
flutter test test/ --machine > test_results.json
```

**Expected Results:**
- Core Services: ✅ 52 passed
- Additional: ✅ 39 passed  
- Integration: ✅ 30 passed
- **Total: ✅ 398+ passed**

**Test Execution Timeline:**
- All tests: ~8-10 minutes
- Core services: ~2 minutes
- Additional: ~1.5 minutes
- Integration: ~1 minute

---

### 4️⃣ Code Quality Analysis

**Why:** Flutter analyzer catches typing issues, unused variables, best practice violations

```bash
# Run analyzer
flutter analyze

# Run with detail
flutter analyze --detailed-exit-code

# Format check (without modifying)
dart format --line-length 100 lib/ test/ --set-exit-if-changed
```

**Expected Output:**
```
Analyzing paykari_bazar...
No issues found!
```

**Common Issues:**
- ⚠️ Unused imports → Run `dart format`
- ⚠️ Type issues → Check variable declarations
- ⚠️ Missing null safety → Add `?` or `!`

---

### 5️⃣ Code Formatting

**Why:** Consistent formatting prevents merge conflicts and improves readability

```bash
# Format all code
dart format lib/ test/ --line-length 100

# Check format without modifying
dart format lib/ test/ --set-exit-if-changed

# Format specific file
dart format lib/src/features/auth/auth_service.dart
```

**Config (in `analysis_options.yaml`):**
```yaml
dart_format:
  line_length: 100
```

---

## 🤖 Automated Pre-Commit Hook Setup

### Option A: Git Hooks (Manual)

#### Create `.git/hooks/pre-commit`

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Running pre-commit checks...${NC}"

# Check 1: Dependencies
echo -e "${YELLOW}1️⃣  Checking dependencies...${NC}"
flutter pub get > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Dependency check failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dependencies OK${NC}"

# Check 2: Code generation
echo -e "${YELLOW}2️⃣  Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Code generation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Code generation OK${NC}"

# Check 3: Code analysis
echo -e "${YELLOW}3️⃣  Running code analysis...${NC}"
flutter analyze --no-pub
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Code analysis failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Code analysis OK${NC}"

# Check 4: Code formatting
echo -e "${YELLOW}4️⃣  Checking code format...${NC}"
dart format lib/ test/ --set-exit-if-changed > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Code formatting check failed (run 'dart format lib/ test/')${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Code format OK${NC}"

# Check 5: Run tests
echo -e "${YELLOW}5️⃣  Running tests (this may take a few minutes)...${NC}"
flutter test test/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ All tests passed${NC}"

echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
echo -e "${YELLOW}Proceeding with commit...${NC}"
exit 0
```

#### Make Executable

```bash
chmod +x .git/hooks/pre-commit
```

#### Test Hook

```bash
# Run manually to test
./.git/hooks/pre-commit

# Or make a commit to trigger
git add .
git commit -m "test: trigger pre-commit hook"
```

### Option B: Husky (NPM-based)

```bash
# Install husky
npm install husky --save-dev

# Initialize husky
npx husky install

# Create pre-commit hook
npx husky add .husky/pre-commit "flutter test test/"
```

### Option C: Skip Pre-Commit (Emergency Only)

```bash
# Push without running pre-commit hook
git commit --no-verify

# Or skip entirely
git push --no-verify
```

---

## 📋 Complete Workflow Example

### Scenario: Adding New Feature

```bash
# 1. Create feature branch
git checkout -b feature/new-dashboard

# 2. Make changes
# ... edit files ...

# 3. Stage changes
git add lib/src/features/dashboard/

# 4. Run local checks
flutter test test/               # Test immediately
flutter analyze                  # Check quality
dart format lib/src/features/    # Format code

# 5. Commit
git commit -m "feat: add new dashboard"

# 6. Pre-commit hook runs automatically:
#    ✅ Dependencies checked
#    ✅ Code generated
#    ✅ Analysis passed
#    ✅ Formatting verified
#    ✅ All tests passed

# 7. Push to GitHub
git push origin feature/new-dashboard

# 8. GitHub Actions automatically:
#    ✅ Runs full test suite
#    ✅ Builds APK
#    ✅ Runs quality checks
#    ✅ Generates coverage report
#    ✅ Uploads artifacts
```

---

## 🚨 Common Issues & Solutions

### Issue: "flutter test" Hangs

**Problem:** Test timeout or infinite wait

**Solutions:**
```bash
# Run with timeout
flutter test test/ --timeout 60

# Kill hanging processes
pkill -f dart
pkill -f flutter

# Run single test file
flutter test test/core_services/ai_service_test.dart
```

### Issue: "flutter analyze" Reports Too Many Errors

**Problem:** Stale analysis cache

**Solutions:**
```bash
# Clear analysis cache
rm -rf .dart_tool/

# Rebuild
flutter pub get
flutter analyze
```

### Issue: Tests Pass Locally but Fail in CI/CD

**Possible causes:**
- Different Dart version
- Platform-specific code (Linux vs macOS)
- Race conditions in async code

**Debugging:**
```bash
# Install same Flutter version as CI/CD
flutter --version

# Run tests with extra logging
flutter test test/ -v

# Check for flaky tests
flutter test test/ --repeat=5
```

### Issue: Code Format Keeps Changing

**Problem:** Different line length settings

**Solutions:**
```bash
# Check formatter config
cat analysis_options.yaml | grep line_length

# Format consistently
dart format lib/ test/ --line-length 100

# Add to pre-commit hook
```

### Issue: "No such file or directory" in Pre-Commit Hook

**Problem:** Path issues on Windows vs macOS/Linux

**Solutions:**
```bash
# Use cross-platform path
#!/bin/bash
BASEDIR=$(cd "$(dirname "$0")/../.." && pwd)
cd "$BASEDIR"

# Or use simpler approach
flutter test test/
```

---

## ⏱️ Expected Execution Times

| Task | Duration | Notes |
|------|----------|-------|
| `flutter pub get` | 30 sec | First time slower |
| `build_runner build` | 1-2 min | Only if code changes |
| `flutter test test/` | 8-10 min | Full suite |
| `flutter analyze` | 1 min | Quick check |
| `dart format` | 30 sec | Formatting check |
| **Total (pre-commit)** | **12-15 min** | Run during lunch! |

---

## 🎯 Best Practices

### ✅ DO:

1. **Run tests before pushing**
   ```bash
   flutter test test/
   ```

2. **Keep pre-commit hooks fast** (optional)
   - Run only critical checks locally
   - Full validation in GitHub Actions

3. **Format code regularly**
   ```bash
   dart format lib/ test/
   ```

4. **Check for unused imports**
   ```bash
   flutter analyze
   ```

5. **Use meaningful commit messages**
   ```bash
   git commit -m "feat: add user authentication"
   ```

### ❌ DON'T:

1. **Push without testing**
   - CI/CD will fail
   - Wastes time

2. **Hardcode secrets**
   - Use `.env` files
   - Use GitHub Secrets

3. **Commit large files**
   - Use `.gitignore`
   - Store in Firebase Storage instead

4. **Ignore analyzer warnings**
   - Fix them now, not later
   - Prevents bugs

5. **Skip pre-commit checks**
   ```bash
   # ❌ DON'T do this:
   git push --no-verify
   
   # ✅ DO fix the issue instead
   flutter test test/
   ```

---

## 📊 Status Dashboard

### Current CI/CD Setup

| Component | Status | Details |
|-----------|--------|---------|
| **GitHub Actions** | ✅ Ready | `.github/workflows/flutter-test-ci.yml` |
| **Test Suite** | ✅ 398 tests | All passing |
| **Code Quality** | ✅ Passing | 0 analyzer warnings |
| **Coverage** | ✅ Active | Codecov integration |
| **Build Artifacts** | ✅ Auto | APK generated per build |
| **Pre-Commit Hooks** | 📝 Optional | Setup guide above |

---

## 🔗 Related Documents

- [CI_CD_SETUP_GUIDE.md](CI_CD_SETUP_GUIDE.md) - Full CI/CD configuration
- [FINAL_TEST_COVERAGE_REPORT.md](FINAL_TEST_COVERAGE_REPORT.md) - Complete test metrics
- [README.md](README.md) - Project overview

---

**Last Updated:** GitHub Actions workflow committed  
**Next Step:** Push code to GitHub to trigger workflow!
