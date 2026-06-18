# 06 — Analytics, PRs, and Plateau Data Model v1.0

## 1. Purpose

This file defines the data model for local-only analytics: exercise history, estimated 1RM, PR detection, weekly volume, trends, plateau flags, and AI suggestion linkage. Analytics are derived from workout logs and must not mutate source logs.

---

## 2. Analytics Source of Truth

The source of truth is:

```text
workout_sessions
workout_session_exercises
set_logs
exercises
programs/saved_workouts as metadata only
```

Do not store analytics as primary truth unless the value is expensive enough to cache.

---

## 3. e1RM

For eligible working sets, compute and store `estimated_1rm_kg` on `set_logs`.

Eligibility:

```text
set_type = working
completed = true
actual_weight_kg not null
actual_reps not null
actual_reps >= 1
exercise modality = strength
exercise is not time/distance-only
```

Excluded:

```text
warmup sets
skipped sets
failed/incomplete sets unless explicitly supported later
bodyweight-only sets without load model
cardio/distance/time sets
```

Recommended formula can be implementation-selected, but must remain consistent in v1 once chosen.

---

## 4. Personal Records

Option A: compute PRs from `set_logs` dynamically.

Option B: maintain `personal_records` table.

Recommendation: store PR flags on `set_logs` and optionally maintain a small `personal_records` table for fast display.

```text
personal_records
  id text primary key
  exercise_id int not null
  record_type text not null              // max_weight | max_reps_at_weight | estimated_1rm | volume
  value_kg real nullable
  value_reps int nullable
  value_numeric real nullable
  set_log_id text not null
  achieved_at datetime not null
  created_at datetime not null
```

PR recalculation should run when:

```text
a workout session is completed
a completed workout is edited
a workout session is deleted
an exercise is merged/replaced if that feature exists later
```

---

## 5. Weekly Volume and Trends

Prefer query-based calculations in v1. Add cache only if performance requires.

Potential cache table:

```text
analytics_weekly_exercise_summary
  id text primary key
  exercise_id int not null
  week_start_local text not null
  working_sets int not null
  total_reps int not null
  total_volume_kg real nullable
  top_weight_kg real nullable
  top_estimated_1rm_kg real nullable
  sessions_count int not null
  generated_at datetime not null
```

Cache invalidation:

```text
on set log insert/update/delete
on workout session delete
on exercise ID migration
on unit conversion bug fix
```

---

## 6. Plateau Detection

### 6.1 `plateau_flags`

```text
plateau_flags
  id text primary key
  exercise_id int not null
  status text not null                   // open | dismissed | resolved | ai_suggestion_requested | ai_suggestion_applied
  plateau_type text not null             // e1rm_stall | reps_stall | volume_stall | load_stall
  severity text nullable                 // low | medium | high
  detection_window_sessions int nullable
  detection_window_weeks int nullable
  basis_json text not null               // sanitized derived metrics only
  first_detected_at datetime not null
  last_detected_at datetime not null
  resolved_at datetime nullable
  ai_generation_snapshot_id text nullable
  user_action text nullable
  created_at datetime not null
  updated_at datetime not null
```

### 6.2 Basis JSON

`basis_json` may include derived metrics:

```json
{
  "exercise_id": 4,
  "sessions_considered": 4,
  "top_estimated_1rm_kg_values": [100, 100, 99.5, 100],
  "working_set_count": 12,
  "date_range": {
    "start": "2026-05-01",
    "end": "2026-06-01"
  }
}
```

It must not include raw free-form notes, injuries, body measurements, or full logs.

---

## 7. Plateau Suggestion AI Link

AI suggestions are generated in a separate AI flow. Store the link, not raw prompt/response.

```text
plateau_flags.ai_generation_snapshot_id -> ai_generation_snapshots.id
```

The snapshot should contain sanitized metadata:

```text
operation_category = PLATEAU_SUGGESTION
operation_subtype nullable
status
schema version
provider/model
reference files used
validation status
```

No raw prompt, response, candidate list, or lift-log content is stored in the snapshot.

---

## 8. Analytics DTOs

UI analytics should be built from DTOs:

```text
ExerciseTrendDto
WeeklyVolumeDto
PersonalRecordDto
PlateauFlagDto
WorkoutHistoryDto
```

Do not expose Drift rows directly to UI components.

---

## 9. Privacy Rules

Analytics derived from logs are still private.

Do not send to:

```text
Crashlytics
exports
external import prompts
image import prompts
progress media analysis prompts unless explicitly needed and consented
```

May send summarized slices to:

```text
programme generation
daily workout generation
plateau suggestion
AI trainer chat
deload
exercise swap
```

---

## 10. Acceptance Tests

M5 cannot close until:

- Warm-up sets do not trigger PRs.
- Warm-up sets do not affect e1RM.
- Warm-up sets do not affect plateau detection.
- A constructed plateau test case creates a plateau flag.
- Deleting a workout recalculates affected PRs or invalidates cache.
- Analytics remain available offline.
- Crashlytics payload inspection shows no logs or derived sensitive metrics.
- Plateau AI flow receives summarized DTOs, not raw full database rows.
