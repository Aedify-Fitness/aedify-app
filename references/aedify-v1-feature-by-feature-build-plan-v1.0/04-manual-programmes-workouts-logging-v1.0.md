# Manual Programmes, Workouts + Logging Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-04 |
| Milestone Coverage | M4 |
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

Build the core non-AI training product: manual workouts, multi-week programmes, workout execution, set prescriptions, actual set logs, warm-up/working set separation, supersets, custom exercises, programme activation, and history.

## 3. User-Facing Outcomes

- The user can create and edit custom workouts and programmes.
- The user can run a workout and log actual weights, reps, RPE/RIR, rest, and notes.
- Warm-up sets are clearly separated from working sets.
- Supersets are supported in manual custom workouts/programmes.
- Completed sessions appear in local history.

## 4. Scope

### 4.1 In Scope

- Workout builder
- Programme builder
- Template/session model
- Set prescription editor
- Workout runner
- Set logger
- Superset grouping
- Warm-up/working set model
- Custom exercise creation
- Programme activation/deactivation
- History view

### 4.2 Out of Scope

- AI generation
- Sharing/export
- Analytics charts beyond basic history
- External import
- Progress media

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M1 foundation
- M2 exercise library
- M3 profile/settings for units/equipment defaults

### 5.2 Enables Later Work

- M5 analytics
- M7 AI validation save flows
- M10 sharing
- M11/M12 imports

## 6. Data Ownership and Storage Plan

- Tables: `workouts`, `workout_exercises`, `set_prescriptions`, `programmes`, `programme_weeks`, `programme_days`, `programme_workout_refs`, `workout_sessions`, `logged_sets`, `superset_groups`, `custom_exercises`.
- Use local UUIDs for user-created records.
- Exercise references may point to canonical exercise ID or local custom exercise ID.
- Warm-up and working set types must be explicit.
- Actual logs must preserve planned-vs-actual relationship when launched from plan.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `workoutBuilderControllerProvider`
- `programmeBuilderControllerProvider`
- `workoutRunnerControllerProvider`
- `setLogControllerProvider`
- `customExerciseControllerProvider`
- `activeProgrammeProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Workout builder
- Programme builder
- Exercise picker
- Set editor
- Superset editor
- Workout runner
- Rest timer
- Workout summary
- History detail
- Custom exercise editor

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Create workout: name, select exercises, add prescriptions, validate, save draft or saved workout.
- Run workout: instantiate session, display planned sets, log actuals, complete session.
- Create programme: define weeks/days, assign workouts, validate schedule, save inactive or activate.
- Superset: group exercises, show back-to-back execution order, preserve logs per exercise.

## 10. Validation Rules

- Workout must have at least one exercise.
- Each exercise must have valid set prescriptions.
- Working sets required for analytics; warm-up sets optional except by feature rules.
- Superset members must reference exercises in same workout.
- Custom exercise must have name and at least one muscle group or modality.
- Completed sessions cannot lose actual set data when programme changes later.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Free-form notes are private and cannot be logged.
- Workout/programme data stays local unless user explicitly exports later.
- Custom exercise definitions can be exported only in share flow with user action.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Missing exercise
- Invalid set prescription
- Unsaved changes
- Active programme conflict
- Workout session interrupted
- Custom exercise missing required fields

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M4-T01 | Create workout/programme Drift schema | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T02 | Build exercise picker integration | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T03 | Build set prescription editor | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T04 | Build workout builder | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T05 | Build programme builder | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T06 | Build workout runner | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T07 | Implement set logging | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T08 | Implement supersets | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T09 | Implement custom exercises | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T10 | Implement active programme state | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T11 | Add history screens | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M4-T12 | Add M4 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Manual workout can be created and run.
- Programme can be created, saved inactive, activated, and edited.
- Warm-up sets are visible but excluded by later analytics.
- Superset logging works.
- Workout session survives app backgrounding/relaunch if persisted mid-session.

## 15. Manual QA Checklist

- Create simple workout and complete it.
- Create programme with two weeks.
- Add warm-up sets and confirm labels.
- Create superset and complete runner flow.
- Create custom exercise and use it.
- Interrupt active session and resume.

## 16. Automated Test Coverage

- Builder validation tests
- Session persistence tests
- Superset order tests
- Warm-up/working set tests
- Custom exercise tests
- Widget tests for runner states

## 17. Handoff Notes

- M5 analytics reads logged sets and excludes warm-ups.
- M7/M8 use the same save validators for AI output.
- M10 exports this local model.

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
