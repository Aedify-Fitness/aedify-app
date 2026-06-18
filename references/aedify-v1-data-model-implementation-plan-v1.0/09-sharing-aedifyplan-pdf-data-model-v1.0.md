# 09 — Sharing, `.aedifyplan`, and PDF Export Data Model v1.0

## 1. Purpose

This file defines the data model and DTO boundaries for local file-based sharing and PDF export. Sharing is local file export/import only. There are no hosted links, accounts, public marketplace, cloud sharing, or social features in v1.

---

## 2. Export Principle

Never serialize Drift rows directly.

Always build a sanitized DTO:

```text
Drift domain rows
  -> export mapper
  -> sanitized share/pdf DTO
  -> local temp file
  -> OS share sheet
```

The mapper is a privacy boundary.

---

## 3. Programme and Workout Provenance Fields

Programmes and saved workouts already include:

```text
imported bool
imported_at datetime nullable
share_schema_version int nullable
external_share_id text nullable
export_privacy_mode text nullable
creation_method
import_origin
source_file_retained
```

These fields support both imported plans and future exports.

---

## 4. `.aedifyplan` Top-Level DTO

```json
{
  "share_schema_version": 1,
  "exported_at": "2026-06-12T00:00:00Z",
  "app": {
    "name": "Aedify",
    "export_format": "aedifyplan",
    "app_version": "1.0.0",
    "build_number": "1"
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

### 4.1 `content_type`

Allowed:

```text
program
saved_workout
```

### 4.2 `privacy_mode`

Allowed:

```text
template
exact_prescription
```

Default: `template`.

`exact_prescription` requires explicit privacy warning before export.

---

## 5. Export DTO Must Exclude

```text
profile
injuries
goals unless needed as generic plan tags
body measurements
progress media
progress analysis
workout logs
set logs
PRs
plateau flags
API keys
chat history
prompt text
raw AI responses
candidate lists
AI generation snapshots
source file contents
original screenshots
enhanced screenshots
image artifacts
local absolute file paths
Crashlytics metadata
```

---

## 6. Export DTO May Include

```text
programme/workout name
description
template structure
weeks/days/workouts
exercise IDs and names
custom exercise definitions needed to use the plan
set prescriptions according to privacy mode
rest times
RPE/RIR prescriptions
progression/deload notes if part of plan
source metadata that does not include source excerpts
```

---

## 7. Imported `.aedifyplan` Validation

Before DB write:

```text
validate JSON parse
validate share_schema_version
validate content_type
validate required fields
validate exercise references
validate custom exercise definitions
validate programme/workout structure
validate set prescriptions
validate no forbidden fields present
preview to user
save inactive by default
```

Unsupported share schema versions are rejected unless locally migratable.

---

## 8. Custom Exercises in Share Files

Shared custom exercises should include full local definitions needed by the plan.

On import:

```text
create new local custom exercise ID
do not reuse sender local ID
store original_share_key for traceability
map plan references to new local IDs
```

---

## 9. Export Events

Optional local table:

```text
export_events
  id text primary key
  entity_type text not null              // program | saved_workout
  entity_id text not null
  export_format text not null            // aedifyplan | pdf | both
  privacy_mode text nullable
  share_schema_version int nullable
  exported_at datetime not null
  temp_file_deleted_at datetime nullable
```

Do not store exported file content.

---

## 10. PDF DTO

PDF export should use a separate DTO from `.aedifyplan`.

PDF sections:

```text
title page
programme/workout summary
privacy mode note
weekly schedule
workout prescription summaries
blank/open logging tables
optional exercise instructions appendix
```

PDF is read-only and not importable in v1.

---

## 11. Temporary Files

Recommended:

```text
exports/temp/aedifyplan/{export_id}.aedifyplan
exports/temp/pdf/{export_id}.pdf
```

Cleanup:

```text
after OS share completes where possible
on app startup for expired temp exports
when user manually clears temp files
```

---

## 12. Acceptance Tests

M10 cannot close until:

- A saved workout exports as `.aedifyplan`.
- A programme exports as `.aedifyplan`.
- Both import on another local install as inactive editable copies.
- Custom exercises are recreated with new local IDs.
- PDF export includes prescription summaries and blank logging tables.
- PDF is not importable.
- Exact prescription mode shows privacy warning.
- Export DTO contains no forbidden data.
- Crashlytics receives no export contents.
