# MenuCard V1.1.3

## Publish is now a simple QR maker
- Replaced the multi-step export/upload/confirm workflow with one focused Publish screen.
- Paste a public HTTPS menu URL and tap Generate QR code.
- The generated QR is displayed in the app and the URL is saved in the local JSON file.
- Existing saved public menu URLs are automatically used as the initial QR destination.

## QR export and sharing
- High-resolution PNG QR image export.
- A4 PDF QR sheet export with a large, print-friendly QR code.
- Both formats open the Android share sheet so owners can send the QR or save it to a supported destination.
- PDF uses a font-safe English heading so shops using Gujarati or Hindi names do not get missing-glyph output.

## Offline-first and privacy
- QR rendering and PDF creation happen on-device.
- QR destination is local-only metadata; it is excluded from public menu JSON.
- HTTPS URLs are required. URLs with credentials or fragments are rejected.
- No backend, database, hosting integration, upload or synchronization was added.
- Private backup and restore remain available from the app-bar backup menu, outside Publish.

## Tests and release checks
- Repository tests cover QR URL persistence, HTTPS validation, and keeping QR metadata out of public JSON.
- Widget test covers invalid-link feedback, successful QR generation and PNG/PDF actions.
- CI runs formatting, Flutter analysis/tests, customer renderer checks and a release-mode APK build.
- Main-branch APK uses the default debug signing key when production signing secrets are not configured; it is for device testing, not Play Store distribution.

## Important
A QR code can only open a menu if the pasted URL is already public and accessible to customers. MenuCard does not host or upload the menu website.