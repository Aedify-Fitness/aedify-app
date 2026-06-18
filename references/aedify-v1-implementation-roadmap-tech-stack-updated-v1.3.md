# Aedify — v1 Implementation Roadmap

| Field | Value |
|---|---|
| Product | Aedify |
| Roadmap Version | 1.3 — Tech Stack Updated, Milestones Renumbered After Progress Media Reorder |
| Source Baseline | PRD v1.10 / v1 Final — Re-locked after Package Validation |
| Status | Implementation Planning — Updated for Validated Stack, Progress Media Reorder, and Renumbered Milestones |
| Platforms | iOS and Android, Flutter single codebase |
| Architecture Constraint | Local-only, offline-first, BYOK AI |
| v1 Deployment Constraint | Private release, maximum 5 users, not public launch |
| Created | 2026-06-10 |

---

## 1. Purpose

This document converts the locked PRD v1.10 into an implementation roadmap.

It is not a PRD refinement document. It does not introduce new product scope. Any new product behavior discovered during implementation must be handled as a formal change request or PRD version bump, not silently merged into v1.

This rewrite updates sections affected by the validated implementation-stack correction: Riverpod remains selected, Hive is replaced by `shared_preferences`, `flutter_secure_storage` is restricted to secrets, and Dio + Retrofit remain the approved HTTP stack.

Roadmap v1.3 additionally renumbers the milestone sequence after moving Progress Media Tracking before AI Infrastructure.

Sequencing update: **M6 — Progress Media Tracking** now comes before **M7 — AI Infrastructure**. The milestones have been renumbered to match the new roadmap order. This is a build-order and roadmap-numbering change only; it does not change product scope or the functional acceptance criteria of Progress Media Tracking, AI Infrastructure, AI Physique Analysis, or any other milestone.

The roadmap answers:

- what should be built first;
- how the work should be phased;
- which milestones depend on earlier milestones;
- which acceptance gates must be met before moving forward;
- how later implementation plans should break down from this roadmap.

---

## 2. Source Inputs

Primary implementation sources:

1. `PRD-Aedify-v1-FINAL-relocked.md`
2. `aedify-package-validation-decision-log-v1.md`
3. `aedify-ai-companion-instruction-set-v1.10.md`
4. `aedify-musclewiki-exercises.firebase.json`
5. `aedify-transform-for-firebase.js`
6. Bundled AI reference files `00`–`09`

The roadmap assumes:

- PRD v1.10 is final for v1 and re-locked after package validation.
- The package-validation update changes implementation stack only; it does not change product scope.
- The app remains local-only and offline-first.
- Firebase Storage hosts the versioned exercise dataset.
- AI is BYOK only.
- Non-AI features must work offline after first exercise dataset sync.
- App-actionable AI responses must be structured JSON and locally validated.
- Imported external plans are drafts until reviewed and saved by the user.
- Progress media and physique analysis remain local by default.
- Crashlytics must be aggressively redacted.

---

## 3. Roadmap Principles

### 3.1 Build from local core outward

The app should be useful before AI exists. Manual creation, local storage, exercise browsing, and workout logging must be stable before AI generation is layered on top.

### 3.2 Validate before persistence

Anything imported, generated, repaired, or shared must be validated before database writes.

This applies to:

- Firebase exercise dataset imports;
- AI-generated workouts;
- AI-generated programmes;
- AI chat save flows;
- `.aedifyplan` imports;
- external file imports;
- image/screenshot imports;
- progress physique analysis snapshots.

### 3.3 Keep schema versions separate

The following version tracks must remain independent:

- Drift database schema version;
- Firebase exercise dataset schema version;
- `.aedifyplan` share schema version;
- AI structured-output schema versions;
- prompt/instruction-set version;
- app version.

Do not couple migrations across these layers unless explicitly required.

### 3.4 Prefer local deterministic logic before AI

AI should structure, suggest, or assist. The app should decide whether output is valid.

The app owns:

- schema validation;
- exercise ID validation;
- programme expansion;
- save confirmation;
- import review state;
- privacy filtering;
- Crashlytics redaction;
- unsupported provider/model blocking;
- temporary artifact cleanup.

### 3.5 Privacy is a build gate, not polish

Any milestone that can touch private data must include privacy acceptance checks before it is considered complete.

---

## 4. Critical Path Summary

The critical path for v1 is:

