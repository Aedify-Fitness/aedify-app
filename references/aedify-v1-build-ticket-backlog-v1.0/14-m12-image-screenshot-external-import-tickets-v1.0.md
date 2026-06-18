# M12 — Image/Screenshot External Import Tickets v1.0

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
| Milestone | M12 — Image/Screenshot External Import |
| Ticket Count | 7 |

---

## Milestone Goal

Image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup.

## Tickets

### V1-M12-001 — Implement image/screenshot picker and ordering flow

| Field | Value |
|---|---|
| Ticket ID | V1-M12-001 |
| Title | Implement image/screenshot picker and ordering flow |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image import |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement image/screenshot picker and ordering flow so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image import workstream for Implement image/screenshot picker and ordering flow.
- Primary implementation focus: PNG/JPG/JPEG/WEBP/HEIC support where possible, multi-select, user-defined order.
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

- Implement image/screenshot picker and ordering flow is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement image/screenshot picker and ordering flow.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-002 — Implement local-first readability enhancement pipeline

| Field | Value |
|---|---|
| Ticket ID | V1-M12-002 |
| Title | Implement local-first readability enhancement pipeline |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image preprocessing |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need implement local-first readability enhancement pipeline so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image preprocessing workstream for Implement local-first readability enhancement pipeline.
- Primary implementation focus: orientation, crop, deskew, brightness/contrast, sharpening, noise reduction, upscaling where practical.
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

- Implement local-first readability enhancement pipeline is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement local-first readability enhancement pipeline.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-003 — Implement multimodal provider capability gate

| Field | Value |
|---|---|
| Ticket ID | V1-M12-003 |
| Title | Implement multimodal provider capability gate |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image import AI gate |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement multimodal provider capability gate so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image import AI gate workstream for Implement multimodal provider capability gate.
- Primary implementation focus: image input required, fail closed for text-only or unknown model, change-provider path.
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

- Implement multimodal provider capability gate is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement multimodal provider capability gate.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-004 — Implement image import AI parse and repair operation

| Field | Value |
|---|---|
| Ticket ID | V1-M12-004 |
| Title | Implement image import AI parse and repair operation |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image import AI |
| Ticket Type | ai |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the AI layer, I need implement image import ai parse and repair operation so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image import AI workstream for Implement image import AI parse and repair operation.
- Primary implementation focus: ordered/enhanced images, no invention, missing/unclear metadata, structured draft.
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

- Implement image import AI parse and repair operation is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Provider/capability/consent gates run before provider calls.
- Invalid or unsafe outputs cannot be saved.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement image import ai parse and repair operation.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-005 — Reuse external import matching/review/save for image drafts

| Field | Value |
|---|---|
| Ticket ID | V1-M12-005 |
| Title | Reuse external import matching/review/save for image drafts |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image import review |
| Ticket Type | feature |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the user, I need reuse external import matching/review/save for image drafts so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image import review workstream for Reuse external import matching/review/save for image drafts.
- Primary implementation focus: exercise resolution, quality warnings, inactive save, image metadata.
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

- Reuse external import matching/review/save for image drafts is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.

**QA / Test Steps**

- Run unit/widget/integration tests covering reuse external import matching/review/save for image drafts.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.
- Run iOS and Android smoke coverage for user-facing flows.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-006 — Implement image artifact cleanup and privacy tests

| Field | Value |
|---|---|
| Ticket ID | V1-M12-006 |
| Title | Implement image artifact cleanup and privacy tests |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | Image import privacy |
| Ticket Type | privacy |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the app owner, I need implement image artifact cleanup and privacy tests so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the Image import privacy workstream for Implement image artifact cleanup and privacy tests.
- Primary implementation focus: original/enhanced/temp artifacts excluded from logs/Crashlytics/exports and cleaned.
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

- Implement image artifact cleanup and privacy tests is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Storage boundary checks pass.
- Migration/cleanup/rollback behavior is tested where applicable.

**QA / Test Steps**

- Run unit/widget/integration tests covering implement image artifact cleanup and privacy tests.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.

### V1-M12-007 — Create M12 image import acceptance suite

| Field | Value |
|---|---|
| Ticket ID | V1-M12-007 |
| Title | Create M12 image import acceptance suite |
| Milestone | M12 — Image/Screenshot External Import |
| Feature Area | M12 acceptance |
| Ticket Type | qa |
| Priority | P0 |
| Source References | Roadmap M12; Architecture Plan; Feature Plan; Data Model Plan; AI Plan where applicable; Testing Plan acceptance gates; Package Validation Log |

**User / Developer Story**

As the implementer, I need create m12 image import acceptance suite so that image import, ordering, readability enhancement, multimodal BYOK gate, AI parse, review, cleanup..

**Implementation Scope**

- Implement the M12 acceptance workstream for Create M12 image import acceptance suite.
- Primary implementation focus: formats, ordering, enhancement, gates, parse/repair, review/save, cleanup/privacy.
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

- Create M12 image import acceptance suite is implemented according to the source plans for M12.
- Implementation does not expand PRD v1 scope.
- All required dependencies are available or the feature fails closed with a clear user-facing state.
- Fixture/manual test evidence is attached to the milestone gate.
- A failing privacy or data-integrity case blocks completion.

**QA / Test Steps**

- Run unit/widget/integration tests covering create m12 image import acceptance suite.
- Run negative/error-state tests, not only happy path.
- Run redaction/sentinel checks when private data can be touched.

**Out of Scope**

- Product behavior not already approved in the re-locked PRD v1.10.
- Public launch, cloud sync, user accounts, subscriptions, ads, or social features.
- Silent PRD changes inside implementation tickets.
