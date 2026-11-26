# Current State

**Updated:** 2026-11-27

## Repository
- https://github.com/chandravadiyaDeep/menucard
- Default branch: main; GitHub Pages enabled for the product landing page.

## Architecture decision locked
- [x] Option B: local JSON + manual static publishing.
- [x] No MenuCard backend, API server, Worker, cloud database, automatic sync or remote editing.
- [x] Owner-side logic, validation, local persistence and package generation remain on-device.
- [x] Static hosting is only a public file origin; owners manually upload and replace the static package.

## Documentation and static template added
- [x] Updated README and product requirements for local JSON and manual publishing.
- [x] Replaced the previous SQLite architecture proposal with the JSON-first architecture.
- [x] Replaced roadmap with JSON persistence, static customer page and manual publish milestones.
- [x] Added docs/STATIC_PUBLISHING.md with first-publish, update, revision, cache and troubleshooting steps.
- [x] Added examples/sample-menu.json.
- [x] Added static-menu-template with HTML, CSS, browser JavaScript and a sample menu.json.
- [x] Updated app/README.md to flag the current SQLite scaffold for migration.

## Current implementation reality
- The Flutter owner app still uses Drift/SQLite in app/lib and is not yet compliant with the approved JSON-first architecture.
- The static customer template is a repository prototype; the Android app does not yet export this package.
- The owner app does not yet have JSON import/export, static package ZIP export, hosted URL confirmation or QR generation.
- No server-side MenuCard code has been added.
- The static template has not yet been validated on a real hosting provider or mobile browser.

## Existing verified work
- GitHub Pages deployment workflow succeeded previously: https://github.com/chandravadiyaDeep/menucard/actions/runs/45868756522
- GitHub Pages is for the product landing page only; it is not selected as the production host for individual shops.
- No APK release is currently published. Flutter CI/build/test success is not yet established.

## Next implementation sequence
1. Replace Drift/SQLite with a versioned JSON-backed local repository and atomic persistence.
2. Add menu CRUD and tests against the JSON repository.
3. Build the publish ZIP on-device using the static-menu-template and the public menu snapshot.
4. Add local publish revision tracking, HTTPS URL confirmation and URL-only QR generation.
5. Validate package upload/update behavior on a static host that permits the shop's intended commercial use.
6. Run Flutter analyzer, tests, Android build and device QA; publish an APK only after verified success.

## Guardrails
- Do not add database dependencies, server-side functions, backend endpoints, API credentials or automatic uploads.
- Do not claim that exporting a ZIP means the public menu is updated.
- Keep the local menu safe if export or upload fails.
- Add useful comments to all new code and update this file after meaningful repository changes.
