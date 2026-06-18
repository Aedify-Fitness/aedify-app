# M0 — Implementation Lock & Backlog Setup Tickets v1.0

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
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Ticket Count | 5 |

---

## Milestone Goal

Governance and tracker readiness before implementation starts.

## Tickets

### V1-M0-001 — Create implementation boards, labels, and ticket templates

| Field | Value |
|---|---|
| Ticket ID | V1-M0-001 |
| Title | Create implementation boards, labels, and ticket templates |
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Feature Area | Implementation governance |
| Ticket Type | process |
| Priority | P0 |
| Source References | Roadmap M0; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementation lead, I need create implementation boards, labels, and ticket templates so that governance and tracker readiness before implementation starts..

**Implementation Scope**

- Implement the Implementation governance workstream for Create implementation boards, labels, and ticket templates.
- Primary implementation focus: milestone lanes M0–M14, labels, ownership fields, change-control state, dependency links.
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

- Create implementation boards, labels, and ticket templates is implemented according to the source plans for M0.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering create implementation boards, labels, and ticket templates.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M0-002 — Import all planning artifacts into versioned docs folder

| Field | Value |
|---|---|
| Ticket ID | V1-M0-002 |
| Title | Import all planning artifacts into versioned docs folder |
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Feature Area | Implementation governance |
| Ticket Type | docs |
| Priority | P0 |
| Source References | Roadmap M0; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementation team, I need import all planning artifacts into versioned docs folder so that governance and tracker readiness before implementation starts..

**Implementation Scope**

- Implement the Implementation governance workstream for Import all planning artifacts into versioned docs folder.
- Primary implementation focus: PRD, validation log, roadmap, architecture, feature, data, AI, testing, and backlog package.
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

- Import all planning artifacts into versioned docs folder is implemented according to the source plans for M0.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering import all planning artifacts into versioned docs folder.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M0-003 — Create PRD-to-ticket traceability matrix

| Field | Value |
|---|---|
| Ticket ID | V1-M0-003 |
| Title | Create PRD-to-ticket traceability matrix |
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Feature Area | Traceability |
| Ticket Type | docs |
| Priority | P0 |
| Source References | Roadmap M0; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementation team, I need create prd-to-ticket traceability matrix so that governance and tracker readiness before implementation starts..

**Implementation Scope**

- Implement the Traceability workstream for Create PRD-to-ticket traceability matrix.
- Primary implementation focus: requirement coverage, non-goal boundaries, milestone mapping, QA mapping.
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

- Create PRD-to-ticket traceability matrix is implemented according to the source plans for M0.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering create prd-to-ticket traceability matrix.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M0-004 — Define Definition of Ready and Definition of Done

| Field | Value |
|---|---|
| Ticket ID | V1-M0-004 |
| Title | Define Definition of Ready and Definition of Done |
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Feature Area | Implementation governance |
| Ticket Type | process |
| Priority | P0 |
| Source References | Roadmap M0; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementation lead, I need define definition of ready and definition of done so that governance and tracker readiness before implementation starts..

**Implementation Scope**

- Implement the Implementation governance workstream for Define Definition of Ready and Definition of Done.
- Primary implementation focus: source references, dependencies, acceptance criteria, tests, privacy checks, scope control.
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

- Define Definition of Ready and Definition of Done is implemented according to the source plans for M0.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering define definition of ready and definition of done.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M0-005 — Create fixture and sample-data governance rules

| Field | Value |
|---|---|
| Ticket ID | V1-M0-005 |
| Title | Create fixture and sample-data governance rules |
| Milestone | M0 — Implementation Lock & Backlog Setup |
| Feature Area | Testing governance |
| Ticket Type | qa |
| Priority | P1 |
| Source References | Roadmap M0; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create fixture and sample-data governance rules so that governance and tracker readiness before implementation starts..

**Implementation Scope**

- Implement the Testing governance workstream for Create fixture and sample-data governance rules.
- Primary implementation focus: synthetic fixtures, sentinel values, golden fixture update process, no real private data.
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

- Create fixture and sample-data governance rules is implemented according to the source plans for M0.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create fixture and sample-data governance rules.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
