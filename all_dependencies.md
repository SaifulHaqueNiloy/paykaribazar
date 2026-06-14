# Project Dependencies Analysis

This document lists all direct and development dependencies used in the **Paykari Bazar** project (root `pubspec.yaml`), grouped by functionality.

---

## 1. Core & Architecture

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`flutter_riverpod`** | `^2.6.1` | State management and dependency injection. | Riverpod is already excellent for this project. | Update to `^2.8.0` (latest stable 2.x). Consider Riverpod 3.x for major improvements (breaking changes). |
| **`go_router`** | `^14.2.0` | Declarative routing for Flutter. | | No newer version. Alternatives: **AutoRoute**, vanilla navigator. |
| **`get_it`** | `^8.0.2` | Service locator for accessing services. | | Update to `^8.2.0`. Alternative: Can be replaced entirely by Riverpod providers if desired. |
| **`intl`** | `^0.19.0` | Internationalization, formatting dates/numbers. | Standard package. | No newer version. |
| **`cupertino_icons`** | `^1.0.8` | iOS style icons. | Standard package. | Update to `^1.0.9`. |

---

## 2. Firebase Integration

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`firebase_core`** | `^3.2.0` | Core Firebase SDK initialization. | Required for Firebase. | No newer version. |
| **`firebase_auth`** | `^5.1.1` | User authentication (email, google, fb). | | No newer version. Alternatives: Supabase Auth, custom OAuth. |
| **`cloud_firestore`** | `^5.0.2` | Cloud NoSQL database. | | No newer version. Alternatives: Supabase, Appwrite, custom backend. |
| **`firebase_database`** | `^11.0.2` | Real-time database. | | No newer version. Alternatives: WebSockets, Supabase Realtime. |
| **`firebase_storage`** | `^12.1.1` | Cloud storage for images/files. | | No newer version. Alternatives: AWS S3, Cloudinary. |
| **`firebase_messaging`** | `^15.0.2` | Push notifications. | | No newer version. Alternative: OneSignal. |
| **`firebase_analytics`** | `^11.1.1` | Analytics and user behavior tracking. | | No newer version. Alternatives: Mixpanel, Amplitude. |
| **`firebase_crashlytics`** | `^4.0.2` | Crash reporting. | Sentry (already using). | No newer version. Consider consolidating error reporting to a single service (e.g., Sentry). |
| **`firebase_remote_config`**| `^5.5.0` | Dynamic flag/config updates. | | No newer version. Alternatives: Flagsmith, Unleash. |
| **`firebase_app_check`** | `^0.3.2+10` | App integrity and security. | Required to prevent abuse. | No newer version. |

---

## 3. UI, Animations & Layouts

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`google_fonts`** | `^6.3.0` | Dynamically loading fonts. | | No newer version. Alternative: Use local assets for better offline performance/privacy. |
| **`cached_network_image`**| `^3.3.1` | Multi-platform image caching. | Standard. | No newer version. |
| **`shimmer`** | `^3.0.0` | Shimmer effect during loading states. | | No newer version. Alternative: Custom painters for simpler effects. |
| **`lottie`** | `^3.1.2` | Vector animation rendering. | | No newer version. Alternative: Rive (more interactive, potentially smaller files). |
| **`badges`** | `^3.1.2` | Notification badges (e.g., cart item count).| | No newer version. Alternative: Custom widget (very simple to write). |
| **`carousel_slider`** | `^5.0.0` | Slideshows / Banners. | | No newer version. Alternative: `PageView` widget. |
| **`photo_view`** | `^0.15.0` | Zoomable image viewing. | | No newer version. Alternative: Custom gesture detector for basic zoom. |
| **`flutter_widget_from_html`**| `^0.15.1` | Render HTML strings as Flutter widgets. | | No newer version. Alternative: `flutter_html`. |

---

## 4. Security & Storage

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`local_auth`** | `^2.1.6` | Biometric authentication (fingerprint/FaceID).| Required for biometrics. | Update to `^2.2.0`. |
| **`flutter_secure_storage`**| `^9.0.0` | Secure key-value storage (Keychain/Keystore).| | No newer version. Alternative: Hive (with encrypted box). |
| **`encrypt`** | `^5.0.1` | AES/RSA cryptography for data. | Standard. | No newer version. |
| **`hive`** / **`hive_flutter`** | `^2.2.3` / `^1.1.0` | Fast local key-value database. | | No newer version. Alternatives: **Isar** (newer database by same author, often faster), **sqflite**. |

---

## 5. Media, Documents & Utilities

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`image_picker`** | `^1.1.2` | Selecting photos/videos from gallery/camera. | Standard. | No newer version. |
| **`file_picker`** | `^8.0.6` | Selecting any file type from storage. | Standard. | No newer version. |
| **`photo_manager`** | `^3.3.0` | Advanced gallery asset queries. | Standard. | No newer version. |
| **`pdf`** / **`printing`** | `^3.10.8` / `^5.11.1` | Generating and printing PDF documents. | Standard. | No newer version. |
| **`widgets_to_image`** | `^2.0.1` | Capture any Flutter widget as an image. | Standard. | No newer version. |
| **`audioplayers`** | `^6.0.0` | Playing local/remote audio assets. | | No newer version. Consider consolidating with `just_audio` if `just_audio` is preferred for high-fidelity playback. |
| **`just_audio`** | `^0.9.46` | High-fidelity audio playback. | Duplicate of `audioplayers` functionality. | No newer version. Consider removing `audioplayers` if `just_audio` meets all needs, or vice-versa, to avoid redundancy. |
| **`record`** | `^6.2.0` | Recording audio from mic. | Standard. | No newer version. |
| **`speech_to_text`** | `^7.3.0` | Voice-to-text transcription. | Standard. | No newer version. |
| **`flutter_local_notifications`**| `^17.2.2` | Displaying local notifications. | Standard. | No newer version. |

---

## 6. Networking & Integration

| Package | Current Version | Purpose | Alternatives / Notes | Suggestion (Better Version / Alternative) |
| :--- | :--- | :--- | :--- | :--- |
| **`dio`** | `^5.5.0+1` | Advanced HTTP client. | | No newer version. Consider removing `http` if `dio` meets all needs, to avoid redundancy. |
| **`http`** | `^1.2.0` | Basic HTTP client. | Duplicate of `dio` functionality. | No newer version. Consider removing `http` if `dio` is the primary HTTP client. |
| **`connectivity_plus`** | `^6.0.3` | Monitor network connection status. | Standard. | No newer version. |
| **`url_launcher`** | `^6.3.0` | Opening web URLs, phone dialer, emails. | Standard. | No newer version. |
| **`google_generative_ai`**| `^0.4.3` | Gemini API integration. | Standard. | No newer version. |
| **`google_maps_flutter`** | `^2.7.0` | Interactive map rendering. | | No newer version. Alternative: **flutter_map** (OpenStreetMap, free/no API key required). |
| **`geolocator`** | `^12.0.0` | Accessing GPS location coordinates. | Standard. | No newer version. |
| **`sentry_flutter`** | `^9.13.0` | Error reporting and tracking. | Firebase Crashlytics. | No newer version. Consider consolidating error reporting to a single service (e.g., Sentry). |
| **`flutter_dotenv`** | `^5.1.0` | Reading environment variables from `.env`.| Standard. | No newer version. |
