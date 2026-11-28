# Open-Source Stack Research

**Status:** Research shortlist updated for Android + iOS; no scanner implementation selected.

The product prefers open-source software, open datasets, and self-hostable services. Google ML Kit and Apple Vision are technically attractive native SDKs, but they are not open-source libraries. Their inclusion is an explicit pragmatic option, not a change to the open-source-first principle. A free SDK/API is not automatically open source.

## 1. Scanner strategy comparison (Android + iOS)

The scanner engine and the camera UI are separate architectural concerns. The product should own the camera experience wherever a custom branded scanner is required, while delegating barcode detection/decoding to a platform engine behind one internal interface.

### Option A — Google Code Scanner (Android only, ready-made UI)
- Official docs: https://developers.google.com/ml-kit/vision/barcode-scanning/code-scanner
- Uses Google Play services to provide a complete scanning UI and returns a decoded Barcode object.
- Does not require the app to implement camera permission or camera UI; image processing is on-device.
- Useful for a minimal integration or as an Android fallback.
- **Limitation:** Android-only and the scanner interface is controlled by Google. It does not let our app place its own full camera UI/overlay over Google's scanner screen.
- **Fit:** Not suitable as the sole cross-platform solution or when a fully branded scanner camera is mandatory.

### Option B — Google ML Kit Barcode Scanning (Android + iOS, custom UI)
- Android docs: https://developers.google.com/ml-kit/vision/barcode-scanning/android
- iOS docs: https://developers.google.com/ml-kit/vision/barcode-scanning/ios
- Supports common 1D and 2D barcode formats and on-device decoding.
- The app supplies camera frames and owns the camera preview, scan frame, overlays, controls, and interaction design.
- Android offers bundled and Google Play services-delivered model options. The unbundled model can require a first-use download; bundled increases app size but is available immediately.
- iOS uses the ML Kit iOS SDK and requires the app's own camera capture/UI pipeline for a live branded scanner.
- **Limitation:** ML Kit is a Google proprietary SDK, not an open-source scanner implementation. Platform integration and dependency versions need to be maintained separately.
- **Fit:** Strong candidate if branded UI and similar detection behavior across Android and iOS outweigh the open-source-only preference.

### Option C — Apple Vision on iOS + Android scanner counterpart
- Apple docs: https://developer.apple.com/documentation/vision/vndetectbarcodesrequest
- Apple's Vision framework exposes barcode detection and observations on iOS.
- The app owns the camera UI and can use Apple's native capture stack.
- **Limitation:** This creates a platform-specific implementation; Android still needs a separate engine. Supported symbologies and behavior must be compared against the exact formats we intend to support.
- **Fit:** Strong native iOS candidate if platform-native frameworks are preferred over using Google ML Kit on both platforms.

### Option D — Open-source ZXing family / zxing-cpp
- ZXing: https://github.com/zxing/zxing
- zxing-cpp: https://github.com/zxing-cpp/zxing-cpp
- Open-source barcode decoding family with broad 1D/2D format support.
- Can reduce dependence on proprietary scanner SDKs and better align with the project's open-source-first principle.
- The original Java ZXing repository says it is in maintenance mode; evaluate maintained ports and bindings rather than assuming every wrapper is active or equally reliable.
- **Limitation:** Camera capture, real-time frame scheduling, focus/torch behavior, overlays, lifecycle, and platform integration remain our responsibility. Verify supported formats, performance, bindings, and exact licenses on both platforms.
- **Fit:** Best candidate to investigate if open-source control is a priority and engineering complexity is acceptable.

### Comparison matrix

| Criterion | Code Scanner | ML Kit Barcode | Apple Vision + Android peer | ZXing family |
|---|---|---|---|---|
| Android | Yes | Yes | Separate Android engine | Yes, via maintained bindings |
| iOS | No | Yes | Native iOS + Android peer | Yes, via maintained bindings |
| Our own camera UI | No | Yes | Yes | Yes |
| On-device decode | Yes | Yes | Yes | Yes |
| Offline scan after required components are available | Yes | Yes | Yes | Yes |
| Open-source scanner engine | No | No | No for Vision | Yes |
| Camera integration work | Low | Medium | Medium/high | High |
| Cross-platform behavior | Not applicable | Similar API family; validate parity | Different engines | Depends on bindings |
| Main concern | Android-only, Google UI | Proprietary SDK and model delivery | Platform-specific divergence | Integration/performance burden |

*This is a preliminary architecture comparison, not a measured benchmark. Accuracy, latency, supported symbologies, first-run behavior, and device coverage must be tested with a shared sample set before choosing.*

### Preliminary recommendation (not final approval)
Keep the scanner provider replaceable. Prototype and benchmark **ML Kit on both platforms** against **ZXing-family implementations**, and include **Apple Vision** as an iOS-native comparison. Keep Google Code Scanner as an Android-only low-effort fallback/alternative, not the primary cross-platform architecture.

Do not select a Flutter, React Native, or native app framework yet. Framework selection must follow the scanner compatibility and UI ownership decision.

## 2. Product data sources

### Open Food Facts
- API docs: https://openfoodfacts.github.io/documentation/
- Product lookup: https://openfoodfacts.github.io/documentation/docs/Product-Opener/v3/products/get-api-v3-product-code/
- Open Food Facts provides an open food-product database and barcode lookup API. The current documentation recommends API v3 for new product reads.
- Data is community-contributed and can be incomplete or inaccurate. It is not a universal catalogue for every product category.
- Respect the Open Database License and Database Contents License, image licenses, API identification requirements, and rate limits. Use a descriptive User-Agent.
- For testing, review the staging environment and usage instructions in the official docs.

### Open Beauty Facts
- Investigate as a separate category-specific source for cosmetics and beauty products. Confirm current API availability, dataset coverage, and terms before adoption.

