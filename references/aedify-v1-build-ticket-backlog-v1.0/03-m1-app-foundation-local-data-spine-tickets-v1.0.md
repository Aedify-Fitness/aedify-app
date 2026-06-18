# M1 — App Foundation + Local Data Spine Tickets v1.0

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
| Milestone | M1 — App Foundation + Local Data Spine |
| Ticket Count | 11 |

---

## Milestone Goal

Local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI.

## Tickets

### V1-M1-001 — Initialize Flutter project structure and module boundaries

| Field | Value |
|---|---|
| Ticket ID | V1-M1-001 |
| Title | Initialize Flutter project structure and module boundaries |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | App foundation |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need initialize flutter project structure and module boundaries so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the App foundation workstream for Initialize Flutter project structure and module boundaries.
- Primary implementation focus: core/app/routing/database/services/features/shared/test utilities and import boundaries.
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

- Initialize Flutter project structure and module boundaries is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering initialize flutter project structure and module boundaries.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-002 — Set up Riverpod dependency injection skeleton

| Field | Value |
|---|---|
| Ticket ID | V1-M1-002 |
| Title | Set up Riverpod dependency injection skeleton |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | State management |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need set up riverpod dependency injection skeleton so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the State management workstream for Set up Riverpod dependency injection skeleton.
- Primary implementation focus: service/repository/controller providers, overrides, lifecycle rules, async states.
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

- Set up Riverpod dependency injection skeleton is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering set up riverpod dependency injection skeleton.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-003 — Implement Drift/SQLite foundation and migration scaffold

| Field | Value |
|---|---|
| Ticket ID | V1-M1-003 |
| Title | Implement Drift/SQLite foundation and migration scaffold |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Durable data |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement drift/sqlite foundation and migration scaffold so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Durable data workstream for Implement Drift/SQLite foundation and migration scaffold.
- Primary implementation focus: database class, schema versioning, migration strategy, transactions, foreign keys.
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

- Implement Drift/SQLite foundation and migration scaffold is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement drift/sqlite foundation and migration scaffold.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-004 — Implement local file storage directory contract

| Field | Value |
|---|---|
| Ticket ID | V1-M1-004 |
| Title | Implement local file storage directory contract |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Local file storage |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement local file storage directory contract so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Local file storage workstream for Implement local file storage directory contract.
- Primary implementation focus: documents/cache/temp/media/import/export/thumbnails/enhanced-image directories and cleanup helpers.
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

- Implement local file storage directory contract is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement local file storage directory contract.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-005 — Implement flutter_secure_storage wrapper for secrets

| Field | Value |
|---|---|
| Ticket ID | V1-M1-005 |
| Title | Implement flutter_secure_storage wrapper for secrets |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Secure secrets |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement flutter_secure_storage wrapper for secrets so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Secure secrets workstream for Implement flutter_secure_storage wrapper for secrets.
- Primary implementation focus: BYOK add/read/rotate/delete by alias, fake secure storage, leakage tests.
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

- Implement flutter_secure_storage wrapper for secrets is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement flutter_secure_storage wrapper for secrets.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-006 — Implement shared_preferences wrapper for non-critical preferences

| Field | Value |
|---|---|
| Ticket ID | V1-M1-006 |
| Title | Implement shared_preferences wrapper for non-critical preferences |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Simple preferences |
| Ticket Type | data |
| Priority | P1 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement shared_preferences wrapper for non-critical preferences so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Simple preferences workstream for Implement shared_preferences wrapper for non-critical preferences.
- Primary implementation focus: typed allowed keys only, forbidden critical/private data checks.
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

- Implement shared_preferences wrapper for non-critical preferences is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement shared_preferences wrapper for non-critical preferences.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-007 — Set up Dio/Retrofit networking foundation

| Field | Value |
|---|---|
| Ticket ID | V1-M1-007 |
| Title | Set up Dio/Retrofit networking foundation |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Networking |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need set up dio/retrofit networking foundation so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Networking workstream for Set up Dio/Retrofit networking foundation.
- Primary implementation focus: base Dio client, Retrofit pattern, hand-written adapters for complex AI calls, timeouts, cancellation.
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

- Set up Dio/Retrofit networking foundation is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering set up dio/retrofit networking foundation.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-008 — Implement redacted logging and Crashlytics harness

| Field | Value |
|---|---|
| Ticket ID | V1-M1-008 |
| Title | Implement redacted logging and Crashlytics harness |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Privacy foundation |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement redacted logging and crashlytics harness so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Privacy foundation workstream for Implement redacted logging and Crashlytics harness.
- Primary implementation focus: allowlisted diagnostics, forbidden-field redaction, sentinel privacy tests.
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

- Implement redacted logging and Crashlytics harness is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement redacted logging and crashlytics harness.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-009 — Create routing shell and navigation guards

| Field | Value |
|---|---|
| Ticket ID | V1-M1-009 |
| Title | Create routing shell and navigation guards |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Navigation |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need create routing shell and navigation guards so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Navigation workstream for Create routing shell and navigation guards.
- Primary implementation focus: onboarding, AI missing-key, unsupported-capability, unsaved draft, import entry placeholders.
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

- Create routing shell and navigation guards is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering create routing shell and navigation guards.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-010 — Create feature flags and private-release config

| Field | Value |
|---|---|
| Ticket ID | V1-M1-010 |
| Title | Create feature flags and private-release config |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Configuration |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need create feature flags and private-release config so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Configuration workstream for Create feature flags and private-release config.
- Primary implementation focus: local flags for AI, imports, sharing, media, physique, Crashlytics, diagnostics.
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

- Create feature flags and private-release config is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering create feature flags and private-release config.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M1-011 — Create foundation CI and smoke tests

| Field | Value |
|---|---|
| Ticket ID | V1-M1-011 |
| Title | Create foundation CI and smoke tests |
| Milestone | M1 — App Foundation + Local Data Spine |
| Feature Area | Quality automation |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M1; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create foundation ci and smoke tests so that local-first app shell, storage boundaries, Riverpod, Drift, secure storage, networking, logging, and CI..

**Implementation Scope**

- Implement the Quality automation workstream for Create foundation CI and smoke tests.
- Primary implementation focus: format, analysis, unit, migration, widget smoke, redaction gate.
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

- Create foundation CI and smoke tests is implemented according to the source plans for M1.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create foundation ci and smoke tests.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
