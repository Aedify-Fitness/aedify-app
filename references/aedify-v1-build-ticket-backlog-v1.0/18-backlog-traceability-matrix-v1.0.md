# 18 — Backlog Traceability Matrix v1.0

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

---

## Ticket Summary

| Ticket ID | Milestone | Title | Area | Type | Priority |
|---|---|---|---|---|---|
| V1-M0-001 | M0 — Implementation Lock & Backlog Setup | Create implementation boards, labels, and ticket templates | Implementation governance | process | P0 |
| V1-M0-002 | M0 — Implementation Lock & Backlog Setup | Import all planning artifacts into versioned docs folder | Implementation governance | docs | P0 |
| V1-M0-003 | M0 — Implementation Lock & Backlog Setup | Create PRD-to-ticket traceability matrix | Traceability | docs | P0 |
| V1-M0-004 | M0 — Implementation Lock & Backlog Setup | Define Definition of Ready and Definition of Done | Implementation governance | process | P0 |
| V1-M0-005 | M0 — Implementation Lock & Backlog Setup | Create fixture and sample-data governance rules | Testing governance | qa | P1 |
| V1-M1-001 | M1 — App Foundation + Local Data Spine | Initialize Flutter project structure and module boundaries | App foundation | feature | P0 |
| V1-M1-002 | M1 — App Foundation + Local Data Spine | Set up Riverpod dependency injection skeleton | State management | feature | P0 |
| V1-M1-003 | M1 — App Foundation + Local Data Spine | Implement Drift/SQLite foundation and migration scaffold | Durable data | data | P0 |
| V1-M1-004 | M1 — App Foundation + Local Data Spine | Implement local file storage directory contract | Local file storage | data | P0 |
| V1-M1-005 | M1 — App Foundation + Local Data Spine | Implement flutter_secure_storage wrapper for secrets | Secure secrets | privacy | P0 |
| V1-M1-006 | M1 — App Foundation + Local Data Spine | Implement shared_preferences wrapper for non-critical preferences | Simple preferences | data | P1 |
| V1-M1-007 | M1 — App Foundation + Local Data Spine | Set up Dio/Retrofit networking foundation | Networking | feature | P1 |
| V1-M1-008 | M1 — App Foundation + Local Data Spine | Implement redacted logging and Crashlytics harness | Privacy foundation | privacy | P0 |
| V1-M1-009 | M1 — App Foundation + Local Data Spine | Create routing shell and navigation guards | Navigation | feature | P1 |
| V1-M1-010 | M1 — App Foundation + Local Data Spine | Create feature flags and private-release config | Configuration | feature | P1 |
| V1-M1-011 | M1 — App Foundation + Local Data Spine | Create foundation CI and smoke tests | Quality automation | qa | P0 |
| V1-M2-001 | M2 — Exercise Dataset Sync + Exercise Library | Implement Firebase exercise dataset download client | Exercise dataset sync | feature | P0 |
| V1-M2-002 | M2 — Exercise Dataset Sync + Exercise Library | Create exercise dataset parser and schema validator | Exercise dataset sync | data | P0 |
| V1-M2-003 | M2 — Exercise Dataset Sync + Exercise Library | Persist canonical exercise library in Drift | Exercise library data | data | P0 |
| V1-M2-004 | M2 — Exercise Dataset Sync + Exercise Library | Build exercise library list and detail screens | Exercise library UI | feature | P0 |
| V1-M2-005 | M2 — Exercise Dataset Sync + Exercise Library | Implement exercise video and thumbnail handling | Exercise media | feature | P1 |
| V1-M2-006 | M2 — Exercise Dataset Sync + Exercise Library | Implement bodymap SVG muscle-bucket interaction | Bodymap | feature | P1 |
| V1-M2-007 | M2 — Exercise Dataset Sync + Exercise Library | Build deterministic candidate exercise query service | Candidate engine | data | P0 |
| V1-M2-008 | M2 — Exercise Dataset Sync + Exercise Library | Reserve custom exercise model hooks | Exercise model | data | P2 |
| V1-M2-009 | M2 — Exercise Dataset Sync + Exercise Library | Build dataset sync status and recovery UI | Sync UX | feature | P1 |
| V1-M2-010 | M2 — Exercise Dataset Sync + Exercise Library | Create exercise dataset/library QA fixture suite | Exercise QA | qa | P0 |
| V1-M3-001 | M3 — Onboarding, Profile, Settings + BYOK Setup | Build onboarding flow and completion gate | Onboarding | feature | P0 |
| V1-M3-002 | M3 — Onboarding, Profile, Settings + BYOK Setup | Implement profile repository and edit screens | Profile | feature | P0 |
| V1-M3-003 | M3 — Onboarding, Profile, Settings + BYOK Setup | Implement settings shell and storage-boundary displays | Settings | feature | P1 |
| V1-M3-004 | M3 — Onboarding, Profile, Settings + BYOK Setup | Implement BYOK provider/model/key configuration UI | BYOK setup | feature | P0 |
| V1-M3-005 | M3 — Onboarding, Profile, Settings + BYOK Setup | Create provider capability matrix and gate service | BYOK capability gates | ai | P0 |
| V1-M3-006 | M3 — Onboarding, Profile, Settings + BYOK Setup | Connect profile preferences to candidate engine | Profile/candidate integration | data | P1 |
| V1-M3-007 | M3 — Onboarding, Profile, Settings + BYOK Setup | Implement unit and measurement preference handling | Units/settings | feature | P1 |
| V1-M3-008 | M3 — Onboarding, Profile, Settings + BYOK Setup | Create onboarding/profile/BYOK privacy tests | Profile privacy QA | qa | P0 |
| V1-M3-009 | M3 — Onboarding, Profile, Settings + BYOK Setup | Create M3 setup acceptance smoke flow | M3 acceptance | qa | P0 |
| V1-M4-001 | M4 — Manual Programmes, Workouts + Logging | Create programme/workout domain repositories | Programmes/workouts data | data | P0 |
| V1-M4-002 | M4 — Manual Programmes, Workouts + Logging | Build manual workout builder | Manual workouts | feature | P0 |
| V1-M4-003 | M4 — Manual Programmes, Workouts + Logging | Build manual multi-week programme builder | Manual programmes | feature | P0 |
| V1-M4-004 | M4 — Manual Programmes, Workouts + Logging | Implement active workout session runner | Workout logging | feature | P0 |
| V1-M4-005 | M4 — Manual Programmes, Workouts + Logging | Implement workout history and programme library | Training history | feature | P0 |
| V1-M4-006 | M4 — Manual Programmes, Workouts + Logging | Implement custom exercise creation for manual flows | Custom exercises | feature | P1 |
| V1-M4-007 | M4 — Manual Programmes, Workouts + Logging | Implement warmup vs working set behavior | Set prescriptions/logging | feature | P0 |
| V1-M4-008 | M4 — Manual Programmes, Workouts + Logging | Implement manual superset/execution group support | Supersets | feature | P1 |
| V1-M4-009 | M4 — Manual Programmes, Workouts + Logging | Implement reusable draft validation service | Validation | data | P0 |
| V1-M4-010 | M4 — Manual Programmes, Workouts + Logging | Implement transactional save and rollback service | Persistence | data | P0 |
| V1-M4-011 | M4 — Manual Programmes, Workouts + Logging | Create M4 manual tracker acceptance suite | M4 acceptance | qa | P0 |
| V1-M5-001 | M5 — Analytics, PRs + Plateau Base Logic | Implement analytics query layer over completed logs | Analytics data | data | P0 |
| V1-M5-002 | M5 — Analytics, PRs + Plateau Base Logic | Implement PR detection service | PR analytics | feature | P0 |
| V1-M5-003 | M5 — Analytics, PRs + Plateau Base Logic | Implement e1RM estimation service | Strength analytics | feature | P0 |
| V1-M5-004 | M5 — Analytics, PRs + Plateau Base Logic | Implement plateau detection base logic | Plateau logic | feature | P1 |
| V1-M5-005 | M5 — Analytics, PRs + Plateau Base Logic | Build analytics dashboard and exercise history screens | Analytics UI | feature | P1 |
| V1-M5-006 | M5 — Analytics, PRs + Plateau Base Logic | Implement analytics invalidation after edits/deletes | Analytics consistency | data | P0 |
| V1-M5-007 | M5 — Analytics, PRs + Plateau Base Logic | Create M5 analytics acceptance fixture suite | M5 acceptance | qa | P0 |
| V1-M6-001 | M6 — Progress Media Tracking | Create progress media storage model and repositories | Progress media data | data | P0 |
| V1-M6-002 | M6 — Progress Media Tracking | Build progress photo capture/import flow | Progress media capture | feature | P0 |
| V1-M6-003 | M6 — Progress Media Tracking | Build progress video capture/import flow | Progress media video | feature | P1 |
| V1-M6-004 | M6 — Progress Media Tracking | Implement progress media gallery and comparison UI | Progress media UI | feature | P0 |
| V1-M6-005 | M6 — Progress Media Tracking | Implement progress media reminder cadence | Progress reminders | feature | P1 |
| V1-M6-006 | M6 — Progress Media Tracking | Implement progress media deletion and cleanup service | Media lifecycle | privacy | P0 |
| V1-M6-007 | M6 — Progress Media Tracking | Create progress media privacy exclusion tests | Progress privacy QA | qa | P0 |
| V1-M6-008 | M6 — Progress Media Tracking | Create M6 progress media acceptance smoke flow | M6 acceptance | qa | P0 |
| V1-M7-001 | M7 — AI Infrastructure | Create AI operation registry | AI infrastructure | ai | P0 |
| V1-M7-002 | M7 — AI Infrastructure | Implement AI provider adapter contract and fake provider | Provider adapters | ai | P0 |
| V1-M7-003 | M7 — AI Infrastructure | Implement real BYOK provider adapters | Provider adapters | ai | P1 |
| V1-M7-004 | M7 — AI Infrastructure | Implement prompt builder and context assembly service | Prompt builder | ai | P0 |
| V1-M7-005 | M7 — AI Infrastructure | Implement structured-output schema registry and validators | Structured output | ai | P0 |
| V1-M7-006 | M7 — AI Infrastructure | Implement structured-output repair orchestrator | AI repair | ai | P0 |
| V1-M7-007 | M7 — AI Infrastructure | Implement AI candidate exercise payload builder | Candidate exercise engine | ai | P0 |
| V1-M7-008 | M7 — AI Infrastructure | Implement AI request lifecycle controller | AI lifecycle | ai | P1 |
| V1-M7-009 | M7 — AI Infrastructure | Implement AI privacy/consent/redaction middleware | AI privacy | privacy | P0 |
| V1-M7-010 | M7 — AI Infrastructure | Create M7 AI infrastructure acceptance suite | M7 acceptance | qa | P0 |
| V1-M8-001 | M8 — AI Workout + Programme Generation | Build AI daily workout generation entry flow | AI workout generation | ai | P0 |
| V1-M8-002 | M8 — AI Workout + Programme Generation | Implement AI workout draft review and save transaction | AI workout review | feature | P0 |
| V1-M8-003 | M8 — AI Workout + Programme Generation | Build AI multi-week programme generation flow | AI programme generation | ai | P0 |
| V1-M8-004 | M8 — AI Workout + Programme Generation | Implement Beginner Path A/B generation flow | Beginner AI generation | ai | P0 |
| V1-M8-005 | M8 — AI Workout + Programme Generation | Implement non-beginner strength warmup prescription rules | AI prescription rules | ai | P0 |
| V1-M8-006 | M8 — AI Workout + Programme Generation | Implement AI superset eligibility rules | AI prescription rules | ai | P1 |
| V1-M8-007 | M8 — AI Workout + Programme Generation | Implement powerbuilding eligibility and source-integrity guardrails | Powerbuilding AI | ai | P1 |
| V1-M8-008 | M8 — AI Workout + Programme Generation | Implement AI generation error states | AI generation resilience | feature | P1 |
| V1-M8-009 | M8 — AI Workout + Programme Generation | Create M8 AI generation acceptance suite | M8 acceptance | qa | P0 |
| V1-M9-001 | M9 — AI Trainer Chat + AI Update Flows | Build local AI trainer chat controller | AI chat | ai | P0 |
| V1-M9-002 | M9 — AI Trainer Chat + AI Update Flows | Implement chat safety routing | AI chat safety | ai | P0 |
| V1-M9-003 | M9 — AI Trainer Chat + AI Update Flows | Implement chat save-intent routing | Chat save flows | ai | P0 |
| V1-M9-004 | M9 — AI Trainer Chat + AI Update Flows | Implement exercise swap recommendation flow | AI updates | ai | P1 |
| V1-M9-005 | M9 — AI Trainer Chat + AI Update Flows | Implement exercise swap apply transaction | AI updates | feature | P1 |
| V1-M9-006 | M9 — AI Trainer Chat + AI Update Flows | Implement deload recommendation and apply flow | AI updates | ai | P1 |
| V1-M9-007 | M9 — AI Trainer Chat + AI Update Flows | Implement plateau suggestion flow | AI plateau suggestions | ai | P1 |
| V1-M9-008 | M9 — AI Trainer Chat + AI Update Flows | Implement AI update source metadata | AI update metadata | data | P1 |
| V1-M9-009 | M9 — AI Trainer Chat + AI Update Flows | Create M9 chat/update acceptance suite | M9 acceptance | qa | P0 |
| V1-M10-001 | M10 — Local Sharing + PDF Export | Define .aedifyplan schema v1 and validators | Plan sharing schema | data | P0 |
| V1-M10-002 | M10 — Local Sharing + PDF Export | Implement .aedifyplan export flow | Plan sharing export | feature | P0 |
| V1-M10-003 | M10 — Local Sharing + PDF Export | Implement .aedifyplan import flow | Plan sharing import | feature | P0 |
| V1-M10-004 | M10 — Local Sharing + PDF Export | Implement PDF export generator | PDF export | feature | P0 |
| V1-M10-005 | M10 — Local Sharing + PDF Export | Implement sharing privacy filter service | Sharing privacy | privacy | P0 |
| V1-M10-006 | M10 — Local Sharing + PDF Export | Implement export/import file lifecycle cleanup | File lifecycle | privacy | P1 |
| V1-M10-007 | M10 — Local Sharing + PDF Export | Build sharing/import error and review states | Sharing UX | feature | P1 |
| V1-M10-008 | M10 — Local Sharing + PDF Export | Create M10 sharing/PDF acceptance suite | M10 acceptance | qa | P0 |
| V1-M11-001 | M11 — External Text File Import | Implement external text file picker and extraction pipeline | External text import | feature | P0 |
| V1-M11-002 | M11 — External Text File Import | Implement external import AI consent gate | Import consent | privacy | P0 |
| V1-M11-003 | M11 — External Text File Import | Implement external text import AI parse operation | External import AI | ai | P0 |
| V1-M11-004 | M11 — External Text File Import | Implement external import exercise matching workflow | Exercise matching | feature | P0 |
| V1-M11-005 | M11 — External Text File Import | Implement external import review and inactive save | External import review | feature | P0 |
| V1-M11-006 | M11 — External Text File Import | Implement import repair/retry UX | External import resilience | feature | P1 |
| V1-M11-007 | M11 — External Text File Import | Create external import privacy/source-integrity tests | External import privacy QA | qa | P0 |
| V1-M11-008 | M11 — External Text File Import | Create M11 external text import acceptance suite | M11 acceptance | qa | P0 |
| V1-M12-001 | M12 — Image/Screenshot External Import | Implement image/screenshot picker and ordering flow | Image import | feature | P0 |
| V1-M12-002 | M12 — Image/Screenshot External Import | Implement local-first readability enhancement pipeline | Image preprocessing | feature | P0 |
| V1-M12-003 | M12 — Image/Screenshot External Import | Implement multimodal provider capability gate | Image import AI gate | ai | P0 |
| V1-M12-004 | M12 — Image/Screenshot External Import | Implement image import AI parse and repair operation | Image import AI | ai | P0 |
| V1-M12-005 | M12 — Image/Screenshot External Import | Reuse external import matching/review/save for image drafts | Image import review | feature | P0 |
| V1-M12-006 | M12 — Image/Screenshot External Import | Implement image artifact cleanup and privacy tests | Image import privacy | privacy | P0 |
| V1-M12-007 | M12 — Image/Screenshot External Import | Create M12 image import acceptance suite | M12 acceptance | qa | P0 |
| V1-M13-001 | M13 — Optional AI Physique Analysis | Implement progress media AI analysis consent flow | Physique analysis consent | privacy | P0 |
| V1-M13-002 | M13 — Optional AI Physique Analysis | Implement media/frame selection for analysis | Physique media prep | feature | P0 |
| V1-M13-003 | M13 — Optional AI Physique Analysis | Implement progress physique analysis AI operation | Physique analysis AI | ai | P0 |
| V1-M13-004 | M13 — Optional AI Physique Analysis | Implement progress media comparison AI operation | Physique comparison AI | ai | P1 |
| V1-M13-005 | M13 — Optional AI Physique Analysis | Build analysis result UI and local snapshot storage | Physique analysis UI | feature | P1 |
| V1-M13-006 | M13 — Optional AI Physique Analysis | Create physique privacy and safety red-team tests | Physique privacy/safety QA | qa | P0 |
| V1-M13-007 | M13 — Optional AI Physique Analysis | Create M13 physique analysis acceptance suite | M13 acceptance | qa | P0 |
| V1-M14-001 | M14 — Privacy, Resilience + Release Hardening | Run full storage-boundary audit | Privacy/security audit | privacy | P0 |
| V1-M14-002 | M14 — Privacy, Resilience + Release Hardening | Run Crashlytics redaction and diagnostics audit | Crashlytics/privacy | privacy | P0 |
| V1-M14-003 | M14 — Privacy, Resilience + Release Hardening | Run import/export privacy audit | Import/export privacy | privacy | P0 |
| V1-M14-004 | M14 — Privacy, Resilience + Release Hardening | Run offline-first and network failure audit | Resilience | qa | P0 |
| V1-M14-005 | M14 — Privacy, Resilience + Release Hardening | Run iOS/Android platform parity audit | Cross-platform | qa | P0 |
| V1-M14-006 | M14 — Privacy, Resilience + Release Hardening | Run performance and storage stress tests | Performance/storage | qa | P1 |
| V1-M14-007 | M14 — Privacy, Resilience + Release Hardening | Run accessibility and usability pass | Accessibility/usability | qa | P1 |
| V1-M14-008 | M14 — Privacy, Resilience + Release Hardening | Create private release smoke script and sign-off checklist | Release management | process | P0 |
| V1-M14-009 | M14 — Privacy, Resilience + Release Hardening | Resolve or classify all blocking defects | Release readiness | process | P0 |
| V1-M14-010 | M14 — Privacy, Resilience + Release Hardening | Prepare private v1 release package and rollback plan | Private release | release | P0 |

## Stack Boundary Coverage

| Boundary | Primary Tickets |
|---|---|
| Riverpod state/dependency injection | V1-M1-002 plus feature-controller tickets in each milestone |
| Drift/SQLite durable data | M1 data foundation, M2 library, M4 programmes/logging, M5 analytics, M6 media metadata, M10–M13 import/AI snapshots |
| shared_preferences non-critical only | V1-M1-006, M3 settings, M14 storage audit |
| flutter_secure_storage secrets only | V1-M1-005, M3 BYOK, M14 storage audit |
| Dio/Retrofit networking | V1-M1-007, M2 sync, M7 provider adapters |
| Crashlytics redaction | V1-M1-008 and all privacy QA/audit tickets |