# Aedify — Testing / Acceptance Plan Index

> Document: Aedify — Testing / Acceptance Plan  
> Plan Version: v1.0  
> Source Baseline: PRD v1.10 re-locked for implementation  
> Roadmap Baseline: aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md  
> Architecture Baseline: aedify-v1-architecture-implementation-plan-v1.0.md  
> Package Scope: Private v1, maximum 5 users  
> Stack Baseline: Flutter, Riverpod, Drift/SQLite, shared_preferences, flutter_secure_storage, Dio, Retrofit, Firebase Storage/Auth/Crashlytics  
> Date: 2026-06-16


## Purpose

This package defines the complete v1 testing and acceptance strategy for the Aedify implementation. It converts the PRD, roadmap, architecture plan, feature build plan, data model plan, and AI implementation plan into executable quality gates.

This is not a generic QA checklist. It is the release-control plan for the private v1 build. A milestone is not considered complete until its functional, data, privacy, resilience, and platform-specific acceptance checks pass.

## Package Structure

| File | Area | Primary Milestones |
|---|---|---|
| `01-testing-strategy-scope-v1.0.md` | Testing philosophy, scope, quality gates, release rules | All |
| `02-test-environments-fixtures-v1.0.md` | Device matrix, local fixtures, fake providers, seeded data | All |
| `03-milestone-acceptance-gates-v1.0.md` | Milestone-by-milestone exit gates | M0–M14 |
| `04-foundation-local-data-tests-v1.0.md` | Flutter foundation, Riverpod, Drift, migrations, storage boundaries | M0–M1 |
| `05-exercise-library-bodymap-tests-v1.0.md` | Firebase dataset sync, exercise library, videos, TTS, bodymap | M2 |
| `06-onboarding-profile-byok-tests-v1.0.md` | Onboarding, profile, settings, secure BYOK | M3 |
| `07-manual-programmes-workouts-logging-tests-v1.0.md` | Manual programmes, workouts, templates, logging | M4 |
| `08-analytics-prs-plateau-tests-v1.0.md` | Analytics, PRs, e1RM, plateau detection | M5 |
| `09-progress-media-tests-v1.0.md` | Progress photos/videos, reminders, local file lifecycle | M6 |
| `10-ai-infrastructure-tests-v1.0.md` | Provider adapters, capability gates, prompt builder, validation/repair | M7 |
| `11-ai-generation-chat-tests-v1.0.md` | AI workouts, programmes, chat-save, update flows | M8–M9 |
| `12-sharing-export-import-tests-v1.0.md` | `.aedifyplan`, PDF export, native share/import validation | M10 |
| `13-external-text-import-tests-v1.0.md` | PDF/TXT/MD/XLSX/CSV extraction and AI import drafts | M11 |
| `14-image-import-tests-v1.0.md` | Screenshot/image import, ordering, enhancement, cleanup | M12 |
| `15-physique-analysis-tests-v1.0.md` | Optional AI physique analysis and comparison | M13 |
| `16-privacy-security-crashlytics-tests-v1.0.md` | Redaction, logs, secrets, exports, local file protection | Cross-cutting / M14 |
| `17-cross-platform-accessibility-performance-tests-v1.0.md` | iOS/Android parity, accessibility, performance, storage stress | Cross-cutting / M14 |
| `18-private-release-acceptance-plan-v1.0.md` | Private release checklist, beta acceptance, sign-off | M14 |
| `19-test-matrix-backlog-ticket-seeds-v1.0.md` | Ticket seeds and traceability matrix | All |

## Milestone Order Under Test

The acceptance plan follows the current roadmap order:

1. M0 — Implementation Lock & Backlog Setup
2. M1 — App Foundation + Local Data Spine
3. M2 — Exercise Dataset Sync + Exercise Library
4. M3 — Onboarding, Profile, Settings + BYOK Setup
5. M4 — Manual Programmes, Workouts + Logging
6. M5 — Analytics, PRs + Plateau Base Logic
7. M6 — Progress Media Tracking
8. M7 — AI Infrastructure
9. M8 — AI Workout + Programme Generation
10. M9 — AI Trainer Chat + AI Update Flows
11. M10 — Local Sharing + PDF Export
12. M11 — External Text File Import
13. M12 — Image/Screenshot External Import
14. M13 — Optional AI Physique Analysis
15. M14 — Privacy, Resilience + Release Hardening

## Acceptance Vocabulary

| Term | Meaning |
|---|---|
| Build gate | Required checks before a milestone can be considered implementation-complete. |
| Release gate | Required checks before the private v1 build can be distributed. |
| Blocking defect | A defect that prevents sign-off because it risks data loss, privacy leakage, incorrect workout persistence, broken onboarding, broken logging, broken BYOK, or crash loops. |
| Non-blocking defect | A defect that does not threaten privacy, data integrity, core functionality, or release safety and can be deferred with explicit approval. |
| Golden fixture | A version-controlled input/output fixture used to lock expected behavior. |
| Redaction test | A test proving forbidden sensitive content is absent from logs, Crashlytics context, exports, files, or AI payloads. |
| Deterministic validation | Local app validation that does not rely on AI. |
| User-review gate | A required human confirmation step before saving AI/import-derived drafts. |

## Package-Level Definition of Done

This package is complete when every implementation workstream has:

- Unit-test targets.
- Integration-test targets.
- Manual QA scenarios.
- Acceptance gates.
- Negative/error cases.
- Privacy checks.
- Data integrity checks.
- iOS/Android parity checks.
- Regression cases for future PRD version bumps.

## Release-Level Definition of Done

v1 is release-ready only when:

- All milestone acceptance gates pass.
- All blocking defects are resolved.
- Offline-first behavior is proven for non-AI features.
- AI features fail safely when no key, no network, unsupported model, invalid JSON, large payload, or provider error occurs.
- Crashlytics redaction is verified with deliberate sensitive test payloads.
- `.aedifyplan` and PDF exports are proven free of forbidden data.
- Progress media and image import artifacts are proven local-only and deleted/retained according to rules.
- Private release distribution is constrained to the agreed maximum of 5 users.