```text
Foundation
  -> Local data model
  -> Exercise dataset sync
  -> Exercise Library
  -> Onboarding/Profile/BYOK
  -> Manual Programs + Workout Logger
  -> Analytics/PR/Plateau base
  -> Progress media
  -> AI infrastructure
  -> AI workout/programme generation
  -> AI chat and update flows
  -> Sharing/export
  -> External import
  -> Image import
  -> AI physique analysis
  -> Privacy hardening
  -> Private release QA
```

The main dependency rule is simple: **do not build AI flows until the local app can validate and persist the same object manually.**

---

## 5. What Must Be Built First

### First implementation milestone

Build **Milestone 1: App Foundation + Local Data Spine** first.

This milestone must establish:

- Flutter project structure;
- app routing shell;
- local Drift database setup;
- migration scaffolding;
- local file storage paths;
- secure storage wrapper;
- environment/config management;
- redacted logging conventions;
- feature flags for AI, sharing, import, progress media, and Crashlytics;
- basic app settings surface.

Validated implementation stack for this milestone:

- Riverpod, latest validated stable version, for app-wide state management, dependency injection, async workflows, local DB streams, feature controllers, and testability.
- Drift / SQLite for durable relational data and migrations.
- `shared_preferences` only for simple non-critical local preferences.
- `flutter_secure_storage` only for BYOK API keys and other secrets.
- Dio as the base HTTP engine.
- Retrofit for stable typed REST clients where useful.

### Why this comes first

Almost every later feature depends on:

- local persistence;
- schema versioning;
- file paths;
- app settings;
- privacy-safe logging;
- dependency injection/service boundaries;
- a predictable navigation shell.

If these are unstable, every later milestone will require rework.

---

## 6. Milestone Overview

| Milestone | Name | Main Outcome | Depends On |
|---:|---|---|---|
| M0 | Implementation Lock & Backlog Setup | PRD converted into tracked implementation backlog | None |
| M1 | App Foundation + Local Data Spine | Local-first app shell and base persistence ready | M0 |
| M2 | Exercise Dataset Sync + Exercise Library | Firebase-hosted exercise data available offline | M1 |
| M3 | Onboarding, Profile, Settings, BYOK Setup | User profile and provider configuration ready | M1, M2 partial |
| M4 | Manual Programmes, Workouts, and Logging | App works as a non-AI training tracker | M1, M2, M3 |
| M5 | Analytics, PRs, and Plateau Base Logic | Logged training produces useful local insights | M4 |
| M6 | Progress Media Tracking | Local progress photos/videos, reminders, comparison | M1, M3 |
| M7 | AI Infrastructure | Provider abstraction, prompt builder, schemas, validation, repair | M3, M4, M5 partial |
| M8 | AI Workout + Programme Generation | Structured AI outputs generate saveable local plans | M7 |
| M9 | AI Trainer Chat + AI Update Flows | Chat, save intent, swaps, deloads, plateau suggestions | M7, M8 |
| M10 | Local Sharing + PDF Export | `.aedifyplan` and PDF sharing work with privacy filters | M4, M7 partial |
| M11 | External Text File Import | PDF/TXT/MD/XLSX/CSV import into reviewed drafts | M7, M10 partial |
| M12 | Image/Screenshot External Import | Image import with enhancement, model gating, draft review | M7, M11 |
| M13 | Optional AI Physique Analysis | Consent-based BYOK analysis snapshots | M7, M6 |
| M14 | Privacy, Resilience, and Release Hardening | v1 private release candidate | All previous |

---

## 7. Milestone Details

## M0 — Implementation Lock & Backlog Setup

### Goal

Prepare the project for implementation without changing the locked PRD.

### Build scope

- Create implementation backlog structure.
- Create milestone labels.
- Create source-of-truth document index.
- Create change-request policy.
- Create definition of done.
- Create privacy review checklist.
- Create AI validation checklist.
- Create import/export validation checklist.

### Deliverables

- `v1-implementation-roadmap.md`
- Implementation backlog board
- Milestone labels `M1`–`M14`
- Change request template
- Bug template
- Acceptance test template

### Acceptance gate

- Every PRD v1 feature maps to at least one roadmap milestone.
- No new product behavior is added.
- Implementation decisions are clearly separated from product decisions.

---

## M1 — App Foundation + Local Data Spine

### Goal

Build the app foundation that every later feature depends on.

### Build scope

#### App shell

- Flutter project structure.
- Routing/navigation shell.
- App theme and reusable UI primitives.
- Error, empty, loading, and permission states.
- Feature flag scaffolding.
- Riverpod provider scope and base dependency-injection graph.

#### Local persistence

