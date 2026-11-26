# Product Requirements — MenuCard

## Product identity
MenuCard is an independent, free digital menu and catalogue app for small local shops: food stalls, tea/coffee shops, snack shops, bakeries and small cafés. It is not a premium restaurant-management platform.

## Goals
- Let non-technical owners create and maintain a menu.
- Keep owner workflows available without internet.
- Work on low-end Android devices with modest storage and data use.
- Support Gujarati, Hindi and English with owner-entered translations.
- Provide local preview, export/backup and a later path to publish.

## Personas
- Owner: manages shop details, categories, items, prices and availability offline.
- Customer: views a published mobile-friendly menu from a QR link or URL. Customer access normally requires internet.

## Functional requirements
### Shop profile
Name (required), optional logo/contact/address, default locale (Gujarati/Hindi/English), and a small set of readable themes.

### Menu
Create, rename, reorder and delete categories. Create/edit/reorder/delete items with stable ID, category ID, translated name/description, INR price, availability, optional local image, sort order and timestamps. Validate non-negative price and non-empty name. Category deletion must explicitly move or remove child items; never cascade silently.

### Languages
Support UI locales Gujarati, Hindi and English. Owners enter translations manually; no automatic translation is assumed. Fallback: requested locale → shop default locale → first non-empty translation.

### Preview
A customer-style mobile preview reads local data and works offline. Keep the layout readable and simple.

### QR and sharing
Generate QR only when a valid published HTTPS URL exists. Encode that URL only, never menu JSON, private data or credentials. Share through Android system share sheet; WhatsApp works as a share target when installed, not as a hard dependency. Until publishing exists, show a clear disabled state.

### Local data and backup
SQLite is the durable local source of truth. Export a versioned backup of profile, categories, items and translations, including referenced images where feasible. Restore validates schema/version and previews changes; never silently overwrite. Show backup status and confirm destructive actions.

## Non-functional requirements
Offline-first core owner workflows; low-end Android performance; transactional writes and migrations; scalable text, accessible contrast and touch targets; verified Gujarati/Hindi rendering; no account or analytics required; no paid backend for core use.

## Explicit exclusions
Ordering, checkout, payment processing, reservations, table management, loyalty, enterprise operations, hospitality analytics, AI, subscriptions and expensive infrastructure.

## Release acceptance
- Fresh install and onboarding work without network.
- Shop/profile/category/item creation works offline.
- Edits survive force-close/restart.
- Validation errors are understandable.
- Gujarati/Hindi/English render and fallback works.
- Preview reflects local saved data.
- Backup export/restore round-trip preserves data.
- QR remains unavailable without a published HTTPS URL.
- CI builds APK and attaches it to a versioned GitHub Release.
- No secrets are committed.
