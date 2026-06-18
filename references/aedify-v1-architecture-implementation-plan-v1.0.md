# Aedify — v1 Architecture Implementation Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document | Architecture Implementation Plan |
| Document Version | 1.0 |
| Source Roadmap | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Source Baseline | PRD v1.10 / v1 Final — Re-locked after Package Validation |
| Status | Implementation Planning |
| Platforms | iOS and Android, Flutter single codebase |
| Architecture Constraint | Local-only, offline-first, BYOK AI |
| v1 Deployment Constraint | Private release, maximum 5 users, not public launch |
| Created | 2026-06-10 |

---

## 1. Purpose

This document defines the implementation architecture for v1 of the Aedify app.

It translates the locked PRD and the updated implementation roadmap into concrete architectural boundaries, module responsibilities, package usage, data-flow rules, storage ownership, AI integration boundaries, privacy constraints, and milestone-facing build decisions.

This is not a PRD refinement document and does not introduce new product scope. If implementation uncovers a product behavior change, it must be handled as a formal change request or future PRD version bump.

---

## 2. Source Inputs

This architecture plan is based on:

1. `PRD-Aedify-v1-FINAL-relocked.md`
2. `aedify-package-validation-decision-log-v1.md`
3. `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md`
4. `aedify-ai-companion-instruction-set-v1.10.md`
5. `aedify-musclewiki-exercises.firebase.json`
6. `aedify-transform-for-firebase.js`
7. Bundled AI reference files `00`–`09`

The current implementation stack is:

| Area | Final v1 Decision | Boundary |
|---|---|---|
| Framework | Flutter, latest stable | Single iOS/Android codebase. |
| Language | Dart | App implementation language. |
| State management | Riverpod, latest validated stable version | App-wide async workflows, feature controllers, dependency injection, and testability. |
| Durable relational data | Drift / SQLite | Owns structured app data and migrations. |
| Simple preferences | `shared_preferences` | Non-critical preferences only. No secrets, logs, programmes, import drafts, AI outputs, or progress media records. |
| Secrets | `flutter_secure_storage` | BYOK API keys and other secrets only. |
| HTTP | Dio + Retrofit | Dio as base engine; Retrofit for stable REST-style clients where useful. |
| Complex AI/multipart/streaming HTTP | Hand-written Dio adapters | Used when Retrofit becomes awkward or too rigid. |
| Firebase | Core, Storage, Auth, Crashlytics | Exercise dataset hosting, anonymous auth, crash diagnostics only. |
| Charts | `fl_chart` | Analytics visualisation. |
| TTS | `flutter_tts` | On-device exercise step audio. |
| Notifications | `flutter_local_notifications` | Local reminders and local plateau/progress prompts. |
| Health integration | `health` | HealthKit + Health Connect. |
| Video playback | `video_player` + `chewie` | Exercise video streaming and local progress media preview where appropriate. |
| DB encryption support | `sqlcipher_flutter_libs` | Local database encryption support where implemented. |
| SVG rendering | `flutter_svg` | Bodymap rendering. |

---

## 3. Architectural Goals

The architecture must satisfy these goals:

1. Keep the app useful without AI.
2. Keep all durable user data local.
3. Keep AI provider keys under user control and stored only in secure storage.
4. Keep non-AI features available offline after exercise dataset sync.
5. Keep AI outputs app-actionable only after local validation.
6. Keep generated/imported/shared content reviewable before persistence or export.
7. Keep privacy filtering and Crashlytics redaction as first-class infrastructure.
8. Keep feature modules independently testable.
9. Keep schema version tracks independent.
10. Keep implementation simple enough for v1 private release scale.

---

## 4. Architectural Non-Goals

The architecture must not add:

- custom backend service;
- cloud sync;
- user accounts;
- hosted plan-sharing links;
- remote storage of user progress media;
- behavioral analytics;
- ad tracking;
- app-managed AI billing;
- public marketplace/community features;
- custom user-authored prompt system;
- scanned/image-only PDF OCR pipeline;
- computer-vision form checking.

---

## 5. Architecture Style

Use a modular, local-first, feature-oriented architecture.

Recommended shape:

```text
Presentation layer
  Flutter screens, widgets, routing, user interaction

Application layer
  Riverpod controllers, feature coordinators, use cases, validation orchestration

Domain layer
  Plain Dart models, enums, policies, validators, business rules

Data layer
  Drift DAOs, repositories, file-store services, secure storage, preferences, network clients

Platform/infrastructure layer
  Firebase, health, notifications, media/camera/gallery, TTS, share sheet, PDF/file tooling
```

Feature modules should not directly own unrelated infrastructure. They should depend on abstractions exposed through Riverpod providers.

---

## 6. Recommended Project Structure