- Drift setup.
- Database open/close lifecycle.
- Schema versioning.
- Migration scaffolding.
- Transaction helpers.
- Local ID generation strategy.
- JSON extension metadata strategy.
- `shared_preferences` wrapper for simple non-critical preferences only.
- Explicit guardrails preventing `shared_preferences` from storing secrets, logs, programmes, import drafts, AI outputs, progress media records, or other critical data.

#### Local files

- App document directory strategy.
- Temporary directory strategy.
- Media directory strategy.
- Export directory strategy.
- Cleanup service.

#### Security and privacy foundation

- `flutter_secure_storage` wrapper for BYOK API keys and secrets only.
- Secret-storage policy preventing API keys from being written to Drift, shared preferences, files, logs, Crashlytics, or exports.
- Redacted logging helper.
- Crashlytics wrapper with denylisted payload fields.
- Local-only sensitive data policy.

#### Settings foundation

- Units.
- Theme/app preferences.
- Feature toggles.
- Data/privacy info screen placeholder.
- Persist simple non-critical preferences through `shared_preferences`, not Hive.

### Dependencies

None after M0.

### Acceptance gate

- App launches on iOS and Android.
- Drift database opens successfully.
- Empty migrations can run.
- Local file paths are created and writable.
- `flutter_secure_storage` can save and retrieve test secret values.
- `shared_preferences` can save and retrieve simple non-critical preferences.
- Static/code review confirms Hive is not a required v1 dependency.
- Logs redact known sensitive field names.
- Crash/reporting wrapper exists even if Crashlytics is not fully wired yet.

---

## M2 — Exercise Dataset Sync + Exercise Library

### Goal

Make the full exercise library available locally and offline after first sync.

### Build scope

#### Dataset pipeline

- Confirm transformed Firebase-ready JSON shape.
- Create Firebase Storage manifest contract.
- Upload dataset and manifest.
- Implement manifest fetch.
- Implement dataset download.
- Implement schema compatibility checks.
- Implement atomic local import.
- Implement rollback on failed import.

#### Local exercise schema

- Exercise table.
- Exercise video table or embedded JSON strategy.
- Muscle group indexes.
- Equipment/category indexes.
- Modality indexes.
- Difficulty indexes.

#### Exercise Library UI

- Exercise list.
- Search.
- Filters.
- Exercise detail page.
- Steps/instructions.
- Video variants.
- Muscle group labels.
- Bodymap placeholder or first implementation depending on asset readiness.

#### Offline behavior

- First-launch sync required state.
- Offline after successful sync.
- Update-required state for unsupported dataset schema.
- Compatible migration path for supported schema changes.

### Dependencies

- M1 local persistence.
- Firebase project/storage setup.
- Final dataset artifact.

### Acceptance gate

- First sync downloads and imports the dataset.
- Exercise Library works offline after sync.
- Unchanged manifest check is fast and does not rewrite local data.
- Unsupported schema shows a clear update-required state.
- Exercise detail works for representative strength, cardio, flexibility, and recovery records.

---

## M3 — Onboarding, Profile, Settings, and BYOK Setup

### Goal

Capture the user profile and configure AI provider access without requiring an account.

### Build scope

#### Onboarding

- Welcome/privacy framing.
- Units.
- Name/nickname.
- Training experience.
- Goals.
- Training schedule.
- Session length.
- Equipment access.
- Injuries/limitations.
- Substitutions/avoid list.
- Optional bodyweight.
- Optional known 1RMs.

#### Profile settings

- Edit profile.
- Edit goals.
- Edit equipment.
- Edit injuries/limitations.
- Edit substitutions.
- Edit schedule/session length.

#### BYOK setup

- Provider selection.
- API key entry.
- `flutter_secure_storage` for API keys and secrets.
- Model selection.
- Test connection.
- Capability registry:
  - text support;
  - structured JSON/schema support;
  - image input support;
  - progress media analysis support.

#### Provider disabled states

- No key configured.
- Invalid key.
- Network unavailable.
- Provider/model unsupported for requested operation.
- Image input unavailable.

### Dependencies

- M1 app foundation.
- M2 partial exercise library for equipment/profile context.

### Acceptance gate

- User can complete onboarding without AI key.
- User can later add, update, or remove API key.
- API key is never stored in Drift.
- API key is never stored in `shared_preferences`, files, logs, Crashlytics, or exports.
- Provider capability checks are available to later AI flows.
- No AI feature is enabled without a configured provider/model that supports that operation.

---

## M4 — Manual Programmes, Workouts, and Logging

### Goal

Make the app fully useful without AI.

### Build scope

#### Programmes Library

