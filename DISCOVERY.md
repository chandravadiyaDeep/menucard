# Product Discovery — Questions to Resolve

This document records open decisions before architecture or implementation.

## 1. Confirmed positioning and platform

**Agreed:** AI-powered universal information scanner — scan something, understand it, ask questions about it, and listen to the answer.

**Agreed technology preference:** open-source-first services, open datasets, and self-hostable components wherever practical. Hosted APIs and proprietary SDKs can be considered only after reviewing cost, terms, privacy, reliability, and trade-offs.

**Agreed initial platforms:** Android + iOS.

**Agreed scanner research strategy:** compare Google Code Scanner, Google ML Kit Barcode Scanning, Apple Vision, and open-source ZXing-family options before selecting an engine. No implementation has been approved.

## 2. Scanner strategy decision

The scanner engine and camera UI are separate choices. We need to decide whether the app owns a branded camera experience or delegates the whole scan UI to a platform service.

| Candidate | Platform coverage | Camera UI ownership | Open source? | Main trade-off |
|---|---|---|---|---|
| Google Code Scanner | Android only | Google-owned scanner UI | No | Lowest camera integration effort; cannot provide one custom branded scanner UI on both platforms |
| Google ML Kit Barcode Scanning | Android + iOS | App-owned UI | No | Strong cross-platform candidate; proprietary SDK and separate platform integration |
| Apple Vision + Android counterpart | iOS native + separate Android engine | App-owned UI | No for Vision | Native iOS option; platform-specific behavior and duplicated integration |
| ZXing family / zxing-cpp | Android + iOS through maintained bindings | App-owned UI | Yes | Aligns with open-source-first principle; more camera and integration work |

Preliminary research indicates that Google Code Scanner is Android-only and supplies its own scanning interface; Google recommends the ML Kit Barcode Scanning API when a custom UI is required. ML Kit's barcode APIs are documented for both Android and iOS. Apple Vision exposes barcode detection on iOS. See OPEN_SOURCE_STACK.md for source links and the benchmark plan.

**Current direction:** keep the engine replaceable. Benchmark ML Kit on both platforms against ZXing-family implementations, and include Apple Vision as an iOS-native comparison. Treat Code Scanner as an Android-only alternative or fallback, not the sole cross-platform solution.

## 3. Product focus
- Which user group should we serve first: everyday consumers, shoppers, students, travellers, or another group?
- What should be the first standout use case?
- Should product discovery be the main differentiator, or should QR understanding and AI be equally central?
- What does “universal” mean for the first release: QR and barcodes only, or OCR/image recognition too?

## 4. Code formats and scanning
- Which QR payload types must be supported?
- Which barcode formats should be included first (EAN-13, EAN-8, UPC-A, UPC-E, Code 128, etc.)?
- Camera only, or gallery scan and manual entry too?
- What mobile framework best supports the chosen scanner adapters, camera lifecycle, and custom UI?
- What minimum device and OS versions are acceptable?
- Do we need to support Android devices without Google Play services?
- Is identical camera UI required across platforms, or is a platform-native adaptation acceptable?

## 5. Scanner validation
1. Create one shared QR/barcode test corpus and run it through each candidate on representative Android and iOS devices.
2. Measure successful decode rate by symbology and difficult condition (low light, glare, blur, rotation, damaged print, distance).
3. Measure time-to-result, duplicate detections, false positives, offline behavior, first-run downloads, app size, and battery/thermal impact.
4. Verify supported formats and exact SDK/library licenses and commercial-use terms.
5. Compare camera UI control, accessibility, lifecycle reliability, maintenance, and integration effort.
6. Select only after results are recorded; do not infer accuracy from marketing claims.

## 6. Product information and open data
- Which product categories matter first: food, beauty, books, electronics, medicine, general retail?
- Which open databases have useful coverage in the target market, especially India?
- Can we use Open Food Facts for food and evaluate other category-specific datasets separately?
- Should the app query public APIs live, use downloadable datasets, or combine both?
- How will the UI show missing, conflicting, or stale data and its source?

## 7. AI assistant
- Which three actions should be in the first release: explain, ask questions, summarize, translate, compare, or extract?
- Should AI be a contextual action panel, chat interface, or both?
- Which open-weight model meets accuracy, latency, device/server resource, and license requirements?
- Should inference run on-device, on our own server, or through a hosted open-model API?
- What content may leave the device, and what consent is required?

## 8. Read-aloud
- Should it read raw decoded content, product details, and AI answers?
- Should we start with native device text-to-speech, a self-hosted open model, or both?
- Which languages and voices matter first?
- Should speech work offline?

## 9. Privacy, accounts, and history
- Should basic scanning work without login?
- Local-only history by default, or optional sync?
- Which data is retained, for how long, and how can users delete it?
- Which features need internet access?

## 10. Platform and business model
- Android + iOS are the agreed initial targets. Which framework should be evaluated after scanner comparison?
- Free, freemium, ads, or paid?
- If AI has a cost, what limits or usage model are acceptable?
- What infrastructure budget is available for hosting open models and data services?

## 11. Validation
1. Compare scanner apps and identify a real unmet need.
2. Test a representative set of QR payloads and barcode samples.
3. Measure product database coverage for target categories and India.
4. Compare scanner engines, camera UI ownership, platform parity, and licenses.
5. Evaluate AI models for groundedness, hallucination rate, latency, and cost.
6. Test TTS language coverage and intelligibility.
7. Define an MVP and acceptance criteria before coding.

## Decision log

| Topic | Decision | Status |
|---|---|---|
| Positioning | AI-powered universal information scanner | Agreed |
| Core promise | Scan, understand, ask questions, listen | Agreed |
| Technology preference | Open-source-first; self-host where practical | Agreed |
| Initial platforms | Android + iOS | Agreed |
| Scanner research | Compare Code Scanner, ML Kit, Apple Vision, ZXing family | Agreed |
| Scanner engine | No selection yet; benchmark required | Open |
| Camera UI ownership | Prefer app-owned UI for branded experience; confirm final choice after comparison | Provisional |
| Product name | ScanWise is a temporary working name | Open |
| Target user | Not selected | Open |
| Barcode formats | Not decided | Open |
| Product data sources | Research required | Open |
| AI model / hosting | Research required | Open |
| TTS approach / languages | Not decided | Open |
| Accounts / sync | Not decided | Open |
| Monetization | Not decided | Open |
