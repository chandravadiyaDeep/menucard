# Product Discovery — Questions to Resolve

This document records open decisions. Discuss and update it before committing to architecture or implementation.

## 1. Product positioning
- Is this primarily a fast QR and barcode scanner, or an AI-powered product information assistant?
- What is the single strongest reason someone would keep this app instead of using the phone's built-in camera?
- Should product information lookup be the standout feature, or should the app treat all QR payload types equally?
- Who is the first target user: everyday consumers, shoppers, students, travellers, or a broader audience?

## 2. Supported codes
- Which QR payload types must be supported in the first release?
- Which barcode formats matter most (for example EAN-13, EAN-8, UPC-A, UPC-E, Code 128)?
- Should the first release scan from camera only, or also from saved images?
- Is manual barcode entry required?

## 3. Product information
- Which product categories should be supported first?
- Which product data provider or open catalogue should be evaluated?
- What should the app show when the barcode is valid but no product record exists?
- Should users be able to correct or contribute product details?
- How should conflicting or stale catalogue information be displayed?

## 4. AI experience
- Should AI appear as suggested action buttons on each result, a chat interface, or both?
- Which three AI actions are most valuable for the first release?
- Should users be able to ask follow-up questions about one scan?
- Which languages should be supported initially?
- Which AI provider and cost model should be evaluated?
- What data may be sent to the AI provider, and only after what consent?

## 5. Read-aloud
- Should read-aloud speak only decoded text, or also product details and AI summaries?
- Should it support language detection and multiple voices?
- Should it work offline using device text-to-speech?
- What controls are essential: play, pause, resume, stop, and speed?

## 6. Privacy and accounts
- Should scanning work without an account?
- Should history be stored only on-device by default?
- Should users be able to sync history across devices?
- Which actions require network access?
- How can users inspect and delete their data?

## 7. Platform and business model
- Android first, iOS first, or cross-platform from the beginning?
- Is the app intended to be free, ad-supported, freemium, or paid?
- If AI has usage limits, how should they be communicated?
- What is the expected budget for data APIs and AI usage?

## 8. Validation plan
Before implementation:
1. Compare existing scanner apps and identify unmet needs.
2. Test sample QR payloads and product barcode datasets.
3. Evaluate product catalogue coverage for the target market.
4. Prototype the scan-to-detail flow.
5. Test AI answers for accuracy, unsupported claims, latency, and cost.
6. Test read-aloud with different content lengths and languages.
7. Agree on an MVP and measurable acceptance criteria.

## Decision log
| Topic | Decision | Status |
|---|---|---|
| Product category | QR and barcode scanner with contextual AI capabilities | Initial direction |
| Read-aloud | Include as a candidate accessibility feature | Proposed |
| Product name | ScanWise is a temporary working name | Open |
| Platforms | Not decided | Open |
| Barcode formats | Not decided | Open |
| Data provider | Not decided | Open |
| AI provider | Not decided | Open |
| Accounts and sync | Not decided | Open |
| Monetization | Not decided | Open |
