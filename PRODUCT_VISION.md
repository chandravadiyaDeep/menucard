# Product Vision — QR & Barcode Scanner with AI

**Status:** Draft for discussion  
**Working name:** ScanWise (not final)

## 1. Vision
Build a smart everyday scanner that helps a person move from **scanning a code** to **understanding the information behind it**.

A user points the camera at a QR code or barcode. The app identifies the code, decodes it, and presents the result in a detailed, easy-to-understand screen. Where reliable information is available, the app can enrich the result with relevant context. The user can read the content, listen to it aloud, and use built-in AI tools to ask questions or get explanations.

The product should be more useful than a camera that only displays raw code text or opens a link without context.

## 2. The core user journey
1. **Open scanner** — the user sees a simple camera-first scanning experience.
2. **Scan** — the app detects a QR code or supported barcode.
3. **Identify** — the app determines the code format and extracts its content or identifier.
4. **Understand** — the app displays the decoded result with a clear title, useful details, and suitable actions.
5. **Explore** — the user can ask AI to explain, summarize, translate, or clarify the information.
6. **Listen** — the user can use text-to-speech / read-aloud to hear supported content.
7. **Continue** — the user can copy, share, open, save, or revisit the scan where appropriate.

## 3. What “full information” should mean
The app should aim to show the most useful information that can be reliably obtained for the scanned code. It must not imply that every code contains a complete profile or that the app can always identify an unknown item.

### QR codes
A QR code may contain plain text, a web address, contact details, Wi-Fi configuration, an email address, a phone number, an event, payment-related data, or another structured payload.

The app should:
- Show the decoded payload in a readable format.
- Recognize common QR content types and present relevant actions.
- Preview links and explain the destination domain before opening.
- Clearly label content that cannot be interpreted or verified.

### Product barcodes
A product barcode usually contains an identifier, not a complete product description. The app may use that identifier to look up product information from an external or locally available catalogue.

Where data is found, a product detail view could include:
- Product name and brand.
- Product image, if a trustworthy source provides one.
- Category and product description.
- Manufacturer or other catalogue details where available.
- Source attribution and the date or status of retrieved information when practical.

If no reliable match exists, show the barcode number and say that product details were not found. Never invent product facts.

## 4. AI capabilities — candidate direction
AI should make scanned information easier to understand, not fabricate missing facts. Candidate capabilities include:
- **Explain:** explain a product, QR payload, label, or technical term in simple language.
- **Summarize:** turn long decoded text or retrieved information into key points.
- **Ask AI:** let users ask questions about the current scan.
- **Translate:** translate supported text into a selected language.
- **Read aloud:** speak the decoded or summarized content using text-to-speech. This is an accessibility and convenience feature, not necessarily an AI feature.
- **Compare:** compare two scanned products when enough trustworthy data is available.
- **Extract:** identify and organize useful fields from supported text or structured content.
- **Safety-aware link help:** explain visible URL details and warn about suspicious patterns without claiming a link is safe.

AI responses should distinguish between decoded content, information retrieved from a source, and AI-generated interpretation. When possible, show sources for external facts. If evidence is missing, the AI should say so.

## 5. Intended users and use cases
Potential users include:
- People who scan products while shopping and want to understand what they are looking at.
- People who scan QR codes for websites, menus, events, contact details, or Wi-Fi.
- People who want long or unfamiliar content explained in simpler language.
- People who benefit from listening instead of reading.
- People who need a scan history to revisit previously scanned information.

These are hypotheses to validate through discovery, not a finalized target-market decision.

## 6. Product principles
1. **Scan first:** the primary action should be immediately obvious.
2. **Useful detail:** present information in a structured, readable way rather than dumping raw text.
3. **Honest results:** separate decoded facts, catalogue lookups, and AI interpretation.
4. **Privacy by design:** process locally where possible; explain clearly whenever content is sent to an external service.
5. **Safe actions:** do not automatically open links, join networks, call numbers, or initiate payments just because a code was scanned.
6. **Accessible by default:** support readable layouts, adjustable text where practical, and read-aloud.
7. **Fast and dependable:** scanning and decoding should work without an AI request.
8. **Graceful failure:** show the raw code result when enrichment is unavailable.

## 7. Trust, privacy, and safety
- Ask for camera permission only when needed and explain why.
- Do not upload camera frames by default.
- Do not send scan contents to an AI provider without clear disclosure and an appropriate user action.
- Treat scanned text and QR payloads as untrusted input. A scanned payload must never be allowed to override app or AI safety instructions.
- Preview web destinations and require user action before opening them.
- Avoid presenting catalogue information as verified if the source is incomplete or unreliable.
- Do not claim that a barcode or QR code is safe, authentic, or genuine solely because it scans successfully.
- Define how scan history is stored, protected, exported, and deleted before release.

## 8. Initial product boundaries
The first version should focus on:
- Camera scanning for selected QR formats and common product barcode formats.
- Accurate decoding and useful result presentation.
- Basic actions appropriate to each content type.
- A read-aloud option for readable text.
- A small, clearly scoped set of AI actions, subject to cost, privacy, and quality validation.

The exact barcode formats, data providers, AI model/provider, supported languages, offline behavior, account model, and monetization are not yet decided.

## 9. What success looks like
A user can scan a supported code quickly, understand what it contains, find relevant details when reliable data exists, and choose to read, listen, or ask for an explanation — without being misled about what the app knows.
