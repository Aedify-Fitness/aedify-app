# M6 — Progress Media Tracking Tickets v1.0

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
| Milestone | M6 — Progress Media Tracking |
| Ticket Count | 8 |

---

## Milestone Goal

Local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates.

## Tickets

### V1-M6-001 — Create progress media storage model and repositories

| Field | Value |
|---|---|
| Ticket ID | V1-M6-001 |
| Title | Create progress media storage model and repositories |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress media data |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need create progress media storage model and repositories so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress media data workstream for Create progress media storage model and repositories.
- Primary implementation focus: sessions, media items, thumbnails, notes, measurement snapshots, reminder state, relative paths.
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

- Create progress media storage model and repositories is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering create progress media storage model and repositories.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-002 — Build progress photo capture/import flow

| Field | Value |
|---|---|
| Ticket ID | V1-M6-002 |
| Title | Build progress photo capture/import flow |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress media capture |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build progress photo capture/import flow so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress media capture workstream for Build progress photo capture/import flow.
- Primary implementation focus: front/back/left/right photos, camera/gallery, thumbnails, notes, save confirmation.
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

- Build progress photo capture/import flow is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build progress photo capture/import flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-003 — Build progress video capture/import flow

| Field | Value |
|---|---|
| Ticket ID | V1-M6-003 |
| Title | Build progress video capture/import flow |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress media video |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build progress video capture/import flow so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress media video workstream for Build progress video capture/import flow.
- Primary implementation focus: short all-sides video, thumbnail, duration/size validation, permission states.
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

- Build progress video capture/import flow is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build progress video capture/import flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-004 — Implement progress media gallery and comparison UI

| Field | Value |
|---|---|
| Ticket ID | V1-M6-004 |
| Title | Implement progress media gallery and comparison UI |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress media UI |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement progress media gallery and comparison ui so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress media UI workstream for Implement progress media gallery and comparison UI.
- Primary implementation focus: timeline, angle display, video previews, baseline/latest and previous/latest comparison.
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

- Implement progress media gallery and comparison UI is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress media gallery and comparison ui.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-005 — Implement progress media reminder cadence

| Field | Value |
|---|---|
| Ticket ID | V1-M6-005 |
| Title | Implement progress media reminder cadence |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress reminders |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement progress media reminder cadence so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress reminders workstream for Implement progress media reminder cadence.
- Primary implementation focus: prompt only after first session, every 2 weeks/monthly/3 months/off.
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

- Implement progress media reminder cadence is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress media reminder cadence.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-006 — Implement progress media deletion and cleanup service

| Field | Value |
|---|---|
| Ticket ID | V1-M6-006 |
| Title | Implement progress media deletion and cleanup service |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Media lifecycle |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement progress media deletion and cleanup service so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Media lifecycle workstream for Implement progress media deletion and cleanup service.
- Primary implementation focus: delete metadata/files/thumbnails/temp artifacts, idempotent cleanup.
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

- Implement progress media deletion and cleanup service is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress media deletion and cleanup service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-007 — Create progress media privacy exclusion tests

| Field | Value |
|---|---|
| Ticket ID | V1-M6-007 |
| Title | Create progress media privacy exclusion tests |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | Progress privacy QA |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create progress media privacy exclusion tests so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the Progress privacy QA workstream for Create progress media privacy exclusion tests.
- Primary implementation focus: sentinel media names/notes/bytes absent from logs, Crashlytics, exports, AI by default.
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

- Create progress media privacy exclusion tests is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create progress media privacy exclusion tests.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M6-008 — Create M6 progress media acceptance smoke flow

| Field | Value |
|---|---|
| Ticket ID | V1-M6-008 |
| Title | Create M6 progress media acceptance smoke flow |
| Milestone | M6 — Progress Media Tracking |
| Feature Area | M6 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M6; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m6 progress media acceptance smoke flow so that local progress photos/videos, reminders, timeline, comparison, deletion, and privacy gates..

**Implementation Scope**

- Implement the M6 acceptance workstream for Create M6 progress media acceptance smoke flow.
- Primary implementation focus: save photo/video sessions, reminders, compare, delete, cleanup, privacy scan.
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

- Create M6 progress media acceptance smoke flow is implemented according to the source plans for M6.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m6 progress media acceptance smoke flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
