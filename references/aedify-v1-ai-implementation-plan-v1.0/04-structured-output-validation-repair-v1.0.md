# 04 — Structured Output, Validation, and Repair Plan v1.0


| Field | Value |
|---|---|
| Document Package | AI Implementation Plan |
| Package Version | v1.0 |
| Source Baseline | PRD v1.10 Final / Re-locked after Package Validation |
| Roadmap Baseline | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Architecture Baseline | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Feature Plan Baseline | `v1-feature-by-feature-build-plan-v1.0/` |
| Data Model Baseline | `v1-data-model-implementation-plan-v1.0/` |
| Status | Implementation Planning |
| Scope Rule | No product scope change; implementation-only breakdown |
| Platforms | iOS and Android |
| App Architecture | Local-only, offline-first, BYOK AI |
| State Management | Riverpod, latest validated stable version |
| Durable Data | Drift / SQLite |
| Simple Preferences | `shared_preferences` only for non-critical values |
| Secrets | `flutter_secure_storage` only |
| Networking | Dio + Retrofit, with hand-written Dio adapters for complex AI calls |
| Created | 2026-06-14 |


---

## 1. Purpose

This file defines how app-actionable AI responses are validated, repaired, reviewed, and persisted.

Structured output is required for any AI result that can become app data.

---

## 2. Shared Envelope Contract

All app-actionable AI outputs should follow a shared envelope before operation-specific payload.

```text
AIResponseEnvelope
  response_type: enum
  status: success | needs_input | blocked | partial | error
  ai_output_schema_version: int/string
  operation_id: string
  generated_at: ISO datetime?  // app may override with local received timestamp
  summary_for_user: string?
  validation_notes: string[]?
  warnings: string[]?
  data: object
```

Validation rules:

1. `response_type` must match operation.
2. `status` must be valid.
3. `ai_output_schema_version` must be supported.
4. `operation_id` must match request.
5. `data` must validate against operation schema.
6. Unknown top-level fields are either rejected or stored in extension metadata only if explicitly allowed.
7. `summary_for_user` must not contain raw prompt, raw source-file text, or private internals.

---

## 3. Schema Registry

Schema registry responsibilities:

- map operation → schema ID;
- expose schema version;
- expose validation function;
- expose repair prompt requirements;
- expose persistence target;
- expose user review requirements;
- expose unsupported schema behavior.

Recommended schema IDs:

| Schema ID | Used By |
|---|---|
| `daily_workout_json` | `DAILY_WORKOUT`, chat-save workout. |
| `multi_week_program_json` | `MULTI_WEEK_PROGRAM`, beginner paths, chat-save programme. |
| `exercise_swap_update_json` | `EXERCISE_SWAP_APPLY_UPDATE`. |
| `deload_update_json` | `DELOAD`. |
| `plateau_suggestion_json` | `PLATEAU_SUGGESTION`. |
| `external_program_import_json` | programme import parse/repair, image parse/repair. |
| `external_workout_import_json` | workout import parse/repair, image parse/repair. |
| `external_exercise_match_json` | exercise match assist. |
| `progress_physique_analysis_json` | progress media analyze/compare/repair. |

---

## 4. Validation Phases

Validation must run in phases so the app can produce useful errors.

### Phase 1 — Transport Parse

- response body exists;
- response body can be parsed;
- code fences/extra prose are stripped only if safe;
- JSON object exists;
- no multiple JSON objects;
- no streaming truncation.

### Phase 2 — Envelope Validation

- required envelope fields;
- expected `response_type`;
- expected `operation_id`;
- supported schema version;
- valid status;
- allowed top-level keys.

### Phase 3 — Schema Validation

- operation-specific required fields;
- enum values;
- arrays/objects shape;
- numeric bounds;
- nullable fields;
- date formats;
- units;
- set prescription structure;
- programme schedule structure.

### Phase 4 — Domain Validation

- canonical exercise IDs exist locally;
- exercise IDs came from candidate list when required;
- experience rules are respected;
- equipment rules are respected;
- injury/substitution constraints are respected where included;
- warm-up/working set rules are respected;
- superset rules are respected;
- progression rules are coherent;
- programme templates can expand;
- imported exercise matches are resolved or marked correctly;
- image unreadable content is flagged;
- physique analysis safety rules pass.

### Phase 5 — Persistence Readiness

- no app-local IDs from AI;
- no raw prompt or response in persistable fields;
- no source-file text in exportable fields;
- no media paths in exportable/share fields;
- no secrets;
- review warnings generated;
- blockers generated;
- sanitized snapshot can be stored if needed.

---

## 5. Repair Lifecycle

One automatic repair attempt is allowed by default for app-actionable outputs.

Repair flow:

```text
AI response received
  → parse/validate
  → if valid: review draft
  → if invalid and repairable: build repair request
  → call same provider/model when possible
  → validate repaired output
  → if valid: review draft with repair note
  → if invalid: show failure + manual retry option
```

Repair request must include:

- original operation ID;
- expected schema ID/version;
- validation error list;
- concise description of required corrections;
- failed output only if safe and needed;
- never include API key;
- never include raw source file unless operation already had consent and it is needed;
- never include unrelated profile/log/media data.

---

