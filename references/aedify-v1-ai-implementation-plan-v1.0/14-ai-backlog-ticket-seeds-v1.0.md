# 14 — AI Backlog Ticket Seeds v1.0


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

This file provides implementation-ticket seeds for AI work. These are not final tickets; they are detailed enough to convert into a task tracker.

Each ticket should be implemented with acceptance criteria, tests, and privacy review.

---

## 2. M7 — AI Infrastructure Tickets

### AI-M7-001 — Create AI domain operation registry

**Build**

- Define `AIOperationId` enum.
- Define operation metadata: response mode, schema ID, capability requirements, consent requirement, prompt template ID.
- Register all v1 operations.

**Acceptance**

- Every AI operation is listed.
- Unknown operation fails closed.
- Tests verify registry metadata for image and progress-media gates.

### AI-M7-002 — Implement provider capability descriptor

**Build**

- Define `AIModelCapabilities`.
- Add local capability mapping for supported provider/model choices.
- Expose Riverpod provider for selected model capabilities.

**Acceptance**

- Text operations pass with text model.
- Image import and physique analysis block when image input unsupported.

### AI-M7-003 — Implement secure BYOK key access boundary

**Build**

- Secure storage wrapper for API keys.
- Drift stores provider/model/key alias metadata only.
- Redaction tests for keys.

**Acceptance**

- API key never appears in Drift/shared preferences/logs/Crashlytics/export fixtures.

### AI-M7-004 — Implement provider adapters

**Build**

- OpenAI adapter.
- Anthropic adapter.
- Gemini adapter.
- Normalize responses/errors.
- Support cancellation/timeouts.

**Acceptance**

- Fake provider integration tests pass.
- Provider-specific errors map to app error taxonomy.

### AI-M7-005 — Implement prompt builder

**Build**

- Operation context registry.
- Instruction-section selector.
- Placeholder renderer.
- Reference selector.
- Prompt privacy guard.

**Acceptance**

- Prompt snapshots for every operation.
- No unresolved placeholders.
- Import/media privacy tests pass.

### AI-M7-006 — Implement schema registry and validator

**Build**

- Shared envelope validator.
- Operation schema validators.
- Domain validation hooks.
- Validation issue model.

**Acceptance**

- Fixture suite passes.
- Unknown exercise IDs and unsupported schemas block save.

### AI-M7-007 — Implement repair orchestrator

**Build**

- Repair eligibility rules.
- One automatic repair attempt.
- Repair prompt builder.
- Repair validation.

**Acceptance**

- Invalid JSON fixture repairs once.
- Second automatic repair is blocked.
- User-triggered retry discloses extra AI call.

---

## 3. M8 — AI Generation Tickets

### AI-M8-001 — Daily workout generation flow

**Build**

- Config UI handoff.
- Candidate list construction.
- Prompt assembly.
- Provider call.
- Validation/repair.
- Review draft.
- Save transaction.

**Acceptance**

- Valid fake response saves workout.
- Invalid exercise blocks save.
- Review can cancel without persistence.

### AI-M8-002 — Multi-week programme generation flow

**Build**

- Programme config handoff.
- Template-based schema validation.
- Expansion preview.
- Review and save.

**Acceptance**

- Programme expands locally before save.
- Schedule errors block save.

### AI-M8-003 — Beginner Path A/B implementation

**Build**

- Choice-first flow.
- Path A strict prompt.
- Path B beginner-safe prompt.
- Beginner-specific validators.

**Acceptance**

- Powerbuilding excluded.
- Beginner supersets rejected.
- Advanced techniques rejected.

### AI-M8-004 — Powerbuilding eligibility routing

**Build**

- Eligibility checker.
- Reference selector integration.
- Optional metadata validation.

**Acceptance**

- Intermediate/advanced strength+muscle request can include file 09.
- Beginners never include file 09.

---

## 4. M9 — Chat and Update Tickets

### AI-M9-001 — AI Trainer chat controller

**Build**

- Thread/message state.
- Provider call.
- Chat history trimming.
- Safety routing.

**Acceptance**

- General chat works.
- Medical concern redirects safely.
- Chat content local only.

### AI-M9-002 — Chat save workout/programme

**Build**

- Save intent detection.
- Structured prompt routing.
- Review draft reuse.
- Save as `ai-chat`.

**Acceptance**

- No persistence without explicit save intent.

### AI-M9-003 — Exercise swap and deload flows

**Build**

- Recommendation prompt.
- Apply update prompt.
- Scope preview.
- Transactional apply.
- Deload review.

**Acceptance**

- Completed logs unchanged.
- User sees affected items.

### AI-M9-004 — Plateau suggestion flow

**Build**

- Plateau event DTO.
- Prompt assembly.
- Suggestion/update review.

**Acceptance**

- Uses local plateau context.
- Suggestion can be dismissed.

---

## 5. M11 — External Text Import Tickets

### AI-M11-001 — Import parse AI flow

**Build**

- Consent gate.
- Import parse prompt.
- Structured draft validation.
- Repair.

**Acceptance**

- Profile/logs excluded by default.
- Draft preserves source and does not adapt.

### AI-M11-002 — Exercise match assist

**Build**

- Local matching first.
- AI assist for ambiguous names.
- User confirmation UI.

**Acceptance**

- Ambiguous matches never auto-save.

---

## 6. M12 — Image Import Tickets

### AI-M12-001 — Image capability and consent gate

**Build**

- Check `supports_image_input`.
- Image consent UI.
- Block unsupported provider/model.

**Acceptance**

- Unsupported model cannot proceed.

### AI-M12-002 — Image package and prompt assembly

**Build**

- Ordered image DTO.
- Enhancement metadata.
- Image parse prompt.

**Acceptance**

- User order preserved.
- Profile/logs excluded.

### AI-M12-003 — Image import validation and cleanup

**Build**

- Unreadable-region validation.
- Reuse external import draft flow.
- Temp artifact cleanup.

**Acceptance**

- Artifacts deleted after save/cancel/expiry.

---

## 7. M13 — Physique Analysis Tickets

### AI-M13-001 — Progress media analysis consent and packaging

**Build**

- Select media/frames.
- Consent screen.
- Package DTO.

**Acceptance**

- Only selected media sent.

### AI-M13-002 — Physique analysis validation and snapshot

**Build**

- Structured schema validation.
- Safety filter.
- Local snapshot persistence.

**Acceptance**

- Exact BF and unsafe outputs rejected.
- Snapshot excluded from exports.

---

## 8. M14 — AI Hardening Tickets

### AI-M14-001 — AI privacy audit

**Build**

- Prompt/log/export/Crashlytics checks.
- Redaction fixtures.

**Acceptance**

- Denylist tests pass.

### AI-M14-002 — Provider resilience QA

**Build**

- Fake provider full matrix.
- Timeout/cancel/rate-limit/quota/invalid-key tests.

**Acceptance**

- Every error has recoverable UI state.

### AI-M14-003 — Final AI manual QA pass

**Build**

- Execute manual QA checklist.
- Capture defects and sign-off.

**Acceptance**

- All AI flows pass on iOS and Android private-release builds.
