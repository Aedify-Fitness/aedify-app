# Aedify — Data Model Implementation Plan v1.0

| Field | Value |
|---|---|
| Document Package | Data Model Implementation Plan |
| Package Version | v1.0 |
| Source Baseline | PRD v1.10 Final / Re-locked after Package Validation |
| Roadmap Baseline | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Architecture Baseline | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Feature Plan Baseline | `v1-feature-by-feature-build-plan-v1.0/` |
| Status | Implementation Planning |
| Scope Rule | No product scope change; implementation-only breakdown |
| Platforms | iOS and Android |
| App Architecture | Local-only, offline-first, BYOK AI |
| Durable Data Store | Drift / SQLite |
| Simple Preferences | `shared_preferences` only for non-critical values |
| Secrets Store | `flutter_secure_storage` only |
| File Store | App sandbox |
| Remote Runtime Data Source | Firebase Storage exercise dataset only |
| Created | 2026-06-12 |

---

## 1. Purpose

This package converts the locked v1 PRD, architecture plan, and feature build plan into an implementation-ready data model.

It answers:

1. Which data belongs in Drift.
2. Which data belongs in secure storage.
3. Which data may use `shared_preferences`.
4. Which data belongs as files in the local app sandbox.
5. Which data is temporary and must be deleted.
6. Which schema versions must remain independent.
7. Which database writes must be transactional.
8. Which data is forbidden from Crashlytics, exports, prompts, and share files.
9. Which migrations are required by milestone.
10. Which tests prove the data model is safe to implement.

This is a data implementation plan, not a product-scope update.

---

## 2. Source Documents

| Source | Role |
|---|---|
| `PRD-Aedify-v1-FINAL-relocked.md` | Locked product, privacy, architecture, and functional baseline. |
| `aedify-package-validation-decision-log-v1.md` | Final implementation stack correction. |
| `aedify-ai-companion-instruction-set-v1.10.md` | AI prompt, structured output, provider capability, and redaction rules. |
| `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` | Current milestone order and implementation sequencing. |
| `aedify-v1-architecture-implementation-plan-v1.0.md` | Layering, module ownership, and tech-stack implementation plan. |
| `v1-feature-by-feature-build-plan-v1.0/` | Feature-level build requirements by milestone. |
| `aedify-musclewiki-exercises.firebase.json` | Current exercise dataset shape and schema version. |
| `aedify-transform-for-firebase.js` | Exercise build-pipeline normalization rules. |

---

## 3. Package File Map

| File | Covers |
|---|---|
| `00-data-model-plan-index-v1.0.md` | Package index, scope, milestone mapping, file map. |
| `01-storage-boundaries-versioning-v1.0.md` | Storage ownership, schema versions, units, privacy classes, file paths. |
| `02-drift-foundation-migrations-v1.0.md` | Drift project structure, base tables, IDs, converters, migrations, indexes. |
| `03-exercise-library-data-model-v1.0.md` | Firebase exercise dataset, exercise tables, videos, audio cache, bodymap data. |
| `04-profile-settings-secure-preferences-v1.0.md` | Profile, goals, equipment, settings, preferences, secure API-key references. |
| `05-programmes-workouts-logging-data-model-v1.0.md` | Programmes, workout templates, expanded workouts, saved workouts, logs. |
| `06-analytics-prs-plateau-data-model-v1.0.md` | e1RM, PRs, volume, trends, plateau flags, analytics cache boundaries. |
| `07-progress-media-data-model-v1.0.md` | Progress media sessions, media items, thumbnails, reminders, comparisons. |
| `08-ai-data-model-structured-output-chat-v1.0.md` | AI provider metadata, chat, generation snapshots, validation events. |
| `09-sharing-aedifyplan-pdf-data-model-v1.0.md` | `.aedifyplan`, PDF export DTOs, sanitized export/import state. |
| `10-external-import-data-model-v1.0.md` | Text-based external import drafts, exercise matching, custom exercise drafts. |
| `11-image-import-data-model-v1.0.md` | Screenshot/image import metadata, temporary artifacts, enhancement tracking. |
| `12-physique-analysis-data-model-v1.0.md` | AI physique analysis snapshots, media refs, consent records. |
| `13-privacy-retention-deletion-data-rules-v1.0.md` | Retention, deletion, redaction, export filtering, Crashlytics allowlist. |
| `14-migration-test-acceptance-checklist-v1.0.md` | Migration sequence, data tests, acceptance gates, backlog ticket seeds. |
| `manifest.json` | Machine-readable package manifest. |

---

## 4. Current Milestone Order Used by This Plan

The data model follows the current roadmap v1.3 milestone sequence:

