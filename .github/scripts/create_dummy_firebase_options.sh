#!/bin/bash
# This script creates a dummy firebase_options.dart file for CI builds
# if it does not already exist.

TARGET_FILE="lib/firebase_options.dart"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Generating dummy firebase_options.dart for CI..."
  mkdir -p lib
  cat << 'EOF' > "$TARGET_FILE"
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy',
    appId: 'dummy',
    messagingSenderId: 'dummy',
    projectId: 'dummy',
    storageBucket: 'dummy',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy',
    appId: 'dummy',
    messagingSenderId: 'dummy',
    projectId: 'dummy',
    storageBucket: 'dummy',
    iosBundleId: 'dummy',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dummy',
    appId: 'dummy',
    messagingSenderId: 'dummy',
    projectId: 'dummy',
    authDomain: 'dummy',
    storageBucket: 'dummy',
  );
}
EOF
  echo "Dummy firebase_options.dart created successfully."
else
  echo "firebase_options.dart already exists. Skipping."
fi
