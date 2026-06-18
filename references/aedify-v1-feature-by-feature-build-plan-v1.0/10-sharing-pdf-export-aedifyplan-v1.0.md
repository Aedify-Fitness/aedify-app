# Local Sharing + PDF Export Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-10 |
| Milestone Coverage | M10 |
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

Build local file-based sharing: `.aedifyplan` export/import for structured app-native plans and PDF export for human-readable read-only sharing, with strict privacy modes and import validation.

## 3. User-Facing Outcomes

- User can export saved workouts/programmes as `.aedifyplan`.
- User can export a human-readable PDF.
- User can choose template or exact-prescription privacy mode.
- User can import `.aedifyplan` as an inactive editable local copy.
- Exports exclude private profile/log/media/AI internals.

## 4. Scope

### 4.1 In Scope

- Export format picker
- `.aedifyplan` schema v1
- Share schema validator
- PDF generation
- Native OS share sheet
- Template vs exact prescription mode
- Optional exercise instructions appendix
- Custom exercise export/import
- Import preview and inactive save

### 4.2 Out of Scope

- Hosted share links
- Cloud PDFs
- PDF import back into app-native structure
- Social feed/marketplace

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M4 saved workouts/programmes
- M2 exercise library
- M1 file store
- M14 privacy rules ongoing

### 5.2 Enables Later Work

- M11 external import contrast/reuse
- Private plan exchange between max 5 users

## 6. Data Ownership and Storage Plan

- Use local export temp files and file records.
- `.aedifyplan` contains share_schema_version=1, plan/workout structure, allowed prescription fields, custom exercise definitions, and no local source IDs that should be reused.
- Imported custom exercises are recreated with new local IDs.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `shareExportControllerProvider`
- `pdfExportControllerProvider`
- `aedifyplanImportControllerProvider`
- `sharePrivacyModeControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Export format picker
- Privacy mode warning
- PDF option screen
- Share progress screen
- Import file picker
- Import validation preview
- Import conflict/custom exercise review

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Export: choose saved plan, choose format/privacy, validate exportable fields, generate file, invoke share sheet, cleanup temp when safe.
- Import: pick `.aedifyplan`, validate schema/version, map exercises/custom exercises, show preview, save inactive editable copy.
- PDF: render readable programme with optional logging tables and optional instructions appendix.

## 10. Validation Rules

- Reject unsupported share schema.
- Never import app-generated PDF as structured plan.
- Imported plans inactive by default.
- Custom exercises require complete local definitions before save.
- Template mode must remove exact loads where required.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Exports exclude profile, injuries, logs, PRs, body measurements, photos/videos, API keys, chat history, prompts, raw AI responses, candidate lists, AI snapshots, progress media, screenshots, source import excerpts.
- Exact prescription mode requires explicit warning.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Unsupported file version
- Corrupted share file
- Missing custom exercise fields
- PDF generation failed
- Share sheet cancelled
- Insufficient storage

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M10-T01 | Define `.aedifyplan` schema v1 | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T02 | Build export mapper | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T03 | Build privacy mode filtering | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T04 | Build PDF renderer | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T05 | Build OS share integration | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T06 | Build import validator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T07 | Build import preview/save inactive flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T08 | Implement custom exercise export/import | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M10-T09 | Add sharing tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- `.aedifyplan` export validates against schema.
- PDF export is readable and not importable.
- Template mode excludes exact prescription fields.
- Import creates inactive editable copy.
- Custom exercises re-created with new IDs.
- Private fields are absent from exported fixture.

## 15. Manual QA Checklist

- Export workout app file.
- Export programme PDF.
- Export both.
- Import app file and activate copy manually.
- Attempt importing PDF and verify blocked.
- Inspect export JSON for excluded fields.

## 16. Automated Test Coverage

- Share schema validation tests
- Export privacy snapshot tests
- Import mapping tests
- Custom exercise recreation tests
- PDF content tests
- Unsupported schema tests

## 17. Handoff Notes

- M11/M12 external imports use similar review-before-save patterns but different source handling.

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
