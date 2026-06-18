# 17 — Cross-Cutting Dependencies and Release Sequence v1.0

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

## Dependency Chain

```text
M0 -> M1 -> M2 -> M3 -> M4 -> M5 -> M6 -> M7 -> M8 -> M9 -> M10 -> M11 -> M12 -> M13 -> M14
```

Progress Media Tracking is intentionally before AI Infrastructure. Optional AI Physique Analysis later depends on both M6 media foundations and M7 AI foundations.

## Release-Blocking Groups

- M1 storage, secure secrets, redaction, and CI gates.
- M4 validation and transactional save gates.
- M6 progress media privacy and cleanup gates.
- M7 operation registry, schema validation, repair, and AI privacy gates.
- M10–M12 export/import privacy and artifact cleanup gates.
- M13 physique safety/privacy red-team gates.
- All M14 P0 release audit and sign-off tickets.

## Recommended Build Batches

- Batch 1: M0–M1 governance/foundation.
- Batch 2: M2–M3 library/profile/BYOK.
- Batch 3: M4–M5 manual tracker/analytics.
- Batch 4: M6 progress media.
- Batch 5: M7 AI infrastructure.
- Batch 6: M8–M9 AI generation/chat/update.
- Batch 7: M10–M12 sharing/import/image import.
- Batch 8: M13 physique analysis.
- Batch 9: M14 release hardening.