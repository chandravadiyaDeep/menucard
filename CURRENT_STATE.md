# Current State

**Updated:** 2026-11-28

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

## V1.1.2 customer preview/search/editor polish (main)
- [x] Full-screen customer preview uses the same bundled HTML/CSS/JavaScript renderer as the exported static website.
- [x] Preview is reachable from Home, My menu and Designs.
- [x] Preview injects the current local JSON snapshot and embeds local photos as data URLs; no server or network is needed.
- [x] Preview photo lookup is indexed by item ID to avoid repeated full-menu scans.
- [x] WebView navigation is restricted to the local preview origin and embedded content.
- [x] Owner menu search covers saved translations of item names/descriptions and category names.
- [x] Category and availability filters include a one-tap clear-all action.
- [x] Customer static menu includes live search.
- [x] Price input is constrained to two decimal places; item deletion requires confirmation; availability can be toggled from item actions.
- [x] Widget tests cover preview entry points, search, filter reset and availability filtering; Node tests exercise the actual customer renderer.
- [x] GitHub Actions workflow checks formatting, static analysis, Flutter tests, JavaScript syntax, renderer tests and release-mode APK build.
- [x] Website download section resolves the latest GitHub Release APK dynamically.
- [x] V1.1.2 quality run, release-mode APK build, checksum and GitHub Release upload completed successfully.
- [x] Latest APK is published as the `v1.1.2` GitHub Release and the landing page resolves the latest APK dynamically.

## V1.1.3 simplified QR Publish (main)
- [x] Publish tab is now a single-purpose menu QR generator; website export/upload/confirmation steps have been removed from that tab.
- [x] Public HTTPS menu URL is entered once and saved as local-only QR metadata in the versioned JSON document.
- [x] Existing published URL is used as the initial QR destination for backward compatibility.
- [x] QR preview appears in the app after generation.
- [x] High-resolution PNG export and A4 PDF export are generated on-device and opened in the Android share sheet for sharing/saving.
- [x] Publish screen wording and buttons simplified to a single QR workflow with Image and PDF actions.
- [x] Publish copy is simplified: one clear QR workflow, with Image and PDF actions.
- [x] QR destination is excluded from customer-facing public JSON.
- [x] Private backup/restore remain accessible from the app-bar backup menu, outside Publish.
- [x] Dart formatting, Flutter static analysis, complete Flutter tests, JavaScript syntax and customer renderer tests passed in Android workflow run #46038192565.
- [ ] Release-mode APK build, checksum and GitHub Release publication are still running in workflow #46038192565.
- [ ] Physical Android QA for QR scanning, PNG/PDF export and share sheet is pending.
## Template-first implementation verification
- [x] Template gallery, template persistence, 120-design catalog and static customer renderer passed Flutter formatting, static analysis and automated tests in Android workflow run #35.
- [ ] Physical device visual QA for the 120-template gallery and customer menu is pending.

## CI verification
- [x] Dart formatting passed.
- [x] Flutter static analysis passed with no issues.
- [x] Complete Flutter test suite passed.
- [x] Customer-menu JavaScript syntax check passed.
- [x] Customer renderer and search tests passed.
- [x] Android release-mode APK built and checksum recorded.
- [x] APK artifact uploaded and V1.1.2 GitHub Release published.
- Latest Android run: https://github.com/chandravadiyaDeep/menucard/actions/runs/45946942376
- Release: https://github.com/chandravadiyaDeep/menucard/releases/tag/v1.1.2
- Website: https://chandravadiyadeep.github.io/menucard/

## Production release status
- The V1.1.2 APK is a release-mode test build signed with the default Android debug key because production signing secrets are not configured.
- It is suitable for device testing, not Play Store distribution or a production-signed update channel.
- Physical Android device QA remains pending.
- The GitHub Pages landing page resolves the newest APK from the public GitHub Releases API; the per-shop customer website package remains a manual owner export/upload.

## Remaining quality gates
1. Install V1.1.2 on physical Android devices and verify fresh install, persistence after force-close, menu CRUD, preview, template switching, image import, backup/restore, QR and sharing.
2. Configure production signing secrets before preparing a Play Store/production-signed release.
3. Test a customer website package on a real static host and scan the published QR.

## Guardrails
- Never call a debug-signed candidate a production APK.
- Never claim a website ZIP export is a public upload.
- Never replace failed local JSON with an empty menu without owner consent.
- Never commit release credentials.
- Keep the app entirely local-first and add useful comments to new code.


## V1.2.0 offline owner-issued account implementation (merged to main)
- [x] App-private `accounts.json` registry, separate from public menu JSON.
- [x] Personal access-code file import; only salted SHA-256 digests are persisted.
- [x] One-time code claim per installation, mobile identifier and shop-name registration.
- [x] First-run activation gate and personal code import UI.
- [x] Local Python generator creates 100 separate personal code files, a distribution ZIP and private issuer CSV ledger.
- [x] Private account recovery JSON export from the owner workspace.
- [x] Account recovery JSON restore from the activation screen on a replacement phone.
- [x] Existing installs with a pre-existing menu file are grandfathered to avoid locking out current owners.
- [x] Repository tests cover code import, duplicate claim, duplicate mobile, recovery, invalid backup and legacy migration.
- [x] README, website and architecture contract updated for offline owner-issued activation.
- [x] PR #3 merged to main: https://github.com/chandravadiyaDeep/menucard/pull/3
- [x] Formatting, Flutter analyzer, Flutter tests, owner-code generator checks, JavaScript syntax and customer renderer tests passed in Android workflow run #46059745026.
- [x] GitHub Pages website deployment succeeded in run #46059968325.
- [ ] Release-mode APK build, checksum and V1.2.0 physical-testing GitHub Release are running in workflow #46059745026.
- [ ] Physical Android testing is the only planned manual QA step after APK publication.
- Cross-device single-use is controlled by the issuer's private CSV ledger; offline app instances cannot coordinate. Phone numbers are identifiers, not verified identity.
- The physical-testing APK uses the Android debug key. It is not a production-signed or Play Store-ready release.
