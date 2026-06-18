# Progress Media Tracking Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-06 |
| Milestone Coverage | M6 |
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

Build local progress media tracking before AI infrastructure: photo sets, short all-sides videos, thumbnails, session notes, optional bodyweight/measurement snapshots, storage controls, and reminders that start only after the first saved media session.

## 3. User-Facing Outcomes

- The user can capture or import progress photos.
- The user can capture or import a short all-sides video.
- The user can save progress media sessions locally.
- The user can compare media sessions manually.
- Reminder cadence can be enabled only after the first saved session.

## 4. Scope

### 4.1 In Scope

- Photo capture/import for front/back/left/right
- Video capture/import with duration cap
- Thumbnail generation
- Media session metadata
- Session notes
- Optional snapshot fields
- Reminder prompt after first session
- Cadence: every 2 weeks/monthly/every 3 months/off
- Storage usage and delete controls

### 4.2 Out of Scope

- AI physique analysis
- Cloud backup
- Public sharing
- Computer-vision form checking
- Automatic body-fat estimation

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M1 file store
- M3 profile/settings and notification permission
- M4 optional bodyweight/history references

### 5.2 Enables Later Work

- M13 AI physique analysis
- M14 privacy audit

## 6. Data Ownership and Storage Plan

- Tables: `progress_media_sessions`, `progress_media_items`, `progress_media_thumbnails`, `progress_media_reminder_state`, optional `progress_measurement_snapshots`.
- Raw media stored as files, not database blobs.
- Drift stores metadata, view angle, file refs, created date, notes, and deletion state.
- Thumbnails are local files with file registry records.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `progressMediaCaptureControllerProvider`
- `progressMediaImportControllerProvider`
- `progressMediaSessionControllerProvider`
- `progressMediaGalleryControllerProvider`
- `progressReminderControllerProvider`
- `progressStorageControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Progress dashboard
- Capture/import picker
- Photo set organizer
- Video preview
- Save session screen
- Session detail
- Session comparison view
- Reminder cadence prompt
- Storage management screen

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Capture photo set: user selects/captures sides, app validates, creates thumbnails, saves session metadata transactionally.
- Capture video: enforce duration cap, preview, generate thumbnail, save.
- First saved session: ask reminder cadence.
- Delete session: delete metadata and files transactionally or mark deleted then cleanup.

## 10. Validation Rules

- At least one photo or one video required.
- Side labels must be explicit when available.
- Video must respect duration/size cap.
- Reminder prompt cannot appear before first saved session.
- Missing file metadata must show recoverable broken-media state.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Progress media never goes to Crashlytics.
- Media remains local unless user explicitly consents to M13 analysis later.
- Media excluded from `.aedifyplan`, PDF export, external imports, and default sharing.
- File paths are private and redacted.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Camera permission denied
- Photo library permission denied
- File too large
- Video too long
- Thumbnail generation failed
- Storage low
- Media file missing

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M6-T01 | Create progress media tables | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T02 | Implement media file categories | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T03 | Build capture/import picker | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T04 | Build photo set organizer | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T05 | Build video preview/save flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T06 | Implement thumbnail generation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T07 | Build session gallery/detail | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T08 | Implement reminder gating/cadence | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T09 | Build storage management | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M6-T10 | Add M6 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Photo session saves and reloads.
- Video session saves and previews.
- Reminder prompt appears only after first saved session.
- Deleting a session removes files or marks cleanup.
- Progress media is excluded from exports/logs.

## 15. Manual QA Checklist

- Create photo-only session.
- Create video-only session.
- Create combined session.
- Deny camera permission.
- Delete session and verify files removed.
- Set reminder cadence and verify local notification scheduling.

## 16. Automated Test Coverage

- Media metadata tests
- File lifecycle tests
- Reminder gating tests
- Permission state tests
- Delete cleanup tests
- Widget tests for gallery empty/error states

## 17. Handoff Notes

- M13 reuses selected media and extracted frames only after explicit AI consent.
- M14 must audit progress media exclusion from all exports and Crashlytics.

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
