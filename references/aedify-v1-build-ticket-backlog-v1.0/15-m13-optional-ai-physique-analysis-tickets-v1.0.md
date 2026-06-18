# M13 — Optional AI Physique Analysis Tickets v1.0

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
| Milestone | M13 — Optional AI Physique Analysis |
| Ticket Count | 7 |

---

## Milestone Goal

Consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion.

## Tickets

### V1-M13-001 — Implement progress media AI analysis consent flow

| Field | Value |
|---|---|
| Ticket ID | V1-M13-001 |
| Title | Implement progress media AI analysis consent flow |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique analysis consent |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement progress media ai analysis consent flow so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique analysis consent workstream for Implement progress media AI analysis consent flow.
- Primary implementation focus: explicit consent, selected media count/type, rough/limited nature, cancel no-call.
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

- Implement progress media AI analysis consent flow is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress media ai analysis consent flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-002 — Implement media/frame selection for analysis

| Field | Value |
|---|---|
| Ticket ID | V1-M13-002 |
| Title | Implement media/frame selection for analysis |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique media prep |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement media/frame selection for analysis so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique media prep workstream for Implement media/frame selection for analysis.
- Primary implementation focus: selected photos/video frames only, temporary payload artifacts, cleanup.
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

- Implement media/frame selection for analysis is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement media/frame selection for analysis.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-003 — Implement progress physique analysis AI operation

| Field | Value |
|---|---|
| Ticket ID | V1-M13-003 |
| Title | Implement progress physique analysis AI operation |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique analysis AI |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement progress physique analysis ai operation so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique analysis AI workstream for Implement progress physique analysis AI operation.
- Primary implementation focus: rough BF range, confidence, limitations, observations, training feedback, safety validation.
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

- Implement progress physique analysis AI operation is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress physique analysis ai operation.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-004 — Implement progress media comparison AI operation

| Field | Value |
|---|---|
| Ticket ID | V1-M13-004 |
| Title | Implement progress media comparison AI operation |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique comparison AI |
| Ticket Type | ai |
| Priority | P1 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement progress media comparison ai operation so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique comparison AI workstream for Implement progress media comparison AI operation.
- Primary implementation focus: baseline/latest and previous/latest comparison, selected media only, bounded feedback.
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

- Implement progress media comparison AI operation is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement progress media comparison ai operation.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-005 — Build analysis result UI and local snapshot storage

| Field | Value |
|---|---|
| Ticket ID | V1-M13-005 |
| Title | Build analysis result UI and local snapshot storage |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique analysis UI |
| Ticket Type | feature |
| Priority | P1 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need build analysis result ui and local snapshot storage so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique analysis UI workstream for Build analysis result UI and local snapshot storage.
- Primary implementation focus: view/save/delete snapshot, source sessions, limitations, no unsafe accepted output.
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

- Build analysis result UI and local snapshot storage is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering build analysis result ui and local snapshot storage.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-006 — Create physique privacy and safety red-team tests

| Field | Value |
|---|---|
| Ticket ID | V1-M13-006 |
| Title | Create physique privacy and safety red-team tests |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | Physique privacy/safety QA |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create physique privacy and safety red-team tests so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the Physique privacy/safety QA workstream for Create physique privacy and safety red-team tests.
- Primary implementation focus: exact BF, diagnosis, attractiveness, shaming, extreme diet, media/key/prompt sentinels.
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

- Create physique privacy and safety red-team tests is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create physique privacy and safety red-team tests.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M13-007 — Create M13 physique analysis acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M13-007 |
| Title | Create M13 physique analysis acceptance suite |
| Milestone | M13 — Optional AI Physique Analysis |
| Feature Area | M13 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M13; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m13 physique analysis acceptance suite so that consent-based selected-media analysis with strict safety, local snapshots, comparison, and deletion..

**Implementation Scope**

- Implement the M13 acceptance workstream for Create M13 physique analysis acceptance suite.
- Primary implementation focus: consent, capability, selected payload, analyze/compare, safety, deletion/cleanup.
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

- Create M13 physique analysis acceptance suite is implemented according to the source plans for M13.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m13 physique analysis acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
