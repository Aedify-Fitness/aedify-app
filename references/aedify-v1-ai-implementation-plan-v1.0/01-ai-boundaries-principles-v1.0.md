# 01 — AI Boundaries and Implementation Principles v1.0


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

This file defines the boundary between the AI layer and the deterministic app layer.

The core rule is simple:

> AI may generate, parse, explain, repair, classify, or suggest. The app validates, reviews, persists, exports, deletes, and audits.

This distinction must be preserved in every AI feature, because the v1 architecture is local-only, offline-first, BYOK, and privacy-sensitive.

---

## 2. What AI Is Allowed to Do

| Allowed AI Action | Examples | Required App Gate |
|---|---|---|
| Generate a draft workout | `DAILY_WORKOUT`, chat-save workout | JSON schema validation + exercise ID validation + user review. |
| Generate a draft programme | `MULTI_WEEK_PROGRAM`, beginner Path A/B, chat-save programme | Template expansion validation + schedule validation + user review. |
| Explain training concepts | AI Trainer chat | Medical/injury guardrails + reference routing. |
| Suggest substitutions | Exercise swap recommendation | Candidate-list restriction + user confirmation before applying. |
| Propose a deload | Deload operation | Local programme update review before save. |
| Suggest plateau actions | Plateau suggestion | Local plateau event context + review. |
| Parse an external text source | External import parse | Consent + extracted programme-relevant content only + import validation. |
| Parse screenshots/images | Image import parse | Image-capable provider gate + explicit consent + unreadable-region flagging. |
| Assist with exercise matching | Import match assist | User confirmation for ambiguous or custom matches. |
| Analyze progress media | Progress media analyze/compare | Explicit media consent + selected media/frame payload + safety filter. |
| Repair invalid structured output | Structured-output repair | One automatic attempt + deterministic validation after repair. |

---

## 3. What AI Must Not Do

| Forbidden AI Action | Reason | Enforcement |
|---|---|---|
| Persist data directly | App must control local database integrity. | AI service returns DTO only; repositories are inaccessible from provider adapters. |
| Create local database IDs | IDs must be generated locally and transactionally. | Validation rejects local ID fields from AI output. |
| Use exercise names not in the supplied candidate list as canonical exercises | Prevent hallucinated exercise catalog entries. | Validator rejects unknown canonical exercise IDs. |
| Invent missing screenshot content | Preserves source integrity for imports. | Image import schema requires `unreadable_regions` and `missing_or_unclear_content`. |
| Adapt an imported programme silently | Import default is extract/normalize/structure. | Prompt + review state has `mode = extract_only` unless later user action changes it. |
| Send raw profile/log/media data by default | Privacy minimization. | Prompt DTO builders expose only operation-specific fields. |
| Store raw prompts/responses as normal app data | They can contain sensitive data. | Persist only sanitized summaries or validation events. |
| Send prompts, AI responses, logs, candidate lists, media paths, or images to Crashlytics | Explicit privacy boundary. | Crash reporter allowlist + redaction tests. |
| Provide medical diagnosis or injury treatment | Safety boundary. | Prompt rules + response post-check for prohibited claims. |
| Provide precise body-fat percentage from photos | Physique analysis must be rough range only. | Schema requires range + confidence; exact single value fails validation. |
| Score attractiveness or shame body composition | Safety boundary. | Post-processing safety filter + schema categories disallow it. |
| Reproduce paid/source programme tables | Source integrity. | Prompt rules + output scanner for source reconstruction patterns. |

---

## 4. Deterministic App Responsibilities

The app must perform these tasks locally, regardless of provider output quality:

1. Select the AI operation.
2. Check provider and model capability.
3. Retrieve the API key from secure storage only when needed for a call.
4. Build a minimal operation-specific DTO.
5. Select allowed reference files.
6. Build candidate exercise lists from local Drift data.
7. Assemble system/user prompt messages.
8. Submit provider request.
9. Parse response.
10. Validate shared envelope.
11. Validate operation-specific schema.
12. Validate exercise IDs and custom-exercise draft fields.
13. Validate programme/workout schedule expansion.
14. Validate set-level prescription rules.
15. Validate warm-up/working set rules.
16. Validate superset rules by user experience level and operation type.
17. Validate import source-integrity fields.
18. Validate progress-media safety fields.
19. Run one automatic repair attempt where eligible.
20. Present review UI.
21. Persist only after user confirmation.
22. Log only redacted non-sensitive diagnostics.

---

## 5. AI Layer Architecture Boundary

Recommended module split:

