# Optional AI Physique Analysis Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-13 |
| Milestone Coverage | M13 |
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

Build explicit-consent AI physique analysis on top of saved progress media and AI infrastructure, returning rough body-fat ranges with confidence and training-oriented feedback while enforcing strict safety, privacy, and non-medical boundaries.

## 3. User-Facing Outcomes

- User can select saved progress media for AI analysis.
- App asks explicit consent before sending media/frames to BYOK provider.
- Analysis returns rough body-fat range, confidence, limitations, and training-focused observations.
- Analysis snapshots remain local and are excluded from sharing/export by default.
- Unsafe outputs are blocked or repaired.

## 4. Scope

### 4.1 In Scope

- Single-session analysis
- Comparison analysis baseline/previous vs latest
- Local frame extraction from videos where practical
- Media package minimization
- Provider image/media capability gate
- `PROGRESS_MEDIA_ANALYSIS/analyze`, `compare`, `repair`
- Analysis snapshot storage
- Safety wording and disclaimers

### 4.2 Out of Scope

- Medical diagnosis
- Precise clinical body composition
- Attractiveness scoring
- Body shaming
- Extreme diet advice
- Automatic background analysis
- CV form checking

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M6 progress media
- M7 AI infrastructure
- M3 provider capabilities

### 5.2 Enables Later Work

- Private v1 progress insights with BYOK consent

## 6. Data Ownership and Storage Plan

- Tables: `physique_analysis_snapshots`, `physique_analysis_media_refs`, optional `video_extracted_frame_refs`.
- Raw media remains file-based.
- Snapshot stores structured result, confidence, media used, limitations, created time, provider/model metadata, and schema version.
- Do not store raw prompt/response.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `physiqueAnalysisSelectionControllerProvider`
- `physiqueAnalysisConsentControllerProvider`
- `videoFrameExtractionControllerProvider`
- `physiqueAnalysisOperationControllerProvider`
- `physiqueAnalysisSnapshotControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Progress session analysis CTA
- Media selection screen
- Consent screen
- Analysis progress
- Analysis result screen
- Comparison result screen
- Analysis history/snapshot detail

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Analyze: choose media, check provider capability, show consent, package selected photos/frames only, call AI, validate structured output, repair once if needed, show result, save snapshot if user confirms/flow allows.
- Compare: select baseline/previous and latest, package comparable views/frames, call AI compare, validate, show trend-focused result.

## 10. Validation Rules

- Body-fat estimate must be a range, not a precise number.
- Confidence level and limitations required.
- No medical diagnosis.
- No attractiveness scoring or physique ranking.
- No body shaming or extreme dieting advice.
- Media used must match selected media only.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Media sent only after explicit consent.
- No unrelated progress media, lift logs, measurements, injuries, chat history, API keys, or DB records sent.
- Analysis snapshots excluded from `.aedifyplan`, PDFs, external imports, Crashlytics, and default sharing.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- No eligible media
- Provider lacks image support
- Consent declined
- Frame extraction failed
- AI output unsafe
- Schema validation failed
- Repair failed

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M13-T01 | Build media selection for analysis | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T02 | Build consent screen | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T03 | Implement frame extraction packaging | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T04 | Implement provider capability gate | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T05 | Implement analyze operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T06 | Implement compare operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T07 | Implement output safety validator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T08 | Build result/snapshot UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T09 | Add export/privacy exclusions | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M13-T10 | Add M13 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Analysis cannot start without explicit consent.
- Selected media only is packaged.
- Result uses range and confidence.
- Unsafe/precise/shaming output is blocked or repaired.
- Snapshot remains local and excluded from exports.

## 15. Manual QA Checklist

- Analyze photo set.
- Analyze video through extracted frames.
- Compare baseline vs latest.
- Decline consent.
- Use unsupported provider.
- Simulate unsafe AI output.
- Inspect exports for absence of snapshots/media.

## 16. Automated Test Coverage

- Consent gate tests
- Media package minimization tests
- Frame extraction tests
- Physique schema tests
- Safety validator tests
- Export exclusion tests

## 17. Handoff Notes

- M14 must perform end-to-end privacy and safety audit for progress media and physique analysis.

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
