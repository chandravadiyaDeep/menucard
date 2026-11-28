# Open-Source Stack Research

**Status:** Initial research shortlist — not a final architecture decision.

The product direction is to prefer open-source software, open datasets, and self-hostable services. A free hosted API is not automatically open source. Review code license, model-weight license, dataset license, API terms, privacy, rate limits, and commercial-use conditions separately.

## 1. QR and barcode decoding

### Candidate: ZXing family
- Project: https://github.com/zxing/zxing
- ZXing is an open-source multi-format 1D/2D barcode decoding library and lists support for common formats including QR Code, EAN-8, EAN-13, UPC-A, UPC-E, Code 128, Data Matrix, and PDF417.
- The original Java repository states it is in maintenance mode. Do not blindly adopt the original Android app or assume it is the best maintained camera integration.
- Evaluate maintained ports and wrappers such as zxing-cpp and Flutter integrations against the selected framework, supported formats, platform behavior, and license.

### Flutter candidate: mobile_scanner
- Project: https://pub.dev/packages/mobile_scanner
- A Flutter camera-scanning integration worth evaluating for developer ergonomics and platform support.
- Important: inspect the actual native engines and dependencies per platform. An open-source Flutter wrapper does not mean every underlying engine is open source.

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

1. **Scanner adapter** — camera frames to decoded payload and symbology.
2. **Content classifier** — classify QR payloads and barcode identifiers.
3. **Data-source adapters** — query one or more product/catalogue sources.
4. **Evidence assembler** — normalize fields and retain provenance, source, and timestamps.
5. **AI adapter** — pass only relevant, user-approved context to a selected model.
6. **Speech adapter** — native TTS initially; optional self-hosted TTS later.
7. **Result UI** — clearly distinguish decoded data, catalogue data, and AI-generated explanation.

Do not couple the UI directly to one vendor's API schema. Each provider should be replaceable.

## 7. Evaluation checklist

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

## 8. Research sources

- Open Food Facts API: https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/
- Open Food Facts product lookup: https://openfoodfacts.github.io/documentation/docs/Product-Opener/v3/products/get-api-v3-product-code/
- OpenMRP repository: https://github.com/openmrp-in/openmrp
- ZXing repository: https://github.com/zxing/zxing
- Ollama API: https://docs.ollama.com/api
- PaddleOCR: https://www.paddleocr.ai/
- Kokoro model card: https://huggingface.co/hexgrad/Kokoro-82M
