# 03 — Exercise Library Data Model v1.0

## 1. Purpose

This file defines the local representation of the Firebase-hosted exercise dataset, including exercise records, videos, bodymap mapping, audio cache metadata, sync metadata, custom exercise coexistence, and AI candidate DTOs.

---

## 2. Source Dataset Contract

The runtime app downloads a versioned JSON file from Firebase Storage, validates it, and persists the full exercise library into Drift.

Current dataset payload shape:

```text
schema_version
generated_at
source
exercise_count
exercises[]
```

Each exercise contains source and derived fields:

```text
id
name
difficulty
primary_muscles
muscle_groups
category
modality
equipment
force
mechanic
grips
steps
videos
```

The app does not call MuscleWiki at runtime.

---

## 3. Tables

### 3.1 `library_meta`

```text
library_meta
  id text primary key default 'exercise_library'
  source text not null                       // musclewiki-api-v1
  schema_version int not null
  library_version text nullable              // manifest latest_version
  generated_at datetime nullable
  downloaded_at datetime nullable
  exercise_count int not null default 0
  manifest_last_updated_at datetime nullable
  manifest_file_path text nullable
  min_app_schema_version int nullable
  sync_status text not null                  // never_synced | syncing | synced | failed
  last_sync_error_code text nullable
  last_sync_error_message text nullable redacted
  created_at datetime not null
  updated_at datetime not null
```

### 3.2 `exercises`

```text
exercises
  id int primary key
  is_custom bool not null default false
  custom_exercise_uuid text nullable unique

  source text not null                       // firebase_dataset | custom | imported_share
  source_dataset_version text nullable
  source_schema_version int nullable

  name text not null
  name_normalized text not null
  difficulty text nullable                   // novice | beginner | intermediate | advanced
  primary_muscles_json text not null         // JSON string[]
  muscle_groups_json text not null           // JSON string[] of 14 UI buckets
  category text nullable
  modality text not null                     // strength | flexibility | cardio | recovery
  equipment text nullable
  force text nullable                        // Push | Pull | Hold | null
  mechanic text nullable                     // Compound | Isolation | null
  grips_json text not null                   // JSON string[]
  steps_json text not null                   // JSON string[]

  is_favorite bool not null default false
  is_substituted_out bool not null default false
  user_notes text nullable

  imported_from_share bool not null default false
  original_share_key text nullable
  created_at datetime not null
  updated_at datetime not null
  deleted_at datetime nullable
```

### 3.3 `exercise_videos`

```text
exercise_videos
  id text primary key
  exercise_id int not null
  url text not null
  angle text nullable                        // front | side | other
  gender text nullable                       // male | female | unknown
  og_image_url text nullable
  sort_order int not null default 0
  created_at datetime not null
```

### 3.4 `exercise_audio_cache`

```text
exercise_audio_cache
  id text primary key
  exercise_id int not null
  step_index int not null
  text_hash text not null
  local_relative_path text not null
  file_size_bytes int nullable
  voice_id text nullable
  generated_at datetime not null
  last_accessed_at datetime nullable
```

Audio cache is optional and purgeable. If missing, the app can regenerate TTS on demand.

---

## 4. Exercise Sync Transaction

The dataset sync flow should be:

```text
fetch manifest
compare manifest.latest_version to library_meta.library_version
download file if needed
parse JSON
validate top-level fields
validate every exercise
migrate payload if compatible
open Drift transaction
  preserve user flags for matching exercise IDs
  delete source dataset exercises and videos
  insert new source exercises
  insert videos
  restore user flags
  update library_meta
commit
```

Custom exercises must not be deleted during dataset refresh.

---

## 5. Validation Rules

Reject dataset before write if:

```text
schema_version missing
exercise_count mismatch
exercise ID duplicated
exercise name empty
difficulty outside novice/beginner/intermediate/advanced
modality outside strength/flexibility/cardio/recovery
muscle_groups contains unknown UI bucket
primary_muscles not array
steps not array
videos not array
video URL invalid
strength modality has unexpected missing equipment unless explicitly allowed
manifest min_app_schema_version exceeds supported app schema
```

Allow nullable:

```text
force
mechanic
equipment for non-strength modalities
videos for records with no video if source permits
```

---

## 6. Custom Exercise Rules

Custom exercises are user-created and must live in the same query surface as source exercises.

Recommended:

```text
id = negative int
is_custom = true
custom_exercise_uuid = uuid
source = custom
```

Required fields:

```text
name
muscle_groups_json
modality
equipment nullable
difficulty nullable
steps_json nullable/default []
```

AI may only use custom exercises if the app candidate list includes them with valid local metadata.

---

## 7. Bodymap Data

The 14 UI muscle buckets drive bodymap highlighting.

Expected buckets:

```text
Chest
Shoulders
Back
Biceps
Triceps
Forearms
Core
Glutes
Quads
Hamstrings
Calves
Adductors
Neck
Feet
```

Bodymap SVG paths are app assets, not remote exercise data. The exercise table stores `muscle_groups_json`; UI maps those buckets to front/back SVG path IDs.

No table is required for bodymap v1 unless dynamic themes or user-edited muscle maps are introduced later.

---

## 8. Candidate Exercise DTOs for AI

The AI candidate list must be generated from explicit DTOs, not raw rows.

Allowed fields:

```json
{
  "id": 123,
  "name": "Barbell Squat",
  "difficulty": "intermediate",
  "muscle_groups": ["Quads", "Glutes"],
  "modality": "strength",
  "equipment": "Barbell",
  "mechanic": "Compound",
  "force": "Push",
  "is_custom": false
}
```

Do not include:

```text
favorite flags unless relevant
substitution notes unless relevant
user notes
local file paths
video URLs unless form/video request specifically needs them
logs
profile data
```

Candidate filtering must be:

1. hard filter by equipment and experience where required;
2. soft rank by goals and compatible adjacent movements;
3. capped by prompt type to control cost.

---

## 9. Exercise Matching for Imports

For imported plans and shared plans, matching should use:

```text
name_normalized exact match
known aliases if implemented
equipment match
modality match
muscle group match
AI match assist only after deterministic matching fails
```

Ambiguous matches must be user-confirmed. Unmatched imported exercises must be:

```text
matched manually
created as custom exercise
removed before save
```

---

## 10. Indexes

Recommended:

```text
exercises(name_normalized)
exercises(is_custom)
exercises(modality)
exercises(equipment)
exercises(difficulty)
exercises(category)
exercise_videos(exercise_id)
exercise_audio_cache(exercise_id, step_index)
```

For muscle group filtering, either:

1. app-side filter after query narrowing; or
2. introduce a normalized join table later:

```text
exercise_muscle_groups
  exercise_id
  muscle_group
```

Use the join table if bodymap/library filters become slow.

---

## 11. Acceptance Tests

M2 cannot close until:

- First sync writes all dataset exercises into Drift.
- Dataset replacement is atomic.
- Failed parse leaves previous library untouched.
- Custom exercises survive refresh.
- Favorites/substitutions survive refresh.
- Bodymap highlights every bucket used by the dataset.
- Candidate DTO contains no forbidden fields.
- Offline launch after sync can browse/search/filter library.
- Manual refresh does not delete custom exercises.
- Unsupported dataset schema shows update-required state.
