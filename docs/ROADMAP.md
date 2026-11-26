# Development Roadmap

## M0 — Product and architecture lock
Requirements, exclusions, local JSON schema, static publishing contract and acceptance tests. Exit: approved Option B architecture is reflected consistently in all docs.

## M1 — UX and navigation
Flutter navigation shell, onboarding, language choice, dashboard, menu editor, customer preview and publish status screen. Keep all owner workflows local.

## M2 — JSON foundation
Remove Drift/SQLite. Implement versioned JSON models, validation, repository, atomic writes, last-known-good recovery and unit tests. Exit: edits survive force-close/restart with no network.

## M3 — Menu management
Shop profile, category/item create/edit/delete/reorder, integer-paise pricing, availability and explicit category deletion handling. Exit: full CRUD and validation tests pass.

## M4 — Languages and images
Gujarati/Hindi/English UI, owner-entered translations, fallback rules, image import/copy/resize and local asset references. Exit: translations and image references survive restart/export.

## M5 — Backup and restore
Versioned private backup export/import, schema validation, preview-before-restore and safe recovery. Exit: round-trip and corrupted-file tests pass.

## M6 — Static customer website
Build a small responsive customer page that renders a public menu from sibling menu.json; package it with CSS/JS and images. No server-side code. Exit: package works from a nested static path and handles missing/invalid JSON.

## M7 — Manual publishing and QR
Export ZIP, choose share/save destination, enter/validate HTTPS hosting URL, confirm upload, store local published revision and generate URL-only QR. Document first upload and replacement workflow. Exit: same URL serves the new revision after cache revalidation.

## M8 — Device QA and release
Test offline editing, app restart, import/export, package extraction, customer page on mobile browsers, QR scanning, host cache behavior, Gujarati/Hindi rendering, small screens and low-end Android. Publish signed APK only after successful CI and device validation.
