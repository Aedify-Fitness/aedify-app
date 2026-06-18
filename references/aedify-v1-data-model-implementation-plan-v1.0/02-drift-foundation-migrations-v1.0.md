# 02 — Drift Foundation and Migration Plan v1.0

## 1. Purpose

This file defines the base Drift implementation structure, migration discipline, identifier strategy, converters, indexes, transaction rules, and test requirements.

---

## 2. Drift Module Layout

Recommended Flutter package layout:

```text
lib/
  data/
    database/
      app_database.dart
      converters/
        json_text_converter.dart
        enum_name_converter.dart
        utc_datetime_converter.dart
      tables/
        schema_meta_table.dart
        app_install_meta_table.dart
        exercises_tables.dart
        profile_tables.dart
        programme_tables.dart
        workout_log_tables.dart
        analytics_tables.dart
        progress_media_tables.dart
        ai_tables.dart
        sharing_tables.dart
        import_tables.dart
      daos/
        exercise_library_dao.dart
        profile_dao.dart
        programme_dao.dart
        workout_log_dao.dart
        analytics_dao.dart
        progress_media_dao.dart
        ai_dao.dart
        sharing_dao.dart
        import_dao.dart
      migrations/
        migration_v1.dart
        migration_test_helpers.dart
  data/
    files/
      app_file_store.dart
      progress_media_file_store.dart
      import_artifact_store.dart
      export_file_store.dart
  data/
    secure/
      secure_secret_store.dart
  data/
    preferences/
      simple_preferences_store.dart
```

### 2.1 DAO Boundary

DAOs should expose domain operations, not table-by-table primitive writes for complex flows.

Good examples:

```text
replaceExerciseLibraryAtomically(...)
saveGeneratedProgrammeAtomically(...)
completeWorkoutSessionAtomically(...)
deleteProgressMediaSessionWithFiles(...)
saveExternalImportDraft(...)
commitResolvedImportDraft(...)
saveAiGenerationSnapshot(...)
```

Avoid exposing low-level writes that allow partial save flows from UI code.

---

## 3. Base Tables

### 3.1 `schema_meta`

```text
schema_meta
  key text primary key
  value text not null
  updated_at datetime not null
```

Required keys:

```text
drift_schema_version
data_model_plan_version
firebase_exercise_supported_schema_min
firebase_exercise_supported_schema_max
share_schema_supported_version
ai_output_schema_supported_min
ai_output_schema_supported_max
instruction_set_version
```

### 3.2 `app_install_meta`

```text
app_install_meta
  id text primary key default 'singleton'
  install_id text not null
  first_opened_at datetime not null
  last_opened_at datetime nullable
  app_version_at_install text nullable
  current_app_version text nullable
  current_build_number text nullable
  created_at datetime not null
  updated_at datetime not null
```

`install_id` is local-only. Do not send it to AI. Avoid using it as a persistent analytics identity.

---

## 4. Identifier Strategy

| Entity Type | ID Type | Reason |
|---|---|---|
| Firebase exercise | `int` source ID | Matches dataset. |
| Custom exercise | Negative `int` or separate UUID table | Avoid collision with source dataset. |
| User-created app records | UUID string | Stable local references. |
| Programme revisions | UUID string | Supports revision history. |
| Import draft local refs | UUID string | AI may echo app-provided refs only. |
| Share external IDs | Random UUID in DTO | Not tied to local DB ID. |
| Progress media files | UUID-backed paths | Avoid exposing user names or dates in file names. |
| AI snapshots | UUID string | Local traceability without raw payloads. |

### 4.1 Custom Exercise ID Recommendation

Use negative integers for custom exercises if programme/set tables need a single `exercise_id int` foreign-key-like field.

Example:

```text
-1, -2, -3...
```

Add:

```text
is_custom bool default false
source_exercise_id int nullable
custom_exercise_uuid text nullable unique
```

Alternative: use polymorphic refs (`exercise_ref_type`, `exercise_ref_id`), but this makes joins and validation more complex. For v1, negative IDs are simpler.

---

## 5. Enum Storage

Store enums as text, not integer ordinal values.

Example values:

```text
experience_level: novice | beginner | intermediate | advanced
modality: strength | flexibility | cardio | recovery
set_type: warmup | working
programme_source: ai-generated | ai-chat | custom
creation_method: manual | ai_generated | ai_chat_save | ai_file_import
import_origin: external_file | aedifyplan
media_type: photo_set | video | both
pose: front | back | left_side | right_side | all_sides_video | unknown
```

Reason: text enum storage is easier to inspect, migrate, export, and validate.

---

## 6. JSON Field Policy

Use JSON text fields for:

- lists of simple values;
- optional metadata that changes more often than core query fields;
- AI structured-output extension metadata;
- validation issue arrays;
- media quality metadata;
- import warnings/blockers;
- source metadata.

Do not overuse JSON for fields that need frequent filtering, joining, sorting, or constraints.

### 6.1 JSON Fields Must Have Typed DTOs

Every JSON column should have a Dart model/converter.

Bad:

```text
Map<String, dynamic> everywhere
```

Good:

```text
ProgrammeProgressionRulesJson
WarmupWeightRuleJson
ImportValidationIssuesJson
ImageQualityMetadataJson
PhysiqueVisualObservationsJson
```

