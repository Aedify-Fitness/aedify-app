# Aedify — v1 Build Ticket Backlog Index

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

## Purpose

This package converts the roadmap, architecture plan, feature plan, data model plan, AI implementation plan, and testing gates into tracker-ready implementation tickets. It is split by milestone to avoid a bloated single file.

## Package Structure

| File | Area | Tickets |
|---|---|---:|
| `02-m0-implementation-lock-backlog-setup-tickets-v1.0.md` | M0 — Implementation Lock & Backlog Setup | 5 |
| `03-m1-app-foundation-local-data-spine-tickets-v1.0.md` | M1 — App Foundation + Local Data Spine | 11 |
| `04-m2-exercise-dataset-sync-exercise-library-tickets-v1.0.md` | M2 — Exercise Dataset Sync + Exercise Library | 10 |
| `05-m3-onboarding-profile-settings-byok-setup-tickets-v1.0.md` | M3 — Onboarding, Profile, Settings + BYOK Setup | 9 |
| `06-m4-manual-programmes-workouts-logging-tickets-v1.0.md` | M4 — Manual Programmes, Workouts + Logging | 11 |
| `07-m5-analytics-prs-plateau-base-logic-tickets-v1.0.md` | M5 — Analytics, PRs + Plateau Base Logic | 7 |
| `08-m6-progress-media-tracking-tickets-v1.0.md` | M6 — Progress Media Tracking | 8 |
| `09-m7-ai-infrastructure-tickets-v1.0.md` | M7 — AI Infrastructure | 10 |
| `10-m8-ai-workout-programme-generation-tickets-v1.0.md` | M8 — AI Workout + Programme Generation | 9 |
| `11-m9-ai-trainer-chat-ai-update-flows-tickets-v1.0.md` | M9 — AI Trainer Chat + AI Update Flows | 9 |
| `12-m10-local-sharing-pdf-export-tickets-v1.0.md` | M10 — Local Sharing + PDF Export | 8 |
| `13-m11-external-text-file-import-tickets-v1.0.md` | M11 — External Text File Import | 8 |
| `14-m12-image-screenshot-external-import-tickets-v1.0.md` | M12 — Image/Screenshot External Import | 7 |
| `15-m13-optional-ai-physique-analysis-tickets-v1.0.md` | M13 — Optional AI Physique Analysis | 7 |
| `16-m14-privacy-resilience-release-hardening-tickets-v1.0.md` | M14 — Privacy, Resilience + Release Hardening | 10 |
| `01-ticket-governance-and-template-v1.0.md` | Ticket rules and tracker template | N/A |
| `17-cross-cutting-dependencies-and-release-sequence-v1.0.md` | Dependency and release sequencing | N/A |
| `18-backlog-traceability-matrix-v1.0.md` | Ticket traceability summary | N/A |

## Backlog Summary

- Total implementation tickets: **129**
- P0 tickets: **94**
- P1 tickets: **34**
- P2 tickets: **1**
- Milestone numbering follows roadmap v1.3: Progress Media is **M6**, AI Infrastructure is **M7**.

## Global Non-Negotiables

- No scope expansion beyond re-locked PRD v1.10.
- Durable structured data goes in Drift/SQLite.
- shared_preferences is only for simple non-critical preferences.
- flutter_secure_storage is the only layer for BYOK keys/secrets.
- AI outputs are drafts until locally validated and reviewed where required.
- Crashlytics gets redacted diagnostics only.
- Progress media, image artifacts, AI internals, source files, prompts, raw responses, and candidate lists are excluded from normal exports/sharing.