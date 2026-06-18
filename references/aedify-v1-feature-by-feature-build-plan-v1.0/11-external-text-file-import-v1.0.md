# External Text File Import Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-11 |
| Milestone Coverage | M11 |
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

Build AI-assisted import for text-based programme/workout files: PDF text, TXT, MD, XLSX, and CSV. The app extracts relevant content locally, asks consent, sends only programme-relevant content to BYOK AI, receives a structured draft, resolves exercises, and saves only after review.

## 3. User-Facing Outcomes

- User can import supported text-based files.
- App extracts content locally before AI.
- User consents before extracted content is sent to BYOK provider.
- AI returns structured import draft, not adapted plan.
- Unmatched/ambiguous exercises require resolution before save.

## 4. Scope

### 4.1 In Scope

- File picker
- Supported file detection
- Text/table extraction
- Import consent screen
- External import AI parse/repair
- Draft persistence or temp state
- Exercise matching exact/alias/ambiguous/unmatched
- Custom exercise draft confirmation
- Import review screen
- Inactive-by-default save

### 4.2 Out of Scope

- Scanned/image-only PDFs
- Encrypted/corrupted PDFs
- Cloud-hosted import links
- Silent adaptation/personalization
- Importing app-generated PDFs

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M2 exercise library
- M4 programme/workout persistence
- M7 AI infrastructure
- M10 review/import patterns

### 5.2 Enables Later Work

- M12 image import reuse of external import draft/review/matching

## 6. Data Ownership and Storage Plan

- Tables: `external_import_sessions`, `external_import_drafts`, `external_import_exercise_matches`, `external_import_issues`, optional temp extracted content file records.
- Original source files are not stored by default.
- Persist sanitized structured draft and issue metadata only if needed to survive restart.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `externalImportPickerControllerProvider`
- `fileExtractionControllerProvider`
- `externalImportConsentControllerProvider`
- `externalImportParseControllerProvider`
- `exerciseResolutionControllerProvider`
- `externalImportReviewControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Import source picker
- File selection screen
- Extraction preview/summary
- AI consent screen
- Import progress
- Exercise resolution screen
- Custom exercise confirmation
- Import review/save screen

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Select file, validate type/size, extract text/tables locally, summarize extracted content, ask consent, call AI parse, validate draft, deterministic exercise match, ask user to resolve ambiguous/unmatched items, save inactive workout/programme.
- Repair flow: validation errors sent to AI once through M7 repair orchestrator.

## 10. Validation Rules

- Supported file type only.
- Weights with ambiguous units flagged for review.
- External imported programme may preserve source duration even if shorter than normal AI-generated minimum.
- Default mode is extract/normalize/structure only; no adaptation unless future explicit flow.
- Unresolved exercises block save.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Original source files not stored by default.
- Only programme-relevant extracted content sent after consent.
- No full profile/log data in default parse flow.
- Source excerpts, prompts, raw AI responses, and extraction snapshots excluded from exports and Crashlytics.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Unsupported file type
- Encrypted/corrupted file
- No extractable text
- Extraction partial
- AI consent declined
- Ambiguous units
- Unresolved exercises
- Provider failure

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M11-T01 | Build import source picker | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T02 | Implement file validation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T03 | Implement local extraction pipeline | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T04 | Build consent screen | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T05 | Implement AI parse operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T06 | Implement draft validator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T07 | Implement exercise matching | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T08 | Build resolution UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T09 | Build review/save inactive flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M11-T10 | Add M11 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- TXT/MD/CSV/XLSX/text-PDF fixtures import to drafts.
- Scanned PDF is blocked with clear message.
- Consent appears before AI call.
- Ambiguous/unmatched exercise cannot save until resolved.
- Imported programme saved inactive.
- Source files are not retained by default.

## 15. Manual QA Checklist

- Import TXT workout.
- Import CSV programme.
- Import text-based PDF.
- Attempt scanned PDF.
- Resolve ambiguous exercise.
- Create custom exercise from unmatched import.
- Save and inspect inactive programme.

## 16. Automated Test Coverage

- File type tests
- Extraction fixture tests
- AI import schema tests
- Exercise match tests
- Custom exercise resolution tests
- Privacy export exclusion tests

## 17. Handoff Notes

- M12 reuses draft schema, resolution UI, and review/save flow with image-specific source metadata.

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
