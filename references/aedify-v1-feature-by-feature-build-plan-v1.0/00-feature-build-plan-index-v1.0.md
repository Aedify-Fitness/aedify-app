# Feature-by-Feature Build Plan — Index

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-00 |
| Milestone Coverage | M0–M14 overview |
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


## 2. Purpose

This index coordinates the split Feature-by-Feature Build Plan package. The earlier roadmap establishes the order of major milestones; this package turns those milestones into detailed implementation files that can be converted into tickets, sprint plans, acceptance criteria, and QA scripts.

The package is intentionally split to avoid one bloated document. Each file owns one feature area or tightly related group of feature areas and follows the same implementation pattern: scope, dependencies, data ownership, state management, service boundaries, UX states, validation, privacy, ticket breakdown, acceptance criteria, and QA.

## 3. Source Inputs

Primary sources:

1. `PRD-Aedify-v1-FINAL-relocked.md`
2. `aedify-package-validation-decision-log-v1.md`
3. `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md`
4. `aedify-v1-architecture-implementation-plan-v1.0.md`
5. `aedify-ai-companion-instruction-set-v1.10.md`
6. `aedify-musclewiki-exercises.firebase.json`
7. `aedify-transform-for-firebase.js`
8. Bundled reference files `00`–`09`

## 4. Package Files

| Order | File | Milestone / Area | Purpose |
|---:|---|---|---|
| 00 | `00-feature-build-plan-index-v1.0.md` | M0–M14 | Package guide and cross-file rules. |
| 01 | `01-foundation-local-data-spine-v1.0.md` | M0–M1 | App shell, project structure, Riverpod foundation, Drift, local file store, preferences, secure storage, logging, redaction. |
| 02 | `02-exercise-dataset-library-bodymap-v1.0.md` | M2 | Firebase dataset sync, exercise library, local exercise storage, search/filtering, bodymap, exercise details, video/TTS support. |
| 03 | `03-onboarding-profile-settings-byok-v1.0.md` | M3 | Onboarding, profile, equipment/goals, settings, BYOK configuration, provider capability checks, Health/notification permissions. |
| 04 | `04-manual-programmes-workouts-logging-v1.0.md` | M4 | Manual programme/workout creation, workout execution, set logging, templates, supersets, warm-up/working set handling. |
| 05 | `05-analytics-prs-plateau-base-v1.0.md` | M5 | Local analytics, PRs, e1RM, charts, plateau detection base events, warm-up exclusions. |
| 06 | `06-progress-media-tracking-v1.0.md` | M6 | Progress photos/videos, local media sessions, reminders, thumbnails, storage controls. |
| 07 | `07-ai-infrastructure-v1.0.md` | M7 | Provider abstraction, prompt builder, structured-output validation lifecycle, repair orchestration, provider capability routing. |
| 08 | `08-ai-workout-programme-generation-v1.0.md` | M8 | Daily workout generation, multi-week programme generation, beginner paths, powerbuilding eligibility, save review. |
| 09 | `09-ai-trainer-chat-update-flows-v1.0.md` | M9 | AI trainer chat, conversational vs app-actionable routing, programme/workout updates, deloads, swaps, plateau suggestions. |
| 10 | `10-sharing-pdf-export-aedifyplan-v1.0.md` | M10 | `.aedifyplan` export/import, PDF export, share privacy modes, custom exercise import/export. |
| 11 | `11-external-text-file-import-v1.0.md` | M11 | Text-based PDF/TXT/MD/XLSX/CSV import, local extraction, AI parse draft, exercise resolution, import review. |
| 12 | `12-image-screenshot-import-v1.0.md` | M12 | Screenshot/image import, image ordering, local readability enhancement, multimodal AI gating, temporary artifact cleanup. |
| 13 | `13-ai-physique-analysis-v1.0.md` | M13 | Optional AI physique analysis from selected progress media, consent gate, frame packaging, rough range output, analysis snapshots. |
| 14 | `14-privacy-resilience-release-hardening-v1.0.md` | M14 | Privacy audit, Crashlytics allowlist, resilience, backups/exports boundaries, final private-release QA. |

## 5. Current Milestone Order

1. M0 — Implementation Lock & Backlog Setup
2. M1 — App Foundation + Local Data Spine
3. M2 — Exercise Dataset Sync + Exercise Library
4. M3 — Onboarding, Profile, Settings, and BYOK Setup
5. M4 — Manual Programmes, Workouts, and Logging
6. M5 — Analytics, PRs, and Plateau Base Logic
7. M6 — Progress Media Tracking
8. M7 — AI Infrastructure
9. M8 — AI Workout and Programme Generation
10. M9 — AI Trainer Chat and AI Update Flows
11. M10 — Local Sharing and PDF Export
12. M11 — External Text File Import
13. M12 — Image/Screenshot External Import
14. M13 — Optional AI Physique Analysis
15. M14 — Privacy, Resilience, and Private Release Hardening

## 6. Cross-File Implementation Rules

### 6.1 Storage ownership

- Drift owns durable structured app data, relationships, indexes, and migrations.
- Local app files own binary media, temporary imported files, thumbnails, exports, and generated PDFs.
- `shared_preferences` owns only small non-critical toggles and display preferences.
- `flutter_secure_storage` owns only secrets.
- Firebase Storage owns only the shared exercise dataset and manifest.
- Crashlytics receives only redacted crash diagnostics.

### 6.2 AI ownership

AI never owns persistence. AI can generate, parse, repair, classify, or suggest. The app validates, reviews, confirms, and saves.

### 6.3 Review-before-save rule

Any content created from AI, import, image import, chat save flow, or shared file import must pass a review gate before it becomes an active saved programme or workout.

### 6.4 Schema independence

Keep these versions independent:

- Drift schema version.
- Firebase dataset schema version.
- `.aedifyplan` share schema version.
- AI structured-output schema version.
- Prompt/instruction-set version.
- App version.

### 6.5 Ticket readiness

Every feature file includes ticket candidates. A ticket can enter implementation when it has a clear user story, required data model changes, state/controller ownership, acceptance criteria, privacy impact, test plan, and manual QA path.

## 7. Recommended Usage

Use the files in order. Do not start M8 AI generation before M7 AI infrastructure is accepted. Do not start M13 AI physique analysis before M6 progress media and M7 AI infrastructure are accepted. Do not start import features before the core exercise library and workout/programme persistence model are stable.

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