| Milestone | Name | Data Model Impact |
|---|---|---|
| M0 | Implementation Lock & Backlog Setup | Confirms versioning and schema-governance process. |
| M1 | App Foundation + Local Data Spine | Drift foundation, migrations, storage wrappers, secure storage wrappers. |
| M2 | Exercise Dataset Sync + Exercise Library | Firebase dataset cache, exercise tables, videos, audio cache, bodymap mapping. |
| M3 | Onboarding, Profile, Settings, BYOK Setup | Profile, settings, provider metadata, secure key aliases. |
| M4 | Manual Programmes, Workouts, and Logging | Programmes, templates, saved workouts, workout sessions, set logs. |
| M5 | Analytics, PRs, and Plateau Base Logic | e1RM, PRs, trends, plateau flags. |
| M6 | Progress Media Tracking | Progress media sessions, media items, reminders, comparison metadata. |
| M7 | AI Infrastructure | AI provider metadata, generation snapshots, validation/repair events. |
| M8 | AI Workout + Programme Generation | AI-generated programme/workout persistence, snapshots, schema-version links. |
| M9 | AI Trainer Chat + AI Update Flows | Chat, save-from-chat, swaps, deloads, programme revisions. |
| M10 | Local Sharing + PDF Export | Share DTOs, export events, import provenance. |
| M11 | External Text File Import | Import drafts, extraction metadata, exercise match state, custom exercise drafts. |
| M12 | Image/Screenshot External Import | Image import artifact metadata, quality metadata, cleanup state. |
| M13 | Optional AI Physique Analysis | Analysis snapshots, media refs, consent tracking. |
| M14 | Privacy, Resilience, and Release Hardening | Data audit, migration tests, redaction tests, deletion tests. |

---

## 5. Global Data Model Principles

1. **Drift owns durable structured app data.** This includes exercises, programmes, templates, logs, imports, progress media metadata, schema versions, and local metadata.
2. **The app sandbox owns binary/user files.** This includes progress photos, videos, thumbnails, extracted video frames, temporary import images, temporary exports, and optional audio cache.
3. **`shared_preferences` is not a data store.** It is only for non-critical, non-sensitive settings that can be safely reset.
4. **`flutter_secure_storage` stores secrets only.** API keys and secret tokens never go into Drift, files, logs, exports, prompts, Crashlytics, or shared preferences.
5. **Exports are DTO-driven.** Never serialize Drift rows directly into `.aedifyplan` or PDF.
6. **Prompts are DTO-driven.** Never pass entire local rows to AI. Build prompt payloads from explicit, minimal, operation-specific DTOs.
7. **Crashlytics is deny-by-default.** Only redacted, low-sensitivity diagnostic metadata may be attached.
8. **Schema versions are independent.** Drift, Firebase dataset, share files, AI structured output, prompt files, and app version all evolve separately.
9. **All persistence paths must be reviewable and testable.** Any user-facing save flow should have a deterministic validation gate before write.
10. **No migration may destroy user-created data.** Dataset refreshes may replace Firebase exercises, but custom exercises, logs, programmes, and user flags must be preserved.

---

## 6. Entity Ownership Summary

| Domain | Primary Storage | Secondary Storage | Notes |
|---|---|---|---|
| Exercise library | Drift | Firebase Storage source JSON | Runtime app does not call MuscleWiki. |
| Exercise videos | Drift URLs/metadata | Remote video URLs | Video bytes are not stored by default. |
| Exercise step audio | Drift metadata | App sandbox cache | Cache is optional and purgeable. |
| User profile | Drift | None | Sensitive enough to keep out of logs/Crashlytics. |
| BYOK keys | Secure storage | Drift stores alias only | API key value never leaves secure storage except during provider call. |
| UI preferences | `shared_preferences` or Drift | None | Use shared prefs only when value is non-critical and non-sensitive. |
| Programmes/workouts/logs | Drift | None | Transactional writes required. |
| Progress media metadata | Drift | App sandbox files | Media bytes never in DB. |
| Progress media files | App sandbox | Drift paths | Delete files and DB refs together. |
| AI chats | Drift | None | Chat history local only. |
| AI raw prompts/responses | Not persisted | Not applicable | Store sanitized summaries only. |
| `.aedifyplan` export | Temporary file | Sanitized DTO | Delete temp file after share when practical. |
| PDF export | Temporary file | Sanitized DTO | Read-only, not importable. |
| External import drafts | Drift or temporary state | Temp extracted artifacts | Persist draft if imports should survive restart. |
| Image import artifacts | Temporary files + optional Drift metadata | None | Delete after save/cancel/expiry. |

---

## 7. Versioning Rule

Every artifact this plan creates or references must include a version in either the file name, schema field, or both.

| Artifact | Required Version |
|---|---|
| Data model plan package | `v1.0` in folder, zip, and file names. |
| Drift database | `schemaVersion` plus `schema_meta` rows. |
| Firebase exercise dataset | `schema_version` and library manifest version. |
| `.aedifyplan` | `share_schema_version`. |
| AI structured outputs | `ai_output_schema_version`. |
| Instruction set | Instruction-set file version. |
| Prompt templates | Prompt template version or instruction-set package version. |
| App binary | App version/build number. |

---

## 8. Implementation Hand-off

Implementation should start with:

1. `01-storage-boundaries-versioning-v1.0.md`
2. `02-drift-foundation-migrations-v1.0.md`
3. `03-exercise-library-data-model-v1.0.md`

The rest of the package follows milestone order.

---

## 9. Completion Definition for This Data Model Plan

This package is complete when:

- Every v1 feature domain has an assigned storage owner.
- Every durable entity has a proposed Drift table or explicit reason not to.
- Every file-backed entity has path ownership and delete behavior.
- Every secret has a secure-storage-only rule.
- Every export/import flow uses a sanitized DTO boundary.
- Every AI flow uses minimal prompt payloads and local validation state.
- Every milestone has migration and testing implications documented.
- Every privacy-sensitive field has explicit redaction/exclusion behavior.
