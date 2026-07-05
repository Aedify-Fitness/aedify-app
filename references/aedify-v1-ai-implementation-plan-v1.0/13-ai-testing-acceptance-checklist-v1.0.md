# 13 — AI Testing and Acceptance Checklist v1.0


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

This file defines the tests required before AI implementation can be considered complete.

AI testing must use provider mocks and deterministic fixtures. Live provider tests are useful but cannot be the only proof because provider output varies.

---

## 2. Test Layers

| Layer | Purpose |
|---|---|
| Unit tests | DTO builders, prompt rendering, capability gates, schema validation, redaction. |
| Golden/snapshot tests | Prompt text and schema fixtures remain deterministic. |
| Integration tests | End-to-end flow with fake provider and Drift test DB. |
| Manual QA | Real device flows, provider setup, consent screens, review screens. |
| Privacy tests | Prove secrets/media/prompts/responses do not leak to logs/Crashlytics/exports. |
| Migration tests | Ensure AI-related tables survive schema changes. |
| Provider smoke tests | Minimal live calls for each provider/model family where configured. |

---

## 3. Provider Mock Requirements

Fake provider must support:

- valid text response;
- valid structured JSON response;
- invalid JSON response;
- wrong schema response;
- unknown exercise ID response;
- slow response;
- timeout;
- cancellation;
- invalid key;
- rate limit;
- quota exceeded;
- image unsupported;
- image supported;
- provider refusal;
- unsafe physique analysis response.

---

## 4. Prompt Builder Tests

For every AI operation:

- required placeholders resolve;
- optional missing values render `(not provided)`;
- correct instruction sections included;
- correct prompt template selected;
- correct schema selected;
- correct candidate list type selected;
- correct reference files selected;
- no API key appears;
- no raw DB row appears;
- no unresolved placeholder remains;
- prompt privacy guard passes valid payloads;
- prompt privacy guard blocks invalid payloads.

Special cases:

- beginner Path A excludes powerbuilding;
- import parse excludes profile/logs;
- image import includes image order metadata;
- physique analysis includes consent record and selected media only.

---

## 5. Structured Output Validation Tests

Required fixtures:

| Fixture | Expected Result |
|---|---|
| Valid daily workout | Valid review draft. |
| Valid multi-week programme | Valid expandable programme draft. |
| Wrong response type | Repairable invalid. |
| Unsupported schema | Blocked invalid. |
| Unknown exercise ID | Repairable invalid then blocked if repeated. |
| Exercise outside candidate list | Repairable invalid. |
| Missing set type | Repairable invalid or blocker. |
| Beginner superset | Blocker. |
| Warm-up above 80% | Blocker. |
| Unexpandable schedule | Blocker. |
| Import unresolved exercise | Blocker until resolved. |
| Image import invents unclear content | Blocker/repair. |
| Physique exact BF number | Repairable invalid. |
| Physique medical diagnosis | Blocked invalid. |
| Prompt/response in exportable field | Blocker. |

---

## 6. Flow Acceptance Tests

### M7 AI Infrastructure

- provider setup works with fake provider;
- key stored only in secure storage;
- capability descriptor blocks image operations when unsupported;
- structured output repair runs once;
- redacted errors only.

### M8 Generation

- daily workout generation → review → save;
- multi-week programme generation → expand → review → save;
- beginner Path A follows strict beginner constraints;
- non-beginner powerbuilding eligible flow includes allowed metadata;
- invalid output cannot save.

### M9 Chat/Updates

- normal chat stays conversational;
- save workout intent creates structured draft;
- save programme intent creates structured draft;
- swap recommendation does not mutate;
- swap apply shows scope preview;
- deload applies only after review;
- plateau suggestion uses local plateau event.

### M11 Text Import

- supported files extract locally;
- consent required before AI;
- parsed draft validates;
- ambiguous exercise requires confirmation;
- unresolved custom exercise blocks save;
- imported plan inactive by default.

### M12 Image Import

- unsupported model blocks;
- consent required;
- ordered images preserve order;
- unreadable content flagged;
- temp artifacts cleaned;
- draft follows external import flow.

### M13 Physique Analysis

- consent required;
- selected photos/frames only;
- exact BF rejected;
- unsafe content rejected;
- snapshot saved locally;
- excluded from exports/Crashlytics.

---

## 7. Privacy Tests

Automated tests should assert these strings/categories never appear in logs or Crashlytics context:

- API key sample;
- prompt text sample;
- raw AI response sample;
- candidate exercise list sample;
- lift log sample;
- injury note sample;
- progress media path;
- screenshot filename;
- source-file excerpt;
- chat message;
- body measurement;
- structured output JSON.

Export tests:

- `.aedifyplan` excludes AI internals;
- PDF excludes AI internals;
- imported source text excluded;
- progress media and analysis excluded;
- screenshots/artifacts excluded;
- API keys excluded.

---

## 8. Manual QA Checklist

Manual QA should cover:

1. first AI provider setup;
2. invalid key correction;
3. model switch from image-capable to non-image-capable;
4. daily workout generation;
5. multi-week programme generation;
6. beginner Path A;
7. chat Q&A;
8. chat save workout;
9. chat save programme;
10. exercise swap recommendation/apply;
11. deload;
12. plateau suggestion;
13. text import parse;
14. image import parse;
15. progress media analysis;
16. cancellation during AI call;
17. offline state;
18. delete AI chat;
19. delete API key;
20. export privacy check.

---

## 9. Release Gate

AI implementation is release-ready only when:

- all provider-mock tests pass;
- all schema fixtures pass;
- all prompt snapshot tests pass;
- all privacy tests pass;
- all supported operations have manual QA sign-off;
- provider smoke tests pass for at least one configured provider;
- unsupported provider/model states are clear;
- no AI operation can silently persist data;
- no media/source-file flow can run without consent;
- no forbidden data appears in Crashlytics/export artifacts.
