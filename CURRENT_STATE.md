# Current State

**Last updated:** 2026-11-28  
**Project phase:** Product discovery and technical comparison  
**Positioning:** AI-powered universal information scanner  
**Working name:** ScanWise (temporary; not approved)  
**Initial platforms:** Android + iOS (agreed)  
**Scanner strategy:** Compare multiple engines before selection (agreed)

## Confirmed direction
- Product promise: scan something, understand it, ask questions about it, and listen to the answer.
- Start with QR codes and supported product barcodes.
- Initial target platforms are Android and iOS.
- Compare Google Code Scanner, Google ML Kit Barcode Scanning, Apple Vision, and open-source ZXing-family options before selecting a scanner.
- Prefer open-source software, open datasets, and self-hostable services.
- Keep providers replaceable and disclose when data is processed externally.
- No implementation is approved yet.

## Scanner comparison findings
- Google Code Scanner is Android-only and provides a Google-controlled ready-made scanning UI. It is not suitable as the sole engine if the app needs one branded camera experience across Android and iOS.
- Google ML Kit Barcode Scanning supports Android and iOS. With the Barcode Scanning API, the app can own the camera UI and send frames to the scanner.
- Apple Vision provides native barcode detection on iOS and is a platform-specific comparison candidate.
- ZXing-family / zxing-cpp options are open-source candidates but require validation of maintained bindings, camera integration, supported formats, and performance.
- ML Kit and Apple Vision are proprietary SDKs; they are not open-source. Their possible use must be treated as an explicit trade-off against the open-source-first preference.
- Preliminary recommendation: benchmark ML Kit on both platforms against ZXing-family implementations, and include Apple Vision on iOS. Keep the scanner adapter replaceable. This is not a final engine selection.

Official references and detailed comparison are in OPEN_SOURCE_STACK.md.

## Repository reset
- The previous MenuCard product content was removed from the main branch by a reset commit.
- The main branch was verified empty immediately after the reset.
- Other branches, tags, releases, uploaded release assets, and historical Git commits may still contain the old project. Their cleanup was not completed through the available GitHub connection.
- Do not assume the entire repository history or release archive has been erased.

## Current documentation
- README.md
- PRODUCT_VISION.md
- FEATURE_MAP.md
- DISCOVERY.md
- OPEN_SOURCE_STACK.md
- CURRENT_STATE.md

## Technology research status
Initial candidates documented in OPEN_SOURCE_STACK.md:
- Scanner: compare ML Kit (Android + iOS), Android-only Google Code Scanner, Apple Vision (iOS), and open-source ZXing-family options.
- Product data: Open Food Facts for food products; investigate category-specific and India-focused sources.
- AI: Ollama for local/self-hosted inference with a suitable open-weight model.
- Read-aloud: device TTS first as a baseline; evaluate Kokoro or other self-hosted open TTS.
- OCR: PaddleOCR only if label/image text recognition becomes part of the approved scope.

These are research candidates, not final architecture decisions.

## Still undecided
- Final name and branding.
- First target user and primary differentiator.
- Scanner engine and final camera UI behavior.
- Mobile framework and minimum OS/device requirements.
- QR payload and barcode format support.
- Product database providers and coverage.
- AI model, hosting, resource requirements, and usage budget.
- TTS engine and language support.
- Offline behavior, history, accounts, and sync.
- Monetization and MVP acceptance criteria.

## Working rules
1. Do not bring back MenuCard restaurant, cinema, table, seat, or menu requirements.
2. Do not implement features until scope and MVP are discussed and approved.
3. Keep discovery, architecture, implementation, and release status separate.
4. After each development task, update this file with changes, tests actually run, results, known issues, and next step.
5. Never claim a feature is tested unless an actual test was run.
6. Add useful comments to code where they clarify non-obvious logic.
7. Prefer privacy-conscious defaults and explain external data or AI processing.
8. Distinguish decoded content, external dataset results, and AI-generated interpretation.
9. Record license and data-use terms before adopting software, models, or datasets.
10. If a task cannot be completed with available tools, state exactly what remains manual.

## Next step
Complete scanner research and define a representative benchmark corpus. Then decide the first user segment, first scan categories, first three AI capabilities, and mobile framework before architecture freeze or coding.