```text
lib/features/ai/
  application/
    ai_operation_controller.dart
    ai_generation_controller.dart
    ai_chat_controller.dart
    ai_import_controller.dart
    ai_physique_analysis_controller.dart
  domain/
    ai_operation.dart
    ai_capability.dart
    ai_request_context.dart
    ai_response_envelope.dart
    ai_validation_result.dart
    ai_error.dart
  infrastructure/
    providers/
      ai_provider.dart
      openai_provider.dart
      anthropic_provider.dart
      gemini_provider.dart
    prompt_builder/
      prompt_builder.dart
      prompt_context_resolver.dart
      reference_selector.dart
      placeholder_renderer.dart
    validation/
      schema_registry.dart
      ai_output_validator.dart
      ai_repair_orchestrator.dart
    privacy/
      prompt_privacy_guard.dart
      ai_redactor.dart
      ai_consent_gate.dart
```

Rules:

- `application` coordinates Riverpod state and user workflows.
- `domain` owns operation contracts, DTOs, errors, and validation results.
- `infrastructure/providers` knows provider-specific API details.
- `infrastructure/prompt_builder` knows prompt assembly.
- `infrastructure/validation` knows schema/repair rules.
- `infrastructure/privacy` knows redaction and consent enforcement.
- Repositories remain in feature modules and are only called after validation and user confirmation.

---

## 6. App-Actionable vs Conversational Outputs

| Flow | Output Type | Persistence Behavior |
|---|---|---|
| AI Trainer general Q&A | Conversational text | Store chat message locally if chat history enabled. |
| AI Trainer asks to save workout | Structured JSON | Review draft, then save as `source = ai-chat`. |
| AI Trainer asks to save programme | Structured JSON | Review draft, then save as `source = ai-chat`. |
| Workout generation | Structured JSON | Review draft, then save if accepted. |
| Programme generation | Structured JSON | Review draft, then save if accepted. |
| Exercise swap recommendation | Conversational or options DTO | No programme change. |
| Exercise swap apply | Structured update payload | Review affected occurrences before applying. |
| Deload | Structured update payload | Review before applying. |
| Plateau suggestion | Structured suggestion/update payload | Review before save/action. |
| External import | Structured draft | Draft remains inactive until resolved/reviewed. |
| Image import | Structured draft | Draft remains inactive until resolved/reviewed. |
| Physique analysis | Structured analysis snapshot | Save locally only after user accepts/storage choice if required. |

---

## 7. Review-Before-Save Contract

Every AI-generated or AI-parsed app-actionable item must enter a review state before persistence.

Review state must show:

- generated/imported title;
- source operation;
- generation timestamp;
- provider/model used;
- validation status;
- unresolved blockers;
- review warnings;
- exercises requiring confirmation;
- custom exercises requiring completion;
- schedule expansion preview;
- set prescriptions and warm-up/working labels;
- supersets if present;
- privacy note for source/import/media flows;
- explicit Save / Cancel controls.

Block save when:

- JSON invalid after repair;
- wrong `response_type`;
- unsupported schema version;
- unknown exercise IDs;
- unresolved imported exercise matches;
- incomplete custom exercise drafts;
- malformed set prescriptions;
- missing set type labels where required;
- programme schedule cannot be expanded;
- unsupported beginner superset or beginner AI warm-up behavior;
- source-file content, AI internals, prompt text, raw AI response, or media artifacts appear in exportable fields;
- image import omits unreadable-region reporting when quality is low;
- physique analysis contains exact body-fat value, diagnosis, attractiveness scoring, shaming, or extreme diet guidance.

---

## 8. AI Source Attribution and Reference Use

The AI layer may include bundled reference files only when operation rules allow them.

| Reference Area | Usage Rule |
|---|---|
| `aedify-aedify-01-getting-started.md` | Beginner mindset and habit guidance. |
| `aedify-aedify-02-weight-loss.md` | Weight-loss education only, not medical treatment. |
| `aedify-aedify-03-muscle-building.md` | Muscle-building principles and beginner routine progression. |
| `aedify-aedify-04-nutrition-and-diet.md` | General calorie/protein/diet education. |
| `aedify-aedify-05-exercise-programming.md` | Programming principles and routine selection. |
| `aedify-aedify-06-faq.md` | Common questions, bulk/cut, expectations, troubleshooting. |
| `aedify-aedify-07-supplements.md` | Supplement education, not medical dosing prescriptions. |
| `aedify-aedify-08-glossary.md` | Term definitions for chat or explanations. |
| `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` | Supplemental only for eligible non-beginner Build Strength + Build Muscle requests. |

Reference selection must be deterministic before the AI call. The provider must not choose hidden reference material.

---

## 9. Acceptance Gate

This boundary plan is accepted only when:

- every AI operation has a deterministic local owner;
- no provider adapter can write to Drift directly;
- no AI payload builder can access secure keys except through the provider call boundary;
- validation rejects unknown exercise IDs and local IDs from AI;
- import flows prove AI cannot silently adapt source content;
- image import proves unreadable content is flagged, not invented;
- physique analysis proves exact body-fat values and prohibited content are rejected;
- Crashlytics tests prove prompts/responses/media/logs/keys are excluded.
