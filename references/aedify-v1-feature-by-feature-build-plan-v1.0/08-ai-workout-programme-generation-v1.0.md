# AI Workout + Programme Generation Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-08 |
| Milestone Coverage | M8 |
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

Build AI-generated daily workout and multi-week programme flows on top of the validated AI infrastructure, with review-before-save, beginner-path handling, powerbuilding eligibility, structured validation, and deterministic local persistence.

## 3. User-Facing Outcomes

- User can generate a daily workout from profile/goals/equipment.
- User can generate a multi-week programme.
- Beginner users receive the locked beginner-path behavior.
- Eligible non-beginners can receive strength + hypertrophy/powerbuilding-style outputs without copied source programmes.
- Generated content is reviewed before save and persisted only after validation.

## 4. Scope

### 4.1 In Scope

- Daily workout generation
- Multi-week programme generation
- Beginner Path A/Path B selector
- Candidate-list construction
- Set-level prescriptions
- Warm-up/working set distinction
- Superset support only where allowed
- Powerbuilding scoped reference routing for eligible non-beginners
- Generated draft review/edit/save
- Needs-input and blocked states

### 4.2 Out of Scope

- Freeform chat
- External import
- Image import
- Physique analysis
- Automatic background generation

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M2 exercise library
- M3 profile/BYOK
- M4 save validators
- M5 analytics context where useful
- M7 AI infrastructure

### 5.2 Enables Later Work

- M9 AI chat save/update flows
- M10 sharing generated plans
- M14 final AI QA

## 6. Data Ownership and Storage Plan

- Use existing workout/programme tables from M4.
- Add optional `ai_generation_snapshots` only if storing redacted metadata; do not store prompts/raw responses.
- Drafts remain unsaved until user confirms.
- Generated workouts/programmes should record source=`ai-generated` and schema versions.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `dailyWorkoutGenerationControllerProvider`
- `programmeGenerationControllerProvider`
- `beginnerPathControllerProvider`
- `generatedDraftReviewControllerProvider`
- `aiSaveConfirmationControllerProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- AI workout generator form
- AI programme generator form
- Beginner path choice screen
- Generation progress screen
- Generated workout review
- Generated programme review
- Needs-input screen
- Blocked/unsupported provider screen

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Daily workout: gather profile, schedule, equipment, candidate list, call AI, validate, show draft, save as workout if confirmed.
- Programme: gather profile, target duration, schedule, candidate list, call AI, validate template, expand locally where required, review, save inactive/active by user choice.
- Beginner: if no established base, show Path A proven progression vs Path B custom beginner path before generation.
- Powerbuilding: only route supplemental reference for eligible non-beginner strength + hypertrophy requests.

## 10. Validation Rules

- Generated exercise IDs must exist in local library.
- AI cannot invent local refs.
- Set-level prescription required.
- Beginner AI outputs must not include advanced elements disallowed by PRD.
- AI-generated beginner outputs must not include supersets.
- Non-beginner strength-focused outputs must label warm-up and working sets.
- Powerbuilding output must not reproduce proprietary programme tables or exact sequences.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Only minimum needed profile/log context sent.
- Injuries/limitations sent only when needed for safety and never logged.
- Generated drafts remain local.
- No prompts/responses/candidate lists in Crashlytics.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- No BYOK key
- Missing bodyweight/lift estimate for Build Strength
- No valid candidate exercises
- Provider unsupported
- Invalid AI output
- Repair failed
- User cancels review

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M8-T01 | Build generation forms | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T02 | Build beginner path selector | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T03 | Implement candidate-list context packaging | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T04 | Implement daily workout AI operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T05 | Implement programme AI operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T06 | Build draft review UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T07 | Implement local save mapping | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T08 | Add powerbuilding gating | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T09 | Add generation error states | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M8-T10 | Add M8 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Daily workout generation works with fake provider fixtures.
- Programme generation validates and saves only after review.
- Beginner Path A/B behavior appears correctly.
- Invalid exercise IDs are rejected.
- Superset rules are enforced by experience/flow.
- Powerbuilding routing is gated correctly.

## 15. Manual QA Checklist

- Generate daily workout as beginner.
- Generate programme as non-beginner.
- Generate strength programme without enough anchors and verify needs-input.
- Attempt unsupported provider and verify blocker.
- Inspect saved source/schema metadata.

## 16. Automated Test Coverage

- Schema fixtures for daily workout/programme
- Beginner gating tests
- Powerbuilding eligibility tests
- Candidate ID rejection tests
- Warm-up rule tests
- Save transaction tests

## 17. Handoff Notes

- M9 chat save flows reuse the same generation validators and persistence mappers.

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
