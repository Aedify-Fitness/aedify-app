# M5 analytics acceptance — V1-M5-007

Date: 2026-11-04. Status: **M5-007 complete; shipped M5 acceptance passed; user approved M5 on 2026-11-04**.

This gate verifies the shipped M5-001–006 pipeline against the locked M5 ticket,
roadmap acceptance gate, analytics test/data-model plans, PRD working-set/Epley/
plateau rules and architecture §18. No new analytics persistence is introduced.

## Deterministic fixtures

`test/app/m5/m5_analytics_acceptance_test.dart` uses isolated file-backed SQLite,
real repositories and the same Riverpod read provider as Stats. Expected values
are fixed independently of the production formulas. Clock: 2026-11-04 12:00;
exposures occur 18, 11, 4 and 1 days earlier, one in each displayed calendar week.

| Fixture | Working performances | Volume, kg × reps | Best external kg | Latest reliable e1RM, kg | Expected plateau outcome |
| --- | --- | ---: | ---: | ---: | --- |
| No history | None | Unavailable | Unavailable | Unavailable | No evaluation/flag |
| Progression | 80/85/90/95 kg × 5 | 1,750 | 95 | 110.8333… | Progressing |
| Plateau | Four sessions of 100 kg × 5 | 2,000 | 100 | 116.6666… | Open, with missed-target/high-effort evidence |
| Warm-up heavy | Same working sets plus 12 warm-ups of 500/750/1,000 kg × 20 | 2,000 | 100 | 116.6666… | Same signal as working-only fixture |
| Corrected log | Last 100 × 5 corrected to 120 × 6 | 2,220 | 120 | 144 | Existing flag resolved; progressing |
| Custom exercise | ID -9; 30/30/32.5/35 kg × 8 | 1,020 | 35 | 44.3333… | Progressing |

All nonempty fixtures mix programme, saved-workout and standalone sessions.
Programme metadata carries an AI-generated source; saved-workout metadata is
marked imported/reviewed. These simulate already-logged sources and do not
exercise future AI generation/import workflows. Weekly volumes/comparisons,
record values, confidence, canonical unit preservation and visible warm-up
history are checked together. Source snapshots, table inventories and row counts
across every table before/after repeated analytics reads prove that no source
row, extra record or hidden cache is created or changed; only the existing
plateau lifecycle is persisted.

Seven additional gate cases cover deload suppression, missing programme context,
unfinished/cancelled/deleted sessions, warm-up-only history, high-rep/unsupported
evidence, correction/deletion, cooldown across disk reopen, invalid queries and
rollback/retry after an injected flag-write failure. Existing M5-006 fixtures
cover atomic multi-row source corrections and live provider invalidation.

## Privacy gate and defect fixed

`test/app/m5/m5_diagnostic_privacy_acceptance_test.dart` captures logger, HTTP
diagnostic and Crashlytics sinks. Sentinels cover secrets, notes, body data,
exercise names, PRs, e1RM, weekly volume, plateau flags and nested future fields.
Only allowed diagnostic codes may survive. Local-personal analytics remain
ineligible for diagnostic/export channels; no export writer is enabled here.

The first run exposed a real leak in `CrashlyticsService.logSafe`: unknown
metadata keys could carry derived analytics into crash logs. The method now
applies the existing diagnostic-field allowlist before redaction, matching the
other diagnostic boundaries. This also blocks nested payloads under new keys
while preserving allowed error/version fields. The fixture failed before this
fix and passes afterward. No analytics call site sends logs or metrics.

## Native and presentation acceptance

`integration_test/m5_analytics_ui_test.dart` retains its light/dark dashboard,
charts, exercise drilldown, warm-up history and dismissal flow. A second case
mounts the actual `AedifyApp` with an isolated database, controlled offline-ready
bootstrap and small route harness. It proves detection before Stats opens,
saved imperial units, live correction/PR/e1RM/volume refresh, durable dismissal
after database/container reopen, deletion and return to empty history.

Both native cases block Dart HTTP creation and require zero attempts. Firebase
initialization/dataset download, real provider keys, physical phones and private
user data are excluded from these synthetic fixtures. Disk reopen is tested;
this ticket does not claim a new operating-system termination test.

