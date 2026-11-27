# Architecture — Local JSON and Manual Static Publishing

## Locked decision
MenuCard V1 uses on-device JSON as its single source of truth. Publishing is manual and produces a static website bundle. There is no backend, API server, Worker, database server, automatic sync, remote write endpoint or account service.

Static hosting is a file origin only: it serves HTML, CSS, JavaScript, JSON and images uploaded by the shop owner. It does not execute MenuCard business logic.

## System boundaries

### Android owner app
All owner-side application logic runs on-device:
1. Presentation: guided shop setup, Flutter screens, navigation, localization and view state.
2. Domain: validation, price conversion, language fallback, category/item rules and revision management.
3. Design system: 120 ready-made combinations from 10 layout families and 12 curated themes; templates are data-driven and separate from shop content.
4. Data: local JSON repository, atomic file persistence, image files and backup import/export.
5. Rendering/publishing: bind the current shop/menu JSON to the selected template, preview it offline using the exact customer HTML/CSS/JavaScript renderer in a local WebView, package static assets, export ZIP, validate HTTPS URL and generate QR.
6. Platform adapters: Android file picker, share sheet and storage APIs.

The UI must call repositories/use cases; it must not write JSON files directly.

### Static customer menu
The exported package contains a static index.html, CSS/JavaScript assets, menu.json and public images. Browser JavaScript parses the JSON and renders the customer menu. The static host only returns files. The browser-side renderer reads `template_id` from menu.json and binds the shop's current text, dishes and prices into the selected layout.

## On-device data storage
- Canonical file: app-private shop-menu.json.
- Optional public images: app-private image directory, referenced by stable relative asset IDs/paths.
- Local backup: versioned JSON/ZIP export, kept separate from the public publish package.
- Use stable UUIDs for shop, category and item IDs.
- Use integer paise (price_minor) to avoid floating-point currency errors.
- Include schema_version, revision, updated_at, shop, languages, `template_id` and categories with nested items.
- Keep `template_selected` as local onboarding state only; never expose it in the public JSON.
- Persist safely: serialize and validate → write a temporary sibling file → flush/close → retain previous valid file → rename temporary file into place.
- On startup, validate the file; if the primary is invalid, offer recovery from the last-known-good copy rather than silently resetting it.
- No SQLite/Drift or other database is part of the approved V1 persistence layer.

## JSON schema and example
See [sample-menu.json](../examples/sample-menu.json). The schema is versioned. Unknown future schema versions must be rejected with a clear upgrade message; compatible additive fields may be ignored only when explicitly documented.

## Template rendering contract
- Menu content is the single source of truth. Template selection must never copy content into template-specific fields or create per-template menu records.
- `template_id` uses a stable `layout-theme` ID, such as `editorial-terracotta`.
- Flutter's template catalog provides the owner gallery and visual previews. The exported customer viewer uses the same ID to apply the matching CSS layout and theme.
- The browser renderer uses an allowlist for layout and theme identifiers and renders owner-provided text through `textContent`, never executable HTML.
- The owner preview injects a validated local public-JSON snapshot into the same renderer used by the exported site. Local item photos are embedded as data URLs for offline preview; no network request or server is required.
- The customer renderer supports search across translated category names, dish names and descriptions. Search is presentation-only and never mutates the stored menu JSON.
- Changing a menu field and changing a template are independent operations. Existing data remains intact when the owner switches designs.

## Manual publishing contract

### Exported package layout
The exported folder contains:
- index.html
- assets/menu.css
- assets/menu.js
- assets/images/ for public image files
- menu.json

The package is self-contained and uses relative paths. It must work when hosted from a subdirectory, not only from a domain root.

### Owner workflow
1. Edit the menu locally; the app increments the local revision and saves JSON.
2. Open Designs and inspect the full customer preview. The preview uses the exact static customer renderer and current local menu snapshot.
3. Tap Export website package. The app validates public fields and creates a ZIP file.
4. The owner uploads/extracts the ZIP through a static hosting provider's manual upload/dashboard flow. The provider must allow commercial use and static file hosting under its current terms.
5. On first publish, the owner copies the resulting HTTPS URL back into MenuCard and confirms that the customer page opens.
6. MenuCard generates a QR code for that URL. The QR is stable as long as the owner keeps publishing to the same hosted URL/path.
7. For updates, the owner exports a fresh package and manually replaces the files at the same hosted path. No QR reprint is needed.
8. The owner returns to MenuCard and marks the exported revision as published only after confirming the upload. The app records the confirmed public URL, revision and confirmation time locally.

### Important status distinction
- Local revision: newest changes saved on this phone.
- Exported revision: snapshot packaged for upload.
- Published revision: revision the owner has manually confirmed is live at the saved URL.

Never infer upload success from file export. If the owner edits after exporting, show that the local revision is newer than the exported/published revision.

## Customer loading and cache behavior
- Customer page fetches its sibling menu.json using a relative URL, so the bundle works under a subpath.
- Fetch with browser cache revalidation/no-store where supported.
- Static host/CDN must revalidate menu.json (for example, no-cache or short-lived caching with ETag). A host that indefinitely caches JSON is not suitable for reliable updates.
- Include revision and updated timestamp in the customer page so customers can identify the loaded version.
- If JSON cannot load, show a clear unavailable message; never show a fake or stale menu as current.

## Security and privacy
- Export only explicitly public shop/menu fields and images.
- Never export private local file paths, device identifiers, app settings, backup history, tokens or credentials.
- Anything published is public and downloadable.
- HTTPS is required for the saved customer URL.
- No owner authentication is implemented in V1. The hosting provider's dashboard account and its own security controls are the owner's responsibility.

## Migration from current prototype
The current Flutter scaffold uses Drift/SQLite. That implementation does not match this locked architecture. Before adding more menu features, replace Drift tables/repository with a JSON-backed repository and update tests/dependencies. Do not keep SQLite as a hidden secondary source of truth.

## Non-goals
No database, backend API, serverless functions, cloud sync, remote menu editing, automatic uploads, real-time collaboration, ordering or payment flows.
