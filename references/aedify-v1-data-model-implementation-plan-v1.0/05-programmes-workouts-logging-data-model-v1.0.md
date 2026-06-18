# 05 — Programmes, Workouts, Templates, and Logging Data Model v1.0

## 1. Purpose

This file defines the core training data model: manual programmes, AI programmes, chat-saved programmes, saved workouts, expanded programme occurrences, workout sessions, exercise entries, set prescriptions, set logs, supersets, warm-up sets, revisions, and import/share provenance.

---

## 2. Programme Model Overview

The app needs two related representations:

1. **Templates** — reusable programme/workout structure.
2. **Expanded occurrences** — concrete scheduled workouts and sets generated from templates.

AI multi-week programmes are template-based by default. The app expands and validates them before saving.

---

## 3. `programs`

```text
programs
  id text primary key
  name text not null
  description text nullable
  source text not null                   // ai-generated | ai-chat | custom
  creation_method text not null          // manual | ai_generated | ai_chat_save | ai_file_import
  import_origin text nullable            // external_file | aedifyplan

  status text not null default 'draft'   // draft | inactive | active | completed | archived
  active bool not null default false
  start_date_local text nullable
  end_date_local text nullable
  weeks_total int nullable
  days_per_week int nullable
  session_length_minutes int nullable

  goal_tags_json text not null default '[]'
  equipment_json text not null default '[]'
  experience_level_at_creation text nullable
  preferred_units_at_creation text nullable

  periodisation_model text nullable       // default_3_plus_1 | block | linear | undulating | source_preserved
  training_style text nullable            // general | strength | hypertrophy | powerbuilding
  reference_strategy text nullable
  block_type text nullable

  progression_rules_json text nullable
  deload_rules_json text nullable
  warmup_policy_json text nullable
  fatigue_management_json text nullable

  ai_generation_snapshot_id text nullable
  ai_output_schema_version int nullable

  imported bool not null default false
  imported_at datetime nullable
  import_source_file_type text nullable
  import_review_status text nullable      // pending_review | resolved | saved
  source_file_retained bool not null default false

  share_schema_version int nullable
  external_share_id text nullable
  export_privacy_mode text nullable       // template | exact_prescription

  created_at datetime not null
  updated_at datetime not null
  archived_at datetime nullable
  deleted_at datetime nullable
```

---

## 4. Programme Templates

### 4.1 `program_workout_templates`

```text
program_workout_templates
  id text primary key
  program_id text not null
  template_key text not null              // app-provided ref AI may echo
  name text not null
  description text nullable
  day_type text nullable                  // upper | lower | push | pull | legs | full_body | custom
  estimated_duration_minutes int nullable
  sort_order int not null
  created_at datetime not null
  updated_at datetime not null
```

### 4.2 `program_template_exercises`

```text
program_template_exercises
  id text primary key
  workout_template_id text not null
  exercise_id int not null
  exercise_ref text nullable              // app-provided ref for AI update flows
  exercise_role text nullable             // primary | secondary | tertiary | conditioning | mobility_recovery
  programme_role text nullable
  superset_group_id text nullable
  superset_order int nullable
  sort_order int not null
  notes text nullable
  cues_json text nullable
  created_at datetime not null
```

### 4.3 `program_template_exercise_sets`

```text
program_template_exercise_sets
  id text primary key
  template_exercise_id text not null
  set_index int not null

  set_type text not null                  // warmup | working
  set_intent text nullable                // top_set | backoff | volume | pump | technique | test | taper_practice | working
  prescribed_reps_min int nullable
  prescribed_reps_max int nullable
  prescribed_reps_exact int nullable
  duration_seconds int nullable
  distance_meters real nullable

  weight_prescription_type text nullable  // fixed_weight | percent_1rm | percent_working_weight | bodyweight | rpe_based | none
  prescribed_weight_kg real nullable
  prescribed_weight_pct_1rm real nullable
  prescribed_weight_pct_working real nullable
  bodyweight_multiplier real nullable

  prescribed_rpe_min real nullable
  prescribed_rpe_max real nullable
  prescribed_rir int nullable
  rest_seconds int nullable

  loading_model text nullable             // fixed_percent_1rm | rpe_target | double_progression | calibration | bodyweight | time_based
  percent_1rm_min real nullable
  percent_1rm_max real nullable
  rpe_min real nullable
  rpe_max real nullable
  load_selection_note text nullable

  is_calibration_estimate bool not null default false
  derived_from_working_set_index int nullable
  warmup_weight_rule_json text nullable
  created_at datetime not null
```

---

## 5. Expanded Programme Occurrences

### 5.1 `program_weeks`

```text
program_weeks
  id text primary key
  program_id text not null
  week_number int not null
  week_type text nullable                 // normal | deload | test | taper | hypertrophy | strength
  starts_on_local text nullable
  notes text nullable
```

### 5.2 `program_workouts`

```text
program_workouts
  id text primary key
  program_id text not null
  program_week_id text nullable
  workout_template_id text nullable
  occurrence_ref text not null
  name text not null
  scheduled_date_local text nullable
  scheduled_day_index int nullable
  status text not null default 'planned'  // planned | started | completed | skipped | replaced
  revision_id text nullable
  created_at datetime not null
  updated_at datetime not null
```

### 5.3 `program_exercises`

```text
program_exercises
  id text primary key
  program_workout_id text not null
  source_template_exercise_id text nullable
  exercise_id int not null
  exercise_role text nullable
  superset_group_id text nullable
  superset_order int nullable
  sort_order int not null
  notes text nullable
```

