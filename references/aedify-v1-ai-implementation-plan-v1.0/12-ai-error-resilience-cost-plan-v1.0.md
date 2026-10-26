# 12 — AI Error Handling, Resilience, and Cost Control Plan v1.0


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

This file defines how AI workflows fail safely and recoverably.

AI operations are network-dependent and provider-dependent. The app must remain stable when AI is unavailable, slow, invalid, expensive, or unsupported.

---

## 2. AI Error Taxonomy

```text
AIErrorCategory
  provider_not_configured
  api_key_missing
  api_key_invalid
  capability_blocked
  offline
  timeout
  cancelled
  rate_limited
  quota_exceeded
  provider_unavailable
  provider_refusal
  invalid_response
  schema_validation_failed
  repair_failed
  privacy_guard_blocked
  consent_required
  payload_too_large
  unsupported_schema_version
  unknown
```

Each error must provide:

- user-facing message;
- retryability;
- whether repair is applicable;
- whether user action is required;
- redacted debug code;
- safe Crashlytics context if crash-worthy.

---

## 3. User-Facing States

Every AI controller should expose explicit states:

```text
idle
checking_provider
blocked_provider_not_configured
blocked_capability
awaiting_consent
building_prompt
estimating_cost
sending
streaming
validating
repairing
review_ready
needs_input
failed_retryable
failed_non_retryable
cancelled
saved
```

Do not represent all failures as a generic error.

---

## 4. Retry Policy

| Failure | Automatic Retry | User Retry | Notes |
|---|---:|---:|---|
| transient network error | 0–1 optional | Yes | Avoid hidden BYOK costs if provider call may have completed. |
| provider 5xx | No default or 1 conservative | Yes | Explain provider issue. |
| timeout | No default | Yes | User may retry. |
| rate limit | No | Later | Show provider rate-limit message. |
| invalid API key | No | After edit key | Direct user to settings. |
| invalid JSON/schema | One repair attempt | Yes after failure | Disclose additional AI call for manual retry. |
| capability blocked | No | After model switch | No retry until model changes. |
| privacy guard blocked | No | Developer/user action | Do not send payload. |
| user cancellation | No | Yes | Keep draft only if safe and expected. |

---

## 5. Cancellation

Long AI operations must support cancellation:

- generation;
- external import parse;
- image import parse;
- progress media analysis;
- repair calls.

Cancellation behavior:

- cancel network token;
- mark operation cancelled;
- keep no partial provider response unless already validated;
- clean temporary media/import artifacts if user cancels entire flow;
- do not save draft;
- show clear state.

---

## 6. Payload Size Management

The prompt builder should estimate payload size before sending.

Strategies:

- cap candidate lists;
- trim chat history;
- summarize older chat turns locally;
- limit lift log window;
- avoid full source file when extracted content is enough;
- compress/resize images where readability remains acceptable;
- extract video frames instead of sending video;
- split import if source is too large and user agrees;
- show blocked state if payload cannot fit safely.

---

## 7. Cost Control UX

Minimum cost controls:

- setup disclosure: BYOK provider may charge user;
- retry disclosure: repair/retry may cost another AI call;
- image/media disclosure: image and physique analysis calls may cost more;
- cancellation during long calls;
- avoid unnecessary automatic retries;
- no background AI calls without direct user action in v1.

Optional:

- local count of AI calls by operation;
- local monthly estimated usage;
- warning when usage crosses user-configured threshold;
- model cost tier labels.

---

## 8. Offline Behavior

When offline:

- non-AI app features continue;
- manual workouts/logging continue;
- exercise library works from local cache;
- progress media capture continues;
- AI buttons show offline blocked state;
- drafts already validated locally remain viewable;
- no provider calls attempted;
- import extraction can happen locally but AI parse waits for connection and consent.

---

## 9. Recovery Rules

| Flow | Recoverable State |
|---|---|
| Workout generation fails | User can retry or create manually. |
| Programme generation fails | User can retry or create manually. |
| Chat fails | User message remains, failed AI response state can retry. |
| Import parse fails | Extracted content remains local until user cancels/expires. |
| Image import fails | Temp artifacts remain only for retry/session, then cleanup. |
| Physique analysis fails | Progress media remains unaffected. |
| Repair fails | Original invalid draft not saveable; user can retry manually or discard. |

---

## 10. Acceptance Gate

Resilience implementation is accepted when:

- every AI flow has explicit Riverpod states;
- cancellation works;
- offline states block AI without breaking non-AI features;
- invalid key/quota/rate-limit errors are user-actionable;
- repair attempts are limited and disclosed;
- payload-too-large state is handled;
- cost-sensitive operations warn users;
- no background AI calls happen silently.
