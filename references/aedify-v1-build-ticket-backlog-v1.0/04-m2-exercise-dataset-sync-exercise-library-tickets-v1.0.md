# M2 — Exercise Dataset Sync + Exercise Library Tickets v1.0

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
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Ticket Count | 10 |

---

## Milestone Goal

Firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine.

## Tickets

### V1-M2-001 — Implement Firebase exercise dataset download client

| Field | Value |
|---|---|
| Ticket ID | V1-M2-001 |
| Title | Implement Firebase exercise dataset download client |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise dataset sync |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the user, I need implement firebase exercise dataset download client so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise dataset sync workstream for Implement Firebase exercise dataset download client.
- Primary implementation focus: manifest/version fetch, dataset JSON download, retry, offline, interrupted download recovery.
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

- Implement Firebase exercise dataset download client is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement firebase exercise dataset download client.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-002 — Create exercise dataset parser and schema validator

| Field | Value |
|---|---|
| Ticket ID | V1-M2-002 |
| Title | Create exercise dataset parser and schema validator |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise dataset sync |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the app, I need create exercise dataset parser and schema validator so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise dataset sync workstream for Create exercise dataset parser and schema validator.
- Primary implementation focus: schema_version, generated_at, source, exercise_count, required exercise fields, future schema rejection.
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

- Create exercise dataset parser and schema validator is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering create exercise dataset parser and schema validator.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-003 — Persist canonical exercise library in Drift

| Field | Value |
|---|---|
| Ticket ID | V1-M2-003 |
| Title | Persist canonical exercise library in Drift |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise library data |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the app, I need persist canonical exercise library in drift so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise library data workstream for Persist canonical exercise library in Drift.
- Primary implementation focus: canonical exercise tables, videos, steps, muscles, indexes, transactional replacement.
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

- Persist canonical exercise library in Drift is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering persist canonical exercise library in drift.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-004 — Build exercise library list and detail screens

| Field | Value |
|---|---|
| Ticket ID | V1-M2-004 |
| Title | Build exercise library list and detail screens |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise library UI |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the user, I need build exercise library list and detail screens so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise library UI workstream for Build exercise library list and detail screens.
- Primary implementation focus: offline search/filter/detail for modality, equipment, difficulty, muscle groups, steps, videos.
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

- Build exercise library list and detail screens is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build exercise library list and detail screens.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-005 — Implement exercise video and thumbnail handling

| Field | Value |
|---|---|
| Ticket ID | V1-M2-005 |
| Title | Implement exercise video and thumbnail handling |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise media |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the user, I need implement exercise video and thumbnail handling so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise media workstream for Implement exercise video and thumbnail handling.
- Primary implementation focus: remote video display, offline placeholders, missing variants, no blocking core detail text.
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

- Implement exercise video and thumbnail handling is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement exercise video and thumbnail handling.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-006 — Implement bodymap SVG muscle-bucket interaction

| Field | Value |
|---|---|
| Ticket ID | V1-M2-006 |
| Title | Implement bodymap SVG muscle-bucket interaction |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Bodymap |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the user, I need implement bodymap svg muscle-bucket interaction so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Bodymap workstream for Implement bodymap SVG muscle-bucket interaction.
- Primary implementation focus: front/back SVG, 14 UI muscle buckets, tap-to-filter, accessibility labels.
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

- Implement bodymap SVG muscle-bucket interaction is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement bodymap svg muscle-bucket interaction.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-007 — Build deterministic candidate exercise query service

| Field | Value |
|---|---|
| Ticket ID | V1-M2-007 |
| Title | Build deterministic candidate exercise query service |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Candidate engine |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the app, I need build deterministic candidate exercise query service so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Candidate engine workstream for Build deterministic candidate exercise query service.
- Primary implementation focus: hard equipment/experience filters, avoid lists, soft goal ranking, compact DTOs.
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

- Build deterministic candidate exercise query service is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering build deterministic candidate exercise query service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-008 — Reserve custom exercise model hooks

| Field | Value |
|---|---|
| Ticket ID | V1-M2-008 |
| Title | Reserve custom exercise model hooks |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise model |
| Ticket Type | data |
| Priority | P2 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the app, I need reserve custom exercise model hooks so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise model workstream for Reserve custom exercise model hooks.
- Primary implementation focus: canonical vs custom identity and relationships for later manual/import/share flows.
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

- Reserve custom exercise model hooks is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering reserve custom exercise model hooks.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-009 — Build dataset sync status and recovery UI

| Field | Value |
|---|---|
| Ticket ID | V1-M2-009 |
| Title | Build dataset sync status and recovery UI |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Sync UX |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the user, I need build dataset sync status and recovery ui so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Sync UX workstream for Build dataset sync status and recovery UI.
- Primary implementation focus: first-sync offline, retry, stale dataset, unsupported schema, safe errors.
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

- Build dataset sync status and recovery UI is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build dataset sync status and recovery ui.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M2-010 — Create exercise dataset/library QA fixture suite

| Field | Value |
|---|---|
| Ticket ID | V1-M2-010 |
| Title | Create exercise dataset/library QA fixture suite |
| Milestone | M2 — Exercise Dataset Sync + Exercise Library |
| Feature Area | Exercise QA |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M2; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log; aedify-transform-for-firebase.js; aedify-musclewiki-exercises.firebase.json |

**User / Developer Story**

As the implementer, I need create exercise dataset/library qa fixture suite so that firebase-hosted exercise dataset available offline with library, bodymap, and candidate engine..

**Implementation Scope**

- Implement the Exercise QA workstream for Create exercise dataset/library QA fixture suite.
- Primary implementation focus: valid/corrupt/future/duplicate fixtures and search/bodymap/candidate expectations.
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

- Create exercise dataset/library QA fixture suite is implemented according to the source plans for M2.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create exercise dataset/library qa fixture suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
