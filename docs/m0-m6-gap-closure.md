# M0–M6 remaining-gap closure

Date: 2026-11-06. Status: all reviewed non-held gaps closed. User authorized fixing all remaining gaps while holding M2/M3 live-service verification and M6 physical-device verification. M7 remains unstarted.

Follow-up on 2026-11-06: removed the three Python helpers and newly added YAML issue templates at the user's request, including their CI step and active references. The existing workflow, PR checklist, GitHub board/labels and evidence snapshots are retained. The file inventory below reflects this cleanup. Format, remaining workflow YAML, local links, removed-file/reference checks and whitespace checks passed; app analysis/tests were not repeated for the cleanup.

To rerun the connected gap test, use `flutter test integration_test/m0_m6_gap_closure_test.dart -d DEVICE_ID --no-uninstall`. On the Android emulator, manually cancel the first system CSV picker and save the second under a unique synthetic filename. Inspect and remove that exported fixture afterward; system-picker automation and host CSV readback are no longer supplied by a repository helper. The iOS fixture cancels its picker itself. Earlier native evidence below records the completed closure run.

| Gap | Work | Verification status |
|---|---|---|
| M5 body-measurement charts | Schema-v21 numeric history, metric/imperial/percentage charts and ten-field measurement entry; onboarding completion and changed profile weight record history transactionally. | Focused checks passed; native UI/reopen passed on both platforms. |
| M5 programme adherence | On-read due-workout summaries, unique completion attribution, future/draft/deleted exclusion, explicit unscheduled counts and selected date range. | Focused and native UI checks passed. |
| M5 analytics CSV | Versioned canonical working-set/measurement/adherence DTO export, spreadsheet formula protection, explicit review and native system-document destination; no notes/media/secrets/AI internals. | Consent/DTO tests passed; native picker presentation/cancel passed on both; Android system save/readback/removal passed. |
| Android plugin compatibility | `FlutterFragmentActivity` supplies the `ComponentActivity` contract required by the installed Health plugin while retaining the existing video/notification adapters. | Native SDK-status probe passed; zero Health registration/cast errors in the synthetic app process. Connected media regression passed again on iOS and Android. |
| M0 governance | Verify/create milestone labels and a linked project board; source index, ready/done criteria, fixture policy, PR checklist and requirements traceability. | Created and verified the private linked board, M0–M14 labels, all 129 canonical tickets, six closure cards and two explicit holds. All 137 cards have milestone/workstream/change-control fields; future and held work is Todo. |
| Tracking consistency | Consolidate current status and separate completed implementation from user-held verification. | Current tracker and historical evidence reconciled; the two user-held verification scopes remain explicit. |

## Explicit holds

- M2 live Firebase first-sync verification and M3 successful real-key BYOK verification: on hold by user instruction. Do not collect keys or attempt live calls as part of this task.
- M6 physical iOS/Android camera/gallery, permission, notification delivery/reboot/focus/battery, accessibility/gestures and storage-pressure checks: on hold by user instruction. Synthetic simulator/emulator checks remain eligible.
- M7–M14 feature implementation remains outside this task. Governance may represent the already locked future backlog as not started; it does not authorize starting those features.

## Implementation boundaries

- Schema v21 adds nullable `body_fat_percent` and `neck_cm` columns for manual entries required by PRD FR-13.1. The v20 migration preserves existing measurements; earlier migration fixtures remain covered. No new package, backend, cloud sync or AI behavior. Existing Drift tables retain ownership; analytics reads do not create derived caches.
- Measurement history is distinct from immutable M6 snapshots. New Stats records do not rewrite private check-in metadata. Existing profiles without measurement history are not assigned invented historical weights/dates.
- Adherence counts published, non-deleted programmes' scheduled occurrences through today in the selected range. Skips count as uncompleted due work; duplicate sessions count once. Only a completed session with matching programme and occurrence ownership supplies completion. An explicit occurrence date takes precedence; otherwise a valid scheduled-day index is resolved from its owning week start, or the programme start plus its week offset. Invalid explicit dates or missing schedule context are reported as unscheduled. Calendar boundaries use local dates, including for UTC callers.
- CSV is a distinct, user-requested analytics export under PRD FR-7.7. It does not enable `.aedifyplan`, PDF, app-backup or media export. Review names the personal numeric data included; the OS destination controls where the user saves it. Native adapters accept bounded bytes, fixed filenames and safe status codes only. iOS temporary copies are removed on completion/cancel and recovered at next adapter initialization after interruption.

## Evidence

