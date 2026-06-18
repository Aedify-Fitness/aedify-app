# Analytics, PRs + Plateau Base Logic Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-05 |
| Milestone Coverage | M5 |
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

Compute local training insights from logged workouts: PRs, e1RM estimates, volume, trend charts, adherence, and deterministic plateau signals that later AI plateau suggestions can use.

## 3. User-Facing Outcomes

- The user can see training history and simple progress charts.
- The app detects personal records from working sets.
- The app estimates e1RM where appropriate.
- The app identifies plateau candidates locally without AI.
- Warm-up sets do not contaminate PR, e1RM, plateau, or progression analytics.

## 4. Scope

### 4.1 In Scope

- PR detection
- e1RM estimation
- Volume trends
- Exercise history charts
- Programme adherence summaries
- Plateau candidate event generation
- Local notifications/prompts for plateau review where allowed

### 4.2 Out of Scope

- AI plateau advice
- Nutrition analytics
- Wearable analytics beyond supported health integration
- Public leaderboards

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M4 logged sets
- M3 notification settings optional

### 5.2 Enables Later Work

- M7 AI infrastructure
- M9 plateau suggestions
- M14 release hardening

## 6. Data Ownership and Storage Plan

- Tables: `personal_records`, `exercise_analytics_snapshots`, `plateau_events`, `analytics_cache`, optional `adherence_summaries`.
- Derived analytics can be recomputed; persist snapshots only when useful for performance/history.
- Link PRs to source logged set/session.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `analyticsDashboardControllerProvider`
- `exerciseHistoryControllerProvider`
- `prControllerProvider`
- `plateauDetectionControllerProvider`
- `analyticsRecomputeJobProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Analytics dashboard
- Exercise history detail
- PR list
- Plateau candidate prompt/detail
- Chart components

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- After workout completion: enqueue local analytics recompute, detect PRs, update charts, evaluate plateau candidates.
- Manual recompute: rebuild analytics from logs.
- Plateau event: create local event with evidence, not advice.

## 10. Validation Rules

- Only working sets count for PR/e1RM/plateau.
- Bodyweight/time-based exercises need separate PR rules.
- e1RM should not be computed from unsuitable rep ranges or missing load.
- Plateau event must cite actual local evidence fields.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Logs and body metrics remain local.
- Charts cannot send data off-device.
- Crash reports may include analytics error code, not exercise log contents.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- No logged data empty state
- Insufficient data for PR/e1RM
- Corrupted/missing source session
- Chart rendering failure
- Notification permission denied

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M5-T01 | Create analytics tables | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T02 | Implement PR engine | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T03 | Implement e1RM engine | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T04 | Implement volume/adherence summaries | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T05 | Build analytics dashboard | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T06 | Build exercise history charts | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T07 | Implement plateau detection events | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T08 | Add analytics recompute job | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M5-T09 | Add M5 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- PRs appear after qualifying sessions.
- Warm-up sets never create PRs.
- Plateau events are generated only after enough evidence.
- Charts render from local data offline.
- Analytics cache can be safely rebuilt.

## 15. Manual QA Checklist

- Complete workouts with increasing loads.
- Verify PR creation.
- Add warm-up heavier than prior and verify no PR.
- Create repeated stalled logs and verify plateau event.
- Clear analytics cache and recompute.

## 16. Automated Test Coverage

- PR calculation tests
- e1RM formula tests
- Warm-up exclusion tests
- Plateau threshold tests
- Chart view-model tests
- Analytics migration/cache tests

## 17. Handoff Notes

- M9 AI plateau suggestions must use plateau events and log evidence, not raw unsupported assumptions.

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
