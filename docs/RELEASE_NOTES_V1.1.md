# MenuCard V1.1.0

## What’s new

- Guided first-time setup asks for the shop name, preferred menu language (English, Gujarati or Hindi), and shop type.
- Creates useful starter menu categories for cafes/snack shops, restaurants, bakeries, tea stalls and other shops.
- Keeps setup optional for returning owners; the existing dashboard and local menu remain available.
- App version is now 1.1.0 (Android build number 2).

## Existing V1 capabilities retained

- Offline-first local JSON storage and recovery copy.
- 120 ready-made layout/theme combinations.
- Menu item photos, categories, prices and availability.
- Static website ZIP export, manual hosting and QR sharing.
- Private backup and restore.

## Verification

The onboarding UI has a widget test. Full release verification is performed by the Android GitHub Actions workflow on this branch. A successful CI run is required before calling this build tested or release-ready.

## Known release gates

- Physical Android device testing is still required.
- Production signing is not configured; this build is a test candidate, not a Play Store release.
- Shop menu website hosting remains a manual owner action by design.
