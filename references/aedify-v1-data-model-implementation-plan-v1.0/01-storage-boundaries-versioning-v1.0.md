# 01 — Storage Boundaries, Versioning, Units, and Privacy Classes v1.0

## 1. Purpose

This file defines the non-negotiable storage boundaries for v1. It exists to prevent accidental leakage, avoid misuse of `shared_preferences`, and keep the local-only/offline-first architecture consistent across implementation.

---

## 2. Storage Ownership Matrix

| Data Type | Store In | Never Store In | Reason |
|---|---|---|---|
| Exercise dataset records | Drift | `shared_preferences`, secure storage | Structured queryable data with migrations. |
| Exercise dataset JSON download | Temporary app cache during sync | Permanent user export | Source payload is replaced atomically after validation. |
| Exercise library version | Drift `library_meta` | Secure storage | Non-secret structured metadata. |
| Custom exercises | Drift | Firebase, shared prefs | User-created durable structured records. |
| User profile | Drift | Crashlytics, exports by default | Durable user data, privacy-sensitive. |
| Goals/equipment/injuries/substitutions | Drift | Crashlytics, shared prefs | Used by AI and generation; must be queryable and protected. |
| BYOK API keys | `flutter_secure_storage` | Drift, files, shared prefs, logs, Crashlytics | Secrets only. |
| AI provider display metadata | Drift | Secure storage for non-secret fields | Queryable app configuration; no secret value. |
| Simple non-critical app toggles | `shared_preferences` | Secure storage | Safe to reset; not business-critical. |
| Programmes/workout templates | Drift | shared prefs, raw export | Durable relational data. |
| Expanded programme workouts | Drift | shared prefs | Required for schedule, logs, swaps, revisions. |
| Set logs | Drift | Crashlytics, shared prefs | Core training history. |
| Analytics cache | Drift or computed in memory | Crashlytics | Local derivation from set logs. |
| Progress media metadata | Drift | shared prefs, Crashlytics | Queryable timeline and deletion coordination. |
| Progress photos/videos/thumbnails | App sandbox files | Drift blobs, Crashlytics, exports by default | Large binary media; local-only. |
| Extracted video frames | App sandbox files | Drift blobs, Crashlytics | Temporary or media-linked files. |
| AI physique analysis snapshots | Drift | exports by default, Crashlytics | Local-only structured results. |
| Chat messages | Drift | Crashlytics, exports by default | Local private conversation history. |
| Raw AI prompts/responses | Not persisted | All stores unless future explicit debug mode | Privacy and provider data-minimization. |
| AI generation snapshots | Drift sanitized summary only | Crashlytics | Supports traceability without storing raw provider payloads. |
| External import source files | Temporary files only unless future explicit retention | Exports, Crashlytics | Source file content excluded by default. |
| External import drafts | Drift or temporary state | shared prefs | Must survive validation/review if persisted. |
| Image import original/enhanced files | Temporary app sandbox files | Exports, Crashlytics, long-term media store | Must be deleted after import flow. |
| `.aedifyplan` file | Temporary export file | Permanent app DB | Generated from sanitized DTO. |
| PDF export file | Temporary export file | Permanent app DB | Human-readable read-only artifact. |

---

## 3. Version Tracks

The app must not conflate version numbers.

| Version Track | Stored Where | Example Field | Migration/Compatibility Rule |
|---|---|---|---|
| Drift DB schema | Drift generated schema + `schema_meta` | `drift_schema_version` | App migration code owns this. |
| Firebase exercise dataset schema | Dataset payload and manifest | `schema_version`, `min_app_schema_version` | Compatible schemas migrate locally; unsupported future schemas block. |
| Firebase library content version | `library_meta` | `library_version`, `latest_version` | Controls dataset refresh. |
| `.aedifyplan` share schema | Share file DTO | `share_schema_version` | Unsupported share schema rejected unless migratable. |
| AI structured-output schema | AI snapshot and validation code | `ai_output_schema_version` | Separate from Drift and share schema. |
| Prompt/instruction-set version | Prompt metadata | `instruction_set_version` | Stored as metadata only; not a DB schema. |
| App binary version | App metadata | `app_version`, build number | Used in exports and diagnostics. |

