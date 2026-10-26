# Aedify — AI Implementation Plan v1.0


| Field | Value |
|---|---|
| Document Package | AI Implementation Plan |
| Package Version | v1.0 |
| Source Baseline | PRD v1.10 Final / Re-locked after Package Validation |
| Roadmap Baseline | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Architecture Baseline | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Feature Plan Baseline | `v1-feature-by-feature-build-plan-v1.0/` |
| Data Model Baseline | `v1-data-model-implementation-plan-v1.0/` |
| Status | Implementation Planning |
| Scope Rule | No product scope change; implementation-only breakdown |
| Platforms | iOS and Android |
| App Architecture | Local-only, offline-first, BYOK AI |
| State Management | Riverpod, latest validated stable version |
| Durable Data | Drift / SQLite |
| Simple Preferences | `shared_preferences` only for non-critical values |
| Secrets | `flutter_secure_storage` only |
| Networking | Dio + Retrofit, with hand-written Dio adapters for complex AI calls |
| Created | 2026-06-14 |


---

## 1. Purpose

This package translates the locked AI requirements into an implementation-ready plan for the in-app AI layer.

It answers:

1. Which AI operations exist in v1.
2. Which operations require structured JSON and local validation.
3. Which operations are conversational only.
4. Which local data may be included in each prompt payload.
5. Which local data must never be included in prompts.
6. How BYOK providers are configured and called.
7. How provider capabilities gate image import and progress-media analysis.
8. How prompt templates are assembled from the modular instruction set.
9. How structured-output schemas are versioned, validated, repaired, reviewed, and persisted.
10. How AI-generated workouts/programmes become saved app data.
11. How external file/image imports become editable drafts.
12. How AI physique analysis uses selected progress media after consent.
13. How privacy, redaction, Crashlytics exclusions, and cost disclosure are enforced.
14. What tests must pass before AI features are considered implementation-ready.

This is an implementation plan only. It does not add new product scope beyond the re-locked v1 PRD.

---

## 2. Source Documents

| Source | Role |
|---|---|
| `PRD-Aedify-v1-FINAL-relocked.md` | Locked v1 product, AI, privacy, BYOK, import, image import, and progress-media baseline. |
| `aedify-package-validation-decision-log-v1.md` | Final implementation stack correction and storage/network boundaries. |
| `aedify-ai-companion-instruction-set-v1.10.md` | Modular AI instruction-set source, per-call prompt templates, and AI operation contracts. |
| `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` | Current milestone order; M6 Progress Media before M7 AI Infrastructure. |
| `aedify-v1-architecture-implementation-plan-v1.0.md` | Layering, AI module ownership, provider abstraction, prompt builder, structured-output lifecycle. |
| `v1-feature-by-feature-build-plan-v1.0/` | Feature-level implementation details for M7–M13 AI-related flows. |
| `v1-data-model-implementation-plan-v1.0/` | Drift entities, storage ownership, AI snapshots, import drafts, progress-media records. |
| `aedify-aedify-00-index.md` through `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` | Bundled AI reference corpus used by prompt builder where eligible. |
| `aedify-musclewiki-exercises.firebase.json` | Local exercise catalog shape used for candidate exercise lists. |

---

## 3. Package File Map

