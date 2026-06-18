# AI Trainer Chat + Update Flows Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-09 |
| Milestone Coverage | M9 |
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

Build the conversational AI trainer and app-actionable update flows: normal chat, chat-to-save workout/programme, exercise swaps, deloads, programme updates, and plateau suggestions grounded in local data.

## 3. User-Facing Outcomes

- User can ask normal training questions conversationally.
- User can explicitly trigger save flows from chat.
- User can request exercise swaps or programme changes with review before apply.
- User can get deload or plateau suggestions based on local evidence.
- App-actionable chat outputs validate before persistence.

## 4. Scope

### 4.1 In Scope

- AI trainer chat UI
- Conversation state stored locally if implemented
- Intent routing for conversational vs save/update flows
- Chat-save workout/programme operation
- Exercise swap apply/update
- Deload week generation
- Plateau suggestion flow using M5 events
- Review/apply update screens

### 4.2 Out of Scope

- Custom user prompt system
- Background proactive AI coaching
- Medical diagnosis
- Cloud chat history sync

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M4 local programmes/workouts
- M5 analytics/plateau events
- M7 AI infrastructure
- M8 generation mappers

### 5.2 Enables Later Work

- More complete private release experience
- Future v2 coaching extensions

## 6. Data Ownership and Storage Plan

- Tables: `ai_chat_threads`, `ai_chat_messages` if chat history is persisted; `programme_update_drafts`, `applied_programme_updates` for update review.
- Do not store raw provider responses unless they are the sanitized user-facing chat content.
- Prompt internals and candidate lists are not persisted.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `aiTrainerChatControllerProvider`
- `chatIntentRouterProvider`
- `programmeUpdateControllerProvider`
- `exerciseSwapControllerProvider`
- `deloadControllerProvider`
- `plateauSuggestionControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- AI chat screen
- Save-from-chat review
- Programme update review
- Exercise swap review
- Deload week review
- Plateau suggestion review
- Apply confirmation

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Normal chat: assemble conversational context, call provider, show text response; no persistence changes.
- Explicit save: route to structured operation, validate JSON, show draft, save only after confirmation.
- Exercise swap: build candidate list, request structured update, validate fatigue/loading adjustments, review, apply transactionally.
- Plateau: use M5 plateau event evidence, request 3-week plan, review, save/apply if confirmed.

## 10. Validation Rules

- Normal chat cannot silently save or mutate data.
- App-actionable chat must return JSON envelope.
- Updates may only reference existing app-provided refs.
- Exercise swaps must use valid exercise IDs.
- Plateau plan must use evidence and exactly one rationale tag per session where required.
- Deload changes must preserve programme structure unless user chooses otherwise.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Chat history is local.
- Chat prompts/responses are not Crashlytics payloads.
- Do not send full logs/profile unless operation requires scoped evidence.
- Medical/injury/eating-disorder concerns are escalated safely.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Provider unavailable
- Ambiguous user intent
- Invalid update refs
- Repair failed
- Programme changed before applying update
- Unsafe/medical request blocked

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M9-T01 | Build AI chat UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T02 | Implement conversational prompt route | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T03 | Implement chat intent router | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T04 | Implement chat-save workout/programme flows | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T05 | Implement exercise swap flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T06 | Implement deload flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T07 | Implement plateau suggestion flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T08 | Build update review/apply screens | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M9-T09 | Add M9 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Normal chat cannot mutate app state.
- Explicit save flow creates review draft.
- Swap flow applies transactionally.
- Plateau suggestion uses local plateau event.
- Unsafe medical advice request is blocked safely.

## 15. Manual QA Checklist

- Ask normal question.
- Ask to create and save workout from chat.
- Ask for exercise swap.
- Ask for deload.
- Trigger plateau suggestion from event.
- Ask injury/medical question and verify safe handling.

## 16. Automated Test Coverage

- Intent router tests
- Update ref validation tests
- Swap fatigue adjustment tests
- Plateau schema tests
- Chat privacy tests
- Transaction conflict tests

## 17. Handoff Notes

- M10 can share workouts/programmes produced or modified by AI once they are saved locally.

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
