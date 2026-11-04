# M5 PR detection — V1-M5-002

Implemented 2026-10-26 in V1-M5-002, with e1RM records added in V1-M5-003.
This is the implementation policy for the PR service within the locked
roadmap's weight, rep, e1RM and volume scope. Analytics presentation belongs
to later M5 tickets.

## Record comparisons

| Type | Eligible performance | Value | Comparison scope |
| --- | --- | --- | --- |
| `maxWeight` | Strength, weighted-reps mode, positive reps and positive finite load | kg | Exercise |
| `maxRepsAtWeight` | Strength, weighted-reps mode, positive reps and finite non-negative load | reps | Exercise + exact canonical kg load |
| `maxReps` | Strength, reps-only mode, positive reps | reps | Exercise |
| `volume` | Eligible weighted set with positive finite kg × reps | kg × reps | Exercise, single-set volume |
| `estimatedOneRepMax` | Eligible standard-confidence Epley estimate from 1–10 reps | Estimated kg | Exercise |

The first eligible performance for each comparison establishes a baseline
(`isBaseline = true`, `previousValue = null`). Strict improvements add record
achievements with the previous value. Ties preserve the earliest achievement.
Rep comparisons at a newly encountered load establish their own baseline even
if the exercise already has records at other loads.

Zero external load permits rep records at zero kg and creates no weight/volume
record. Reps-only exercises do not infer bodyweight or external load; residual
hidden weight fields are ignored. Timed/cardio exercises, unknown/missing modes
or modalities, invalid actuals and overflowing volume do not produce the
corresponding strength records. No endurance/speed ranking policy is introduced.

Completed actual performance is used even when it falls short of a prescribed
target. Pending, skipped and failed/incomplete sets do not qualify. Targets,
stored `is_pr` flags and stored e1RM estimates never determine these records.
Values remain canonical kg without display-unit conversion or rounding.

e1RM records use the shared estimator and exclude low-confidence high-rep
estimates and bodyweight-only equipment lacking a total-load model. See
[e1RM policy](e1rm-estimation.md) for formula, eligibility and confidence rules.

## Source and lifecycle

`PersonalRecordService.detect` consumes the completed working-set evidence from
V1-M5-001. That repository excludes warm-ups, active/cancelled/deleted sessions
and orphaned source records. Canonical and custom exercise IDs remain distinct;
programme, saved-workout and standalone sessions use the same comparisons.

Detection copies and orders evidence by performed time, session ID, membership
ID, set index and set ID. Input order and later correction timestamps cannot
change the chronology. The result exposes immutable current records and a
chronological achievement history, with source exercise/set/session IDs.

`PersonalRecordProviders.recordsProvider(exerciseId)` derives async state from
the existing local query stream; `null` selects all exercises. It always reads
the complete relevant exercise history. Apply display date/session filters
after detection to avoid creating false baselines. Source corrections,
deletions and eligibility changes rebuild both current records and history.
Safe query failures propagate unchanged; invalidate the matching
`AnalyticsProviders.completedWorkingSetsProvider` to retry.

This follows the architecture's compute-on-read policy and the data model's
dynamic PR option. There are no cache tables, schema/dependency changes or
derived writes to source logs. Results contain no notes or body measurements;
the service emits no logs, network requests, exports or crash reports.

## V1-M5-002 files and verification

- `lib/features/analytics/domain/personal_record.dart`
- `lib/features/analytics/domain/personal_record_service.dart`
- `lib/features/analytics/application/personal_record_providers.dart`
- `test/features/analytics/domain/personal_record_service_test.dart`
- `test/features/analytics/data/drift_analytics_repository_test.dart`
- This policy, `docs/changelog.md` and `docs/implementation.md`.

`dart format .` checked 813 files; `flutter analyze` passed. All 49 analytics
tests pass, including 31 new unit/SQLite/Riverpod cases covering comparisons,
baselines/ties, invalid values, exact kg loads, source filtering, actual history
correction, hard/soft deletion, safe failures and retry. The full suite passed
all 1,708 tests with zero failures/skips. Native UI checks are not applicable to this service-only ticket;
no screens or completion-summary widgets were changed.

V1-M5-003 adds the e1RM service, confidence-aware record eligibility and shared
chronology helper. Its current file inventory and verification are recorded in
[e1RM estimation](e1rm-estimation.md). V1-M5-004 must wait for user review and
explicit go-ahead.