- Saved workouts.
- Multi-week programmes.
- Active programme.
- Inactive programmes.
- Programme detail.
- Programme activation/deactivation.
- Duplicate/edit/delete.

#### Manual workout builder

- Create single workout.
- Add exercises.
- Add sets.
- Mark set type: `warmup` or `working`.
- Add reps, weight, duration, distance, RPE, RIR, notes where applicable.
- Superset support for manual workouts.
- Rest time support.
- Custom exercise creation.

#### Manual programme builder

- Create programme.
- Create weeks.
- Create sessions.
- Reuse workout templates.
- Schedule days.
- Edit programme before activation.

#### Workout logger

- Start workout from saved workout.
- Start workout from active programme session.
- Start empty workout.
- Log sets.
- Complete workout.
- Save workout history.
- Repeat previous workout.
- Exercise history view.

### Dependencies

- M1 local database.
- M2 exercise library.
- M3 profile/settings.

### Acceptance gate

- A user can create, run, and complete a workout with no AI.
- Warm-up and working sets are persisted distinctly.
- Manual supersets can be created and logged.
- Completed logs are immutable enough that later programme edits do not rewrite history.
- Custom exercises can be used in manual workouts.

---

## M5 — Analytics, PRs, and Plateau Base Logic

### Goal

Turn logged training into useful local insights and prepare for AI-assisted plateau suggestions later.

### Build scope

#### Analytics

- Workout history.
- Per-exercise history.
- Volume trends.
- Working-set-only analytics.
- Optional total-work view including warm-ups.
- Week-over-week comparisons.
- Bodyweight trend if logged.

#### PR detection

- Max weight PR.
- Rep PR.
- Estimated 1RM PR.
- Volume PR where useful.
- Exclude warm-up sets.

#### Plateau detection base

- Minimum history thresholds.
- Ignore warm-up sets.
- Ignore deload weeks.
- Detect repeated stalled e1RM or performance pattern.
- Allow dismissing/acknowledging plateau alerts.
- Create local plateau event state for later AI suggestion flow.

### Dependencies

- M4 workout logging.

### Acceptance gate

- Warm-ups are excluded from default analytics, PRs, e1RM, and plateau detection.
- Constructed plateau test cases produce expected local flags.
- Deload or intentionally light sessions do not create false positives.
- Analytics remain available offline.

---

## M6 — Progress Media Tracking

### Goal

Enable local progress photo/video tracking and comparison.

### Build scope

#### Progress media sessions

- Create progress media session.
- Capture/import front photo.
- Capture/import back photo.
- Capture/import left-side photo.
- Capture/import right-side photo.
- Capture/import short all-sides video.
- Generate thumbnails.
- Add session notes.
- Optional bodyweight/measurement snapshot.
- Delete media/session.

#### Local storage

- Store raw media in app-local storage.
- Store metadata in Drift.
- Store thumbnails locally.
- Avoid database blobs for raw media.
- Storage usage visibility.

#### Comparison

- Baseline vs latest.
- Previous vs latest.
- Side-by-side view.
- Date/bodyweight labels where available.

#### Reminders

- Ask for reminder cadence only after first saved progress media session.
- Supported cadence:
  - every 2 weeks;
  - monthly;
  - every 3 months;
  - off.
- Local notifications only.

### Dependencies

- M1 local files/database.
- M3 profile/settings.

### Acceptance gate

- Progress media works without AI.
- Media remains local by default.
- Reminder prompt appears only after first saved progress media session.
- User can delete media.
- Progress media is excluded from sharing/export flows.

---

## M7 — AI Infrastructure

### Goal

Build the shared AI foundation once, then reuse it across generation, chat, import, repair, and analysis flows.

### Build scope

#### Provider abstraction

- Common provider interface.
- Dio-based HTTP client foundation with redacting interceptors, timeout handling, cancellation, and normalized provider errors.
- Retrofit clients for stable typed REST-style endpoints where useful.
- Hand-written Dio adapters for complex AI provider payloads, streaming, multipart, image import, and progress media analysis calls where Retrofit is awkward.
- OpenAI adapter.
- Anthropic adapter.
- Google/Gemini adapter.
- Capability detection/registry.
- Model metadata.
- Error normalization.
- Request cancellation.
- Timeout handling.

#### Prompt builder

- Instruction-set section registry.
- Per-operation prompt routing.
- Template variable substitution.
- Empty values render as `(not provided)`.
- Candidate exercise injection.
- Reference file injection.
- Schema injection.
- Chat history injection where allowed.

#### Structured output