```text
lib/
  main.dart

  app/
    app.dart
    router/
    theme/
    localization/
    bootstrap/
    feature_flags/

  core/
    db/
      app_database.dart
      migrations/
      tables/
      daos/
      converters/
    storage/
      app_file_paths.dart
      secure_storage_service.dart
      preferences_service.dart
      local_file_store.dart
      temporary_artifact_store.dart
    network/
      dio_client.dart
      network_status.dart
      interceptors/
      retry_policy.dart
      error_mapper.dart
    firebase/
      firebase_bootstrap.dart
      firebase_auth_service.dart
      firebase_storage_client.dart
      crashlytics_service.dart
      crash_redaction.dart
    validation/
      validation_result.dart
      schema_version_policy.dart
      json_schema_validator.dart
      exercise_reference_validator.dart
    privacy/
      privacy_classifier.dart
      export_privacy_filter.dart
      crashlytics_redaction_policy.dart
      ai_payload_privacy_policy.dart
    logging/
      app_logger.dart
      redacted_log_event.dart
    errors/
      app_error.dart
      user_error_message_mapper.dart
    utils/

  shared/
    widgets/
    components/
    models/
    formatters/
    units/

  features/
    onboarding/
    profile/
    settings/
    exercise_library/
    bodymap/
    workout_builder/
    workout_execution/
    programmes/
    lift_log/
    analytics/
    plateau_detection/
    progress_media/
    ai_infrastructure/
    ai_generation/
    ai_trainer_chat/
    sharing/
    external_import/
    image_import/
    physique_analysis/
    health_integration/
    notifications/

  ai/
    instruction_set/
    prompts/
    schemas/
    providers/
    prompt_builder/
    validation/
    repair/
    reference/
    candidate_selection/

assets/
  reference/
    aedify-00-index.md
    aedify-01-getting-started.md
    aedify-02-weight-loss.md
    aedify-03-muscle-building.md
    aedify-04-nutrition-and-diet.md
    aedify-05-exercise-programming.md
    aedify-06-faq.md
    aedify-07-supplements.md
    aedify-08-glossary.md
    aedify-09-powerbuilding-strength-hypertrophy.md
  bodymaps/
  schema/
```

### Structure rules

- `core/` contains reusable infrastructure with no feature-specific UI assumptions.
- `features/` contains product modules and user journeys.
- `ai/` contains AI-specific prompt, provider, schema, and validation infrastructure.
- Feature modules may depend on `core/`, `shared/`, and `ai/` where needed.
- `core/` must not depend on `features/`.
- `ai/` may depend on `core/validation`, `core/privacy`, `core/network`, and local data abstractions, but should not depend on presentation widgets.

---

## 7. Dependency Direction

Use one-way dependencies:

```text
UI widgets
  -> Riverpod controllers
    -> Use cases / coordinators
      -> Repositories / services
        -> Drift / files / secure storage / network / platform APIs
```

Do not allow:

- UI widgets to call Drift DAOs directly;
- UI widgets to read secure storage directly;
- AI provider adapters to write to Drift directly;
- import parsers to persist final programmes directly;
- Crashlytics logging to receive raw app objects;
- `shared_preferences` to become a general cache or data store.

---

## 8. Riverpod Architecture

### 8.1 Role of Riverpod

Riverpod is the dependency injection and state orchestration layer.

Use Riverpod for:

- app bootstrap state;
- repository injection;
- Drift DAO exposure;
- feature controllers;
- async workflows;
- provider capability checks;
- AI lifecycle state;
- import/review state;
- progress media capture state;
- settings and preferences state;
- test overrides.

### 8.2 Provider types

Recommended provider usage:

| Provider Type | Use |
|---|---|
| `Provider` | Pure services, repositories, validators, mappers. |
| `FutureProvider` | One-shot async reads, manifest checks, capability checks. |
| `StreamProvider` | Drift streams, active programme state, log history streams. |
| `NotifierProvider` / `AsyncNotifierProvider` | Feature controllers and multi-step flows. |
| `StateProvider` | Small local UI state only, not durable data. |

### 8.3 Controller boundaries

Each major user journey should have a feature controller:

- `onboardingControllerProvider`
- `exerciseSyncControllerProvider`
- `workoutBuilderControllerProvider`
- `workoutExecutionControllerProvider`
- `programmeBuilderControllerProvider`
- `aiGenerationControllerProvider`
- `aiChatControllerProvider`
- `sharingControllerProvider`
- `externalImportControllerProvider`
- `imageImportControllerProvider`
- `progressMediaControllerProvider`
- `physiqueAnalysisControllerProvider`

Controllers should coordinate workflow state, call use cases, and expose UI-friendly state.

They should not contain raw SQL, raw HTTP request construction, or privacy filtering rules inline.

---

## 9. Drift / SQLite Architecture

### 9.1 Drift ownership

Drift owns all durable structured data:

- exercise dataset records;
- exercise dataset metadata;
- user profile;
- equipment/favorites/substitutions;
- programmes;
- workout templates;
- scheduled workout occurrences;
- prescribed sets;
- logged workouts;
- logged sets;
- PR records or PR-derived cache where needed;
- plateau flags;
- import drafts if persistence across restarts is required;
- share/import metadata;
- progress media sessions;
- progress media item metadata;
- body measurements/bodyweight records;
- progress reminder state;
- AI analysis snapshots;
- schema/version metadata.

### 9.2 Drift must not store

Drift must not store:

