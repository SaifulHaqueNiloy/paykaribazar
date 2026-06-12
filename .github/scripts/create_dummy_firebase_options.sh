#!/bin/bash
# This script creates dummy files for CI builds if they do not already exist.

# 1. Create dummy firebase_options.dart
TARGET_DART_FILE="lib/firebase_options.dart"
if [ ! -f "$TARGET_DART_FILE" ]; then
  echo "Generating dummy firebase_options.dart for CI..."
  mkdir -p lib
  cat << 'EOF' > "$TARGET_DART_FILE"
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
    apiKey: 'AIzaSyBoOeByDeSXM9HJAQm4JQw23GEs0wHgXac',
    appId: '1:1081673908768:android:004d7251718ac85f547245',
    messagingSenderId: '1081673908768',
    projectId: 'paykari-bazar-a19e7',
    databaseURL: 'https://paykari-bazar-a19e7-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'paykari-bazar-a19e7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYR4YdX3eWGZMvce7mPYasD_BNrEwNi4E',
    appId: '1:1081673908768:ios:fdb0e402954656e3547245',
    messagingSenderId: '1081673908768',
    projectId: 'paykari-bazar-a19e7',
    databaseURL: 'https://paykari-bazar-a19e7-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'paykari-bazar-a19e7.firebasestorage.app',
    iosBundleId: 'com.example.paykariBazar',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyApWFRK_CbOvvCgdrlQnWmrxo6Hc_hfoq4',
    appId: '1:1081673908768:web:a9f00e4ae6d3ca3e547245',
    messagingSenderId: '1081673908768',
    projectId: 'paykari-bazar-a19e7',
    authDomain: 'paykari-bazar-a19e7.firebaseapp.com',
    databaseURL: 'https://paykari-bazar-a19e7-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'paykari-bazar-a19e7.firebasestorage.app',
    measurementId: 'G-5GGBFKE191',
  );
}
EOF
  echo "Real firebase_options.dart created successfully."
else
  echo "firebase_options.dart already exists. Skipping."
fi

# 2. Create dummy .env file
TARGET_ENV_FILE=".env"
if [ ! -f "$TARGET_ENV_FILE" ]; then
  echo "Generating dummy .env for CI..."
  cat << 'EOF' > "$TARGET_ENV_FILE"
CLOUDINARY_CLOUD_NAME=dummy
CLOUDINARY_API_KEY=dummy
CLOUDINARY_API_SECRET=dummy
CLOUDINARY_UPLOAD_PRESET=dummy
CLOUDINARY_URL=dummy
GEMINI_MASTER_KEY_1=dummy
GEMINI_MASTER_KEY_2=dummy
GEMINI_MASTER_KEY_3=dummy
GEMINI_MASTER_KEY_4=dummy
GEMINI_MASTER_KEY_5=dummy
NVIDIA_API_KEY=dummy
GEMINI_SUPPORT_KEY_1=dummy
GEMINI_SUPPORT_KEY_2=dummy
GEMINI_SUPPORT_KEY_3=dummy
GEMINI_SUPPORT_KEY_4=dummy
GEMINI_SUPPORT_KEY_5=dummy
GEMINI_API_KEY_1=dummy
GEMINI_API_KEY_2=dummy
GEMINI_API_KEY_3=dummy
GEMINI_API_KEY_4=dummy
GEMINI_API_KEY_5=dummy
GROQ_API_KEY_1=dummy
GROQ_API_KEY_2=dummy
DEEPSEEK_API_KEY_1=dummy
DEEPSEEK_API_KEY_2=dummy
HUGGINGFACE_API_KEY_1=dummy
RECRAFT_API_KEY_1=dummy
MAPS_API_KEY=dummy
SENTRY_DSN=dummy
ADMIN_PHONE=dummy
TELEGRAM_BOT_TOKEN=dummy
TELEGRAM_CHAT_ID=dummy
EOF
  echo "Dummy .env created successfully."
else
  echo ".env already exists. Skipping."
fi

# 3. Create dummy google-services.json
TARGET_JSON_FILE="android/app/google-services.json"
if [ ! -f "$TARGET_JSON_FILE" ]; then
  echo "Generating dummy google-services.json for CI..."
  mkdir -p android/app
  cat << 'EOF' > "$TARGET_JSON_FILE"
{
  "project_info": {
    "project_number": "1234567890",
    "project_id": "dummy-project"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1234567890:android:abc123xyz",
        "android_client_info": {
          "package_name": "com.paykaribazar.app"
        }
      },
      "api_key": [
        {
          "current_key": "dummy_key"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF
  echo "Dummy google-services.json created successfully."
else
  echo "google-services.json already exists. Skipping."
fi
