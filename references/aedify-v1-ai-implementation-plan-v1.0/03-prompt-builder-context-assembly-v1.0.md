# 03 — Prompt Builder and Context Assembly Plan v1.0


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

This file defines how the app assembles AI prompts from the modular instruction set and local app data.

The prompt builder must be deterministic, testable, and privacy-minimizing. It must never “just dump the app state” into the provider.

---

## 2. Prompt Builder Responsibilities

The prompt builder owns:

1. selecting the AI operation;
2. selecting instruction-set sections;
3. selecting reference files;
4. resolving placeholders;
5. formatting local DTOs into prompt-safe text;
6. attaching structured-output schema text when required;
7. attaching candidate exercise lists;
8. attaching media metadata for multimodal operations;
9. enforcing prompt privacy rules;
10. producing provider-neutral request objects.

It does not own:

- API key retrieval;
- HTTP calls;
- schema validation;
- database writes;
- user review UI;
- Crashlytics logging;
- exercise candidate selection logic itself.

---

## 3. Prompt Assembly Pipeline

```text
User action
  → AI operation resolver
  → capability gate
  → context requirement registry
  → local DTO resolvers
  → reference selector
  → candidate exercise engine
  → schema selector
  → placeholder renderer
  → prompt privacy guard
  → provider-neutral AI request
  → provider adapter
```

Each step must be separately unit-testable.

---

## 4. Operation Context Registry

Create a registry that describes what each operation needs.

```text
AIOperationContextSpec
  operation_id
  instruction_sections
  required_profile_fields
  required_lift_log_window
  requires_candidate_list
  candidate_list_type
  requires_reference_files
  reference_selection_policy
  requires_structured_schema
  schema_id
  requires_chat_history
  requires_import_text
  requires_images
  requires_progress_media
  requires_consent_type
  prompt_template_id
  response_type
```

Example entries:

| Operation | Instruction Sections | Candidate List | Reference Files | Schema |
|---|---|---|---|---|
| `DAILY_WORKOUT` | Tone, Athlete Profile, Current Working Weights, Lift Log, Programming Rules | daily workout candidates | none by default | `daily_workout_json` |
| `MULTI_WEEK_PROGRAM/general` | Tone, Athlete Profile, Current Working Weights, Lift Log, Reference Files, Programming Rules | programme candidates | 1–3 selected | `multi_week_program_json` |
| `AI_TRAINER_CHAT` | Tone, Identity, Athlete Profile, Lift Log, Reference Files, Programming Rules, How to Respond | optional only when needed | 1–3 selected | none unless save intent |
| `EXTERNAL_PLAN_IMPORT_PARSE` | Tone, Structured Output Rules, External Import Rules | import match candidates optional/later | none by default | `external_program_import_json` or `external_workout_import_json` |
| `EXTERNAL_PLAN_IMPORT_IMAGE_PARSE` | Tone, Structured Output Rules, Image Import Rules | import match candidates optional/later | none by default | external import schema |
| `PROGRESS_MEDIA_ANALYSIS_ANALYZE` | Tone, Identity subset/safety, Progress Media Rules | none | none | `progress_physique_analysis_json` |

---

## 5. Placeholder Rendering Rules

The instruction set uses placeholders such as `{profile.name}` and `{schema.multi_week_program_json}`.

Rendering rules:

1. Known value renders as formatted value.
2. Unknown or empty value renders as `(not provided)`.
3. Lists render as readable bullet lists or compact JSON depending placeholder type.
4. Dates render in ISO date plus display date if useful.
5. Weights render in the user's preferred units.
6. Sensitive values never render.
7. Secret placeholders are forbidden.
8. Prompt builder fails closed if a required placeholder has no resolver.
9. Prompt builder must support snapshot tests for every operation.

Forbidden placeholders:

- raw API key;
- secure storage value;
- raw Drift row dump;
- full database export;
- Crashlytics session ID;
- local absolute media path unless provider needs a file attachment through controlled media packaging;
- raw prompt from previous calls;
- raw provider response from previous calls.

---

## 6. Local DTO Inputs

Prompt inputs should use DTOs that are shaped for the operation.

| DTO | Used By | Includes | Excludes |
|---|---|---|---|
| `PromptProfileDto` | generation/chat/swap/deload/plateau | goals, schedule, equipment, experience, constraints, units | API keys, private DB IDs not needed, media paths. |
| `WorkingWeightsDto` | strength generation, deload, plateau | exercise name/id, recent top set, working set estimate, date, confidence | warm-up sets for analytics. |
| `RecentLiftLogDto` | generation/chat/plateau | recent sessions, working sets, notes if needed and consented | full lifetime logs, unrelated notes. |
| `CandidateExerciseListDto` | generation/swap/import matching | allowed exercise IDs and metadata | full catalog when not needed. |
| `ReferenceSelectionDto` | generation/chat/plateau | selected 1–3 reference excerpts/files | unrelated reference corpus. |
| `ImportTextDto` | text import | extracted programme-relevant content, source metadata | full source file if irrelevant, original file path. |
| `ImageImportPackageDto` | image import | selected/enhanced images, order, quality metadata, instructions | unrelated user profile/logs. |
| `ProgressMediaPackageDto` | physique analysis | selected images/frames, comparison metadata | unrelated logs/programmes. |
| `SchemaDto` | structured operations | schema ID/version/text | unrelated schemas. |