### 3.1 Required `schema_meta` Rows

`schema_meta` should be a key-value table, not hardcoded constants only.

Recommended keys:

```text
drift_schema_version
firebase_exercise_supported_schema_min
firebase_exercise_supported_schema_max
last_successful_exercise_library_version
share_schema_supported_version
ai_output_schema_supported_min
ai_output_schema_supported_max
instruction_set_version
data_model_plan_version
```

---

## 4. Canonical Units

All persisted numeric values must use canonical units.

| Domain | Canonical Unit | UI Conversion |
|---|---|---|
| Bodyweight | kg | Display kg/lb based on profile. |
| Lift weight | kg | Display kg/lb based on profile. |
| Height/length | cm | Display cm/ft-in based on profile. |
| Distance | meters | Display meters/km/miles where needed. |
| Duration | seconds | Display minutes/seconds. |
| Rest time | seconds | Display minutes/seconds. |
| Dates/times | UTC timestamp + local display | Display in device timezone. |
| Body-fat estimate | percentage range | Show as range only. |

### 4.1 Conversion Rule

The UI may accept either kg/lb and cm/ft-in, but persistence must convert before writing to Drift. Store the user's preferred display unit separately; never use it to change stored units.

---

## 5. Privacy Classes

| Class | Examples | Allowed in Drift | Allowed in Files | Allowed in Secure Storage | Allowed in Crashlytics | Allowed in Export |
|---|---|---:|---:|---:|---:|---:|
| Public static | Exercise names, categories, videos | Yes | Optional cache | No | Yes, if non-user-specific | Yes, if part of plan |
| Local personal | Profile, goals, logs, measurements | Yes | No, unless file-backed | No | No | No by default |
| Secret | API keys | No | No | Yes | No | No |
| Local media | Progress photos/videos | Metadata only | Yes | No | No | No by default |
| Temporary import artifact | Source files, screenshots, enhanced images | Metadata only if needed | Yes, temporary | No | No | No |
| AI internal | Prompts, responses, candidate lists, validation errors | Sanitized summaries only | No | No | No | No |
| Exportable plan content | Programmes/workout templates | Yes | Generated export only | No | No | Yes, sanitized |
| Diagnostic safe | App version, OS, screen, non-sensitive error code | Optional | No | No | Yes | No |

---

## 6. Crashlytics Allowlist

Crashlytics must use an allowlist, not a denylist.

Allowed:

```text
app_version
build_number
platform
os_version
device_model
screen_name
route_name
non_sensitive_feature_flag
drift_schema_version
exercise_dataset_schema_version
exercise_library_version
error_code
redacted_stack_trace
operation_name_without_payload
```

Forbidden:

```text
API keys
prompt text
AI responses
chat history
structured output JSON
candidate exercise lists
injuries
limitations
lift logs
set logs
body measurements
profile notes
free-form notes
progress media file paths
progress photos
progress videos
thumbnails
extracted frames
physique-analysis results
original screenshots
enhanced screenshots
image-processing artifacts
source-file excerpts
local database rows
local database dumps
export file contents
Firebase Storage URLs that reveal user state
```

---

## 7. File Path Ownership

Recommended app sandbox layout:

```text
/app_support/
  db/
    ai_gym_companion.sqlite
  media/
    progress/
      sessions/{session_id}/
        originals/
        thumbnails/
        frames/
  imports/
    temp/{import_draft_id}/
      extracted/
      images_original/
      images_enhanced/
  exports/
    temp/
      aedifyplan/
      pdf/
  audio-cache/
    exercise_steps/{exercise_id}/
```

### 7.1 Path Storage Rule

Drift may store relative file paths rooted at the app support directory. Avoid storing absolute platform-specific paths if possible because app container paths may change across reinstalls, backups, or OS-level moves.

### 7.2 File Integrity Fields

For file-backed records, store:

```text
local_relative_path
file_size_bytes
content_hash nullable
width nullable
height nullable
duration_seconds nullable
created_at
last_verified_at nullable
```