- Shared envelope validator.
- Schema registry.
- Response type validation.
- JSON parsing.
- Provider-native JSON/schema mode when available.
- Fallback prompt-constrained JSON mode.
- One automatic repair attempt.
- User-triggered retry path.

#### Candidate exercise engine

- Hard filter by equipment and experience.
- Soft rank by goals, focus, and adjacent movement compatibility.
- Candidate caps per operation.
- Custom exercise inclusion only when app-provided.
- No AI-generated local database IDs.

#### AI privacy controls

- Consent state where required.
- Prompt/response exclusion from Crashlytics.
- Candidate list exclusion from Crashlytics.
- No API keys in logs.
- No API keys or secrets in Drift, `shared_preferences`, files, Crashlytics, exports, or generated artifacts.
- No raw AI response persistence unless explicitly allowed as safe local metadata.

### Dependencies

- M3 BYOK setup.
- M4 local programme/workout models.
- M5 analytics partial for plateau context.

### Acceptance gate

- App-actionable AI request can be sent and validated with a test schema.
- Invalid JSON triggers one repair attempt.
- Invalid exercise IDs are rejected.
- Provider/model unsupported states block before prompt assembly.
- Prompt builder leaves no unresolved template variables.
- Crash/error payload inspection confirms AI internals are redacted.
- Dio/Retrofit request logging redacts authorization headers, API keys, prompts, raw responses, and file/media payload references.

---

## M8 — AI Workout and Programme Generation

### Goal

Generate app-actionable workouts and programmes that can be reviewed, validated, expanded, and saved locally.

### Build scope

#### Daily workout generation

- Request form.
- Candidate list generation.
- Prompt assembly.
- Structured response validation.
- Review screen.
- Save as workout.
- Start immediately.

#### Multi-week programme generation

- General programme flow.
- Beginner Path A flow.
- Beginner Path B/custom flow.
- Non-beginner flow.
- Strength-focused warm-up rules.
- Superset validation.
- Template-based programme output.
- App-side expansion at save time.
- Atomic save transaction.

#### Powerbuilding routing

- Include supplemental powerbuilding reference only for eligible non-beginner strength + hypertrophy requests.
- Exclude it completely for beginners.
- Preserve source-integrity guardrails.

#### Review and validation UX

- Validation warnings.
- Blocking errors.
- Needs-input state.
- Partial-success state where allowed.
- User confirmation before save.

### Dependencies

- M7 AI infrastructure.
- M4 local programme/workout persistence.
- M5 analytics for working weights where available.

### Acceptance gate

- AI-generated workout saves and can be logged.
- AI-generated programme expands into concrete weeks/workouts/sets.
- Beginner outputs do not include AI-generated supersets.
- Persisted sets are set-level and marked warm-up/working.
- Non-beginner strength warm-ups obey percentage bands and do not exceed 80% of associated working set.
- Generated content never contains exercise IDs outside the candidate list.

---

## M9 — AI Trainer Chat and AI Update Flows

### Goal

Add conversational trainer support and controlled AI-driven modifications.

### Build scope

#### AI Trainer Chat

- Local chat threads.
- Chat message persistence.
- Reference-aware Q&A.
- Profile-aware responses where allowed.
- Medical/injury/eating-disorder safety handling.
- Save-intent detection.

#### Chat save flows

- Chat-generated single workout save.
- Chat-generated multi-week programme save.
- Explicit user save intent required.
- Structured save conversion.
- Validation and review before persistence.

#### Exercise swap

- Single occurrence.
- Future occurrences.
- Entire programme.
- Completed logs never edited.
- Candidate-limited replacement suggestions.

#### Deload flow

- Deload generation from current programme/week.
- Keep movement patterns where possible.
- Reduce volume/load according to rules.
- User review before apply.

#### Plateau suggestion flow

- Trigger from local plateau event.
- Provide relevant lift log slice and candidates.
- Suggest actionable changes.
- User review before apply.

### Dependencies

- M7 AI infrastructure.
- M8 generation validation patterns.
- M5 plateau base logic.

### Acceptance gate

- Normal trainer chat remains conversational.
- App-actionable chat save returns structured JSON only.
- Saved chat workouts/programmes require explicit user action.
- Exercise swaps do not alter completed logs.
- Deload and plateau suggestions are previewed before applying.

---

## M10 — Local Sharing and PDF Export

### Goal

Allow local sharing without violating the local-only/no-account privacy model.

### Build scope

#### `.aedifyplan` export

- Export saved workout.
- Export multi-week programme.
- Privacy mode: template by default.
- Optional exact prescription mode with warning.
- Sanitized DTO generation.
- Share schema validation.
- Temporary file writing.
- Native OS share sheet.
- Temporary file cleanup.

