# Static customer menu template

This folder is a static-only customer menu. It contains no server-side code.

For a real publish package, the Android app will copy these files and replace menu.json with the owner's public menu export. Copy public image files into assets/images and use relative paths such as assets/images/item-01.webp in the JSON.

Test by serving this folder from any suitable static file host. Opening index.html directly from a local file manager may fail because browsers restrict fetch() from file URLs. The menu page fetches menu.json from the same hosted folder.