### 7.3 Cleanup Ownership

| File Type | Cleanup Trigger |
|---|---|
| Temporary import extracted text | Save, cancel, expiry, failed import cleanup. |
| Temporary original/enhanced screenshots | Save, cancel, expiry, app startup cleanup. |
| Temporary `.aedifyplan` export | After share completes where possible; startup cleanup. |
| Temporary PDF export | After share completes where possible; startup cleanup. |
| Progress media original | User deletes media/session. |
| Progress thumbnail | Delete with parent media item. |
| Extracted video frame | Delete with parent video/session unless retained for analysis snapshot view. |
| Exercise audio cache | User clears cache or app storage pressure cleanup. |

---

## 8. `shared_preferences` Boundary

Allowed examples:

```text
has_seen_onboarding_intro
last_selected_tab
theme_mode
non-sensitive UI collapse states
last_opened_library_filter if recoverable
feature_flag_overrides for local development only
```

Forbidden examples:

```text
API keys
provider secrets
profile
injuries
goals
equipment access
programmes
saved workouts
set logs
import drafts
AI outputs
chat messages
progress media records
progress media paths
body measurements
Crashlytics redaction state
schema versions required for migration safety
```

If loss of the value would corrupt the user's app state, it does not belong in `shared_preferences`.

---

## 9. Secure Storage Boundary

Secure storage may contain:

```text
ai_provider_api_key:{provider_id}
ai_provider_secret_alias:{provider_id}
optional provider-specific encrypted token if needed later
```

Secure storage must not contain:

```text
profile
programmes
logs
chat history
AI responses
progress media paths
database rows
non-secret settings
```

### 9.1 Secret Alias Pattern

Drift stores a non-secret alias:

```text
provider_id = "openai"
secure_key_alias = "ai_provider_api_key:openai"
key_last_validated_at = datetime nullable
```

The secret value is retrieved only at call time and never logged.

---

## 10. Export Boundary

Exports must be generated from explicit DTOs.

Never export:

```text
profile
injuries
body measurements
progress media
progress analysis
logs unless export mode later explicitly adds them
API keys
chat history
prompt text
raw AI responses
candidate lists
AI generation snapshots
source files
screenshots
enhanced screenshots
image artifacts
Crashlytics metadata
local database IDs that are not needed for import resolution
```

Allowed in `.aedifyplan`:

```text
share_schema_version
exported_at
app metadata
content_type
privacy_mode
programme/workout template content
exercise resolution block
custom exercise definitions required by the plan
source_metadata without private or source-file excerpts
```

Allowed in PDF:

```text
human-readable programme/workout summary
prescription tables
blank/open logging tables
optional exercise instructions appendix
privacy warning if exact prescription mode
```

---

## 11. AI Prompt Boundary

Every AI request must have an operation-specific prompt DTO. The app must not pass full Drift rows.

Examples:

| AI Operation | May Include | Must Exclude |
|---|---|---|
| Programme generation | Profile summary, goals, equipment, recent logs slice, candidate list, schemas | API keys, full DB, progress media, raw private notes unrelated to task |
| External text import parse | Extracted programme-relevant text/tables, file type, schema | Full profile, logs, injuries, measurements, chat history |
| Image import parse | Selected/enhanced images, order metadata, quality metadata, import instructions | API keys, logs, full profile, unrelated progress media |
| Progress physique analysis | Selected progress media/frames and minimal comparison metadata after consent | Logs, programme library, API keys, unrelated profile data |
| Exercise match assist | Unresolved exercise names and candidate exercises | Profile/logs unless required for matching, raw source file |

---

## 12. Implementation Acceptance Gate

Before any milestone that writes data is marked complete:

- The storage owner is documented.
- The table/file path exists or is intentionally deferred.
- Secrets are verified to stay in secure storage only.
- Crashlytics redaction tests cover the new domain.
- Export filtering tests cover the new domain.
- Deletion tests cover the new domain.
- Migration tests cover upgrade from prior schema.
- Transaction tests cover partial failure.
