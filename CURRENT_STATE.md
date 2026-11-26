# Current State

**Updated:** 2026-11-26

## Repository
- https://github.com/chandravadiyaDeep/menucard
- Default branch: main; GitHub Pages enabled.
- Repository was empty at connection time; this is the initial implementation baseline.

## Completed
- [x] Product requirements and exclusions: `docs/PRODUCT_REQUIREMENTS.md`.
- [x] Offline-first architecture, SQLite schema and future sync contract: `docs/ARCHITECTURE.md`.
- [x] UI sitemap and delivery roadmap.
- [x] Responsive root landing page with a CSS-built menu illustration (no stock images).
- [x] Download section checks latest GitHub Release and APK asset; falls back to Releases when none exists.
- [x] GitHub Pages deployment workflow.
- [x] Flutter foundation: Drift database model, local shop profile edit, category creation, item creation and local preview.
- [x] Android workflow builds/tests and publishes APK on `v*` tags.

## Verification evidence
- GitHub Pages Actions run #2 completed successfully: https://github.com/chandravadiyaDeep/menucard/actions/runs/45868756522
- Pages upload and deploy steps succeeded.
- Release API currently returns an empty list; no downloadable APK has been published yet.
- Flutter CI has not yet run; no Android build or widget test is claimed as passing.
- First Pages run failed due artifact lookup; workflow was corrected and run #2 succeeded.

## Not yet implemented
- Category/item edit and delete; explicit category deletion handling.
- Availability editing UI and category ordering.
- Manual translation editor and localized app UI strings.
- Backup export/restore.
- Logo and image picker.
- QR/link publishing and Android share sheet.
- Real-device and low-end Android validation.

## Important notes
- Drift schema source: `app/lib/data/app_database.dart`. The generated file must be validated against the pinned Drift generator before relying on it.
- This is an early foundation, not a release-ready product.
- A real APK requires successful Android workflow completion and a Release asset.
- QR remains unavailable until a public HTTPS menu destination is implemented.

## Next action
Validate Flutter analyzer/build/test in GitHub Actions and fix compile issues, then add edit/delete and backup/restore before a test release.
