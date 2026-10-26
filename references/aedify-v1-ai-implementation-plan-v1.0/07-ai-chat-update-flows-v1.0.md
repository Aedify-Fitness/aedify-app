# 07 — AI Trainer Chat and Update Flows Plan v1.0


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

This file defines implementation for M9 AI Trainer Chat and AI update flows.

It covers:

- normal AI Trainer chat;
- chat save workout;
- chat save programme;
- exercise swap recommendation;
- exercise swap apply update;
- deload flow;
- plateau suggestion flow;
- chat history handling;
- conversational vs structured-output routing.

---

## 2. Chat Routing Model

The chat controller must classify each user message into one of these modes:

| Mode | Trigger | Output |
|---|---|---|
| General chat | User asks advice, explanation, clarification. | Conversational response. |
| Save workout intent | User asks to create/save a workout from chat. | Structured workout draft. |
| Save programme intent | User asks to create/save a programme from chat. | Structured programme draft. |
| Update intent | User asks to modify saved item. | Clarify target or structured update flow. |
| Medical/injury concern | Pain, diagnosis, treatment, clinical request. | Safe refusal/redirect to qualified professional. |
| Import-related request | User wants to parse an external source. | Route to import flow, not normal chat. |
| Progress media analysis request | User wants body/physique analysis. | Route to consented progress-media analysis flow. |

---

## 3. Normal AI Trainer Chat

Normal chat is conversational and not required to return JSON.

Prompt includes:

- tone;
- identity;
- athlete profile where useful;
- recent lift log slice where relevant;
- reference files selected by intent;
- programming rules;
- how-to-respond rules;
- chat history within context limits.

Normal chat must not:

- persist new workouts/programmes automatically;
- prescribe medical treatment;
- inspect progress media without consented analysis flow;
- use image import path casually;
- send full local database rows;
- include raw prompts/responses in Crashlytics.

---

## 4. Chat Save Workout

When user explicitly asks to save/create a workout from chat:

1. Detect save intent.
2. Build structured-output request using `AI_TRAINER_CHAT_SAVE_WORKOUT`.
3. Include relevant chat context.
4. Include profile, equipment, constraints, candidate list.
5. Request JSON only.
6. Validate as daily/saved workout schema.
7. Repair once if eligible.
8. Present review draft.
9. Save as `source = ai-chat` only after confirmation.

Blocked states:

- ambiguous request without enough data;
- missing provider/key;
- unsupported schema;
- unknown exercise IDs;
- invalid set prescriptions;
- user cancels review.

---

## 5. Chat Save Programme

When user explicitly asks to save/create a programme from chat:

1. Detect programme save intent.
2. Require enough schedule/duration/goal data or return `needs_input`.
3. Build `AI_TRAINER_CHAT_SAVE_PROGRAMME` request.
4. Include candidate programme exercise list.
5. Include reference files where allowed.
6. Request template-based JSON programme.
7. Validate programme expansion.
8. Present review draft.
9. Save as `source = ai-chat` after confirmation.

Programme outputs must follow all M8 generation rules.

---

## 6. Exercise Swap Recommendation

Recommendation flow is advisory.

Input:

- target exercise;
- reason for swap;
- active workout/programme context;
- equipment;
- injuries/substitutions;
- swap candidate list.

Output:

- conversational explanation;
- optional ranked options;
- no automatic update.

User then chooses an option or asks to apply.

---

## 7. Exercise Swap Apply Update

Apply flow is app-actionable and structured.

Scope options:

| Scope | Meaning |
|---|---|
| `single_occurrence` | Update only one scheduled occurrence. |
| `remaining_programme` | Update uncompleted future occurrences. |
| `entire_programme_template` | Update reusable template and applicable future occurrences. |

Validation:

- original target exists;
- replacement exists in candidate list;
- scope is valid;
- completed logs remain unchanged;
- schedule/template update can be applied transactionally;
- user sees affected occurrence preview before save.

---

## 8. Deload Flow

Deload flow can be triggered by:

- user request;
- plateau context;
- programme schedule;
- fatigue-related chat request.

AI may propose:

- load reduction;
- volume reduction;
- exercise simplification;
- technique week;
- taper/test prep for eligible advanced users;
- no change if deload not appropriate.

Validation:

- deload changes are bounded;
- warm-up/working set labels remain valid;
- progression rules after deload are coherent;
- user reviews before applying;
- completed logs are never edited.

---

## 9. Plateau Suggestion Flow

Plateau suggestion uses local plateau detection output.

Input:

- plateau event;
- affected exercise;
- recent working sets;
- recent volume/intensity trend;
- PR/e1RM context;
- programme context;
- candidate accessories/variations;
- user constraints.

Output may include:

- explanation of likely cause;
- suggested action;
- deload recommendation;
- swap/accessory recommendation;
- progression adjustment;
- request for more data.

App must distinguish:

- suggestion only;
- structured update candidate;
- deload flow handoff;
- swap flow handoff.

---

## 10. Chat History Storage and Privacy

Chat messages are local only.

Store:

- thread ID;
- role;
- message content;
- timestamp;
- provider/model used for AI message;
- optional source operation link;
- local-only status.

Do not store:

- API keys;
- provider auth headers;
- raw network debug payloads;
- images/media in chat unless later explicitly scoped;
- Crashlytics copies of chat content.

User should be able to delete chat threads locally.

---

## 11. Acceptance Gate

M9 AI chat/update flows are accepted when:

- normal chat stays conversational;
- save intents route to structured-output flows;
- chat-generated saved items use `source = ai-chat`;
- swap recommendation does not mutate data;
- swap apply shows affected scope before saving;
- deload update is reviewable;
- plateau suggestion uses local plateau event context;
- medical/injury concerns are safely redirected;
- provider switching preserves local history;
- chat content is never sent to Crashlytics.
