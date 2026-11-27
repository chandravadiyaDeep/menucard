# MenuCard — Free Digital Menu for Local Shops

A polished offline-first Android app for small local businesses to create, manage and manually publish a digital menu.

## V1 product
- Edit shop profile, menu categories, items, prices and availability offline.
- Store the authoritative menu as versioned JSON on the Android device.
- Add item photos and owner-entered English, Gujarati and Hindi translations.
- Export a self-contained static website ZIP, then upload it manually to a static hosting provider.
- Save the public HTTPS URL and generate a QR code. The QR contains only the customer URL.
- Export and restore a private backup that includes menu data and selected photos.

## Architecture
Menu data and owner accounts are stored as app-private local JSON. Account activation uses individual owner-issued offline codes; the issuer keeps a private CSV ledger because no offline app can enforce cross-device single-use. Public publishing remains a manual static website upload. No MenuCard backend, API server, Worker, remote database or automatic synchronization is used. Static hosting only serves static HTML, CSS, JavaScript, JSON and images uploaded by the owner.

See [manual publishing instructions](docs/STATIC_PUBLISHING.md), [architecture](docs/ARCHITECTURE.md), [offline account workflow](docs/OFFLINE_ACCOUNTS.md), and [release instructions](app/RELEASE.md).

## Build status
The Flutter source is being migrated to the V1 JSON-first architecture. GitHub Actions runs formatting, static analysis, automated tests and an APK build. A passing CI artifact is a release-mode candidate; production signing and physical-device QA are required before production distribution.

## Project links
- [Current state](CURRENT_STATE.md)
- [Product requirements](docs/PRODUCT_REQUIREMENTS.md)
- [Development roadmap](docs/ROADMAP.md)
- [Sample JSON schema](examples/sample-menu.json)

MenuCard is independent and free. It does not provide ordering, payments, reservations, loyalty or enterprise analytics.