#### `.aedifyplan` import

- Open file in app.
- Parse JSON.
- Validate share schema version.
- Validate content type and required fields.
- Resolve exercise references.
- Re-create custom exercises with new local IDs where needed.
- Preview imported content.
- Save inactive by default.

#### PDF export

- Human-readable programme/workout PDF.
- Prescription summaries.
- Printable/open logging tables.
- Optional exercise-instructions appendix off by default.
- Privacy filtering.

### Dependencies

- M4 programme/workout models.
- M7 schema validation patterns.

### Acceptance gate

- Export does not include profile, injuries, logs, PRs, body measurements, photos, API keys, chat history, prompts, raw AI responses, candidate lists, or AI generation snapshots.
- Imported plans are inactive by default.
- Unsupported share schema is rejected unless locally migratable.
- PDF is not importable in v1.

---

## M11 — External Text File Import

### Goal

Convert supported text-based external programme/workout files into reviewed local drafts.

### Build scope

#### Supported inputs

- Text-based PDF.
- TXT.
- MD.
- XLSX.
- CSV.

#### Extraction pipeline

- Local file picker.
- File type validation.
- Local text/table extraction.
- Extracted content preview or summary.
- AI-processing consent.
- Send only programme-relevant extracted content.
- Do not send private profile/log data during default import parse.

#### AI parse pipeline

- `EXTERNAL_PLAN_IMPORT/parse`.
- Structured draft response.
- Repair attempt on invalid output.
- External workout import schema.
- External programme import schema.

#### Exercise matching

- Exact/alias auto-match.
- Ambiguous match confirmation.
- Unmatched exercise resolution:
  - match to existing;
  - create custom;
  - remove.
- Optional `exercise_match_assist` AI flow.

#### Review and save

- Draft review screen.
- Warnings and blocking issues.
- Save inactive by default.
- No silent adaptation, personalization, expansion, or rewrite.

### Dependencies

- M7 AI infrastructure.
- M10 sanitized import/export validation patterns.
- M4 local programme/workout/custom exercise models.

### Acceptance gate

- Supported file types create import drafts.
- Unsupported/corrupted/encrypted/scanned PDF files fail clearly.
- Imported plan preserves source content where available.
- Missing/ambiguous content is flagged, not invented.
- User must resolve unmatched exercises before save.
- Saved imported plans are inactive by default.

---

## M12 — Image/Screenshot External Import

### Goal

Support screenshot/image-based programme import with local readability enhancement and multimodal BYOK gating.

### Build scope

#### Supported images

- PNG.
- JPG/JPEG.
- WEBP.
- HEIC/HEIF where platform-supported.

#### Image selection and ordering

- Multi-image picker.
- Preview selected images.
- User-defined ordering.
- Order becomes source order for AI extraction.

#### Local readability enhancement

- Orientation correction.
- Crop tools where practical.
- De-skew where practical.
- Brightness/contrast adjustment.
- Sharpening.
- Noise reduction.
- Upscaling where practical.
- Track enhancement methods in metadata.

#### Provider/model gating

- Require image-capable BYOK provider/model.
- Block unsupported provider/model before prompt assembly.
- Display fallback guidance: use text-based file or compatible model.

#### AI image parse pipeline

- `EXTERNAL_PLAN_IMPORT/image_parse`.
- `EXTERNAL_PLAN_IMPORT/image_repair`.
- Reuse external programme/workout schemas.
- Capture image metadata:
  - source input type;
  - source file types;
  - image count;
  - order source;
  - enhancement methods;
  - image quality;
  - unreadable regions;
  - missing/unclear content.

#### Temporary artifacts

- Original screenshots not stored by default.
- Enhanced images temporary only.
- Image-processing artifacts temporary only.
- Expiry/cleanup rules.

### Dependencies

- M7 AI infrastructure.
- M11 import review/matching pipeline.
- M3 provider capability registry.

### Acceptance gate

- Image import is blocked without image-capable provider/model.
- Multi-image order is explicit before AI processing.
- Enhancement does not alter programme content.
- AI is instructed not to invent missing text, cropped tables, numbers, or programme content.
- Unreadable/cropped regions are flagged.
- Original/enhanced images and processing artifacts are not exported, shared, or sent to Crashlytics.

---

## M13 — Optional AI Physique Analysis

### Goal

Add explicit-consent AI physique analysis on selected local progress media.

### Build scope

#### Consent flow

- Select specific media or extracted frames.
- Show clear AI-processing consent.
- Explain rough visual estimate limitations.
- Confirm provider/model capability.

