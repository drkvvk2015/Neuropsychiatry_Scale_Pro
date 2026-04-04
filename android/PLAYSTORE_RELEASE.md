# Google Play Store Release Guide

## What is already configured in this project

- Release signing support via `android/key.properties` (with example template).
- Play/Core dependency required for release minification.
- R8/resource shrinking enabled for release builds.
- Microphone permission declared explicitly.
- App label set to `NeuroScale Pro`.
- Backup/data-extraction disabled to protect local clinical data.
- Cleartext HTTP traffic disabled.

## Current status

- Android toolchain is healthy.
- Release AAB packaging works through Gradle.
- A real upload keystore is still required for Play submission.
- `flutter build appbundle --release` may show a misleading native symbol message on this machine even when Gradle packaging succeeds.

## One-time machine setup (required on this PC)

Your current machine is missing Android SDK cmdline-tools, so release bundle creation is blocked.

1. Open Android Studio.
2. Go to **SDK Manager**.
3. Install:
   - Android SDK Command-line Tools (latest)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
4. In terminal, run:
   - `flutter doctor --android-licenses`
5. Re-run:
   - `flutter doctor -v`
   - Ensure Android toolchain has no errors.

## Release signing setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill real values:
   - storePassword
   - keyPassword
   - keyAlias
   - storeFile
3. Keep keystore and key.properties private (already git-ignored).
4. Release builds are intentionally blocked until this file exists, so Play bundles cannot be accidentally signed with the debug key.

## Build commands

- Validate environment:
  - `flutter doctor -v`
- Build release AAB:
  - `flutter build appbundle --release`

If Flutter reports a symbol-stripping error but Gradle is otherwise healthy, use:

- `cd android`
- `./gradlew bundleRelease`

Expected output:
- `build/app/outputs/bundle/release/app-release.aab`

## Play Console checks before upload

1. Complete Data Safety form (app stores local clinical data).
2. Confirm permissions declaration for microphone use.
3. Upload app icon, screenshots, privacy policy URL.
4. Complete content rating and app access declarations.
5. Upload ProGuard mapping file if requested:
   - `build/app/outputs/mapping/release/mapping.txt`

## Notes

- If release build still fails with symbol stripping, it is usually local SDK/NDK tooling mismatch.
- Project Gradle settings are already prepared for Play Store release; remaining blocker is local Android SDK setup.