- BYOK API keys;
- raw prompt bodies;
- raw AI responses unless explicitly required for a validated local snapshot;
- Crashlytics payloads;
- original source files by default;
- original screenshots by default;
- enhanced image artifacts by default;
- raw progress media blobs;
- secrets;
- exported file contents unless represented as local metadata.

Raw media and files should live in the app sandbox file system, with only paths and metadata in Drift where required.

### 9.3 Transaction policy

Use Drift transactions for any write that creates or modifies multiple related rows.

Transactional flows include:

- exercise dataset sync;
- programme save;
- workout template save;
- workout execution completion;
- AI-generated workout/programme save;
- chat-to-library save;
- `.aedifyplan` import save;
- external import final save;
- image import final save;
- progress media session save;
- physique analysis snapshot save.

### 9.4 Schema version policy

Keep separate version concepts:

| Version Track | Owner | Example |
|---|---|---|
| Drift schema version | App database | table/column migrations |
| Firebase exercise dataset schema version | Exercise sync module | dataset `schema_version` |
| `.aedifyplan` share schema version | Sharing/import module | `share_schema_version = 1` |
| AI structured-output schema version | AI validation module | workout/programme/import/analysis schemas |
| Instruction-set version | AI prompt system | `aedify-ai-companion-instruction-set-v1.10.md` |
| Reference corpus version | AI reference loader | files `00`–`09` |
| App version | Release build | semantic app version/build number |

Do not combine these into a single global version.

---

## 10. `shared_preferences` Architecture

### 10.1 Allowed usage

Use `shared_preferences` only for simple, non-critical local preferences:

- theme mode;
- accent/UI preference if added later;
- last opened tab;
- dismissed non-sensitive tips;
- non-sensitive display toggles;
- onboarding screen completion hints only if not security-sensitive;
- local UI defaults that can be safely reset.

### 10.2 Disallowed usage

Do not use `shared_preferences` for:

- API keys;
- provider secrets;
- user profile source of truth;
- workouts;
- programmes;
- logs;
- exercises;
- imports;
- AI outputs;
- progress media metadata;
- body measurements;
- health data;
- crash data;
- export/import payloads;
- structured-output validation results;
- anything that must survive corruption or requires migration.

### 10.3 Preference wrapper

Access preferences only through `PreferencesService`.

No feature module should call `SharedPreferences.getInstance()` directly.

---

## 11. Secure Storage Architecture

### 11.1 Allowed usage

Use `flutter_secure_storage` for:

- BYOK API keys;
- provider-specific secret tokens;
- any future secret value that should never be recoverable from plain app files.

### 11.2 Disallowed usage

Do not use secure storage for:

- full user profile;
- programme data;
- logs;
- large JSON payloads;
- raw AI outputs;
- progress media;
- general preferences;
- import drafts.

### 11.3 Secret access rules

- API keys must be read only at the moment they are needed for an AI call or provider validation.
- API keys must never be logged.
- API keys must never be written to Drift, `shared_preferences`, files, exports, Crashlytics, or debug dumps.
- UI may show provider configured/unconfigured state, not the raw key after save.
- Any in-memory key handling must be short-lived and hidden from generic logging.

---

## 12. Local File Storage Architecture

### 12.1 File store responsibilities

Use local app sandbox storage for:

- TTS audio cache;
- exported `.aedifyplan` files before share sheet handoff;
- exported PDFs before share sheet handoff;
- progress media photos;
- progress media videos;
- progress media thumbnails;
- locally extracted canonical video frames;
- temporary import files;
- temporary enhanced screenshot artifacts;
- temporary PDF/extraction artifacts.

### 12.2 File category separation

Recommended logical directories:

```text
app_sandbox/
  tts_cache/
  exports/
    aedifyplan/
    pdf/
  progress_media/
    sessions/
      {session_id}/
        photos/
        videos/
        thumbnails/
        extracted_frames/
  imports/
    temp/
      {import_session_id}/
        source_extracts/
        images_original/
        images_enhanced/
        tables/
  logs/
    local_redacted_only/
```

### 12.3 File lifecycle rules

| File Type | Persist? | Cleanup Rule |
|---|---:|---|
| Progress photos/videos | Yes, local only | User-controlled delete; remove on session delete. |
| Progress thumbnails | Yes, local only | Delete with owning media item. |
| Canonical extracted frames | Yes only if needed for saved analysis/session | Delete with owning session/analysis. |
| Exported `.aedifyplan` | Temporary | Delete after share or on cleanup sweep. |
| Exported PDF | Temporary | Delete after share or on cleanup sweep. |
| Original external import source file | No by default | Delete after import flow unless user explicitly keeps source outside app. |
| Original screenshot import files | No by default | Temporary; delete after reviewed import save/cancel. |
| Enhanced screenshots | No by default | Temporary; delete after reviewed import save/cancel. |
| AI prompt/response debug files | No | Not allowed in v1. |

### 12.4 File metadata

Only store paths/metadata in Drift when needed.

Never store large binary media directly in Drift.

---

## 13. Network Architecture

### 13.1 Dio base client

Dio is the base HTTP engine for:

- Firebase-adjacent manifest/dataset download where direct Firebase APIs do not abstract enough;
- AI provider calls;
- streaming or cancellable requests;
- multipart/image requests;
- provider capability checks;
- file download/upload-like provider payloads where allowed by BYOK provider APIs.

