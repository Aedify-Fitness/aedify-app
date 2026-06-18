# 04 — Profile, Settings, Secure Storage, and Preferences Data Model v1.0

## 1. Purpose

This file defines the user profile, onboarding state, app settings, body measurements, strength anchors, AI provider metadata, secure API-key aliasing, and the strict boundary between Drift, secure storage, and `shared_preferences`.

---

## 2. `user_profile`

```text
user_profile
  id text primary key default 'default'
  name text nullable
  sex text nullable
  date_of_birth date nullable
  height_cm real nullable
  bodyweight_kg real nullable
  bodyweight_logged_at datetime nullable
  preferred_units text not null default 'metric'  // metric | imperial
  experience_level text not null                  // novice | beginner | intermediate | advanced
  target_session_length_minutes int nullable
  training_days_per_week int nullable
  training_day_names_json text not null default '[]'
  onboarding_completed bool not null default false
  onboarding_completed_at datetime nullable
  created_at datetime not null
  updated_at datetime not null
```

### 2.1 Profile Privacy

The profile must never be sent to:

```text
Crashlytics
.aedifyplan exports
PDF exports
external import parse prompts
image import parse prompts
progress analysis unless explicitly needed and consented
```

Profile may be used in:

```text
AI workout/programme generation
AI trainer chat
exercise swaps
deloads
plateau suggestions
```

---

## 3. Goals and Equipment

For v1, JSON fields are acceptable. If filtering becomes complex, normalize later.

### 3.1 Option A — JSON fields on profile

```text
user_profile
  goals_json text not null default '[]'
  equipment_access_json text not null default '[]'
  favorite_exercise_ids_json text not null default '[]'
  substituted_exercise_ids_json text not null default '[]'
  injuries_limitations_json text not null default '[]'
  other_notes text nullable
```

### 3.2 Option B — normalized tables

```text
profile_goals
  id text primary key
  profile_id text
  goal text
  priority int

profile_equipment
  id text primary key
  profile_id text
  equipment text
  access_level text nullable

profile_exercise_preferences
  id text primary key
  exercise_id int
  preference_type text       // favorite | substitute_out | avoid
  reason text nullable

profile_limitations
  id text primary key
  body_region text nullable
  description text
  severity text nullable
  cleared_for_training bool nullable
```

Recommendation: use JSON for initial v1 unless UI needs complex editing/search. Keep DTO interfaces stable so the persistence implementation can later normalize without feature rewrites.

---

## 4. Strength Anchors

Known 1RMs and recent working weights should be separate from the profile row.

```text
strength_anchors
  id text primary key
  exercise_id int not null
  anchor_type text not null       // known_1rm | estimated_1rm | working_weight | calibration_estimate
  weight_kg real nullable
  reps int nullable
  rpe real nullable
  rir int nullable
  source text not null            // user_entered | log_derived | ai_seeded | imported
  source_set_log_id text nullable
  confidence text nullable        // low | medium | high
  logged_at datetime nullable
  created_at datetime not null
  updated_at datetime not null
```

Build Strength anchor priority should be:

1. recent working weights from logs;
2. known 1RMs;
3. bodyweight-relative estimates;
4. `needs_input`.

This table supports that priority without embedding all strength data in the profile.

---

## 5. Body Measurements

```text
body_measurements
  id text primary key
  measured_at datetime not null
  bodyweight_kg real nullable
  waist_cm real nullable
  chest_cm real nullable
  hips_cm real nullable
  left_arm_cm real nullable
  right_arm_cm real nullable
  left_thigh_cm real nullable
  right_thigh_cm real nullable
  notes text nullable
  created_at datetime not null
  updated_at datetime not null
```

Body measurements are private local data. They are excluded from Crashlytics, plan sharing, PDF export, external imports, and AI prompts unless a specific consented flow later requires them.

---

## 6. App Settings in Drift

Use Drift for settings that must survive migrations and affect core behavior.

```text
app_settings
  id text primary key default 'default'
  preferred_units text not null default 'metric'
  theme_mode text nullable
  notifications_enabled bool not null default true
  workout_timer_sound_enabled bool not null default true
  exercise_audio_enabled bool not null default false
  crashlytics_enabled bool not null default true
  redaction_strict_mode bool not null default true
  created_at datetime not null
  updated_at datetime not null
```

Progress media reminder settings are defined in the progress media document because they are domain-specific.

---

## 7. `shared_preferences` Usage

Allowed:

```text
has_seen_intro_carousel
last_selected_home_tab
last_library_filter_json if recoverable and non-sensitive
temporary UI sort mode
```

Not allowed:

```text
profile
goals
injuries
equipment
API keys
programmes
logs
settings that determine migration safety
AI outputs
import drafts
progress media paths
```

Implementation rule: if a setting appears in the feature acceptance criteria, consider Drift first.

---

## 8. AI Provider Metadata

The API key value lives in secure storage. Drift stores metadata and secure key aliases only.

```text
ai_provider_configs
  id text primary key
  provider_name text not null       // openai | anthropic | google | other_supported
  display_name text nullable
  selected_model text nullable
  secure_key_alias text not null
  is_active bool not null default false

  supports_text_input bool not null default true
  supports_image_input bool not null default false
  supports_json_schema_mode bool not null default false
  supports_streaming bool not null default false
  supports_tool_calling bool nullable

  max_context_tokens int nullable
  max_output_tokens int nullable
  max_images_per_request int nullable
  max_image_size_bytes int nullable

  last_validated_at datetime nullable
  last_validation_status text nullable       // valid | invalid | unknown | rate_limited
  last_error_code text nullable
  created_at datetime not null
  updated_at datetime not null
```

### 8.1 Secure Storage Key Pattern

```text
ai_provider_api_key:{provider_config_id}
```

Only the secure store adapter may read/write/delete actual secrets.

---

## 9. Provider Capability Cache

If provider capabilities vary by model, keep a separate cache:

```text
ai_model_capabilities
  id text primary key
  provider_name text not null
  model_name text not null
  supports_text_input bool not null
  supports_image_input bool not null
  supports_json_schema_mode bool not null
  supports_streaming bool not null
  max_context_tokens int nullable
  max_output_tokens int nullable
  max_images_per_request int nullable
  checked_at datetime not null
```

Image import and physique analysis must check `supports_image_input` before prompt assembly.

---

## 10. Permission State

Optional table for local display/retry logic:

```text
permission_state
  permission text primary key      // camera | photos | notifications | health
  status text not null             // unknown | granted | denied | permanently_denied | limited
  last_checked_at datetime not null
```

Do not depend solely on this table for actual permission state; always query platform APIs before performing restricted operations.

---

## 11. Acceptance Tests

M3 cannot close until:

- Profile values are saved in canonical units.
- Preferred units only affect display.
- API key value is absent from Drift.
- API key value is absent from shared preferences.
- API key value is absent from logs and Crashlytics test payloads.
- Provider capability checks can block image-dependent flows.
- `shared_preferences` wipe does not corrupt profile, BYOK metadata, programmes, logs, or media.
- Deleting a provider config deletes or invalidates its secure key alias.
