# MenuCard V1.1.1

## Customer menu preview
- Added a full-screen customer preview in the owner app.
- Preview uses the exact bundled customer HTML, CSS and JavaScript used by exported websites.
- Local shop/menu JSON and photos are embedded into the preview session as local data; no upload or backend is involved.
- Preview reflects the selected layout, theme, language, item availability, images and prices.

## Menu search and filtering
- Owner search covers dish names and descriptions across saved translations, plus category names.
- Added category and availability filters (all, available, paused).
- Added a search-empty state and clear-search action.
- Customer-facing static menus also support live search across categories, dishes and descriptions.

## Editing improvements
- Price entry accepts up to two decimal places.
- Item deletion now requires explicit confirmation.
- Existing category/item edit, image selection, availability and local JSON persistence are retained.
- Filter selection resets safely when its category is deleted.

## Architecture and privacy
- No server, database, API, account or synchronization service was added.
- The owner app continues to store the canonical menu JSON and images locally.
- The preview reuses the exported static customer renderer rather than introducing a second independent menu design implementation.
- Website export remains a manual owner-controlled action.

## Verification and release
- Flutter formatting, static analysis, automated tests, Node renderer tests and Android release build run in GitHub Actions.
- The verified APK is published as the V1.1.1 GitHub Release asset. The marketing site reads the latest official release and links directly to its APK asset.
- Physical Android device QA and production signing are still required before Play Store distribution.