### 13.2 Retrofit usage

Use Retrofit for stable typed REST clients where request/response shapes are predictable:

- simple provider metadata endpoints;
- stable Firebase-hosted manifest-like HTTP fetches if exposed as direct download URLs;
- any deterministic REST service wrappers that do not require streaming/multipart complexity.

### 13.3 Hand-written Dio adapters

Use hand-written Dio adapters for:

- OpenAI/Anthropic/Gemini chat/completion calls where payloads differ significantly;
- streaming responses;
- image input requests;
- multipart payloads;
- provider-specific JSON/schema mode quirks;
- cancellation-heavy flows;
- custom retry/error mapping;
- cost/capability metadata handling.

### 13.4 Network error model

Map all network errors into app-level errors:

| Error Class | User-Facing Handling |
|---|---|
| Offline | Show clear offline message; preserve draft state. |
| Timeout | Retry option; no silent duplicate save. |
| Provider auth error | Prompt user to update/check BYOK key. |
| Provider capability unsupported | Disable unsupported operation and explain why. |
| Rate limit/quota | Explain provider limit and offer retry later. |
| Malformed provider response | Attempt structured repair where allowed. |
| Firebase dataset unavailable | Retry sync; keep existing local dataset if present. |

---

## 14. Firebase Architecture

### 14.1 Firebase responsibilities

Firebase is used only for:

- app initialization;
- anonymous auth for exercise dataset access;
- Firebase Storage-hosted exercise manifest and dataset;
- Firebase Crashlytics crash diagnostics.

### 14.2 Firebase must not be used for

- user accounts;
- user profile storage;
- cloud sync;
- progress media upload;
- programme sharing backend;
- behavioral analytics;
- product usage telemetry;
- AI request proxying;
- BYOK storage;
- remote user logs.

### 14.3 Exercise dataset sync

Flow:

```text
App startup or manual sync
  -> anonymous Firebase auth
  -> read manifest
  -> compare latest_version/schema_version with local metadata
  -> if unchanged, no bulk download
  -> if changed, download full dataset JSON
  -> validate top-level schema
  -> validate exercise records
  -> migrate compatible schema where supported
  -> write to Drift in one transaction
  -> update local dataset metadata
```

### 14.4 Crashlytics boundary

Crashlytics is allowed only for crash diagnostics.

All Crashlytics logging must go through `CrashlyticsService`, which must apply a redaction policy before any custom key/log/error is sent.

Never call Firebase Crashlytics directly from feature modules.

---

## 15. AI Architecture

### 15.1 AI responsibilities

AI may:

- generate single workouts;
- generate multi-week programmes;
- answer trainer chat questions;
- convert chat-shaped workouts/programmes into structured saveable outputs after explicit save intent;
- assist exercise swaps;
- assist deload decisions;
- provide plateau suggestions;
- parse external text-based files into import drafts;
- parse selected screenshots/images into import drafts where model supports image input;
- repair invalid structured outputs once automatically where allowed;
- analyze progress media only after explicit consent.

### 15.2 AI must not

AI must not:

- persist directly;
- create local database IDs;
- bypass local validation;
- silently adapt imported external programmes unless user requested adaptation in a later flow;
- invent missing screenshot text;
- diagnose medical conditions;
- provide precise body-composition claims;
- score attractiveness;
- body shame;
- produce beginner powerbuilding outputs;
- reproduce proprietary programme tables or paid source layouts;
- store API keys;
- receive more private context than the operation needs.

### 15.3 AI package structure

```text
ai/
  providers/
    ai_provider.dart
    ai_provider_capabilities.dart
    openai_provider.dart
    anthropic_provider.dart
    gemini_provider.dart
    provider_error_mapper.dart
  prompt_builder/
    prompt_builder.dart
    section_router.dart
    variable_resolver.dart
    context_pack_builder.dart
  instruction_set/
    instruction_set_repository.dart
    instruction_set_version.dart
  prompts/
    daily_workout_template.dart
    multi_week_program_template.dart
    chat_save_workout_template.dart
    external_import_template.dart
    image_import_template.dart
    physique_analysis_template.dart
  schemas/
    workout_generation_schema.json
    programme_generation_schema.json
    external_program_import_schema.json
    external_workout_import_schema.json
    physique_analysis_schema.json
  validation/
    ai_response_validator.dart
    exercise_id_validator.dart
    superset_validator.dart
    warmup_rule_validator.dart
    schema_version_validator.dart
  repair/
    structured_output_repair_service.dart
  reference/
    reference_file_loader.dart
    reference_selection_policy.dart
  candidate_selection/
    candidate_exercise_selector.dart
    candidate_ranking_policy.dart
```

### 15.4 Provider abstraction

Define a provider-agnostic interface:

```text
AiProvider
  - providerId
  - displayName
  - getCapabilities(modelId)
  - validateApiKey(apiKey)
  - sendTextRequest(request)
  - sendStructuredRequest(request)
  - sendImageRequest(request)
  - streamChat(request)
```

Provider capabilities should include:

- text input;
- image input;
- streaming;
- JSON mode;
- schema mode;
- maximum context size if available;
- image count/size constraints if known;
- cost metadata if available or configured.

### 15.5 Prompt builder

The prompt builder owns:

- instruction-set section selection;
- per-operation prompt template selection;
- variable substitution;
- candidate exercise list injection;
- reference-file selection;
- schema injection where needed;
- context minimization;
- privacy filtering before AI payload construction;
- provider capability check before payload construction.

Feature modules must request a prompt package from the prompt builder rather than assembling prompts ad hoc.

### 15.6 Structured output lifecycle

```text
User action
  -> collect local context
  -> build candidate list
  -> build prompt package
  -> call provider
  -> parse response
  -> validate JSON envelope
  -> validate schema version
  -> validate response_type/status
  -> validate exercise IDs and app rules
  -> if recoverable invalid response: one repair attempt
  -> if valid: show review screen
  -> user confirms save
  -> transactional Drift write
```

### 15.7 AI context minimization

Only send context needed for the current operation.

Examples:

| Operation | Context Allowed |
|---|---|
| Daily workout generation | Profile, goals, equipment, constraints, recent relevant logs, candidate exercises. |
| Multi-week programme generation | Profile, goals, schedule, constraints, anchors, candidate exercises, selected references. |
| Chat | Relevant profile/log slices and chat history as needed. |
| External text import parse | Extracted programme-relevant content only. No private profile/log data by default. |
| Image import parse | Selected/enhanced images, order metadata, quality metadata, import instruction. No unrelated profile/log data. |
| Physique analysis | Selected media/frames and minimal comparison metadata after explicit consent. |

---

## 16. Exercise Dataset Architecture

### 16.1 Runtime source

The runtime app does not call MuscleWiki.

The runtime app reads a Firebase Storage-hosted, versioned, transformed JSON dataset and persists it into Drift.

### 16.2 Local exercise model

Exercise records must support:

- source exercise ID;
- name;
- difficulty;
- primary muscles;
- 14-bucket muscle groups;
- category;
- modality;
- equipment;
- force;
- mechanic;
- grips;
- steps;
- videos;
- local favorite/substitution state;
- custom exercise distinction where user-created exercises are supported.

### 16.3 Dataset validation

Before writing to Drift:

- validate top-level schema version;
- validate exercise count where provided;
- validate required fields;
- validate enum values;
- validate unique exercise IDs;
- validate videos array shape;
- validate muscle groups against local app-supported buckets;
- reject or migrate unsupported future schema versions according to policy.

### 16.4 Candidate exercise lists

Candidate lists sent to AI must be locally built and hard-filtered before prompt construction.

The AI must only reference supplied exercise IDs.

---

## 17. Manual Workout and Programme Architecture

Manual building is foundational because AI-generated outputs must eventually become the same local objects.

### 17.1 Core local objects

Recommended durable concepts:

- `Programme`
- `ProgrammeWeek`
- `WorkoutTemplate`
- `WorkoutOccurrence`
- `WorkoutExercisePrescription`
- `SetPrescription`
- `WorkoutSession`
- `LoggedExercise`
- `LoggedSet`
- `ExerciseSubstitution`
- `SupersetGroup`

### 17.2 Save policy

All programme/workout saves should use the same persistence path regardless of source:

| Source | Save Path |
|---|---|
| Manual custom | Local validation -> transactional save |
| AI generated | AI validation -> review -> same transactional save |
| AI chat saved | AI validation -> review -> same transactional save |
| External import | Import validation -> exercise match -> review -> same transactional save |
| `.aedifyplan` import | Share schema validation -> review -> same transactional save |

This prevents separate persistence logic from drifting across feature sources.

---

## 18. Analytics and Plateau Architecture

### 18.1 Local computation

Analytics and plateau detection are local-only.

They read from logged workouts and logged sets, not from AI snapshots.

### 18.2 Warm-up exclusion

Warm-up sets must be visible in history but excluded from:

- PR detection;
- e1RM calculation;
- plateau detection;
- progression triggers;
- default analytics.

### 18.3 Derived data policy

Prefer computing analytics on read for v1 private scale unless performance requires local derived caches.

If derived caches are added:

- make them invalidatable;
- tie them to log mutation timestamps;
- never treat derived caches as source of truth.

### 18.4 Plateau event flow

```text
Workout session completed
  -> local analytics reads relevant logged working sets
  -> plateau rules evaluate minimum session count/trend
  -> plateau flag stored locally if triggered
  -> local notification or in-app prompt displayed
  -> user chooses AI suggestion
  -> AI receives relevant log slice only
  -> suggestion returned conversationally and/or structured as appropriate
```

---

## 19. Progress Media Architecture

Progress Media Tracking is now built before AI Infrastructure in the roadmap.

### 19.1 Scope

Progress media covers:

- front/back/left-side/right-side photos;
- short all-sides progress video;
- imported media;
- thumbnails;
- optional bodyweight/measurement snapshot;
- session notes;
- reminder cadence;
- local comparison views.

### 19.2 Storage

