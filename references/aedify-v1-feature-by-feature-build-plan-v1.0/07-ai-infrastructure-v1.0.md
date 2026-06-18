# AI Infrastructure Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-07 |
| Milestone Coverage | M7 |
| Source Roadmap | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Source Architecture Plan | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Source Baseline | PRD v1.10 / v1 Final — Re-locked after Package Validation |
| Status | Implementation Planning |
| Platforms | iOS and Android, Flutter single codebase |
| Architecture Constraint | Local-only, offline-first, BYOK AI |
| Created | 2026-06-10 |

---

## 1. Document Rule

This file breaks implementation work into buildable feature slices. It does not change product scope, product requirements, user journeys, privacy rules, or milestone ordering. If implementation reveals a product behavior that is not already covered by the locked PRD, that behavior must be handled as a formal change request or future PRD version bump.

The validated v1 stack is assumed throughout this file:

- Flutter + Dart for the iOS/Android app.
- Riverpod for dependency injection, feature controllers, and async workflow state.
- Drift / SQLite for durable structured app data and migrations.
- `shared_preferences` for simple, non-critical preferences only.
- `flutter_secure_storage` for BYOK API keys and other secrets only.
- Dio + Retrofit for HTTP, with hand-written Dio adapters for complex AI, streaming, image, multipart, or provider-specific calls.
- Firebase Storage for the exercise dataset, Firebase Auth for anonymous dataset access, and Firebase Crashlytics for crash diagnostics only.

---


## 2. Feature Objective

Build the provider-agnostic BYOK AI foundation: provider abstraction, capability routing, prompt builder, structured-output schemas, local validation, repair lifecycle, request minimization, provider error mapping, and safe AI operation orchestration.

## 3. User-Facing Outcomes

- AI-enabled flows can check provider/key/capability before starting.
- App-actionable prompts return structured JSON only and are locally validated.
- Invalid AI outputs get one automatic repair attempt.
- Prompt assembly uses only the minimum required local context.
- Provider/network errors are mapped to safe user messages.

## 4. Scope

### 4.1 In Scope

- Provider abstraction for OpenAI/Anthropic/Google-style providers
- Model/capability registry
- Prompt module loader
- Per-call prompt template filling
- Structured-output schema registry
- JSON/schema mode where available
- Local validator and repair orchestrator
- AI operation audit metadata without raw prompts/responses
- Hand-written Dio adapters for complex calls

### 4.2 Out of Scope

- Specific workout generation UX
- AI chat UX
- External import UX
- Physique analysis UX

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M1 foundation
- M2 exercise/candidate queries
- M3 BYOK provider setup
- M4/M5/M6 for downstream context

### 5.2 Enables Later Work

- M8 AI generation
- M9 chat/update flows
- M11 external import
- M12 image import
- M13 physique analysis

## 6. Data Ownership and Storage Plan

- Tables: `ai_provider_configs` metadata from M3, `ai_operation_records`, `ai_validation_failures`, optional `ai_schema_versions`.
- Do not persist raw prompt bodies, raw AI responses, candidate lists, media, screenshots, or secrets.
- Persist operation type, schema version, model id, status, created time, and redacted error code only.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `aiProviderRegistryProvider`
- `aiCapabilityServiceProvider`
- `promptBuilderProvider`
- `structuredOutputValidatorProvider`
- `aiOperationControllerProvider`
- `aiRepairControllerProvider`
- `candidateListBuilderProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- AI unavailable/needs setup components
- Provider capability blocker component
- AI operation progress sheet
- Validation failure/retry UI component
- Developer-only schema validation fixture screen

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Operation start: check key exists, check provider capability, build minimized context, assemble prompt, call provider, parse response, validate schema, attempt repair once if needed, return draft/suggestion to caller.
- Repair: send validation errors, expected schema, original invalid output if safe and necessary, candidate list if needed, then validate again.
- Capability gate: block image/media flows before prompt assembly if unsupported.

## 10. Validation Rules

- All app-actionable output must be valid JSON envelope.
- AI may only use supplied exercise IDs.
- AI cannot generate local DB IDs.
- Candidate lists are hard-filtered by equipment/experience and soft-ranked by goals.
- One automatic repair attempt only; second retry requires user action.
- Missing required context returns `needs_input` or local blocker.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Prompts, raw responses, structured outputs, candidate lists, injuries, logs, media, screenshots, and local DB records never go to Crashlytics.
- Only required prompt context is sent to AI provider.
- API keys inserted into request headers in memory only.
- Provider terms are user-controlled BYOK; app does not proxy.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- No provider key
- Provider auth failed
- Capability unsupported
- Network timeout
- Invalid JSON
- Schema validation failed
- Repair failed
- Provider rate limit
- User cancelled

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M7-T01 | Define AI operation types and schemas | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T02 | Build provider abstraction | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T03 | Build provider adapters | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T04 | Build prompt builder | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T05 | Build schema registry | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T06 | Build output validator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T07 | Build repair orchestrator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T08 | Build candidate-list service | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T09 | Build AI operation records | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T10 | Build capability blockers | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M7-T11 | Add M7 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Text AI call can complete through abstraction in test mode.
- Provider capability checks correctly block unsupported flows.
- Invalid output triggers one repair attempt.
- Raw prompts/responses are not persisted.
- Candidate-list ID validation rejects invented IDs.
- Provider errors map to safe messages.

## 15. Manual QA Checklist

- Configure fake provider and run structured call.
- Simulate invalid JSON.
- Simulate invented exercise ID.
- Simulate unsupported image model.
- Simulate rate limit/auth failure.
- Inspect AI operation records for redacted metadata only.

## 16. Automated Test Coverage

- Prompt builder tests
- Schema validator tests
- Repair lifecycle tests
- Provider adapter tests
- Capability routing tests
- Privacy persistence tests
- Candidate-list tests

## 17. Handoff Notes

- M8/M9/M11/M12/M13 must call AI only through this infrastructure.

## 15. Implementation Exit Standard

A feature slice is not complete until all of the following are true:

- The UI path works on both iOS and Android.
- All durable writes are transactional where multiple records must stay consistent.
- Riverpod controllers expose explicit loading, success, empty, validation-error, blocked, and failure states where relevant.
- Drift migrations or schema-version checks are covered by tests when durable tables are added or changed.
- Sensitive fields are not written to `shared_preferences`, logs, Crashlytics, exports, or temporary artifacts.
- Error messages tell the user what happened and what they can do next.
- The feature still works offline unless the locked PRD explicitly requires network or AI access.
- Manual QA steps have been executed and captured before moving to the next dependent feature.
