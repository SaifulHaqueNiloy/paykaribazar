# 🔍 Duplicate / Empty / Stub File Audit

Generated: 2026-06-15

## Empty Files (0 bytes)
| Path | Notes |
|------|-------|
| `ai_response_cache.lock` | Lock file, safe to ignore |
| `app_cache_box.hive` | Cache file, safe to ignore |
| `stderr.txt` | Likely build artifact |
| `docs/logs/analysis_results.txt` | Empty log file |

## Stub/Deprecated Files (< 100 bytes, non-functional)
| Path | Size | Content Summary |
|------|------|-----------------|
| `lib/src/features/delivery/delivery_dashboard_screen.dart` | 79 B | `// DEPRECATED: Duplicate of lib/src/features/delivery/delivery_dashboard.dart` |
| `lib/src/features/staff/staff_team_screen.dart` | 77 B | `// DEPRECATED: Duplicate of lib/src/features/profile/staff_team_screen.dart` |
| `lib/src/features/products/widgets/product_widgets.dart` | 94 B | Single re-export: `export 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart' show ProductCard;` |
| `lib/src/core/extensions.dart` | 99 B | Single re-export: `export 'extensions/map_extensions.dart';` + comment |
| `paykari_bazar/lib/main.dart` | 83 B | Redirect stub: `export 'main_customer.dart';` |
| `paykari_bazar_admin/lib/main.dart` | 77 B | Redirect stub: `export 'main_admin.dart';` |
| `paykari_bazar_admin/lib/main_admin.dart` | 59 B | `// DEPRECATED: Moved to paykari_bazar/lib/main_admin.dart` |
| `paykari_bazar/test/widget_test.dart` | 66 B | `// Deprecated: Use logic-based tests in coupon_service_test.dart` |

## Exact Duplicate Files
| File A | File B | Size | Notes |
|--------|--------|------|-------|
| `test/widget_test.dart` | `test/widgets/widget_test.dart` | 391 B each | Identical content — both import `main_customer.dart` and test `CustomerApp` |

## Recommendations
1. **Delete deprecated stubs**: Remove files marked `DEPRECATED` that have been superseded by canonical implementations
2. **Consolidate test duplicates**: Keep one of the duplicate `widget_test.dart` files, delete the other
3. **Consider re-exports**: The re-export stubs (`extensions.dart`, `product_widgets.dart`) could be folded into their target files or kept as convenience aliases
4. **Add to `.gitignore`**: Empty cache/lock files (`ai_response_cache.lock`, `app_cache_box.hive`, `stderr.txt`) should be gitignored if not already