#### Frame selection

- Photo selection.
- Video frame extraction.
- Prefer canonical front/back/left/right frames.
- Send selected frames only.

#### AI analysis pipeline

- `PROGRESS_MEDIA_ANALYSIS/analyze`.
- `PROGRESS_MEDIA_ANALYSIS/compare`.
- `PROGRESS_MEDIA_ANALYSIS/repair`.
- Structured `progress_physique_analysis` response.
- Validation and repair.

#### Output rules

- Rough body-fat range only.
- Confidence level required.
- Limitations required.
- Training-oriented physique feedback.
- No medical diagnosis.
- No precise body-composition claims.
- No attractiveness scoring.
- No body shaming.
- No extreme dieting advice.

#### Local analysis snapshots

- Store structured result locally.
- Link to session/comparison context.
- Delete with session or independently where applicable.

### Dependencies

- M7 AI infrastructure.
- M6 progress media.
- M3 provider capability registry.

### Acceptance gate

- Analysis cannot run without explicit consent.
- Analysis cannot run without supported provider/model.
- Output body-fat estimate is a range, not a precise number.
- Results are not exported, shared, or sent to Crashlytics.
- Unsafe outputs are blocked or repaired.

---

## M14 — Privacy, Resilience, and Private Release Hardening

### Goal

Prepare a private v1 release candidate.

### Build scope

#### Privacy audit

- Crashlytics payload inspection.
- Export payload inspection.
- `.aedifyplan` inspection.
- PDF inspection.
- Import artifact cleanup validation.
- Progress media exclusion validation.
- AI prompt/response exclusion validation.

#### Resilience

- Offline cold launch after first sync.
- No-key AI disabled states.
- Bad-key provider states.
- Network failure states.
- Dataset download failure states.
- Dataset migration failure states.
- Import parse failure states.
- AI invalid JSON states.
- Repair failure states.

#### Performance

- First dataset sync target validation.
- Subsequent launch manifest check validation.
- Exercise search/filter responsiveness.
- Workout logger responsiveness.
- Large programme expansion behavior.
- Image preprocessing memory behavior.
- Progress video storage limits.

#### Release readiness

- Private build configuration.
- Firebase Storage rules/config.
- Crashlytics redaction confirmed.
- App privacy copy.
- Manual QA script.
- Known limitations document.
- Tester onboarding instructions.

### Dependencies

All previous milestones.

### Acceptance gate

- All core user journeys pass manually.
- All privacy-sensitive exports are inspected and clean.
- Offline mode works for non-AI features.
- AI flows fail safely when provider, model, key, network, or schema validation fails.
- Private release build is ready for limited distribution.

---

## 8. Dependency Map

```text
M0 Implementation Lock
  -> M1 Foundation
      -> M2 Exercise Dataset + Library
      -> M3 Onboarding/Profile/BYOK
          -> M6 Progress Media
          -> M7 AI Infrastructure
      -> M4 Manual Workouts/Programmes
          -> M5 Analytics/Plateau Base
              -> M7 AI Infrastructure
              -> M9 Plateau AI Suggestions
          -> M8 AI Workout/Programme Generation
              -> M9 AI Chat/Update Flows
          -> M10 Sharing/PDF Export
              -> M11 External Text Import
                  -> M12 Image Import
M7 + M6 -> M13 AI Physique Analysis
M14 depends on M1-M13
```

---

## 9. Cross-Cutting Workstreams

These workstreams run across multiple milestones and should not be treated as one-off tasks.

### 9.1 Privacy and redaction

Applies to: all milestones.

Validated storage boundaries:

- Drift owns durable structured relational app data and migrations.
- `shared_preferences` is limited to simple non-critical preferences only.
- `flutter_secure_storage` is the only approved layer for BYOK API keys and secrets.
- API keys must never be written to Drift, `shared_preferences`, files, logs, Crashlytics, exports, or generated artifacts.

Must protect:

- API keys;
- prompts;
- raw AI responses;
- structured output JSON;
- candidate exercise lists;
- injuries;
- substitutions;
- lift logs;
- PR history;
- bodyweight history;
- body measurements;
- progress media;
- physique analysis results;
- original source files;
- screenshots;
- enhanced images;
- import artifacts.

### 9.2 Schema validation

Applies to: M2, M4, M7, M8, M9, M10, M11, M12, M13.

Schemas must fail closed when unsafe, unsupported, or ambiguous.

### 9.3 Local file lifecycle

Applies to: M1, M6, M10, M11, M12, M13.