## 6. Repair Eligibility

| Failure | Auto Repair? | Notes |
|---|---|---|
| JSON has trailing prose | Yes | Prefer local extraction first if safe. |
| Missing envelope field | Yes | Repair can wrap payload. |
| Wrong `response_type` | Yes | If payload appears relevant. |
| Unsupported schema version | No | Show app update or schema incompatibility state. |
| Unknown exercise ID | Yes once | Ask AI to use supplied candidates only; still validate. |
| Exercise not in candidate list | Yes once | Reject if repeated. |
| Ambiguous imported exercise match | No | User confirmation required, not repair. |
| Missing required custom exercise field | Maybe | AI can suggest, user still confirms. |
| Image unreadable text omitted | Maybe | Repair asks to list unreadable regions; cannot invent content. |
| Exact body-fat number | Yes once | Repair asks for range + confidence. |
| Medical diagnosis/body shaming | No or repair with safety warning | Prefer block and show safe error. |
| Provider refusal | No | User can revise request. |
| Network failure | No | Retry transport, not structured repair. |

---

## 7. Validation Result Model

```text
AIValidationResult
  status: valid | valid_with_warnings | repairable_invalid | blocked_invalid
  blockers: ValidationIssue[]
  warnings: ValidationIssue[]
  normalized_payload: object?
  sanitized_snapshot: object?
  repair_context: AIRepairContext?
```

```text
ValidationIssue
  code: string
  severity: blocker | warning | info
  path: string?
  user_message: string
  developer_message_redacted: string?
```

Issue examples:

- `unknown_exercise_id`
- `exercise_not_in_candidate_list`
- `missing_set_type`
- `beginner_superset_not_allowed`
- `warmup_exceeds_80_percent_working_weight`
- `programme_schedule_unexpandable`
- `import_unresolved_exercise_match`
- `source_text_in_persisted_field`
- `image_unreadable_content_not_reported`
- `body_fat_exact_value_not_allowed`
- `medical_claim_not_allowed`

---

## 8. Review Draft State

After validation, structured output becomes a review draft.

Draft includes:

- operation ID;
- provider/model metadata;
- schema ID/version;
- validation result;
- sanitized payload;
- generated title;
- user-facing summary;
- list of blockers;
- list of warnings;
- created timestamp;
- repair attempt count;
- source metadata;
- save target.

Draft must not include:

- raw prompt;
- raw response;
- API key;
- full candidate list unless needed for debugging and local only;
- original screenshots;
- enhanced images;
- source-file content in exportable fields.

---

## 9. Save Rules by Response Type

| Response Type | Save Target | Required Review |
|---|---|---|
| `daily_workout` | Saved workout or workout template | Exercise IDs, set prescriptions, schedule/date, warm-up/working labels. |
| `multi_week_program` | Programme templates + schedule | Programme expansion, deload/progression rules, exercise IDs. |
| `exercise_swap_update` | Updated workout/programme occurrence(s) | Scope preview and affected items. |
| `deload_update` | Programme/workout update | Before/after load/volume preview. |
| `plateau_suggestion` | Suggestion event or programme update | User chooses action. |
| `external_program_import` | Inactive imported programme draft | Exercise matches, custom exercises, source warnings. |
| `external_workout_import` | Inactive imported workout draft | Exercise matches, custom exercises, source warnings. |
| `external_exercise_match` | Match suggestions | User confirmation where required. |
| `progress_physique_analysis` | Local analysis snapshot | Consent record and safety validation. |

---

## 10. Persistence Snapshot Policy

Allowed to persist:

- operation ID;
- provider ID/model ID;
- schema ID/version;
- validation result summary;
- repair attempt count;
- sanitized structured payload if needed for draft/history;
- user-facing summary;
- references to saved domain entity after save.

Not allowed to persist by default:

- full raw prompt;
- full raw provider response;
- candidate list;
- API key;
- source-file original content;
- original/enhanced screenshots;
- progress media bytes;
- provider authorization headers;
- crash/debug raw payloads.

---

## 11. Structured Output Test Fixtures

Each schema needs fixture sets:

1. valid minimal output;
2. valid rich output;
3. missing envelope;
4. wrong response type;
5. unsupported schema version;
6. unknown exercise ID;
7. malformed set prescription;
8. missing warm-up/working set label;
9. invalid superset group;
10. unexpandable programme schedule;
11. privacy leak in persisted field;
12. repairable invalid JSON;
13. irreparable unsafe output.

Feature-specific fixtures:

- beginner programme with forbidden superset;
- powerbuilding output for beginner user;
- imported exercise ambiguous match;
- image import with unreadable regions;
- physique analysis with exact single body-fat value;
- physique analysis with prohibited medical/attractiveness language.

---

## 12. Acceptance Gate

Structured-output implementation is accepted when:

- every app-actionable operation has a schema ID;
- shared envelope validation exists;
- schema validation is deterministic;
- domain validation checks exercise IDs and candidate-list membership;
- repair lifecycle allows only one automatic attempt by default;
- repair does not leak secrets or unrelated context;
- invalid outputs produce actionable blockers/warnings;
- no invalid output can be saved;
- review drafts are sanitized;
- fixture suite covers all required failure modes.
