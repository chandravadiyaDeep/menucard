# Android app

This directory contains the Flutter application.

## Prerequisites
- Flutter stable
- Android SDK / Android toolchain

## Run locally
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

The generated Drift file `lib/data/app_database.g.dart` is produced by build_runner. It is not checked into this initial scaffold.

## Build APK
```bash
flutter build apk --release
```

The initial scope is shop profile, categories, menu item creation and a local preview. QR publishing, backup/restore, translations editing, images, and synchronization are later milestones and are not represented as complete here.