### 5.4 `program_exercise_sets`

Same core fields as template sets, plus:

```text
program_exercise_sets
  id text primary key
  program_exercise_id text not null
  source_template_set_id text nullable
  set_index int not null
  ... prescription fields ...
```

---

## 6. Saved Workouts

Saved workouts are standalone reusable sessions.

```text
saved_workouts
  id text primary key
  name text not null
  description text nullable
  source text not null                    // ai-generated | ai-chat | custom
  creation_method text not null           // manual | ai_generated | ai_chat_save | ai_file_import
  status text not null default 'active'   // active | archived | deleted
  estimated_duration_minutes int nullable
  goal_tags_json text not null default '[]'
  equipment_json text not null default '[]'
  ai_generation_snapshot_id text nullable
  ai_output_schema_version int nullable
  imported bool not null default false
  imported_at datetime nullable
  import_origin text nullable
  import_source_file_type text nullable
  import_review_status text nullable
  share_schema_version int nullable
  external_share_id text nullable
  export_privacy_mode text nullable
  created_at datetime not null
  updated_at datetime not null
  archived_at datetime nullable
```

Child tables:

```text
saved_workout_exercises
saved_workout_exercise_sets
```

Use the same exercise/set prescription fields as programme templates.

---

## 7. Workout Execution

### 7.1 `workout_sessions`

```text
workout_sessions
  id text primary key
  source text not null                    // program | saved_workout | standalone
  program_id text nullable
  program_workout_id text nullable
  saved_workout_id text nullable

  name text not null
  started_at datetime not null
  completed_at datetime nullable
  duration_seconds int nullable
  status text not null                    // in_progress | completed | abandoned | deleted

  bodyweight_kg_at_session real nullable
  notes text nullable
  energy_level int nullable
  perceived_difficulty int nullable

  created_at datetime not null
  updated_at datetime not null
```

### 7.2 `workout_session_exercises`

```text
workout_session_exercises
  id text primary key
  workout_session_id text not null
  source_program_exercise_id text nullable
  source_saved_workout_exercise_id text nullable
  exercise_id int not null
  exercise_name_snapshot text not null
  sort_order int not null
  superset_group_id text nullable
  notes text nullable
```

### 7.3 `set_logs`

```text
set_logs
  id text primary key
  workout_session_exercise_id text not null
  exercise_id int not null
  performed_at datetime not null

  set_index int not null
  set_type text not null default 'working'       // warmup | working
  set_intent text nullable

  prescribed_reps_min int nullable
  prescribed_reps_max int nullable
  prescribed_weight_kg real nullable
  prescribed_rpe_min real nullable
  prescribed_rpe_max real nullable

  actual_reps int nullable
  actual_weight_kg real nullable
  actual_duration_seconds int nullable
  actual_distance_meters real nullable
  actual_rpe real nullable
  actual_rir int nullable

  completed bool not null default false
  skipped bool not null default false
  is_pr bool not null default false
  estimated_1rm_kg real nullable

  notes text nullable
  created_at datetime not null
  updated_at datetime not null
```

---

## 8. Superset Rules

Represent supersets with a `superset_group_id` shared by exercises in the same group.

Validation:

```text
AI-generated beginner programmes/workouts must not include supersets.
Manual custom workouts/programmes may include supersets for all levels.
AI non-beginner supersets must have matching working-set counts.
Warm-up sets should not be paired as superset work unless manually created.
```

---

## 9. Warm-Up Rules

Warm-up sets:

- have `set_type = warmup`;
- may have `set_intent = warmup`;
- are visible in workout history;
- are excluded from PR detection;
- are excluded from e1RM;
- are excluded from plateau detection;
- are excluded from default volume analytics;
- may reference the associated working set with `derived_from_working_set_index`.

For non-beginner strength-focused AI outputs, warm-up sets should progressively increase and not exceed 80% of the associated working set.

---

## 10. Programme Revisions

```text
program_revisions
  id text primary key
  program_id text not null
  revision_number int not null
  change_type text not null              // manual_edit | ai_swap | ai_deload | import_fix | schedule_change
  update_scope text nullable             // single_occurrence | future_occurrences | entire_program
  affected_refs_json text nullable
  summary text not null
  ai_generation_snapshot_id text nullable
  created_at datetime not null
```

Completed workout logs must never be edited by programme revisions.

---

## 11. Save Transactions

### 11.1 Save Programme

Transaction:

```text
insert program
insert templates
insert template exercises
insert template sets
expand programme schedule
insert expanded weeks/workouts/exercises/sets
link AI snapshot if present
commit
```

### 11.2 Complete Workout

Transaction:

```text
create/update workout_session
insert/update session exercises
insert/update set_logs
compute e1RM for eligible working sets
detect PRs
invalidate analytics cache
optionally evaluate plateau flags
commit
```

---

## 12. Acceptance Tests

M4 cannot close until:

- Manual workout can be saved without AI.
- Manual programme can be saved without AI.
- AI programme can be saved only after validation.
- Template expansion creates concrete week/workout/set rows.
- Warm-up sets are visible but excluded from analytics.
- Completed logs are not mutated by swaps or programme edits.
- Superset validation rejects invalid AI beginner supersets.
- Set logs store canonical kg even if UI uses lb.
- Deleting/archive behavior preserves historical logs.
