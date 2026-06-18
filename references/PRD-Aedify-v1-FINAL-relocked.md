# Product Requirements Document
## Aedify

| | |
|---|---|
| **Version** | v1 Final (locked baseline: PRD v1.10) |
| **Date** | June 10, 2026 |
| **Status** | Final — Re-locked for Implementation after Package Validation |
| **Platforms** | iOS and Android (Flutter, single codebase) |
| **Architecture** | Local-only, offline-first, BYOK (Bring Your Own Key) for AI |
| **v1 Deployment** | Private — maximum 5 users — not intended for public release — exercise data hosted in Firebase Storage; local file/PDF plan sharing; AI-assisted external file/image import; progress media tracking with optional AI physique analysis |

> **Finalization note:** This document is the locked final PRD for v1. PRD v1.10 is the accepted baseline. Future product changes must be handled as formal change requests or a version bump; they should not be silently merged into this v1 baseline.

> **Implementation-readiness correction:** The final PRD was temporarily unlocked for package validation only. No product scope changed. The validated implementation-stack correction keeps Riverpod as the state-management choice, replaces Hive with `shared_preferences` for simple non-critical local preferences, and keeps `flutter_secure_storage` as the only approved storage layer for BYOK API keys and other secrets.

### Changelog vs v1.9

This revision adds **image / screenshot support** to AI-Assisted External Programme / Workout Import while preserving the local-only, offline-first, BYOK architecture, the v1.8 draft-and-review import model, and the v1.9 progress-media privacy rules.

- **§4 / §5.15 / §10.7**: Added image/screenshot import journey. Users can import one or more screenshots or image files as an external workout/programme source.
- **§5.15 / §7.12**: Added supported image inputs: PNG, JPG/JPEG, WEBP, and HEIC/HEIF where platform-supported.
- **§5.15 / §10.7**: Added multi-image selection and user-defined screenshot ordering. User-defined order becomes the source order for AI extraction.
- **§5.15 / §7.12**: Added local-first image readability enhancement/preprocessing for low-quality screenshots, including rotation/orientation correction, crop, de-skew, brightness/contrast, sharpening, noise reduction, and upscaling where practical.
- **§5.15 / §9.13**: Added strict image-import AI rules: enhancement is readability-only; AI must not invent missing text, complete cropped tables, change numbers, or alter programme content.
- **§7.12 / §9.13**: Added multimodal BYOK provider/model gating. Screenshot import requires image input support; unsupported providers/models block image import with clear messaging.
- **§5.15 / §9.13**: Added `EXTERNAL_PLAN_IMPORT/image_parse` and `EXTERNAL_PLAN_IMPORT/image_repair` operation subtypes while reusing the existing external import structured-output schemas and exercise matching flow.
- **§8.7**: Added image import metadata fields for source input type, source file types, image count, order source, enhancement methods, image quality, unreadable regions, and missing/unclear content.
- **§6.3 / §12 / §13**: Added privacy/source-integrity guardrails. Original screenshots, enhanced images, image-processing artifacts, AI internals, private app data, and source-reference content are excluded from Crashlytics, `.aedifyplan`, PDF exports, and all plan-sharing/import/export flows.
- **§5.15 / §12**: Scanned/image-only PDFs remain out of scope unless explicitly reopened later; direct image files/screenshots are supported through the v1.10 image import path.

### Historical changelog vs v1.8

This revision adds **Progress Media Tracking** and optional **AI Physique Analysis** while preserving the local-only, offline-first, BYOK architecture and the v1.8 draft-and-review import model.

- **§4 / §5.12 / §10.6**: Expanded progress photos into progress media sessions. Users can capture or import front, back, left-side, and right-side photos and/or a short all-sides progress video.
- **§5.10 / §5.12**: Added progress media reminders. The app asks for reminder cadence only after the first saved progress media session. Supported cadences: every 2 weeks, monthly, every 3 months, or off.
- **§5.12 / §7.11 / §8.6**: Added local progress media storage model for photo sets, video captures, thumbnails, session notes, optional bodyweight/measurement snapshots, and reminder state.
- **§5.12 / §9.12 / §10.6**: Added optional AI physique analysis. Users can explicitly send selected progress photos or locally extracted video frames to their configured BYOK AI provider for rough body-fat range estimation and physique feedback.
- **§5.12 / §9.12**: Added `progress_physique_analysis_json` structured output. Body-fat estimation must be a range with confidence, not a precise number.
- **§5.12 / §9.12**: Added progress comparison mode for baseline vs latest and previous vs latest check-ins.
- **§6.3 / §12 / §13**: Added privacy guardrails. Progress media and AI physique-analysis results remain local by default, are never sent to Crashlytics, are excluded from `.aedifyplan` and PDF exports, and are sent to AI only after explicit user consent.
- **§11 / §12**: Clarified that AI physique analysis is not medical diagnosis, not a precise body-composition measurement, not attractiveness scoring, and not computer-vision form checking.

### Historical changelog vs v1.7

This revision added **AI-Assisted External Programme / Workout Import** while preserving the local-only, offline-first, BYOK architecture and the v1.7 file-based sharing model.

- **§4 / §5.15 / §10.5**: Added external programme/workout import journey. Users can import programmes or workouts from text-based PDF, TXT, MD, XLSX, and CSV files.
- **§5.15 / §7.10 / §9.11**: Added AI-assisted extraction flow. The app extracts programme-relevant text/tables locally, asks for AI-processing consent, sends only relevant extracted content to the user's BYOK AI provider, and receives a structured draft.
- **§5.15 / §8.5 / §9.11**: Added `external_program_import_json` and `external_workout_import_json` schemas for structured import drafts.
- **§5.15 / §8.5**: External imported programmes may preserve source-file duration even when shorter than the normal AI-generated 8+ week minimum.
- **§5.15**: Import defaults to **extract, normalize, and structure**. It does not adapt, rewrite, expand, or personalize the source programme unless the user explicitly asks in a later flow.
- **§5.15 / §10.5**: Added exercise matching and review workflow: exact/alias matches can auto-match, ambiguous matches require user confirmation, and unmatched exercises must be matched, created as custom, or removed before save.
- **§5.15 / §8.5**: Added custom exercise creation contract for unmatched imported exercises. AI may prefill metadata, but the user must confirm required fields before save.
- **§5.15 / §7.10 / §12**: OCR, scanned/image-only PDFs, encrypted PDFs, corrupted files, and cloud-hosted imports are out of scope for v1.8.
- **§6.3 / §12 / §13**: Added external-import privacy/source-integrity guardrails. Original source files are not stored by default; exports must exclude original source-file content, AI extraction snapshots, prompts, raw AI responses, private profile/log data, and source-reference content.
- **§7.10 / §9.11**: Added external import repair and optional exercise-match-assist prompt subtypes.
- **§10.5 / §13**: Added user-facing consent, unsupported-file handling, ambiguous-unit handling, and inactive-by-default save behavior.

### Historical changelog vs v1.6.1

This revision adds local file-based workout/programme sharing while preserving the local-only, offline-first, no-account architecture.

- **§4 / §5.14 / §10.4**: Added **Plan Sharing** user journey and UX. Users can export saved workouts and multi-week programmes from the Programs Library via the native OS share sheet.
- **§5.14 / §7.9 / §8.4**: Added `.aedifyplan` as the temporary app-native share file extension with `share_schema_version = 1`. The extension may be renamed later when the app name is finalized; the internal share schema remains stable.
- **§5.14 / §10.4**: Added PDF export for users who want to share a human-readable programme with someone who does not have the app. PDF exports are read-only and not importable in v1.
- **§5.14**: Added export format picker: app plan file, PDF, or both.
- **§5.14**: Added privacy modes: `template` by default and optional `exact_prescription` with explicit privacy warning.
- **§5.14 / §10.4**: PDF exports include prescription summaries and printable/open workout logging tables so recipients can manually record actual weights, reps, RPE, and notes.
- **§5.14**: Exercise-instructions appendix is optional and off by default to avoid overly long PDFs.
- **§7.9 / §8.4**: Added deterministic local import validation for `.aedifyplan`; imported plans are inactive by default, editable local copies, and never linked to the sender.
- **§5.14 / §8.4**: Added custom exercise export/import handling. Shared custom exercises include full local definitions and are re-created with new local IDs on import.
- **§6.3 / §12 / §13**: Added sharing privacy guardrails: exports never include profile data, injuries, lift logs, PRs, body measurements, photos, API keys, chat history, prompts, raw AI responses, candidate lists, or AI generation snapshots.
- **§5.14 / §9 / §12**: Powerbuilding-derived exports preserve source-integrity guardrails and must not include source excerpts or reconstruct paid programme tables.

### Historical changelog vs v1.5

This revision adds the scoped powerbuilding reference layer while preserving v1.5's structured-output architecture.

- **§5.3 / §8 / §9**: Added `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` as a supplemental AI reference for combined **Build Strength + Build Muscle** generation.
- **§5.3**: Added powerbuilding-style generation rules for eligible non-beginner athletes, including exercise-role classification, loading-model selection, autoregulation, fatigue management, and deload/taper handling.
- **§5.3.2 / §9**: Clarified that all beginner AI generation paths must exclude the powerbuilding reference, regardless of Path A, Path B/custom generation, daily generation, chat-to-programme flow, exercise swap, or deload. Beginner Path A remains strictly wiki-derived.
- **§8 / §9**: Added optional structured-output metadata for `training_style`, `reference_strategy`, `exercise_role`, `set_intent`, `loading_model`, `block_type`, and related powerbuilding fields.
- **§9.4 / §9.6**: Updated reference-file selection and bundled corpus count from eight wiki files to nine reference files, with file 09 treated as supplemental and scoped.
- **§9.7**: Updated candidate-list ranking for combined strength + hypertrophy requests to prioritize primary compounds, useful secondary compounds, and hypertrophy accessories while preserving equipment + experience hard filters.
- **§10**: Added lightweight UI labels for `Strength + Hypertrophy`, `Powerbuilding`, and exercise roles.
- **§12 / §13**: Added risks and acceptance criteria for powerbuilding-specific AI outputs, beginner exclusion, source reconstruction prevention, and recovery/fatigue management.

### Historical changelog vs v1.4

This revision formalizes the AI generation contract before implementation. The major shifts:

- **§5.3 / §8 / §9**: App-actionable AI outputs now use mandatory structured JSON with a shared envelope, response type, status, schema version, and validation rules. Normal chat remains conversational.
- **§5.3 / §8 / §9**: Multi-week programme generation is **template-based by default**. The AI returns reusable workout templates, weekly schedules, progression rules, warm-up policy, deload rules, and explicit overrides. The app expands and validates the programme at save time.
- **§5.3 / §8 / §9**: Prescriptions are now **set-level**, not exercise-level. Every prescribed and logged set is marked `warmup` or `working`.
- **§5.3 / §5.5 / §8 / §9**: Warm-up sets for non-beginner strength-focused AI outputs are progressively loaded, apply only to loaded strength exercises with absolute working weights, and must not exceed 80% of the associated working set.
- **§5.4 / §5.5 / §8 / §10**: Supersets are supported for manual custom workouts/programmes at all experience levels and for AI-generated non-beginner outputs. AI-generated beginner workouts/programmes must not include supersets.
- **§5.6 / §5.7 / §8**: Warm-up sets are excluded from PR detection, e1RM, plateau detection, progression triggers, and default analytics. They remain visible in workout history.
- **§5.8 / §9**: Chat can generate and save both single workouts and multi-week programmes after explicit user save intent. Chat-generated items use `source = 'ai-chat'`.
- **§9**: Added `STRUCTURED_OUTPUT_REPAIR`, an internal retry flow for invalid JSON or schema-validation failures. The app gets one automatic repair attempt by default.
- **§9**: Candidate exercise list soft caps are defined per prompt type to control BYOK cost and reduce hallucination risk.
- **§7.4 / §9**: Provider integration is still provider-agnostic, but native JSON/schema mode should be used opportunistically when supported.
- **§6.3 / §7 / §12**: Crashlytics redaction rules are now explicit and non-negotiable. Crash reports must never include prompt text, AI responses, keys, logs, measurements, injuries, candidate lists, or structured output JSON.
- **§12**: v1.5 closes the pre-lock open-question audit: programme expansion timing, repair attempts, Build Strength anchor priority, warm-up edge cases, superset limits, Path A periodisation behavior, custom exercise eligibility, swap scope semantics, schema-version separation, and plate-inventory deferral.

### Historical changelog vs v1.3

- **§5.3.2 / §9**: Beginner **Path A** now generates a structured, persisted programme inferred from the bundled wiki guidance instead of only presenting the recommended routine conversationally. The AI must follow the wiki guidance exactly, map the routine to valid local exercise IDs, and return JSON that the app validates and saves to the Programs Library.
- **§7.4**: BYOK provider abstraction is fully populated from v1.2 instead of referencing the prior PRD.
- **§6.5 / §7 / §12**: Firebase Crashlytics selected for crash reporting. This is the explicit exception to the no-telemetry stance because reliable crash diagnostics require sending crash data off-device.
- **§7.5 / §12**: Firebase manifest fields finalized. No per-language manifests and no changelog field in v1.
- **§5.2.1 / §8 / §12**: Schema bump policy changed from hard-fail-only to **migrate where possible**. Unsupported future schemas still show an update-required screen.
- **§7.7 / §12**: Bodymap SVG sourcing resolved: use open-source alternatives as the starting point, adapted into the app's 14-bucket SVG path contract.
- **§9.7 / §12**: Candidate-list filtering resolved: hard filter by equipment + experience; soft filter by goals and include adjacent goal-compatible movements.
- **§12**: Public-release/licensing questions removed from launch blockers because this app is not intended for public release.

### Historical changelog vs v1.2

This was the substantial architectural revision introduced in v1.3. The major shifts:

