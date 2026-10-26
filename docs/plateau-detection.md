# M5 plateau base logic — V1-M5-004

Implemented 2026-10-26 against locked PRD FR-7.1.1–7 and the analytics/data-model
plans. Detection is deterministic, offline and independent of AI.

## Detection policy

- Consider completed, non-skipped working sets from finished sessions within
  the inclusive 28-day window ending at the explicitly injected clock. Future
  performances are excluded. Count distinct sessions, not sets or exercise rows.
- Each exposure uses its highest standard-confidence Epley estimate. At least
  four sessions with reliable estimates are required. Evaluate the latest three
  exposures in performance order; a high-rep-only exposure is retained and causes
  insufficient history rather than being skipped to manufacture a stall.
- Compute ordinary least-squares slope over equally spaced session indices
  0, 1, 2, equivalent to `(last e1RM - first e1RM) / 2` kg per session. Positive
  slope is progressing; zero/negative slope qualifies as a plateau. No epsilon
  or minimum missed-target count changes this locked trigger.
- A deload in the latest three exposures suppresses detection. Programme-week
  context comes from ownership-checked session → workout → week joins. Missing
  or unknown programme/week/source context fails closed. An older deload outside
  the rolling three exposures does not suppress the current trend.
- Archived/substituted exercises are inactive. Unknown modes/modalities and
  reps-only/timed/cardio evidence are unsupported. Bodyweight-only or other
  evidence lacking reliable load estimates cannot satisfy the history gate.

Outcome codes distinguish plateau, progressing, insufficient history, deload,
unknown context, inactive, unsupported and dismissed states. The DTO contains
only exercise identity, session counts, three summarized exposures, slope and
reason codes. It carries no names, source set/session IDs, notes, injury data,
body metrics, raw logs or database rows.

Reason codes are `nonIncreasingE1rm`, `missedTargets` and `highEffort`. Exact or
minimum rep targets and positive prescribed load can provide missed-target
evidence when valid actuals fall short. A maximum-only rep target is not a
required minimum. A set that falls short of both targets counts as one missed set.
RPE 9–10, or RIR-only evidence converted by the existing effort policy, supplies
high-effort evidence. These are observations, not fatigue/injury diagnoses or
AI coaching advice. Prescription misses are not required for the plateau rule.

## Durable lifecycle and privacy

Schema v19 adds `plateau_flags`, one `e1rm_stall` record per exercise, with
open/dismissed/resolved lifecycle, detection dates, dismissal date and sanitized
derived basis JSON. Repeated equivalent recomputes do not rewrite or duplicate
flags. Sources remain unchanged. No cache becomes primary truth.

Recompute reads current sources and reconciles all flags in one Drift
transaction. Corrections, missing/deleted evidence, expiry, deload changes and
inactive metadata resolve obsolete flags. When no recent source remains, stale
basis metrics are cleared. A flag's dismissal date is retained across resolution
so a returning signal cannot bypass its cooldown.

Dismissal is transactional and idempotent. Dismissed signals cannot reopen
before `dismissedAt + 14 days`; they may reopen exactly at that boundary if
evidence still qualifies. The cooldown survives database close/reopen. Missing
or resolved flags return a safe missing code. SQL failures expose only safe
failure codes; raw SQL parameters and errors never leave the repository.

No secrets, full notes, prompts, AI responses or media enter this table or DTO.
The module emits no logs, crash reports, exports, AI calls or network traffic.

## Application APIs and handoff

`PlateauDetectionService.evaluate` is pure Dart. `PlateauRepository.recompute`
reconciles durable state; `watchEvaluations` watches source tables, programme
weeks and dismissal state. An active subscription also refreshes once a minute
to handle time-window and cooldown expiry. Writes caused by reconciliation are
idempotent so observing flags does not create an update loop.

`PlateauProviders` supplies repository/clock injection, async evaluation states
and a dismissal controller with safe failures and retry. UI does not access
Drift directly. M5-005 consumes these APIs for dashboard indicators and review;
M5-006 owns app-wide recomputation integration. Notification and AI suggestion
flows remain in their owning milestones. Device upgrade/UI acceptance belongs
to the later M5 acceptance work; no mobile screens were changed here.

## Changed files and verification

- `lib/core/db/tables/plateau_flags.dart`
- `lib/core/db/app_database.dart`, generated `lib/core/db/app_database.g.dart`
- `lib/features/analytics/domain/analytics_set_log.dart`
- `lib/features/analytics/data/drift_analytics_repository.dart`
- `lib/features/plateau_detection/domain/plateau_evaluation.dart`
- `lib/features/plateau_detection/domain/plateau_detection_service.dart`
- `lib/features/plateau_detection/data/plateau_repository.dart`
- `lib/features/plateau_detection/data/drift_plateau_repository.dart`
- `lib/features/plateau_detection/application/plateau_providers.dart`
- `test/features/plateau_detection/domain/plateau_detection_service_test.dart`
- `test/features/plateau_detection/data/drift_plateau_repository_test.dart`
- `test/core/db/app_database_test.dart`, `test/core/db/migration_test.dart`
- This policy, `docs/changelog.md` and `docs/implementation.md`.

Approved code generation completed and `dart format .` checked 826 files.
`flutter analyze` is clean; the full suite passed all 1,773 tests with zero
failures/skips, including 35 new plateau regressions. Fixtures cover migration from
v18 and earlier versions, source preservation, cooldown after reopen, atomic
rollback on injected SQL failure, sanitization, correction/deletion and live
updates. Native iOS/Android UI checks were not repeated for this service-only
ticket. No dependencies changed.

Pause for user review before V1-M5-005.
