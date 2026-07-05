# 02 — BYOK Provider and Capability Implementation Plan v1.0


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

This file defines how the app configures and calls BYOK AI providers.

The provider layer must support OpenAI, Anthropic, and Google models configured by the user, while remaining provider-agnostic above the adapter boundary.

The app must treat provider capabilities as runtime configuration because not every selected model supports:

- native JSON/schema mode;
- streaming;
- image input;
- multi-image input;
- large context windows;
- tool-like structured responses;
- cost-efficient long prompts;
- video input.

v1 should not depend on server-side proxies. The user's API key is stored locally and used directly from the device.

---

## 2. Provider Abstraction

Recommended domain contract:

```text
AIProvider
  id: provider enum
  displayName: string
  validateApiKey(apiKeyRef) -> ProviderKeyValidationResult
  listKnownModels() -> List<AIModelDescriptor>
  getModelCapabilities(modelId) -> AIModelCapabilities
  sendText(request) -> AIProviderResponse
  sendStructured(request) -> AIProviderResponse
  sendMultimodal(request) -> AIProviderResponse
  estimateRequestCost(request) -> AICostEstimate?
```

`AIProvider` must not know about Drift repositories, feature controllers, or user-facing navigation. It only receives sanitized request payloads.

---

## 3. Provider Implementations

| Provider | Adapter | Use Cases | Notes |
|---|---|---|---|
| OpenAI | `OpenAIProvider` | Text, structured JSON, image-capable models where configured. | Use provider-native JSON/schema mode opportunistically where available. |
| Anthropic | `AnthropicProvider` | Text, structured output by prompt constraints, image-capable models where configured. | Map system/user messages according to provider format. |
| Google | `GeminiProvider` | Text, structured output, image-capable models where configured. | Map system instructions and multimodal content parts. |

Provider list is closed for v1. Adding providers later requires a new adapter plus capability mapping, but should not require changes to feature controllers.

---

## 4. Secure Key Storage

| Data | Storage | Allowed? | Notes |
|---|---|---|---|
| API key value | `flutter_secure_storage` | Yes | Only retrieved during validation or request execution. |
| API key alias/ref | Drift | Yes | E.g. `provider_config.secure_key_alias`. |
| Selected provider | Drift | Yes | Durable user AI setup. |
| Selected model | Drift | Yes | Durable user AI setup. |
| Last key validation date | Drift | Yes | Non-secret metadata. |
| Masked key suffix | Drift | Optional | Store only last 4 characters if needed for UX. |
| API key value in logs | Anywhere | No | Redaction must catch it. |
| API key value in shared prefs | `shared_preferences` | No | Explicitly forbidden. |
| API key value in Crashlytics | Crashlytics | No | Explicitly forbidden. |
| API key value in export/PDF | Files | No | Explicitly forbidden. |

The secure key lookup flow:

1. Controller requests provider config from Drift.
2. Controller requests key value from secure storage using alias.
3. Key value is passed directly to provider adapter request construction.
4. Key value is never attached to `AIRequestContext`, logs, validation events, snapshots, or errors.
5. Key value is cleared from local temporary variables as soon as practical.

---

## 5. Model Capability Descriptor

Every selected model should resolve to a local capability descriptor:

```text
AIModelCapabilities
  provider: openai | anthropic | google
  model_id: string
  display_name: string
  supports_text: bool
  supports_native_json_schema: bool
  supports_json_mode: bool
  supports_streaming: bool
  supports_image_input: bool
  supports_multi_image_input: bool
  supports_video_input: bool default false
  max_input_tokens: int?
  max_output_tokens: int?
  max_images_per_request: int?
  max_image_size_mb: int?
  supports_system_message: bool
  supports_system_instruction: bool
  known_cost_tier: cheap | medium | expensive | unknown
  last_validated_at: datetime?
```

Capability descriptor is used before prompt assembly where the payload type matters.

---

## 6. Capability Gates by Operation

| Operation | Required Capability | Blocked State |
|---|---|---|
| `AI_TRAINER_CHAT` | `supports_text` | “Selected model cannot process text prompts.” |
| `DAILY_WORKOUT` | `supports_text` | “AI workout generation requires a text-capable model.” |
| `MULTI_WEEK_PROGRAM` | `supports_text` | “AI programme generation requires a text-capable model.” |
| structured outputs | text + schema prompt; native JSON if available | Use prompt-only JSON when native schema mode missing. |
| `EXTERNAL_PLAN_IMPORT_PARSE` | `supports_text` | “External text import requires a text-capable model.” |
| `EXTERNAL_PLAN_IMPORT_IMAGE_PARSE` | `supports_image_input` | “Screenshot import requires an image-capable provider/model.” |
| `PROGRESS_MEDIA_ANALYSIS_ANALYZE` | `supports_image_input` | “AI physique analysis requires an image-capable provider/model.” |
| video physique analysis | `supports_image_input` after local frame extraction | Full video upload not required in v1. |