- **§5.2 / §7 / §8**: Exercise data source pivoted from MuscleWiki at runtime to **Firebase Storage**. The two-tier cache (minimal list + lazy detail) is replaced by a **single bulk sync** of a versioned JSON file produced by a build-time data pipeline (fetch + transform + upload). The runtime app no longer calls MuscleWiki.
- **§5.2 / §8**: **Four-difficulty enum** (`novice`, `beginner`, `intermediate`, `advanced`) — MuscleWiki exposes four buckets, not three.
- **§5.2.2 / §8**: **Muscle taxonomy mapping** baked in. 45 granular API muscle values map to **14 UI buckets**. Both fields stored: `primary_muscles` (source) and `muscle_groups` (UI bucket).
- **§5.2 / §8**: **`modality` field** added (`strength` / `flexibility` / `cardio` / `recovery`), derived from category.
- **§5.2 / §8**: **`force` enum corrected** to `Push` / `Pull` / `Hold` / `null` (v1.2 had `Static` — wrong; the API uses `Hold`, present in 228 records).
- **§5.2 / §8**: **`category` and `equipment` both preserved** (Reading A). `category` is the source value (after typo normalization); `equipment` equals `category` when `modality == 'strength'`, else `null`.
- **§5.13 / §11**: **Bodymap SVG generation is now in scope for v1**, via pre-made anatomical SVGs (Option A). The `bodymap_male` / `bodymap_female` URLs from the API are always null, so we generate our own.
- **§9 (major rewrite)**: **AI prompt architecture is now a modular instruction set.** The system portion lives in a separately-maintained file (`ai-companion-instruction-set.md`) with named sections. Per-call prompts are thin user messages with task-specific content. Replaces v1.2's "stuff everything into each prompt" model.
- **§9 / §5.3**: **Seven prompt categories** (up from v1.2's five). Added `EXERCISE_SWAP` and `DELOAD`.
- **§5.3.4 / §9**: **Per-call periodisation override**. Default is 3+1 mesocycle, but per-call prompts may specify block / linear / undulating models.
- **§5.x / §8**: **Programs Library has three on-ramps**. `source` field is `{ai-generated, ai-chat, custom}` (was `{ai, custom}` in v1.2). The third on-ramp is chat-generated sessions promoted to the library via the save flow.
- **§9**: **AI candidate list richness restored**. Since the full dataset is local after sync, each candidate sent to the AI includes `{id, name, difficulty, muscle_groups, modality, equipment, mechanic}` — not just `{id, name, difficulty}`. v1.2's OQ-9 / R11 is resolved.
- **§8**: **Schema versioning** for the Firebase exercise dataset introduced in v1.3. v1.4 changes the policy to migrate compatible schema changes and reserve update-required hard stops for unsupported future schemas.
- **§12.3**: Open questions were reorganized; in v1.4 the remaining v1.3 questions listed there are resolved.

### Changelog vs v1.1, v1.0

Preserved in earlier revisions. v1.1 added the MuscleWiki two-tier cache and four-variant videos; v1.2 added BYOK details, plateau detection, the unified Programs Library, and resolved the original eight open questions.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Goals and Non-Goals](#2-goals-and-non-goals)
3. [Target Users and Personas](#3-target-users-and-personas)
4. [Key User Journeys](#4-key-user-journeys)
5. [Functional Requirements](#5-functional-requirements)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Technical Architecture](#7-technical-architecture)
8. [Data Model](#8-data-model)
9. [AI Prompt Engineering](#9-ai-prompt-engineering)
10. [UI/UX Considerations](#10-uiux-considerations)
11. [Out of Scope (v1)](#11-out-of-scope-v1)
12. [Risks, Dependencies, and Open Questions](#12-risks-dependencies-and-open-questions)
13. [Success Criteria](#13-success-criteria)
14. [Glossary](#14-glossary)
15. [Implementation Notes for Later](#15-implementation-notes-for-later)
16. [Lock Status](#16-lock-status)

---

## 1. Executive Summary

The Aedify is a cross-platform (iOS + Android) mobile app that acts as a personal trainer, workout programmer, and progress tracker for gym-goers of all experience levels. It combines a curated exercise library (sourced from MuscleWiki, hosted in Firebase Storage as a versioned JSON file) with user-supplied AI capabilities (BYOK — Bring Your Own Key) to generate personalized workout programs, deliver evidence-based fitness guidance, and detect training plateaus from logged data.

The app is **offline-first** and **client-only**: no backend service, no user accounts, no cloud sync. The single remote dependency at runtime is **Firebase Storage**, which hosts the exercise dataset as a versioned JSON file plus a small manifest. The app downloads the dataset once via anonymous Firebase auth, persists it locally in Drift (SQLite), and only re-syncs when the manifest's `latest_version` increments. AI features (program generation, AI Trainer Q&A, plateau suggestions, AI-assisted external file/image import, and optional progress-media analysis) require connectivity and a user-provided API key from a supported LLM provider.

The product is **free**. There is no monetization, no advertising, no in-app purchase. The AI cost is borne by the user via their own LLM provider account.

### What makes this product distinctive

- **User-controlled AI cost and provider choice** via BYOK (no vendor lock-in, no subscription).
- **Evidence-based defaults** — AI prompts are anchored to a bundled reference corpus (the [thefitness.wiki](https://thefitness.wiki/) content from r/Fitness and r/weightroom), so guidance is consistent and grounded.
- **Offline-first by default** — after the first launch sync, the entire app is usable without a network connection. Only AI calls require connectivity.
- **Structured 8+ week programming** with built-in deload weeks and configurable periodisation (default 3+1 mesocycle; per-call overrides for block, linear, or undulating models).
- **Scoped strength + hypertrophy programming** — for suitable intermediate/advanced athletes, the AI can use a supplemental powerbuilding reference to combine strength-focused primary compounds with hypertrophy-focused accessory work, while preserving fatigue management and structured progression.
- **Plateau detection** that uses the actual lift log — regardless of where the workout came from — to surface AI-generated suggestions when progress stalls.
- **Unified Programs Library** — AI-generated, chat-generated, and user-built programs sit side-by-side as first-class entities.
- **AI-assisted external import** — users can import text-based files or screenshots/images into editable local workout/programme drafts with review, matching, and privacy guardrails.
- **Modular AI instruction set** — a single source of truth for the AI's persistent operating context, with sections selectively included in each per-call prompt.

---

## 2. Goals and Non-Goals

### 2.1 Goals (v1)

| ID | Goal |
|----|------|
| G1 | Enable a user to onboard with their AI provider of choice within 5 minutes. |
| G2 | Allow generation of an AI-built workout program (single-day or 8+ week multi-week) personalized to the user's goals, equipment, schedule, and constraints. |
| G3 | Allow fully manual creation of custom workouts with no AI involvement. |
| G4 | Provide a complete exercise library with text, video, and audio descriptions, sourced from a single versioned JSON file in Firebase Storage and cached locally on first launch. |
| G5 | Provide a comprehensive lift log with sets, reps, weight, optional RPE/RIR, and notes. |
| G6 | Surface analytics: previous workouts, per-exercise trends, charts, week-over-week comparisons. |
| G7 | Detect training plateaus across all logged workouts (any source) and trigger AI-driven suggestions. |
| G8 | Provide an always-available AI Trainer Q&A interface using the bundled reference corpus + user profile. |
| G9 | Honor offline-first principles: every non-AI feature functions without a network connection. |
| G10 | Integrate with Apple Health (iOS) and Health Connect (Android). |
| G11 | Support all experience levels (beginner → advanced), with explicit beginner routine-progression guidance. |
| G12 | Treat AI-generated, AI-chat-generated, and user-built programs as equal first-class entities in a single Programs Library. |
| G13 | Render exercise-specific muscle bodymaps generated from in-app SVG assets, not relying on remote URLs. |
| G14 | Support scoped powerbuilding-style AI generation for suitable non-beginner strength + hypertrophy requests, using the supplemental reference file without copying proprietary source programme tables. |
| G15 | Allow users to share saved workouts and multi-week programmes as local app-native share files and/or human-readable PDFs without introducing accounts, hosted links, cloud sync, or social features. |
| G16 | Allow users to capture or import recurring progress photos and videos for visual comparison over time. |
| G17 | Allow users to optionally run AI physique analysis on progress media to receive rough body-fat range estimates, physique observations, and benchmark-style progress feedback. |

### 2.2 Non-Goals (v1)

- ❌ Cloud sync of user data across devices.
- ❌ Cloud backup or sync of progress photos, videos, or physique-analysis results.
- ❌ Multi-user accounts, authentication, or social features.
- ❌ Hosted plan-sharing links, public programme marketplace, followers, likes, comments, or social feeds.
- ❌ Precise or clinically validated body-fat measurement from images/video.
- ❌ Attractiveness scoring, body shaming, medical diagnosis, eating-disorder coaching, or appearance-value judgments.
- ❌ A custom backend service (Firebase Storage is the only remote dependency at runtime; there is no application server).
- ❌ In-app purchases, subscriptions, or ads.
- ❌ Wearable companion apps (Apple Watch, Wear OS) — surface integrations only.
- ❌ Nutrition tracking, meal planning, or calorie counting.
- ❌ Sharing completed workout logs, active programme progress, PR history, body measurements, progress photos, or profile data in v1.
- ❌ Coaching marketplace, real human trainer connection.
- ❌ Video recording or form-check via computer vision.
- ❌ Cloud TTS — TTS is on-device only.
- ❌ Per-user MuscleWiki BYOK at runtime (the runtime app reads from Firebase, not MuscleWiki, and the app is not intended for public release).

---

## 3. Target Users and Personas

The app supports **all experience levels**. The AI is responsible for adapting its output to the user's stated level.

### 3.1 Persona: "Brand-New Brian" (Beginner)

- 28, has never followed a structured program.
- Owns a gym membership, joined 2 weeks ago.
- Doesn't know his max lifts; has never deadlifted.
- **Needs**: Hand-holding, recommended routine progression (Basic Beginner Routine → 5/3/1 / GZCLP), simple onboarding that doesn't ask for numbers he doesn't have.
- **Critical UX**: Must be able to skip max-lift entry during onboarding and update it later. When he triggers programme generation, the AI offers a choice — proven progression or custom design — before generating anything.

### 3.2 Persona: "Intermediate Iris" (Intermediate, 1–3 years training)

- 32, has been lifting for 2 years on a self-made push/pull/legs split.
- Knows her 1RMs, has plateaued on bench press for 3 months.
- Has a knee injury that limits squat depth.
- **Needs**: A program that respects her injury, leverages her favorite exercises, and helps her break through plateau via AI suggestions.
- **Critical UX**: Plateau detection on bench, AI suggestions grounded in her actual log data.

### 3.3 Persona: "Advanced Alex" (Advanced, 5+ years)

- 38, competitive amateur powerlifter.
- Wants to build his own custom programs but use the app for logging and analytics.
- Prefers his own coach's programming; uses AI only for ad-hoc Q&A.
- **Needs**: Frictionless custom workout builder, deep analytics, AI Trainer for occasional questions.
- **Critical UX**: Must be able to bypass AI workout generation entirely.

---

## 4. Key User Journeys

### 4.1 First Launch → First AI Workout

```
App Install
  → Onboarding: AI Provider Setup (BYOK)
  → Onboarding: User Profile Capture
    (max lifts, injuries, favorites, substitutions, notes, sex/preferred video gender)
  → Exercise Library Bulk Sync from Firebase Storage:
      - Anonymous Firebase auth
      - Read manifest.json (small)
      - Download exercises/v{N}.json (full dataset, ~3.5 MB)
      - Parse + write to Drift in a single transaction
      - Mark local schema_version + library_version
  → Hardcoded `INIT` prompt runs once to validate AI setup
  → Home Screen
  → Tap "Generate AI Workout"
  → Select goal(s): build muscle / lose weight / build strength (multi-select)
  → Select scope: today only / weekly program (8+ weeks)
  → If weekly: select days/week, session length, weeks total, optional periodisation override
  → If today-only: select muscle groups (compound split or specific muscles)
  → AI generates workout(s); user reviews; saves to Programs Library
```

### 4.2 Daily Workout Execution

```
Home Screen
  → Today's Workout (from active program) OR pick a saved workout from Programs Library
  → Step-through interface: exercise card with streamed video, step-by-step text, audio sequence (TTS)
    - All exercise details are available offline (full dataset cached from first sync)
    - Only video stream itself requires connectivity
  → Log each set (weight, reps, optional RPE/RIR)
  → Rest timer auto-starts after each set
  → Mark workout complete
  → Plateau-detection background task runs against the new log entries
  → Optional: post-workout notes
  → Sync workout summary to Apple Health / Health Connect
```

### 4.3 Plateau Detection → AI Suggestion

```
User logs new bench press session (from any source: AI program / AI-chat / custom / standalone log)
  → Background analytics task: rolling 3-session e1RM trend
  → No improvement detected → flag plateau on bench press
  → Notification: "Looks like bench press has plateaued. Want suggestions?"
  → Tap notification
  → AI Trainer chat opens; the app sends the PLATEAU_SUGGESTION per-call prompt:
      context (lift, weight, session count), exercise-specific log slice,
      system message assembled from instruction set sections (per routing)
  → AI returns conversational analysis (2–4 paragraphs) + structured JSON 3-week plan
  → User can accept the plan (persists to programme) or discuss further in chat
```

### 4.4 Custom Workout Creation

```
Home Screen → "Build Custom Workout"
  → Add exercises from cached library OR add a fully custom exercise
    (custom: name, body parts, optional video URL, step-by-step description; TTS audio synthesized per step)
  → For each exercise: configure target sets, reps, weight, rest time
  → Save → assigned to Programs Library (filterable as "Custom")
  → Available for execution like any AI-generated workout
```

### 4.5 Chat-to-Library On-Ramp (new in v1.3)

```
User opens AI Trainer chat
  → Types: "Give me a chest workout for today, 45 minutes, dumbbells"
  → AI generates a markdown-table session (per HOW TO RESPOND in instruction set)
  → User reviews; the session lives in chat only by default
  → User taps "Save to library" (or types "save that workout")
  → App sends follow-up call with structured-output schema
  → AI returns the same session as JSON, referencing exercise IDs from the candidate list
  → App validates IDs against the library; persists to Saved Workouts with source='ai-chat'
  → Appears in Programs Library alongside AI-generated and custom workouts
```

---

### 4.6 Share Programme or Workout

```
Programs Library
  → Open saved programme or saved workout
  → Tap Share
  → Choose format:
      - App plan file (.aedifyplan)
      - PDF
      - Both
  → Choose privacy mode:
      - Template (default; excludes exact strength-revealing loads where possible)
      - Exact prescription (includes prescribed loads; shows privacy warning)
  → Optional: include exercise-instructions appendix in PDF (off by default)
  → Preview privacy summary
  → Native OS share sheet
```

Import flow:

```
Open .aedifyplan file from Files / AirDrop / messaging / email
  → App validates share schema and content locally
  → Preview imported plan
  → Resolve missing exercises or custom exercises if needed
  → Save inactive copy to Programs Library
  → User may edit or manually activate
```

PDF exports are read-only human documents and are not importable in v1.


### 4.7 Import External Programme or Workout

User journey:

```text
Programs Library / Saved Workouts Library / Global Add
  → Import from file
  → Choose source: text-based PDF, TXT, MD, XLSX, CSV, or Images / screenshots
  → App checks file type and extractability
  → App extracts programme-relevant text/tables locally, or prepares selected screenshots/images
  → User confirms AI-processing consent
  → AI converts extracted content into a structured import draft
  → App validates the draft and runs exercise matching
  → User resolves ambiguous/unmatched exercises
  → User previews imported programme/workout
  → User saves
  → Imported programme appears inactive by default, or imported workout appears in Saved Workouts
```

Key principles:

- The AI creates an **import draft**, not a direct save.
- The app validates the draft before persistence.
- The user must resolve ambiguous and unmatched exercises before save.
- Imported programmes are inactive by default.
- The original source file or screenshot image is not stored by default.
- Import defaults to extraction/normalization/structuring, not adaptation.
- Screenshot/image imports use the same validation, exercise matching, and inactive-by-default save rules as text imports.


### 4.8 Progress Media Capture and Optional AI Physique Analysis

```text
Progress tab
  → Add progress media
  → Choose capture type:
      - Photo set
      - Video
      - Both
  → Capture or import front, back, left-side, and right-side photos and/or a short all-sides video
  → Save baseline or new progress session locally
  → If this is the first saved progress media session, ask reminder cadence:
      - Every 2 weeks
      - Every month
      - Every 3 months
      - Off
  → Show session in progress media timeline
```

Optional AI analysis flow:

```text
Progress media session
  → Tap Analyze with AI
  → App explains selected media/frames will be sent to the user's configured AI provider
  → User confirms
  → For photo sets: send selected progress photos
  → For video: extract canonical frames locally where possible: front, back, left side, right side
  → AI returns rough body-fat range, confidence, physique observations, and practical focus areas
  → App stores the analysis snapshot locally
  → User can compare baseline vs latest or previous vs latest analysis
```

Key principles:

- Progress media is local-first and private by default.
- AI analysis is user-triggered only; no automatic or background media analysis.
- Body-fat output is an approximate range with confidence, not a precise measurement.
- Analysis is educational and training-oriented, not medical, diagnostic, shaming, or appearance-scoring.
- Progress media and analysis results are excluded from plan sharing, external imports, Crashlytics, and default exports.


### 4.9 Import External Programme or Workout from Images / Screenshots

User journey:

```text
Programs Library / Saved Workouts Library / Global Add
  → Import
  → Choose source:
      - Document file
      - Images / screenshots
  → Select one or more supported image files
  → Reorder images into the correct reading order
  → App checks image quality
  → App applies local readability enhancement when needed
  → User previews selected/enhanced images where practical
  → User confirms AI-processing consent
  → App sends the image import package to an image-capable BYOK AI provider/model
  → AI converts visible programme/workout content into a structured import draft
  → App validates the draft and runs exercise matching
  → User resolves ambiguous/unmatched exercises and unclear fields
  → User previews imported programme/workout
  → User saves
  → Imported programme appears inactive by default, or imported workout appears in Saved Workouts
```

Key principles:

- Image import extends the existing external import flow; it is not a separate import system.
- User-defined screenshot order becomes the source order.
- Image enhancement is for readability only and must not alter programme meaning.
- The AI must not invent cropped, missing, or unreadable programme content.
- Original screenshots and enhanced images are temporary import artifacts and are not stored by default.

## 5. Functional Requirements

### 5.1 Onboarding

#### 5.1.1 AI Provider Setup (BYOK)

**Description**: User selects an LLM provider and supplies an API key, which is stored in platform-secure storage.

**Supported providers (v1)**:

| Provider | Models exposed in UI | Notes |
|---|---|---|
| OpenAI | GPT-4o, GPT-4o-mini, o1, o1-mini | Default selection is the cheapest. User can override. |
| Anthropic | Claude Sonnet 4.6, Claude Haiku 4.5, Claude Opus 4.7 | Default selection is the cheapest. User can override. |
| Google | Gemini 2.5 Pro, Gemini 2.5 Flash | Default selection is the cheapest. User can override. |

**Functional requirements**:

- FR-1.1.1: User selects provider from a list with brief descriptions.
- FR-1.1.2: User pastes API key. Key is validated by issuing a minimal test call (1–2 tokens) before being stored.
- FR-1.1.3: Validated key is stored in `flutter_secure_storage`. Plain-text key never written to logs, app-state files, or anywhere else.
- FR-1.1.4: User selects a default model from the provider's available list. Pre-selected default is the cheapest model in that provider's catalog, with a subtle hint about more capable options.
- FR-1.1.5: User can advance only after a successful validation call (or explicitly choose "Skip AI for now").
- FR-1.1.6: An "Estimated cost per workout generation" indicator shows estimated token usage and approximate USD cost.
- FR-1.1.7: User may **skip AI setup**. AI features are disabled until configured. Custom workouts, lift log, exercise library, and analytics remain fully usable.
- FR-1.1.8: User can switch providers, change keys, or change default models at any time from Settings. Chat history is retained across provider switches; prior turns are serialized as plain text and sent to the new provider.

**Acceptance criteria**:
- ✅ Invalid key rejected with clear error before storage.
- ✅ Valid key stored encrypted; never appears in any log, error report, or telemetry.
- ✅ Skipping AI setup does not block any non-AI feature.

#### 5.1.2 User Profile Capture

**Description**: After AI setup, capture the data needed to personalize generated workouts.

| Field | Type | Required? | Notes |
|---|---|---|---|
| Display name | String | Yes | Stored locally only. |
| Date of birth | Date | Optional | For age-appropriate intensity recommendations. |
| Sex (assigned at birth) | Enum (Male / Female / Prefer not to say) | Optional | Used for protein/calorie heuristics and as the default video-gender for exercise detail playback (see FR-2.3.2). |
| Height | Number + unit (cm / ft+in) | Optional | |
| Bodyweight | Number + unit (kg / lb) | Optional | Logged as first body-measurement entry. |
| Bench press 1RM | Number + unit | Optional | "Skip — I don't know" allowed. |
| Squat 1RM | Number + unit | Optional | Same. |
| Deadlift 1RM | Number + unit | Optional | Same. |
| Self-assessed experience level | Enum (Beginner / Intermediate / Advanced) | Yes | Drives default routine recommendations. Maps to MuscleWiki difficulty enum (`novice` / `beginner` / `intermediate` / `advanced`) for library filtering. |
| Injuries / limitations | Free text + tag selection | Optional | Stored verbatim for AI context. |
| Favorite exercises | Multi-select from cached library | Optional | AI is instructed to prioritize these. |
| Exercises to substitute | Multi-select from cached library, each paired with a substitute or "AI's choice" | Optional | AI must avoid the originals. |
| Other notes for your trainer | Free text (max 1000 chars) | Optional | Catch-all for context. |

**Functional requirements**:

- FR-1.2.1: All fields except display name and experience level can be skipped.
- FR-1.2.2: Profile data persists in local DB; can be edited any time from Settings → Profile.
- FR-1.2.3: Editing profile triggers a prompt: "Regenerate active program with updated info?" if a multi-week program is in progress.
- FR-1.2.4: Favorites and substitutions reference exercise IDs from the locally-cached library. If the library hasn't been synced yet, exercise selection screens block with "Library is loading — try again in a moment."
- FR-1.2.5: The `sex` field defaults the exercise detail video to the matching gender. If "Prefer not to say" or unset, the default is **male** (with a clearly visible gender toggle on the detail screen).
- FR-1.2.6: All weight, length, and dimension values are stored in **canonical metric units** (kg, cm). Display conversion happens at the UI layer based on `user_profile.preferred_units`.

#### 5.1.3 Reference File and `INIT` Prompt

**Description**: After profile capture, the hardcoded `INIT` prompt runs once. Per the modular instruction-set architecture (§9), the system message is assembled from the sections routed to `INIT` (TONE, ATHLETE PROFILE, LIFT LOG, PROGRAMMING RULES), and the per-call user message includes a brief exercise library overview plus the kickoff task.

**Functional requirements**:

- FR-1.3.1: On profile completion, the app issues a single AI call using the `INIT` per-call user-message template (see §9.3.1).
- FR-1.3.2: The system message includes the routed sections from the instruction set, populated from local data.
- FR-1.3.3: The per-call user message includes an **exercise library overview** line (e.g., *"1,902 exercises across 14 muscle groups, 4 difficulty levels, 4 modalities, filterable by equipment."*) so the AI can acknowledge scope without being sent the full catalog.
- FR-1.3.4: If the AI call fails, user sees a clear error with retry and "skip for now" options.
- FR-1.3.5: The AI's response is shown as the AI Trainer's first message (initializes chat history).

### 5.2 Exercise Library

#### 5.2.1 Sourcing and Caching (Single Bulk Sync from Firebase Storage)

The exercise dataset is built by a dev-side data pipeline (see §7.6) and uploaded to Firebase Storage as a single versioned JSON file. The runtime app reads from Firebase Storage on first launch (and only on `latest_version` increment thereafter), parses, and persists to the local Drift DB. There are no per-tap lazy loads — every exercise's full detail is in the local DB after the initial sync.

**Functional requirements**:

- FR-2.1.1: **First-launch sync**:
  - Anonymous Firebase auth (`signInAnonymously()`) if not already authenticated.
  - Read `gs://{bucket}/exercises/manifest.json` (tiny — a few hundred bytes).
  - Manifest contains only: `latest_version`, `last_updated_at`, `exercise_count`, `file_path` (e.g., `exercises/v1.json`), `min_app_schema_version`. No `changelog` field and no per-language manifests in v1.
  - If local `library_version` is missing or `< manifest.latest_version`: download `manifest.file_path`. Show a progress indicator ("Loading exercise library… {N}%").
  - Parse the JSON. Validate `schema_version` and run a local migration when the dataset schema is compatible with the installed client (see FR-2.1.5).
  - Replace the local `exercises` table contents atomically (single transaction). Update local `library_version`.
- FR-2.1.2: **Subsequent launches**: read manifest. If `latest_version` unchanged, no download — use cached data. If incremented, fetch and replace as in FR-2.1.1.
- FR-2.1.3: The dataset is cached in **Drift (SQLite)**. Every exercise record carries the full set of fields described in §8 (no partially-loaded records as in v1.2's two-tier model).
- FR-2.1.4: A manual **"Refresh Exercise Library"** action exists in Settings. It clears the local exercise table and re-runs the sync. Custom exercises are NOT affected.
- FR-2.1.5: **Schema version check + migration**: if `manifest.min_app_schema_version > app's supported schema version`, the app refuses to download and shows a "Please update the app" screen. If the dataset schema is within the app's supported migration range, the app downloads, migrates the payload locally, validates the migrated shape, and atomically writes the result to Drift.
- FR-2.1.6: If the manifest fetch fails on first launch, the user sees an error with retry. Custom workouts, lift log, profile, and analytics remain usable; library browsing is blocked until sync succeeds.
- FR-2.1.7: If sync fails partway through (download succeeded but parse failed), the local DB is left untouched (transactional atomicity). The user sees a retry option.

**Cached fields per exercise** (full record, always present after sync):

| Field | Source | Notes |
|---|---|---|
| `id` | source dataset | int. |
| `name` | source dataset | |
| `difficulty` | source dataset (lowercased during build) | enum: `novice` / `beginner` / `intermediate` / `advanced`. |
| `primary_muscles` | source dataset | string array (the 45 granular MuscleWiki muscle names). |
| `muscle_groups` | derived in build pipeline | string array (the 14 UI buckets). |
| `category` | source dataset (with typo normalization, e.g., `Medicineball` → `Medicine-Ball`) | string. |
| `modality` | derived in build pipeline | enum: `strength` / `flexibility` / `cardio` / `recovery`. |
| `equipment` | derived in build pipeline | `category` if `modality == 'strength'`, else `null`. |
| `force` | source dataset (empty strings normalized to null) | enum: `Push` / `Pull` / `Hold` / `null`. |
| `mechanic` | source dataset (empty strings normalized to null) | enum: `Compound` / `Isolation` / `null`. |
| `grips` | source dataset | string array. |
| `steps` | source dataset | ordered string array. |
| `videos` | source dataset | array of `{url, angle, gender, og_image}`. Stored in `exercise_videos` table (one-to-many). |
| `source` | local | `'firebase'` (synced from Firebase Storage) or `'custom'` (user-created). |
| `is_favorite` | local user | boolean. |
| `is_substituted` | local user | boolean. |
| `substitute_id` | local user | FK to another exercise. |

**Notes on the source dataset**:
- 1,902 exercises across the four difficulties: novice (563), beginner (674), intermediate (474), advanced (191).
- 4 modalities: strength (1,460), recovery (218), flexibility (176), cardio (48).
- 14 muscle group buckets cover the full taxonomy.
- `bodymap_male` / `bodymap_female` from the MuscleWiki API are 100% null — dropped during transform. We generate bodymaps locally (see §7.7).

#### 5.2.2 Body-Part Taxonomy

The 45-value MuscleWiki `primary_muscles` enum maps to a 14-bucket UI taxonomy. The mapping is **derived in the build pipeline** so the client never has to apply it at runtime. The full table:

| UI bucket | Source values |
|---|---|
| Chest | Chest, Mid and Lower Chest, Upper Pectoralis |
| Shoulders | Shoulders, Front Shoulders, Anterior Deltoid, Rear Shoulders, Posterior Deltoid, Lateral Deltoid |
| Back | Lats, Traps, Traps (mid-back), Upper Traps, Lower Traps, Lower back |
| Biceps | Biceps, Short Head Bicep, Long Head Bicep |
| Triceps | Triceps, Long Head Tricep |
| Forearms | Forearms, Wrist Extensors, Wrist Flexors |
| Core | Abdominals, Obliques, Lower Abdominals, Upper Abdominals |
| Glutes | Glutes, Gluteus Medius, Gluteus Maximus |
| Quads | Quads, Rectus Femoris, Inner Quadriceps, Outer Quadricep |
| Hamstrings | Hamstrings, Lateral Hamstrings, Medial Hamstrings |
| Calves | Calves, Gastrocnemius, Soleus, Tibialis |
| Adductors | Groin, Inner Thigh |
| Neck | Neck |
| Feet | Feet |

The mapping must be kept in sync between the build pipeline (Node.js `aedify-transform-for-firebase.js`) and the client UI (Flutter widget code). When the dataset's `schema_version` changes due to a new muscle name being added, both sides update; strict mode in the transform script forces this synchronization (it fails loudly on unmapped values).

**Compound-split derivations** (Push / Pull / Legs / Upper / Lower / Full Body) are computed in the client from `muscle_groups` + `force`:

- **Push** = exercises with `force == 'Push'` whose `muscle_groups` include Chest, Shoulders, or Triceps.
- **Pull** = exercises with `force == 'Pull'` whose `muscle_groups` include Back, Biceps.
- **Legs** = exercises whose `muscle_groups` include Glutes, Quads, Hamstrings, Calves, or Adductors.
- **Upper** = Push + Pull + Core.
- **Lower** = Legs.
- **Full Body** = no filter / union.

#### 5.2.3 Exercise Detail View

**Functional requirements**:

- FR-2.3.1: Tapping an exercise from any list opens the detail screen. Full data is always available locally (no shimmer-load state needed in v1.3).
- FR-2.3.2: **Video playback**:
  - Default video selection: `gender` matches user's profile `sex` (male / female / unset → male); `angle = front`.
  - Two toggles visible above the video player: gender (male / female) and angle (front / side). Selection is remembered per exercise.
  - Video is streamed (no caching). On stream failure (offline, CDN error), show a clear placeholder + retry; text + audio remain available.
  - `og_image` is used as the poster frame.
- FR-2.3.3: **Step-by-step instructions**: rendered as an ordered list. Each step is its own tappable row.
- FR-2.3.4: **Audio guide**: "Play audio guide" button plays the steps as a sequence.
- FR-2.3.5: TTS audio is synthesized per step via `flutter_tts`:
  - Each step is synthesized to a separate audio file at first playback.
  - Files cached in app storage under `(exercise_id, step_index, locale)` keys.
  - Playback sequence: step 1 audio → 1-second pause → step 2 audio → 1-second pause → … The active step row is highlighted in the UI as it plays.
  - User can tap any individual step to play just that step. Can pause / resume / restart.
- FR-2.3.6: **Muscle diagram**: rendered from local SVG assets via the bodymap pipeline (§7.7). Highlights the `muscle_groups` for this exercise. Gender follows the same default + toggle as video selection. Front and back views available via tab or flip.
- FR-2.3.7: User can favorite/unfavorite from this screen.
- FR-2.3.8: User can mark for substitution from this screen.
- FR-2.3.9: User can tap "Ask AI about this exercise" → opens AI Trainer with the exercise as pre-populated context.
### 5.3 AI Workout Program Generation

#### 5.3.1 Goal and Configuration Selection

**Functional requirements**:

- FR-3.1.1: User selects one or more goals: **Build Muscle**, **Lose Weight**, **Build Strength** (multi-select).
- FR-3.1.2: User selects scope: **Today only** OR **Weekly program**.
- FR-3.1.3: If "Weekly program": user selects program length in weeks (minimum **8**, maximum 16 in v1).
- FR-3.1.4: User selects available training days per week (Mon–Sun checkboxes).
- FR-3.1.5: User selects target session length in minutes (30 / 45 / 60 / 75 / 90 / 120).
- FR-3.1.6: User selects equipment access (multi-select). The selection filters which exercises become candidates.
- FR-3.1.7: For "Today only": user additionally selects muscle group focus (compound split OR specific muscles, per §5.2.2) and optionally specifies session intent (high-volume hypertrophy / low-volume strength / skill / active recovery) and a free-form context note.
- FR-3.1.8: **"Build Strength" goal prerequisites**:
  - If user has a 1RM for the relevant lift → AI uses 1RM directly.
  - If user has bodyweight only → AI uses bodyweight-relative defaults, flagged as starting estimates.
  - If both → AI uses 1RM as primary, bodyweight for relative-strength ratio + sanity check.
  - If neither → "Build Strength" is disabled in the UI with a CTA to add data.
- FR-3.1.9: For multi-week programs, the user may optionally specify a **periodisation override** (block / linear / undulating). If omitted, the default 3+1 mesocycle from PROGRAMMING RULES applies.

#### 5.3.2 Beginner Routine Progression Option (Choice-First Flow)

**Functional requirements**:

- FR-3.2.1: If the user's experience level is "Beginner" and they trigger multi-week programme generation, the app sends the `MULTI_WEEK_PROGRAM` (beginner variant) prompt. The AI's first response **must offer the choice between two paths and wait for the user's selection before generating**:
  - **Path A**: Proven progression (Basic Beginner Routine → 5/3/1 / GZCLP).
  - **Path B**: Custom-designed programme around the user's goals.
- FR-3.2.2: The AI explains the trade-offs of each path (1–2 sentences each, citing wiki where appropriate) and asks the user to pick.
- FR-3.2.3: **Path A**: After the user selects the proven-progression path, the AI must infer a complete beginner programme from the bundled wiki guidance and return structured JSON that the app validates and saves to the Programs Library with `source = 'ai-generated'`.
  - The AI must use `aedify-aedify-05-exercise-programming.md` as the primary programming reference and include `aedify-aedify-01-getting-started.md` where beginner habit/adherence guidance is relevant.
  - The AI must follow the wiki guidance exactly: with barbell access, start from the r/Fitness Basic Beginner Routine; without barbell access, use the wiki-supported bodyweight beginner path. It must not invent a custom split and label it Path A.
  - The generated programme must preserve the proven routine's intent, frequency, progression model, and graduation path. Any exercise substitution is allowed only when required by equipment, injury, or explicit user constraints, and the substitution must preserve the same movement pattern as closely as possible.
  - The AI must map every exercise to a valid local exercise ID from the candidate list. Unknown exercises are not allowed in Path A output.
  - The AI returns both: (1) structured programme JSON conforming to `{{schema.multi_week_program_json}}`, and (2) a short conversational explanation of how the programme follows the wiki path and when the user should graduate to the next stage.
- FR-3.2.4: **Path B**: AI generates a custom programme per the constraints (calibration week, conservative loading, requested periodisation). Returns structured JSON + a conversational walkthrough.
- FR-3.2.5: Intermediate and Advanced users do not see this choice; AI generates freely with awareness of their level.

- FR-3.2.6: All beginner AI generation excludes `aedify-aedify-09-powerbuilding-strength-hypertrophy.md`, regardless of Path A, Path B/custom generation, daily workout, multi-week programme, chat-generated programme, exercise swap, deload, or save-to-library flow. The AI must follow beginner-safe wiki and instruction-set guidance and must not apply intermediate/advanced powerbuilding blocks, heavy singles, peaking/tapering logic, advanced intensity techniques, or aggressive volume progression.
- FR-3.2.7: Beginner Path A remains strictly wiki-derived and must follow the bundled wiki beginner guidance to the tee.
- FR-3.2.8: Beginner Path B may borrow only beginner-safe principles that already exist elsewhere in the instruction set: progressive overload, conservative calibration, balanced muscle coverage, recovery, and simple deload guidance. It must not use advanced powerbuilding structures by default.

#### 5.3.3 Today-Only Workout Generation

Triggered by the `DAILY_WORKOUT` prompt (§9.3.2).

**Functional requirements**:

- FR-3.3.1: Inputs to the per-call user message: session length, focus, optional intent, optional context note, equipment, warm-up / cool-down toggles, active programme reference (if overriding a scheduled session), and the candidate exercise list.
- FR-3.3.2: Output: a single workout structured as warm-up (optional), 4–8 main exercises with prescribed sets, reps (or rep range), target weight (% of 1RM where applicable), and rest time. Plus cool-down (optional).
- FR-3.3.3: **Exercise resolution**: AI returns exercise IDs from the candidate list. The app validates each returned ID against the local exercise table. Unknown IDs trigger a fuzzy-match fallback by name; no match → "AI suggestion (manual replacement needed)" with a "Choose from library" CTA.
- FR-3.3.4: Rest times: minimum 30 seconds, no maximum. Rest can be uniform or per-exercise.
- FR-3.3.5: The generated workout is saved to the local DB as a Saved Workout with `source = 'ai-generated'` and presented for review/edit before activation.
- FR-3.3.6: On generation, the app captures the exact prompt + variable values used, for reproducibility.
- FR-3.3.7: If the daily workout request combines `Build Strength` + `Build Muscle`, and the athlete is eligible, the AI may label the workout `training_style = strength_hypertrophy` and may assign `exercise_role` and `set_intent` metadata to improve validation, logging, and later analytics.

#### 5.3.4 Multi-Week Program Generation (8+ weeks)

Triggered by the `MULTI_WEEK_PROGRAM` prompt (§9.3.3) — general or beginner variant.

**Functional requirements**:

- FR-3.4.1: Inputs: user profile (via system message), goals, days/week, weeks total, session length, equipment, periodisation override (optional), candidate exercise list.
- FR-3.4.2: **Default program structure**: mesocycles of 3 training weeks + 1 deload week, repeating. 8 weeks = 2 mesocycles. 12 weeks = 3.
- FR-3.4.3: **Per-call periodisation override**: the per-call prompt may specify an alternative model (e.g., block periodisation: 4 weeks volume → 4 weeks intensity → 3 weeks heavy → 1 week deload). When specified, the AI honors the requested model. PROGRAMMING RULES in the instruction set codifies the default + override behavior.
- FR-3.4.4: Progressive overload is encoded per the rules in PROGRAMMING RULES.
- FR-3.4.5: Goal-conditional rules from PROGRAMMING RULES apply (e.g., cardio session/week for Lose Weight, compound-lifts-first for Build Strength, ≥2× per major muscle for Build Muscle).
- FR-3.4.6: After generation, the user can accept as-is, request a regeneration with feedback, or edit individual sessions.
- FR-3.4.7: The generated program is saved to the Programs Library with `source = 'ai-generated'`.

- FR-3.4.8: Multi-week programmes with `training_style = strength_hypertrophy` may specify a `block_type` per programme, mesocycle, or week. Supported values are `base`, `accumulation`, `hypertrophy_biased`, `strength_biased`, `peak`, and `deload`.
- FR-3.4.9: If the AI uses a powerbuilding-style structure, it must include a fatigue-management strategy. The app validates that the output contains at least one of: explicit deload week, volume reduction rule, RPE/RIR cap, taper rule, or conservative progression rule.

#### 5.3.4.1 Powerbuilding-style Strength + Hypertrophy Generation

**Description**: When a suitable athlete requests both `Build Strength` and `Build Muscle`, the AI may use `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` as a supplemental reference to generate a hybrid programme or workout. The output must remain original, locally valid, schema-compliant, and adapted to the athlete's profile, equipment, training history, and recovery constraints.

**Trigger conditions**:

- The athlete's selected goals include both `Build Strength` and `Build Muscle`; or
- The athlete explicitly requests a "powerbuilding", "strength + hypertrophy", "strength and size", "powerlifting/bodybuilding hybrid", or similar programme.

**Eligibility rules**:

- FR-3.PB.1: Default eligibility is `intermediate` or `advanced`.
- FR-3.PB.2: The AI may generate a simplified strength + hypertrophy programme for a `beginner` only through beginner-safe generation rules, without using file 09 or advanced powerbuilding structures.
- FR-3.PB.3: All beginner AI generation paths must never use the powerbuilding reference, regardless of whether the request starts from Beginner Path A, Beginner Path B/custom generation, `DAILY_WORKOUT`, `MULTI_WEEK_PROGRAM`, `AI_TRAINER_CHAT`, exercise swap, deload, or chat-to-save flow. Beginner Path A remains strictly derived from bundled wiki beginner guidance.
- FR-3.PB.4: If the athlete lacks recent working weights, useful 1RMs, estimated 1RMs, or bodyweight anchors, the AI must either produce a conservative calibration-focused plan or return `needs_input` when the requested strength prescription cannot be responsibly anchored.

**Programming rules**:

- FR-3.PB.5: Treat `Build Strength + Build Muscle` as one hybrid goal, not two independent goals stitched together.
- FR-3.PB.6: Every generated exercise prescription must include optional `exercise_role` metadata where relevant: `primary`, `secondary`, `tertiary`, `conditioning`, or `mobility_recovery`.
- FR-3.PB.7: Primary lifts are heavy compound patterns with high strength relevance and high systemic fatigue, such as squat, bench press, deadlift, overhead press, or close variations.
- FR-3.PB.8: Secondary lifts are compound accessories that support primary lifts or build major muscle groups with less systemic fatigue.
- FR-3.PB.9: Tertiary lifts are isolation/accessory movements for hypertrophy, weak points, local volume, joint balance, or pump work.
- FR-3.PB.10: The AI must include fatigue management in any multi-week powerbuilding-style output. Acceptable mechanisms include deload weeks, lower-volume weeks, RPE/RIR ceilings, reduced accessory volume, or taper logic when testing is requested.
- FR-3.PB.11: The AI must not prescribe advanced peak/testing blocks unless the athlete is advanced or explicitly requests a test-oriented block.
- FR-3.PB.12: True 1RM testing must be treated as advanced and optional. AMRAP/e1RM testing is the safer default for most strength + hypertrophy users.
- FR-3.PB.13: Deadlift frequency and deadlift volume must be conservative relative to squat/bench volume because deadlift fatigue cost is high.

**Loading model rules**:

- FR-3.PB.14: Primary lifts may use `fixed_percent_1rm`, `percent_1rm_bracket`, `rpe_target`, `rpe_range`, `top_set_backoff`, or `calibration`.
- FR-3.PB.15: Secondary and tertiary work should usually use rep ranges, RPE/RIR targets, double progression, tempo/technique targets, or calibration rather than rigid percentage prescriptions.
- FR-3.PB.16: When using RPE/RIR or percentage brackets, the AI must explain that the target is effort and technique, not always the top of the bracket.
- FR-3.PB.17: If warm-ups move poorly, recovery is poor, or form degrades, the generated guidance should bias toward the lower end of the prescribed bracket.

**Reference integrity rules**:

- FR-3.PB.18: The AI may use `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` for principles only.
- FR-3.PB.19: The AI must not reproduce, reconstruct, or output source PDF programme tables, exact week-by-week layouts, proprietary exercise sequences, or branded programme clones.
- FR-3.PB.20: The app should preserve `reference_files_used` metadata on generated AI outputs so the user/developer can inspect which references influenced the generation.

#### 5.3.5 Deload and Progressive Overload

**Functional requirements**:

- FR-3.5.1: Every multi-week program contains at least one explicit deload week per 4–5 weeks of training (subject to the periodisation model — block periodisation places deloads differently than 3+1).
- FR-3.5.2: Deload weeks are visually marked in the program calendar.
- FR-3.5.3: Progressive overload deltas (from PROGRAMMING RULES):
  - Beginner upper-body lifts: +2.5 lb (or +1 kg) per week.
  - Beginner lower-body lifts: +5 lb (or +2.5 kg) per week.
  - Intermediate / Advanced: AI determines based on goal and current 1RM.
- FR-3.5.4: When a user logs a workout and fails to hit prescribed reps, the next session's prescribed weight does not auto-increment (overload is paused).
- FR-3.5.5: **Standalone deload generation**: a user can request a deload week independently of program generation via the `DELOAD` prompt. The AI generates a single deload week based on the prior training week, reducing volume ~40% and intensity ~20%, capping RPE at 5–6.

#### 5.3.6 Program Completion

**Functional requirements**:

- FR-3.6.1: A program is considered "complete" when the user has logged at least one session for the final scheduled day of the final week, OR when the user manually marks it complete from the Programs Library.
- FR-3.6.2: On completion, the dashboard shows three options:
  - **Repeat this program**: reschedules the same program starting next week.
  - **Regenerate with my latest 1RMs**: re-runs the original generation prompt against the current profile.
  - **Generate a fresh program**: opens the AI generation flow at step 1.
- FR-3.6.3: Completed programs are not deleted. They remain in the Programs Library marked "Completed."
- FR-3.6.4: If the user dismisses the completion prompt without picking an option, the program is marked completed and the user lands on a "no active program" home state.

#### 5.3.7 Exercise Substitution (new in v1.3)

Triggered by the `EXERCISE_SWAP` prompt (§9.3.4).

**Functional requirements**:

- FR-3.7.1: User can request to swap an exercise out of an active programme. Entry points: long-press on an exercise in the program calendar, or via chat ("swap [exercise] in my programme").
- FR-3.7.2: Inputs: original exercise (id + name), candidate exercises filtered by same primary muscle group + user's equipment, excluding injury-loading or already-substituted exercises, current programme block context.
- FR-3.7.3: AI returns a conversational recommendation: replacement exercise (name + id), reasoning, and whether prescribed sets/reps/weight/RPE should change.
- FR-3.7.4: If the user accepts and asks to update the programme, the AI returns structured JSON for the affected future sessions. The app validates and updates the persisted programme.

### 5.4 Custom Workout Creation

**Functional requirements**:

- FR-4.1: User can create an arbitrarily structured workout with no AI involvement.
- FR-4.2: Exercises can be selected from the cached library OR added as fully custom.
- FR-4.3: Custom exercises require: name, primary body parts (multi-select from the 14-bucket taxonomy), step-by-step instructions (array of strings, min 1 step), optional video URL, optional equipment tags. `force` defaults to `null`; `mechanic` defaults to `null`; the user can set them. Audio is auto-generated per step via TTS.
- FR-4.4: Custom exercises are stored in the same local DB table as Firebase-synced exercises, with `source = 'custom'`.
- FR-4.5: For each exercise in a custom workout: target sets, target reps (or rep range), target weight (optional), rest time (min 30s).
- FR-4.6: User can save the workout as a one-off OR save as a template for reuse OR build a custom multi-week program manually.
- FR-4.7: Custom programs and one-off custom workouts are saved to the Programs Library with `source = 'custom'`.


#### 5.4.1 v1.5 Custom Builder Parity

Manual custom workouts and custom programmes must support the same persistence capabilities as AI-generated outputs where relevant.

**Functional requirements**:

- FR-4.8: User can create supersets inside manual custom workouts and custom programmes at any experience level, including beginner.
- FR-4.9: Superset groups must support group label, exercise order inside the group, rest between exercises, and rest after the group.
- FR-4.10: User can mark every prescribed set as `warmup` or `working`.
- FR-4.11: User can edit reps, weight, duration, distance, RPE/RIR target, rest time, set type, and notes per set.
- FR-4.12: User can duplicate, delete, reorder, and insert sets.
- FR-4.13: User can manually add warm-up sets and may use an optional helper to estimate warm-up loads from a working set.
- FR-4.14: Custom multi-week programmes can use reusable workout templates, weekly schedules, deload weeks, supersets, and set-level prescriptions.
- FR-4.15: User-created custom exercises may be used by AI generation only when the app includes them in the candidate list with a valid local `exercise_id`, name, muscle groups, equipment, modality, and difficulty/experience metadata. The AI must not invent custom exercises.

### 5.x Programs Library (Unified, Three On-Ramps)

**Functional requirements**:

- FR-X.1: Single screen under the Programs tab. Shows two segmented sections: **Programs** (multi-week plans) and **Saved Workouts** (one-off workouts not tied to a program).
- FR-X.2: Each row shows: name, **source badge** (`AI-generated` / `AI-chat` / `Custom`), goal tags, weeks (programs only), creation date, "Active" indicator if currently scheduled, "Completed" if applicable.
- FR-X.3: Filters: All / AI-generated / AI-chat / Custom. Sort: most recent / alphabetical / longest.
- FR-X.4: Tap → program detail screen (week calendar) or workout detail screen.
- FR-X.5: Actions per row: Set Active, Duplicate, Edit, Delete, Share. Share opens the v1.7 export flow, not raw JSON export.
- FR-X.6: Only one program can be "Active" at a time. Activating one deactivates the previous active program with a confirmation dialog.
- FR-X.7: Search by program/workout name.
- FR-X.8: **Chat on-ramp**: workouts and programmes created via the chat-to-library save flows (FR-8.11 / FR-8.12) appear here with `source = 'ai-chat'`. Indistinguishable in function from other sources; the badge is the only visible difference.
- FR-X.9: Programmes created by AI may store an `ai_generation_snapshot_json` locally for review/debugging. This snapshot must never be sent to Crashlytics, sharing exports, PDFs, or any telemetry sink.
- FR-X.10: Programs Library toolbar includes **Import Plan File**. Import accepts `.aedifyplan` files only in v1 and runs deterministic local validation before save.

### 5.5 Workout Execution

**Functional requirements**:

- FR-5.1: User taps "Start" on a scheduled workout (from active program) or any saved workout.
- FR-5.2: Step-through UI: one exercise per screen with embedded video (streamed), text instructions, "Play audio" button, and muscle diagram (local SVG).
- FR-5.3: For each set: weight input, reps input, optional RPE (1–10), optional RIR (0–5), optional notes per set.
- FR-5.4: After logging a set, a rest timer auto-starts using the prescribed rest time. Audible alarm + haptic on completion.
- FR-5.5: User can: skip a set, swap an exercise mid-workout (via `EXERCISE_SWAP` flow), add an extra set, end workout early.
- FR-5.6: On workout completion: summary screen (total volume, time, exercises completed, PRs detected), optional post-workout note, sync to Health platform. Plateau-detection task is triggered.
- FR-5.7: Workouts in progress survive app backgrounding and crashes (state persisted to disk after every set log).


#### 5.5.1 Superset Execution UX (v1.5)

When exercises share an `execution_group.group_key` and `execution_group.mode = 'superset'`, the workout player must:

- display the exercises as one grouped card with a clear label such as `Superset A`;
- show each exercise's position inside the group;
- guide the user through Exercise 1 → Exercise 2 → rest after group;
- support rest between exercises and rest after the group;
- allow skipping one exercise without deleting or skipping the whole group;
- preserve group order during logging;
- show completion status per exercise and per group.

AI-generated beginner workouts/programmes must not include supersets. Manual custom beginner workouts/programmes may include supersets. For v1 AI-generated supersets, exercises in the same superset must have matching working-set counts. Asymmetric supersets are deferred unless manually created by the user.

### 5.6 Lift Log

**Functional requirements**:

- FR-6.1: All workout-execution data writes to a normalized lift log table.
- FR-6.2: Log entries are immutable by default but editable from the history view.
- FR-6.3: Logged data per set: exercise ID, date/time, weight, reps, RPE, RIR, notes, workout ID (FK), set number, and `set_type` (`warmup` / `working`).
- FR-6.4: e1RM is computed per logged set using the **Epley formula**: `e1RM = weight × (1 + reps/30)`, valid for reps ≤ 10. For reps > 10, e1RM is flagged as low-confidence.
- FR-6.5: PR detection runs on logged `working` sets by default. Warm-up sets are excluded from PR detection, e1RM, plateau detection, progression triggers, and default volume analytics.
- FR-6.6: A "log without workout" entry mode exists for standalone logging. Entries from this mode feed plateau detection the same as any other source.

### 5.7 Analytics and Progress Tracking

**Functional requirements**:

- FR-7.1: Dashboard with at-a-glance stats.
- FR-7.2: **Per-workout analytics**.
- FR-7.3: **Per-exercise analytics**: e1RM over time, top set, total volume, all logged sets.
- FR-7.4: **Week-over-week comparison**.
- FR-7.5: **Body measurement charts**.
- FR-7.6: Shared chart component (`fl_chart`).
- FR-7.7: Export analytics as CSV.

#### 5.7.1 Plateau Detection

**Source-agnostic**: runs against the `set_logs` table regardless of workout source (AI-generated / AI-chat / custom / standalone log).

**Functional requirements**:

- FR-7.1.1: Background analytics task after every `set_log` write.
- FR-7.1.2: For each exercise logged in the last 4 weeks with at least 4 sessions, compute a rolling 3-session e1RM trend.
- FR-7.1.3: Plateau flagged if slope ≤ 0 and no deload week within those sessions.
- FR-7.1.4: Notification delivered (if enabled) + banner on dashboard.
- FR-7.1.5: Tapping the banner opens AI Trainer with the `PLATEAU_SUGGESTION` per-call prompt pre-populated.
- FR-7.1.6: Plateau flags can be dismissed; dismissed flags do not re-trigger for 14 days.
- FR-7.1.7: Detection runs in pure Dart (offline). Only AI suggestion requires connectivity.


#### 5.7.2 Warm-up vs Working Set Analytics (v1.5)

Default analytics use `working` sets only for PR detection, e1RM, plateau detection, progression triggers, top-set charts, default volume charts, and week-over-week strength trends.

Warm-up sets remain visible in session history and workout detail, but they do not affect strength analytics unless a future optional view explicitly includes total work including warm-ups.

### 5.8 AI Trainer Chat

**Functional requirements**:

- FR-8.1: Persistent chat interface accessible from home and contextual entry points.
- FR-8.2: Messages routed to the user's configured AI provider.
- FR-8.3: Each chat call assembles its system message from the instruction-set sections routed to `AI_TRAINER_CHAT` (TONE, IDENTITY, ATHLETE PROFILE, LIFT LOG, REFERENCE FILES, PROGRAMMING RULES, HOW TO RESPOND); the user message is the athlete's typed text.
- FR-8.4: Reference file selection is context-aware (1–3 most relevant per the keyword index in §9.4).
- FR-8.5: User can manually attach context.
- FR-8.6: Chat history persisted locally. Can be cleared.
- FR-8.7: Each response shows estimated token usage + approximate USD cost.
- FR-8.8: When offline, chat input is disabled.
- FR-8.9: Streaming responses supported where the provider supports SSE.
- FR-8.10: **Provider switch retains chat history**: prior turns serialized as plain text to the new provider.
- FR-8.11: **Chat → Saved Workout flow**: when the AI generates a session inline and the user explicitly requests to save it (button tap or natural-language "save that workout"), the app sends a follow-up structured save call. AI returns JSON; app validates exercise IDs and set-level prescriptions; persists to Saved Workouts with `source = 'ai-chat'`.
- FR-8.12: **Chat → Saved Programme flow** (new in v1.5): when the AI discusses or drafts a multi-week programme in chat and the user explicitly requests to save it, the app sends a follow-up structured save call using `chat_saved_programme_json`. AI returns template-based programme JSON; app validates, expands, and persists to Programs Library with `source = 'ai-chat'`. Chat-generated programmes are never persisted automatically.

### 5.9 Profile Management and Editing

**Functional requirements**:

- FR-9.1: Settings → Profile lets the user edit any captured field.
- FR-9.2: Settings → AI lets the user change provider, key, model.
- FR-9.3: Settings → Reference Files lists bundled reference files with toggles to include/exclude from AI context.
- FR-9.4: Settings → Data lets the user export all data as JSON, delete all data (with double-confirmation), or refresh the exercise library.
- FR-9.5: Editing max lifts triggers a non-blocking prompt to update the active program.

### 5.10 Notifications

**Functional requirements**:

- FR-10.1: Opt in during onboarding or from Settings.
- FR-10.2: Notification types: workout reminders, plateau alerts, streak preservation, deload reminders, progress media reminders.
- FR-10.3: Each type toggleable independently.
- FR-10.4: `flutter_local_notifications`.
- FR-10.5: Progress media reminders are scheduled only after the first saved progress media session and use the cadence selected by the user.

### 5.11 Health Platform Integration

**Functional requirements**:

- FR-11.1: Opt in during onboarding or Settings.
- FR-11.2: iOS via Apple Health (`health` package + HealthKit entitlement).
- FR-11.3: Android via Health Connect (`health` package).
- FR-11.4: Write on workout completion: type, duration, active calories, exercise list summary.
- FR-11.5: Read: bodyweight, body fat %, height.
- FR-11.6: Permissions requested incrementally.

### 5.12 Progress Media Tracking and Optional AI Physique Analysis (v1.9)

This replaces the earlier progress-photo-only requirement with a richer progress media system. It supports visual progress tracking through photos and videos and an optional AI analysis layer.

#### 5.12.1 Progress media capture

**Functional requirements**:

- FR-12.1: Users can capture or import a **progress photo set**.
- FR-12.2: A recommended complete photo set contains four poses:
  - `front`
  - `back`
  - `left_side`
  - `right_side`
- FR-12.3: Users can capture or import a **progress video** that captures all sides.
- FR-12.4: Users can save photos only, video only, or both in one progress media session.
- FR-12.5: Full four-pose photo sets are recommended, but partial sessions may be saved and marked as incomplete.
- FR-12.6: Videos should have a configurable max duration, with a v1.9 recommendation of 30–60 seconds to control local storage usage.
- FR-12.7: Each progress media session is timestamped and can optionally attach current bodyweight, body-measurement snapshot, and notes.
- FR-12.8: The first saved progress media session is marked as the baseline by default unless the user changes it later.
- FR-12.9: Users can delete individual media items or full sessions. Deletion removes local files and database references.
- FR-12.10: The app should show capture guidance:
  - use similar lighting;
  - use similar camera distance/height;
  - use similar clothing;
  - use the same poses;
  - use a similar time of day where possible.

#### 5.12.2 Progress media reminders

**Functional requirements**:

- FR-12.11: The app does not schedule progress media reminders before the first saved progress media session.
- FR-12.12: After the first saved progress media session, the app asks the user to choose a reminder cadence:
  - `two_weeks`
  - `monthly`
  - `three_months`
  - `off`
- FR-12.13: Progress media reminders are local notifications only.
- FR-12.14: Users can change cadence or disable reminders from Progress settings and Settings → Notifications.
- FR-12.15: If the user records a new progress session before the reminder date, the next reminder resets from the new session date.
- FR-12.16: Reminder actions should support `Take progress media`, `Snooze`, and `Skip this reminder` where platform support allows.

#### 5.12.3 Progress media comparison

**Functional requirements**:

- FR-12.17: Users can view a progress media timeline.
- FR-12.18: Users can compare baseline vs latest.
- FR-12.19: Users can compare any two dates.
- FR-12.20: Photo comparison should match the same pose where possible: front-to-front, back-to-back, left-side-to-left-side, right-side-to-right-side.
- FR-12.21: Video sessions should support playback and thumbnail preview.
- FR-12.22: Progress media can be filtered by media type, pose, and date.

#### 5.12.4 Optional AI physique analysis

AI physique analysis is an optional layer on top of progress media. It is not run automatically.

**Functional requirements**:

- FR-12.23: Users can explicitly run AI analysis on a selected progress photo set, progress video, or both.
- FR-12.24: Before AI analysis, the app must show a consent screen explaining that selected media or extracted frames will be sent to the user's configured BYOK AI provider.
- FR-12.25: For videos, the default behavior is to extract a small set of canonical frames locally where possible instead of sending the full raw video.
- FR-12.26: Canonical video frames should correspond to front, back, left-side, and right-side views where possible.
- FR-12.27: If canonical frames cannot be detected locally, the app may ask the user to select representative frames manually, or it may send a short clipped segment only after explicit confirmation.
- FR-12.28: The AI returns a structured analysis snapshot using `progress_physique_analysis_json`.
- FR-12.29: Body-fat estimation must be shown as a rough range, not a precise number. Example: `16–19%`, confidence `medium`.
- FR-12.30: The AI may provide:
  - overall summary;
  - rough body-fat range and confidence;
  - visible muscularity observations;
  - symmetry and proportion observations;
  - conditioning/leanness observations;
  - strengths;
  - lagging areas;
  - baseline-vs-latest comparison;
  - previous-vs-latest comparison;
  - recommended training/nutrition focus areas;
  - benchmark-style notes for the user's stated goal.
- FR-12.31: The AI must not provide medical diagnosis, disease claims, eating-disorder coaching, attractiveness scoring, moral judgments, insults, or shaming language.
- FR-12.32: The app stores AI physique analysis results locally only.
- FR-12.33: Users can delete AI analysis snapshots independently of media, or delete media and linked analyses together.

#### 5.12.5 Privacy and export restrictions

**Functional requirements**:

- FR-12.34: Progress photos, videos, thumbnails, extracted frames, and AI physique-analysis results are stored locally by default.
- FR-12.35: Progress media is never sent to AI unless the user explicitly starts AI analysis and consents.
- FR-12.36: Progress media and analysis results must never be sent to Crashlytics.
- FR-12.37: Progress media and analysis results must never be included in `.aedifyplan` exports, PDF plan exports, external import drafts, AI prompt logs, or default data-sharing flows.
- FR-12.38: Full app data export may include progress media metadata, but raw media export must be an explicit user action if supported.
- FR-12.39: No cloud backup or sync of progress media is in scope for v1.9.

### 5.13 Body Measurements and Bodymap Rendering

**Functional requirements**:

- FR-13.1: User can log: bodyweight, body fat %, waist, chest, hip, left/right arm, left/right thigh, neck.
- FR-13.2: Timestamped.
- FR-13.3: Bodyweight syncs with Health platform if integration enabled.
- FR-13.4: Charts over time.
- FR-13.5: **Bodymap rendering** (new in v1.3, in scope): exercise detail and analytics screens show a muscle-highlight diagram rendered from local SVG assets (one male, one female, front and back views each). The `muscle_groups` of an exercise drive which SVG paths get highlighted. See §7.7 for pipeline details.

### 5.14 Plan Sharing (v1.7)

Plan sharing is **local export/import**, not cloud or social sharing. It must preserve the app's local-only, offline-first, no-account architecture.

#### 5.14.1 Supported share content

**Functional requirements**:

- FR-14.1: User can share a saved workout.
- FR-14.2: User can share a multi-week programme.
- FR-14.3: User cannot share completed workout logs, active progress, PR history, bodyweight history, body measurements, progress photos, injuries, substitutions, chat history, AI prompts, raw AI responses, candidate exercise lists, API keys, or `ai_generation_snapshot_json`.
- FR-14.4: Shared content represents the plan/template only. Completion state and workout history are never included.
- FR-14.5: Imported plans are saved inactive by default. The recipient must manually activate them.

#### 5.14.2 Export formats

The Share action presents a format picker:

| Format | Purpose | Importable? | Notes |
|---|---|---:|---|
| `.aedifyplan` | App-native structured plan file | Yes | Temporary extension until final app name is chosen. |
| `.pdf` | Human-readable programme/workout document | No | For recipients who do not have the app. |
| Both | Share app-native file and PDF together | `.aedifyplan` only | App passes both generated local files to the OS share sheet. |

**Functional requirements**:

- FR-14.6: `.aedifyplan` is the temporary app-native share extension.
- FR-14.7: Internal share schema uses `share_schema_version = 1`.
- FR-14.8: The file extension may be renamed later when the app name is finalized; import must rely on schema validation, not extension alone.
- FR-14.9: PDF generation happens fully on-device from local workout/programme data.
- FR-14.10: No hosted links, cloud-hosted PDFs, public share pages, accounts, or backend service are introduced for sharing.

#### 5.14.3 Privacy modes

Sharing supports two privacy modes:

| Mode | Default? | Behavior |
|---|---:|---|
| `template` | Yes | Shares structure, reps, RPE/RIR, rest, progression, warm-up rules, supersets, and notes. Avoids exact strength-revealing loads where possible. |
| `exact_prescription` | No | Includes exact prescribed loads in the prescription summary. Requires explicit warning before export. |

**Functional requirements**:

- FR-14.11: Template export is the default.
- FR-14.12: Exact prescription export shows a privacy warning: "This export includes exact prescribed weights, which may reveal your strength level. Only share it with people you trust."
- FR-14.13: Exact prescription values appear in the workout prescription summary, not as filled-in actual performance logs.

#### 5.14.4 `.aedifyplan` share schema

The app-native file is JSON with this top-level shape:

```json
{
  "share_schema_version": 1,
  "exported_at": "2026-06-07T12:00:00Z",
  "app": {
    "name": "Aedify",
    "export_format": "aedifyplan",
    "app_version": "1.7.0"
  },
  "content_type": "program",
  "privacy_mode": "template",
  "content": {},
  "exercise_resolution": {
    "dataset_schema_version": 1,
    "exercise_dataset_version": "2026-05-10",
    "custom_exercises": []
  },
  "source_metadata": {
    "source": "ai-generated",
    "imported": false,
    "training_style": "strength_hypertrophy",
    "reference_files_used": ["aedify-09-powerbuilding-strength-hypertrophy.md"],
    "source_integrity_note": "Generated from high-level principles only; no source programme tables or proprietary layouts are included."
  }
}
```

Allowed `content_type` values:

```text
program
saved_workout
```

Allowed `privacy_mode` values:

```text
template
exact_prescription
```

**Functional requirements**:

- FR-14.14: `.aedifyplan` preserves app-specific structure including exercise IDs, set-level prescriptions, warm-up/working set labels, supersets, RPE/RIR targets, rest, progression rules, deload rules, workout templates, weekly schedules, and custom exercise definitions.
- FR-14.15: The exported file must not contain private profile data, logs, active progress, AI snapshots, prompts, raw AI responses, candidate lists, injuries, photos, measurements, or API keys.
- FR-14.16: Unsupported `share_schema_version` values are rejected unless the app includes a compatible local migration.

#### 5.14.5 PDF export

PDF export is a read-only human document. It is designed to let a recipient follow and manually log the plan even if they do not have the app.

For a multi-week programme, PDF structure should be:

1. Cover page.
2. Programme overview.
3. Weekly schedule.
4. Workout templates.
5. Progression rules.
6. Deload rules.
7. Workout prescription summaries.
8. Printable/open workout logging tables.
9. Optional exercise-instructions appendix.
10. Privacy + safety disclaimer.

For a saved workout, PDF structure should be:

1. Workout overview.
2. Prescription summary.
3. Printable/open workout logging table.
4. Superset group notes, if applicable.
5. Optional exercise-instructions appendix.
6. Privacy + safety disclaimer.

**Functional requirements**:

- FR-14.17: PDF exports include workout tables for manual progress logging.
- FR-14.18: The prescription summary appears before the logging table for each workout/day.
- FR-14.19: In exact-prescription PDFs, exact prescribed loads appear in the prescription summary.
- FR-14.20: Actual log columns remain blank so the PDF recipient can record actual weights, reps, RPE, and notes.
- FR-14.21: PDF workout tables must support exercise, set number, set type, target reps, target RPE/RIR, blank actual weight, blank actual reps, blank actual RPE, and notes.
- FR-14.22: Supersets must be visibly grouped in the PDF with labels such as `Superset A`, exercise order (`A1`, `A2`), rest between exercises, and rest after group.
- FR-14.23: Warm-up sets and working sets must be clearly labeled in PDF tables.
- FR-14.24: PDF exports must never include raw AI prompt text, raw AI responses, candidate lists, chat history, API keys, user profile data, injuries, progress photos, body measurements, completed workout logs, PR history, or `ai_generation_snapshot_json`.

Example PDF log-table columns:

| Exercise | Set | Type | Target reps | Target RPE/RIR | Actual weight | Actual reps | Actual RPE | Notes |
|---|---:|---|---:|---|---|---|---|---|
| Barbell Squat | 1 | Warm-up | 5 | Easy |  |  |  |  |
| Barbell Squat | 2 | Warm-up | 3 | Easy |  |  |  |  |
| Barbell Squat | 3 | Working | 5 | RPE 7–8 |  |  |  |  |
| Barbell Squat | 4 | Working | 5 | RPE 7–8 |  |  |  |  |

#### 5.14.6 Optional exercise-instructions appendix

The exercise-instructions appendix is optional and off by default.

**Functional requirements**:

- FR-14.25: Export flow includes a toggle: **Include exercise instructions appendix**.
- FR-14.26: Default toggle state is off.
- FR-14.27: Appendix may include exercise setup, step-by-step instructions, coaching cues, and simple notes for each exercise.
- FR-14.28: Appendix must not include source-reference excerpts, AI prompts, raw AI responses, or proprietary source material.
- FR-14.29: UI copy warns that enabling the appendix may make the PDF much longer.

#### 5.14.7 Import behavior

**Functional requirements**:

- FR-14.30: App can import `.aedifyplan` files.
- FR-14.31: Import validation is deterministic and local. AI is not required for import.
- FR-14.32: Import preview shows plan name, content type, duration, source, training style, schedule, privacy mode, exercise resolution status, and whether custom exercises will be created.
- FR-14.33: Imported plans are inactive by default.
- FR-14.34: Imported plans are editable local copies. No link to the sender remains.
- FR-14.35: Imported source provenance is preserved as `imported = true` and `original_source`.
- FR-14.36: UI displays imported labels such as `Imported · AI-generated`, `Imported · AI-chat`, or `Imported · Custom`.

Exercise resolution order:

1. Match by `exercise_id` against the local exercise library.
2. If ID exists and name roughly matches, accept.
3. If ID is missing or dataset version is different, fallback to name + equipment + muscle groups + modality.
4. If no safe match exists, require user replacement before save.
5. If the share includes a custom exercise definition, create a new local custom exercise and map plan prescriptions to that new local ID.

Reject import if:

- `share_schema_version` is unsupported and cannot be migrated locally;
- `content_type` is not `program` or `saved_workout`;
- required fields are missing;
- programme duration is invalid;
- set-level prescriptions are malformed;
- warm-up sets appear after working sets;
- warm-up percentage rules are violated where they apply;
- superset groups are malformed;
- imported AI-generated beginner plans contain supersets;
- exercises cannot be resolved and the user refuses replacement;
- file includes private data that should never be shared.

#### 5.14.8 Custom exercises in shared plans

If a shared plan contains custom exercises, the app-native export includes the full local definition needed for import:

```json
{
  "custom_exercises": [
    {
      "export_exercise_key": "custom_1",
      "name": "Band-Assisted Tempo Split Squat",
      "muscle_groups": ["Quads", "Glutes"],
      "equipment": ["Band"],
      "modality": "strength",
      "mechanic": "Compound",
      "force": "Push",
      "steps": ["..."],
      "video_url": null
    }
  ]
}
```

On import, the app creates a new local exercise ID, marks the exercise as custom/imported, and rewrites plan prescriptions to reference the new local ID.

#### 5.14.9 Powerbuilding source-integrity rule for sharing

For powerbuilding-derived plans, exports may include only generated plan data and high-level metadata. They must not include source excerpts, copied programme tables, branded phase layouts, proprietary week-by-week layouts, or exact source exercise sequences.

Allowed metadata:

```json
{
  "training_style": "strength_hypertrophy",
  "reference_files_used": ["aedify-09-powerbuilding-strength-hypertrophy.md"],
  "source_integrity_note": "Generated from high-level principles only; no source programme tables or proprietary layouts are included."
}
```

---



### 5.15 AI-Assisted External Programme / Workout Import (v1.8)

External import lets users bring programmes or workouts written outside the app into the local Programs Library / Saved Workouts Library with AI assistance.

This is separate from v1.7 `.aedifyplan` import:

- `.aedifyplan` import is deterministic, app-native, and does not require AI.
- External file import is AI-assisted because source files may be unstructured, inconsistent, or written in different table formats.

#### 5.15.1 Supported source types

FR-15.1: v1.10 supports these external import source types:

```text
PDF — text-based only
TXT
MD
XLSX
CSV
PNG
JPG / JPEG
WEBP
HEIC / HEIF where platform-supported
```

FR-15.2: OCR, scanned PDFs, image-only PDFs, encrypted PDFs, corrupted PDFs, and cloud-hosted import links remain out of scope. Direct image files/screenshots are supported only through the v1.10 image/screenshot import path.

FR-15.3: If a PDF cannot be read as text/tables, show:

```text
This PDF appears to be scanned, image-only, encrypted, or unreadable. OCR is not supported in this version. Please use a text-based PDF, TXT, MD, XLSX, or CSV file.
```

#### 5.15.2 Import consent and AI processing

FR-15.4: Before sending extracted content to AI, the app must show an AI-processing consent screen.

Consent copy:

```text
AI-assisted import

The app will extract programme-relevant text and tables from this file and send them to your selected AI provider to convert them into an editable workout or programme draft.

Do not continue if the file contains private information you do not want sent to your AI provider.

The app will not send your API key, lift logs, body measurements, progress photos, chat history, or full profile as part of this import.

Continue?
```

FR-15.5: If the user cancels consent, no AI call is made and import stops.

FR-15.6: The app sends only programme-relevant extracted content to the AI provider. It must not send unrelated file metadata, user profile, injuries, lift logs, body measurements, progress photos, chat history, API keys, AI prompts, or AI internals unless explicitly required by a later user-triggered adaptation flow.

#### 5.15.3 Extraction behavior

FR-15.7: The app performs local extraction before AI processing:

| File type | Extraction behavior |
|---|---|
| Text-based PDF | Extract text, tables, page references/headings where available. |
| TXT | Extract raw text. |
| MD | Extract raw text, headings, and markdown tables. |
| XLSX | Extract sheet names, rows/columns, table regions, and merged-cell text where available. |
| CSV | Extract headers, rows, and detected columns. |

FR-15.8: Sheet names in XLSX must be preserved because they may represent weeks, days, phases, or blocks.

#### 5.15.4 Extract vs adapt

FR-15.9: Default import behavior is **extract, normalize, and structure**.

FR-15.10: The AI must preserve the source programme/workout as closely as possible. It must not silently:

```text
change exercises
add weeks
change training days
change goals
rewrite progression
add deloads
adapt to user injuries
automatically adapt to user equipment
convert the plan into a different training style
```

FR-15.11: Adaptation to the user profile is a separate, later user-triggered AI action, not part of default import.

#### 5.15.5 Duration and content detection

FR-15.12: External imported programmes may be shorter than the normal AI-generated 8-week minimum when the source file is shorter.

Examples:

```text
Source defines 4 weeks → import 4 weeks.
Source defines 6 weeks → import 6 weeks.
Source defines 12 weeks → import 12 weeks.
Source defines one session → import as saved workout.
```

FR-15.13: The normal `>= 8 weeks` rule still applies when the app is generating a new AI programme from scratch.

FR-15.14: The AI must classify imported content as:

```text
program
saved_workout
unknown
```

FR-15.15: If classification is `unknown`, the app asks the user:

```text
I found workout content, but I’m not sure whether this should be imported as a single workout or a programme.

Import as:
1. Saved workout
2. Programme
```

#### 5.15.6 Exercise matching and resolution

FR-15.16: Exercise matching runs after the AI returns the structured import draft.

FR-15.17: Matching order:

1. Exact normalized match.
2. Alias/common-name match.
3. Fuzzy + metadata match.
4. User resolution for no match.

FR-15.18: Normalization should ignore case, punctuation, pluralization, repeated spaces, and common symbols.

FR-15.19: Alias matching should support common abbreviations such as:

```text
BB = Barbell
DB = Dumbbell
OHP = Overhead Press
RDL = Romanian Deadlift
DL = Deadlift
Lat Pulldown = Pulldown variant
```

FR-15.20: Exact normalized and high-confidence alias matches may auto-match, but must still be shown in review.

FR-15.21: Ambiguous/fuzzy matches require user confirmation before save.

FR-15.22: Unmatched exercises must be resolved before save. The user must choose one:

```text
Match to existing exercise
Create as custom exercise
Remove from imported programme/workout
```

FR-15.23: The app must not silently guess low-confidence matches.

#### 5.15.7 Custom exercise creation for unmatched imports

FR-15.24: When the user chooses **Create as custom exercise**, AI may prefill metadata from the file context, but the user must confirm all required fields.

Required custom-exercise fields:

```text
name
modality
equipment
primary muscle group(s)
difficulty / experience level
```

Optional fields:

```text
mechanic
force
instructions / steps
coaching cues
notes
video URL
```

FR-15.25: The app generates the local custom exercise ID. The AI must never generate local database IDs.

FR-15.26: Custom exercises created through import can later be used by AI only when candidate-listed with valid local metadata.

#### 5.15.8 Units and missing data

FR-15.27: If the file clearly specifies kg or lb, parse values, convert to canonical kg for persistence, and display according to user preference.

FR-15.28: If weights are present but units are missing, ask the user before saving:

```text
This file includes weights, but it does not specify whether they are kg or lb. Which unit should be used for this import?
```

Options:

```text
kg
lb
Import without weights
Cancel import
```

FR-15.29: If the file contains mixed units, ask the user to confirm detected units before save.

FR-15.30: The AI may infer non-critical structure such as exercise grouping, day names, week numbers, set order, focus tags, equipment from exercise names, and muscle groups from matched local exercises.

FR-15.31: The AI must flag missing or unclear critical fields for review:

```text
missing units
unclear exercise names
missing progression rules
missing rest times
unclear week/day structure
ambiguous supersets
unclear warm-up vs working set labels
```

FR-15.32: The AI should not invent extra weeks, training days, deload weeks, progression models, new exercises, user-specific substitutions, injury adaptations, or exact weights where none exist.

#### 5.15.9 Supersets, warm-up sets, and imported complexity

FR-15.33: The importer should recognize common superset/circuit notation:

```text
A1 / A2
B1 / B2
SS1
Superset
Circuit
Giant set
```

FR-15.34: Clear supersets are preserved using the existing `execution_group` model. Ambiguous grouping is flagged for user review.

FR-15.35: Imported supersets may exist regardless of user experience because they come from an external source, but beginner users should see a warning before activating a complex imported plan:

```text
This imported plan includes supersets. Supersets can make workouts more complex. Review the plan carefully before activating it.
```

FR-15.36: Preserve warm-up labels when the source file clearly identifies warm-up sets.

FR-15.37: If all sets are listed together and no warm-up labels are present, treat them as working sets unless the source clearly indicates otherwise.

FR-15.38: Imported warm-up sets are excluded from PRs, e1RM, plateau detection, progression, and default analytics, same as app-generated warm-up sets.

#### 5.15.10 Save behavior and export compatibility

FR-15.39: Imported programmes save inactive by default.

FR-15.40: Imported workouts save to the Saved Workouts Library.

FR-15.41: Imported items use:

```text
source = custom
creation_method = ai_file_import
import_origin = external_file
imported = true
```

FR-15.42: UI label:

```text
Imported · External file
```

FR-15.43: Original source files are not stored by default.

FR-15.44: Imported external plans can later be exported as `.aedifyplan`, PDF, or both, but exports must not include original source-file content, source PDF pages, copied notes, branded source tables, AI extraction snapshots, prompts, raw AI responses, candidate lists, profile data, logs, injuries, measurements, photos, or API keys.

FR-15.45: Powerbuilding and other source-sensitive imported plans must preserve the existing source-integrity guardrails.


#### 5.15.11 Image / Screenshot Import (v1.10)

FR-15.46: Users can import one or more image files/screenshots as a source for an external programme or saved workout.

FR-15.47: Supported image formats are:

```text
PNG
JPG
JPEG
WEBP
HEIC
HEIF
```

FR-15.48: HEIC/HEIF support is platform-dependent. If unsupported, the app shows a clear unsupported-format message and suggests converting the image to PNG or JPG.

FR-15.49: When multiple images are selected, the app must show a reorder screen before AI processing. User-defined image order becomes the source order.

FR-15.50: The app should assess image quality before AI extraction using signals such as resolution, blur, contrast, brightness, orientation, skew, cropping, visible text density, duplicate images, and image count.

FR-15.51: Suggested image quality statuses:

```text
good
acceptable
poor
unreadable
```

FR-15.52: Poor-quality images should go through readability enhancement before AI extraction where practical.

FR-15.53: Unreadable images should warn the user, allow retry/reselect, and block AI extraction if no useful programme/workout content is visible.

#### 5.15.12 Image Enhancement / Readability Preprocessing (v1.10)

FR-15.54: Image enhancement exists only to improve programme readability before extraction. It must not alter programme meaning.

FR-15.55: Allowed local preprocessing includes:

```text
orientation correction
rotation
crop empty borders
de-skew angled screenshots/photos
brightness correction
contrast improvement
sharpening
noise reduction
resolution upscaling
table/text readability improvement
```

FR-15.56: The app or AI must not:

```text
invent missing text
complete cropped tables
guess unreadable exercises
change numbers
change sets
change reps
change weights
change rest periods
change dates
rewrite notes
silently correct source content
adapt the programme
add missing weeks
add missing days
add missing exercises
```

FR-15.57: Enhancement principle:

```text
Enhanced image improves readability only. The extracted programme remains a draft and must be reviewed by the user before save.
```

FR-15.58: The app should attempt local preprocessing first where possible. AI-assisted image enhancement or interpretation is allowed only when local enhancement is insufficient, the selected BYOK provider/model supports image input, and the user has accepted AI-processing consent.

#### 5.15.13 Multimodal Provider Gating (v1.10)

FR-15.59: Screenshot import requires a provider/model capability check before AI processing.

Suggested provider capability flag:

```text
supports_image_input: bool
```

Optional future capability fields:

```text
supports_image_json_output
supports_multi_image_input
max_image_count
max_image_size_mb
```

FR-15.60: If the selected provider/model does not support image input, show:

```text
Your selected AI provider or model does not support image-based import. Switch to a model that supports image input or use a text-based file instead.
```

FR-15.61: If the selected image count exceeds provider/model limits, show:

```text
You selected more images than this AI provider can process at once. Remove some screenshots or split the import into smaller parts.
```

#### 5.15.14 Image Import Consent (v1.10)

FR-15.62: Before sending screenshots/images or enhanced versions to AI, the app must show AI-processing consent.

Consent copy:

```text
AI screenshot import

The app will send the selected screenshots and, if needed, enhanced versions of those screenshots to your selected AI provider to extract the workout or programme into an editable draft.

Image enhancement is used only to improve readability. The AI must not invent missing text, complete cropped sections, or change the source programme.

Do not continue if the screenshots contain private information you do not want sent to your AI provider. The app will not send your API key, workout logs, injuries, measurements, chat history, or unrelated profile data as part of this import.

Continue?
```

FR-15.63: If the user cancels consent, no AI call is made and image import stops.

FR-15.64: The image import package may include original selected images, locally enhanced images, image order metadata, and import instructions. It must not include API keys, lift logs, injuries, measurements, chat history, full profile, or unrelated private app data.

#### 5.15.15 Image AI Extraction Rules (v1.10)

FR-15.65: The AI must extract only visible programme/workout content.

FR-15.66: The AI must respect user-defined screenshot order and preserve source structure where clear.

FR-15.67: The AI should preserve weeks, days, workouts, exercises, sets, reps, weights, units, rest, RPE/RIR, tempo, supersets, warmups, working sets, progression rules, and deloads when visible.

FR-15.68: The AI must mark unclear values, cropped regions, unreadable regions, and missing important fields rather than guessing.

FR-15.69: The AI must not invent missing screenshots, fill in cropped content, guess unreadable numbers, guess kg vs lb, or convert an unclear programme into a better programme.

FR-15.70: Image imports reuse the existing `external_program_import_json`, `external_workout_import_json`, and `external_exercise_match_json` schemas with additional image import metadata.

FR-15.71: Image imports use the same exercise matching, unit handling, validation, save behavior, export compatibility, and source-integrity rules as text-based external imports.

#### 5.15.16 Image Import Privacy and Temporary Artifact Rules (v1.10)

FR-15.72: Original screenshots are not stored by default.

FR-15.73: Enhanced images are not stored by default.

FR-15.74: Original and enhanced images are temporary import artifacts and should be deleted after import completion, cancellation, or failure.

FR-15.75: Original screenshots, enhanced images, image-processing artifacts, image-source excerpts, AI prompts, and raw AI responses must not be included in `.aedifyplan`, PDF exports, Crashlytics, external import/export flows, AI internals, private app data exports, or source-reference content.

FR-15.76: Persist only the validated structured draft and user-confirmed local plan/workout data.

## 6. Non-Functional Requirements

### 6.1 Offline-First Architecture

| Feature | Online required? | Cached? |
|---|---|---|
| App launch and navigation | No | N/A |
| Exercise library browse | No (after first sync) | Yes — full dataset |
| Exercise detail | No | Yes — full data + per-step audio |
| Exercise video | Yes | No (stream-only) |
| Bodymap rendering | No | Yes — bundled SVG assets |
| Lift log read/write | No | N/A |
| Analytics | No | N/A |
| Plateau detection | No | N/A (computed locally) |
| AI Trainer chat | **Yes** | Last 10 chat history turns cached |
| AI workout generation | **Yes** | Generated workouts cached after creation |
| Programs Library browse | No | Yes |
| Notifications | No (local) | N/A |
| Health platform sync | No (local SDK) | N/A |
| Firebase exercise sync | **Yes** (first time, and on `latest_version` increment only) | Yes — full dataset persisted in Drift |

**Acceptance criteria**:
- ✅ After first launch with sync complete, cold-launching with airplane mode → user can browse the entire library, view any exercise's text + audio, log a workout, view analytics, and use bodymaps.
- ✅ First launch in airplane mode → exercise library remains empty until network returns; custom workouts, lift log, profile, and analytics still work.

### 6.2 Performance

- App cold start: < 2 seconds.
- Library browse: 60 fps with the full catalog.
- Exercise detail: < 100 ms render.
- First-launch sync: ≤ 10 seconds on a stable connection (3.7 MB download + parse + DB insert).
- Subsequent launches: < 200 ms manifest check (no download).
- Lift log write: < 50 ms.
- AI streaming response: visible within 2 seconds.

### 6.3 Privacy and Security

- No behavioural analytics, product analytics, ad tracking, or usage telemetry is sent off-device.
- **Crashlytics exception**: Firebase Crashlytics is enabled for crash diagnostics only. This intentionally sends crash reports off-device because reliable crash analytics are not possible purely on-device. Crash reports must never include API keys, prompt bodies, lift-log contents, health data, or free-form user notes.
- API keys never leave the device.
- Local storage encrypted at rest where the platform supports it.
- Progress photos, progress videos, extracted video frames, thumbnails, and physique-analysis results stored in the app sandbox.
- Firebase Storage access is anonymous and read-only via security rules — no PII transmitted in either direction.
- Privacy policy: "We have no servers. Firebase Storage hosts only the exercise catalog (the same content for all users). Your AI provider may collect data per their own terms — review them. Screenshot/image imports and AI physique analysis send selected media only after explicit consent."


#### 6.3.1 Crashlytics Redaction Rules (v1.5)

Firebase Crashlytics is the explicit exception to the no-telemetry stance, but crash payloads must be strictly redacted. Crash reports must never include:

- API keys;
- prompt text;
- AI responses;
- chat history;
- structured output JSON;
- exercise candidate lists;
- injuries or limitations;
- lift logs or set logs;
- body measurements;
- progress media paths;
- progress photos, videos, thumbnails, extracted frames, or AI physique-analysis results;
- original screenshots, enhanced screenshots, image-processing artifacts, or image import source excerpts;
- local database dumps;
- Firebase Storage URLs that reveal user state.

Allowed crash context is limited to app version, OS version, device model, screen name, non-sensitive feature flags, local schema version, exercise dataset version, error code, and redacted stack traces.

### 6.4 Accessibility

- 48dp/44pt minimum tap targets.
- Full VoiceOver / TalkBack support.
- Dynamic Type / font scaling.
- WCAG AA contrast.
- Audio descriptions of exercises serve as a built-in accessibility win.

### 6.5 Localization (v1)

- English only.
- All user-facing strings via `flutter_intl`.
- Reference files in English; localization deferred to v2.

---

## 7. Technical Architecture

### 7.1 Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Framework | Flutter (latest stable) | Cross-platform, offline-first friendly. |
| Language | Dart | |
| State management | Riverpod, latest validated stable version | Chosen over Provider for stronger testability, async workflow handling, dependency injection, and feature-level state isolation. |
| Local DB (relational) | Drift (SQLite-backed) | |
| Simple local preferences | `shared_preferences` | Non-critical preferences only; not for secrets, relational data, logs, programmes, imports, or progress media. |
| Secure storage | `flutter_secure_storage` | BYOK API keys and other sensitive values only. |
| HTTP | Dio + Retrofit | Dio as base HTTP engine; Retrofit for stable typed REST clients where useful. |
| Firebase | `firebase_core`, `firebase_storage`, `firebase_auth`, `firebase_crashlytics` | Exercise dataset hosting + anonymous auth + crash diagnostics. |
| Charts | `fl_chart` | |
| TTS | `flutter_tts` | On-device, free. |
| Notifications | `flutter_local_notifications` | |
| Health integration | `health` | HealthKit + Health Connect. |
| Video player | `video_player` + `chewie` | |

#### 7.1.1 Package Validation Decision Log

| Area | Decision | Rationale | Boundary |
|---|---|---|---|
| State management | Use Riverpod instead of Provider. | Riverpod is better suited to app-wide asynchronous workflows, feature-level controllers, dependency injection, and testing without tying business logic to `BuildContext`. | Provider remains a valid Flutter option, but is not selected for v1. |
| Local relational storage | Use Drift / SQLite. | The app's durable data is relational: exercises, programmes, workouts, set prescriptions, logs, imports, progress media sessions, and schema versions. | Drift owns durable structured app data and migrations. |
| Simple local preferences | Use `shared_preferences` instead of Hive. | The app only needs simple non-critical key-value preferences outside Drift and secure storage. | Do not store API keys, logs, programmes, import drafts, AI outputs, progress media records, or critical app data in `shared_preferences`. |
| Secure secrets | Use `flutter_secure_storage`. | BYOK API keys must be stored in platform-secure storage and never in shared preferences, Drift, files, logs, or Crashlytics. | Secrets only; non-sensitive app settings remain outside secure storage. |
| HTTP | Use Dio + Retrofit. | Dio handles cancellation, interceptors, uploads/downloads, timeouts, and provider error mapping; Retrofit is useful for stable typed REST-style clients. | Use hand-written Dio adapters where AI provider payloads, streaming, or multipart requests make Retrofit awkward. |

| Encryption (DB) | `sqlcipher_flutter_libs` | |
| SVG rendering | `flutter_svg` | Bodymap pipeline. |

| R-PM-1 | Progress media consumes significant local storage | Medium | Add video duration cap, thumbnails, media delete controls, and storage usage visibility. |
| R-PM-2 | Progress media or analysis leaks through crash reports or exports | Medium | Exclude raw media and analysis results from Crashlytics, `.aedifyplan`, PDF exports, external imports, and default data-sharing flows. |
| R-PM-3 | AI body-fat estimate appears more precise than it is | Medium | Require range output, confidence level, disclaimers, and UI wording that says rough visual estimate. |
| R-PM-4 | AI physique feedback harms user body image | Medium | Neutral language rules, no attractiveness scoring, no shaming, no extreme diet advice, and medical/eating-disorder escalation rules. |
| R-PM-5 | Video analysis is costly or unsupported by some BYOK providers | Low–Medium | Prefer local frame extraction over full video upload and require provider capability checks. |
| R-IMG-1 | Blurry or low-resolution screenshots cause incorrect extraction | Medium | Image quality checks, local readability enhancement, confidence warnings, and user review before save. |
| R-IMG-2 | Cropped programme tables produce incomplete plans | Medium | Flag unreadable/cropped regions and block AI from inventing missing content. |
| R-IMG-3 | Wrong screenshot order corrupts programme structure | Medium | Mandatory reorder screen for multi-image imports; user-defined order becomes source order. |
| R-IMG-4 | Selected BYOK model does not support image input | Medium | Provider/model capability gating and clear fallback message to use a text-based file or compatible model. |
| R-IMG-5 | Image imports cost more than text imports | Low–Medium | Explicit consent before AI call, provider image-count limits, and split-import guidance. |
| R-IMG-6 | Screenshots contain private data | Medium | Consent copy, temporary artifacts, no default storage, no Crashlytics, no exports. |
| R-IMG-7 | Paid/source programme screenshot is re-exported as source content | Medium | Do not store/export original or enhanced images; export only validated local plan data and preserve source-integrity guardrails. |

Removed from v1.2: `shimmer` (no longer needed — exercise detail is always loaded after first sync).

### 7.2 Module Structure

```
lib/
  app/                            # App-level widgets, theming, routing
  core/
    db/                           # Drift schema + DAOs
    network/                      # Dio config, interceptors
    storage/                      # Secure storage wrappers
    firebase/                     # Firebase init, anonymous auth, storage client, Crashlytics init
    constants/
  features/
    onboarding/
    exercise_library/
      sync/                       # Manifest check + bulk download from Firebase Storage
      detail/                     # Detail screen (no longer has bootstrap/lazy-load logic)
    workout_generation/           # AI generation flows
    custom_workout/
    programs_library/             # Unified programs + saved workouts list (3 source badges)
    workout_execution/
    lift_log/
    analytics/
    plateau_detection/
    ai_trainer/                   # Chat
    profile/
    settings/
    notifications/
    health_integration/
    progress_photos/
    body_measurements/
    bodymap/                      # SVG-based muscle highlighting widget
  shared/                         # Reusable widgets, themes, utilities
  ai/
    providers/                    # OpenAI, Anthropic, Gemini adapters
    instruction_set/              # Modular instruction set (sections + routing logic)
    prompts/                      # Per-call user-message templates
    reference/                    # Reference file loader + indexer
assets/
  reference/                      # Bundled .md files (wiki + future)
  bodymaps/                       # SVG anatomical assets (male/female × front/back)
```

### 7.3 Caching Strategy

**Exercise data**: single bulk sync from Firebase Storage; persisted to Drift; manifest-driven invalidation.

**TTS audio**: cached per `(exercise_id, step_index, locale)` on first synthesis.

**AI responses**: not cached (each call is unique by context).

**Reference files**: bundled at build time; loaded into memory at app launch.

**Bodymap SVGs**: bundled in app assets; loaded on-demand into widget cache.

### 7.4 BYOK Provider Abstraction

The app uses a provider abstraction so prompt construction, validation, streaming, token estimation, and pricing display are independent of the selected LLM vendor.

```dart
abstract class AIProvider {
  Future<String> validateKey(String apiKey);
  Stream<String> streamChat({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
    required String model,
    required Map<String, dynamic> options,
  });
  Future<TokenUsage> estimateTokens(String text);
  PricingTable get pricing;
}

class OpenAIProvider implements AIProvider { ... }
class AnthropicProvider implements AIProvider { ... }
class GeminiProvider implements AIProvider { ... }
```

**Provider responsibilities**:

- Validate the user's API key without storing or exposing the raw key outside secure storage.
- Normalize chat streaming into a single app-level `Stream<String>` interface.
- Support model selection and the cheapest default model policy from §5.1.1 / §9.4.
- Estimate token usage before calls where practical so the app can show cost previews.
- Surface provider-specific errors in normalized app error states: invalid key, insufficient credits, rate limit, unsupported model, network failure, and provider outage.
- Never log API keys, prompt bodies, user profile details, lift logs, or provider responses to console, files, or Crashlytics.

Streaming is implemented with SSE-compatible adapters where the provider supports streaming. If a provider's API does not use SSE internally, its adapter must still expose the same app-level stream contract.


#### 7.4.1 Structured Output Capability Handling (v1.5)

Structured-output support is provider-agnostic:

- If the configured provider/model supports native JSON mode or schema mode, the app should use it for app-actionable prompts.
- If native structured output is unavailable, the app uses strict prompt instructions, local validation, and the `STRUCTURED_OUTPUT_REPAIR` flow.
- If a provider repeatedly fails to produce valid structured output, the app shows a provider-specific error and suggests switching model/provider.

### 7.5 Firebase Storage Integration (Runtime)

**Anonymous Firebase auth** is initialized on first app launch and persisted across sessions. The auth token is opaque to the user.

**Storage structure**:

```
gs://{project}.appspot.com/
  └─ exercises/
       ├─ manifest.json           ← read on every launch (small)
       ├─ v1.json                 ← current dataset
       └─ v2.json                 ← (future version, when published)
```

**Manifest format** (final for v1.4):

```json
{
  "latest_version": 1,
  "last_updated_at": "2026-05-10T12:00:00Z",
  "exercise_count": 1902,
  "file_path": "exercises/v1.json",
  "min_app_schema_version": 1
}
```

**Security rules**:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /exercises/{file=**} {
      allow read: if request.auth != null;   // anonymous auth OK
      allow write: if false;                 // dev uploads via service account only
    }
  }
}
```

**Sync flow** (FR-2.1.1 through FR-2.1.7) is implemented in the `exercise_library/sync/` module. The client never writes to Firebase Storage.

**Cost at private 5-user scale**: trivial. Free-tier limits (1 GB storage, 10 GB/month downloads) are not approached.

**Private deployment note**: the architecture is intentionally sized for a private, non-public build. Scaling to a public release is outside the product plan.

### 7.6 Build-Time Data Pipeline

The exercise dataset is produced by a two-step Node.js pipeline that runs on the developer's machine.

**Step 1: `aedify-fetch-musclewiki.js`**
- Reads exercises from the MuscleWiki API.
- Two-phase: paginated list calls per difficulty (4 buckets × ~7 pages each ≈ 28 calls), then detail calls per exercise (1,902 calls).
- Resumable across runs (skips already-fetched IDs).
- Handles 404, 429 (long backoff), 5xx (retry with exponential backoff).
- Writes incrementally to `aedify-musclewiki-exercises.json`.

**Step 2: `aedify-transform-for-firebase.js`**
- Reads `aedify-musclewiki-exercises.json`.
- Applies the transformations specified in §5.2.1.
- Strict mode by default: fails on any unmapped muscle name or category, forcing the mapping tables to stay in sync with whatever MuscleWiki ships.
- Normalizes known typos (e.g., `Medicineball` → `Medicine-Ball`).
- Writes `aedify-musclewiki-exercises.firebase.json` (~3.7 MB indented, ~2.5 MB compact).

**Step 3: Upload**
- Dev uploads `aedify-musclewiki-exercises.firebase.json` to Firebase Storage as `exercises/v{N}.json`.
- Dev updates `exercises/manifest.json` with the new `latest_version` and `file_path`.

The pipeline is not part of the runtime app; it's developer tooling.

### 7.7 Bodymap SVG Pipeline (introduced in v1.3; sourcing resolved in v1.4)

The `bodymap_male` and `bodymap_female` URLs in the MuscleWiki API are always null, so we generate our own muscle-highlight diagrams from bundled SVG assets.

**Assets** (bundled in `assets/bodymaps/`):

- `male-front.svg`
- `male-back.svg`
- `female-front.svg`
- `female-back.svg`

Each SVG has every muscle as a separate path with an `id` matching the 14 UI bucket names (e.g., `id="chest"`, `id="lats"` → renders as part of `back` highlighting).

**Sourcing**: use open-source alternatives as the starting point, then adapt the selected assets into the app's SVG path contract. The chosen source assets must allow redistribution in a private app build and must be documented in the project repository.

The final bundled SVGs must:
- Have separable paths for each of the 14 muscle groups.
- Use stable path IDs that match the app's muscle-group keys.
- Match in visual style across male/female × front/back.
- Avoid embedding unnecessary metadata, external links, or remote dependencies.
- Be checked into the app repository as local assets.

**Flutter widget** (`bodymap/`):

- Accepts `gender`, `view` (front/back), and `highlighted_groups` (array of muscle group names).
- Loads the matching SVG via `flutter_svg`.
- Walks the SVG paths and applies a highlight color to paths whose `id` is in `highlighted_groups`.
- Renders front and back as a flippable view.

**Constraints**:

- Some muscle groups only appear on one view (e.g., Lats from the back; Chest from the front). Highlighting a muscle group whose path doesn't exist in the current view silently no-ops.
- Bodymaps are not a substitute for the muscle group label list — both are shown.

### 7.8 TTS Pipeline

Unchanged from v1.2: `flutter_tts` synthesizes each step to a separate file, cached under `(exercise_id, step_index, locale)`. Sequencer plays files with a 1-second pause between steps and highlights the active step in the UI.

### 7.9 Local Sharing Export / Import Pipeline (v1.7)

Sharing is implemented entirely on-device.

**Export pipeline**:

1. User selects saved workout or programme.
2. User selects export format: `.aedifyplan`, PDF, or both.
3. User selects privacy mode: `template` or `exact_prescription`.
4. App builds a sanitized share model from persisted local programme/workout data.
5. App removes disallowed private fields.
6. App validates the sanitized export payload.
7. App writes a temporary local file.
8. App invokes the native OS share sheet.
9. Temporary files may be deleted after share completion or app cleanup.

**PDF pipeline**:

- Generated locally from the sanitized share model.
- Produces prescription summaries plus printable/open logging tables.
- Optional exercise-instructions appendix is off by default.
- Exact prescribed weights appear only in prescription summaries; logging rows remain blank for actual performance.

**Import pipeline**:

1. User opens `.aedifyplan` file in the app.
2. App parses JSON and validates `share_schema_version`.
3. App validates content type and required fields.
4. App resolves exercise references against the local library.
5. App creates imported custom exercises where needed.
6. App previews imported content and unresolved replacements.
7. User confirms save.
8. App persists imported plan inactive by default.

No AI call is required for import. AI may be used later only if the user asks to modify, regenerate, or adapt the imported plan.

---


### 7.10 AI-Assisted External File Import Pipeline (v1.8)

External file import is implemented as an on-device extraction + BYOK AI parsing + local validation pipeline.

**Pipeline**:

```text
1. User selects supported file.
2. App validates extension/MIME and basic readability.
3. App extracts programme-relevant text/tables locally.
4. App shows AI-processing consent.
5. App sends extracted programme-relevant content to BYOK AI provider.
6. AI returns `external_program_import_json` or `external_workout_import_json`.
7. App validates schema and triggers repair if needed.
8. App performs deterministic exercise matching.
9. App optionally asks AI for difficult match assistance.
10. User resolves ambiguous/unmatched exercises.
11. App previews final imported plan.
12. User saves; imported programme is inactive by default.
```

**Extractor responsibilities**:

| File type | Extractor behavior |
|---|---|
| Text-based PDF | Extract text, tables, headings, page references. |
| TXT | Read raw text. |
| MD | Read raw text, headings, markdown tables. |
| XLSX | Extract sheet names, rows, table regions, merged-cell text where available. |
| CSV | Extract headers and rows. |

**Unsupported file handling**:

- scanned/image-only PDFs;
- encrypted PDFs;
- corrupted files;
- unsupported file extensions;
- cloud-only URLs;
- scanned/image-only PDFs remain out of scope; direct image/screenshot files use the v1.10 image import pipeline.

**Privacy constraint**:

Do not send full local database state, user profile, logs, measurements, injuries, progress photos, AI keys, or chat history as part of import parsing. Send only the extracted programme/workout content needed for conversion.

**Repair behavior**:

The same structured-output repair pattern from §9.8.17 applies to external import outputs. The app gets one automatic repair attempt by default.


### 7.11 Progress Media Capture and AI Physique Analysis Pipeline (v1.9)

Progress media remains local by default.

Capture/import pipeline:

```text
Camera or gallery import
  → normalize local file metadata
  → generate thumbnail
  → optionally attach bodyweight/measurement snapshot
  → save local file path + metadata to Drift
  → update progress media timeline
  → schedule next reminder if enabled
```

AI analysis pipeline:

```text
User selects progress media session(s)
  → App shows AI media-processing consent
  → For photo sets: app prepares selected pose images
  → For video: app extracts representative frames locally where possible
  → App sends selected images/frames to BYOK AI provider
  → AI returns `progress_physique_analysis_json`
  → App validates structured output
  → App stores analysis snapshot locally
```

Rules:

- No automatic background AI analysis.
- No raw media in Crashlytics.
- No raw media or analysis results in plan sharing exports.
- For video, prefer selected/extracted frames over full raw video to reduce cost, latency, and privacy exposure.
- The app should support provider capability checks because not all BYOK providers/models accept image input.


### 7.12 Image / Screenshot External Import Pipeline (v1.10)

Image/screenshot import extends the external file import pipeline with image-specific preprocessing and multimodal provider checks.

**Pipeline**:

```text
1. User selects Images / screenshots as the import source.
2. App validates image extension/MIME and basic readability.
3. App checks the selected BYOK provider/model for image input support.
4. User selects one or more supported images.
5. App shows image thumbnails and, for multiple images, a reorder screen.
6. App assesses image quality.
7. App applies local readability enhancement where needed.
8. App shows enhanced-image preview or quality warning where practical.
9. App shows AI screenshot import consent.
10. App sends the image import package to the image-capable BYOK provider/model.
11. AI returns `external_program_import_json` or `external_workout_import_json` with image import metadata.
12. App validates schema and triggers repair if needed.
13. App performs deterministic exercise matching and optional match assistance.
14. User resolves ambiguous/unmatched exercises and unclear fields.
15. App previews final imported plan.
16. User saves; imported programme is inactive by default.
17. App deletes temporary original/enhanced image import artifacts.
```

**Image import package may include**:

```text
original selected images
locally enhanced images
image order metadata
image quality metadata
enhancement methods applied
import instructions
```

**Image import package must not include**:

```text
API keys
lift logs
injuries
measurements
chat history
full user profile
progress media unrelated to this import
unrelated private app data
```

**Local enhancement responsibilities**:

```text
orientation correction
rotation
crop empty borders
de-skew
brightness/contrast correction
sharpening
noise reduction
upscaling where practical
```

**Temporary artifact rule**:

Original screenshots and enhanced images are temporary import artifacts. They are not stored by default, not exported, and not sent to Crashlytics.


## 8. Data Model

**Units convention**: all weight, length, and dimension values stored in canonical metric (kg, cm). UI display conversion based on `user_profile.preferred_units`.

Drift schema (simplified):

```
exercises                          # Synced from Firebase + local custom records
  id                  int (PK)     # int per source, stored as int for Firebase records
  name                string
  difficulty          enum (novice / beginner / intermediate / advanced)
  primary_muscles     json (array of strings — 45 granular values)
  muscle_groups       json (array of strings — 14 UI bucket values)
  category            string       # raw source value (typo-normalized)
  modality            enum (strength / flexibility / cardio / recovery)
  equipment           string?      # = category if modality='strength', else null
  force               enum? (Push / Pull / Hold)
  mechanic            enum? (Compound / Isolation)
  grips               json (array of strings)
  steps               json (array of strings)
  source              enum ('firebase' | 'custom')
  is_favorite         bool (default false)
  is_substituted      bool (default false)
  substitute_id       int? (FK exercises.id)
  created_at          datetime
  updated_at          datetime

exercise_videos
  id                  string (PK, uuid)
  exercise_id         int (FK exercises.id, ON DELETE CASCADE)
  url                 string
  angle               enum (front / side)
  gender              enum (male / female)
  og_image_url        string

audio_cache
  exercise_id         int (PK, FK exercises.id)
  step_index          int (PK)
  locale              string (PK)
  file_path           string
  generated_at        datetime

library_meta                       # Singleton row
  id                  int (always 1)
  schema_version      int          # of the synced dataset after any local migration
  library_version     int          # from Firebase manifest's latest_version
  last_sync_at        datetime

programs
  id                  string (PK, uuid)
  name                string
  source              enum ('ai-generated' | 'ai-chat' | 'custom')     # three on-ramps
  goal_tags           json (array)
  weeks_total         int
  start_date          date?
  is_active           bool (default false)
  is_completed        bool (default false)
  completed_at        datetime?
  generated_prompt    text?        # for ai-generated reproducibility
  periodisation_model string?      # 'mesocycle_3_plus_1' (default) | 'block_4_4_3_1' | 'linear' | 'undulating'
  created_at          datetime
  updated_at          datetime

program_weeks
  id                  string (PK, uuid)
  program_id          string (FK)
  week_number         int
  is_deload           bool

program_workouts
  id                  string (PK, uuid)
  program_week_id     string (FK)
  day_of_week         enum
  name                string
  estimated_duration  int (minutes)

program_exercises
  id                  string (PK, uuid)
  program_workout_id  string (FK)
  exercise_id         int (FK exercises.id)
  order_index         int
  prescribed_sets     int
  prescribed_reps_min int
  prescribed_reps_max int
  prescribed_weight   real?
  prescribed_weight_pct_1rm real?
  rest_seconds        int

saved_workouts                     # One-off workouts not tied to a program
  id                  string (PK, uuid)
  name                string
  source              enum ('ai-generated' | 'ai-chat' | 'custom')     # three on-ramps
  goal_tags           json (array)
  generated_prompt    text?
  created_at          datetime
  updated_at          datetime

saved_workout_exercises            # Same shape as program_exercises
  id                  string (PK, uuid)
  saved_workout_id    string (FK)
  exercise_id         int (FK)
  order_index         int
  prescribed_sets     int
  prescribed_reps_min int
  prescribed_reps_max int
  prescribed_weight   real?
  rest_seconds        int

workout_sessions                   # Actual executions
  id                  string (PK, uuid)
  program_workout_id  string? (FK)
  saved_workout_id    string? (FK)
  date                datetime
  duration_seconds    int
  notes               text

set_logs
  id                  string (PK, uuid)
  workout_session_id  string? (FK)    # null for "log without workout"
  exercise_id         int (FK)
  set_number          int
  weight              real
  reps                int
  rpe                 real?
  rir                 int?
  notes               text
  is_pr               bool
  e1rm                real
  logged_at           datetime

user_profile                       # Singleton row
  id                  int (always 1)
  display_name        string
  dob                 date?
  sex                 enum? (male / female / not_specified)
  height_cm           real?
  experience_level    enum (beginner / intermediate / advanced)
  bench_1rm           real?
  squat_1rm           real?
  deadlift_1rm        real?
  injuries            text?
  notes               text?
  preferred_units     enum ('metric' | 'imperial')
  default_video_gender enum (male / female)
  default_video_angle  enum (front / side)

body_measurements
  id                  string (PK, uuid)
  date                datetime
  type                enum (bodyweight / body_fat_pct / waist / ...)
  value               real
  unit                enum

progress_photos
  id                  string (PK, uuid)
  date                datetime
  pose                enum (front / side / back)
  file_path           string

chat_messages
  id                  string (PK, uuid)
  role                enum (user / assistant / system)
  content             text
  context_files_used  json (array)
  tokens_in           int
  tokens_out          int
  model               string
  created_at          datetime

plateau_flags
  id                  string (PK, uuid)
  exercise_id         int (FK)
  detected_at         datetime
  dismissed_at        datetime?
  resolved_at         datetime?

ai_provider_config                 # Singleton row
  id                  int (always 1)
  provider            enum
  model               string
  # api_key in flutter_secure_storage, not here
```


### 8.1 v1.5 Programme Template and Set-Level Prescription Additions

v1.5 changes AI-generated programme/workout prescriptions from exercise-level prescriptions to **set-level prescriptions**. This is required for warm-up vs working set classification, superset execution, accurate analytics, and template-based programme expansion.

Additional local tables / fields (simplified):

```
program_workout_templates
  id                         string (PK, uuid)
  program_id                 string (FK programs.id)
  template_key               string
  name                       string
  focus_tags                 json
  estimated_duration_minutes int
  template_role              enum (primary_strength_day / hypertrophy_day / conditioning_day / recovery_day / mobility_day / mixed_day)

program_template_exercises
  id                         string (PK, uuid)
  program_workout_template_id string (FK)
  exercise_id                int (FK exercises.id)
  order_index                int
  block_type                 enum (warmup / main / accessory / conditioning / cooldown / mobility / recovery)
  execution_group_mode       enum (single / superset)
  execution_group_key        string?
  execution_group_label      string?
  position_in_group          int?
  rest_between_exercises_seconds int?
  rest_after_group_seconds   int?
  tempo                      string?
  coaching_cues              json?
  substitution_note          text?
  progression_rule           text?

program_template_exercise_sets
  id                         string (PK, uuid)
  program_template_exercise_id string (FK)
  set_index                  int
  set_type                   enum (warmup / working)
  prescribed_reps_min        int?
  prescribed_reps_max        int?
  duration_seconds           int?
  distance_meters            real?
  weight_prescription_type   enum (absolute / percent_1rm / bodyweight_based / bodyweight_only / not_applicable)
  prescribed_weight          real?
  prescribed_weight_pct_1rm  real?
  bodyweight_multiplier      real?
  prescribed_rpe_min         real?
  prescribed_rpe_max         real?
  prescribed_rir             int?
  rest_seconds               int
  is_calibration_estimate    bool default false
  derived_from_working_set_index int?
  warmup_weight_rule         json?

program_schedule_days
  id                         string (PK, uuid)
  program_id                 string (FK programs.id)
  week_number                int
  day_index                  int
  day_name                   string
  template_key               string
  phase_name                 string?
  is_deload                  bool default false
  week_goal                  text?
  template_modifiers         json?

program_expanded_occurrences
  id                         string (PK, uuid)
  program_id                 string (FK programs.id)
  week_number                int
  day_index                  int
  template_key               string
  program_workout_id         string (FK program_workouts.id)
  generated_from_snapshot_version int
  is_completed               bool default false
```

Existing `program_exercises` and `saved_workout_exercises` keep exercise-level metadata. Add companion set tables:

```
program_exercise_sets
  id                         string (PK, uuid)
  program_exercise_id        string (FK)
  set_index                  int
  set_type                   enum (warmup / working)
  prescribed_reps_min        int?
  prescribed_reps_max        int?
  duration_seconds           int?
  distance_meters            real?
  weight_prescription_type   enum
  prescribed_weight          real?
  prescribed_weight_pct_1rm  real?
  bodyweight_multiplier      real?
  prescribed_rpe_min         real?
  prescribed_rpe_max         real?
  prescribed_rir             int?
  rest_seconds               int
  is_calibration_estimate    bool default false
  derived_from_working_set_index int?
  warmup_weight_rule         json?

saved_workout_exercise_sets
  id                         string (PK, uuid)
  saved_workout_exercise_id  string (FK)
  set_index                  int
  set_type                   enum (warmup / working)
  prescribed_reps_min        int?
  prescribed_reps_max        int?
  duration_seconds           int?
  distance_meters            real?
  weight_prescription_type   enum
  prescribed_weight          real?
  prescribed_weight_pct_1rm  real?
  bodyweight_multiplier      real?
  prescribed_rpe_min         real?
  prescribed_rpe_max         real?
  prescribed_rir             int?
  rest_seconds               int
  is_calibration_estimate    bool default false
  derived_from_working_set_index int?
  warmup_weight_rule         json?
```

Add to `set_logs`:

```
set_type enum('warmup' | 'working') default 'working'
```

Add to `programs` and `saved_workouts` where applicable:

```
ai_generation_snapshot_json json?  # local only; never sent to Crashlytics
ai_output_schema_version int?
source enum('ai-generated' | 'ai-chat' | 'custom')
```



### 8.2 v1.6.1 Powerbuilding Metadata Additions

v1.6.1 adds optional metadata for strength + hypertrophy outputs. These fields are layered on top of the v1.5 structured-output model and should not be required for simple daily workouts, beginner generation, mobility-only work, or general fitness sessions.

Programme-level optional fields:

```ts
training_style?: 
  | 'general_fitness'
  | 'strength'
  | 'hypertrophy'
  | 'strength_hypertrophy'
  | 'fat_loss'
  | 'conditioning'
  | 'mobility_recovery';

reference_strategy?: {
  reference_files_used: string[];       // e.g., ['aedify-03-muscle-building.md', 'aedify-05-exercise-programming.md', 'aedify-09-powerbuilding-strength-hypertrophy.md']
  primary_reference_file?: string | null;
  reference_notes?: string | null;
};

block_type?: 
  | 'base'
  | 'accumulation'
  | 'hypertrophy_biased'
  | 'strength_biased'
  | 'peak'
  | 'deload'
  | null;
```

Exercise-prescription optional fields:

```ts
exercise_role?: 
  | 'primary'
  | 'secondary'
  | 'tertiary'
  | 'conditioning'
  | 'mobility_recovery'
  | null;

loading_model?: 
  | 'fixed_percent_1rm'
  | 'percent_1rm_bracket'
  | 'rpe_target'
  | 'rpe_range'
  | 'top_set_backoff'
  | 'double_progression'
  | 'calibration'
  | 'bodyweight'
  | 'time_based'
  | null;

load_selection_note?: string | null;
```

Set-level optional fields:

```ts
set_intent?: 
  | 'warmup'
  | 'top_set'
  | 'backoff'
  | 'volume'
  | 'technique'
  | 'pump'
  | 'test'
  | 'taper_practice'
  | 'working'
  | null;

percent_1rm?: number | null;
percent_1rm_min?: number | null;
percent_1rm_max?: number | null;

rpe_target?: number | null;
rpe_min?: number | null;
rpe_max?: number | null;

rir_target?: number | null;
rir_min?: number | null;
rir_max?: number | null;
```

Powerbuilding metadata validation:

- If `set_type = warmup`, the set must not count toward PRs, e1RM, plateau detection, progression triggers, or default analytics.
- If `set_intent = top_set`, the parent set must have `set_type = working`.
- If `set_intent = backoff`, the parent set must have `set_type = working`.
- If `set_intent = pump`, the parent exercise should normally have `exercise_role = tertiary`, unless the AI provides a valid reason.
- If `loading_model` uses percentage fields, the athlete must have a known or estimated 1RM anchor for that lift or movement pattern.
- If `loading_model = percent_1rm_bracket`, both `percent_1rm_min` and `percent_1rm_max` are required, and min must be less than max.
- If `loading_model = rpe_range`, both `rpe_min` and `rpe_max` are required, and min must be less than or equal to max.
- If `training_style = strength_hypertrophy`, each strength exercise should include `exercise_role` unless it is clearly a warm-up, mobility, or recovery entry.

### 8.3 Programme Expansion and Revision Rules

- AI multi-week programmes use template-based output by default.
- The app expands templates into concrete programme weeks/workouts/sets at save time, validates the expanded result, and persists atomically.
- Programme swaps, deloads, and edits create internal programme revisions. Completed workout logs are never mutated.
- `single_occurrence` swaps update only the selected expanded occurrence.
- `future_occurrences` swaps update the selected occurrence and future matching expanded occurrences; where safe, the app may split/update the underlying template from that point forward.
- `entire_program` swaps update all uncompleted matching occurrences and the reusable template. Completed logs remain unchanged.
- AI structured-output schema versioning is separate from Firebase exercise dataset schema versioning and Drift schema versioning.

### 8.4 Plan Sharing Data Model Additions (v1.7)

Add optional provenance/export fields to programmes and saved workouts:

```text
programs / saved_workouts
  imported                 bool default false
  imported_at              datetime nullable
  original_source           enum nullable  // ai-generated | ai-chat | custom
  share_schema_version      int nullable
  external_share_id         string nullable
  export_privacy_mode       enum nullable  // template | exact_prescription
```

Add optional fields to custom exercises:

```text
exercises
  imported_from_share       bool default false
  original_share_key        string nullable
```

The share/export layer should use a sanitized DTO rather than serializing Drift rows directly. The DTO must explicitly exclude private data, logs, AI prompts/responses, AI snapshots, and telemetry-sensitive fields.

Suggested share DTO top-level shape:

```json
{
  "share_schema_version": 1,
  "exported_at": "2026-06-07T12:00:00Z",
  "app": {
    "name": "Aedify",
    "export_format": "aedifyplan",
    "app_version": "1.7.0"
  },
  "content_type": "program",
  "privacy_mode": "template",
  "content": {},
  "exercise_resolution": {
    "dataset_schema_version": 1,
    "exercise_dataset_version": "2026-05-10",
    "custom_exercises": []
  },
  "source_metadata": {}
}
```

Validation rules:

- `share_schema_version` is independent of Firebase exercise dataset schema, Drift schema, and AI structured-output schema.
- Unsupported share schema versions are rejected unless locally migratable.
- Imported files must be validated before any local DB writes.
- Imported plans are saved inactive by default.
- Imported plans are editable local copies and have no ongoing relationship to the sender.

| R-PM-1 | Progress media consumes significant local storage | Medium | Add video duration cap, thumbnails, media delete controls, and storage usage visibility. |
| R-PM-2 | Progress media or analysis leaks through crash reports or exports | Medium | Exclude raw media and analysis results from Crashlytics, `.aedifyplan`, PDF exports, external imports, and default data-sharing flows. |
| R-PM-3 | AI body-fat estimate appears more precise than it is | Medium | Require range output, confidence level, disclaimers, and UI wording that says rough visual estimate. |
| R-PM-4 | AI physique feedback harms user body image | Medium | Neutral language rules, no attractiveness scoring, no shaming, no extreme diet advice, and medical/eating-disorder escalation rules. |
| R-PM-5 | Video analysis is costly or unsupported by some BYOK providers | Low–Medium | Prefer local frame extraction over full video upload and require provider capability checks. |
| R-IMG-1 | Blurry or low-resolution screenshots cause incorrect extraction | Medium | Image quality checks, local readability enhancement, confidence warnings, and user review before save. |
| R-IMG-2 | Cropped programme tables produce incomplete plans | Medium | Flag unreadable/cropped regions and block AI from inventing missing content. |
| R-IMG-3 | Wrong screenshot order corrupts programme structure | Medium | Mandatory reorder screen for multi-image imports; user-defined order becomes source order. |
| R-IMG-4 | Selected BYOK model does not support image input | Medium | Provider/model capability gating and clear fallback message to use a text-based file or compatible model. |
| R-IMG-5 | Image imports cost more than text imports | Low–Medium | Explicit consent before AI call, provider image-count limits, and split-import guidance. |
| R-IMG-6 | Screenshots contain private data | Medium | Consent copy, temporary artifacts, no default storage, no Crashlytics, no exports. |
| R-IMG-7 | Paid/source programme screenshot is re-exported as source content | Medium | Do not store/export original or enhanced images; export only validated local plan data and preserve source-integrity guardrails. |

Removed from v1.2: `is_detail_loaded`, `detail_loaded_at`, `bodymap_male_url`, `bodymap_female_url` (single-tier cache; bodymaps are local SVGs).
---


### 8.5 External File Import Data Model Additions (v1.8)

External imports use draft state before persistence. This state may be implemented as temporary local state or persisted draft tables, but the PRD requires the following conceptual model.

#### 8.5.1 Programme and saved workout provenance fields

Add or reuse nullable provenance fields on programmes and saved workouts:

```text
creation_method enum nullable
  manual
  ai_generated
  ai_chat_save
  ai_file_import

import_origin enum nullable
  external_file
  aedifyplan

imported bool default false
imported_at datetime nullable
import_source_file_type enum nullable
  pdf
  txt
  md
  xlsx
  csv

import_review_status enum nullable
  pending_review
  resolved
  saved

source_file_retained bool default false
```

For v1.8 external imports:

```text
source = custom
creation_method = ai_file_import
import_origin = external_file
imported = true
source_file_retained = false
```

#### 8.5.2 Import draft state

Conceptual draft state:

```text
import_drafts
  id
  detected_content_type enum('program' | 'saved_workout' | 'unknown')
  source_file_type enum('pdf' | 'txt' | 'md' | 'xlsx' | 'csv')
  extracted_content_hash nullable
  ai_response_schema_version int
  status enum('pending_ai' | 'pending_review' | 'needs_input' | 'blocked' | 'resolved' | 'saved')
  detected_units enum('kg' | 'lb' | 'mixed' | 'unknown')
  confidence enum('low' | 'medium' | 'high')
  missing_or_unclear_items json array
  draft_json json
  created_at
  updated_at
```

The app does not store original source files by default. If a future version adds optional source-file retention, it must be explicit and separately consented.

#### 8.5.3 Exercise match draft state

```text
import_exercise_matches
  id
  import_draft_id
  source_exercise_name
  matched_exercise_id nullable
  matched_exercise_name nullable
  match_type enum('exact_normalized' | 'alias' | 'fuzzy_metadata' | 'manual' | 'custom_created' | 'removed' | 'unmatched')
  confidence enum('low' | 'medium' | 'high')
  requires_user_confirmation bool
  resolution_status enum('auto_matched' | 'needs_confirmation' | 'resolved' | 'removed')
  context_from_file text nullable
```

#### 8.5.4 Custom exercise draft state

```text
import_custom_exercise_drafts
  id
  import_draft_id
  source_exercise_name
  suggested_name
  modality
  equipment json array
  primary_muscle_groups json array
  difficulty
  mechanic nullable
  force nullable
  instructions json array nullable
  coaching_cues json array nullable
  notes text nullable
  confirmed_by_user bool default false
  created_exercise_id nullable
```

Required fields before save:

```text
name
modality
equipment
primary muscle group(s)
difficulty / experience level
```

#### 8.5.5 Import validation requirements

Block save if:

```text
structured JSON is invalid
response_type is wrong
programme/workout object is missing
weights are present and units are ambiguous
exercise matches are unresolved
custom exercise required fields are incomplete
sets/reps are malformed
superset groups are malformed
warm-up/working set labels are missing where required
programme schedule cannot be expanded
unsupported schema version
source-file content or AI internals appear in persisted/exportable fields
```

Allow save with review warnings if:

```text
rest times are missing
RPE/RIR is missing
progression rules are missing
deload rules are missing
duration is shorter than 8 weeks because source file is shorter
optional cues/instructions are missing
```


### 8.6 Progress Media and AI Physique Analysis Data Model Additions (v1.9)

#### 8.6.1 Progress media sessions

```text
progress_media_sessions
  id
  captured_at datetime
  media_type enum('photo_set' | 'video' | 'both')
  is_baseline bool default false
  bodyweight_kg nullable
  body_measurement_snapshot_id nullable
  notes text nullable
  reminder_cadence_at_capture enum nullable('two_weeks' | 'monthly' | 'three_months' | 'off')
  created_at datetime
  updated_at datetime
```

#### 8.6.2 Progress media items

```text
progress_media_items
  id
  session_id
  type enum('photo' | 'video' | 'video_frame' | 'thumbnail')
  pose enum('front' | 'back' | 'left_side' | 'right_side' | 'all_sides_video' | 'unknown')
  local_file_path text
  thumbnail_path text nullable
  duration_seconds int nullable
  width int nullable
  height int nullable
  file_size_bytes int nullable
  created_at datetime
```

#### 8.6.3 Progress media reminder settings

```text
settings
  progress_media_reminders_enabled bool default false
  progress_media_reminder_cadence enum nullable('two_weeks' | 'monthly' | 'three_months')
  last_progress_media_session_at datetime nullable
  next_progress_media_reminder_at datetime nullable
```

#### 8.6.4 AI physique analysis snapshots

```text
progress_physique_analysis_snapshots
  id
  session_id
  comparison_session_id nullable
  analysis_schema_version int
  provider_name text nullable
  model_name text nullable
  estimated_body_fat_min_percent decimal nullable
  estimated_body_fat_max_percent decimal nullable
  confidence enum('low' | 'medium' | 'high')
  overall_summary text
  visual_observations json
  muscularity_by_region json
  symmetry_assessment text nullable
  conditioning_assessment text nullable
  strengths json array
  lagging_areas json array
  progress_vs_baseline text nullable
  progress_vs_last_check_in text nullable
  recommended_focus_areas json array
  disclaimer text
  created_at datetime
```

Rules:

- Analysis snapshots store AI results locally only.
- Raw AI prompts, raw AI responses, media bytes, and provider payloads are not persisted unless a future explicit debug mode is added.
- If media is deleted, linked extracted frames and thumbnails are deleted. The app should either delete linked analyses or mark them as orphaned/unviewable depending on the user's delete action.


### 8.7 Image / Screenshot Import Metadata Additions (v1.10)

Image imports reuse the existing external import draft tables and add image-specific metadata to the draft payload or optional nullable columns.

#### 8.7.1 Import draft source fields

```text
import_drafts
  source_input_type enum('text_pdf' | 'txt' | 'md' | 'xlsx' | 'csv' | 'image_screenshot')
  source_file_types json array nullable
  image_count int nullable
  image_order_source enum('single_image' | 'user_defined' | 'file_picker_order' | 'unknown') nullable
  enhancement_applied bool default false
  enhancement_methods json array nullable
  image_quality enum('good' | 'acceptable' | 'poor' | 'unreadable') nullable
  unreadable_regions json array nullable
  missing_or_unclear_content json array nullable
```

#### 8.7.2 Temporary image import artifact state

Implementation may use temporary in-memory state or a temporary local table while the import is in progress:

```text
image_import_artifacts
  id
  import_draft_id nullable
  image_index int
  original_temp_path text
  enhanced_temp_path text nullable
  file_type enum('png' | 'jpg' | 'jpeg' | 'webp' | 'heic' | 'heif')
  quality_status enum('good' | 'acceptable' | 'poor' | 'unreadable')
  enhancement_methods json array nullable
  created_at
  expires_at nullable
```

This state must be deleted after import completion, cancellation, or failure. It must not be included in any export or Crashlytics payload.

#### 8.7.3 Example image import metadata

```json
{
  "source_input_type": "image_screenshot",
  "source_file_types": ["png", "jpg"],
  "image_count": 3,
  "image_order_source": "user_defined",
  "enhancement_applied": true,
  "enhancement_methods": [
    "orientation_correction",
    "contrast_improvement",
    "sharpening"
  ],
  "image_quality": "acceptable",
  "unreadable_regions": [
    {
      "image_index": 2,
      "region_description": "bottom-right table cells",
      "impact": "weights for final two exercises unclear"
    }
  ],
  "missing_or_unclear_content": [
    {
      "field": "weight_unit",
      "reason": "Weights are visible but unit is not shown"
    }
  ]
}
```

## 9. AI Prompt Engineering

### 9.1 Modular Instruction Set Architecture

v1.3 replaces v1.2's "every prompt re-states the full context" model with a **modular instruction set** maintained as a separate file (`ai-companion-instruction-set.md`).

**Design**:

- The instruction set has named sections: `TONE`, `IDENTITY`, `ATHLETE PROFILE`, `CURRENT WORKING WEIGHTS`, `LIFT LOG`, `REFERENCE FILES`, `PROGRAMMING RULES`, `HOW TO RESPOND`.
- Each per-call prompt selects a subset of sections (per the routing table, §9.2). The selected sections become the **system message** for the LLM call.
- The **per-call user message** is a template specific to the prompt category, with variable placeholders (`{{namespace.field}}`) filled by the app at request time. It contains task-specific data: candidate exercise lists, structured-output schemas, request parameters, etc.
- The instruction set is editable separately from the prompts. Updating the AI's general operating context (e.g., refining the safety guardrail) is a single-file change with no per-prompt edits.

**Variable injection**: at request time, the app's prompt builder substitutes `{{namespace.field}}` placeholders from local data (Drift, secure storage, profile). Empty values render as `(not provided)` so the AI can distinguish absence from emptiness.

**LLM API mechanics**: the system message goes in the `system` field (OpenAI, Anthropic) or `system_instruction` (Gemini). Chat history threads through the `messages` array. The per-call user message is the final entry in `messages`.

### 9.2 Section-to-Prompt Routing

The seven prompt categories and which instruction-set sections each receives:

| Section | INIT | DAILY_WORKOUT | MULTI_WEEK_PROGRAM | EXERCISE_SWAP | DELOAD | PLATEAU_SUGGESTION | AI_TRAINER_CHAT |
|---|---|---|---|---|---|---|---|
| TONE | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| IDENTITY | — | — | — | — | — | — | ✓ |
| ATHLETE PROFILE | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| CURRENT WORKING WEIGHTS | — | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| LIFT LOG | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| REFERENCE FILES | — | — | ✓ | — | — | ✓ | ✓ |
| PROGRAMMING RULES | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| HOW TO RESPOND | — | — | — | — | — | — | ✓ |

### 9.3 The Seven Prompt Categories

Full per-call user-message templates live in `ai-companion-instruction-set.md` under "Per-call user messages." Summarized here:

#### 9.3.1 `INIT`

One-time, post-onboarding. AI confirms profile, flags missing fields, sets up programme-building expectations. System message: minimal (TONE, ATHLETE PROFILE, LIFT LOG [empty on fresh install], PROGRAMMING RULES). User message includes an exercise library overview line + the kickoff task.

#### 9.3.2 `DAILY_WORKOUT`

Single-session generation. Inputs: focus, intent (optional), context note (optional), equipment, session length, warm-up/cool-down toggles, active programme reference (if overriding). Output: structured JSON + brief conversational note.

#### 9.3.3 `MULTI_WEEK_PROGRAM` (general + beginner variant)

Multi-week (8+) programme generation. General template: structured JSON for full programme + Day 1 in detail + outline of remaining days. Per-call periodisation override supported. **Beginner variant**: offers proven-progression vs custom-design choice first, waits for user pick before generating.

#### 9.3.4 `EXERCISE_SWAP` (new in v1.3)

Single exercise replacement. Inputs: exercise to swap out, candidate replacements (filtered by muscle group + equipment + injuries). Output: conversational recommendation; if user accepts, structured JSON for affected future sessions.

#### 9.3.5 `DELOAD` (new in v1.3)

Single deload-week generation. Inputs: prior training week. Output: structured JSON for the deload week (same exercises, volume −40%, intensity −20%) + brief conversational note.

#### 9.3.6 `PLATEAU_SUGGESTION`

Plateau analysis + 3-week breakthrough plan. Inputs: stalled lift, weight, session count, exercise-specific log slice. Output: 2–4 paragraph analysis + structured JSON 3-week plan with tagged rationales (technique / volume / intensity / rest / nutrition).

#### 9.3.7 `AI_TRAINER_CHAT`

Free-form chat. No fixed user-message template; the athlete's typed text is the user message. The system message is assembled from the full chat routing. Supports the chat-to-library save flow (FR-8.11).

### 9.4 Reference File Selection Algorithm

For prompts that include REFERENCE FILES (`MULTI_WEEK_PROGRAM`, `DAILY_WORKOUT` when generation is reference-backed, `DELOAD`, `PLATEAU_SUGGESTION`, `AI_TRAINER_CHAT`), the app picks the 1–3 most relevant `.md` files based on request type, user goals, user message keywords, and prompt subtype.

Base algorithm:

1. Tokenize the user message + recent assistant turn (chat) or request parameters (generation).
2. Match against a hardcoded keyword index per reference file.
3. Apply mandatory inclusion rules.
4. Sort by match count and mandatory priority.
5. Take the top 3, unless a prompt-specific cap is lower.
6. If no matches, default to `aedify-aedify-00-index.md` only.

Mandatory inclusion rules:

- If the athlete is a beginner, include only beginner-safe references required for the request. Do not include `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` in any beginner prompt category or path.
- If goals include both `Build Strength` and `Build Muscle`, and the athlete is intermediate or advanced, include `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` unless a higher-priority safety constraint excludes it.
- If the user explicitly asks for powerbuilding, strength + hypertrophy, strength and size, or a powerlifting/bodybuilding hybrid, include `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` unless the athlete is a beginner.
- If the request is a plateau suggestion for squat, bench, deadlift, overhead press, or close compound variations, `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` may be included for intermediate/advanced athletes.
- If the request is injury, pain, rehab, medical concern, general fat loss, any beginner-scoped generation, casual movement, or mobility-only, do not include `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` by default.

Reference-selection output should be stored in the structured output metadata when the AI returns an app-actionable response.


### 9.5 Token Budget Management

- Per-call input cap: 30,000 tokens. Trims oldest chat history first, then drops the lowest-ranked reference file.
- Per-call output cap: 4,000 tokens (chat), 8,000 tokens (workout generation).
- Estimated cost shown before any call > $0.10 USD.

### 9.6 Bundled Reference Files

`assets/reference/` contains the reference corpus:

- `aedify-aedify-00-index.md` — entry point, cross-references.
- `aedify-aedify-01-getting-started.md` — gym basics, equipment, terminology.
- `aedify-aedify-02-weight-loss.md` — caloric deficit, cardio guidance.
- `aedify-aedify-03-muscle-building.md` — hypertrophy principles, volume guidelines.
- `aedify-aedify-04-nutrition-and-diet.md` — CICO, macronutrients, protein/fat/carb targets.
- `aedify-aedify-05-exercise-programming.md` — periodisation, beginner routines, intermediate progressions.
- `aedify-aedify-06-faq.md` — common questions.
- `aedify-aedify-07-supplements.md` — evidence-based supplement guidance.
- `aedify-aedify-08-glossary.md` — terminology.
- `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` — supplemental strength + hypertrophy programming principles for suitable intermediate/advanced athletes.

Files `01`–`08` are derived from thefitness.wiki. File `09` is a supplemental derived reference based on user-provided powerbuilding PDFs. It extracts high-level programming principles only and must not be used to reproduce, reconstruct, or output source programme tables, exact week-by-week layouts, or proprietary exercise sequences.

Loaded into a singleton `ReferenceCorpus` at app launch with keyword indexes. Adding/updating files = bundling + bumping corpus version.


### 9.7 Candidate List Construction

For prompts that generate workouts, the app constructs a **candidate exercise list** filtered to the user's context. Each candidate is sent to the AI as `{id, name, difficulty, muscle_groups, modality, equipment, mechanic}`.

**Filtering policy**:

- **Hard filters**: equipment access and experience level. Exercises outside the user's available equipment or clearly above the user's experience level are excluded before the AI call.
- **Soft filters**: goals and focus. The app ranks goal-matching exercises highest, but includes adjacent compatible exercises so the AI can build balanced sessions without token waste.
  - Example: Build Muscle + Chest focus still includes shoulders/triceps as adjacent push muscles.
  - Example: Lose Weight still includes resistance-training candidates, plus cardio candidates when appropriate.
  - Example: Build Strength prioritizes compound strength movements but may include accessories that support the primary lifts.

Prompt-specific behavior:

- **`DAILY_WORKOUT`**: hard filter by equipment + experience; soft-rank by focus area, session intent, and goals, including adjacent muscle groups as needed.
- **`MULTI_WEEK_PROGRAM`**: hard filter by equipment + experience; soft-rank by goals, movement coverage, and programme balance.
- **`EXERCISE_SWAP`**: hard filter by equipment + experience + injury/substitution exclusions; soft-rank by same primary muscle group, same movement pattern, and similar fatigue profile.
- **`DELOAD`**: no separate candidate list — uses the prior training week's exercises directly.

- **`MULTI_WEEK_PROGRAM` with `Build Strength + Build Muscle`**: hard filter by equipment + experience; soft-rank primary compound patterns first, then secondary compounds that support the priority lifts, then tertiary hypertrophy accessories for weak points and proportional development. Include enough adjacent muscle groups to build a balanced programme.
- **`DAILY_WORKOUT` with `Build Strength + Build Muscle`**: hard filter by equipment + experience; soft-rank exercises according to the requested session intent (`high-volume hypertrophy`, `low-volume strength`, `skill focus`, `active recovery`) and recent fatigue/log context.
- **`PLATEAU_SUGGESTION` for primary compounds**: include the plateaued lift, close variations, secondary supports, and low-fatigue tertiary accessories that address plausible weak points without overloading recovery.

Filtering happens client-side from the local Drift `exercises` table.

---


### 9.8 v1.5 Structured AI Output Contract

Structured JSON is mandatory only for app-actionable outputs. Normal AI Trainer chat remains conversational unless the athlete explicitly asks to save a workout or programme.

Structured outputs are required for:

- `DAILY_WORKOUT`
- `MULTI_WEEK_PROGRAM/general`
- `MULTI_WEEK_PROGRAM/beginner_path_a`
- `MULTI_WEEK_PROGRAM/beginner_path_b`
- `EXERCISE_SWAP/apply_update`
- `DELOAD`
- `PLATEAU_SUGGESTION`
- `AI_TRAINER_CHAT/chat_save_workout`
- `AI_TRAINER_CHAT/chat_save_programme`
- internal `STRUCTURED_OUTPUT_REPAIR`

Conversational outputs remain allowed for:

- `AI_TRAINER_CHAT/chat`
- `EXERCISE_SWAP/recommendation`
- `MULTI_WEEK_PROGRAM/beginner_choice`

#### 9.8.1 Shared structured-output envelope

Every app-actionable response must be valid JSON only, with no markdown, no code fences, and no text outside the JSON.

```json
{
  "schema_version": 1,
  "response_type": "multi_week_program",
  "status": "success",
  "user_message": "I created a 12-week programme using reusable workout templates and progression rules.",
  "data": {}
}
```

Allowed `status` values:

| Status | Meaning | Persistable? |
|---|---|---:|
| `success` | Output is complete and validatable. | Yes |
| `partial_success` | Output is usable but includes substitutions, omissions, or caveats. | User review required |
| `needs_input` | Required data is missing. | No |
| `blocked` | Request violates safety, medical, injury, or app-scope rules. | No |

Allowed structured `response_type` values:

```
daily_workout
chat_saved_workout
multi_week_program
chat_saved_programme
program_update
deload_week
plateau_plan
needs_input
blocked
```

#### 9.8.2 Universal validation rules

The app rejects structured output if:

- JSON is invalid;
- `schema_version` is missing or unsupported;
- `response_type` does not match the expected prompt operation;
- `status = success` but required `data` is missing;
- an exercise lacks a valid local `exercise_id`;
- an exercise ID was not in the app-supplied candidate list;
- the AI invents local database IDs or local refs;
- the output uses unsupported units;
- the programme duration violates the minimum 8-week rule;
- injury or substitution constraints are violated;
- app-actionable output is returned as free text instead of JSON.

The AI must not generate database IDs. It may only reference valid `exercise_id` values from the candidate list and may echo app-provided refs in update flows.

#### 9.8.3 `daily_workout_json`

Used by `DAILY_WORKOUT` and `AI_TRAINER_CHAT/chat_save_workout`.

```json
{
  "schema_version": 1,
  "response_type": "daily_workout",
  "status": "success",
  "user_message": "I created a 45-minute upper-body workout for today.",
  "data": {
    "workout": {
      "name": "Upper Body Strength — 45 Minutes",
      "source": "ai-generated",
      "goal_tags": ["build_strength", "build_muscle"],
      "focus_tags": ["chest", "back", "shoulders"],
      "difficulty_target": "intermediate",
      "estimated_duration_minutes": 45,
      "equipment_used": ["Dumbbells", "Bench"],
      "session_intent": "single_session",
      "warmup_included": true,
      "cooldown_included": true,
      "exercises": [],
      "session_notes": [],
      "validation_summary": {
        "candidate_filter_applied": true,
        "injury_constraints_respected": true,
        "substitution_constraints_respected": true,
        "all_exercise_ids_from_candidate_list": true
      }
    }
  }
}
```

`chat_saved_workout_json` reuses this shape with `response_type = 'chat_saved_workout'`, `source = 'ai-chat'`, and `session_intent = 'chat_saved_session'`.

#### 9.8.4 Final shared `exercise_prescription`

All persisted AI exercise prescriptions use set-level prescriptions.

```json
{
  "order_index": 1,
  "block": "main",
  "execution_group": {
    "mode": "single",
    "group_key": null,
    "label": null,
    "position_in_group": null,
    "rest_between_exercises_seconds": null,
    "rest_after_group_seconds": null
  },
  "exercise_id": 8,
  "exercise_name": "Barbell Squat",
  "sets": [],
  "tempo": null,
  "coaching_cues": ["Brace before each rep."],
  "substitution_note": null,
  "progression_rule": "If all working sets are completed at RPE ≤8 for 2 consecutive exposures, add 2.5–5 kg next time."
}
```

Allowed `block` values:

```
warmup
main
accessory
conditioning
cooldown
mobility
recovery
```

Allowed `execution_group.mode` values:

```
single
superset
```

#### 9.8.5 Final shared `set_prescription`

```json
{
  "set_index": 1,
  "set_type": "working",
  "reps": {
    "reps_min": 5,
    "reps_max": 5,
    "duration_seconds": null,
    "distance_meters": null
  },
  "weight": {
    "type": "absolute",
    "value_kg": 100,
    "percent_1rm": null,
    "bodyweight_multiplier": null,
    "is_calibration_estimate": false,
    "rounding_note": null
  },
  "effort": {
    "rpe_min": 7,
    "rpe_max": 8,
    "rir_target": 2,
    "failure_allowed": false
  },
  "rest_seconds": 180,
  "derived_from_working_set_index": null,
  "warmup_weight_rule": null
}
```

Allowed `set_type` values:

```
warmup
working
```

At least one of `reps_min`, `duration_seconds`, or `distance_meters` must be present.

#### 9.8.6 Warm-up set rules

Warm-up percentage rules apply only when all are true:

- the goal includes `build_strength`;
- the athlete is not a beginner;
- the exercise is a loaded strength exercise;
- the working set has an absolute `value_kg`;
- the exercise is a compound lift or a priority strength target.

Warm-up sets must come before working sets, progressively increase, and never exceed 80% of the associated working set weight. Warm-ups derive from the first/heaviest/top working set unless explicitly tied to another working set.

For three warm-up sets:

| Warm-up set | Required band |
|---:|---|
| 1 | 20–40% of working weight |
| 2 | 41–60% of working weight |
| 3 | 61–80% of working weight |

Warm-up percentage rules do not apply to bodyweight-only, cardio, mobility, recovery, or unclear-load exercises. The AI may prescribe 1–3 warm-up sets. More than 3 requires explicit justification.

#### 9.8.7 Superset rules

- Manual custom workouts/programmes may include supersets for any experience level, including beginners.
- AI-generated beginner workouts/programmes must not include supersets.
- AI-generated non-beginner workouts/programmes may include supersets for accessories, antagonistic pairings, or time efficiency.
- Heavy primary compound lifts must not be supersetted unless explicitly requested.
- v1 AI-generated supersets require matching working-set counts.
- Asymmetric supersets are deferred unless manually created by the user.

#### 9.8.8 Template-based `multi_week_program_json`

`multi_week_program_json` is template-based by default. The AI returns programme metadata, reusable workout templates, weekly schedule, progression rules, warm-up policy, deload rules, expansion rules, and explicit overrides. The app expands and validates at save time.

```json
{
  "schema_version": 1,
  "response_type": "multi_week_program",
  "status": "success",
  "user_message": "I created a 12-week programme using reusable workout templates and progression rules.",
  "data": {
    "program": {
      "name": "Beginner Strength Foundation — 12 Weeks",
      "source": "ai-generated",
      "generation_path": "beginner_path_a",
      "output_mode": "template_based",
      "experience_target": "beginner",
      "goal_tags": ["build_strength", "build_muscle"],
      "duration_weeks": 12,
      "days_per_week": 3,
      "training_day_names": ["Monday", "Wednesday", "Friday"],
      "estimated_session_minutes": 60,
      "periodisation_model": "wiki_beginner_progression",
      "progression_model": "linear_progression",
      "workout_templates": [],
      "weekly_schedule": [],
      "progression_rules": [],
      "warmup_policy": {},
      "deload_rules": {},
      "template_expansion_rules": {},
      "explicit_overrides": [],
      "source_guidance": {},
      "candidate_filter_summary": {},
      "program_notes": []
    }
  }
}
```

Allowed `response_type` values for this schema are `multi_week_program` and `chat_saved_programme`. `chat_saved_programme_json` reuses the same schema with `source = 'ai-chat'` and `generation_path = 'chat_saved'`.

`output_mode = 'fully_expanded'` is allowed only when template-based output cannot express the plan.

#### 9.8.9 Workout templates

```json
{
  "template_key": "workout_a",
  "name": "Workout A — Squat Focus",
  "focus_tags": ["quads", "glutes", "push"],
  "estimated_duration_minutes": 60,
  "template_role": "primary_strength_day",
  "exercises": []
}
```

Allowed `template_role` values:

```
primary_strength_day
hypertrophy_day
conditioning_day
recovery_day
mobility_day
mixed_day
```

#### 9.8.10 Weekly schedule

```json
{
  "week_number": 1,
  "phase_name": "Calibration",
  "is_deload": false,
  "week_goal": "Learn the main movements and establish conservative working weights.",
  "days": [
    {
      "day_index": 1,
      "day_name": "Monday",
      "template_key": "workout_a",
      "template_modifiers": {
        "load_adjustment_percent": 0,
        "volume_adjustment_percent": 0,
        "rpe_cap": 7,
        "notes": "Calibration exposure. Do not chase load."
      }
    }
  ]
}
```

`week_number` starts at 1 and must be contiguous. Every week must contain exactly `days_per_week` scheduled days unless explicitly justified. `template_key` must exist in `workout_templates`.

#### 9.8.11 Progression rules

```json
{
  "rule_key": "main_lift_linear_progression",
  "applies_to": {
    "template_keys": ["workout_a", "workout_b"],
    "exercise_ids": [8, 4],
    "set_type": "working"
  },
  "trigger": {
    "condition": "top_of_rep_range_at_target_rpe_for_2_consecutive_exposures",
    "target_rpe_max": 8
  },
  "progression_action": {
    "type": "increase_load",
    "upper_body_increment_kg": 2.5,
    "lower_body_increment_kg": 5,
    "accessory_action": "add_reps_before_load"
  },
  "stall_action": {
    "type": "pause_increment",
    "notes": "Do not increase load if prescribed reps are missed or RPE exceeds target."
  }
}
```

Progression applies only to working sets. Deload weeks do not progress load.

#### 9.8.12 Warm-up policy

```json
{
  "applies_to": "non_beginner_strength_focused_loaded_compounds",
  "required_for": ["primary_compound_lifts", "priority_strength_targets"],
  "excluded_for": [
    "beginner_ai_generated_programmes",
    "bodyweight_only_exercises",
    "cardio",
    "mobility",
    "recovery",
    "unclear_load_exercises"
  ],
  "derivation_rule": "derive_from_first_heaviest_or_top_working_set_unless_explicitly_tied",
  "max_percent_of_working_weight": 80,
  "default_three_set_bands": [
    {"set": 1, "min_percent": 20, "max_percent": 40},
    {"set": 2, "min_percent": 41, "max_percent": 60},
    {"set": 3, "min_percent": 61, "max_percent": 80}
  ]
}
```

#### 9.8.13 Deload rules

```json
{
  "included": true,
  "type": "scheduled",
  "weeks": [4, 8, 12],
  "volume_reduction_percent": 40,
  "intensity_reduction_percent": 20,
  "rpe_cap": 6,
  "movement_selection_rule": "keep_same_exercises_and_session_order_where_possible",
  "progression_rule": "no_load_progression_during_deload"
}
```

Beginner Path A should not blindly impose the default 3+1 mesocycle if that conflicts with the wiki-guided beginner routine. Path A follows the selected beginner path's intended progression and uses reset/deload behavior only when appropriate.

#### 9.8.14 Programme update schema

Used by `EXERCISE_SWAP/apply_update`.

Allowed `apply_to` values:

```
single_occurrence
future_occurrences
entire_program
```

- `single_occurrence` updates only the selected week/day occurrence.
- `future_occurrences` updates from the selected occurrence onward.
- `entire_program` updates all uncompleted matching occurrences and the reusable template.
- Completed workout logs are never edited.

#### 9.8.15 Deload week schema

Used by `DELOAD`. It returns a structured deload week with the same exercise selection as the source week, about 40% volume reduction, about 20% load/intensity reduction, RPE capped at 5–6, and no load progression.

#### 9.8.16 Plateau plan schema

Used by `PLATEAU_SUGGESTION`. The response includes conversational analysis inside `data.plateau_plan.analysis_paragraphs` plus a three-week plan. Each session includes exactly one rationale tag:

```
technique
volume
intensity
rest
nutrition
```

The target plateau exercise must be included unless injury/substitution constraints block it.

#### 9.8.17 `STRUCTURED_OUTPUT_REPAIR`

Internal retry flow when AI output fails validation. Triggers include invalid JSON, missing fields, wrong response type, invalid exercise IDs, broken warm-up rules, malformed supersets, programme template expansion failure, or scope violations.

Default retry policy:

- one automatic repair attempt;
- maximum two attempts only if the user manually retries;
- after failed repair, show a user-safe failure message and do not persist;
- because BYOK cost belongs to the user, the app should disclose when a retry requires another AI call.

Repair prompt receives the expected schema, validation errors, invalid JSON, and candidate exercise list. It returns corrected JSON only.

#### 9.8.18 Candidate exercise list caps

Soft caps, not hard technical limits:

| Prompt / operation | Candidate cap |
|---|---:|
| `DAILY_WORKOUT` | 60–80 |
| `MULTI_WEEK_PROGRAM` | 120–180 |
| `EXERCISE_SWAP` | 10–25 |
| `DELOAD` | none; use source week |
| `PLATEAU_SUGGESTION` | 40–80 |
| `AI_TRAINER_CHAT/chat_save_workout` | 60–80 |
| `AI_TRAINER_CHAT/chat_save_programme` | 120–180 |

The app should send fewer candidates where possible and group candidates by muscle group/equipment.

#### 9.8.19 Build Strength anchor priority

A `build_strength` programme can proceed if the app has at least one useful strength anchor. Priority order:

1. recent working weights from logs;
2. known 1RMs;
3. bodyweight-relative estimates;
4. if none exist, return `needs_input` asking for bodyweight or at least one lift estimate.

#### 9.8.20 Schema placeholders

The instruction set exposes these placeholders:

```
{{schema.daily_workout_json}}
{{schema.chat_saved_workout_json}}
{{schema.multi_week_program_json}}
{{schema.chat_saved_programme_json}}
{{schema.programme_update_json}}
{{schema.deload_week_json}}
{{schema.three_week_plateau_plan_json}}
{{schema.ai_refusal_or_needs_input_json}}
```


#### 9.8.21 Powerbuilding metadata and source-integrity rules

When `reference_files_used` includes `aedify-aedify-09-powerbuilding-strength-hypertrophy.md`, the structured output must include:

- `training_style = strength_hypertrophy` unless the request is a narrow plateau/deload response.
- `reference_strategy.reference_files_used`.
- `exercise_role` for strength exercises where applicable.
- `loading_model` for each exercise or set group where the prescription uses load logic beyond plain sets/reps.
- `set_intent` for top sets, back-off sets, test sets, taper-practice sets, and pump/volume work when applicable.
- A user-facing note that the plan is inspired by general strength + hypertrophy principles, not copied from any source programme.

If the first output violates the source-integrity rule by copying or appearing to reconstruct a source programme layout, the `STRUCTURED_OUTPUT_REPAIR` attempt must regenerate the programme using only generalized principles and a different week/session organization.

### 9.9 Instruction-set Update Requirement for v1.6.1

`ai-companion-instruction-set-v1.6.1.md` must include:

1. `REFERENCE FILES` recognizes `aedify-aedify-09-powerbuilding-strength-hypertrophy.md`.
2. `PROGRAMMING RULES` includes scoped powerbuilding rules:
   - use only for suitable strength + hypertrophy requests;
   - avoid totally for beginners, regardless of path or prompt category;
   - classify exercises by role where helpful;
   - use fatigue management;
   - use autoregulation when brackets/RPE/RIR are prescribed;
   - do not copy source programme tables or branded layouts.
3. Per-call user-message templates for `MULTI_WEEK_PROGRAM`, `DAILY_WORKOUT`, `DELOAD`, and `PLATEAU_SUGGESTION` support:
   - `training_style`;
   - `reference_files_used`;
   - `exercise_role`;
   - `loading_model`;
   - `set_intent`;
   - `block_type`.
4. `AI_TRAINER_CHAT` may discuss powerbuilding principles conversationally but must not output proprietary source programme sequences.

### 9.10 v1.5 Operation Subtypes

Keep the seven top-level prompt categories, but use operation subtypes:

| Top-level category | Operation subtype |
|---|---|
| `INIT` | `init` |
| `DAILY_WORKOUT` | `generate_daily_workout` |
| `MULTI_WEEK_PROGRAM` | `general`, `beginner_choice`, `beginner_path_a`, `beginner_path_b` |
| `EXERCISE_SWAP` | `recommendation`, `apply_update` |
| `DELOAD` | `generate_deload_week` |
| `PLATEAU_SUGGESTION` | `three_week_plateau_plan` |
| `AI_TRAINER_CHAT` | `chat`, `chat_save_workout`, `chat_save_programme` |
| Internal | `structured_output_repair` |


### 9.11 External File Import Prompt Contract (v1.8)

External file import uses structured outputs and local validation. AI import outputs are drafts only and must not be persisted without app validation and user review.

#### 9.11.1 `external_program_import_json`

```json
{
  "schema_version": 1,
  "response_type": "external_program_import",
  "status": "success",
  "user_message": "I extracted a programme draft from the file. Some exercises need review before saving.",
  "data": {
    "import_summary": {
      "detected_content_type": "program",
      "detected_program_name": "Imported Strength Programme",
      "detected_duration_weeks": 6,
      "detected_days_per_week": 4,
      "detected_units": "unknown",
      "source_file_type": "pdf",
      "confidence": "medium",
      "missing_or_unclear_items": [
        "Weight units are not specified.",
        "Rest times are missing for some accessories."
      ]
    },
    "program": {
      "name": "Imported Strength Programme",
      "source": "custom",
      "creation_method": "ai_file_import",
      "import_origin": "external_file",
      "output_mode": "template_based",
      "duration_weeks": 6,
      "days_per_week": 4,
      "training_day_names": [],
      "workout_templates": [],
      "weekly_schedule": [],
      "progression_rules": [],
      "warmup_policy": {},
      "deload_rules": {},
      "explicit_overrides": [],
      "program_notes": []
    },
    "exercise_resolution": {
      "matched": [],
      "ambiguous": [],
      "unmatched": []
    },
    "needs_user_review": true
  }
}
```

#### 9.11.2 `external_workout_import_json`

```json
{
  "schema_version": 1,
  "response_type": "external_workout_import",
  "status": "success",
  "user_message": "I extracted a saved workout draft from the file. Please review exercise matches before saving.",
  "data": {
    "import_summary": {
      "detected_content_type": "saved_workout",
      "detected_workout_name": "Imported Upper Body Workout",
      "detected_units": "kg",
      "source_file_type": "xlsx",
      "confidence": "high",
      "missing_or_unclear_items": []
    },
    "workout": {
      "name": "Imported Upper Body Workout",
      "source": "custom",
      "creation_method": "ai_file_import",
      "import_origin": "external_file",
      "goal_tags": [],
      "focus_tags": [],
      "estimated_duration_minutes": null,
      "equipment_used": [],
      "exercises": [],
      "session_notes": []
    },
    "exercise_resolution": {
      "matched": [],
      "ambiguous": [],
      "unmatched": []
    },
    "needs_user_review": true
  }
}
```

#### 9.11.3 Exercise resolution schema

Matched exercise:

```json
{
  "source_exercise_name": "Barbell Squat",
  "matched_exercise_id": 8,
  "matched_exercise_name": "Barbell Squat",
  "match_type": "exact_normalized",
  "confidence": "high",
  "requires_user_confirmation": false
}
```

Ambiguous exercise:

```json
{
  "source_exercise_name": "Lat Pulldown",
  "candidate_matches": [
    {
      "exercise_id": 23,
      "exercise_name": "Machine Pulldown",
      "reason": "Closest local match by name and movement pattern."
    },
    {
      "exercise_id": 829,
      "exercise_name": "Underhand Pulldown",
      "reason": "Similar movement, different grip."
    }
  ],
  "confidence": "medium",
  "requires_user_confirmation": true
}
```

Unmatched exercise:

```json
{
  "source_exercise_name": "Meadows Row",
  "context_from_file": "Listed on Pull Day as 3 sets of 8-10 reps.",
  "suggested_custom_exercise": {
    "name": "Meadows Row",
    "modality": "strength",
    "equipment": ["Barbell"],
    "primary_muscle_groups": ["Back"],
    "difficulty": "intermediate",
    "mechanic": "Compound",
    "force": "Pull",
    "instructions": [],
    "coaching_cues": []
  },
  "requires_user_resolution": true
}
```

#### 9.11.4 `EXTERNAL_PLAN_IMPORT_PARSE`

```text
TASK
Extract the workout or programme from the provided file content and convert it into a structured import draft.

FILE CONTEXT
- File type: {{import.file_type}}
- Extracted text/tables:
{{import.extracted_content}}

IMPORT MODE
- Default mode: extract, normalize, and structure only.
- Do not adapt the programme to the athlete unless explicitly requested.
- Preserve the source programme/workout as closely as possible.

RULES
- Detect whether the file contains a programme, saved workout, or unknown workout content.
- Preserve weeks, days, workout names, exercises, sets, reps, rest, RPE/RIR, tempo, supersets, warm-up sets, working sets, progression notes, and deload notes when present.
- Do not invent extra weeks, exercises, deloads, or progression rules.
- If critical data is missing or unclear, add it to missing_or_unclear_items.
- If units are unclear, set detected_units to "unknown".
- Do not include source-file excerpts beyond what is needed in structured fields.
- Do not include AI reasoning, prompts, private user profile data, or source-file metadata unrelated to the programme.
- Do not generate local database IDs.

OUTPUT
Return valid JSON only.

If the file contains a programme:
Use schema {{schema.external_program_import_json}}

If the file contains a single workout:
Use schema {{schema.external_workout_import_json}}

If unknown:
Return status = "needs_input" and explain whether the user should choose programme or saved workout.
```

#### 9.11.5 `EXTERNAL_PLAN_IMPORT_REPAIR`

```text
TASK
Repair the external import structured JSON.

The previous import draft failed validation. Return corrected JSON only.

EXPECTED RESPONSE TYPE
{{repair.expected_response_type}}

VALIDATION ERRORS
{{repair.validation_errors_json}}

INVALID JSON RECEIVED
{{repair.invalid_json}}

RULES
- Fix every validation error.
- Preserve the original extracted programme intent.
- Do not invent exercises, local IDs, weeks, days, or progression rules.
- If the draft cannot be repaired safely, return needs_input or blocked.
- Return JSON only.

OUTPUT SCHEMA
{{repair.expected_schema}}
```

#### 9.11.6 `EXTERNAL_PLAN_IMPORT_EXERCISE_MATCH_ASSIST`

This subtype is optional. The app should do deterministic matching first and ask AI only for difficult cases.

```text
TASK
Help match imported exercise names to local exercise candidates.

SOURCE EXERCISES
{{import.unresolved_exercise_names}}

LOCAL CANDIDATE EXERCISES
{{candidates.exercise_matching_candidates}}

RULES
- Do not invent exercise IDs.
- Use only supplied local candidates.
- Return high-confidence matches, ambiguous matches, and unmatched exercises separately.
- If unsure, mark as ambiguous or unmatched.
- Do not silently guess.

OUTPUT
Return valid JSON only using {{schema.external_exercise_match_json}}
```

#### 9.11.7 External import schema placeholders

Add these placeholders to the instruction set:

```text
{{schema.external_program_import_json}}
{{schema.external_workout_import_json}}
{{schema.external_exercise_match_json}}
```

#### 9.11.8 Routing update

External file import may be represented as either a new top-level prompt category or as internal operation subtypes. Recommendation for v1.8:

```text
Top-level category: EXTERNAL_PLAN_IMPORT
Operation subtypes:
  parse
  repair
  exercise_match_assist
```

Include instruction-set sections:

```text
TONE
STRUCTURED OUTPUT RULES
EXERCISE LIBRARY / CANDIDATE LIST
PROGRAMMING RULES
```

Do not include full athlete profile, lift log, injury list, body measurements, chat history, or AI generation snapshots in the default parse flow.


### 9.12 Progress Media AI Analysis Prompt Contract (v1.9)

Add a new top-level operation family:

```text
PROGRESS_MEDIA_ANALYSIS
  analyze
  compare
  repair
```

#### 9.12.1 Media input handling

The app should send only the selected media needed for the analysis request:

- For photo sets: front, back, left-side, and right-side images where available.
- For videos: locally extracted canonical frames where possible.
- For comparison: selected baseline/previous and current images or frames.

The app must not send unrelated progress media, lift logs, body measurements, injuries, full profile, chat history, API keys, or local database records unless a future explicitly consented flow requires it.

#### 9.12.2 `progress_physique_analysis_json`

```json
{
  "schema_version": 1,
  "response_type": "progress_physique_analysis",
  "status": "success",
  "user_message": "I analyzed the selected progress media and estimated a rough body-fat range.",
  "data": {
    "analysis_scope": "single_session",
    "media_used": ["front", "back", "left_side", "right_side"],
    "estimated_body_fat_percent_min": 16,
    "estimated_body_fat_percent_max": 19,
    "confidence_level": "medium",
    "confidence_notes": [
      "Lighting and pose are reasonably consistent.",
      "Estimate is still approximate and should not be treated as a precise measurement."
    ],
    "overall_summary": "Visible conditioning appears moderate with some muscular development through the shoulders and arms.",
    "visual_observations": [],
    "muscularity_assessment_by_region": [],
    "symmetry_assessment": "No major asymmetry is obvious from the provided views.",
    "conditioning_assessment": "Leanness appears moderate based on visible waist and muscle separation.",
    "strengths": [],
    "lagging_areas": [],
    "progress_vs_baseline": null,
    "progress_vs_last_check_in": null,
    "recommended_focus_areas": [],
    "likely_next_visual_milestones": [],
    "goal_alignment_note": "Continue comparing photos under similar conditions to track visual changes more reliably.",
    "disclaimer": "This is an approximate visual estimate, not a medical or clinically validated body-composition measurement."
  }
}
```

#### 9.12.3 Analysis rules

- Return a body-fat range, never a single precise percentage.
- Include confidence level: `low`, `medium`, or `high`.
- State that the estimate is approximate and not medically validated.
- Analyze visible physique traits only.
- Use neutral, practical, non-shaming language.
- Focus on training-relevant observations: muscularity, leanness, symmetry, proportions, and visible progress.
- Do not infer health status, disease, fertility, hormone status, eating disorder status, or mental health.
- Do not provide attractiveness ratings or appearance scores.
- Do not prescribe extreme dieting or aggressive bodyweight manipulation based only on appearance.
- If media quality is poor, return low confidence and explain what would improve future comparisons.

#### 9.12.4 Comparison rules

When comparing two sessions:

- Compare only the sessions/media supplied by the app.
- Prefer same-pose comparisons.
- Describe visible changes conservatively.
- Do not claim changes that are not visible or are likely due to lighting, angle, pump, hydration, or pose.
- Compare against the user's own baseline, not against celebrities, competitors, or idealized physiques.

#### 9.12.5 Repair prompt

Progress media analysis uses the shared structured-output repair flow. The expected response type is `progress_physique_analysis`.


### 9.13 Image / Screenshot External Import Prompt Contract (v1.10)

Image import uses the existing external import response schemas and matching flow, with two additional operation subtypes:

```text
EXTERNAL_PLAN_IMPORT/image_parse
EXTERNAL_PLAN_IMPORT/image_repair
```

The existing `EXTERNAL_PLAN_IMPORT/exercise_match_assist` subtype remains unchanged.

#### 9.13.1 `EXTERNAL_PLAN_IMPORT_IMAGE_PARSE`

```text
TASK
Extract an external workout or programme from selected screenshots/images and return a structured import draft.

IMAGE CONTEXT
- Source input type: {{import.source_input_type}}
- Image count: {{import.image_count}}
- Image order: {{import.image_order}}
- Image quality: {{import.image_quality}}
- Enhancement applied: {{import.enhancement_applied}}
- Enhancement methods: {{import.enhancement_methods}}
- Images: {{import.images}}

RULES
- Return structured JSON only.
- Treat the images as source material for extraction only.
- Respect the user-defined image order.
- Extract visible workout/programme structure as accurately as possible.
- Preserve weeks, days, workouts, exercises, sets, reps, weights, units, rest, RPE/RIR, tempo, supersets, warmups, working sets, progression rules, and deloads when visible.
- Do not adapt the programme.
- Do not improve or rewrite the programme.
- Do not invent missing text.
- Do not complete cropped tables.
- Do not guess unreadable numbers.
- Do not guess ambiguous units.
- If image quality is poor, lower confidence and flag limitations.
- If content is unreadable, return needs_input or blocked.
- Do not generate local database IDs.
- Do not include AI reasoning, prompt text, raw AI response, source screenshots, or source-image excerpts in persisted/exportable fields.

OUTPUT
Return valid JSON only using either:
- {{schema.external_program_import_json}}
- {{schema.external_workout_import_json}}
```

#### 9.13.2 `EXTERNAL_PLAN_IMPORT_IMAGE_REPAIR`

```text
TASK
Repair a failed structured import response created from image/screenshot import.

VALIDATION ERRORS
{{repair.validation_errors_json}}

INVALID JSON
{{repair.invalid_json}}

RULES
- Return corrected JSON only.
- Preserve original extraction intent where safe.
- Do not invent missing source content.
- Do not create local IDs.
- Do not guess unreadable image content.
- Do not add weeks, days, exercises, sets, reps, weights, or progression rules not supported by the screenshots.
- Remove source-image excerpts, AI reasoning, prompt text, raw AI output, or private data if present.
- If the draft cannot be repaired safely, return status = needs_input or blocked.

OUTPUT
{{schema.expected_external_import_schema}}
```

#### 9.13.3 Routing update

Image import is represented as subtypes under `EXTERNAL_PLAN_IMPORT`:

```text
Top-level category: EXTERNAL_PLAN_IMPORT
Operation subtypes:
  parse
  repair
  exercise_match_assist
  image_parse
  image_repair
```

Include instruction-set sections:

```text
TONE
STRUCTURED OUTPUT RULES
EXTERNAL IMPORT RULES
IMAGE IMPORT RULES
SOURCE INTEGRITY RULES
PRIVACY RULES
```

Do not include full athlete profile, lift log, injury list, body measurements, chat history, progress media, or AI generation snapshots in the default image parse flow.


## 10. UI/UX Considerations

### 10.1 Information Architecture

```
Bottom navigation (5 tabs):
  1. Home          (today's workout, plateau banners, quick actions)
  2. Programs      (Programs Library; "Generate AI Program" CTA)
  3. Library       (exercise library, search/filter)
  4. Progress      (analytics, photos, measurements)
  5. AI Trainer    (chat)

Settings via top-bar gear icon on every tab.
```

### 10.2 Key Screens

| Screen | Primary purpose | Critical elements |
|---|---|---|
| Home | Show what to do today | Today's workout card; plateau banners; quick "Log a lift" CTA; streak counter |
| Programs Library | Unified list of all programs + saved workouts | 3-source filter (All / AI-generated / AI-chat / Custom); search; "Active" / "Completed" badges |
| Workout Execution | Step through a workout | Exercise card (video + steps + audio sequencer + bodymap); set inputs; rest timer; swap exercise |
| Generate Workout | Configure AI generation | Goals → scope → duration → days → length → equipment → optional periodisation → generate |
| Program Calendar | Visualize multi-week plan | Week-by-week grid; deload weeks visually distinct; tap a day to open workout |
| Exercise Detail | Learn about an exercise | Streamed video w/ gender + angle toggles; step-by-step list with active highlight during audio; SVG muscle diagram (flippable front/back); Favorite / Substitute / Ask AI |
| AI Trainer | Conversational Q&A | Streaming responses; "context used" indicator; cost-per-message indicator; Save-to-library affordance on session-shaped responses |
| Analytics | See progress | Per-exercise charts; week-over-week comparison; PR list |
| Settings | Configure | Profile / AI / Reference / Notifications / Health / Data sections |


### 10.3 Strength + Hypertrophy / Powerbuilding Labels

When an AI-generated output uses `training_style = strength_hypertrophy`, the UI may show:

- Programme badge: `Strength + Hypertrophy`
- Optional style badge: `Powerbuilding`
- Exercise role labels:
  - `Primary lift`
  - `Secondary lift`
  - `Accessory`
  - `Conditioning`
  - `Mobility / Recovery`

Role labels are informational only in v1. They should not overcomplicate the workout execution screen. On the session screen, the priority is still: exercise name, set order, reps, weight, RPE/RIR, rest, and warm-up/working-set clarity.

### 10.4 Plan Sharing UX (v1.7)

Sharing is exposed from the Programs Library row action and the programme/workout detail screen.

#### Export flow

```text
More actions → Share
  → Choose format: App plan file (.aedifyplan), PDF, or Both
  → Choose privacy mode: Template or Exact prescription
  → If PDF: optional Include exercise instructions appendix toggle (off by default)
  → Privacy summary
  → Native OS share sheet
```

Privacy summary example:

```text
This export includes the workout structure, exercises, sets, reps, rest times, RPE/RIR targets, warm-up/working set labels, supersets, progression rules, and notes.
It does not include your profile, completed logs, injuries, progress photos, measurements, AI key, chat history, AI prompts, raw AI responses, candidate lists, or AI generation snapshots.
```

Exact prescription warning:

```text
This export includes exact prescribed weights, which may reveal your strength level. Only share it with people you trust.
```

#### PDF layout requirements

PDFs must be readable on screen and printable. Workout tables should be spacious enough for manual logging.

Each workout/day includes:

1. Prescription summary.
2. Open logging table.
3. Superset grouping notes where applicable.
4. Optional exercise instructions/cues if appendix is enabled.

The logging table must leave `Actual weight`, `Actual reps`, `Actual RPE`, and `Notes` blank, even when the PDF is exported in exact-prescription mode. Exact prescribed loads are shown in the prescription summary, not pre-filled as actual performance.

#### Import flow

```text
Open .aedifyplan file
  → Validate file
  → Preview plan
  → Resolve missing exercises/custom exercises
  → Save inactive local copy
```

The imported item appears in the Programs Library with an imported source label such as `Imported · AI-generated`.


### 10.5 External File Import UX (v1.8)

External import should feel like a guided review workflow, not an invisible AI conversion.

#### Entry points

```text
Programs Library → Import
Saved Workouts Library → Import
Global Add button → Import from file
```

#### Import flow

```text
Choose file
→ Extract file content
→ Confirm AI processing
→ AI creates import draft
→ Review detected programme/workout
→ Resolve exercise matches
→ Resolve units/missing fields if needed
→ Preview final import
→ Save inactive
```

#### Exercise resolution screen

For each ambiguous/unmatched exercise, show:

```text
Source exercise name
Context from file
Suggested match(es)
Actions:
  Match to existing exercise
  Create custom exercise
  Remove from import
```

#### Custom exercise creation review

Required fields must be visibly confirmed:

```text
Name
Modality
Equipment
Primary muscle groups
Difficulty / experience level
```

Optional fields can be edited/collapsed:

```text
Mechanic
Force
Instructions
Coaching cues
Notes
Video URL
```

#### Unit confirmation

If weights are present and units are unclear:

```text
This file includes weights, but it does not specify whether they are kg or lb. Which unit should be used for this import?

kg
lb
Import without weights
Cancel import
```

#### Unsupported file state

```text
This file cannot be imported in this version.

Supported formats: text-based PDF, TXT, MD, XLSX, CSV.
OCR/scanned PDFs and image-only files are not supported yet.
```

#### Beginner complexity warning

If a beginner imports a plan containing supersets, circuits, advanced loading, or high complexity:

```text
This imported plan includes advanced or complex training structure. Review it carefully before activating it.
```

The app should not block the import solely because the imported plan is complex, but activation should be a deliberate user action.


### 10.6 Progress Media UX (v1.9)

Entry points:

```text
Progress tab → Add progress media
Progress tab → Media timeline
Progress tab → Compare
Progress media session → Analyze with AI
Settings → Notifications → Progress media reminders
```

Capture flow:

```text
Add progress media
  → Choose Photo set / Video / Both
  → Capture or import media
  → Review media
  → Attach optional bodyweight / notes
  → Save
  → If first session: choose reminder cadence
```

AI analysis flow:

```text
Progress media session
  → Analyze with AI
  → Consent screen
  → Select media / confirm extracted frames
  → Run analysis
  → View rough body-fat range + physique notes
  → Save local analysis snapshot
```

Comparison flow:

```text
Compare
  → Choose baseline/latest or any two dates
  → Choose pose or video session
  → View side-by-side media
  → Optional: compare with AI
```

User-facing copy principles:

- Use "rough estimate" and "visual estimate" for body-fat analysis.
- Avoid words that imply clinical precision.
- Explain that lighting, pose, camera distance, clothing, pump, hydration, and time of day affect analysis quality.
- Keep feedback practical and tied to user goals.

### 10.7 Design Principles

- **Big numbers, small chrome**: weight and reps are the most important things on the workout-execution screen.
- **Muted tones during workout, bright tones for celebration**.
- **No dark patterns**.
- **Beginner-friendly defaults, expert-accessible depth**.
- **Theming**: light + dark; system preference default; WCAG AA contrast.

---


### 10.7 Image / Screenshot Import UX (v1.10)

#### 10.7.1 Import source picker

Add:

```text
Images / screenshots
```

Helper text:

```text
Import a programme or workout from one or more screenshots.
```

#### 10.7.2 Image selection screen

Show:

- supported formats;
- selected image count;
- selected thumbnails;
- remove image action;
- continue button.

#### 10.7.3 Reorder screen

Show when multiple images are selected:

- drag-and-drop thumbnails;
- image number labels;
- helper text: `This order will be used for AI extraction.`

#### 10.7.4 Enhancement preview screen

Show when enhancement is applied:

- original thumbnail;
- enhanced thumbnail;
- enhancement methods applied;
- quality warning if needed.

Actions:

```text
Use enhanced images
Use originals
Reselect images
Cancel
```

#### 10.7.5 Import review screen updates

Existing import review screen should include:

- source input: Images / screenshots;
- image count;
- enhancement applied: yes/no;
- quality warnings;
- missing/unclear fields;
- unreadable/cropped regions;
- exercise resolution status;
- save inactive CTA.

#### 10.7.6 Error states

Provider/model does not support images:

```text
Your selected AI provider or model does not support image-based import. Switch to a model that supports image input or use a text-based file instead.
```

Image unreadable:

```text
This image is too blurry, dark, cropped, or low-resolution to import reliably. Try a clearer screenshot or crop the programme area manually.
```

Content partially unclear:

```text
Some parts of the screenshots could not be read clearly. The app created a draft where possible, but you must review the unclear fields before saving.
```

Too many images:

```text
You selected more images than this AI provider can process at once. Remove some screenshots or split the import into smaller parts.
```


## 11. Out of Scope (v1)

- Cloud sync / multi-device.
- Cloud-hosted external file imports or import links.
- User accounts.
- Social features.
- Hosted plan-sharing links, public plan marketplace, social feeds, comments, likes, follows, or cloud-hosted PDFs.
- Importing app-generated/shared PDFs back into structured workouts/programmes. Shared PDFs are read-only human documents. External text-based PDFs may be imported through the v1.8 AI-assisted file import flow.
- Wearable companion apps.
- Computer-vision form check, rep counting, pose correction, or exercise technique scoring.
- Precise/clinical body-fat measurement from media.
- Automatic background AI analysis of progress media.
- Attractiveness scoring, physique ranking, body shaming, medical diagnosis, or eating-disorder coaching.
- OCR for scanned/image-only PDFs or workout screenshots.
- Cloud TTS / premium voices.
- Nutrition / meal logging beyond bodyweight.
- Localization to non-English languages.
- In-app purchases / subscription / ads.
- Custom user-authored prompts.
- Pre-bundled exercise starter pack (no longer needed since Firebase Storage delivers the full dataset on first launch).
- Per-user MuscleWiki BYOK at runtime (the runtime architecture does not need it, and public release is out of scope).

---

## 12. Risks, Dependencies, and Open Questions

### 12.1 Risks

| ID | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | iOS App Store rejection of BYOK apps routing to external paid AI services | **High** | Review App Store guideline 3.1.3(b) before submission. Worst case: ship with AI features disabled, enable via web-side BYOK config. |
| R2 | Firebase Storage outage during first-launch sync | Low | Anonymous auth retries; retry UI for download. Once cached, no further dependency. Trivial impact at private 5-user scale. |
| R3 | BYOK user surprise costs | Medium | Per-call cost preview; running monthly cost indicator; warning at $10/month threshold. |
| R4 | AI hallucinated exercises that don't match the candidate list | Low | Structured-output schemas force AI to return IDs from a provided list. Fuzzy-match fallback. UI escape hatch to manually pick. Lower severity than v1.2 now that candidate lists are richer. |
| R5 | TTS quality varies across devices / locales | Low | Allow user to disable audio per exercise; v2 could add cloud TTS opt-in. |
| R6 | Plateau detection false positives during deload | Medium | Algorithm excludes deload weeks. Dismiss + re-flag UI. Require 4+ sessions before flagging. |
| R7 | Health Connect availability on older Android | Low | Graceful degradation. |
| R8 | Exercise videos failing to stream | Medium | Player surfaces error + retry. Text + audio remain available. |
| R9 | Bundled reference files become outdated | Low | Updates via app release. Reference corpus version shown in About. |
| R10 | User edits profile and silently invalidates active program | Medium | FR-1.2.3 prompts the user to regenerate. |
| R13 | Bodymap SVG sourcing produces visually inconsistent assets | Medium | Use one open-source source family where possible; adapt assets into a single style guide and 14-bucket path contract before launch. |
| R14 | Build pipeline drift between transform script and client (e.g., new muscle name added by MuscleWiki) | Low–Medium | Transform script's strict mode fails loudly on unmapped values; forces sync at build time, not runtime. |
| R15 | Schema migration logic fails or older clients cannot parse a future dataset | Low–Medium | Maintain explicit dataset migration functions and fixture tests. If `min_app_schema_version` exceeds the installed client, show a clear "Please update" screen. |
| R16 | AI structured output is invalid or too large | Medium | Template-based programme output, local validation, one automatic `STRUCTURED_OUTPUT_REPAIR` retry, and user-safe failure state. |
| R17 | Crash reports leak sensitive training/profile/AI data | Medium | Strict Crashlytics redaction rules; never attach prompts, AI responses, logs, injuries, measurements, candidate lists, or local database records. |
| R-PB-1 | Over-complex programmes for beginners | Medium | Exclude file 09 from all beginner AI generation paths; gate by experience; keep beginner prescriptions simple. |
| R-PB-2 | Source reconstruction risk | Medium | Prompt guardrail, structured-output validation notes, repair attempt if output appears copied, no source tables in reference file. |
| R-PB-3 | Recovery overload | Medium | Require fatigue-management strategy, deload/taper rules, RPE/RIR caps, conservative deadlift volume, and progression limits. |
| R-PB-4 | Schema bloat | Low | Keep powerbuilding fields optional and only populate them when relevant. |
| R-PB-5 | Misleading expertise signal | Low–Medium | Add user-facing note that AI outputs are general guidance and should be adjusted based on performance, pain, and recovery. |
| R-SH-1 | Sharing export leaks sensitive personal data | Medium | Use sanitized share DTOs; never serialize local DB rows directly; privacy summary; exact-prescription warning; test exports for forbidden fields. |
| R-SH-2 | Imported files are malformed, unsafe, or unsupported | Medium | Deterministic local validation, schema version checks, exercise resolution flow, inactive-by-default import, and reject unsupported files. |
| R-SH-3 | PDF is too long or hard to use | Low–Medium | Exercise-instructions appendix is optional and off by default; tables prioritize manual logging readability. |
| R-SH-4 | Recipient mistakes prescribed loads for completed logs | Low | Exact loads appear only in prescription summaries; actual logging table columns remain blank. |
| R-IMP-1 | AI mis-parses an external programme table | Medium | Structured import schema, local validation, user preview, one repair attempt, and inactive-by-default save. |
| R-IMP-2 | Exercise-name matching chooses the wrong local exercise | Medium | Exact/alias auto-match only for high confidence; ambiguous/fuzzy matches require user confirmation; unmatched exercises cannot be saved unresolved. |
| R-IMP-3 | User imports copyrighted or paid source material and later exports source content | Medium | Do not store original source files by default; exports exclude source-file content, copied notes, branded tables, AI extraction snapshots, and source-reference content. |
| R-IMP-4 | User sends sensitive source-file content to BYOK AI provider without realizing | Medium | AI-processing consent screen before any AI call; send only extracted programme-relevant content. |
| R-IMP-5 | Scanned/image-only PDFs fail import | Low | Clear unsupported-file message; OCR explicitly out of scope for v1.8. |
| R-IMP-6 | Imported programmes shorter than normal app-generated minimum confuse users | Low | Preserve source duration and label as imported external file; normal 8+ week rule still applies only to new AI-generated programmes. |

| R-PM-1 | Progress media consumes significant local storage | Medium | Add video duration cap, thumbnails, media delete controls, and storage usage visibility. |
| R-PM-2 | Progress media or analysis leaks through crash reports or exports | Medium | Exclude raw media and analysis results from Crashlytics, `.aedifyplan`, PDF exports, external imports, and default data-sharing flows. |
| R-PM-3 | AI body-fat estimate appears more precise than it is | Medium | Require range output, confidence level, disclaimers, and UI wording that says rough visual estimate. |
| R-PM-4 | AI physique feedback harms user body image | Medium | Neutral language rules, no attractiveness scoring, no shaming, no extreme diet advice, and medical/eating-disorder escalation rules. |
| R-PM-5 | Video analysis is costly or unsupported by some BYOK providers | Low–Medium | Prefer local frame extraction over full video upload and require provider capability checks. |
| R-IMG-1 | Blurry or low-resolution screenshots cause incorrect extraction | Medium | Image quality checks, local readability enhancement, confidence warnings, and user review before save. |
| R-IMG-2 | Cropped programme tables produce incomplete plans | Medium | Flag unreadable/cropped regions and block AI from inventing missing content. |
| R-IMG-3 | Wrong screenshot order corrupts programme structure | Medium | Mandatory reorder screen for multi-image imports; user-defined order becomes source order. |
| R-IMG-4 | Selected BYOK model does not support image input | Medium | Provider/model capability gating and clear fallback message to use a text-based file or compatible model. |
| R-IMG-5 | Image imports cost more than text imports | Low–Medium | Explicit consent before AI call, provider image-count limits, and split-import guidance. |
| R-IMG-6 | Screenshots contain private data | Medium | Consent copy, temporary artifacts, no default storage, no Crashlytics, no exports. |
| R-IMG-7 | Paid/source programme screenshot is re-exported as source content | Medium | Do not store/export original or enhanced images; export only validated local plan data and preserve source-integrity guardrails. |

Removed from v1.2:
- ~~R11 (AI quality with minimal-only candidate data)~~ — resolved by richer candidate list (§9.7).
- ~~R12 (bootstrap weight)~~ — moot; single bulk download is faster than v1.2's per-difficulty paginated calls.

### 12.2 Dependencies

| Dependency | Source | Risk |
|---|---|---|
| Flutter SDK | flutter.dev | Low |
| Drift, Riverpod, shared_preferences, flutter_secure_storage, Dio, Retrofit, fl_chart, flutter_tts, flutter_local_notifications, health, video_player, chewie, sqlcipher_flutter_libs, flutter_svg | pub.dev | Low |
| Firebase (Storage, Auth, Core, Crashlytics) | Google | Low–Medium (vendor lock for exercise hosting and crash diagnostics) |
| MuscleWiki API | MuscleWiki | Build-time only. No runtime dependency. |
| LLM provider APIs (OpenAI, Anthropic, Google) | Respective vendors | Medium — user-controlled via BYOK. Native JSON/schema mode used opportunistically when available. |
| Apple Health / Health Connect SDKs | Apple / Google | Low |
| Bundled reference files | thefitness.wiki-derived local markdown files plus scoped supplemental powerbuilding reference | Low — private non-public app scope. |
| Bodymap SVG assets | Open-source alternatives adapted into local SVG assets | Medium |
| Local PDF/file/share tooling | Flutter packages for on-device PDF rendering, file writing, and native OS share sheet | Low–Medium — package choice finalized during implementation, but no backend dependency is introduced. |
| Local file extraction tooling | Flutter/Dart packages or platform helpers for text-based PDF, TXT/MD, XLSX, and CSV extraction | Medium — extraction quality varies by source file format; OCR is deferred. |
| Local camera/gallery/media tooling | Flutter packages and platform APIs for camera capture, gallery import, video capture, thumbnails, and local file management | Medium — permissions, media size, and platform behavior need implementation testing. |
| Vision-capable BYOK model support | User-selected AI providers/models | Medium — not all configured models support image input; the app must detect capability or disable AI media analysis. |
| Image-capable BYOK model support | User-selected AI providers/models | Medium — screenshot import requires image input support and provider-specific image count/size limits. |
| Local image preprocessing tooling | Flutter/Dart packages or platform helpers | Medium — readability enhancement quality varies by platform, image quality, and screenshot source. |

### 12.3 Resolved Decisions and Remaining Open Questions

**Resolved since v1.2** (no longer open):

| ID | Decision |
|---|---|
| OQ-1 (v1.0) | AI provider scope: OpenAI, Anthropic, Google in v1; others deferred. |
| OQ-2 (v1.0) | Multi-language: English only in v1. |
| OQ-4 (v1.0) | Workout duration: 30–120 min in 15-min increments. |
| OQ-5 (v1.0) | Photo storage: encrypted app sandbox. |
| OQ-7 (v1.0) | Onboarding length: 5-min target. |
| OQ-8 (v1.0) | Beginner detection: experience level + 1RM presence drives the routine-progression option in §5.3.2. |
| OQ-9 (v1.2) | AI candidate list shape: rich, includes `{id, name, difficulty, muscle_groups, modality, equipment, mechanic}` (resolved by v1.3's single bulk sync). |
| OQ-10 (v1.2) | Programs Library: unified, three-source on-ramp (AI-generated / AI-chat / Custom). |
| OQ-11 (v1.2) | Program completion: three-option dashboard (repeat / regenerate / fresh). |
| OQ-12 (v1.2) | MuscleWiki auth header: build-time only. No runtime impact. |
| (v1.3-new) | Exercise data source: Firebase Storage, single bulk sync. |
| (v1.3-new) | Difficulty enum: four values (`novice` / `beginner` / `intermediate` / `advanced`). |
| (v1.3-new) | Muscle taxonomy: 14 UI buckets, mapping derived in build pipeline. |
| (v1.3-new) | Modality field: `strength` / `flexibility` / `cardio` / `recovery`. |
| (v1.3-new) | `force` enum: `Push` / `Pull` / `Hold` / `null`. |
| (v1.3-new) | `category` and `equipment` both retained (Reading A). |
| (v1.3-new) | Bodymaps: Option A (pre-made SVGs) in scope for v1. |
| (v1.3-new) | AI prompts: modular instruction set with seven categories. |
| (v1.3-new) | Periodisation: 3+1 mesocycle default with per-call override. |
| (v1.4-new) | Beginner Path A: AI infers a structured, persisted programme from wiki guidance and saves it to the Programs Library. |
| OQ-3 (v1.3) | Public-release/licensing review: no public release is planned; removed as a launch blocker. |
| OQ-6 (v1.3) | Crash reporting: Firebase Crashlytics selected as the explicit crash-diagnostics telemetry exception. |
| OQ-13 (v1.3) | Manifest fields finalized: no per-language manifests and no changelog field. |
| OQ-14 (v1.3) | Schema bump policy: migrate compatible dataset schema changes; show update-required only when unsupported. |
| OQ-15 (v1.3) | Bodymap SVG sourcing: use open-source alternatives adapted into the app's local SVG contract. |
| OQ-17 (v1.3) | Candidate filtering: hard filter by equipment + experience; soft filter by goals with adjacent inclusions. |
| (v1.5-new) | App-actionable AI outputs: mandatory structured JSON with shared envelope; normal chat remains conversational. |
| (v1.5-new) | Multi-week programme output: template-based by default; app expands and validates at save time. |
| (v1.5-new) | Structured-output repair: one automatic retry, then fail safely. |
| (v1.5-new) | Prescriptions: set-level model with every prescribed/logged set marked `warmup` or `working`. |
| (v1.5-new) | Warm-up policy: applies only to loaded non-beginner strength exercises with absolute working weights; progressive load bands capped at 80% of working weight. |
| (v1.5-new) | Analytics: working sets drive PRs, e1RM, plateau detection, progression, and default charts; warm-up sets are excluded. |
| (v1.5-new) | Supersets: allowed for manual custom workouts/programmes at all levels; AI-generated beginner outputs cannot include supersets; v1 AI supersets require matching working-set counts. |
| (v1.5-new) | Chat save flow: chat can save both single workouts and multi-week programmes after explicit user intent. |
| (v1.5-new) | Candidate-list soft caps defined per prompt to reduce cost and hallucination risk. |
| (v1.5-new) | Build Strength anchor priority: working weights → 1RMs → bodyweight estimates → needs input. |
| (v1.5-new) | Beginner Path A: wiki-derived routine structure overrides default 3+1 periodisation when needed. |
| (v1.5-new) | Custom exercises: AI may use user-created exercises only if candidate-listed with valid local metadata. |
| (v1.5-new) | Equipment increments: no plate/dumbbell inventory feature in v1; user/app may round to available load. |
| (v1.5-new) | Exercise swaps: support `single_occurrence`, `future_occurrences`, and `entire_program`; completed logs are never edited. |
| (v1.5-new) | AI output schema versioning: separate from Firebase exercise dataset schema and Drift schema. |
| (v1.5-new) | Crashlytics redaction: non-negotiable privacy rule. |
| (v1.6-new) | Powerbuilding reference scope: `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` is supplemental for suitable strength + hypertrophy requests, not a universal default. |
| (v1.6.1-new) | Beginner exclusion: all beginner AI generation paths must not use file 09. Beginner Path A remains strictly wiki-derived. |
| (v1.6-new) | Source integrity: the AI may use principles from file 09 but must not reproduce, reconstruct, or output source PDF tables, branded programme layouts, or proprietary sequences. |
| (v1.6-new) | Schema extension style: powerbuilding fields are optional metadata layered on top of the v1.5 structured-output model. |
| (v1.7-new) | Plan sharing: local file export/import only; no hosted links, cloud sharing, public marketplace, accounts, or social features. |
| (v1.8-new) | External imports: AI-assisted structured drafts from text-based PDF, TXT, MD, XLSX, and CSV. |
| (v1.8-new) | OCR/scanned PDFs/image-only screenshots are out of scope. |
| (v1.8-new) | External import defaults to extract/normalize/structure, not adapt. |
| (v1.8-new) | External imported programmes may preserve source duration even below 8 weeks. |
| (v1.8-new) | Import requires AI-processing consent because extracted content is sent to the user's BYOK provider. |
| (v1.8-new) | Imported items save inactive by default and original source files are not stored by default. |
| (v1.8-new) | Ambiguous exercise matches require confirmation; unmatched exercises must be matched, created as custom, or removed before save. |
| (v1.8-new) | Later exports of external imports must exclude original source-file content, AI internals, and private app data. |
| (v1.7-new) | Share formats: temporary `.aedifyplan` app-native file, PDF, or both. Extension may change later when app naming is finalized. |
| (v1.7-new) | Share schema: `share_schema_version = 1`, separate from Firebase exercise dataset schema, Drift schema, and AI structured-output schema. |
| (v1.7-new) | PDF export: read-only human document, not importable in v1, with prescription summaries and open workout logging tables. |
| (v1.7-new) | PDF appendix: exercise-instructions appendix is optional and off by default. |
| (v1.7-new) | Privacy mode: template export is default; exact prescription export requires explicit privacy warning. |
| (v1.7-new) | Import behavior: imported `.aedifyplan` plans are validated locally, previewed before save, inactive by default, and editable as local copies. |
| (v1.7-new) | Custom exercises: shared custom exercises include definitions and are recreated locally with new local IDs on import. |

| (v1.10-new) | External image/screenshot import supports PNG, JPG/JPEG, WEBP, and HEIC/HEIF where platform-supported. |
| (v1.10-new) | Users can select and reorder multiple screenshots before AI processing; user-defined order becomes source order. |
| (v1.10-new) | Image enhancement is local-first and readability-only; it must not invent missing text or alter programme content. |
| (v1.10-new) | Screenshot import requires an image-capable BYOK provider/model and explicit consent before images are sent. |
| (v1.10-new) | Original screenshots and enhanced images are temporary import artifacts and are not stored or exported by default. |
| (v1.10-new) | Scanned/image-only PDFs remain out of scope unless explicitly reopened later. |

**Remaining open questions** (to be addressed before launch):

None currently recorded after the v1.5 pre-lock audit. New architectural or product decisions should create a new PRD version bump.

---

## 13. Success Criteria

### 13.1 Functional Success

- ✅ All FR-* items implemented and passing manual acceptance tests.
- ✅ Structured-output validation rejects invalid exercise IDs, malformed supersets, broken warm-up rules, unsupported schema versions, and wrong response types.
- ✅ Template-based programmes expand into concrete weeks/workouts/sets and persist atomically.
- ✅ Chat-generated workouts and programmes are saved only after explicit user intent.
- ✅ First-launch Firebase sync completes in ≤ 10 seconds on a stable connection.
- ✅ One automatic structured-output repair attempt works for recoverable invalid JSON/schema failures.
- ✅ Crashlytics payload inspection confirms no prompts, AI responses, logs, injuries, measurements, candidate lists, or structured output JSON are transmitted.
- ✅ Subsequent launches with unchanged `latest_version` complete library checks in ≤ 200 ms.
- ✅ Compatible dataset schema changes migrate successfully before the atomic Drift write.
- ✅ Unsupported dataset schema changes display a clear "Please update the app" screen.
- ✅ Offline cold launch (after first sync) shows the full library and allows logging, analytics, and bodymap rendering.
- ✅ The modular instruction set produces functioning prompts across all seven categories with no template variable left unsubstituted.
- ✅ Beginner programme generation triggers the choice-first flow (Path A / Path B) and waits for user selection before generating.
- ✅ Chat-to-library save flow successfully promotes a chat-generated session to Saved Workouts with `source = 'ai-chat'`.
- ✅ Bodymap widget correctly highlights the muscle groups of any tested exercise on both male and female views, front and back.
- ✅ Plateau detection flags a constructed test case (4 sessions of identical e1RM) and surfaces the AI suggestion flow.
- ✅ Given an intermediate/advanced athlete with goals `Build Strength` + `Build Muscle`, the AI can generate a valid structured programme using `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` as a supplemental reference.
- ✅ Beginner AI generation never includes or applies the powerbuilding reference, regardless of path or prompt category.
- ✅ A generated strength + hypertrophy programme classifies strength exercises by role where applicable (`primary`, `secondary`, `tertiary`, etc.).
- ✅ A generated strength + hypertrophy programme includes a valid fatigue-management strategy.
- ✅ Structured-output validation accepts optional powerbuilding metadata but does not require it for simple non-powerbuilding workouts.
- ✅ Source-integrity test confirms the AI output does not reproduce source PDF programme tables, exact week-by-week layouts, proprietary exercise sequences, or branded programme clones.
- ✅ Plateau suggestions for primary compound lifts can use file 09 for intermediate/advanced athletes without copying any source layout.
- ✅ User can export a saved workout and multi-week programme as `.aedifyplan` and import it on another device running the app.
- ✅ User can export a saved workout and multi-week programme as PDF.
- ✅ PDF export includes prescription summaries and blank/open logging tables for actual weight, actual reps, actual RPE, and notes.
- ✅ Exact-prescription PDF shows exact loads in the prescription summary while leaving actual logging columns blank.
- ✅ Exercise-instructions appendix toggle is off by default and, when enabled, adds exercise steps/cues without exposing AI prompts or source reference excerpts.
- ✅ Imported plans are inactive by default and display imported provenance labels.
- ✅ Import validation rejects malformed supersets, broken warm-up ordering, unsupported share schema versions, and unresolved exercises unless the user resolves replacements.
- ✅ Sharing export inspection confirms no profile data, injuries, logs, progress photos, measurements, API keys, chat history, prompts, raw AI responses, candidate lists, or `ai_generation_snapshot_json` are included.

- ✅ User can import a text-based PDF, TXT/MD, XLSX, or CSV programme/workout.
- ✅ App shows AI-processing consent before sending extracted file content to the selected BYOK AI provider.
- ✅ AI returns a structured external import draft using `external_program_import_json` or `external_workout_import_json`.
- ✅ App detects programme vs saved workout or asks the user when content type is unclear.
- ✅ App preserves source programme duration even when shorter than 8 weeks.
- ✅ App auto-matches exact/strong alias exercise names and shows them in review.
- ✅ App requires user confirmation for ambiguous exercise matches.
- ✅ App requires unmatched exercises to be matched, created as custom, or removed before save.
- ✅ User can create local custom exercises from unmatched imported exercises after confirming required fields.
- ✅ Imported external programmes are saved inactive by default.
- ✅ Imported external plans can later be exported as `.aedifyplan` or PDF without original source-file content or AI internals.
- ✅ User can import one or more PNG/JPG/WEBP/HEIC screenshots as an external programme/workout source.
- ✅ User can reorder selected screenshots before AI processing.
- ✅ App detects unsupported image formats and unsupported image-capable providers/models.
- ✅ App applies readability enhancement to low-quality screenshots where practical and shows preview/warnings.
- ✅ App asks for explicit AI-processing consent before sending original or enhanced screenshots to a BYOK provider.
- ✅ AI extracts visible screenshot content into a structured external import draft without inventing missing or cropped content.
- ✅ App flags unclear/cropped/unreadable screenshot regions and missing/unclear fields.
- ✅ Image imports reuse the existing exercise matching and unresolved review flow.
- ✅ Original screenshots, enhanced screenshots, and image-processing artifacts are not stored or exported by default.

### 13.2 Technical Success

- ✅ Drift schema migrations and exercise-dataset migrations are clean across simulated upgrade paths.
- ✅ Build-time `aedify-transform-for-firebase.js` strict mode passes for the current 1,902-exercise dataset.
- ✅ Build-time pipeline failure (unmapped muscle name) is loud and prevents accidental shipping.
- ✅ Firebase Storage security rules verified: anonymous read works; writes are blocked.
- ✅ Crashlytics test crash appears in Firebase without prompt bodies, API keys, lift-log contents, health data, or free-form user notes.
- ✅ All API keys remain in `flutter_secure_storage` and never appear in logs, Crashlytics reports, error reports, or telemetry.
- ✅ Reference-selection tests verify that `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` is injected for eligible non-beginner strength + hypertrophy requests and excluded for all beginner-scoped requests, rehab/pain, mobility-only, and general-fat-loss-only requests.
- ✅ `.aedifyplan` share-schema fixtures validate and migrate/reject correctly.
- ✅ PDF generation works offline and produces usable printable tables for at least one saved workout and one multi-week programme.
- ✅ Powerbuilding-derived exports preserve source-integrity guardrails and do not contain source excerpts, paid programme tables, branded phase layouts, or proprietary exercise sequences.

- ✅ Text-based PDF/TXT/MD/XLSX/CSV extraction fixtures produce stable extracted content for the AI import prompt.
- ✅ Scanned/image-only PDF fixtures show the unsupported/OCR-needed message and make no AI call.
- ✅ External import structured-output validation and repair flow works with valid, invalid, and partially malformed AI responses.
- ✅ Exercise matching fixtures cover exact, alias, fuzzy/ambiguous, unmatched, custom-created, and removed exercise paths.
- ✅ External imports never persist original source files by default and never include source-file excerpts, AI prompts, raw AI responses, or extraction snapshots in later exports.

- ✅ User can capture or import a complete four-pose progress photo set.
- ✅ User can capture or import a short all-sides progress video.
- ✅ First progress media session can become the baseline and trigger a cadence selection prompt.
- ✅ Progress media reminders support every 2 weeks, monthly, every 3 months, and off.
- ✅ User can compare baseline vs latest and any two progress sessions.
- ✅ AI physique analysis requires explicit consent before any media or extracted frames are sent to a BYOK provider.
- ✅ AI physique analysis returns a rough body-fat range with confidence, not a precise single value.
- ✅ AI analysis uses neutral, training-oriented language and does not provide medical diagnosis, attractiveness scoring, body shaming, or extreme dieting instructions.
- ✅ Progress media and AI analysis results are excluded from Crashlytics, `.aedifyplan`, PDF exports, external imports, and default sharing flows.
- ✅ Image import fixtures cover good, acceptable, poor, unreadable, cropped, and multi-screenshot source cases.
- ✅ Provider capability tests disable screenshot import when `supports_image_input` is false.
- ✅ Image import repair flow rejects AI-invented missing content and source-image excerpts.
- ✅ Temporary image import artifacts are deleted after completion, cancellation, and failure.

### 13.3 User Success (private 5-user deployment)

- ✅ Each user completes onboarding within 5 minutes (target G1).
- ✅ Each user generates their first AI workout within 10 minutes of launch (target G2).
- ✅ Each user reports the bodymap rendering matches the muscle groups they expected for at least 10 sampled exercises.
- ✅ Beginner user (Persona 3.1) reports the choice-first flow felt non-pushy and informative.
- ✅ Intermediate user (Persona 3.2) receives a plateau flag on their stalled lift within 4 weeks of starting to log it.

---

## 14. Glossary

| Term | Definition |
|---|---|
| **1RM** | One-rep maximum — the maximum weight a person can lift for one rep with proper form. |
| **AI-chat (source)** | Programs/workouts created via the AI Trainer chat and promoted to the library via the save flow. One of three Programs Library on-ramps. |
| **AI-generated (source)** | Programs/workouts created via a formal AI generation flow (`DAILY_WORKOUT` / `MULTI_WEEK_PROGRAM` prompts). One of three Programs Library on-ramps. |
| **Block periodisation** | A periodisation model in which training blocks focus on distinct qualities (volume, intensity, peak) in sequence. Example: 4 weeks volume → 4 weeks intensity → 3 weeks heavy → 1 week deload. |
| **Bulk sync** | The act of downloading the entire exercise dataset from Firebase Storage in a single transaction, replacing the local cache atomically. v1.3 replaces v1.2's two-tier (minimal + lazy) cache with this model. |
| **BYOK** | Bring Your Own Key — the user supplies their own LLM API key; the app does not host or proxy. |
| **Calibration week** | Week 1 of any new programme, in which prescribed weights are starting estimates that the user adjusts based on actual performance. |
| **Candidate list** | The filtered list of exercises sent to the AI in a per-call user message. The AI must pick from this list when prescribing exercises. |
| **Custom (source)** | Programs/workouts built by the user with no AI involvement. One of three Programs Library on-ramps. |
| **Deload** | A planned week (or session) of reduced volume and intensity to allow recovery before the next training block. |
| **e1RM (estimated one-rep maximum)** | Estimated 1RM derived from a working set using the Epley formula: `weight × (1 + reps/30)`. Reliable for reps ≤ 10. |
| **Force enum** | The direction of resistance for an exercise: `Push`, `Pull`, `Hold`, or `null`. |
| **Linear periodisation** | A periodisation model with steadily increasing intensity (decreasing reps) over the training block. |
| **Manifest** | The small JSON file at `gs://{bucket}/exercises/manifest.json` describing the current dataset version. |
| **Mechanic enum** | `Compound` (multi-joint), `Isolation` (single-joint), or `null`. |
| **Mesocycle** | A block of training weeks, typically 3 work weeks + 1 deload week. The default periodisation model. |
| **Modality** | The activity type of an exercise: `strength`, `flexibility`, `cardio`, or `recovery`. Derived from category in the build pipeline. |
| **Modular instruction set** | The PRD-v1.3 architecture for AI prompts: a single file with named sections, selectively routed to each per-call prompt's system message. |
| **Muscle group** | One of the 14 UI buckets (Chest, Shoulders, Back, Biceps, Triceps, Forearms, Core, Glutes, Quads, Hamstrings, Calves, Adductors, Neck, Feet). |
| **Per-call user message** | The task-specific user-turn template for each prompt category. Contains the candidate list, request parameters, structured-output schema, etc. |
| **Periodisation** | The systematic planning of athletic training: how volume, intensity, and exercise selection vary over time. |
| **PR** | Personal record. |
| **Primary muscle** | One of the 45 granular MuscleWiki muscle values (e.g., `Anterior Deltoid`, `Lower Traps`). Stored alongside the UI-bucket mapping. |
| **Prompt category** | One of the seven AI prompt types: `INIT`, `DAILY_WORKOUT`, `MULTI_WEEK_PROGRAM`, `EXERCISE_SWAP`, `DELOAD`, `PLATEAU_SUGGESTION`, `AI_TRAINER_CHAT`. |
| **Proven progression** | The Path-A option in the beginner choice flow: a referenced wiki-defined routine progression (Basic Beginner Routine → 5/3/1 / GZCLP). |
| **RIR** | Reps in reserve — how many additional reps a lifter could have performed. |
| **RPE** | Rate of perceived exertion (1–10). |
| **Schema version** | The integer marker on the exercise dataset. The client migrates compatible schema changes locally and refuses only when `min_app_schema_version` exceeds what the installed app supports. |
| **Section routing** | The mapping from prompt category → which instruction-set sections appear in its system message. See §9.2. |
| **Three on-ramps** | The three sources from which a workout/programme can enter the Programs Library: AI-generated, AI-chat, Custom. |
| **Two-tier cache** | The v1.2 caching model (minimal records + lazy-loaded details). Replaced in v1.3 by a single bulk sync. Retained here as a glossary entry for change-tracking. |
| **Undulating periodisation** | A periodisation model in which volume and intensity vary daily or weekly rather than progressing linearly. |
| **Working weight** | The actual weight a lifter uses for prescribed work sets, derived from logged sessions (distinct from 1RM, which is the theoretical max). |
| **`.aedifyplan`** | Temporary app-native share-file extension for exported workouts/programmes. The extension may change when the app name is finalized; the internal share schema remains the contract. |
| **Share schema version** | The version field for app-native exported plan files. Separate from Firebase exercise dataset schema, Drift schema, and AI structured-output schema. |
| **Template export** | Default sharing privacy mode that shares plan structure without exact strength-revealing loads where possible. |
| **Exact prescription export** | Sharing privacy mode that includes exact prescribed loads and therefore requires an explicit privacy warning. |

| **Powerbuilding** | A training style that combines powerlifting-style strength development on major compound lifts with bodybuilding-style hypertrophy work. |
| **Primary exercise** | A main heavy compound movement with high strength relevance and high systemic fatigue, such as squat, bench, deadlift, overhead press, or close variations. |
| **Secondary exercise** | A compound accessory movement that supports primary lifts or builds major muscle groups with less systemic fatigue. |
| **Tertiary exercise** | Isolation/accessory work for hypertrophy, weak points, joint balance, or local volume. |
| **Top set** | A heavier or higher-effort working set performed before back-off or volume work. |
| **Back-off set** | A working set performed after a top set, usually at lower load and/or higher volume. |
| **Taper** | A planned reduction in training volume while maintaining some intensity, usually before testing or performance. |
| **AMRAP** | As many reps as possible; can be used to estimate strength without testing a true 1RM. |


| **AI-assisted external import** | v1.8 feature where the app extracts programme/workout content from a supported external file and uses the user's BYOK AI provider to convert it into a structured local draft. |
| **External import draft** | A structured, unsaved programme/workout generated from an external file. It requires validation, exercise matching, and user review before save. |
| **Extract/normalize/structure** | The default external import mode: preserve the source plan while converting it into app data. It does not adapt or rewrite the programme unless the user explicitly asks later. |
| **Exercise resolution** | The process of matching exercise names found in an imported file to local exercise IDs, or resolving them as custom exercises/removals. |
| **Unmatched exercise** | An imported exercise name that cannot be safely matched to the local exercise library. It must be matched, created as custom, or removed before save. |
| **Ambiguous exercise match** | A possible exercise match with insufficient confidence for automatic save. It requires user confirmation. |
| **AI-processing consent** | The required confirmation shown before extracted external file content is sent to the user's selected AI provider. |


| **Progress media session** | A timestamped visual progress check-in containing a photo set, a video, or both. |
| **Photo set** | A group of progress photos, ideally front, back, left-side, and right-side. |
| **All-sides video** | A short progress video intended to capture the user's physique from multiple angles. |
| **AI physique analysis** | Optional BYOK AI analysis of selected progress media that returns a rough body-fat range and training-oriented physique observations. |
| **Rough body-fat range** | An approximate visual estimate expressed as a range, not a precise measurement. |
| **Analysis snapshot** | The locally stored structured result returned from an AI physique-analysis call. |
| **Canonical video frames** | Representative frames extracted from a progress video, preferably front, back, left-side, and right-side views. |


| **Image / screenshot external import** | v1.10 extension of AI-assisted external import that converts selected screenshots/images into a structured local programme or workout draft. |
| **Image import package** | The set of selected original images, optional enhanced images, image order metadata, quality metadata, and import instructions sent to an image-capable BYOK provider after consent. |
| **Image readability enhancement** | Local-first preprocessing to improve legibility, such as rotation, crop, de-skew, brightness/contrast correction, sharpening, noise reduction, and upscaling. It must not change programme content. |
| **Enhanced image** | A temporary readability-improved version of an imported screenshot. It is not stored or exported by default. |
| **Unreadable region** | A portion of a screenshot that cannot be confidently read because it is blurry, cropped, low-resolution, obscured, or otherwise unclear. |
| **Image-capable provider/model** | A BYOK AI provider/model configuration that supports image input for multimodal analysis. |

---

## 15. Implementation Notes for Later

This PRD update does **not** require immediate Flutter implementation. It affects the design inputs for:

1. `ai-companion-instruction-set-v1.6.1.md`
2. per-call user-message templates
3. structured-output JSON schemas
4. validation rules
5. reference-selection logic
6. candidate-list ranking
7. optional UI labels
8. local sharing export/import schema
9. PDF export layout and privacy filtering
10. external file extraction pipeline
11. external import structured-output schemas
12. exercise matching and custom exercise draft review
13. progress media capture/import and local storage
14. progress media reminder scheduling
15. AI physique-analysis structured-output schemas
16. progress media consent and privacy filtering
17. image/screenshot external import flow
18. image readability preprocessing and temporary artifact cleanup
19. multimodal provider/model capability gating
20. image import structured-output metadata and prompt templates

No database migration is strictly required if the structured output is persisted as JSON payloads with optional nullable columns or extension metadata. If these fields are promoted to first-class Drift columns, a schema migration will be needed. The v1.7 sharing fields are optional nullable provenance/export fields and can be introduced through a small Drift migration when implementation begins. v1.8 external-import draft state can be implemented as temporary local state first, but persisted draft tables may be useful if imports need to survive app restarts. v1.9 progress media likely requires Drift migrations for media session metadata, media item metadata, reminder settings, and optional analysis snapshots; raw media remains file-based in local app storage rather than database blobs. v1.10 image import can initially keep original/enhanced images as temporary files plus JSON metadata in the import draft; if import sessions must survive app restarts, add temporary artifact metadata with expiry/cleanup rules.

---

## 16. Lock Status

This document remains **provisional** until explicitly approved as final.

Current locked working baseline:

> PRD v1.10 locks image/screenshot support for AI-Assisted External Programme / Workout Import. Users can import one or more supported image files, including PNG, JPG/JPEG, WEBP, and HEIC/HEIF where platform-supported, reorder screenshots before processing, and use local-first readability enhancement for low-quality images. Screenshot import requires an image-capable BYOK AI provider/model and explicit AI-processing consent before selected original or enhanced images are sent. Enhancement is strictly for readability and must not invent missing text, complete cropped tables, change numbers, or alter programme content. Image imports use the existing draft-and-review external import flow, preserve the source programme where visible, flag unclear or unreadable content, reuse existing exercise matching and validation rules, save imported plans inactive by default, and exclude original screenshots, enhanced images, image-processing artifacts, AI internals, private app data, and source-reference content from Crashlytics, `.aedifyplan`, PDF exports, and all plan-sharing/import/export flows.

Historical v1.9 lock retained:

> PRD v1.9 locks progress media tracking with optional AI physique analysis. Users can capture or import front, back, left-side, and right-side progress photos and/or a short all-sides progress video. Progress reminders start only after the first saved progress media session and may be scheduled every 2 weeks, monthly, every 3 months, or off. AI physique analysis is explicit-consent only, sends selected media or extracted frames to the user's BYOK provider, returns rough body-fat ranges with confidence and training-oriented physique feedback, and must not provide medical diagnosis, precise body-composition claims, attractiveness scoring, body shaming, or extreme dieting advice. Progress media and analysis results remain local by default and are excluded from Crashlytics, `.aedifyplan`, PDF exports, external imports, AI internals, private app data, and source-reference content.

---

**End of final v1 PRD.**
