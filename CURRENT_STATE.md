# Current State

**Updated:** 2026-11-27

## Repository
- https://github.com/chandravadiyaDeep/menucard
- Default branch: main; GitHub Pages hosts the product landing page.

## Product direction update — template-first digital menu designer
- [x] Shop profile and menu data are entered once, then bound into a ready-made template.
- [x] 120 selectable designs: 10 layout families × 12 color themes.
- [x] Selected design is stored as a stable `template_id`; dish names/prices remain independent of presentation.
- [x] Customer static viewer applies the selected design automatically.

## Locked architecture
- [x] Option B: app-private local JSON is the single source of truth.
- [x] All owner-side business logic runs on-device.
- [x] Manual export of a static HTML/CSS/JS/JSON package; owner uploads and replaces files.
- [x] No MenuCard backend, database, Worker, API, automatic upload or synchronization.

## V1 application implementation committed to main
- [x] Versioned menu document models and JSON validation.
- [x] Local JSON repository with serialized writes, staged recovery snapshot and corruption recovery.
- [x] Shop profile editing, category/item create/edit/delete and item availability controls.
- [x] English/Gujarati/Hindi menu content selection with owner-entered translations.
- [x] Optional item photo import and public image packaging.
- [x] Static customer website assets embedded in the Flutter app.
- [x] On-device static website ZIP export.
- [x] Private backup ZIP export and guarded backup restore.
- [x] Local publish revision state, HTTPS URL confirmation and QR generation.
- [x] Owner navigation includes Home, My menu, Designs and Publish.
- [x] Guided 3-step setup card: shop profile → dishes/prices → choose a design.
- [x] Data-driven template catalog and gallery with 120 combinations.
- [x] Customer static viewer binds menu JSON to the selected layout/theme.
- [x] Repository tests for first-run storage, persistence, public export privacy, validation, category deletion, URL confirmation, recovery, concurrent writes and item edit/move behavior.
- [x] Dashboard widget smoke test.

## Template-first implementation verification
- [x] Template gallery, template persistence, 120-design catalog and static customer renderer passed Flutter formatting, static analysis and automated tests in Android workflow run #35.
- [ ] Physical device visual QA for the 120-template gallery and customer menu is pending.

## CI verification
- [x] Flutter formatting step completed.
- [x] Flutter static analysis passed.
- [x] Complete Flutter test suite passed on the latest build attempt.
- [x] Android platform project generation and dependency installation passed.
- [ ] Latest release-mode APK build is still running in GitHub Actions.
- Latest run: https://github.com/chandravadiyaDeep/menucard/actions/runs/45939079658
- CI now uses Java 21 because the previous Java 17 run crashed inside Android Lint.
- No APK artifact is claimed until the build and artifact-upload steps complete.

## Production release status
- No permanent production signing keystore has been configured in GitHub Actions secrets.
- Main-branch release-mode artifacts are installable test candidates, not production/Play Store signed releases.
- No physical Android device QA or public static-host upload verification has been completed.
- No production APK is currently published.
- See app/RELEASE.md for the four required signing secrets and secure release process.

## Remaining quality gates
1. Confirm the release-mode APK build and retrieve its Actions artifact.
2. Install and test on physical Android devices: fresh install, persistence after force-close, menu CRUD, template gallery, customer preview/export, image import/export, backup/restore, share sheet and QR.
3. Upload a generated customer package to a suitable static host, verify replacement/cache behavior and scan the QR.
4. Configure persistent signing secrets before creating a production release tag.

## Guardrails
- Never call a debug-signed candidate a production APK.
- Never claim a website ZIP export is a public upload.
- Never replace failed local JSON with an empty menu without owner consent.
- Never commit release credentials.
- Keep the app entirely local-first and add useful comments to new code.