### India-specific candidate: OpenMRP
- Project: https://github.com/openmrp-in/openmrp
- Describes itself as an open product database for India with barcode lookup and product fields such as brand, pack size, MRP, and category.
- The project describes code under Apache-2.0, data under ODbL-1.0, and media under CC-BY-SA-4.0. These terms and current API requirements must be verified directly before integration.
- The API documentation describes a free self-service API key. Do not assume it is keyless or unlimited.

### Important product-data rule
A barcode typically gives the app an identifier. It does not itself provide a complete product profile. The app must report “not found” when a trustworthy database match is unavailable. Never fabricate missing details.

## 3. AI inference

### Ollama
- Docs: https://docs.ollama.com/api
- Project: https://github.com/ollama/ollama
- Provides a local model runtime and HTTP API, including chat and OpenAI-compatible routes.
- Useful for local development and self-hosted inference. A production deployment still needs hardware, monitoring, authentication, network controls, and capacity planning.
- The model's own license is separate from the runtime license. Check every selected model's terms.

### Production alternatives to evaluate later
- vLLM: https://github.com/vllm-project/vllm — high-throughput model serving.
- llama.cpp: https://github.com/ggml-org/llama.cpp — efficient local inference across supported hardware.
- Hosted open-weight model providers may be useful for prototypes, but hosted inference is a third-party service even when the model weights are open.

## 4. Read-aloud / text-to-speech

### First baseline: native platform TTS
- Test Android and iOS built-in speech engines first. This may avoid hosting costs and can support offline speech depending on installed voices and platform settings.
- Confirm voice availability and behavior on actual target devices.

### Kokoro
- Model information: https://huggingface.co/hexgrad/Kokoro-82M
- Open-weight TTS candidate with an Apache-2.0 model card for the referenced release. Verify the exact model version and any runtime/dependency licenses before deployment.
- Could be served through a self-hosted HTTP API if quality, language coverage, latency, and resource requirements meet product needs.

## 5. OCR / reading text from images

### PaddleOCR
- Project: https://github.com/PaddlePaddle/PaddleOCR
- Docs: https://www.paddleocr.ai/
- Open-source OCR toolkit with self-hosting options. Evaluate only if the product expands beyond QR/barcode payloads into reading labels, packaging, or text in images.
- OCR is not barcode decoding; treat these as separate capabilities.

## 6. Suggested architecture principle

Keep a provider-independent application layer:

1. **Camera/capture layer** — permissions, camera lifecycle, preview, focus, torch, frame capture.
2. **Scanner adapter** — normalize platform-specific SDK results into one internal structure: raw value, symbology, parsed payload, bounds, timestamp, and confidence/metadata when available.
3. **Content classifier** — classify QR payloads and barcode identifiers.
4. **Data-source adapters** — query one or more product/catalogue sources.
5. **Evidence assembler** — normalize fields and retain provenance, source, and timestamps.
6. **AI adapter** — pass only relevant, user-approved context to a selected model.
7. **Speech adapter** — native TTS initially; optional self-hosted TTS later.
8. **Result UI** — clearly distinguish decoded data, catalogue data, and AI-generated explanation.

Do not couple the UI directly to one vendor's API schema. Each provider should be replaceable. A platform-specific scanner may be selected behind the same adapter contract.

## 7. Scanner benchmark plan (before implementation selection)

Prepare one shared test corpus containing:
- QR codes: plain text, HTTPS URL, vCard/contact, Wi-Fi, email, phone, event, Unicode text, malformed/unsupported payloads.
- Retail barcodes: EAN-13, EAN-8, UPC-A, UPC-E, Code 128, ITF, plus any additional formats approved for MVP.
- Conditions: low light, glare, blur, rotation, damaged/low-quality print, different distances, small labels, multiple codes in frame.
- Devices: representative Android devices (including devices without Google Play services if in target scope) and supported iPhone models.

Measure:
- Successful decode rate per format and condition.
- Time-to-first-result and repeated-frame latency.
- False positives and duplicate detections.
- App size and first-run model download behavior.
- Offline behavior and camera lifecycle reliability.
- Battery/thermal impact during repeated scanning.
- Custom UI flexibility, accessibility, maintenance activity, exact licenses, and commercial-use constraints.

## 8. Evaluation checklist

For every candidate, record:
- Open-source status and exact license.
- Model-weight license, if applicable.
- Dataset and image license, if applicable.
- Commercial use and redistribution requirements.
- API key, rate limit, and fair-use policy.
- Data sent to the provider and retention policy.
- Coverage for Indian products and supported languages.
- Latency, reliability, cost, and fallback behavior.
- Maintenance activity and community health.

## 9. Research sources

- Google Code Scanner (Android only): https://developers.google.com/ml-kit/vision/barcode-scanning/code-scanner
- Google ML Kit Android barcode scanning: https://developers.google.com/ml-kit/vision/barcode-scanning/android
- Google ML Kit iOS barcode scanning: https://developers.google.com/ml-kit/vision/barcode-scanning/ios
- Apple Vision barcode detection: https://developer.apple.com/documentation/vision/vndetectbarcodesrequest
- ZXing repository: https://github.com/zxing/zxing
- zxing-cpp: https://github.com/zxing-cpp/zxing-cpp
- Open Food Facts API: https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/
- Open Food Facts product lookup: https://openfoodfacts.github.io/documentation/docs/Product-Opener/v3/products/get-api-v3-product-code/
- OpenMRP repository: https://github.com/openmrp-in/openmrp
- Ollama API: https://docs.ollama.com/api
- PaddleOCR: https://www.paddleocr.ai/
- Kokoro model card: https://huggingface.co/hexgrad/Kokoro-82M
