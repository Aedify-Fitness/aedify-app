# 10 — External Text File Import Data Model v1.0

## 1. Purpose

This file defines the data model for AI-assisted external programme/workout import from text-based PDF, TXT, MD, XLSX, and CSV files.

The import flow creates a structured local draft, requires user review, resolves exercise matches, and saves the imported item inactive by default.

---

## 2. Import Draft Storage

External imports may initially be in memory, but persisted draft tables are recommended so imports can survive app restarts.

### 2.1 `import_drafts`

```text
import_drafts
  id text primary key
  source_input_type text not null          // text_file | image_screenshot
  import_kind text nullable                // program | saved_workout | unknown
  status text not null                     // extracting | ai_pending | ai_parsed | needs_review | blocked | saved | cancelled

  file_type text nullable                  // pdf | txt | md | xlsx | csv
  original_file_name text nullable
  source_file_retained bool not null default false

  extracted_content_hash text nullable
  extracted_summary_json text nullable
  detected_units text nullable             // metric | imperial | mixed | unknown

  ai_generation_snapshot_id text nullable
  ai_output_schema_version int nullable

  parsed_programme_json text nullable       // draft DTO, not final domain row
  parsed_workout_json text nullable

  missing_or_unclear_items_json text not null default '[]'
  validation_blockers_json text not null default '[]'
  validation_warnings_json text not null default '[]'

  review_status text not null default 'pending_review'
  saved_entity_type text nullable           // program | saved_workout
  saved_entity_id text nullable

  created_at datetime not null
  updated_at datetime not null
  expires_at datetime nullable
```

---

## 3. Import Exercise Matches

```text
import_exercise_matches
  id text primary key
  import_draft_id text not null
  source_exercise_name text not null
  source_exercise_name_normalized text not null

  match_status text not null               // exact | alias | ambiguous | unmatched | custom_created | removed
  matched_exercise_id int nullable
  confidence text nullable                 // low | medium | high
  candidate_exercise_ids_json text nullable

  user_confirmed bool not null default false
  user_decision text nullable              // accepted | changed | custom_created | removed

  ai_match_snapshot_id text nullable
  created_at datetime not null
  updated_at datetime not null
```

Ambiguous matches require confirmation. Unmatched exercises must be matched, created as custom, or removed before save.

---

## 4. Custom Exercise Drafts

```text
import_custom_exercise_drafts
  id text primary key
  import_draft_id text not null
  source_exercise_name text not null
  proposed_name text not null
  proposed_muscle_groups_json text nullable
  proposed_modality text nullable
  proposed_equipment text nullable
  proposed_steps_json text nullable
  user_confirmed bool not null default false
  created_exercise_id int nullable
  created_at datetime not null
  updated_at datetime not null
```

AI may prefill metadata, but the user must confirm required fields before save.

---

## 5. Validation Blockers

Block save if:

```text
programme/workout type is unknown
required programme/workout name missing
all exercises missing
any exercise remains unmatched or ambiguous
required set/rep fields are impossible to interpret
units create unsafe ambiguity for loads
schema validation fails
AI output response type wrong
AI invented local IDs
AI invented exercise IDs outside candidate list
```

---

## 6. Review Warnings

Allow save with warnings if:

```text
rest times missing
RPE/RIR missing
progression rules missing
deload rules missing
duration shorter than 8 weeks because source file is shorter
optional cues/instructions missing
some fields marked unclear but non-critical
```

---

## 7. Save Flow

```text
draft parsed
exercise matching completed
user resolves blockers
preview final imported item
transaction:
  create custom exercises if any
  create inactive programme or saved workout
  map imported exercises to local IDs
  store provenance fields
  mark draft saved
cleanup temp source artifacts unless retained by explicit future feature
```

Imported programme/workout:

```text
source = custom
creation_method = ai_file_import
import_origin = external_file
imported = true
source_file_retained = false
status = inactive
```

---

## 8. Privacy Rules

Default import parse prompt may include:

```text
file type
extracted programme-relevant text/tables
schema
candidate exercises where needed
```

Default import parse prompt must exclude:

```text
full athlete profile
lift logs
injuries
body measurements
chat history
progress media
AI generation snapshots
API keys
unrelated private app data
```

Original source files are not stored by default and must not be exported.

---

## 9. Acceptance Tests

M11 cannot close until:

- TXT/MD/CSV/XLSX/text PDF import can create draft.
- AI parse creates structured draft only.
- Draft is not persisted as programme until review/save.
- Ambiguous matches require user confirmation.
- Unmatched exercises block save.
- Custom exercise draft requires user confirmation.
- Imported programme saves inactive by default.
- Original source content is not included in `.aedifyplan` or PDF export.
- Import prompts exclude profile/log/private data by default.
