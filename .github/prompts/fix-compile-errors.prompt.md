---
description: "Diagnose and fix the 16 compilation errors in Paykari Bazar. Run the automated fix script, analyze error output, and suggest targeted fixes."
name: "Fix Compile Errors"
argument-hint: "Optional: specific error module or file to focus on"
agent: "agent"
tools: ["run_in_terminal", "read_file", "replace_string_in_file"]
---

# Fix Paykari Bazar Compilation Errors

Paykari Bazar currently has 16 compilation errors preventing builds. This prompt helps diagnose and fix them.

## Step 1: Run Automated Fix Script

The fastest solution is to use the built-in fix script:

```bash
./fix_errors.sh
```

This script handles:
- Code generation via build_runner
- Conflicting output cleanup
- Common Flutter/Dart lint issues

## Step 2: If That Fails, Diagnose Manually

Run Flutter analyze to get detailed error output:

```bash
flutter analyze
```

Common error patterns:

| Error Pattern | Likely Cause | Fix |
|---------------|--------------|-----|
| `CartState not found` | Missing export in commerce module | Add to `lib/src/features/commerce/exports.dart` |
| `FutureProvider<X> not defined` | Riverpod provider registration incomplete | Register in `lib/src/di/providers.dart` |
| `Unimplemented service` | Service interface without implementation | Implement stubs: CartPosService, CouponService, GeofencingService, CompassService |
| `Firebase initialization order` | DI phase dependency issue | Check `lib/src/app_bootstrap.dart` phase sequence |
| `import not found` | Conflicting build_runner output | Delete `build/`, run `flutter pub get`, rebuild |

## Step 3: Verify Specific Module

If you know which module is failing:

1. **Commerce module** (`lib/src/features/commerce/`):
   - Check all classes exported in `exports.dart`
   - Verify `CartService` and `CartState` are defined

2. **AI module** (`lib/src/features/ai/`):
   - Verify `AIService`, `AICacheService`, `AIRateLimiter` are exported
   - Check Riverpod providers in DI

3. **Logistics module** (`lib/src/features/logistics/`):
   - `GeofencingService` is currently a stub—implement or remove references

4. **Admin module** (`lib/src/features/admin/`):
   - Separate router configuration in `router_admin.dart`

## Step 4: Run Full Build Test

After fixes, test the build:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run specific app to verify
flutter run -t lib/main_customer.dart
```

## Expected Output

Successful build should show:
- ✓ 0 errors from Flutter analyze
- ✓ Code generation complete (build_runner)
- ✓ App launches without crashes
- ✓ Both customer and admin apps run (with `-t` flag)

## Need More Help?

If errors persist:
1. Check [FEATURE_STATUS_CHECK.md](../FEATURE_STATUS_CHECK.md) for which features are stubbed
2. Review [APP_STRUCTURE_EXPLORATION.md](../APP_STRUCTURE_EXPLORATION.md) for expected modules
3. Check `.github/instructions/` for module-specific guidelines

**Status target:** Reduce from 16 → 0 errors before next release.
