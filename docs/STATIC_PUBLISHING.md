# Public Menu URL and QR Code — V1.1.3

## What the Publish tab does
The Publish tab has one job: turn a public menu URL into a QR code that can be displayed, exported and shared.

1. Host the customer-facing menu website at a public HTTPS URL using a hosting service you control.
2. Paste that URL into MenuCard's Publish tab.
3. Tap **Generate QR code**.
4. Preview the QR code, then choose **Export / share PNG** or **Export / share PDF**.
5. Use the Android share sheet to send the file or save it to a supported destination.

The QR code contains only the public URL. It does not contain the menu data itself.

## Important architecture boundary
- MenuCard remains offline-first. The QR URL is saved in the local JSON document.
- QR image generation and PDF creation run on the device.
- MenuCard does not host the public menu, upload website files, or create a hosting account.
- Customers need internet access to open the public HTTPS URL.
- The QR URL is local-only metadata and is never included in the public menu JSON.
- Existing saved publishedUrl values are used as the initial QR URL for backward compatibility.

## Changing the destination
Paste a new public HTTPS URL and generate the QR code again. Print or share the new QR image/PDF. Previously printed QR codes continue to point to the old URL.

## Backup
Private menu backup and restore remain available from the app-bar backup menu. They are separate from QR creation and do not appear in the Publish tab.

## Troubleshooting
- QR scanner reports an invalid link: confirm the URL starts with HTTPS and has no login credentials or fragment.
- QR opens a 404 page: confirm the hosted menu URL is correct and publicly accessible.
- QR image/PDF is not sent: choose another compatible destination in the Android share sheet, or save it to the device first.
- A QR opens an old menu: the hosting URL is unchanged, but the files at that URL may not have been updated. MenuCard does not perform uploads or cache invalidation.

## Privacy
Anyone who scans or receives the QR image can open the URL. Do not use private or password-protected URLs as a customer menu link.