Required states:

- permanent local app data;
- temporary import artifacts;
- temporary export artifacts;
- temporary enhanced images;
- thumbnails;
- delete/cleanup flows;
- expiry rules.

### 9.4 AI capability handling

Applies to: M3, M7, M8, M9, M11, M12, M13.

Capabilities should be checked before prompt assembly, not after an API failure where possible.

### 9.5 Review before save

Applies to: M8, M9, M10, M11, M12, M13.

User review is required for:

- AI-generated workouts/programmes;
- chat-save promotions;
- AI swaps/deloads/plateau actions;
- `.aedifyplan` imports;
- external text imports;
- image imports;
- custom exercise creation from imports;
- physique analysis storage where applicable.

---

## 10. Build Order Recommendation

Recommended implementation order:

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

Rationale:

- M1–M5 create the core non-AI training app.
- M6 is moved before M7 because progress media is local-first, non-AI functionality and should be stable before AI physique analysis is layered on top.
- M7 centralizes AI complexity after the local training core and local progress media base are in place.
- M8–M9 build AI on top of existing local validation and persistence.
- M10–M12 reuse local model validation, AI infrastructure, import review, and privacy filtering.
- M13 should come after both AI infrastructure and progress media are stable.
- M14 validates the entire product as an integrated private release candidate.

---

## 11. Milestone Exit Checklist Template

Each milestone should close only when the following are true:

```text
[ ] Feature works on iOS.
[ ] Feature works on Android.
[ ] Riverpod state/providers are testable without `BuildContext`-bound business logic.
[ ] Local database writes are transactional where needed.
[ ] Offline behavior is defined and tested.
[ ] Error states are user-readable.
[ ] Privacy-sensitive fields are redacted from logs/crash reports.
[ ] Secrets are stored only in `flutter_secure_storage`.
[ ] `shared_preferences` stores only simple non-critical preferences.
[ ] Data is not exported unless explicitly allowed.
[ ] Relevant schema validation exists.
[ ] Relevant migration behavior is defined.
[ ] Manual QA path is documented.
[ ] No new product behavior was introduced outside PRD v1.10.
```

---

## 12. Roadmap-to-Tickets Breakdown Strategy

After this roadmap is accepted, break each milestone into tickets using this shape:

```text
Ticket ID:
Title:
Milestone:
Feature Area:
User Story:
Implementation Notes:
Data Model Impact:
AI/Prompt Impact:
Privacy Impact:
Dependencies:
Acceptance Criteria:
Manual QA Steps:
Out of Scope:
```

Recommended ticket sizing:

- Keep each ticket independently reviewable.
- Separate data model changes from UI implementation when the schema is large.
- Separate provider adapters from AI feature flows.
- Separate validators from screens that consume them.
- Separate privacy filters from export UI.
- Separate image preprocessing from image import AI parsing.

---

## 13. Immediate Next Deliverables

After this roadmap, generate these implementation planning documents in order:

1. `v1-architecture-implementation-plan.md`
2. `v1-feature-by-feature-build-plan.md`
3. `v1-data-model-implementation-plan.md`
4. `v1-ai-implementation-plan.md`
5. `v1-testing-acceptance-plan.md`
6. `v1-build-ticket-backlog.md`

The next document should be:

```text
v1-architecture-implementation-plan.md
```

It should define:

- module boundaries;
- folder structure;
- Riverpod provider/dependency-injection boundaries;
- service boundaries;
- Drift database structure at a high level;
- `shared_preferences` preference boundaries;
- `flutter_secure_storage` secret boundaries;
- Firebase Storage sync implementation;
- Dio/Retrofit HTTP architecture;
- AI provider abstraction;
- file/media handling;
- import/export handling;
- privacy/redaction architecture.

---

## 14. Explicit Non-Goals for This Roadmap

This roadmap does not add:

- cloud sync;
- user accounts;
- public launch scope;
- social features;
- paid subscription or ads;
- scanned/image-only PDF OCR;
- computer-vision form checking;
- nutrition/meal logging beyond PRD scope;
- custom user-authored prompt system;
- exact reproduction of paid/source programme tables;
- background cloud processing.

---

## 15. Roadmap Completion Definition

The roadmap is complete when:

- each milestone is implemented;
- each milestone passes its acceptance gate;
- all PRD v1.10 functional requirements are covered;
- all privacy and Crashlytics redaction requirements are verified;
- all AI flows validate structured outputs locally;
- all import/export flows validate before persistence;
- all non-AI features work offline after first exercise dataset sync;
- the private release build is ready for up to 5 users.

