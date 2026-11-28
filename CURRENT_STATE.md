# Current State

**Last updated:** 2026-11-28  
**Project phase:** Product discovery  
**Working concept:** QR & Barcode Scanner with AI  
**Working name:** ScanWise (temporary; not approved)

## Repository reset
- The previous MenuCard product content was removed from the main branch by a reset commit.
- The main branch was verified empty immediately after the reset.
- Other branches, tags, releases, uploaded release assets, and historical Git commits may still contain the old project. Their cleanup was not completed through the available GitHub connection.
- Do not assume the entire repository history or release archive has been erased.

## Current vision
A user scans a QR code or supported barcode and receives a clear, detailed result. The app decodes the content, looks up additional information when an appropriate data source exists, and presents useful actions. Users can read the result, listen using read-aloud, and use contextual AI capabilities such as explaining, summarizing, translating, and asking questions.

## Files created for the new project
- README.md
- PRODUCT_VISION.md
- FEATURE_MAP.md
- DISCOVERY.md
- CURRENT_STATE.md

## Not yet decided
- Final product name and branding.
- Target users and strongest differentiator.
- Android / iOS / cross-platform scope.
- Supported QR payload types and barcode formats.
- Product catalogue provider and market coverage.
- AI provider, model, budget, and privacy controls.
- Read-aloud languages and controls.
- Offline behavior, history, accounts, and synchronization.
- Monetization.
- MVP acceptance criteria.

## Working rules
1. Do not bring back MenuCard restaurant, cinema, table, seat, or menu requirements.
2. Do not implement features until the product scope and MVP are discussed and approved.
3. Keep product discovery, architecture, implementation, and release status clearly separated.
4. After each development task, update this file with what changed, what was tested, test results, known issues, and the next step.
5. Never claim a feature is tested unless an actual test was run.
6. In code changes, include useful comments where they clarify non-obvious logic.
7. Prefer privacy-conscious defaults and explain any external data or AI processing.
8. Clearly distinguish decoded code content, external catalogue data, and AI-generated explanations.
9. If a task cannot be completed with available access or tools, state exactly what remains manual.

## Next step
Continue product discovery using DISCOVERY.md. Agree on the target user, primary differentiator, initial code formats, product data source, and the first three AI capabilities before selecting the technical architecture.