- Raw media files live in local app sandbox.
- Drift stores metadata and file paths.
- No media is sent off-device unless the user explicitly starts AI physique analysis later.
- Progress media is excluded from `.aedifyplan`, PDF exports, external imports, default sharing flows, and Crashlytics.

### 19.3 Reminder dependency

The app should ask for reminder cadence only after the first saved progress media session.

Reminder state can be modeled in Drift because it is user progress-data-adjacent and should not be a disposable preference.

### 19.4 Architecture reason for M6 before M7

Building progress media before AI Infrastructure ensures that:

- local media capture/import works without AI;
- file lifecycle rules are validated early;
- media privacy constraints are already implemented before any AI media payload is possible;
- physique analysis can later depend on stable local media session records.

---

## 20. Physique Analysis Architecture

Physique analysis is optional and depends on both:

- Progress Media Tracking;
- AI Infrastructure.

### 20.1 Consent gate

Every AI physique-analysis call requires explicit user consent for the selected media/frames.

Consent is operation-specific. Saving progress media locally does not imply consent to AI analysis.

### 20.2 Payload policy

Prefer selected photos or locally extracted canonical frames over full video upload.

The AI payload should include only:

- selected media/frames;
- session orientation metadata;
- baseline/latest comparison metadata where needed;
- minimal user context required to interpret progress.

### 20.3 Output policy

The output must be a validated local analysis snapshot and should include:

- rough body-fat range;
- confidence;
- limitations;
- physique observations;
- benchmark-style progress feedback;
- training-focused suggestions;
- non-medical framing.

It must not include:

- precise body-fat percentage;
- diagnosis;
- attractiveness scoring;
- body shaming;
- extreme diet advice.

---

## 21. Sharing Architecture

### 21.1 Export types

Support:

- `.aedifyplan` native app file;
- PDF;
- both.

### 21.2 Export privacy modes

Support:

- template mode by default;
- exact prescription mode only with explicit warning.

### 21.3 Export filtering

Export filters must exclude:

- profile;
- injuries;
- substitutions not needed by plan template;
- lift logs;
- completed workout logs;
- PR history;
- body measurements;
- progress media;
- API keys;
- chat history;
- prompts;
- raw AI responses;
- candidate lists;
- AI snapshots;
- source file excerpts;
- screenshot images;
- enhanced screenshot artifacts;
- physique analysis results.

### 21.4 Import validation

`.aedifyplan` import should be deterministic and local:

```text
File selected/opened
  -> parse JSON/package
  -> validate share_schema_version
  -> validate required fields
  -> map bundled custom exercises to new local IDs
  -> detect missing/invalid exercises
  -> show preview
  -> save inactive local copy after confirmation
```

---

## 22. External Text File Import Architecture

### 22.1 Supported sources

- text-based PDF;
- TXT;
- MD;
- XLSX;
- CSV.

### 22.2 Flow

```text
Select file
  -> validate file type
  -> extract text/tables locally
  -> show extraction confidence/preview where useful
  -> ask AI-processing consent
  -> send extracted programme-relevant content only
  -> receive structured draft
  -> validate draft
  -> run exercise matching
  -> user resolves ambiguous/unmatched exercises
  -> preview
  -> save inactive programme or saved workout
```

### 22.3 Import draft boundary

AI output is an import draft only.

No direct persistence until:

- schema validation passes;
- exercise matching issues are resolved;
- user reviews the draft;
- user confirms save.

### 22.4 Source-file policy

Original source files are not stored by default.

Persist only the normalized local programme/workout data and allowed metadata.

---

## 23. Image/Screenshot Import Architecture

### 23.1 Scope

Supported image inputs:

- PNG;
- JPG/JPEG;
- WEBP;
- HEIC/HEIF where platform-supported.

### 23.2 Flow

```text
Select images/screenshots
  -> validate file types
  -> allow user-defined ordering
  -> run local readability enhancement where needed
  -> produce quality metadata
  -> check BYOK provider/model image capability
  -> ask AI-processing consent
  -> send selected/enhanced images and metadata
  -> AI returns structured import draft
  -> local validation
  -> exercise matching
  -> user review
  -> save inactive programme/workout
  -> cleanup temporary image artifacts
```

### 23.3 Local enhancement boundary

Local enhancement may improve readability through:

- orientation correction;
- crop;
- de-skew;
- brightness/contrast;
- sharpening;
- noise reduction;
- upscaling where practical.

Enhancement must not change programme content.

### 23.4 AI image rules

AI must not:

- invent missing text;
- complete cropped tables;
- change numbers;
- infer unreadable exercises as fact;
- alter programme content;
- produce direct saves.

Unreadable regions and missing/unclear content must be surfaced for user review.

---

## 24. Health Integration Architecture

Health integration is a local platform integration.

### 24.1 Scope

Use the `health` package for:

- Apple Health on iOS;
- Health Connect on Android.

### 24.2 Boundary

Health integration must not become cloud sync.

The app should handle unsupported platform/version states gracefully.

### 24.3 Data policy

Only sync the explicitly supported workout summary data defined by v1 scope.

Do not sync AI prompts, detailed local logs beyond the permitted health summary, progress media, physique analysis snapshots, or private notes unless explicitly in scope.

---

