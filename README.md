# MenuCard — Free Digital Menu for Local Shops

A simple, free, offline-first Android app for small local businesses to create and manage a digital menu.

## Product promise
- Owners create and edit shop menus on their Android device, including offline.
- The authoritative data is a versioned JSON document stored locally on-device.
- Owners manually export a static customer-menu package and upload it to a static hosting provider.
- Customers scan a QR code and view the latest successfully published static menu.
- Gujarati, Hindi and English content is entered by the owner; translations are never silently machine-generated.

## Architecture decision
**Local JSON + manual static publishing (Option B).** No application backend, API server, Worker, cloud database, account service, or automatic synchronization. Static hosting only serves files uploaded by the owner; it runs no MenuCard server-side logic.

The Android app keeps all owner-side business logic and menu editing on-device. See the [publishing workflow](docs/STATIC_PUBLISHING.md), [architecture](docs/ARCHITECTURE.md), and [JSON example](examples/sample-menu.json).

## Project status
The responsive product landing page is deployed through GitHub Pages. The Flutter app is an early prototype; its current persistence code still uses Drift/SQLite and must be migrated to the approved local-JSON design before V1. No APK is currently published.

See [PRODUCT_REQUIREMENTS.md](docs/PRODUCT_REQUIREMENTS.md), [ROADMAP.md](docs/ROADMAP.md), and [CURRENT_STATE.md](CURRENT_STATE.md).

## Development
Flutter stable is the Android target. All new code must include useful comments. Do not add backend services or database dependencies without an explicit product decision.

## Free and independent
MenuCard is independent of any premium restaurant platform. No subscriptions, ordering, checkout, payments, reservations, loyalty, or enterprise analytics.
