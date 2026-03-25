https://console.firebase.google.com/project/paykari-bazar-a19e7/overview
https://paykari-bazar-a19e7.web.app


একটি ছোট টিপস:
কমান্ডটি দেওয়ার আগে নিশ্চিত হয়ে নিন যে আপনার সব লেটেস্ট কোড গিটহাবে পুশ করা আছে:
1.
git add .
2.
git commit -m "Ready for release"
3.
git push origin main
4.
তারপর: .\scripts\release.bat 1.0.0+3
সারকথা: হ্যাঁ, এটিই আপনার প্রজেক্টের জন্য রিলিজ করার "ম্যাজিক কমান্ড"! 🎉

ƒÆí Next Steps:
=============================================================================

1. Watch GitHub Actions:
   ≡ƒöù https://github.com/YOUR_USERNAME/paykari_bazar/actions

2. After build completes (~20 min):
   ΓÇó Download APKs from Releases page
   ΓÇó Transfer to your phone
   ΓÇó Install and test both apps

3. Share release with your team:
   ≡ƒöù https://github.com/YOUR_USERNAME/paykari_bazar/releases/v1.0.0+



WITHOUT FLAVOR
flutter build web 	
firebase deploy --only hosting
shorebird patch --platforms=android --release-version=1.0.0+2

flutter build web
firebase deploy --only hosting
shorebird release android --flutter-version=3.41.4 --artifact apk -- --target-platform android-arm64

flutter build appbundle --release --target-platform=android-arm,android-arm64,android-x64
shorebird release --platforms=android --flutter-version=3.41.4

input::::
flutter build apk --split-per-abi
output :.........app-armeabi-v7a-release.apk (33.1MB).....app-arm64-v8a-release.apk (34.5MB).........app-x86_64-release.apk (36.0MB)

flutter build web -t lib/main_admin.dart --release
if (Test-Path build/web_admin) { Remove-Item -Recurse -Force build/web_admin }
move build/web build/web_admin
firebase deploy --only hosting:admin

shorebird release android --artifact apk -- --target-platform android-arm64

WITH FLAVOR..................................................................................................................................

#web....................................
flutter build web -t lib/main_customer.dart --release
#if (Test-Path build/web_customer) { Remove-Item -Recurse -Force build/web_customer }
move build/web build/web_customer
firebase deploy --only hosting:customer
flutter build web -t lib/main_admin.dart --release
#if (Test-Path build/web_admin) { Remove-Item -Recurse -Force build/web_admin }
move build/web build/web_admin
firebase deploy --only hosting:admin

#shorebird ................................
copy shorebird_customer.yaml shorebird.yaml
shorebird release android -t lib/main_customer.dart --artifact apk -- --target-platform android-arm64
Move-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "build/app/outputs/flutter-apk/customer-release.apk" -Force
shorebird preview -t lib/main_customer.dart
copy shorebird_admin.yaml shorebird.yaml
shorebird release android -t lib/main_admin.dart --artifact apk -- --target-platform android-arm64
Move-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "build/app/outputs/flutter-apk/admin-release.apk" -Force
shorebird preview -t lib/main_admin.dart

only apk release..............................................
"scripts": {
  "release-admin": "shorebird release android -t lib/main_admin.dart --artifact apk -- --target-platform android-arm64 && mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/admin-release.apk",
  "release-customer": "shorebird release android -t lib/main_customer.dart --artifact apk -- --target-platform android-arm64 && mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/customer-release.apk",
  "deploy-apps": "node server.js"
}



Patch...........................................................
copy shorebird_customer.yaml shorebird.yaml
shorebird patch android -t lib/main_customer.dart --release-version=1.0.0+1

copy shorebird_admin.yaml shorebird.yaml
shorebird patch android -t lib/main_admin.dart --release-version=2.0.0+1

flutter build apk -t lib/main_customer.dart --obfuscate --split-debug-info=build/app/outputs/symbols


git push..........................................................
git status
git add .
git commit -m "Updated Encryption service and fixed Cache service errors"
git push origin main

flutter error find............................................
flutter clean;flutter pub get;flutter analyze | Select-String -Pattern "^  error"

check...................................................
flutter test 2>&1 > test_results.txt; type test_results.txt | Select-Object -First 150

+  Deploy complete!

Project Console: https://console.firebase.google.com/project/paykari-bazar-a19e7/overview
Hosting URL: https://paykari-bazar-a19e7.web.app
Hosting URL: https://paykari-bazar-admin.web.app
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/SaifulHaqueNiloy/paykaribazar.git
 * [new tag]         v1.0.0 -> v1.0.0
PS C:\Users\Nazifa\paykari_bazar>

powershell
# 1. Clean previous builds to avoid conflicts
flutter clean

# 2. Build the web app
flutter build web -t lib/main_customer.dart --release

# 3. Remove existing folder if it exists (Ensures 'move' works)
if (Test-Path build/web_customer) { Remove-Item -Recurse -Force build/web_customer }

# 4. Move to the target folder
move build/web build/web_customer

# 5. Deploy to Firebase
firebase deploy --only hosting:customer


