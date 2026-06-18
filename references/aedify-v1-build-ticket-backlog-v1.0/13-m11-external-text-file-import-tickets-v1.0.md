# M11 — External Text File Import Tickets v1.0

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
| Milestone | M11 — External Text File Import |
| Ticket Count | 8 |

---

## Milestone Goal

Text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save.

## Tickets

### V1-M11-001 — Implement external text file picker and extraction pipeline

| Field | Value |
|---|---|
| Ticket ID | V1-M11-001 |
| Title | Implement external text file picker and extraction pipeline |
| Milestone | M11 — External Text File Import |
| Feature Area | External text import |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement external text file picker and extraction pipeline so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the External text import workstream for Implement external text file picker and extraction pipeline.
- Primary implementation focus: PDF/TXT/MD/XLSX/CSV support, local extraction, unsupported/corrupt/encrypted/scanned rejection.
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

- Implement external text file picker and extraction pipeline is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement external text file picker and extraction pipeline.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-002 — Implement external import AI consent gate

| Field | Value |
|---|---|
| Ticket ID | V1-M11-002 |
| Title | Implement external import AI consent gate |
| Milestone | M11 — External Text File Import |
| Feature Area | Import consent |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement external import ai consent gate so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the Import consent workstream for Implement external import AI consent gate.
- Primary implementation focus: summary, explicit BYOK processing consent, cancel/delete, no AI before consent.
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

- Implement external import AI consent gate is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement external import ai consent gate.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-003 — Implement external text import AI parse operation

| Field | Value |
|---|---|
| Ticket ID | V1-M11-003 |
| Title | Implement external text import AI parse operation |
| Milestone | M11 — External Text File Import |
| Feature Area | External import AI |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement external text import ai parse operation so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the External import AI workstream for Implement external text import AI parse operation.
- Primary implementation focus: extract/normalize/structure only, no adaptation, no private profile/logs by default.
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
- Confirm artifacts from sharing/import/media/AI flows are excluded from Crashlytics and normal exports unless explicitly allowed by PRD.

**Dependencies**

- Prior milestone gates listed in roadmap v1.3.
- Foundation services from M1 where applicable.

**Acceptance Criteria**

- Implement external text import AI parse operation is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement external text import ai parse operation.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-004 — Implement external import exercise matching workflow

| Field | Value |
|---|---|
| Ticket ID | V1-M11-004 |
| Title | Implement external import exercise matching workflow |
| Milestone | M11 — External Text File Import |
| Feature Area | Exercise matching |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement external import exercise matching workflow so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the Exercise matching workstream for Implement external import exercise matching workflow.
- Primary implementation focus: exact/alias auto-match, ambiguous confirm, unmatched match/create/remove.
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

- Implement external import exercise matching workflow is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement external import exercise matching workflow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-005 — Implement external import review and inactive save

| Field | Value |
|---|---|
| Ticket ID | V1-M11-005 |
| Title | Implement external import review and inactive save |
| Milestone | M11 — External Text File Import |
| Feature Area | External import review |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement external import review and inactive save so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the External import review workstream for Implement external import review and inactive save.
- Primary implementation focus: review draft, resolve issues, save inactive, preserve source duration.
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

- Implement external import review and inactive save is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement external import review and inactive save.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-006 — Implement import repair/retry UX

| Field | Value |
|---|---|
| Ticket ID | V1-M11-006 |
| Title | Implement import repair/retry UX |
| Milestone | M11 — External Text File Import |
| Feature Area | External import resilience |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement import repair/retry ux so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the External import resilience workstream for Implement import repair/retry UX.
- Primary implementation focus: extraction/provider/validation/matching failures, safe retry/delete states.
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

- Implement import repair/retry UX is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement import repair/retry ux.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-007 — Create external import privacy/source-integrity tests

| Field | Value |
|---|---|
| Ticket ID | V1-M11-007 |
| Title | Create external import privacy/source-integrity tests |
| Milestone | M11 — External Text File Import |
| Feature Area | External import privacy QA |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create external import privacy/source-integrity tests so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the External import privacy QA workstream for Create external import privacy/source-integrity tests.
- Primary implementation focus: source content, extracted text, prompt/response, key, profile sentinel scans.
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

- Create external import privacy/source-integrity tests is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create external import privacy/source-integrity tests.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M11-008 — Create M11 external text import acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M11-008 |
| Title | Create M11 external text import acceptance suite |
| Milestone | M11 — External Text File Import |
| Feature Area | M11 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M11; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m11 external text import acceptance suite so that text-based external programme/workout import, consent, AI parsing, matching, review, and inactive save..

**Implementation Scope**

- Implement the M11 acceptance workstream for Create M11 external text import acceptance suite.
- Primary implementation focus: supported/unsupported files, consent, AI parse, matching, save, privacy.
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

- Create M11 external text import acceptance suite is implemented according to the source plans for M11.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m11 external text import acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
