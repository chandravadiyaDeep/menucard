# Product Requirements — MenuCard

## Product identity
MenuCard is an independent, free digital menu app for small local shops: food stalls, tea/coffee shops, snack shops, bakeries and small cafés. It is not a restaurant-management or ordering platform.

## Locked V1 architecture
- The Android app owns all menu-editing, validation, localization, packaging and publishing-preparation logic.
- The authoritative shop profile and menu are stored as a versioned JSON document in the app's private on-device storage.
- The app works offline for all owner operations.
- Publishing is a deliberate manual export-and-upload action. The app creates a static website package; the owner uploads it using a static hosting provider's dashboard/file-upload workflow.
- The public package consists only of static HTML, CSS, JavaScript, JSON and optional image files. It contains no server-side code and requires no database.
- Customer access is read-only and served by static hosting. The customer page fetches the published JSON file.
- There is no backend, API server, Worker, database service, account system, automatic sync or remote editing.

## Goals
- Let non-technical owners create and maintain a menu on-device.
- Keep owner workflows available without internet.
- Support Gujarati, Hindi and English with owner-entered translations.
- Let owners publish a customer-facing QR menu without server-side application code.
- Make it possible to replace the published package manually while keeping the public menu URL stable.

## Personas
- Owner: edits shop details, categories, items, prices, availability and translations offline; exports and manually uploads a publish package.
- Customer: scans a QR code or opens a URL to view the latest successfully uploaded menu. Internet is required for first load and updates.

## Functional requirements

### Shop profile
Shop name (required), optional description/contact/address/logo, default locale (Gujarati/Hindi/English), currency (INR in V1), and readable themes. Only public menu fields may be exported.

### Menu
Create, rename, reorder and delete categories. Create/edit/reorder/delete items with stable ID, category ID, translated name/description, integer price in paise, availability, optional image, sort order and timestamps. Validate non-negative prices and non-empty names. Category deletion must explicitly move or remove child items; never cascade silently.

### Languages
Support Gujarati, Hindi and English. Owners enter translations manually; no automatic translation is assumed. Fallback: requested locale → shop default locale → first non-empty translation.

### Local JSON persistence
- Store one canonical, schema-versioned JSON document per shop in app-private storage.
- Validate every write against required fields and supported schema version.
- Write to a temporary file, flush it, then atomically replace the previous document so interrupted saves do not corrupt the menu.
- Keep a recoverable previous copy and support explicit backup export/import.
- Never require network access for editing, preview, backup or restore.

### Customer preview
A customer-style preview reads the same local JSON document and works offline.

### Manual publishing
- Export a ZIP/folder containing index.html, static viewer assets, menu.json and referenced public images.
- Validate the exported JSON and ensure it contains no private device paths, credentials or internal app metadata.
- Owner uploads/extracts the package using a static hosting provider's manual dashboard or file-upload workflow.
- The owner saves the resulting HTTPS public URL in the app. A QR code encodes that URL only.
- On later updates, the owner exports again and replaces the files at the same hosted path. The QR URL stays unchanged.
- The app distinguishes local edits from the last published revision. A successful export is not represented as a successful public upload.
- The app must not claim a menu is live until the owner confirms the hosted URL and optionally tests it.

### QR and sharing
Generate QR only after the owner supplies and validates a public HTTPS menu URL. Encode the URL only, never raw menu JSON, private data or credentials. Share via Android system share sheet; WhatsApp is an optional share target, not a dependency.

### Backup and restore
Export/import a versioned JSON backup, including referenced image assets where feasible. Restore validates schema, IDs and references and previews changes; never silently overwrite. A publish package is distinct from a full private backup.

## Non-functional requirements
Offline-first owner workflows; low-end Android performance; atomic file writes; small package/data use; accessible touch targets; verified Gujarati/Hindi rendering; no mandatory account, analytics, location permission, database or server-side code.

## Explicit exclusions
Ordering, checkout, payment processing, reservations, table management, loyalty, enterprise operations, hospitality analytics, AI, subscriptions, automatic publishing, automatic sync, multi-device collaboration and server-side application logic.

## Release acceptance
- Fresh install and onboarding work without network.
- Shop/profile/category/item creation and editing work offline.
- JSON survives force-close/restart and malformed imports are rejected safely.
- Gujarati/Hindi/English render and fallback works.
- Preview reflects the current local JSON.
- Backup export/import round-trip preserves data.
- Publish package contains a working static customer page and valid menu JSON.
- Replacing the hosted package at the same path updates the customer menu without changing the QR URL, subject to host cache revalidation.
- No API/backend/database credentials or secrets are committed.
- CI builds and tests the APK; release claims are based on actual workflow evidence.
