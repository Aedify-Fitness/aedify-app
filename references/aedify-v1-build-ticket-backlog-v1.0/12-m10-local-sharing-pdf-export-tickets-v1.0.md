# M10 — Local Sharing + PDF Export Tickets v1.0

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
| Milestone | M10 — Local Sharing + PDF Export |
| Ticket Count | 8 |

---

## Milestone Goal

Native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup.

## Tickets

### V1-M10-001 — Define .aedifyplan schema v1 and validators

| Field | Value |
|---|---|
| Ticket ID | V1-M10-001 |
| Title | Define .aedifyplan schema v1 and validators |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | Plan sharing schema |
| Ticket Type | data |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app, I need define .aedifyplan schema v1 and validators so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the Plan sharing schema workstream for Define .aedifyplan schema v1 and validators.
- Primary implementation focus: share_schema_version 1, allowed fields, custom exercises, future schema rejection.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Define .aedifyplan schema v1 and validators is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering define .aedifyplan schema v1 and validators.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run repository, migration, transaction, and rollback fixtures.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-002 — Implement .aedifyplan export flow

| Field | Value |
|---|---|
| Ticket ID | V1-M10-002 |
| Title | Implement .aedifyplan export flow |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | Plan sharing export |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement .aedifyplan export flow so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the Plan sharing export workstream for Implement .aedifyplan export flow.
- Primary implementation focus: format picker, template default, exact prescription warning, OS share sheet, temp cleanup.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement .aedifyplan export flow is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement .aedifyplan export flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-003 — Implement .aedifyplan import flow

| Field | Value |
|---|---|
| Ticket ID | V1-M10-003 |
| Title | Implement .aedifyplan import flow |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | Plan sharing import |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement .aedifyplan import flow so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the Plan sharing import workstream for Implement .aedifyplan import flow.
- Primary implementation focus: parse/validate, preview, custom exercise recreation, inactive local copy.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement .aedifyplan import flow is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement .aedifyplan import flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-004 — Implement PDF export generator

| Field | Value |
|---|---|
| Ticket ID | V1-M10-004 |
| Title | Implement PDF export generator |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | PDF export |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement pdf export generator so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the PDF export workstream for Implement PDF export generator.
- Primary implementation focus: human-readable summaries, printable logging tables, optional appendix off by default.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement PDF export generator is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement pdf export generator.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-005 — Implement sharing privacy filter service

| Field | Value |
|---|---|
| Ticket ID | V1-M10-005 |
| Title | Implement sharing privacy filter service |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | Sharing privacy |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement sharing privacy filter service so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the Sharing privacy workstream for Implement sharing privacy filter service.
- Primary implementation focus: allowlist export DTO, forbidden field sentinels, shared filter for .aedifyplan/PDF.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement sharing privacy filter service is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement sharing privacy filter service.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-006 — Implement export/import file lifecycle cleanup

| Field | Value |
|---|---|
| Ticket ID | V1-M10-006 |
| Title | Implement export/import file lifecycle cleanup |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | File lifecycle |
| Ticket Type | privacy |
| Priority | P1 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement export/import file lifecycle cleanup so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the File lifecycle workstream for Implement export/import file lifecycle cleanup.
- Primary implementation focus: temp export/import cleanup, failed share/import cleanup, no default source-file retention.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement export/import file lifecycle cleanup is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement export/import file lifecycle cleanup.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-007 — Build sharing/import error and review states

| Field | Value |
|---|---|
| Ticket ID | V1-M10-007 |
| Title | Build sharing/import error and review states |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | Sharing UX |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build sharing/import error and review states so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the Sharing UX workstream for Build sharing/import error and review states.
- Primary implementation focus: invalid/future/corrupt/unsupported/privacy-warning/custom-exercise states.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Build sharing/import error and review states is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build sharing/import error and review states.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M10-008 — Create M10 sharing/PDF acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M10-008 |
| Title | Create M10 sharing/PDF acceptance suite |
| Milestone | M10 — Local Sharing + PDF Export |
| Feature Area | M10 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M10; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m10 sharing/pdf acceptance suite so that native .aedifyplan sharing, PDF export, import validation, privacy filters, and file cleanup..

**Implementation Scope**

- Implement the M10 acceptance workstream for Create M10 sharing/PDF acceptance suite.
- Primary implementation focus: golden app plan, PDF readability/privacy, custom exercise, share sheet smoke.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Create M10 sharing/PDF acceptance suite is implemented according to the source plans for M10.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m10 sharing/pdf acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
