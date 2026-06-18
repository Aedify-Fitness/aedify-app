# Privacy, Resilience + Private Release Hardening Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-14 |
| Milestone Coverage | M14 |
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

Harden the completed v1 app for a private release of up to 5 users: privacy audit, Crashlytics allowlist verification, storage cleanup, failure recovery, migration tests, offline behavior, accessibility checks, performance checks, and release readiness.

## 3. User-Facing Outcomes

- App is ready for private iOS/Android release.
- Crashlytics payloads are redacted and allowlisted.
- All sensitive data stays local unless explicitly consented to BYOK AI flow.
- Offline behavior is tested.
- Import/export/media temporary files are cleaned.
- Known unsupported states are user-friendly.

## 4. Scope

### 4.1 In Scope

- Privacy audit
- Crashlytics allowlist tests
- Schema migration tests
- Offline mode tests
- Storage cleanup tests
- Provider failure tests
- Import/export fixture tests
- Progress media storage checks
- Accessibility pass
- Performance smoke tests
- Release checklist
- Known limitations document

### 4.2 Out of Scope

- Public launch operations
- Monetization
- Cloud sync
- Account recovery
- External beta analytics

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M0–M13 complete or feature-frozen

### 5.2 Enables Later Work

- Private release to maximum 5 users

## 6. Data Ownership and Storage Plan

- Audit all Drift tables for classification.
- Audit all file categories for cleanup/exportability.
- Audit preferences keys for disallowed data.
- Audit secure storage key names.
- Audit Crashlytics context allowlist.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `releaseReadinessControllerProvider` optional developer-only checklist.
- `privacyAuditServiceProvider` for test/dev checks.
- `storageCleanupControllerProvider` final verification.

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Developer-only release readiness screen
- User-facing About/Privacy summary
- Storage management review
- Safe unsupported/update-required screens

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Run privacy audit fixtures.
- Run all migration tests.
- Run offline-first scenarios.
- Run AI/provider unavailable scenarios.
- Run import/export/media cleanup scenarios.
- Generate private release checklist sign-off.

## 10. Validation Rules

- No secrets in Drift/preferences/files/logs.
- No private data in Crashlytics.
- No progress media or AI internals in exports.
- No temporary image/import artifacts after cleanup.
- Unsupported schemas show clear update-required state.
- All critical writes transactional.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- This milestone is the final enforcement gate for every privacy promise.
- Any failure blocks release until fixed or formally descoped.
- Crashlytics must remain diagnostics-only.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Migration failure
- Dataset unsupported
- Provider unavailable
- Storage low
- File cleanup failed
- Permission denied
- Export/import corruption
- Crash redaction failure

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M14-T01 | Create privacy audit checklist | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T02 | Create Crashlytics payload tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T03 | Create migration test matrix | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T04 | Create offline QA matrix | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T05 | Audit preferences/secure storage | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T06 | Audit file lifecycle cleanup | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T07 | Run import/export fixture tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T08 | Run progress media privacy tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T09 | Run AI safety tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T10 | Prepare private release build checklist | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M14-T11 | Write known limitations/release notes | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- All milestone exit checklists pass.
- All privacy snapshot tests pass.
- Manual QA passes on iOS and Android.
- Crashlytics test event contains only allowed fields.
- Private release notes and known limitations are written.
- No product scope drift is found.

## 15. Manual QA Checklist

- Full fresh install path.
- Offline after dataset sync.
- BYOK setup and removal.
- Manual programme/workout/logging.
- AI generation with fake/real provider.
- Progress media capture/delete.
- Sharing/export/import.
- External text/image import.
- Physique analysis consent flow.
- Crash redaction verification.

## 16. Automated Test Coverage

- End-to-end smoke tests
- Migration matrix tests
- Privacy snapshot tests
- Export fixture diff tests
- File cleanup tests
- Accessibility checks
- Performance smoke tests
- Provider failure tests

## 17. Handoff Notes

- After M14, implementation can move to private release packaging and user feedback collection.

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
