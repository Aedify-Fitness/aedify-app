# Foundation + Local Data Spine Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-01 |
| Milestone Coverage | M0–M1 |
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

Build the app foundation that every later feature depends on: repository structure, routing shell, Riverpod dependency graph, Drift database, migration framework, local file-store abstraction, secure storage wrapper, preferences wrapper, logging/redaction, error model, environment/config, and basic app settings.

## 3. User-Facing Outcomes

- Stable launch on iOS and Android.
- Basic route shell with placeholder feature areas.
- Startup loading, success, and safe failure states.
- No direct plugin access outside approved wrappers.
- Crash diagnostics initialized through the redaction boundary only.

## 4. Scope

### 4.1 In Scope

- Flutter app shell and routing scaffold.
- Riverpod provider root and dependency graph.
- Drift database bootstrap, schema-version policy, migration harness, and transaction helper.
- Local file-store directory/category system.
- `shared_preferences` wrapper for non-critical UI preferences only.
- `flutter_secure_storage` wrapper for BYOK keys and secrets only.
- Dio base client factory with redacted interceptors.
- App-wide error model and user-safe error presenter.
- Privacy classifier, redaction utilities, and Crashlytics allowlist.
- Feature flag registry and private-release environment config.

### 4.2 Out of Scope

- Exercise dataset sync.
- Real onboarding/profile forms.
- AI provider calls.
- Workout logging.
- Progress media capture.
- Import/export.
- Any backend service or cloud sync.

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- Locked PRD v1.10 re-locked after package validation.
- Package validation decision log.
- Updated roadmap v1.3.
- Architecture implementation plan v1.0.

### 5.2 Enables Later Work

- M2 exercise dataset sync.
- M3 onboarding/profile/BYOK.
- M4 manual workouts/logging.
- M6 progress media tracking.
- M7 AI infrastructure.
- M10–M12 sharing/import flows.

## 6. Data Ownership and Storage Plan

- Create `app_meta` for local app metadata and schema markers.
- Create optional `schema_migrations_log` for migration audit.
- Create `local_file_records` for managed file metadata.
- Keep feature-specific tables out of M1 unless required by scaffolding.
- All multi-record writes must go through transaction helpers.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `appBootstrapControllerProvider` runs startup initialization.
- `appDatabaseProvider` owns Drift instance.
- `preferencesStoreProvider` wraps `shared_preferences`.
- `secureSecretStoreProvider` wraps `flutter_secure_storage`.
- `fileStoreProvider` creates and manages sandbox categories.
- `privacyClassifierProvider` and `appLoggerProvider` enforce redaction.
- `networkClientProvider` exposes base Dio.

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Splash/startup state screen.
- Root navigation shell.
- Generic safe error screen.
- Developer-only diagnostics screen with redacted metadata only.
- Placeholder Settings screen.

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Fresh install bootstrap: initialize Firebase, open Drift, create file directories, load preferences, initialize redacted logging, route to shell.
- Relaunch bootstrap: run migrations, cleanup expired temp files, verify schema markers, route to shell.
- Failure bootstrap: classify error, redact metadata, show safe retry path.

## 10. Validation Rules

- No API key can be stored outside secure storage.
- No durable user data can be stored in `shared_preferences`.
- Startup cannot continue when Drift migration fails.
- Crash/log payloads must pass privacy classifier before emission.
- Temporary file categories must have cleanup policy.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Crashlytics is allowlist-only.
- No prompt, AI response, lift log, body measurement, progress media path, screenshot, file excerpt, or database dump may be logged.
- Secrets never leave secure storage except to construct an explicit provider request in memory.
- Developer diagnostics must be redacted by default.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Database initialization failed.
- Migration failed.
- Secure storage unavailable.
- File directory creation failed.
- Firebase initialization failed.
- Crashlytics disabled or unavailable.

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M0–M1-T01 | Create Flutter app shell and route scaffold | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T02 | Add Riverpod provider root and bootstrap controller | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T03 | Implement Drift bootstrap and migration harness | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T04 | Implement local file-store abstraction | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T05 | Implement preferences wrapper with key allowlist | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T06 | Implement secure secret wrapper | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T07 | Implement Dio base client and redacted interceptors | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T08 | Implement privacy classifier and redaction utilities | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T09 | Configure Firebase core/auth/storage/crashlytics placeholders | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T10 | Create app-wide error model | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T11 | Add developer diagnostics screen | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M0–M1-T12 | Add M1 integration smoke tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- App launches cleanly on iOS and Android.
- Drift opens and migration harness has tests.
- Local file categories are created and temp cleanup can run.
- Preferences wrapper rejects disallowed keys in tests.
- Secure storage wrapper supports save/read/delete in mocked tests.
- Crashlytics test payload is redacted and allowlisted.
- No feature imports Flutter plugin APIs directly except wrappers.

## 15. Manual QA Checklist

- Fresh install on iOS.
- Fresh install on Android.
- Launch offline.
- Force close and relaunch.
- Simulate migration failure.
- Simulate secure-storage failure.
- Trigger fake redacted crash event.
- Clear app data and relaunch.

## 16. Automated Test Coverage

- Unit tests for privacy classifier.
- Unit tests for preferences key allowlist.
- Unit tests for app error presenter.
- Drift migration tests from empty DB to current version.
- Widget test for startup loading/success/failure states.

## 17. Handoff Notes

- M2 can use the Drift, Firebase Storage, Dio, file store, and schema-version helpers.
- M3 can use the secure-storage wrapper for BYOK and preferences wrapper for harmless UI settings.
- All later features must import storage/network/logging through M1 abstractions only.

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
