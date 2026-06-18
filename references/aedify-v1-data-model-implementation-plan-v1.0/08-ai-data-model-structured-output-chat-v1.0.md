# 08 — AI Data Model, Structured Output, Validation, and Chat v1.0

## 1. Purpose

This file defines local storage for AI provider metadata, chat history, generation snapshots, structured-output validation events, repair attempts, and privacy-safe traceability.

AI Infrastructure is M7 in the current roadmap, after Progress Media Tracking.

---

## 2. Core AI Storage Rules

The app may persist:

```text
provider metadata
model capability metadata
chat messages
sanitized generation snapshots
structured validation status
repair attempt counts
links from generated app content to sanitized snapshots
```

The app must not persist by default:

```text
raw prompts
raw AI responses
full provider payloads
candidate exercise lists
full structured output JSON if it includes private or large payloads outside persisted content
API keys
provider request headers
provider response headers containing secrets
```

---

## 3. `chat_threads`

```text
chat_threads
  id text primary key
  title text nullable
  source text not null default 'ai_trainer'
  active_provider_config_id text nullable
  created_at datetime not null
  updated_at datetime not null
  archived_at datetime nullable
  deleted_at datetime nullable
```

## 4. `chat_messages`

```text
chat_messages
  id text primary key
  thread_id text not null
  role text not null                    // user | assistant | system_notice
  content text not null
  content_format text not null default 'text'
  related_ai_generation_snapshot_id text nullable
  saved_entity_type text nullable        // program | saved_workout | none
  saved_entity_id text nullable
  created_at datetime not null
  deleted_at datetime nullable
```

Chat is local-only and excluded from exports and Crashlytics.

---

## 5. `ai_generation_snapshots`

```text
ai_generation_snapshots
  id text primary key

  operation_category text not null       // INIT | DAILY_WORKOUT | MULTI_WEEK_PROGRAM | etc.
  operation_subtype text nullable        // parse | repair | image_parse | analyze | compare
  source_entity_type text nullable       // program | saved_workout | import_draft | plateau_flag | progress_media_session
  source_entity_id text nullable

  provider_name text nullable
  model_name text nullable
  provider_config_id text nullable

  instruction_set_version text nullable
  prompt_template_version text nullable
  ai_output_schema_version int nullable

  reference_files_used_json text nullable
  candidate_count int nullable
  input_summary_json text nullable       // sanitized high-level summary only
  output_summary_json text nullable      // sanitized high-level summary only

  status text not null                   // started | succeeded | failed | blocked | needs_input | repaired
  validation_status text nullable        // not_required | valid | invalid | repaired | failed
  repair_attempt_count int not null default 0
  validation_errors_json text nullable   // sanitized; no raw payload

  token_usage_prompt int nullable
  token_usage_completion int nullable
  estimated_cost_minor_units int nullable
  latency_ms int nullable

  created_at datetime not null
  updated_at datetime not null
```

### 5.1 Snapshot Purpose

Snapshots support local traceability:

- which operation produced a programme/workout/import/analysis;
- which schema version was used;
- whether validation passed;
- whether repair was attempted.

They are not debug dumps.

---

## 6. `structured_output_validation_events`

```text
structured_output_validation_events
  id text primary key
  ai_generation_snapshot_id text not null
  entity_type text nullable
  entity_ref text nullable
  expected_response_type text not null
  schema_version int not null
  validation_passed bool not null
  error_codes_json text not null default '[]'
  redacted_error_summary text nullable
  repair_triggered bool not null default false
  created_at datetime not null
```

Do not store invalid raw JSON. Store error codes and redacted summaries.

---

## 7. Repair Attempts

Rules:

```text
One automatic repair attempt by default.
Second repair requires user-triggered retry.
Repair prompt may receive invalid JSON only if local privacy policy allows; safer default is to send validation errors and a minimized invalid excerpt.
Repair must still use candidate list and schemas.
Repair cannot invent exercise IDs or local refs.
```

If invalid JSON is retained temporarily for repair, keep it in memory where possible and clear after the repair attempt.

---

## 8. Provider Capabilities

Provider capabilities are in `ai_provider_configs` and optional `ai_model_capabilities`.

Important gates:

```text
supports_image_input required for image import
supports_image_input required for progress media analysis
supports_json_schema_mode preferred for structured outputs
supports_streaming optional for chat UI
```

Blocking a flow due to unsupported capability should not create a failed AI snapshot unless the user has started an AI operation. It may create a local UI event but no provider call.

---

## 9. Links from Domain Entities

Domain entities may link to snapshots:

```text
programs.ai_generation_snapshot_id
saved_workouts.ai_generation_snapshot_id
plateau_flags.ai_generation_snapshot_id
import_drafts.ai_generation_snapshot_id
progress_physique_analysis_snapshots.ai_generation_snapshot_id
chat_messages.related_ai_generation_snapshot_id
```

Do not make domain validity depend on snapshot existence. If a snapshot is deleted for privacy cleanup, the generated programme/workout remains.

---

## 10. AI Output Persistence

For generated programmes/workouts:

- persist the validated programme/workout into domain tables;
- store schema version;
- store sanitized snapshot metadata;
- do not store raw response.

For imports:

- persist draft fields into import draft tables;
- preserve missing/unclear items and warnings;
- do not store source excerpts beyond structured fields needed for review.

For physique analysis:

- persist the validated analysis snapshot fields;
- store provider/model and schema version;
- do not store raw response.

---

## 11. Prompt Payload Logs

No prompt payload logs in v1.

If future debug mode is introduced, it must require:

```text
explicit local-only opt-in
visible expiry
manual delete controls
no Crashlytics transmission
no export inclusion
separate PRD version bump
```

---

## 12. Acceptance Tests

M7 cannot close until:

- API keys cannot be read from Drift.
- Provider call retrieves key only at call time.
- Failed AI call stores redacted error only.
- Valid structured output creates snapshot metadata but no raw prompt/response.
- Candidate lists are not persisted in snapshots.
- Repair attempt count is enforced.
- Image-gated flows block before prompt assembly if model lacks image input.
- Crashlytics contains no prompt, response, schema JSON, candidate list, or chat content.
