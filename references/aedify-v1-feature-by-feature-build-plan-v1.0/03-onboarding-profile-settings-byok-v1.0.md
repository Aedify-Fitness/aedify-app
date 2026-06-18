# Onboarding, Profile, Settings + BYOK Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-03 |
| Milestone Coverage | M3 |
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

Build the user setup layer: onboarding, profile, goals, equipment, schedule, units, settings, BYOK provider setup, provider capability checks, permission prompts, and safe update flows that may affect active programmes.

## 3. User-Facing Outcomes

- The user can complete onboarding in a short guided flow.
- The user can edit profile, goals, equipment, schedule, units, and preferences.
- The user can add, test, switch, or delete BYOK provider keys without exposing secrets.
- The app can detect provider/model capabilities before enabling AI image or physique-analysis flows.
- Profile changes that affect active programmes are surfaced safely.

## 4. Scope

### 4.1 In Scope

- Onboarding flow.
- Profile storage in Drift.
- Equipment, goal, experience, schedule, unit, and limitations models.
- Settings screens.
- BYOK provider/key setup.
- Provider test call using redacted errors.
- Capability metadata for text, JSON/schema, image input, multipart, and streaming support.
- Health and notification permission entry points.
- Profile-change impact prompts.

### 4.2 Out of Scope

- AI prompt execution beyond provider test/capability check.
- Workout generation.
- Cloud account creation.
- Subscription/billing.
- Public analytics.

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M1 foundation.
- M2 exercise dataset optional but useful for equipment lists and exercise substitutions.
- Validated provider list from PRD/instruction set.

### 5.2 Enables Later Work

- M4 user-personalized manual builders.
- M6 progress reminder settings.
- M7 AI provider abstraction.
- M8/M9 AI generation/chat.
- M12 image import provider gating.
- M13 physique analysis provider gating.

## 6. Data Ownership and Storage Plan

- Tables: `user_profile`, `profile_goals`, `profile_equipment`, `profile_schedule_days`, `profile_limitations`, `profile_substitutions`, `provider_configs`, `provider_capabilities`, `permission_states`.
- API keys are never stored in Drift; Drift stores only provider configuration metadata and key-present boolean.
- Non-sensitive UI settings may use preferences; durable profile data uses Drift.
- Profile history may be added for change impact if needed.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `onboardingControllerProvider` manages step completion and validation.
- `profileControllerProvider` loads/updates profile.
- `settingsControllerProvider` manages non-sensitive settings.
- `byokSetupControllerProvider` validates provider input and key presence.
- `providerCapabilityControllerProvider` checks model support and caches non-sensitive capability metadata.
- `permissionControllerProvider` coordinates local notification/health permission status.

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Onboarding welcome.
- Training experience/goals step.
- Schedule/session length step.
- Equipment access step.
- Body metrics/units step.
- Injuries/limitations/substitutions step.
- BYOK optional setup step.
- Profile screen.
- Settings screen.
- AI provider settings screen.
- Provider capability/result screen.

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- First-run onboarding: collect minimum profile fields, validate each step, save transactionally, mark onboarding complete.
- Profile edit: update values, detect active programme impact, warn user when regeneration may be needed.
- BYOK setup: choose provider, enter key, store key in secure storage, store non-secret metadata in Drift, run provider test/capability check.
- Provider switch: update active provider metadata without deleting other keys unless user chooses delete.
- Key deletion: delete secret, mark provider unavailable, disable dependent AI flows.

## 10. Validation Rules

- Experience level must map to approved enum.
- Goals must map to supported goal set.
- Schedule days/session length must fall within v1 constraints.
- Equipment values must map to local equipment taxonomy.
- API key field cannot be empty when saving provider key.
- Provider capabilities must be checked before enabling image input or progress media analysis.
- Injury/limitation notes are sensitive and must not be logged.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- API keys live only in secure storage.
- Provider test errors must not include raw request/response bodies.
- Injuries, limitations, notes, DOB, bodyweight, height, and profile free text are private.
- Permission states can be stored locally but not sent to Crashlytics except coarse redacted error codes.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Onboarding validation incomplete.
- Secure storage save/read failure.
- Provider test timeout.
- Provider authentication failure.
- Provider capability unknown.
- Notification permission denied.
- Health permission denied.

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M3-T01 | Build onboarding step models and validators | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T02 | Create profile Drift schema and repository | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T03 | Build onboarding UI flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T04 | Build profile/settings screens | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T05 | Create BYOK secure storage integration | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T06 | Create provider config metadata tables | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T07 | Implement provider key test flow | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T08 | Implement provider capability check and cache | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T09 | Implement profile-change impact warning | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T10 | Add permission status entry points | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M3-T11 | Add M3 QA fixtures and tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- User can complete onboarding and relaunch into main app.
- Profile edits persist and reload.
- BYOK key can be saved, tested, deleted, and never appears in logs.
- Provider capability checks block unsupported image/media flows.
- Profile changes that affect active plans show a warning.
- App remains usable without BYOK; AI-only features are disabled with clear messaging.

## 15. Manual QA Checklist

- Complete onboarding with minimal data.
- Complete onboarding with full data.
- Edit equipment and verify saved state.
- Enter invalid provider key and verify safe error.
- Delete provider key and verify AI flows disabled.
- Deny notification/health permission and verify graceful state.

## 16. Automated Test Coverage

- Profile validation unit tests.
- Secure-storage mock tests.
- Provider capability parser tests.
- Widget tests for onboarding step validation.
- Privacy tests for provider error redaction.

## 17. Handoff Notes

- M7 AI infrastructure must consume provider configs/capabilities through repositories.
- M8/M9 AI flows must not proceed without key and required capabilities.
- M6 reminders can use notification permission and profile settings.

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
