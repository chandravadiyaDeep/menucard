# MenuCard — Free Digital Menu for Local Shops

A simple, free, offline-first Android app for small local businesses to create and manage a digital menu.

## Product promise
- Shop owners can manage shop details, categories, items, prices and availability offline.
- Gujarati, Hindi and English content with explicit owner-entered translations and language fallback.
- Local data remains the source of truth; public QR links require a published internet destination.
- No subscriptions, ordering, checkout, payments, reservations, loyalty, or enterprise analytics.

## Project status
The repository is being initialized. The public one-page site is deployed through GitHub Pages, and the Android build workflow publishes APKs to GitHub Releases. An APK download is shown only after a release containing an APK exists.

See [PRODUCT_REQUIREMENTS.md](docs/PRODUCT_REQUIREMENTS.md), [ARCHITECTURE.md](docs/ARCHITECTURE.md), [ROADMAP.md](docs/ROADMAP.md), and [CURRENT_STATE.md](CURRENT_STATE.md).

## Development
Flutter stable is the target. See `app/` for the Android client. Local persistence is SQLite via Drift; no backend is required for core owner workflows.

## Free and independent
This project is independent of any premium restaurant platform. Core functionality is designed to work without a paid service or recurring subscription.
