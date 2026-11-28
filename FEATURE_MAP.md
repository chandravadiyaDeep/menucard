# Feature Map — Candidate Capabilities

**Status:** Exploration only. Nothing in this file is approved for implementation yet.

## 1. Scanner
| Capability | Description | Priority hypothesis |
|---|---|---|
| QR scanning | Detect and decode supported QR codes using the camera | Core |
| Barcode scanning | Detect common retail/product barcode formats | Core |
| Flashlight | Toggle torch in low-light conditions | Core |
| Gallery scan | Select an image and detect a code inside it | Candidate |
| Scan feedback | Haptic, sound, or visual feedback after a successful scan | Candidate |
| Manual entry | Enter a barcode number or paste QR content | Candidate |
| Duplicate handling | Avoid repeatedly creating identical history entries | Candidate |

## 2. Result and detail screen
The result screen should adapt to the detected content type.

| Content type | Possible presentation |
|---|---|
| Product barcode | Product identity and catalogue details when a reliable match exists |
| Website URL | URL, domain, preview context, and an explicit open action |
| Plain text | Readable text with copy, share, translate, summarize, and read-aloud actions |
| Contact card | Parsed contact fields with user-controlled save action |
| Wi-Fi payload | Network details with sensitive fields handled carefully; never connect automatically |
| Email / phone | Address or number with explicit user-controlled actions |
| Event / calendar | Parsed event details and optional calendar action |
| Unknown / unsupported | Raw decoded content, code format, and copy action |

## 3. Information enrichment
- Search a product catalogue using a decoded barcode identifier.
- Display the source of retrieved product data.
- Indicate when details are missing, incomplete, or unavailable.
- Avoid merging conflicting catalogue records without telling the user.
- Allow users to report incorrect product information (future candidate).

Important distinction: a barcode generally identifies an item through a number. The barcode itself does not contain all product details. Product information depends on the coverage and quality of the catalogue provider.

## 4. Read-aloud and accessibility
- Read decoded text or selected detail sections aloud.
- Play / pause / resume / stop controls.
- Allow the user to choose a supported voice or speech rate where the platform permits.
- Highlight the currently spoken text if feasible.
- Respect device accessibility settings.
- Do not automatically speak sensitive content in public or without user initiation.

Read-aloud is a core candidate feature because the vision explicitly includes listening to scan results.

## 5. In-app AI assistant
Potential contextual actions:
- Explain this.
- Summarize this.
- Translate this.
- Ask a question.
- Compare with another scan.
- Extract key details.

AI guardrails:
- Ground answers in the decoded content and clearly identified retrieved sources.
- Do not invent missing product specifications, ingredients, prices, origins, certifications, or safety claims.
- Tell the user when the app has insufficient information.
- Clearly label generated summaries and explanations.
- Make external AI processing visible and user-controlled.
- Provide an option to use basic scanning without AI.

## 6. Scan history and saved items
Candidate capabilities:
- Recent scans.
- Search and filter history.
- Reopen a previous result.
- Favorites or saved items.
- Delete one item or clear all history.
- Optional export or share.

History storage model and retention defaults need a privacy decision before implementation.

## 7. Potential later capabilities
These may be considered only after the core scanner experience is validated:
- Product comparison.
- Price comparison from permitted sources.
- Ingredient or label explanation where trustworthy data exists.
- Expiry / batch / lot information when encoded or sourced reliably.
- Document or label OCR (separate from barcode decoding).
- More advanced AI workflows.

## 8. Non-goals for the first version (provisional)
- Claiming that every QR code or barcode can be fully identified.
- Automatically opening links or taking actions after a scan.
- Making medical, nutritional, legal, or product-authenticity guarantees.
- Building a general-purpose AI chatbot unrelated to scans before the scanner experience works well.
- Requiring login just to perform a basic scan unless a validated requirement emerges.
