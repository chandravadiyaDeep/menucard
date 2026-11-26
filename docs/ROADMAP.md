# Development Roadmap

## M0 — Scope and architecture
Requirements, exclusions, architecture, data model, sitemap and acceptance tests. Exit: owner approves docs.

## M1 — UX prototype
Flutter navigation shell, onboarding, language choice, home and empty states; public one-page GitHub Pages site. Exit: compact and standard phone layouts reviewed.

## M2 — Flutter foundation
Flutter stable project, app metadata, localization, theme and CI. Exit: successful compile/launch and green CI.

## M3 — Local database
Drift/SQLite schema, migrations, repositories and persistence tests. Exit: offline relaunch tests pass.

## M4 — Menu management
Shop profile, categories, items, ordering, price, availability and preview. Exit: CRUD/validation and all offline owner workflows pass.

## M5 — Languages and backups
Gujarati/Hindi/English UI, owner translation and fallback, versioned export/restore. Exit: localization and round-trip tests pass.

## M6 — QR and sharing
Wait for public publishing URL. Validate HTTPS, encode URL-only QR and share through system sheet. Exit: scan/share tests on Android.

## M7 — Optional publishing
Separate read-only customer menu and reviewed hosting plan. Local data remains authoritative; explicit conflict UI required. No remote sync without product approval.

## M8 — Device QA and release
Test offline launch, force-close, network interruption, translations, small screens, accessibility and low-end device. Publish signed APK through GitHub Releases. Signing material lives only in Actions secrets, never in Git.
