# Android app

This directory contains the Flutter owner application.

## Approved V1 architecture
The app must use one versioned JSON file in private on-device storage as the authoritative menu source. All menu editing, validation, preview, translation, backup and publish-package generation runs on-device. There is no backend, API server, database service or automatic sync.

The current scaffold still contains a Drift/SQLite prototype. It is not compliant with the approved V1 architecture and must be replaced before feature expansion.

## Run locally
```bash
cd app
flutter pub get
flutter test
flutter run
```

During the JSON migration, remove Drift-specific code generation and database dependencies. Add useful comments to all new code.

## Build APK
```bash
flutter build apk --release
```

A successful build must be verified in CI/device testing before calling an APK release-ready.
