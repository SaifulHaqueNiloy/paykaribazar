# Fastlane Configuration

For production releases, ensure these environment variables are set:

## Android
```bash
export ANDROID_PACKAGE_NAME="com.yourcompany.paykari_bazar"
export ANDROID_JSON_KEY_DATA='{"type":"service_account",...}'  # From Google Play Console
```

## Firebase
```bash
export FIREBASE_TOKEN="your_firebase_token"
export FIREBASE_APP_ID="your_firebase_app_id"
```

## iOS (Optional)
```bash
export ITC_TEAM_ID="your_app_store_team_id"
export FASTLANE_USER="your_apple_id"
export FASTLANE_PASSWORD="your_app_specific_password"
```

## Usage Examples

### Build and Deploy to Firebase (Testers)
```bash
fastlane android deploy_firebase_internal apk_path:build/app/outputs/flutter-apk/app-release.apk notes:"New features added"
```

### Build and Deploy to Play Store (Beta)
```bash
fastlane android deploy_play_store_beta bundle_path:build/app/outputs/bundle/release/app.aab version:1.0.0 notes:"Beta release"
```

### Complete Release Workflow (Auto-bump version + build + deploy)
```bash
# Internal testing
fastlane android release track:internal version:patch

# Beta testing
fastlane android release track:beta version:minor

# Production
fastlane android release track:production version:major
```

### Hotfix (Quick patch release)
```bash
fastlane android hotfix
```

### Get current version
```bash
fastlane android get_version
```

### Bump version only
```bash
fastlane android bump_version type:patch
```

## GitHub Actions Integration

Add to `.github/workflows/release.yml`:

```yaml
- name: Run Fastlane Release
  env:
    ANDROID_PACKAGE_NAME: ${{ secrets.ANDROID_PACKAGE_NAME }}
    ANDROID_JSON_KEY_DATA: ${{ secrets.ANDROID_JSON_KEY_DATA }}
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
    FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID }}
  run: |
    sudo gem install fastlane
    fastlane android release track:beta version:minor
```

## Notes
- Always test locally before deploying to production
- Ensure all tests pass before running release lanes
- Keep `pubspec.yaml` version in sync with app stores
- Store sensitive credentials in GitHub Secrets, not in code