---

## 7. Reference File Routing

Reference selection is deterministic and based on operation + user intent.

| Intent / Operation | Reference Selection |
|---|---|
| Beginner general guidance | `aedify-aedify-01-getting-started.md`, `aedify-aedify-05-exercise-programming.md`, maybe `aedify-aedify-03-muscle-building.md`. |
| Beginner Path A | Wiki beginner guidance only; no powerbuilding. |
| Weight loss question | `aedify-aedify-02-weight-loss.md`, `aedify-aedify-04-nutrition-and-diet.md`, maybe `aedify-aedify-06-faq.md`. |
| Muscle gain question | `aedify-aedify-03-muscle-building.md`, `aedify-aedify-04-nutrition-and-diet.md`, `aedify-aedify-05-exercise-programming.md`. |
| Supplement question | `aedify-aedify-07-supplements.md`; no programme generation unless asked. |
| Term explanation | `aedify-aedify-08-glossary.md`. |
| Plateau suggestion | `aedify-aedify-05-exercise-programming.md`, `aedify-aedify-06-faq.md`, plus log context. |
| Strength + hypertrophy for intermediate/advanced | `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` may be included as supplemental only. |
| External import parse | No reference files by default; preserve source plan. |
| Image import parse | No reference files by default; preserve visible source plan. |
| Physique analysis | No training reference files by default unless generating follow-up training suggestions after analysis. |

---

## 8. Powerbuilding Routing Guard

`aedify-aedify-09-powerbuilding-strength-hypertrophy.md` is only eligible when all checks pass:

1. User is not beginner/novice.
2. Goal includes both Build Strength and Build Muscle.
3. Operation is allowed to use the reference.
4. Request is not external import extract-only.
5. Request is not beginner Path A or Path B.
6. Request is not a casual chat unless user asks for strength + hypertrophy programming advice.
7. Prompt includes source-integrity guardrail.
8. Output schema allows optional powerbuilding metadata.

If any check fails, do not include file 09.

---

## 9. Chat History Assembly

AI Trainer chat uses local thread history, but prompt builder must trim it.

Rules:

- Include recent turns only, not entire lifetime thread when too long.
- Summarize older thread segments locally when needed.
- Do not include prior raw AI structured-output JSON unless needed for a repair or update and sanitized.
- Do not include unrelated import source text.
- Do not include progress media unless current operation is progress analysis and consented.
- If user switches provider, existing chat history may be serialized as plain text to the new provider in future calls, but the user must be able to clear chat history locally.

---

## 10. Prompt Privacy Guard

Before any provider call, run a prompt privacy check.

The guard should inspect:

- prompt text;
- message list;
- structured schema;
- candidate list;
- image/media metadata;
- provider request metadata.

Block request if it detects:

- API key pattern;
- secure storage alias value instead of alias name;
- local file paths not meant for provider;
- Crashlytics IDs;
- raw database dumps;
- full export DTOs not needed for operation;
- progress media included without `progress_media_ai_consent`;
- source-file text included without `external_import_ai_consent`;
- screenshot/image payload included without `image_import_ai_consent`;
- private profile/log data included in extract-only import flow.

---

## 11. Prompt Snapshot Testing

Every operation needs at least these prompt builder tests:

1. all required placeholders resolve;
2. missing optional values render `(not provided)`;
3. no unsupported placeholders remain;
4. no secret-like values appear;
5. candidate list is capped and filtered;
6. correct schema is included;
7. correct reference files are selected;
8. beginner operations exclude powerbuilding reference;
9. import operations exclude profile/log data unless adaptation explicitly requested;
10. image operations include image metadata and consent marker;
11. progress-media operations include only selected media/frame metadata and consent marker;
12. prompt length remains within configured model budget or shows truncation strategy.

---

## 12. Acceptance Gate

Prompt builder implementation is accepted when:

- operation context registry exists;
- every operation has a test fixture;
- prompt snapshots are deterministic;
- powerbuilding routing is tested;
- import context minimization is tested;
- media consent gates are tested;
- placeholders never leak unresolved template variables;
- no prompt test contains secrets, raw DB dumps, or forbidden Crashlytics data.
