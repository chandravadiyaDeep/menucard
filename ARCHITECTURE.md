# Proposed Architecture — Android + iOS Universal Scanner

**Status:** Discovery proposal only. This is a logical architecture, not an implementation specification. No framework, scanner engine, or dependency is approved.

## 1. Architectural goals

- Ship on Android and iOS.
- Own the product's camera experience and visual identity where a branded scanner is required.
- Delegate code detection/decoding to replaceable scanner engines rather than writing a decoder from scratch.
- Keep platform-specific camera and scanner integrations behind stable internal interfaces.
- Keep scan, classification, enrichment, AI, and speech concerns independent.
- Preserve basic scan/decode functionality when network, catalogue, AI, or speech services are unavailable.
- Prefer open-source components, while documenting any proprietary SDK trade-off.

## 2. Logical flow

```text
User
  |
  v
App UI / Navigation
  |
  +--> Camera Experience
  |      - permission and lifecycle
  |      - camera preview and frame capture
  |      - scan guide / overlay
  |      - torch, focus, zoom, feedback
  |
  v
Scanner Adapter Interface
  |
  +--> Android providers (candidate engines)
  |      - Google ML Kit Barcode Scanning
  |      - Google Code Scanner (Android-only UI alternative)
  |      - ZXing-family implementation
  |
  +--> iOS providers (candidate engines)
         - Google ML Kit Barcode Scanning
         - Apple Vision
         - ZXing-family implementation
  |
  v
Normalized Scan Result
  |
  v
Content Classifier
  |
  +--> QR payload parser / safe-action resolver
  |
  +--> Barcode identifier resolver
           |
           v
      Product Data Adapters
           |
           v
      Evidence / Provenance Layer
           |
           v
      Context Builder (user-approved data only)
           |
           +--> AI Provider Adapter
           |
           +--> Speech / TTS Adapter
  |
  v
Result UI / History / Share
```

## 3. Scanner and camera boundary

The camera layer owns permission prompts, preview, frame lifecycle, focus/torch controls, zoom, visual scan frame, and user feedback. The scanner adapter receives frames or images and returns normalized scan observations.

A normalized observation should include, where the provider supplies it:
- raw decoded value;
- symbology / format;
- parsed payload type and structured fields;
- bounding box or corner points;
- timestamp;
- provider and relevant diagnostic metadata.

Provider-specific types must not leak into feature screens. The adapter should handle provider initialization, model availability/download state, errors, duplicate-frame suppression, and disposal.

## 4. Candidate provider matrix

| Platform | Candidate | Role | Current status |
|---|---|---|---|
| Android | Google ML Kit Barcode Scanning | Custom app-owned camera UI + on-device decoding | Benchmark candidate |
| Android | Google Code Scanner | Google-managed ready-made scanner UI | Android-only alternative; not the branded primary flow |
| Android | ZXing-family / zxing-cpp | Open-source decoding option | Benchmark candidate |
| iOS | Google ML Kit Barcode Scanning | Custom app-owned camera UI + on-device decoding | Benchmark candidate |
| iOS | Apple Vision | Native on-device barcode detection | Benchmark candidate |
| iOS | ZXing-family / zxing-cpp | Open-source decoding option | Benchmark candidate |

Google ML Kit and Apple Vision are proprietary SDKs. ZXing-family candidates are open-source, but their maintained bindings, camera integration, supported symbologies, and performance need validation. See OPEN_SOURCE_STACK.md.

## 5. Normalized processing pipeline

1. **Capture:** camera frames or a selected still image.
2. **Detect/decode:** scanner provider returns zero or more observations.
3. **Normalize:** map provider-specific results to the internal scan-result model.
4. **De-duplicate:** avoid repeated results from the same code while allowing deliberate rescans.
5. **Classify:** identify QR payload type or barcode identifier.
6. **Resolve:** parse safe QR content or query category-specific catalogue adapters for barcode identifiers.
7. **Assemble evidence:** retain source, retrieval time, fields, and confidence/quality indicators where available.
8. **Explain:** send only the minimum user-approved context to the AI provider.
9. **Speak:** read selected content through platform TTS or an approved speech provider.
10. **Present:** distinguish raw decoded content, retrieved facts, and AI-generated explanations.

## 6. Cross-platform app structure

The eventual app framework is undecided. The chosen framework must be evaluated against:
- camera preview and native frame access on Android and iOS;
- stable access to each candidate scanner engine;
- custom overlay and animation performance;
- permission and background/foreground lifecycle handling;
- flashlight, focus, zoom, and gallery-image support;
- maintainability of native Kotlin/Swift bridges if required;
- accessibility and platform conventions;
- build, signing, release, and testing workflows.

Do not select Flutter, React Native, or fully native development until the scanner benchmark and framework compatibility review are complete.

## 7. Privacy and security boundaries

- Camera frames should remain on-device for scanning unless a separate feature explicitly requires upload and the user consents.
- Do not send scan payloads to AI automatically. Explain the data flow and require user action.
- Treat decoded text, URLs, QR payloads, catalogue fields, and external page content as untrusted data.
- Scanning a URL must not automatically navigate to it. Show a safe preview and require confirmation.
- Never automatically call a number, connect to Wi-Fi, add a contact, create an event, or initiate a payment.
- Keep local scan history as the default candidate; final retention and sync behavior remains open.

## 8. Scanner evaluation gate

Before selecting a provider or framework:
1. Create a common QR/barcode corpus and device matrix.
2. Run each candidate against the same images and live-camera scenarios.
3. Compare decode success by format and difficult condition.
4. Measure time-to-result, false positives, duplicate detections, offline behavior, first-run download behavior, app size, and battery/thermal impact.
5. Validate exact supported formats, license terms, commercial use, maintenance status, and platform requirements.
6. Record results in OPEN_SOURCE_STACK.md and make a documented selection.

## 9. Decisions not yet made

- Mobile framework.
- Scanner engine per platform.
- Whether camera UI must be pixel-identical or may be platform-adapted.
- Minimum supported Android/iOS versions and device requirements.
- Exact QR payload and barcode format scope.
- Gallery scan and manual barcode entry.
- Product catalogue sources and caching.
- AI model and inference hosting.
- TTS engine and initial language coverage.
- History, accounts, sync, and monetization.

## 10. Implementation status

No application code or dependencies have been added as part of this architecture proposal. This document is for discussion and research only.
