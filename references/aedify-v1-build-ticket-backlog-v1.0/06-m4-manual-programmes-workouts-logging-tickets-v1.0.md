# M4 — Manual Programmes, Workouts + Logging Tickets v1.0

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
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Ticket Count | 11 |

---

## Milestone Goal

The app works as an offline non-AI training tracker with transactional save and history.

## Tickets

### V1-M4-001 — Create programme/workout domain repositories

| Field | Value |
|---|---|
| Ticket ID | V1-M4-001 |
| Title | Create programme/workout domain repositories |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Programmes/workouts data |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need create programme/workout domain repositories so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Programmes/workouts data workstream for Create programme/workout domain repositories.
- Primary implementation focus: programmes, workouts, exercises, set prescriptions, warmup/working sets, supersets, sessions, logs.
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

- Create programme/workout domain repositories is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering create programme/workout domain repositories.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-002 — Build manual workout builder

| Field | Value |
|---|---|
| Ticket ID | V1-M4-002 |
| Title | Build manual workout builder |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Manual workouts |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build manual workout builder so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Manual workouts workstream for Build manual workout builder.
- Primary implementation focus: add/reorder/delete exercises, set editor, warmup/working sets, supersets, validation.
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

- Build manual workout builder is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build manual workout builder.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-003 — Build manual multi-week programme builder

| Field | Value |
|---|---|
| Ticket ID | V1-M4-003 |
| Title | Build manual multi-week programme builder |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Manual programmes |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build manual multi-week programme builder so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Manual programmes workstream for Build manual multi-week programme builder.
- Primary implementation focus: weeks/days/workouts, schedule, copy flows, active/inactive state, validation.
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

- Build manual multi-week programme builder is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build manual multi-week programme builder.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-004 — Implement active workout session runner

| Field | Value |
|---|---|
| Ticket ID | V1-M4-004 |
| Title | Implement active workout session runner |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Workout logging |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement active workout session runner so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Workout logging workstream for Implement active workout session runner.
- Primary implementation focus: start, log actual sets, pause/resume, app kill recovery, finish/cancel transactionally.
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

- Implement active workout session runner is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement active workout session runner.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-005 — Implement workout history and programme library

| Field | Value |
|---|---|
| Ticket ID | V1-M4-005 |
| Title | Implement workout history and programme library |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Training history |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement workout history and programme library so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Training history workstream for Implement workout history and programme library.
- Primary implementation focus: saved workouts, saved programmes, completed history, source labels, archive/delete.
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

- Implement workout history and programme library is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement workout history and programme library.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-006 — Implement custom exercise creation for manual flows

| Field | Value |
|---|---|
| Ticket ID | V1-M4-006 |
| Title | Implement custom exercise creation for manual flows |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Custom exercises |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement custom exercise creation for manual flows so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Custom exercises workstream for Implement custom exercise creation for manual flows.
- Primary implementation focus: local custom exercise form, validation, use in manual builder/logging.
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

- Implement custom exercise creation for manual flows is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement custom exercise creation for manual flows.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-007 — Implement warmup vs working set behavior

| Field | Value |
|---|---|
| Ticket ID | V1-M4-007 |
| Title | Implement warmup vs working set behavior |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Set prescriptions/logging |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement warmup vs working set behavior so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Set prescriptions/logging workstream for Implement warmup vs working set behavior.
- Primary implementation focus: clear labels, manual warmups all levels, future analytics exclusion support.
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

- Implement warmup vs working set behavior is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement warmup vs working set behavior.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-008 — Implement manual superset/execution group support

| Field | Value |
|---|---|
| Ticket ID | V1-M4-008 |
| Title | Implement manual superset/execution group support |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Supersets |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement manual superset/execution group support so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Supersets workstream for Implement manual superset/execution group support.
- Primary implementation focus: grouping, ordering, runner display, history, analytics attribution.
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

- Implement manual superset/execution group support is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement manual superset/execution group support.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-009 — Implement reusable draft validation service

| Field | Value |
|---|---|
| Ticket ID | V1-M4-009 |
| Title | Implement reusable draft validation service |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Validation |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement reusable draft validation service so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Validation workstream for Implement reusable draft validation service.
- Primary implementation focus: manual/AI/import/share draft validation, exercise refs, set rules, schedule rules.
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

- Implement reusable draft validation service is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement reusable draft validation service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-010 — Implement transactional save and rollback service

| Field | Value |
|---|---|
| Ticket ID | V1-M4-010 |
| Title | Implement transactional save and rollback service |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | Persistence |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need implement transactional save and rollback service so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the Persistence workstream for Implement transactional save and rollback service.
- Primary implementation focus: atomic writes for workouts/programmes/logs and rollback on injected failure.
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

- Implement transactional save and rollback service is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement transactional save and rollback service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M4-011 — Create M4 manual tracker acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M4-011 |
| Title | Create M4 manual tracker acceptance suite |
| Milestone | M4 — Manual Programmes, Workouts + Logging |
| Feature Area | M4 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M4; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m4 manual tracker acceptance suite so that the app works as an offline non-AI training tracker with transactional save and history..

**Implementation Scope**

- Implement the M4 acceptance workstream for Create M4 manual tracker acceptance suite.
- Primary implementation focus: offline tracker smoke: custom exercise, workout, programme, active session, kill/reopen, history.
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

- Create M4 manual tracker acceptance suite is implemented according to the source plans for M4.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m4 manual tracker acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
