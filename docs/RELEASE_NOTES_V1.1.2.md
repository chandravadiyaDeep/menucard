# MenuCard V1.1.2

## Customer menu preview
- Full customer-facing menu preview is available from Home, My menu and Designs.
- Preview uses the same bundled HTML, CSS and JavaScript renderer as the exported customer website.
- Shop details, selected layout/theme, categories, descriptions, prices, availability and item photos are rendered from the current local JSON snapshot.
- Local photos are embedded as data URLs for offline viewing.
- Preview photo lookup uses an ID index to avoid repeatedly scanning the entire menu.
- WebView navigation is restricted to the local preview origin and embedded content.

## Menu search and filters
- Search across saved translations of dish names and descriptions, plus category names.
- Filter by category and available/paused state.
- Clear all search and filter state with one action when no results match.
- Customer-facing static menu keeps its own live search.

## Editing polish
- Customer preview is directly reachable from Home and My menu as well as Designs.
- Price input is limited to two decimal places and validated before saving.
- Item deletion asks for confirmation.
- Availability can be changed from the item actions menu without opening the full editor.

## Architecture
- Offline-first local JSON remains the single source of truth.
- Preview and search execute on-device.
- No MenuCard backend, database, API, remote account or synchronization service was added.
- Static website publishing remains an explicit owner export/upload action.

## Verification and release status
- CI runs Dart formatting, Flutter static analysis, the complete Flutter test suite, JavaScript syntax checks, customer-renderer tests and a release-mode APK build.
- The GitHub Release workflow publishes the APK and SHA-256 checksum only after those checks pass.
- Main-branch test APKs use the default debug signing key because production signing secrets are not configured. They are for device testing, not Play Store distribution.
- Physical Android device QA remains required.
