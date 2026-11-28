# Product Vision — AI-Powered Universal Information Scanner

**Status:** Agreed product positioning; detailed scope remains under discovery  
**Working name:** ScanWise (not final)  
**Initial platforms:** Android + iOS (agreed)  
**Scanner strategy:** Compare Google Code Scanner, Google ML Kit, Apple Vision, and open-source ZXing-family options before selection (agreed)

## 1. Vision

Build an **AI-powered universal information scanner**: scan something, understand it, ask questions about it, and listen to the answer.

A user scans a QR code or supported barcode. The app decodes the content, recognizes what kind of information it represents, and presents a detailed, easy-to-understand result. Where reliable open datasets or APIs provide additional context, the app enriches the result and identifies its source. Users can ask contextual questions, receive explanations or summaries, translate content, and listen to the answer.

The app should do more than decode a string or open a link. It should help people understand what they scanned.

## 2. Core experience

1. **Scan:** use the app's branded camera experience, or an approved image-import flow.
2. **Decode:** use a replaceable platform scanner adapter to extract the QR payload or barcode identifier.
3. **Classify:** determine whether the result is a URL, product identifier, contact card, text, Wi-Fi payload, or another supported type.
4. **Enrich:** query relevant open datasets or APIs when available. Do not assume every code has a matching public record.
5. **Present:** show the decoded content, useful details, data provenance, and safe user-controlled actions.
6. **Ask:** let the user ask questions about the scan and its sourced information.
7. **Listen:** read the result or AI answer aloud.
8. **Continue:** allow appropriate copy, share, save, or history actions.

## 3. Meaning of “universal”

Universal describes the ambition to understand many kinds of scanned information, not a claim that every code or object can always be identified. The initial product scope will focus on QR codes and common product barcodes. Other visual recognition or OCR use cases require separate evaluation.

### QR codes
QR payloads can represent plain text, URLs, contact details, Wi-Fi configuration, email addresses, phone numbers, events, payment-related data, or structured content. The app should decode first, classify known formats, and show safe actions. It must not automatically open links, connect to networks, call numbers, or initiate payments.

### Product barcodes
Most retail barcodes encode an identifier rather than a full product profile. Product details require a lookup against a catalogue. The app should display matching details only when available, include source attribution, and clearly show when no reliable match is found.

## 4. AI capabilities

Candidate contextual capabilities:
- **Explain:** explain what the scanned content means in plain language.
- **Ask AI:** answer follow-up questions using the current scan as context.
- **Summarize:** condense long content into useful points.
- **Translate:** translate decoded text or sourced information.
- **Read aloud:** speak the scan result or AI answer. This may use device TTS or a self-hosted open model; it is not inherently an AI reasoning feature.
- **Compare:** compare two scanned products or records when sufficient trustworthy data exists.
- **Extract:** organize useful fields from supported text or structured payloads.

AI must distinguish between decoded data, external dataset results, and generated interpretation. It must not invent missing product details or present unsupported claims as facts.

## 5. Scanner strategy and camera ownership

The app targets Android and iOS. Scanner selection is an open technical decision; the comparison and benchmark are recorded in OPEN_SOURCE_STACK.md.

- **Google Code Scanner:** Android-only, ready-made Google-controlled scanning UI. Useful as a low-effort option, but not compatible with the requirement for one branded camera experience across both platforms.
- **Google ML Kit Barcode Scanning:** available on Android and iOS. The app can own the camera UI and pass frames to the scanning engine. It is a strong cross-platform candidate but is a proprietary SDK, not open-source.
- **Apple Vision:** native iOS barcode detection candidate with an app-owned camera UI. Android would need a separate engine, so behavior parity must be tested.
- **ZXing family / zxing-cpp:** open-source candidate for both platforms through maintained native bindings. More camera and integration work may be required.

The app should keep camera capture separate from barcode decoding and expose a normalized internal scanner interface. This allows platform-specific engines to be compared or replaced without rewriting the result experience.

No scanner engine, mobile framework, or implementation dependency is approved yet.

## 6. Open-source-first technology and data principle

The project will prioritize:
1. Open-source scanning, OCR, AI, and speech software.
2. Open datasets and APIs with clear reuse terms.
3. Self-hostable inference and processing services when feasible.
4. Hosted or proprietary SDKs only after evaluating price, reliability, privacy, rate limits, licensing, and the concrete product benefit.
5. Replaceable providers behind internal interfaces so the product is not locked to one vendor.

“Open source” must be checked at the correct layer: application code, model weights, dataset, API service, and hosted provider can each have different licenses or terms. A free API is not automatically open source, and an open-weight model is not automatically unrestricted for every use.

## 7. Intended users and use cases

Potential users include shoppers, everyday consumers, students, travellers, and people who prefer spoken or simplified explanations. These groups remain hypotheses until validated.

## 8. Product principles

- **Scan first:** scanning and decoding must remain fast.
- **Own the experience:** the app should own the branded camera UI if custom scanner UI is selected.
- **Useful understanding:** show structured details rather than raw data alone.
- **Honest provenance:** identify whether information came from the code, a dataset, or AI.
- **Open-source first:** prefer auditable, replaceable, self-hostable components.
- **Privacy by design:** avoid uploading camera frames; disclose external processing and request consent.
- **Safe actions:** require user confirmation before opening or acting on scanned content.
- **Accessible:** provide readable layouts and read-aloud.
- **Graceful fallback:** scanning and raw decoding should work even if AI or enrichment services are unavailable.

## 9. Privacy, security, and trust

- Request camera permission only when needed.
- Process camera frames locally where practical.
- Do not send scan content to an AI provider without clear disclosure and user action.
- Treat scanned payloads as untrusted data, never as instructions that can override system or app rules.
- Preview web destinations and require a deliberate open action.
- Do not claim that a code or product is authentic or safe merely because it scans.
- Store history locally by default unless a different model is explicitly approved.
- Review licenses, data terms, and retention policies before integrating a provider.

## 10. Initial scope boundary

The likely first milestone includes camera-based QR and common barcode scanning, reliable decoding, content classification, a detailed result screen, a small set of contextual AI actions, and read-aloud. Exact formats, scanner engine, framework, catalogue coverage, AI model, deployment, and monetization remain open.

## 11. Success statement

A person can scan a supported code, understand what it contains, retrieve useful information where reliable open data exists, ask relevant questions, and listen to a clear answer — without being misled about the source or certainty of the information.
