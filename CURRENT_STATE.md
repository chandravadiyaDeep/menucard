# Current State

**Updated:** 2026-11-27

## Repository
- https://github.com/chandravadiyaDeep/menucard
- Default branch: main; GitHub Pages hosts the product landing page.

## Locked architecture
- [x] Option B: app-private local JSON as the source of truth.
- [x] All owner-side business logic runs on-device.
- [x] Manual export of a static HTML/CSS/JS/JSON package; owner uploads and replaces files.
- [x] No MenuCard backend, database, Worker, API, automatic upload or synchronization.

## V1 Flutter implementation added in the working change set
- [x] Versioned menu document models and JSON validation.
- [x] Local JSON repository with temporary-file writes and recovery backup.
- [x] Shop profile editing, category/item create/edit/delete and item availability controls.
- [x] English/Gujarati/Hindi content selection with owner-entered translations.
- [x] Optional item photo import and public image packaging.
- [x] Static customer website assets embedded in the Flutter app.
- [x] On-device static website ZIP export.
- [x] Private backup ZIP export and guarded backup restore.
- [x] Local publish revision state, HTTPS URL confirmation and QR generation.
- [x] Material 3 owner dashboard with Home, My Menu and Publish navigation.
- [x] Repository tests for first-run storage, persistence, public export privacy, validation, category deletion, URL confirmation and recovery.

## Verification status
- [ ] Changes have not yet been committed to main.
- [ ] Flutter formatting/analyzer/tests have not yet been run.
- [ ] Android APK build has not yet been run.
- [ ] GitHub Actions candidate build has not yet been confirmed.
- [ ] No production signing keystore has been configured by the owner.
- [ ] No physical Android device QA or public static-host upload verification has been completed.
- [ ] No production APK is currently published.

## Build and release plan
- CI generates the missing Android platform directory using Flutter stable.
- Main branch runs format, analyzer, automated tests and a release-mode APK build.
- Main branch APK artifacts are candidates only and are not treated as production-signed.
- Version tags require the owner's release keystore and publish the signed APK plus SHA-256 checksum.
- See app/RELEASE.md for the secure keystore process.

## Remaining quality gates
1. Delete obsolete Drift/SQLite sources and complete the JSON-only migration.
2. Run CI, fix compile/analyzer/test failures and confirm the APK artifact.
3. Install and test the APK on Android devices: persistence after force-close, menu CRUD, images, backup/restore, sharing and ZIP export.
4. Upload the package to a suitable commercial static host, verify cache update behavior and scan QR.
5. Configure signing secrets before creating a production release tag.

## Guardrails
- Never call a debug-signed artifact a production APK.
- Never claim a website ZIP export is a public upload.
- Never replace failed local JSON with an empty menu without owner consent.
- Never commit release credentials.
- Keep the app entirely local-first and add comments to new code.