| File | Covers |
|---|---|
| `00-ai-implementation-plan-index-v1.0.md` | Package overview, source inputs, milestone mapping, operation registry. |
| `01-ai-boundaries-principles-v1.0.md` | What AI may do, what the app must do locally, privacy and persistence boundaries. |
| `02-provider-byok-capability-plan-v1.0.md` | BYOK provider abstraction, secure key access, model capabilities, provider switching, network adapters. |
| `03-prompt-builder-context-assembly-v1.0.md` | Modular instruction-set composition, placeholder substitution, operation DTOs, reference-file routing. |
| `04-structured-output-validation-repair-v1.0.md` | Shared envelope, schema registry, validation phases, repair lifecycle, review-before-save. |
| `05-candidate-exercise-engine-v1.0.md` | Exercise candidate generation, hard/soft filters, prompt payload caps, anti-hallucination rules. |
| `06-ai-workout-programme-generation-v1.0.md` | Daily workouts, multi-week programmes, beginner paths, strength anchors, powerbuilding routing. |
| `07-ai-chat-update-flows-v1.0.md` | AI Trainer chat, save-from-chat, swaps, deloads, plateau suggestions, conversational/app-actionable split. |
| `08-external-text-import-ai-v1.0.md` | Text/PDF/TXT/MD/XLSX/CSV extraction-to-AI parse, repair, exercise matching assistance. |
| `09-image-screenshot-import-ai-v1.0.md` | Image prompt packaging, multimodal provider gates, image parse/repair, unreadable-region handling. |
| `10-progress-media-physique-analysis-ai-v1.0.md` | AI physique analysis from progress media, comparison, consent, output safety, local snapshots. |
| `11-privacy-consent-redaction-ai-v1.0.md` | AI consent screens, prompt minimization, Crashlytics exclusions, exports exclusions, secret handling. |
| `12-ai-error-resilience-cost-plan-v1.0.md` | Failure taxonomy, retries, provider errors, rate limits, cancellation, cost disclosure, offline states. |
| `13-ai-testing-acceptance-checklist-v1.0.md` | Unit/integration/manual QA, schema fixtures, provider mocks, privacy tests, release gates. |
| `14-ai-backlog-ticket-seeds-v1.0.md` | Detailed ticket seeds for M7–M13 AI implementation work. |
| `manifest.json` | Machine-readable package manifest. |

---

## 4. AI-Relevant Milestone Mapping

| Milestone | Name | AI Implementation Impact |
|---|---|---|
| M3 | Onboarding, Profile, Settings, and BYOK Setup | Provider selection, API-key capture, secure storage, model choice, capability checks. |
| M4 | Manual Programmes, Workouts, and Logging | Provides save targets, set-prescription model, working weights, and log history for AI. |
| M5 | Analytics, PRs, and Plateau Base Logic | Provides plateau events, e1RM/PR context, and working-weight anchors. |
| M6 | Progress Media Tracking | Provides local media sessions and selected media/frame payloads for later AI physique analysis. |
| M7 | AI Infrastructure | Provider abstraction, prompt builder, schema registry, validation/repair, privacy wrappers. |
| M8 | AI Workout + Programme Generation | Daily and multi-week AI generation, review, validation, save to Programs Library. |
| M9 | AI Trainer Chat + AI Update Flows | Conversational chat, chat-save, swaps, deloads, plateau suggestions, update operations. |
| M11 | External Text File Import | AI parsing of extracted programme/workout text into local import drafts. |
| M12 | Image/Screenshot External Import | Multimodal AI parsing of ordered screenshots/images into import drafts. |
| M13 | Optional AI Physique Analysis | AI analysis/compare/repair using selected progress media or extracted frames. |
| M14 | Privacy, Resilience, and Release Hardening | Full AI privacy audit, error hardening, provider mocks, final QA. |

---

## 5. AI Operation Registry

The implementation should treat AI operations as a closed registry. Every operation has a stable identifier, prompt template, expected response mode, capability requirements, validation policy, and persistence policy.

