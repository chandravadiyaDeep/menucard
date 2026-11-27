# UI Sitemap — MenuCard Template-First V1

## Owner app journey
1. Welcome: explain that MenuCard turns shop details and dishes into a ready-made digital menu; no design skills or account required.
2. Shop profile: shop name, optional description/logo/contact/address, default language and currency.
3. Menu setup: add categories and as many dishes as needed, with names, descriptions, prices, optional photos and availability. Support bulk-friendly repeat entry and simple editing.
4. Ready-made design gallery: browse 120 designs (10 layout families × 12 color themes), filter by layout, preview with the owner's actual shop name/dish/price, and apply one design.
5. Live preview: render the complete customer menu using the current profile, menu JSON and selected template. Changes to text/prices immediately flow into the preview.
6. Publish: export a static website ZIP, upload manually, confirm the public URL, then generate/share the QR code.
7. Manage: edit profile/menu at any time, switch templates without losing content, back up or restore the menu.

## Main navigation
- Home: guided 3-step setup progress (shop profile → dishes/prices → choose design), menu summary and publish status.
- My menu: categories, dish details, price and availability editor.
- Designs: template gallery with 120 selectable ready-made combinations.
- Publish: preview/export instructions, QR, public URL and private backup/restore.

## Template gallery
- Show the real shop name and first entered menu item in every template preview when available.
- Clearly distinguish layout family from color theme.
- Show selected design state and confirm that applying a new design keeps all menu data unchanged.
- Allow browsing before setup but require shop profile and at least one menu item before applying a design.

## Customer-facing static menu
- The selected template ID controls the responsive layout and color theme.
- Shop name, description, address, phone, language, categories, dishes, prices, availability and optional images are populated from menu.json.
- No text is manually re-entered into a template.
- Language switcher and responsive mobile layout.
- Clear status/error message if the published menu JSON cannot be loaded.

## Public one-page GitHub Pages site
- Header: MenuCard mark, Features, How it works, FAQ, Download.
- Hero: ready-made QR menu designs for neighbourhood businesses.
- Explain the 3-step workflow: enter shop details → add dishes/prices → choose a design and share.
- Show that MenuCard has 100+ ready-made menu designs.
- Download: dynamically fetch latest APK release; show “Build in progress” if none exists.
- Footer: repository, releases and privacy note.