## 25. Notifications Architecture

Use `flutter_local_notifications` only for local notifications.

Notification triggers include:

- progress media reminders after first saved media session;
- plateau prompts where appropriate;
- workout reminders if present in v1 settings.

Notification content must be privacy-safe.

Avoid sensitive content in lock-screen notification text.

---

## 26. Bodymap Architecture

### 26.1 Assets

Bodymaps use local SVG assets adapted to the app's 14-bucket muscle group contract.

### 26.2 Rendering

Use `flutter_svg` to render:

- male/female where supported by assets;
- front/back views;
- highlighted muscle groups for exercises.

### 26.3 Offline behavior

Bodymaps must work offline because assets are bundled.

---

## 27. TTS Architecture

Use `flutter_tts` for on-device exercise audio.

### 27.1 TTS cache

Cache generated audio or TTS state only where platform support and implementation approach allow.

At minimum, exercise step text must remain available offline.

### 27.2 TTS boundary

Do not use cloud TTS in v1.

Do not send exercise text to a remote TTS provider.

---

## 28. Privacy and Redaction Architecture

### 28.1 Privacy classifier

Create a central privacy classifier that can categorize fields and payloads as:

- public/reference;
- local app data;
- sensitive profile data;
- health/progress data;
- AI internal data;
- secret;
- exportable;
- non-exportable;
- crash-safe;
- crash-forbidden.

### 28.2 Redaction before logging

All logs must pass through a redacted logger.

Never log:

- API keys;
- prompts;
- AI responses;
- chat history;
- structured output JSON;
- exercise candidate lists;
- injuries;
- lift logs;
- set logs;
- body measurements;
- progress media paths;
- progress media files;
- screenshots;
- enhanced screenshots;
- image-processing artifacts;
- source excerpts;
- local database dumps.

### 28.3 Crashlytics allowlist

Allowed Crashlytics context only:

- app version;
- OS version;
- device model;
- screen name;
- non-sensitive feature flags;
- local schema version;
- exercise dataset version;
- error code;
- redacted stack trace.

Prefer allowlist over denylist.

---

## 29. Error Handling Architecture

### 29.1 App error model

Create a common `AppError` model with:

- error code;
- category;
- severity;
- user-safe message;
- recovery action;
- crash-safe metadata;
- original exception retained only in memory/debug, not exported or logged raw.

### 29.2 Error categories

- validation;
- local database;
- local file system;
- secure storage;
- preferences;
- network;
- Firebase sync;
- AI provider;
- AI schema validation;
- import extraction;
- media permissions;
- export/share;
- health integration;
- notification scheduling.

### 29.3 User-facing errors

User-facing messages should explain:

- what failed;
- whether data was saved;
- whether retry is safe;
- what the user can do next.

Do not expose raw provider errors if they contain sensitive data.

---

## 30. Validation Architecture

### 30.1 Validation layers

Use layered validation:

1. Input validation at UI/controller boundary.
2. Domain validation before write.
3. Schema validation for imported/generated JSON.
4. Reference validation against local exercise library.
5. Privacy validation before export/log/AI payload.
6. Transactional persistence checks.

### 30.2 Validation results

Use a common validation result shape:

```text
ValidationResult
  - isValid
  - errors[]
  - warnings[]
  - repairableIssues[]
  - blockingIssues[]
```

Warnings can permit review/save only where the PRD allows.

Blocking issues must prevent persistence.

---

## 31. Feature Module Boundaries

### 31.1 Onboarding/Profile/Settings

Owns:

- user profile capture;
- goals;
- equipment;
- injuries/limitations;
- favorite/substitution preferences;
- BYOK setup UI;
- settings surfaces.

Uses:

- Drift for profile/settings requiring durability;
- `shared_preferences` only for non-critical UI preferences;
- `flutter_secure_storage` only for API keys.

### 31.2 Exercise Library

Owns:

- dataset sync UI state;
- browse/search/filter;
- exercise detail;
- favorite/substitution affordances;
- local bodymap link;
- video playback entry.

Uses:

- Firebase Storage sync service;
- Drift exercises DAO;
- bodymap renderer;
- TTS service.

### 31.3 Workout Builder/Execution

Owns:

- manual workout creation;
- set prescription editing;
- superset creation;
- workout execution;
- set logging;
- rest timer;
- completion flow.

Uses:

- Drift transactional saves;
- local validation;
- notifications where needed.

### 31.4 Programmes

Owns:

- programme templates;
- multi-week structure;
- schedule/occurrences;
- active/inactive state;
- programme calendar.

Uses:

- same save pipeline for manual, AI, chat, imported, and shared programmes.

### 31.5 AI Infrastructure

Owns:

- provider config/capabilities;
- prompt builder;
- schemas;
- structured-output validation;
- repair;
- candidate selection;
- reference selection;
- AI payload privacy.

Does not own:

- final persistence;
- user review screens;
- local DB writes for programme save except through application use cases.

### 31.6 External Import/Image Import

Owns:

- source selection;
- local extraction/preprocessing;
- order metadata;
- quality metadata;
- consent;
- draft validation;
- exercise matching review state.

Does not own:

