# M5 analytics consistency — V1-M5-006

Implemented 2026-11-04 against the locked M5 ticket, PRD FR-7.1.1–7,
architecture §18 and analytics data-model/testing plans.

## Ownership and refresh

Completed sessions and working-set actuals remain the source of truth. PRs,
e1RM, volume and trends compute on read through Drift's joined query and
Riverpod dependencies. Committed log, membership/status, exercise metadata and
programme-week changes refresh active readers. Newly opened readers query
current data. No persisted chart/PR/e1RM cache needs invalidation; legacy stored
PR/e1RM fields are not consumed.

`AnalyticsConsistencyProviders.jobProvider`, retained by `AedifyApp`, starts
plateau reconciliation after successful startup. It retains the same evaluation
provider consumed by Stats, so detection works before Stats is opened and
screens share one writer. Initial evaluation repairs stale flags. Startup
failure/retry and app disposal release the subscription. Timer cancellation is
immediate even if a database transaction is still running; late results are
discarded.

This is an in-process local job. Existing minute ticks handle evidence-window
and dismissal expiry while the app runs; startup catches up after termination.
No operating-system background scheduler, notification or AI flow is added.

## Transactions and failures

Source corrections retain their transactional validation/conflict checks. Drift
publishes changes after commit, so readers do not see partial corrections.
Rollback leaves evidence and derived results unchanged. Session deletion removes
its contribution through the join even if child cleanup leaves orphans. Full
source removal clears obsolete plateau basis. Archiving a custom exercise
retains history while resolving its active plateau.

Plateau reconciliation reads sources and updates affected flags in a separate
atomic transaction. A failed derived write preserves the valid source edit and
rolls back flag changes. The stream emits only `PlateauFailure.unavailable`,
keeps watching and retries on the next committed source/dismissal change or
minute tick. Stats retains its existing error/retry state. Recomputations are
serial, pending triggers are coalesced and unchanged flags cause no write loop.

Warm-up-only saved history refreshes after corrections/deletions even when
strength evidence stays empty. Working/warm-up classification changes affect
all strength calculations while saved history retains both. Classification and
deletion fixtures exercise storage boundaries; no new edit/delete controls are
introduced.

Evidence stays local. The job adds no logs, crash reports, network/AI calls,
exports, preferences or secrets. Schema v19, dependencies and UI remain unchanged.

## Changed files

- `lib/app/app.dart` — retains the app job.
- `lib/app/bootstrap/analytics_consistency_providers.dart` — readiness gating
  and subscription ownership.
- `lib/features/plateau_detection/data/drift_plateau_repository.dart` —
  coalesced triggers, failure recovery and immediate cancellation.
- `test/features/analytics/application/analytics_consistency_test.dart` —
  SQLite/repository/provider fixtures and startup/subscription checks.
- This policy, `docs/analytics-ui.md`, `docs/plateau-detection.md`,
  `docs/changelog.md` and `docs/implementation.md` — current handoff/status.

## Verification

`dart format .` checked 841 files; `flutter analyze` is clean. The focused suite
passed 33 tests and the full suite passed all **1,801 tests**, zero failures or
skips. Twelve new cases cover startup without Stats,
catch-up, real weight/reps corrections, historical PR rebuilds, warm-up flips,
session completion/cancellation/deletion, orphan cleanup, custom archival,
warm-up-only history refresh, multi-row commit/rollback, sanitized failure
recovery and shared subscription disposal.

The SQLite native-download hook was slow. Host tests used the existing macOS
arm64 SQLite 3.3.3 binary, verified against the package's SHA-256
`71074bec684ce243031c34ba16314dcfc39efefa77e72cc95f19b446b224254f`.
A temporary hook override pointed to that identical artifact and was restored
automatically afterward. No manifest or lockfile change remains. Native
iOS/Android checks were not repeated for this data/application-only ticket;
the preceding M5-005 native results remain recorded separately.

Pause for review before V1-M5-007, the milestone acceptance fixture suite.