---

## 7. Date/Time Policy

- Store UTC timestamps.
- Use ISO 8601 text or integer epoch consistently according to Drift project convention.
- Convert to local time only at the UI boundary.
- For user-facing schedule dates, store both:
  - canonical date/time where needed;
  - local date fields where recurrence/calendar grouping needs day-level semantics.

Recommended:

```text
scheduled_date_local text nullable  // YYYY-MM-DD
scheduled_start_at_utc datetime nullable
completed_at_utc datetime nullable
```

---

## 8. Transaction Rules

Use a single transaction for:

| Flow | Required Atomicity |
|---|---|
| Exercise library replacement | Delete/replace source exercises + videos + library_meta update. |
| Save programme | Programme + templates + expanded schedule + sets + AI snapshot link. |
| Save saved workout | Workout + exercises + sets + source metadata. |
| Complete workout | Session + exercise logs + set logs + PR updates/cache invalidation. |
| Apply programme swap | Revision + affected future occurrences + template updates where safe. |
| Import `.aedifyplan` | Validate DTO + create local exercises + create inactive plan. |
| Commit external import | Draft status update + create programme/workout + match links. |
| Delete progress media session | DB row deletions + file deletion coordination with recovery handling. |
| Save physique analysis | Consent record + snapshot + media refs. |

### 8.1 File + DB Transaction Pattern

SQLite transactions cannot include filesystem operations. Use a two-phase pattern:

1. Prepare files in temporary path.
2. Write DB transaction referencing final relative paths.
3. Move files into final paths.
4. If move fails, rollback/cleanup via recovery job.
5. On app startup, cleanup orphan temp files and orphan DB file refs.

---

## 9. Migration Sequence by Milestone

| Milestone | Migration Focus |
|---|---|
| M1 | Base tables, schema meta, app install meta. |
| M2 | Exercise library tables, library meta, videos, audio cache metadata. |
| M3 | Profile, settings, provider metadata, body measurements, strength anchors. |
| M4 | Programmes, saved workouts, templates, expanded instances, workout sessions, set logs. |
| M5 | PRs, plateau flags, analytics cache tables if used. |
| M6 | Progress media sessions/items/reminder settings. |
| M7 | AI provider capabilities, chat tables, generation snapshots, validation events. |
| M8 | AI-generated programme/workout metadata fields and snapshot links. |
| M9 | Chat save, update flows, programme revisions. |
| M10 | Share/export provenance, export events, share import metadata. |
| M11 | External import drafts, match records, custom exercise drafts. |
| M12 | Image import artifact metadata and quality metadata. |
| M13 | Physique analysis snapshots, media refs, consent records. |
| M14 | Hardened cleanup, audit tables if needed, final migration test coverage. |

---

## 10. Minimum Indexes

Add indexes for:

```text
exercises(name_normalized)
exercises(difficulty)
exercises(modality)
exercises(equipment)
programs(status)
programs(source)
programs(active)
program_workouts(program_id, scheduled_date_local)
workout_sessions(started_at)
workout_sessions(program_id)
set_logs(exercise_id, performed_at)
set_logs(workout_session_id)
set_logs(is_pr)
plateau_flags(exercise_id, status)
progress_media_sessions(captured_at)
progress_media_items(session_id)
chat_messages(thread_id, created_at)
ai_generation_snapshots(operation_category, created_at)
import_drafts(status, created_at)
```

JSON array fields such as `muscle_groups_json` may need app-side filtering unless SQLite JSON1 is confirmed and wrapped safely.

---

## 11. Soft Delete vs Hard Delete

| Entity | Delete Strategy | Rationale |
|---|---|---|
| Exercise dataset records | Replace on sync | Source data refresh. |
| Custom exercises | Soft delete if referenced; hard delete if unused | Preserve historical logs. |
| Programmes | Soft delete/archive | Preserve logs and history. |
| Saved workouts | Soft delete/archive | Preserve history. |
| Workout sessions | Hard delete only by explicit user action | User-owned logs. |
| Set logs | Delete with session only | Avoid orphan logs. |
| Progress media | Hard delete files and DB refs by user request | Privacy. |
| Import drafts | Hard delete on cancel/expiry | Temporary by nature. |
| AI chats | User-controlled delete | Privacy. |
| AI snapshots | Delete with parent content or by privacy cleanup | Local trace only. |

---

## 12. Migration Testing Requirements

Each migration must have tests for:

1. Empty database install.
2. Upgrade from immediately previous schema.
3. Idempotent app open after successful migration.
4. Failed migration leaves DB recoverable.
5. User-created data retained.
6. Dataset source records refresh without deleting custom records.
7. JSON converters decode existing rows.
8. Unknown enum values fail gracefully or map to `unknown` only where allowed.
9. File paths remain relative and valid.
10. Privacy-sensitive tables are not included in diagnostics.

---

## 13. Drift Acceptance Gate

M1 cannot close until:

- Drift opens on iOS and Android.
- Schema meta is readable.
- Migration test harness runs.
- Transaction helper exists.
- JSON converter pattern is established.
- Redacted database error reporting is implemented.
- No API key value can be written to Drift by any secure-storage adapter test.
