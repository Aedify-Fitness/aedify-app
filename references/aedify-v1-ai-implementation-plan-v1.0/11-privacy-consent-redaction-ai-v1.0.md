# 11 — AI Privacy, Consent, and Redaction Plan v1.0


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

This file defines privacy implementation rules for all AI operations.

The app is local-only and offline-first. AI features are BYOK and necessarily send selected data to the user's chosen AI provider, but only after the relevant gate and only with minimal operation-specific context.

---

## 2. Consent Types

| Consent Type | Required For | Reusable? |
|---|---|---|
| `byok_terms_acknowledgement` | Initial AI provider setup | Until provider/key reset. |
| `external_import_ai_processing` | Sending extracted text/table content to provider | Per import session. |
| `image_import_ai_processing` | Sending original/enhanced screenshots/images to provider | Per image import session. |
| `progress_media_ai_analysis` | Sending selected progress photos/frames to provider | Per analysis request. |
| `repair_retry_cost_acknowledgement` | Optional extra repair/retry after automatic attempt | Per retry where applicable. |

General AI chat/generation may be covered by the BYOK setup acknowledgement plus per-call UI disclosure if desired. Media/source-file flows need explicit operation-level consent.

---

## 3. Prompt Minimization Matrix

| Data Category | Chat | Generation | Text Import | Image Import | Physique Analysis |
|---|---|---|---|---|---|
| Profile goals/equipment | Allowed if relevant | Required | Excluded by default | Excluded by default | Excluded by default |
| Injuries/limitations | Allowed if relevant | Required for safe exercise selection | Excluded by default | Excluded by default | Excluded unless user asks training follow-up |
| Recent lift log | Allowed if relevant | Required/optional | Excluded | Excluded | Excluded by default |
| Candidate exercises | Only when needed | Required | Match assist only | Match assist only | No |
| Extracted source text | No | No | Consent required | No | No |
| Screenshots/images | No | No | No | Consent required | No |
| Progress media | No | No | No | No | Consent required |
| API key | Provider adapter only | Provider adapter only | Provider adapter only | Provider adapter only | Provider adapter only |
| Raw prompts/responses | Not sent elsewhere | Not sent elsewhere | Not sent elsewhere | Not sent elsewhere | Not sent elsewhere |

---

## 4. Crashlytics AI Denylist

Crashlytics must never receive:

- API keys;
- prompt text;
- AI responses;
- chat history;
- structured output JSON;
- exercise candidate lists;
- injuries/limitations;
- lift logs or set logs;
- body measurements;
- progress media paths;
- progress photos/videos/thumbnails/extracted frames;
- physique-analysis results;
- original screenshots;
- enhanced screenshots;
- image-processing artifacts;
- image import source excerpts;
- local database dumps;
- provider authorization headers;
- user free-form notes.

Allowed crash context is limited to non-sensitive diagnostics such as:

- app version;
- OS version;
- device model;
- screen/feature name;
- redacted error code;
- local schema version;
- exercise dataset version;
- operation ID;
- provider enum but not key;
- model ID if not sensitive;
- redacted stack trace.

---

## 5. Redaction Layer

Every AI error should pass through redaction before display/logging.

Redactor checks:

- API key patterns;
- bearer tokens;
- provider headers;
- email-like PII if not needed;
- prompt bodies;
- JSON response bodies;
- file paths;
- media filenames;
- source excerpts;
- chat messages;
- free-form notes.

Output:

```text
RedactedAIError
  category
  code
  user_message
  retryable
  safe_debug_message
  crash_context_allowlist
```

---

## 6. Export Exclusions

AI-related data excluded from `.aedifyplan` and PDF exports:

- API keys;
- provider configs except maybe display label if explicitly safe;
- chat history;
- prompts;
- raw AI responses;
- AI generation snapshots;
- candidate lists;
- validation internals;
- external source text;
- original source files;
- original/enhanced screenshots;
- image artifacts;
- progress media;
- physique analysis results;
- private profile/log data not part of exported plan.

Exports are DTO-driven and must never serialize AI tables directly.

---

## 7. Consent Record Fields

```text
AIConsentRecord
  id
  consent_type
  operation_id
  provider_id
  model_id
  accepted_at
  source_entity_id nullable
  media_session_ids nullable
  summary_text
  revoked_or_expired_at nullable
```

Consent records should not include raw source content, images, or prompts.

---

## 8. User Deletion Behavior

User deletion/clear actions:

| User Action | Required Result |
|---|---|
| Delete API key | Remove secure storage value and mark provider config unusable. |
| Clear AI chat | Delete local chat thread/messages. |
| Delete AI draft | Delete sanitized draft/snapshot and temp artifacts. |
| Delete import session | Delete import draft, extracted temp files, image artifacts. |
| Delete progress media session | Delete media files, thumbnails, analysis snapshots linked to media unless user chooses otherwise. |
| Clear all app data | Delete Drift DB, secure keys, preferences, local files, temp exports. |

---

## 9. Acceptance Gate

Privacy implementation is accepted when:

- every media/source-file AI flow has explicit consent;
- prompt minimization tests pass;
- Crashlytics denylist tests pass;
- API keys never appear outside secure storage/provider adapter memory;
- exports exclude AI internals;
- deletion removes AI drafts/artifacts/analysis as specified;
- redacted error objects are the only error objects allowed near Crashlytics.
