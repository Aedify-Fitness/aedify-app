# Exercise Dataset, Library + Bodymap Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-02 |
| Milestone Coverage | M2 |
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

Implement the versioned exercise dataset sync from Firebase Storage, persist the exercise catalog locally in Drift, and build the exercise library experience including search, filters, muscle-group browsing, bodymap paths, details, videos, and optional TTS step playback.

## 3. User-Facing Outcomes

- The user can download the exercise library once and use it offline.
- The user can search/filter exercises by name, muscle group, equipment, modality, difficulty, force, and mechanic.
- The user can browse exercises from the 14-bucket bodymap.
- Exercise detail pages show instructions and videos where available.
- Dataset version and sync status are visible in Settings/About.

## 4. Scope

### 4.1 In Scope

- Firebase anonymous access for manifest/dataset read.
- Versioned dataset manifest handling.
- Dataset schema validation and compatible migration policy.
- Bulk import into Drift with transaction safety.
- Exercise library list/search/filter UI.
- Exercise detail page with steps, metadata, video list, and TTS step playback.
- 14-bucket muscle-group model.
- Bodymap SVG rendering with path-hit-area contract.
- Offline dataset availability after first successful sync.

### 4.2 Out of Scope

- Runtime MuscleWiki API calls.
- Per-user MuscleWiki BYOK.
- Cloud sync of user favorites.
- Form checking or pose scoring.
- AI candidate ranking beyond deterministic local filtering.

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M1 app foundation.
- Firebase Storage configuration.
- `aedify-musclewiki-exercises.firebase.json`.
- `aedify-transform-for-firebase.js` mapping contract.
- Bodymap SVG assets matching the 14 UI buckets.

### 5.2 Enables Later Work

- M4 manual workout/programme builders.
- M7 AI candidate-list generation.
- M8 AI programme/workout generation.
- M10 share import validation.
- M11/M12 external import exercise resolution.

## 6. Data Ownership and Storage Plan

- Tables: `exercise_datasets`, `exercises`, `exercise_muscles`, `exercise_groups`, `exercise_videos`, `exercise_steps`, `exercise_aliases` if local aliases are added.
- Persist `schema_version`, `generated_at`, `source`, `exercise_count`, download timestamp, and local import status.
- Exercise IDs from the dataset remain canonical external exercise IDs.
- Do not store video blobs in Drift; store URLs/metadata only.
- Create indexes on name, difficulty, equipment, modality, muscle group, and category.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `exerciseDatasetSyncControllerProvider` manages manifest check/download/import state.
- `exerciseRepositoryProvider` exposes local queries.
- `exerciseSearchControllerProvider` manages search/filter state.
- `bodymapSelectionProvider` maps selected muscle bucket to exercise filters.
- `exerciseDetailControllerProvider` loads exercise, videos, steps, and TTS state.

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Dataset sync screen/state in first launch or Exercise Library.
- Exercise Library list with filters.
- Exercise filter sheet.
- Exercise detail page.
- Bodymap browse page.
- Dataset version/status section in Settings/About.

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- First sync: anonymous Firebase auth, fetch manifest, compare local dataset state, download JSON, validate top-level schema, validate each exercise, import transactionally, mark active dataset.
- Subsequent launch: check manifest when online, skip if version unchanged, use local data offline.
- Search: apply local Drift query with debounce and active filters.
- Bodymap: user taps SVG path, path maps to one of 14 buckets, app filters exercise list by bucket.
- Exercise detail: load metadata and videos; if video fails, steps remain available.

## 10. Validation Rules

- Top-level dataset must include schema_version, generated_at, source, exercise_count, exercises.
- Unsupported future schema must show update-required state.
- Exercise IDs must be unique.
- Every exercise must have name, difficulty, primary_muscles, muscle_groups, category, modality, equipment field, steps array, and videos array.
- Every muscle_group must be one of the 14 UI buckets.
- Video entries must have URL, angle, gender, and optional image metadata.
- Bodymap path IDs must map to valid buckets.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Firebase dataset sync sends no PII.
- Anonymous Firebase Storage access must not transmit user profile or logs.
- Exercise browsing events are not analytics events.
- Crash reports may include dataset version and error code only, never user query text if search text may be sensitive.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Offline before first dataset sync.
- Firebase auth failure.
- Manifest fetch failure.
- Dataset download timeout.
- Unsupported dataset schema.
- Invalid dataset content.
- Import transaction failure.
- Exercise video playback failure.

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M2-T01 | Create dataset manifest client | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T02 | Implement anonymous Firebase dataset access | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T03 | Create Drift exercise schema and DAOs | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T04 | Implement dataset validator | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T05 | Implement transactional dataset importer | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T06 | Build dataset sync controller | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T07 | Build Exercise Library list and filters | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T08 | Build exercise detail screen | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T09 | Integrate video playback fallback | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T10 | Integrate TTS step playback | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T11 | Implement bodymap SVG asset contract | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M2-T12 | Add dataset status UI and tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- A fresh install can sync and import the full dataset.
- After sync, library works offline.
- Search/filter results are correct against fixture data.
- Bodymap selections map to correct 14 buckets.
- Unsupported future schema shows update-required message.
- Failed video playback does not block instructions.
- Dataset import is atomic; partial imports are not left active.

## 15. Manual QA Checklist

- Install app with no local dataset and online.
- Install app with no local dataset and offline.
- Relaunch after successful sync while offline.
- Force a future schema in fixture.
- Search by exercise name, equipment, muscle group, difficulty.
- Tap every bodymap bucket and verify results.
- Open exercise with multiple videos and with no playable video.

## 16. Automated Test Coverage

- Dataset JSON fixture validation tests.
- Drift import transaction rollback test.
- Manifest version comparison tests.
- Bodymap path contract tests.
- Search/filter query tests.
- Widget tests for empty/offline/error states.

## 17. Handoff Notes

- M4 builders must select exercises through the repository.
- M7 candidate-list builder must use hard filters from local exercise queries.
- M11/M12 import matching must resolve names against local exercise indexes.

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
