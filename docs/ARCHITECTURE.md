# Architecture Proposal

## Decision
Use Flutter for Android UI and SQLite through Drift for durable local storage. The first release is backend-free. This makes core owner workflows offline without adding hosting, authentication or sync complexity.

## Layers
1. Presentation: Flutter screens, navigation, localization and view models.
2. Domain: shop/menu entities, validation, language fallback and use cases.
3. Data: Drift repositories, SQLite migrations, file storage and backup import/export.
4. Platform adapters: Android share sheet, file picker and URL-only QR generation.

The UI never writes directly to SQLite; repositories own persistence and transactions.

## Offline strategy
- Local SQLite is authoritative for owner edits.
- No network is needed for launch, profile, categories, items, availability, preview or backup.
- No hidden sync queue in v1; there is no remote write service in scope.
- Customer QR access is separate: a scan needs a valid public menu URL and internet.
- Publishing is a later optional milestone; remote failures must never roll back local edits.

## Future publishing/sync contract (not implemented)
Use stable UUIDs, revisions and local timestamps. Write outbox records in the same SQLite transaction as local edits. Remote upserts are idempotent by UUID/revision. Compare base revisions; never silently overwrite. Present understandable conflict choices and preserve a recoverable copy. Retry boundedly while connected and expose pending/failed status. Publish read-only customer snapshots; never encode private fields or credentials in QR.

## Database design
- shop_profile: singleton ID, name, logo_path, phone, address, default_locale, theme_id, accent_color, updated_at.
- menu_categories: UUID, sort_order, created_at, updated_at.
- menu_items: UUID, category_id FK, price_minor integer (paise), is_available, image_path, sort_order, created_at, updated_at.
- content_translations: entity_type, entity_id, field_key, locale (gu/hi/en), value; unique by entity/type/field/locale.
- app_metadata: key/value for schema/export version and backup metadata.

Use integer paise to avoid floating-point currency errors. Category deletion is an explicit repository transaction after owner chooses to move or remove child items.

## Backup format
Versioned ZIP: manifest.json (format version/export time/app version), database.json (normalized entities and translations), images/ (referenced local assets). Restore validates archive, version, IDs, foreign keys and file sizes; previews summary; commits transactionally. Failure leaves existing DB unchanged.

## QR and sharing
Only generate after publishing supplies a valid HTTPS URL. Encode URL only. Share via Android ACTION_SEND.

## Privacy/performance
No mandatory account, analytics SDK, location permission or network permission for core v1. Optional publishing adds narrowly scoped network access later. Resize optional images before storing.

## Repository boundaries
Independent repo, workflows, app ID and release pipeline. No dependencies, database or credentials from a premium restaurant platform.
