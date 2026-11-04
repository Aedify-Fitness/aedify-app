# M5 e1RM estimation — V1-M5-003

Implemented 2026-10-26. The estimator follows locked PRD FR-6.4 and the M5
analytics architecture, consuming V1-M5-001's completed-working-set evidence.

## Formula and eligibility

Epley: `estimated kg = actual kg × (1 + actual reps / 30)`.

The formula is used exactly, including for one rep. It has no RPE/RIR
adjustment, display-unit conversion, load rounding or prescription fallback.
It is separate from the existing optional RPE-based workout weight suggestion.

Eligible evidence requires strength modality, weighted-reps logging mode,
positive finite external load and positive actual reps. Missing/unknown mode or
modality, reps-only, timed/cardio, bodyweight-only equipment without a total-load
model, zero/negative/non-finite load and overflowing estimates are excluded.
The repository excludes warm-ups, skipped/incomplete sets, unfinished/cancelled/
deleted sessions and orphaned logs before estimation. Custom and canonical
exercises and all session sources use the same rules.

| Actual reps | Confidence | Display estimate | e1RM PR / anchor candidate |
| --- | --- | --- | --- |
| 1–10 | `standard` | Available, always an estimate | Eligible |
| Above 10 | `low` | Available with low-confidence metadata | Excluded |
| Missing/zero/negative | None | No estimate | Excluded |

The immutable summary exposes chronological per-set estimates,
`anchorCandidates` (standard-confidence estimates) and `hasInsufficientData`
(no eligible estimates). A high-rep-only history has low-confidence estimates
and an empty candidate list. Future anchor consumers must still enforce recency,
exercise/load-model compatibility and operation-specific privacy filtering.
No AI payloads, anchor persistence or provider calls are added by this ticket.

## Records, source changes and storage

The existing PR service now includes maximum standard-confidence Epley kg as
`estimatedOneRepMax`. It retains its baseline, strict-improvement and earliest-
tie policies. High-rep estimates cannot create e1RM PRs. The PR and estimate
services share a stable performance ordering helper.

`EstimatedOneRepMaxProviders.estimatesProvider(exerciseId)` exposes loading,
safe error and estimate/insufficient-data states. `null` selects all exercises.
Corrections, deletions and source eligibility changes refresh both estimates
and records through the existing analytics query stream. Retry by invalidating
the matching completed-working-set query provider.

The architecture's compute-on-read preference remains in force: no cache,
schema change or derived writes are introduced. The existing
`set_logs.estimated_1rm_kg` column is not read as truth or populated as a cache.
This avoids stale estimates after historical edits and does not change source
logs or the canonical unit boundary. The service emits no logs, exports,
Crashlytics events, files or network requests; DTOs exclude notes and body data.

## Changed files and verification

- `lib/features/analytics/domain/estimated_one_rep_max.dart`
- `lib/features/analytics/domain/estimated_one_rep_max_service.dart`
- `lib/features/analytics/domain/analytics_set_log_order.dart`
- `lib/features/analytics/application/estimated_one_rep_max_providers.dart`
- `lib/features/analytics/domain/personal_record.dart`
- `lib/features/analytics/domain/personal_record_service.dart`
- `test/features/analytics/domain/estimated_one_rep_max_service_test.dart`
- `test/features/analytics/domain/personal_record_service_test.dart`
- `test/features/analytics/data/drift_analytics_repository_test.dart`
- This policy, `docs/pr-detection.md`, `docs/changelog.md` and
  `docs/implementation.md`.

Formatting checked 818 files. All 79 analytics tests pass, including 30 new cases
for formula/rep boundaries, invalid values/overflow, bodyweight exclusions,
confidence/anchors, e1RM records, read-only source handling, actual history
corrections, source deletions, metadata changes, safe errors and retry.
`flutter analyze` is clean; the full suite passed all 1,738 tests with zero
failures/skips. No UI changed, so
native UI checks were not repeated. No dependencies or code generation changed.

Pause for user review before V1-M5-004 (plateau detection base logic).
