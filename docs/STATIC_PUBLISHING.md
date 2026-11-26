# Manual Static JSON Publishing — V1

## Purpose
This is the approved Option B publishing process. MenuCard creates the menu and website files on the owner's Android phone. The owner manually uploads those files to a static hosting provider. The hosting provider only serves files; no MenuCard server-side code runs there.

## What is required
- MenuCard Android app with a locally saved menu.
- A static hosting provider whose current terms permit the shop's intended commercial use and static website hosting.
- A hosting site/folder with a stable HTTPS URL and the ability to replace files.
- Internet access only for the manual upload and for customers opening the public menu.

MenuCard does not create hosting accounts, upload files, manage provider credentials or publish automatically.

## First-time publishing
1. Finish the shop profile and menu in MenuCard. Preview it locally.
2. Open Publish menu and choose Export website package.
3. The app validates the JSON and packages a ZIP with index.html, menu.json, assets/menu.css, assets/menu.js and any referenced public images.
4. Save the ZIP to the phone or share it to a computer.
5. Create a static site using the hosting provider's manual upload flow. Upload the ZIP or extract it and upload the package contents, depending on the provider's instructions.
6. Open the resulting public HTTPS URL. Confirm the shop name, menu items, prices, language and images are correct.
7. Copy the public page URL into MenuCard and tap Confirm published. This confirmation is a local record; it is not an automated server verification.
8. Generate the QR code. It contains only the public HTTPS page URL. Download, print or share it.

## Publishing an update
1. Make edits in MenuCard. The local JSON revision increases.
2. Preview the new revision and export a fresh website package.
3. Open the same static hosting site and replace the previous package files at the same path. Do not create a new site or folder if the QR URL must remain unchanged.
4. Open the existing QR URL in a private/incognito browser or refresh it. Check the revision/update time and verify the changed content.
5. Return to MenuCard and confirm that this revision has been published.

If the host changes the URL, the owner must update the saved URL and regenerate/reprint the QR code.

## What customers experience
- The QR opens a static customer page.
- The page reads menu.json from the same hosted folder and renders the menu in the browser.
- Customers see the last package that the owner successfully uploaded.
- Local edits that have not been uploaded are private to the owner's device.
- There is no ordering, payment, table booking or customer account feature.

## Revision states
MenuCard must show three separate values:
- Local revision: newest on-device changes.
- Exported revision: latest package created for upload.
- Confirmed published revision: revision the owner says they uploaded and checked.

Exporting is not publishing. Never mark a revision published automatically when the ZIP is created or shared.

## Cache and update reliability
Static hosts and CDNs may cache files. The customer viewer requests menu.json with cache revalidation/no-store, but the hosting provider must also allow menu.json to be revalidated or set to a short cache lifetime. If a provider serves stale JSON indefinitely, it is unsuitable for this workflow. The customer page displays the revision and updated timestamp so an owner can check the uploaded version.

## Privacy and security
- Everything in the publish package is public and can be downloaded by anyone with its URL.
- Export only the shop details, translations, categories, items and images the owner intends customers to see.
- Never export phone-private paths, local backup data, device identifiers, tokens, passwords or provider credentials.
- Use HTTPS. Do not place private information in menu descriptions or images.
- The hosting account is managed by the owner. MenuCard does not store its password or access token.

## Troubleshooting
- Page opens but menu is blank: confirm menu.json is in the same folder as index.html and valid JSON.
- Images are missing: preserve the assets/images folder structure and relative image paths.
- Old menu still appears: re-upload all files, confirm menu.json changed, then test in a private browser. Check the host's cache settings.
- QR points to a 404: verify that the hosting path has not changed and that index.html is at the URL's expected location.
- Upload failed: local menu data is unaffected. Retry the manual upload; do not delete the local menu.

## Important hosting note
GitHub Pages remains the MenuCard product landing-page host. Do not assume it is the right production host for individual shops' commercial menus. Each shop owner must choose a static hosting provider and review its current terms, limits, privacy and cache behavior before publishing.