- Schema-v21 Drift generation completed successfully. `dart format .` checked 910 files (0 changes at the final gate); `flutter analyze` reported no issues; the final `flutter test --concurrency=2 --reporter expanded` passed **2,009/2,009 tests** in 1m56s, zero failures/skips. The initial full run had 2,008 passing cases and one old v18→v20 migration-test expectation; correcting its expected target to v21 produced passing full gates. Source-log preservation assertions remained intact.
- New connected gap journey passed on iPhone 18 Pro/iOS 27 (16s) and Pixel 10 Pro/API 36 (22s), with zero Dart HTTP attempts. Real SQLite/reopen, weight/waist/neck/body-fat writes through the ten-field form, canonical/imperial/percentage display, 50% adherence and consent cancellation were exercised. CSV sentinels excluded private notes/IDs/media/AI values.
- Both platforms presented and cancelled the real system document picker. iOS removed its temporary export directory. Android also saved to Downloads; the host read back the CSV, checked schema/rows/privacy and removed the exact synthetic output. This does not claim a readback of an iOS user-selected destination.
- Existing connected M6 media/reminder/delete/recovery acceptance passed again on iOS (43s) and Android (46s). Foundation storage/onboarding/offline-library/synthetic-BYOK acceptance passed 2/2 on each platform (11s each). These fixtures used synthetic transport, without attempting the held live checks.
- The Android Health SDK-status probe passed with zero registration/cast errors from the fixture process. This verifies plugin registration, without requesting Health data or permissions.
- Measurement/adherence light/dark and media comparison/pending-cleanup previews were reviewed on both platforms. Exact generated app captures were removed after preserving synthetic host copies. Normal `lib/main.dart` entrypoints were restored and confirmed running on both platforms; the headless emulator started for this run was then closed. The original iOS simulator remains running.
- Migration/analytics tests also passed 19/19 under `TZ=America/New_York`, including UTC/local day boundaries. The earlier focused gate passed 219/219 before the added timezone case.
- Requirement traceability covers 231 functional-requirement occurrences across 15 epics. Local governance links resolve and the existing workflow YAML parses. The private [implementation board](https://github.com/orgs/Aedify-Fitness/projects/1) is linked to the repository: **137 cards, 67 Done, 70 Todo, 0 In Progress**. Its 68 future canonical tickets and two holds remain Todo; no people were assigned or repository issues opened. [Verification snapshot](governance/board-state.json). Local link/YAML/source-inventory and whitespace checks passed.

Local evidence stays outside source: `/private/tmp/aedify-m0-m6-gaps-{generation,format,analyze,tests,tests-initial,focused-final,timezone,ios,android,m6-ios,m6-android,foundation-ios,foundation-android,governance}.log`, Android native-save status `...-android-native-status.json` and `...-{ios,android}-previews/`. Logs and captures contain only the isolated synthetic fixtures.

## Changed files

The implementation, regression coverage, native adapters and governance/evidence changes are limited to these files. Locked product/architecture/roadmap/AI source plans are unchanged.

```text
.github/PULL_REQUEST_TEMPLATE.md
.github/workflows/foundation.yml
android/app/src/main/kotlin/com/example/aedify/AnalyticsCsvExport.kt
android/app/src/main/kotlin/com/example/aedify/MainActivity.kt
docs/changelog.md
docs/governance/board-state.json
docs/governance/index.md
docs/governance/requirements-traceability.md
docs/implementation.md
docs/m0-m6-gap-closure.md
docs/m1-m4-gap-closure.md
docs/m5-acceptance.md
docs/m6-acceptance.md
docs/m6-deletion.md
docs/m6-privacy-exclusions.md
integration_test/m0_m6_gap_closure_test.dart
ios/Runner/AppDelegate.swift
lib/core/db/app_database.dart
lib/core/db/app_database.g.dart
lib/core/db/body_measurement_recorder.dart
lib/core/db/tables/body_measurements.dart
lib/features/analytics/analytics_strings.dart
lib/features/analytics/application/analytics_insights_providers.dart
lib/features/analytics/application/analytics_view_providers.dart
lib/features/analytics/data/analytics_csv_destination.dart
lib/features/analytics/data/analytics_insights_repository.dart
lib/features/analytics/domain/analytics_csv.dart
lib/features/analytics/domain/analytics_insights.dart
lib/features/analytics/domain/analytics_query_failure.dart
lib/features/analytics/presentation/analytics_screen.dart
lib/features/analytics/presentation/widgets/analytics_insights_panel.dart
lib/features/analytics/presentation/widgets/analytics_trend_chart.dart
lib/features/onboarding/data/drift_onboarding_repository.dart
lib/features/profile/data/drift_profile_repository.dart
lib/shared/constants/app_error_strings.dart
test/core/db/app_database_test.dart
test/core/db/migration_test.dart
test/features/analytics/application/analytics_insights_controller_test.dart
test/features/analytics/data/analytics_csv_destination_test.dart
test/features/analytics/data/analytics_insights_repository_test.dart
test/features/analytics/domain/analytics_csv_test.dart
test/features/analytics/presentation/analytics_insights_panel_test.dart
test/features/analytics/presentation/analytics_screens_test.dart
test/features/onboarding/data/drift_onboarding_repository_test.dart
test/features/plateau_detection/data/drift_plateau_repository_test.dart
test/features/profile/data/drift_profile_repository_test.dart
test/features/progress_media/progress_photo_flow_test.dart
```

Sources: locked PRD §5.1/FR-7.5/FR-7.7; roadmap M0/M5; M0 backlog/governance; analytics feature/data/test plans; prior M1–M4/M5/M6 evidence. Locked source plans are unchanged.
