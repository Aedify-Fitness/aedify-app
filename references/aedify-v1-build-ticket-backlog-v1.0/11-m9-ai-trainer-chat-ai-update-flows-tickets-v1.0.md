# M9 — AI Trainer Chat + AI Update Flows Tickets v1.0

| Field | Value |
|---|---|
| Product | Aedify |
| Document Package | v1 Build Ticket Backlog |
| Package Version | v1.0 |
| Source Baseline | PRD v1.10 Final / Re-locked after Package Validation |
| Roadmap Baseline | aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md |
| Architecture Baseline | aedify-v1-architecture-implementation-plan-v1.0.md |
| Feature Plan Baseline | v1-feature-by-feature-build-plan-v1.0/ |
| Data Model Baseline | v1-data-model-implementation-plan-v1.0/ |
| AI Plan Baseline | v1-ai-implementation-plan-v1.0/ |
| Testing Baseline | v1-testing-acceptance-plan-v1.0/ |
| Status | Implementation Backlog — Ready for Task Tracker Conversion |
| Scope Rule | No product scope change; implementation-only ticket breakdown |
| Platforms | iOS and Android, Flutter single codebase |
| Architecture | Local-only, offline-first, BYOK AI |
| Stack | Riverpod, Drift/SQLite, shared_preferences, flutter_secure_storage, Dio, Retrofit |
| Created | 2026-06-17 |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Ticket Count | 9 |

---

## Milestone Goal

Conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates.

## Tickets

### V1-M9-001 — Build local AI trainer chat controller

| Field | Value |
|---|---|
| Ticket ID | V1-M9-001 |
| Title | Build local AI trainer chat controller |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI chat |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need build local ai trainer chat controller so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI chat workstream for Build local AI trainer chat controller.
- Primary implementation focus: thread/message state, conversational calls, context trimming, cancellation, local privacy.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Build local AI trainer chat controller is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering build local ai trainer chat controller.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-002 — Implement chat safety routing

| Field | Value |
|---|---|
| Ticket ID | V1-M9-002 |
| Title | Implement chat safety routing |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI chat safety |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement chat safety routing so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI chat safety workstream for Implement chat safety routing.
- Primary implementation focus: medical/injury/eating disorder/mental health redirects, no clinical advice.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement chat safety routing is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement chat safety routing.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-003 — Implement chat save-intent routing

| Field | Value |
|---|---|
| Ticket ID | V1-M9-003 |
| Title | Implement chat save-intent routing |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | Chat save flows |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement chat save-intent routing so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the Chat save flows workstream for Implement chat save-intent routing.
- Primary implementation focus: explicit save/create detection, structured workout/programme route, ai-chat source.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement chat save-intent routing is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement chat save-intent routing.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-004 — Implement exercise swap recommendation flow

| Field | Value |
|---|---|
| Ticket ID | V1-M9-004 |
| Title | Implement exercise swap recommendation flow |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI updates |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement exercise swap recommendation flow so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI updates workstream for Implement exercise swap recommendation flow.
- Primary implementation focus: candidate-filtered alternatives, rationale, no mutation until accepted.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement exercise swap recommendation flow is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement exercise swap recommendation flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-005 — Implement exercise swap apply transaction

| Field | Value |
|---|---|
| Ticket ID | V1-M9-005 |
| Title | Implement exercise swap apply transaction |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI updates |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement exercise swap apply transaction so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI updates workstream for Implement exercise swap apply transaction.
- Primary implementation focus: scope preview, transactional replacement, cancel/rollback, source metadata.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- No direct AI prompt/provider impact unless explicitly listed in the implementation scope.
- If this ticket feeds AI later, expose only minimal DTOs and never raw database rows.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement exercise swap apply transaction is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement exercise swap apply transaction.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-006 — Implement deload recommendation and apply flow

| Field | Value |
|---|---|
| Ticket ID | V1-M9-006 |
| Title | Implement deload recommendation and apply flow |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI updates |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement deload recommendation and apply flow so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI updates workstream for Implement deload recommendation and apply flow.
- Primary implementation focus: deload draft, affected sessions/sets preview, apply after confirmation.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement deload recommendation and apply flow is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement deload recommendation and apply flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-007 — Implement plateau suggestion flow

| Field | Value |
|---|---|
| Ticket ID | V1-M9-007 |
| Title | Implement plateau suggestion flow |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI plateau suggestions |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement plateau suggestion flow so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI plateau suggestions workstream for Implement plateau suggestion flow.
- Primary implementation focus: deterministic plateau DTO, minimal log summary, no invented plateau.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- AI outputs are drafts until locally validated and user-reviewed where required.
- Use operation registry, provider gates, structured-output validation, and one repair attempt where eligible.
- Do not persist raw prompts or raw responses by default.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement plateau suggestion flow is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement plateau suggestion flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-008 — Implement AI update source metadata

| Field | Value |
|---|---|
| Ticket ID | V1-M9-008 |
| Title | Implement AI update source metadata |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | AI update metadata |
| Ticket Type | data |
| Priority | P1 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement ai update source metadata so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the AI update metadata workstream for Implement AI update source metadata.
- Primary implementation focus: source/operation/schema/review metadata without raw prompts or responses.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Use Drift/SQLite for durable structured records and migrations.
- Do not place critical or private data in shared_preferences.
- Use transactions for multi-row writes and rollback on failure.

**AI / Prompt Impact**

- No direct AI prompt/provider impact unless explicitly listed in the implementation scope.
- If this ticket feeds AI later, expose only minimal DTOs and never raw database rows.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement AI update source metadata is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement ai update source metadata.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M9-009 — Create M9 chat/update acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M9-009 |
| Title | Create M9 chat/update acceptance suite |
| Milestone | M9 — AI Trainer Chat + AI Update Flows |
| Feature Area | M9 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M9; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m9 chat/update acceptance suite so that conversational chat, save-intent routing, swaps, deloads, plateau suggestions, and transactional updates..

**Implementation Scope**

- Implement the M9 acceptance workstream for Create M9 chat/update acceptance suite.
- Primary implementation focus: chat, safety, save intent, swap/deload/plateau, transactions, privacy.
- Use the approved architecture and package boundaries for this milestone.
- Add recoverable user-facing states for invalid, missing, offline, unsupported, cancelled, and failed cases where applicable.
- Wire the work through testable services/controllers rather than embedding business rules directly in UI widgets.

**Data Model Impact**

- Follow the data model plan for any touched tables, indexes, relationships, schema versions, and retention rules.
- If this ticket does not require schema changes, prove it consumes existing repositories/services without adding hidden persistence.

**AI / Prompt Impact**

- No direct AI prompt/provider impact unless explicitly listed in the implementation scope.
- If this ticket feeds AI later, expose only minimal DTOs and never raw database rows.

**Privacy / Security Impact**

- Apply global privacy rules and redaction harness.
- Do not log secrets, profile-sensitive data, workout logs, prompts, responses, candidate lists, media, imports, exports, or raw local database rows.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Create M9 chat/update acceptance suite is implemented according to the source plans for M9.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m9 chat/update acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
