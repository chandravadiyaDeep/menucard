# Product Discovery — Questions to Resolve

This document records open decisions before architecture or implementation.

## 1. Confirmed positioning

**Agreed:** AI-powered universal information scanner — scan something, understand it, ask questions about it, and listen to the answer.

**Agreed technology preference:** open-source-first services, open datasets, and self-hostable components wherever practical. Hosted APIs can be considered when their cost, terms, privacy, and reliability are acceptable.

## 2. Product focus
- Which user group should we serve first: everyday consumers, shoppers, students, travellers, or another group?
- What should be the first standout use case?
- Should product discovery be the main differentiator, or should QR understanding and AI be equally central?
- What does “universal” mean for the first release: QR and barcodes only, or OCR/image recognition too?

## 3. Code formats and scanning
- Which QR payload types must be supported?
- Which barcode formats should be included first (EAN-13, EAN-8, UPC-A, UPC-E, Code 128, etc.)?
- Camera only, or gallery scan and manual entry too?
- Which maintained open-source scanner library best fits the selected mobile framework and license requirements?

## 4. Product information and open data
- Which product categories matter first: food, beauty, books, electronics, medicine, general retail?
- Which open databases have useful coverage in the target market, especially India?
- Can we use Open Food Facts for food and evaluate other category-specific datasets separately?
- Should the app query public APIs live, use downloadable datasets, or combine both?
- How will the UI show missing, conflicting, or stale data and its source?

## 5. AI assistant
- Which three actions should be in the first release: explain, ask questions, summarize, translate, compare, or extract?
- Should AI be a contextual action panel, chat interface, or both?
- Which open-weight model meets accuracy, latency, device/server resource, and license requirements?
- Should inference run on-device, on our own server, or through a hosted open-model API?
- What content may leave the device, and what consent is required?

## 6. Read-aloud
- Should it read raw decoded content, product details, and AI answers?
- Should we start with native device text-to-speech, a self-hosted open model, or both?
- Which languages and voices matter first?
- Should speech work offline?

## 7. Privacy, accounts, and history
- Should basic scanning work without login?
- Local-only history by default, or optional sync?
- Which data is retained, for how long, and how can users delete it?
- Which features need internet access?

## 8. Platform and business model
- Android first, iOS first, or cross-platform?
- Free, freemium, ads, or paid?
- If AI has a cost, what limits or usage model are acceptable?
- What infrastructure budget is available for hosting open models and data services?

## 9. Validation
1. Compare scanner apps and identify a real unmet need.
2. Test a representative set of QR payloads and barcode samples.
3. Measure product database coverage for target categories and India.
4. Compare candidate open-source scanner libraries and their licenses.
5. Evaluate AI models for groundedness, hallucination rate, latency, and cost.
6. Test TTS language coverage and intelligibility.
7. Define an MVP and acceptance criteria before coding.

## Decision log

| Topic | Decision | Status |
|---|---|---|
| Positioning | AI-powered universal information scanner | Agreed |
| Core promise | Scan, understand, ask questions, listen | Agreed |
| Technology preference | Open-source-first; self-host where practical | Agreed |
| Product name | ScanWise is a temporary working name | Open |
| Target user | Not selected | Open |
| Platforms | Not decided | Open |
| Barcode formats | Not decided | Open |
| Product data sources | Research required | Open |
| AI model / hosting | Research required | Open |
| TTS approach / languages | Not decided | Open |
| Accounts / sync | Not decided | Open |
| Monetization | Not decided | Open |