| Operation | Milestone | Response Mode | Save Target | Capability Gate |
|---|---:|---|---|---|
| `INIT` | M7 | Structured or constrained setup response | None by default | Text generation |
| `DAILY_WORKOUT` | M8 | Structured JSON | Review draft → saved workout | Text generation + JSON support preferred |
| `MULTI_WEEK_PROGRAM/general` | M8 | Structured JSON | Review draft → programme | Text generation + JSON support preferred |
| `MULTI_WEEK_PROGRAM/beginner_choice` | M8 | Structured decision payload | Path selection UI | Text generation |
| `MULTI_WEEK_PROGRAM_BEGINNER_PATH_A` | M8 | Structured JSON | Review draft → programme | Text generation + JSON support preferred |
| `MULTI_WEEK_PROGRAM_BEGINNER_PATH_B` | M8 | Structured JSON | Review draft → programme | Text generation + JSON support preferred |
| `EXERCISE_SWAP_RECOMMENDATION` | M9 | Conversational + optional options DTO | None | Text generation |
| `EXERCISE_SWAP_APPLY_UPDATE` | M9 | Structured JSON/update payload | Review → programme/workout update | Text generation + JSON support preferred |
| `DELOAD` | M9 | Structured JSON/update payload | Review → programme/workout update | Text generation + JSON support preferred |
| `PLATEAU_SUGGESTION` | M9 | Structured JSON or conversational explanation depending UI entry | Review → suggestion/save action | Text generation + JSON support preferred |
| `AI_TRAINER_CHAT` | M9 | Conversational | Chat message only | Text generation |
| `AI_TRAINER_CHAT_SAVE_WORKOUT` | M9 | Structured JSON | Review draft → saved workout | Text generation + JSON support preferred |
| `AI_TRAINER_CHAT_SAVE_PROGRAMME` | M9 | Structured JSON | Review draft → programme | Text generation + JSON support preferred |
| `EXTERNAL_PLAN_IMPORT_PARSE` | M11 | Structured JSON | Import draft | Text generation + JSON support preferred |
| `EXTERNAL_PLAN_IMPORT_REPAIR` | M11 | Structured JSON | Repaired import draft | Text generation + JSON support preferred |
| `EXTERNAL_PLAN_IMPORT_EXERCISE_MATCH_ASSIST` | M11 | Structured match suggestions | Exercise match review | Text generation |
| `EXTERNAL_PLAN_IMPORT_IMAGE_PARSE` | M12 | Structured JSON | Import draft | Image input + text generation + JSON support preferred |
| `EXTERNAL_PLAN_IMPORT_IMAGE_REPAIR` | M12 | Structured JSON | Repaired import draft | Image input + text generation + JSON support preferred |
| `PROGRESS_MEDIA_ANALYSIS_ANALYZE` | M13 | Structured JSON | Local analysis snapshot | Image input; video handled as selected/extracted frames |
| `PROGRESS_MEDIA_ANALYSIS_COMPARE` | M13 | Structured JSON | Local comparison snapshot | Image input; comparison media selected locally |
| `PROGRESS_MEDIA_ANALYSIS_REPAIR` | M13 | Structured JSON | Repaired analysis snapshot | Image input optional depending failed fields |
| `STRUCTURED_OUTPUT_REPAIR` | M7+ | Structured JSON | Repaired draft/snapshot | Same as original operation where needed |

---

## 6. Global AI Implementation Rules

1. AI never writes directly to Drift.
2. AI never owns app state.
3. AI never creates local IDs.
4. AI must use only supplied exercise IDs for canonical exercises.
5. AI outputs are drafts until validated and accepted.
6. App-actionable outputs must be structured JSON only.
7. Normal trainer chat remains conversational unless the user explicitly asks to save something.
8. External imports preserve source content; they do not adapt unless the user explicitly starts a later adaptation flow.
9. Image import must not invent missing or unreadable content.
10. Progress-media analysis must be rough, limited, non-medical, and explicitly consented.
11. All prompt payloads are operation-specific DTOs, not raw database rows.
12. Raw prompts, raw responses, candidate lists, images, media, and keys are not sent to Crashlytics.
13. Provider capabilities determine whether text, JSON mode, image input, or streaming is available.
14. One automatic structured-output repair attempt is allowed by default.
15. Every failed AI operation must leave the app in a recoverable state.

---

## 7. Implementation Package Completion Definition

This AI plan is complete when implementation can start with:

- a closed AI operation registry;
- provider adapter contracts;
- secure key lookup rules;
- prompt assembly contracts;
- schema validation and repair contracts;
- candidate-list construction rules;
- generation/import/analysis flow contracts;
- privacy and consent gates;
- error and cost states;
- test fixtures and acceptance gates;
- backlog ticket seeds for all AI milestones.