---

## 7. Networking Plan

Use Dio as the base HTTP engine.

Use Retrofit only where the provider endpoint is stable and regular enough to benefit from typed clients.

Use hand-written Dio adapters for:

- provider-specific chat/completions payloads;
- native JSON/schema-mode request bodies;
- streaming response handling;
- image/multimodal payloads;
- multipart-like uploads if required by a provider;
- provider-specific error payload parsing;
- request cancellation and timeout mapping.

Network adapter rules:

1. Never log full request bodies.
2. Never log API keys or authorization headers.
3. Never attach prompt text to thrown exceptions.
4. Map provider status codes to app-level `AIError` categories.
5. Expose retryability separately from user-facing message.
6. Support cancellation token from Riverpod controller.
7. Support operation-specific timeout configuration.

---

## 8. Provider Request Types

| Request Type | Used By | Payload |
|---|---|---|
| `AITextRequest` | Chat, generation, deload, swaps, plateau, text import | system message, user message, optional history, output preference. |
| `AIStructuredRequest` | App-actionable JSON operations | system message, user message, schema, schema version, response type. |
| `AIMultimodalRequest` | Image import, progress-media analysis | system message, user message, selected images/frames, metadata, schema. |
| `AIRepairRequest` | Structured-output repair | original operation metadata, validation errors, failed output excerpt/sanitized JSON, schema. |

Provider adapters should receive one of these normalized request types and convert it into provider-specific HTTP payloads.

---

## 9. Provider Switching Behavior

Provider switching must preserve local app state while changing future AI calls.

When user changes provider/model:

1. Existing programmes, workouts, logs, import drafts, and analysis snapshots remain unchanged.
2. Existing chat history remains local.
3. Future chat turns may be sent to the new provider as plain text history if user continues the same thread.
4. Provider capability cache is invalidated for the old model and loaded for the new model.
5. Operations unsupported by new model become disabled or show blocked states.
6. Existing secure key aliases remain unless user deletes them.
7. No old keys or prompts are exported or logged.

---

## 10. API Key Validation

Key validation should be explicit and lightweight.

Validation result fields:

```text
ProviderKeyValidationResult
  status: valid | invalid | network_error | rate_limited | provider_unavailable | unknown
  provider: enum
  model_checked: string?
  checked_at: datetime
  user_message: string
  redacted_error_code: string?
```

Validation must not use image payloads or expensive prompts.

Recommended flow:

1. User enters key.
2. Key is temporarily held in memory only.
3. App validates with provider using smallest supported request.
4. If valid, app stores key in secure storage and stores metadata in Drift.
5. If invalid, app discards key from memory and shows correction message.
6. Crashlytics receives only redacted error code if validation crashes.

---

## 11. Cost Disclosure and Control

Because BYOK cost belongs to the user, the AI layer must expose cost-sensitive states.

Minimum implementation:

- show that AI calls may incur provider costs;
- disclose when a retry/repair means another AI request;
- show warning before image import and physique analysis because media payloads are likely more expensive;
- prefer concise prompt payloads and candidate lists;
- avoid sending full logs when recent slice is sufficient;
- do not send full video when local frame extraction works;
- provide cancel controls before and during long AI operations.

Optional implementation:

- cost tier label from capability descriptor;
- estimated input/output token count;
- monthly local usage counter based on completed calls;
- user warning threshold.

---

## 12. Provider Error Mapping

| Provider/Error Condition | App Error Category | Retry? | User Message Pattern |
|---|---|---|---|
| Invalid API key | `auth_invalid` | No | “Your API key was rejected. Check the key and provider.” |
| Insufficient quota/credits | `quota_exceeded` | No immediate | “Your provider says this account has no available quota/credits.” |
| Rate limit | `rate_limited` | Later | “The provider is rate-limiting requests. Try again later.” |
| Timeout | `timeout` | Yes | “The AI request timed out. You can retry.” |
| Network unavailable | `offline` | Later | “AI features need internet access.” |
| Unsupported image input | `capability_blocked` | No | “This model does not support image input.” |
| Invalid provider response | `invalid_response` | Repair if structured | “The AI response could not be validated.” |
| Safety refusal | `provider_refusal` | Maybe with revised prompt | “The provider refused the request.” |
| Unknown provider error | `provider_error` | Maybe | “The provider returned an error.” |

---

## 13. Acceptance Gate

Provider implementation is accepted when:

- API keys are stored only in `flutter_secure_storage`;
- provider metadata is stored in Drift without secrets;
- `shared_preferences` never stores AI secrets or outputs;
- provider adapters work through normalized request objects;
- image-dependent operations are blocked when `supports_image_input = false`;
- text operations work without image capability;
- native JSON/schema mode is used when supported but not required for basic operation;
- provider switching preserves chat history locally;
- cancellation, timeout, rate-limit, invalid-key, and quota states are tested;
- logs and Crashlytics never include prompts, responses, headers, keys, media, or candidate lists.
