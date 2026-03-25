# Paykari Bazar - Project-Specific Instructions

This file provides context and rules specifically for the `paykari_bazar` project.

## Immutable Core Rules (STRICT)
- **No Modifications:** DO NOT modify or delete the following core documentation files and folders:
  1. `PROJECT_MASTER_BLUEPRINT.md`
  2. `CORE_FEATURES_RULES.md`
  3. `BACKUP_RULES.md`
  4. `CORE_FEATURES_musthave.md`
  5. `README.md`
  6. `dna/` folder (All files inside are LOCKED).
- **Mandatory Review:** Always read these files BEFORE making any code or configuration changes.
- **Change Log Protocol:** Any update to a LOCKED file must be appended to its `## Change Log` section with Date and Description. Removal of existing lines is strictly prohibited.

## Technical Environment
- **Framework:** Flutter SDK v3.24.0+ (Latest Stable).
- **Native Core:** Kotlin `2.1.0` | Gradle `8.14` | JVM `17`.
- **Java/Kotlin Target:** Mandatory Java 17 for all compatibility levels.
- **Project Structure:** Single Flavor (Standard). Target files are used to distinguish apps.

## Execution Commands
- **Run Customer:** `flutter run -t lib/main_customer.dart`
- **Run Admin:** `flutter run -t lib/main_admin.dart`
- **Build Production:** `flutter build apk -t lib/main_customer.dart --obfuscate --split-debug-info=build/app/outputs/symbols`
- **Shorebird Patch:** `shorebird patch android -t lib/main_customer.dart`

## AI Engine Policy
- **Gemini Rule:** Use ONLY Version 2.0 and above. Gemini 1.5 Pro/Flash is prohibited for project-internal AI features.
- **Routing:** NVIDIA (Kimi-k2.5) > DeepSeek > Gemini 2.0.

## Coding Style & Design
- **Theme Colors:** Primary Teal `#008080`, Accent `#FFC107`, Dark BG `#0F172A`, Light BG `#F0F2F5`.
- **Grid Rule:** Adaptive Grid (2, 3, or 4 columns) as per User Preference.
- **Floating Cart:** Persistent bubble showing `Items | Price`.
- **Firestore Schema:** Adhere to the defined schemas in `PROJECT_MASTER_BLUEPRINT.md`.

## Language
- Support Bangla, English, and Banglish (Phonetic Mapping) in UI and Search logic.