- final programme persistence logic;
- AI provider key storage;
- direct export of source files.

### 31.7 Progress Media

Owns:

- capture/import;
- local file persistence;
- thumbnails;
- session metadata;
- comparisons;
- reminders.

Does not own:

- AI analysis provider calls;
- export/share inclusion;
- cloud upload.

### 31.8 Physique Analysis

Owns:

- consent flow;
- selected media/frame payload construction;
- provider capability check;
- structured analysis validation;
- local analysis snapshot display.

Depends on:

- Progress Media;
- AI Infrastructure;
- privacy filter;
- secure storage provider config.

---

## 32. Milestone-to-Architecture Mapping

| Milestone | Architecture Deliverables |
|---:|---|
| M0 | Backlog structure, architectural decisions recorded, no scope changes. |
| M1 | Project structure, Riverpod root, Drift setup, secure storage wrapper, preferences wrapper, file paths, logging/redaction, feature flags. |
| M2 | Firebase sync service, exercise dataset validators, exercise DAOs, library screens, bodymap asset path. |
| M3 | Onboarding/profile/settings modules, BYOK setup, secure key storage, provider config state. |
| M4 | Manual programme/workout domain model, builder, execution, set logging, transactional save pipeline. |
| M5 | Analytics services, PR/e1RM rules, plateau local rules, chart integration. |
| M6 | Progress media file store, media metadata tables, capture/import flow, thumbnails, reminders, local comparisons. |
| M7 | AI provider abstraction, prompt builder, schemas, validation, repair, candidate/reference selection, AI privacy filtering. |
| M8 | AI workout/programme generation using same local persistence path after review. |
| M9 | Chat, save intent flows, swaps, deloads, plateau suggestions. |
| M10 | `.aedifyplan`, PDF export, import validation, privacy filters, share sheet. |
| M11 | Text file extraction, import drafts, exercise matching, reviewed save. |
| M12 | Image selection/order, readability enhancement, image capability gate, image import draft flow. |
| M13 | AI physique analysis consent, media/frame payloads, analysis schema validation, local snapshots. |
| M14 | Cross-feature privacy audit, resilience testing, release hardening. |

---

## 33. Build-Time Data Pipeline Architecture

The runtime app consumes the transformed Firebase-ready dataset.

Build-time pipeline:

```text
aedify-fetch-musclewiki.js
  -> raw aedify-musclewiki-exercises.json
  -> aedify-transform-for-firebase.js
  -> aedify-musclewiki-exercises.firebase.json
  -> upload to Firebase Storage with manifest
```

Runtime app:

```text
Firebase manifest
  -> transformed exercise JSON
  -> local validation
  -> Drift persistence
```

Runtime app does not need MuscleWiki API keys or MuscleWiki HTTP calls.

---

## 34. Testing Architecture Hooks

Architecture should support tests through dependency injection.

### 34.1 Unit-testable components

- validators;
- schema version policies;
- prompt routing;
- candidate selection;
- privacy filters;
- export filters;
- exercise matching;
- warm-up/set rules;
- superset rules;
- plateau rules;
- file lifecycle policies;
- provider capability gating;
- error mapping.

### 34.2 Integration-testable components

- Drift migrations;
- exercise dataset sync transaction;
- workout save transaction;
- programme expansion;
- AI structured output parse/validate/repair flow with fake provider;
- external import draft save flow;
- progress media metadata save/delete flow;
- export/import round trip.

### 34.3 Fake services

Provide fakes for:

- AI providers;
- secure storage;
- preferences;
- Firebase Storage;
- network status;
- file system;
- media picker/camera;
- notifications;
- health integration;
- Crashlytics.

---

## 35. Implementation Rules

1. Do not write feature code that bypasses repositories/services.
2. Do not let AI write directly to local persistence.
3. Do not store secrets outside secure storage.
4. Do not store critical data in `shared_preferences`.
5. Do not send private app data to Crashlytics.
6. Do not export data without the export privacy filter.
7. Do not persist generated/imported content without validation and review.
8. Do not add backend dependencies.
9. Do not couple version tracks.
10. Do not introduce product behavior beyond the locked PRD.

---

## 36. Architecture Acceptance Checklist

The architecture is implementation-ready when:

- Riverpod root providers are defined for all core services.
- Drift database bootstrap and migration scaffolding exist.
- Secure storage and preferences are wrapped behind separate services.
- File-store paths and lifecycle policies are defined.
- Redacted logging and Crashlytics allowlist are implemented before sensitive features.
- Firebase exercise sync service validates before writing.
- Feature modules have clear controller/repository boundaries.
- AI provider abstraction supports capability checks before unsupported flows.
- Prompt builder owns all AI prompt construction.
- Structured-output validators exist before AI generation flows are saved.
- Progress media storage exists before physique analysis.
- Export/import privacy filters are reusable across sharing and import flows.
- All major services can be replaced by fakes for tests.

---

## 37. Next Implementation Planning Document

The next recommended deliverable after this architecture plan is:

```text
v1-feature-by-feature-build-plan-v1.0.md
```

That document should break each PRD feature into implementation units, screens, controllers, services, validation rules, data dependencies, and acceptance criteria.
