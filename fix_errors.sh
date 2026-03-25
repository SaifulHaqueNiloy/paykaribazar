#!/bin/bash

# 1. Clean up (Optional but recommended)
rm -f pubspec.lock

# 2. Get dependencies
# Note: integration_test and mockito are already in pubspec.yaml
flutter pub get

# 3. Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Analyze again
flutter analyze
