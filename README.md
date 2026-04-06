# NeuroScale Pro

NeuroScale Pro is a Flutter-based clinical support app for structured neuropsychiatric assessment and risk-oriented patient follow-up.

## Features

- Standardized scale-based assessments:
   - BPRS
   - PHQ-9
   - GAD-7
   - HAM-D
   - YMRS
   - Y-BOCS
   - MMSE
   - C-SSRS
- ICU mode for rapid bedside scoring.
- Patient management with assessment history.
- Risk highlighting for high-severity/suicide-related findings.
- Analytics dashboard for trends and usage.
- AI-assisted summary generation with fallback mode when model is unavailable.
- Voice-assisted input support.

## Tech Stack

- Flutter + Provider state management
- SQLite local storage (`sqflite`)
- Android release pipeline with R8, resource shrinking, and Play Store-ready signing

## Project Structure

```text
lib/
   core/
      models/
      providers/
      services/
      theme/
   screens/
   main.dart
android/
test/
```

## Getting Started

1. Install Flutter SDK and Android toolchain.
2. Clone this repository.
3. Install dependencies:

```bash
flutter pub get
```

4. Run app:

```bash
flutter run
```

## Build

Debug APK:

```bash
flutter build apk
```

Release AAB:

```bash
flutter build appbundle --release
```

## Google Play Release Setup

1. Generate an upload keystore.
2. Copy `android/key.properties.example` to `android/key.properties` and fill values.
3. Build signed bundle:

```bash
cd android
./gradlew bundleRelease
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Detailed release steps are documented in `android/PLAYSTORE_RELEASE.md`.

## Release Compliance Checklist (Scale Licensing)

Run this checklist before every production build or store submission.

- Verify each enabled assessment scale is marked `Approved` in `docs/licensing/SCALE_LICENSE_TRACKER.csv`.
- Verify written permission evidence exists for each approved scale in `docs/licensing/evidence/`.
- Confirm required attribution text for each licensed scale is present in app/legal screens.
- Confirm license period is active and not expired.
- Confirm regional deployment limits in each agreement match target release markets.
- Confirm translation/localization rights before shipping non-English item text.
- Keep unapproved scales on placeholder wording or disable them from production builds.
- Record release-date compliance sign-off (owner + date) in your internal release notes.

## Clinical Safety Notice

This app is a clinical support tool. It does not replace professional psychiatric judgment.

## License

MIT
