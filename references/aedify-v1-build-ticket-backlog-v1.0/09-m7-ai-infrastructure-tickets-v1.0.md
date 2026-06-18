# M7 — AI Infrastructure Tickets v1.0

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
| Milestone | M7 — AI Infrastructure |
| Ticket Count | 10 |

---

## Milestone Goal

Provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests.

## Tickets

### V1-M7-001 — Create AI operation registry

| Field | Value |
|---|---|
| Ticket ID | V1-M7-001 |
| Title | Create AI operation registry |
| Milestone | M7 — AI Infrastructure |
| Feature Area | AI infrastructure |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need create ai operation registry so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the AI infrastructure workstream for Create AI operation registry.
- Primary implementation focus: operation IDs, response modes, schemas, capability requirements, consent, prompt template IDs.
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

- Create AI operation registry is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering create ai operation registry.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-002 — Implement AI provider adapter contract and fake provider

| Field | Value |
|---|---|
| Ticket ID | V1-M7-002 |
| Title | Implement AI provider adapter contract and fake provider |
| Milestone | M7 — AI Infrastructure |
| Feature Area | Provider adapters |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement ai provider adapter contract and fake provider so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the Provider adapters workstream for Implement AI provider adapter contract and fake provider.
- Primary implementation focus: provider-neutral DTOs, normalized errors, fake success/error/invalid JSON/cancel fixtures.
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

- Implement AI provider adapter contract and fake provider is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement ai provider adapter contract and fake provider.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-003 — Implement real BYOK provider adapters

| Field | Value |
|---|---|
| Ticket ID | V1-M7-003 |
| Title | Implement real BYOK provider adapters |
| Milestone | M7 — AI Infrastructure |
| Feature Area | Provider adapters |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement real byok provider adapters so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the Provider adapters workstream for Implement real BYOK provider adapters.
- Primary implementation focus: secure key lookup, Dio requests, provider-specific parsing, error normalization.
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

- Implement real BYOK provider adapters is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement real byok provider adapters.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-004 — Implement prompt builder and context assembly service

| Field | Value |
|---|---|
| Ticket ID | V1-M7-004 |
| Title | Implement prompt builder and context assembly service |
| Milestone | M7 — AI Infrastructure |
| Feature Area | Prompt builder |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement prompt builder and context assembly service so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the Prompt builder workstream for Implement prompt builder and context assembly service.
- Primary implementation focus: instruction modules, placeholders, reference selection, operation-minimal DTOs, snapshots.
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

- Implement prompt builder and context assembly service is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement prompt builder and context assembly service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-005 — Implement structured-output schema registry and validators

| Field | Value |
|---|---|
| Ticket ID | V1-M7-005 |
| Title | Implement structured-output schema registry and validators |
| Milestone | M7 — AI Infrastructure |
| Feature Area | Structured output |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement structured-output schema registry and validators so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the Structured output workstream for Implement structured-output schema registry and validators.
- Primary implementation focus: envelope/schema/domain validation for generation, import, image, physique, update flows.
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

- Implement structured-output schema registry and validators is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement structured-output schema registry and validators.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-006 — Implement structured-output repair orchestrator

| Field | Value |
|---|---|
| Ticket ID | V1-M7-006 |
| Title | Implement structured-output repair orchestrator |
| Milestone | M7 — AI Infrastructure |
| Feature Area | AI repair |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement structured-output repair orchestrator so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the AI repair workstream for Implement structured-output repair orchestrator.
- Primary implementation focus: one automatic repair, eligibility rules, repair prompt, user-triggered retry disclosure.
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

- Implement structured-output repair orchestrator is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement structured-output repair orchestrator.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-007 — Implement AI candidate exercise payload builder

| Field | Value |
|---|---|
| Ticket ID | V1-M7-007 |
| Title | Implement AI candidate exercise payload builder |
| Milestone | M7 — AI Infrastructure |
| Feature Area | Candidate exercise engine |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement ai candidate exercise payload builder so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the Candidate exercise engine workstream for Implement AI candidate exercise payload builder.
- Primary implementation focus: compact filtered candidate DTOs, token budget, unknown-ID rejection support.
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

- Implement AI candidate exercise payload builder is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement ai candidate exercise payload builder.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-008 — Implement AI request lifecycle controller

| Field | Value |
|---|---|
| Ticket ID | V1-M7-008 |
| Title | Implement AI request lifecycle controller |
| Milestone | M7 — AI Infrastructure |
| Feature Area | AI lifecycle |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement ai request lifecycle controller so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the AI lifecycle workstream for Implement AI request lifecycle controller.
- Primary implementation focus: Riverpod runner states, cancellation, timeout, retry, duplicate prevention, safe recovery.
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

- Implement AI request lifecycle controller is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement ai request lifecycle controller.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-009 — Implement AI privacy/consent/redaction middleware

| Field | Value |
|---|---|
| Ticket ID | V1-M7-009 |
| Title | Implement AI privacy/consent/redaction middleware |
| Milestone | M7 — AI Infrastructure |
| Feature Area | AI privacy |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement ai privacy/consent/redaction middleware so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the AI privacy workstream for Implement AI privacy/consent/redaction middleware.
- Primary implementation focus: preflight payload checks, consent gates, telemetry redaction, forbidden sentinels.
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

- Apply allowlist logging and Crashlytics redaction.
- No secrets, prompts, responses, candidate lists, private logs, injuries, media, screenshots, imports, or exports in telemetry.
- Add sentinel tests for every touched private data path.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement AI privacy/consent/redaction middleware is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement ai privacy/consent/redaction middleware.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M7-010 — Create M7 AI infrastructure acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M7-010 |
| Title | Create M7 AI infrastructure acceptance suite |
| Milestone | M7 — AI Infrastructure |
| Feature Area | M7 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M7; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m7 ai infrastructure acceptance suite so that provider abstraction, prompt builder, operation registry, schemas, validation, repair, privacy, and fake-provider tests..

**Implementation Scope**

- Implement the M7 acceptance workstream for Create M7 AI infrastructure acceptance suite.
- Primary implementation focus: registry, prompt snapshots, provider fake, validation/repair, privacy/consent, candidates.
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

- Create M7 AI infrastructure acceptance suite is implemented according to the source plans for M7.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m7 ai infrastructure acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