| Check | Host | iOS simulator | Android emulator |
| --- | --- | --- | --- |
| Six numerical fixtures and integrity/privacy gates | Passed (15 new cases) | Covered through native flows below | Covered through native flows below |
| Light/dark charts, drilldown, warm-ups and dismissal | Passed | Passed | Passed |
| App job, correction, disk reopen, unit display and deletion | Passed | Passed | Passed |
| Normal app entrypoint restored/launched | N/A | Passed | Passed |

## Coverage and boundaries

- PR/e1RM formulas, eligibility, ties and baselines: existing domain and query
  tests plus numerical acceptance fixtures.
- Empty/sparse/dense charts, date/exercise filters, unit display and small-screen
  large-text light/dark behavior: `analytics_screens_test.dart` and
  `analytics_view_mapper_test.dart` plus native smoke.
- Metadata/source ownership, custom IDs, warm-ups and actual-history corrections:
  analytics repository tests, M5-006 consistency tests and this suite.
- Plateau rules, safe errors, migration v7/v18 → v19, atomic derived writes and
  dismissal restart: existing database/plateau suites plus acceptance fixtures.
- Injury notes never determine a signal. Intentional light/deload suppression
  requires explicit programme context; missing context fails closed. This gate
  does not invent an intent, injury or fatigue classifier.
- AI suggestions and plateau notifications remain in later owning milestones.
  Optional warm-up-inclusive charts, muscle-group filters, adherence summaries,
  body-measurement charts and CSV export are not certified by this ticket's
  shipped M5-001–006 acceptance. No broader planning checklist is silently marked
  complete, and the locked references are unchanged.
- Existing live Firebase/BYOK acceptance boundaries remain separate.

## Verification and reproduction

Formatting checked 843 Dart files and analysis is clean. The focused acceptance
and diagnostic/privacy run passed 70 tests, including 15 new host cases. The full
suite passed all **1,816 tests**, zero failures/skips. After strengthening the
per-table persistence assertions, the final 15-case acceptance run and analysis
also passed.

Both native cases passed on iPhone 18 Pro / iOS 27 simulator and Pixel 10 Pro /
Android API 36 emulator, with zero Dart HTTP attempts. Light/dark dashboard,
chart, drilldown and saved-history captures were reviewed on both platforms.
Synthetic preview folders are `/private/tmp/aedify-m5-007-{ios,android}-previews`.
Evidence logs are `/private/tmp/aedify-m5-007-{tests,focused,final-fixtures,analyze,ios,android}.log`.
Normal `lib/main.dart` entrypoints were restored and launched successfully on
both devices. Restoration logs are
`/private/tmp/aedify-m5-007-restore-{ios,android}.log`.

```sh
dart format .
flutter analyze
flutter test
flutter test integration_test/m5_analytics_ui_test.dart -d DEVICE_ID --no-uninstall
flutter run -t lib/main.dart -d DEVICE_ID --no-resident
```

The local SQLite hook workaround reuses already-cached macOS/iOS-simulator/
Android arm64 SQLite 3.3.3 binaries, verified against the installed package's
published SHA-256 map. A temporary `test-sqlite3` hook configuration copies these
same binaries locally instead of downloading them again. Configuration is
restored automatically; final diff checks confirm no manifest, lockfile or iOS
project configuration changes remain.

The initial iOS build found a missing `flutterfire` CLI; the user made it
available during verification. The temporary simulator-only upload guard was
removed, restoring the existing Xcode symbol-upload configuration. Device/release
upload behavior is unchanged. Existing plugin migration/deprecation notices remain.

## Changed files

- `test/app/m5/m5_analytics_acceptance_test.dart`
- `test/app/m5/m5_diagnostic_privacy_acceptance_test.dart`
- `integration_test/m5_analytics_ui_test.dart`
- `lib/core/firebase/crashlytics_service.dart`
- This evidence file, `docs/changelog.md` and `docs/implementation.md`.

User approved M5 and authorized M6 on 2026-11-04, with a review pause after every M6 ticket. The M5 verification evidence above is unchanged.
