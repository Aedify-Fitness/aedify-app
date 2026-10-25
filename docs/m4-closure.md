# M4 closure evidence

Date: 2026-10-25. Status: **M4 complete** (implementation began 2026-10-24).

## Implemented scope

- Manual workout/programme builders, saved libraries, activation, warm-up/working sets, supersets, custom exercises, session execution and snapshot history remain implemented.
- Lift Log can start a standalone session and repeat a completed snapshot. Standalone sessions remain open for additional sets/exercises until explicit finish. Existing active sessions require resume; they are never overwritten.
- Runner actual inputs support weighted reps, bodyweight reps, time/distance, optional RPE/RIR and notes. Targets remain hints. Logging and completion validate actual results. Skipped sets remain restorable and invalid legacy completions can be undone and corrected.
- Schema v18 adds prescribed duration/distance/RIR and session exercise logging type. Source edits do not alter session snapshots. Upgrade fixtures cover pre-M4 v7 and later supported schema versions.
- Completed-history corrections are explicit, locally validated and transactional. Identity, prescription, set type, attribution and completion metadata are preserved. Stale edits, cross-session writes, invalid numbers and interrupted writes fail safely.
- Basic per-exercise history reads completed local sessions, including original exercise attribution after a mid-session swap. Repeats use new identities and clear prior actuals, actual set/session notes and derived PR/e1RM results.

## Primary-action theme alignment (2026-10-25)

Add exercises and Save correction now share `AppButtonStyles.primary`, explicitly selecting DESIGN.md's blue light/dark action roles and corresponding foregrounds. Label typography comes from the theme-specific action style; the Add icon shares its foreground. Existing sizing, shape, keyboard layout and guarded callbacks remain intact.

Formatting (780 files), analysis and 10 focused UI tests passed. Native iOS acceptance passed; light/dark action previews were reviewed and the normal app entrypoint restored. The last full suite remains 1,596 passing tests, and Android native acceptance remains from the preceding redesign. No full-suite or Android native rerun for this styling-only follow-up. Evidence: `/private/tmp/aedify-action-buttons-{analyze.log,tests.log,ios.log,ios-restore.log}` and synthetic `/private/tmp/aedify-action-buttons/{empty_light,editor_light,editor_dark}.png` previews.

## Workout/history redesign (2026-10-25)

The six requested entry/history/correction views now share the approved typography and tonal surfaces. Empty sessions keep Add exercises in a safe footer; history cards prioritize actual results and quiet targets; supersets use restrained grouping. The detail page has a responsive overview with secondary Repeat action. Correction sheets retain logging-type-specific fields and scroll context/errors above persistent actions, including at 320px, 2x text and keyboard insets.

A feature-owned `history_visuals.dart` shares presentation patterns; sizing tokens remain centralized. Correction ownership, partial logged-set eligibility, hidden-value preservation and async guards remain tested. Formatting (779 files), analysis and all **1,596 tests** passed, with zero skips. Native iOS and Android offline/redesign acceptance passed; previews cover the empty session, exercise history, light/dark grouped details and weighted/timed correction sheets. Native renders were reviewed and normal `lib/main.dart` entrypoints restored.

Latest evidence: `/private/tmp/aedify-history-redesign-{full-suite.json,analyze.log,layout.log,ios.log,android.log,ios-restore.log,android-restore.log}`. Synthetic native previews live in `/private/tmp/aedify-history-redesign-ios/` and `/private/tmp/aedify-history-redesign-android/` (`empty_light.png`, `exercise_dark.png`, and `detail_`, `superset_`, `editor_`, `timed_editor_` light/dark variants). Six new responsive cases cover 320px/2x-text layouts and keyboard/error/save behavior. Five stale UI expectations were updated; existing business/privacy/storage checks remain enabled.

## Exercise-card correction flow (2026-10-25)

Completion summaries (full and finish-early) now link exercises with logged sets to the saved workout log. Partial exercises allow correction of completed actual logs only. The editor follows logging type, preserves hidden historical values and derives RIR from RPE. Saving refreshes the completion summary metrics. Exercise history now opens from the exercise card, with a non-interactive name/date heading; partial exercises contribute completed logs from finished sessions. Active sessions, pending, skipped and empty sets remain excluded from editing.

The Home shortcut approach was abandoned before any edits. Formatting (778 files), analysis and all **1,590 tests** passed, zero skips. Native completion-card → saved workout log → logging-type-specific correction → repeat acceptance passed on both iOS and Android; editor screenshots reviewed and normal `lib/main.dart` entrypoints restored.

Latest evidence: `/private/tmp/aedify-exercise-corrections-{full-suite.json,analyze.log,focused.log,ios.log,android.log,ios-restore.log,android-restore.log}` and synthetic `/private/tmp/aedify-exercise-corrections-{ios,android}-editor.png` screenshots. Full-suite tests cover normal/early summaries, partial/grouped exercises, logged versus pending/skipped sets, returned-summary refresh and reps-only/duration editor schemas with hidden-value preservation.

## RIR table removal (2026-10-25)

The runner table now displays RPE only: RIR is absent from headers, row cells and target summaries, including mixed supersets and every logging type. RIR-only targets display their equivalent RPE. Internal effort conversion and persistence remain supported. Formatting (777 files), analysis and all **1,585 tests** passed again; native checks were not repeated for this presentation-only follow-up.

Affected files: `lib/features/workout_execution/presentation/widgets/workout_runner_training_log.dart`, `test/features/workout_execution/presentation/widgets/workout_runner_actual_inputs_test.dart`, `test/features/workout_execution/presentation/widgets/workout_runner_training_log_test.dart`, `docs/changelog.md`, `docs/implementation.md` and this report.

## RPE, superset and standalone corrections (2026-10-25)

- Home's Manual log action was still opening the saved-workout builder. It now invokes standalone launch. The prior native harness began at Lift Log and did not cover that entry point; the harness now begins at the real Home screen, with a separate real-router/SQLite regression covering production route wiring.
- RPE is the single editable effort input. RIR is derived and read-only; the existing integer storage uses rounded `10 − RPE`, clamped to 0–5. RIR-only prescriptions initialize editable RPE in saved/programme/repeated sessions and added sets. Older sessions with only actual RIR also populate RPE. Clearing RPE clears derived RIR without changing targets.
- Superset type toggles update the matching linked round together, rather than moving one member into a separate type/round. Real controller/UI/SQLite coverage verifies repeated toggles retain both members and their actuals, other rounds, unrelated exercises and save/reload grouping. Session ordering is the fallback when explicit member order is absent.
- Latest acceptance: **1,585 tests passed**, zero skips; analysis and formatting (777 files) clean. Native Home-to-standalone/offline/reopen/history/correction/repeat passed on iOS and Android with RPE/derived RIR persistence checked. Both light/dark native renders were reviewed and normal entrypoints restored. OS-termination evidence below remains from the original closure.
- Logs: `/private/tmp/aedify-m4-followup-{full-suite.json,analyze.log,ios-smoke.log,android-smoke.log,ios-restore.log,android-restore.log}`. Synthetic screenshots: `/private/tmp/aedify-m4-followup-{ios,android}-{light,dark}.png`.

## Runner/history refinement (2026-10-25)

- Removed `_RunnerSetDetails`. The runner uses logging-type headers and inline grids, optional distance with duration, inline RPE/RIR, and per-set working/warm-up toggles. Horizontal scrolling preserves alignment and large-text readability, including mixed supersets.
- Exercise performance history excludes unfinished exercise occurrences and active sessions, showing only completed, non-skipped sets with actual results. The complete session detail preserves original skipped/pending/unlogged sets. Legacy distance-only logs without logging snapshots retain compatibility.
- Updated widget assertions to inspect the visible round/member order instead of old nested containers. Added all logging-type schemas, mixed-superset ownership/type toggles, optional-distance duration logging, completed-history query/UI filtering and actual-log domain tests.
- The native iOS offline/recovery/history/correction/repeat test passed again after the scrollbar fix. Final light/dark screenshots were reviewed; normal `lib/main.dart` was restored and launched. Android native smoke and OS-termination checks below remain evidence from the original closure; this UI refinement does not change schema or native dependencies.

## Automated acceptance

`dart format .` checked 779 files with no pending changes. `flutter analyze` reported no issues. The latest full `flutter test` suite passed **1,596 tests**, with no failures or skips. The original closure baseline passed 1,573 tests; the runner/history refinements add twenty-three regressions. All original native checks below also passed.

Relevant new suites:

- `test/app/m4/m4_real_storage_acceptance_test.dart`: actual Drift/repository/controller offline flow, corrections, source edits, repetition and active-session conflicts, with network creation blocked.
- `test/app/m4/m4_diagnostic_privacy_acceptance_test.dart`: synthetic secrets/log/notes/prompt/response sentinels captured at logger, HTTP-diagnostic and Crashlytics boundaries.
- `test/features/workout_execution/data/workout_session_recovery_acceptance_test.dart`: file-backed database close/reopen and failed-completion rollback/retry.
- `test/features/workout_execution/application/start_workout_session_use_case_test.dart`: saved/programme target snapshots, logging-mode precedence and mixed-exercise repeat attribution.
- `test/features/lift_log/data/workout_history_corrections_test.dart`: corrections, transaction rollback, stale/source-ownership guards and per-exercise query attribution.
- Widget regressions cover launch/retry/conflict handling, complete actual inputs, corrections/retry, standalone extension, skip restoration, invalid legacy results and small/large-text layouts in both themes.

Existing UI failures were repaired by updating stale headings, controls and schedule-count expectations, and by fixing genuine overflow/touch-target defects. No existing test was skipped or deleted to obtain a pass.

## Native checks

The native harness uses production screens/controllers/repositories with an isolated SQLite fixture. It blocks Dart HTTP creation, uses synthetic custom exercises, and requests no Health or AI access. It bypasses production bootstrap/dataset download so it can verify the already-offline M4 boundary independently.

```sh
flutter test integration_test/m4_offline_smoke_test.dart -d DEVICE_ID --no-uninstall
bash tool/verify_m4_process_recovery.sh DEVICE_ID /private/tmp/aedify-m4-recovery
```

The second command starts the seed phase, waits for an acknowledged committed session, terminates the OS process, and runs recovery in a new process against the same file. The seed test losing its connection is intentional; the recovery phase must pass. This verifies committed progress surviving termination, rather than killing a transaction in flight. Injected transaction failures are covered separately.

| Native check | iOS simulator | Android emulator |
| --- | --- | --- |
| Offline standalone logging, disk reopen/resume, completion, live history, correction and repeat | Passed | Passed |
| Deliberate OS termination after committed progress, relaunch and completion into history | Passed | Passed |
| Restore normal `lib/main.dart` entrypoint and successful debug launch | Passed | Passed |

Devices: iPhone 18 Pro / iOS 27 simulator and Pixel 10 Pro / Android API 36 emulator. Synthetic light/dark native fixtures were visually reviewed. The native test waits for the real summary, taps Done and opens the refreshed history through its visible row.

Latest refinement logs are `/private/tmp/aedify-runner-grid-full-suite.json`, `/private/tmp/aedify-runner-grid-analyze.log`, `/private/tmp/aedify-runner-grid-ios-smoke.log` and `/private/tmp/aedify-runner-grid-ios-restore.log`; synthetic final screenshots use `/private/tmp/aedify-runner-grid-ios-final-{light,dark}.png`.

Original reproduction logs remain outside versioned source in `/private/tmp/aedify-m4-ios-offline-pass.txt`, `/private/tmp/aedify-m4-android-smoke-accepted.txt`, the corresponding `aedify-m4-{ios,android}-recovery/` directories and production-start logs. No physical phone or real progress media was used.

## Build compatibility

- Added Flutter SDK `integration_test` as a development dependency.
- Updated the already-approved `health` package from 3.0.6 to 13.3.2 to remove its obsolete `device_info` Android dependency. The [publisher's package documentation](https://pub.dev/packages/health) identifies Apple Health and Health Connect support and iOS 15 as its minimum. No application Health integration or permission requests were enabled.
- CocoaPods targets now honor the application's existing iOS 15 minimum, which the installed Xcode requires.
- Android now requires API 26 / Android 8.0+ (previous Flutter default: API 24). This is required by `health` 13.3.2. Enabled notification Java desugaring with `desugar_jdk_libs` 2.1.4 and multidex, and retained Flutter's generated Kotlin/Gradle compatibility flags. Generated native build reports are ignored.

## Handoff

M4 is closed. M5 remains planned and has not been implemented. Workout and exercise history views refresh when a completed session is committed.

Restart an already-running application after this change so Drift opens with schema v18. M5 owns charts, PR/e1RM computation and plateau detection. This work does not enable AI, sharing, Health sync or release-hardening features from later milestones. When a mixed historical row lacks the original exercise-name snapshot, history uses its exercise ID instead of assigning the replacement's name.


## Changed files

```text
.gitignore
android/app/build.gradle.kts
android/gradle.properties
docs/changelog.md
docs/implementation.md
docs/m4-closure.md
integration_test/m4_offline_smoke_test.dart
integration_test/m4_process_recovery_test.dart
ios/Podfile
ios/Podfile.lock
lib/app/router/app_router.dart
lib/core/db/app_database.dart
lib/core/db/app_database.g.dart
lib/core/db/tables/set_logs.dart
lib/core/db/tables/workout_session_exercises.dart
lib/features/exercise_library/presentation/exercise_detail_screen.dart
lib/features/lift_log/application/workout_history_controller.dart
lib/features/home/presentation/home_screen.dart
lib/features/lift_log/application/workout_history_providers.dart
lib/features/lift_log/data/drift_workout_history_repository.dart
lib/features/lift_log/data/workout_history_repository.dart
lib/features/lift_log/domain/exercise_history_session.dart
lib/features/lift_log/domain/workout_history_exercise_item.dart
lib/features/lift_log/domain/workout_history_set_correction.dart
lib/features/lift_log/domain/workout_history_set_item.dart
lib/features/lift_log/presentation/lift_log_screen.dart
lib/features/lift_log/presentation/widgets/exercise_history_section.dart
lib/features/lift_log/presentation/widgets/history_visuals.dart
lib/features/lift_log/presentation/widgets/workout_history_correction_sheet.dart
lib/features/lift_log/presentation/widgets/workout_history_exercise_card.dart
lib/features/lift_log/presentation/widgets/workout_history_set_row.dart
lib/features/lift_log/presentation/widgets/workout_history_superset_group_card.dart
lib/features/lift_log/presentation/workout_history_detail_screen.dart
lib/features/lift_log/workout_history_strings.dart
lib/features/programmes/presentation/widgets/programme_builder_workouts.dart
lib/features/workout_execution/application/start_workout_session_use_case.dart
lib/features/workout_execution/application/workout_launch_providers.dart
lib/features/workout_execution/application/workout_runner_controller.dart
lib/features/workout_execution/application/workout_runner_mapper.dart
lib/features/workout_execution/data/drift_workout_session_repository.dart
lib/features/workout_execution/domain/set_log_draft.dart
lib/features/workout_execution/domain/workout_launch_strings.dart
lib/features/workout_execution/domain/workout_runner_block.dart
lib/features/workout_execution/domain/workout_runner_exercise_item.dart
lib/features/workout_execution/domain/workout_runner_set_item.dart
lib/features/workout_execution/domain/workout_runner_set_policy.dart
lib/features/workout_execution/domain/workout_session_exercise_draft.dart
lib/features/workout_execution/presentation/widgets/workout_runner_active_view.dart
lib/features/workout_execution/presentation/widgets/workout_runner_set_row.dart
lib/features/workout_execution/presentation/widgets/workout_runner_training_log.dart
lib/features/workout_execution/presentation/workout_launch_screen.dart
lib/features/workout_execution/presentation/workout_complete_screen.dart
lib/features/workout_execution/presentation/finish_early_session_complete_screen.dart
lib/features/workout_execution/presentation/workout_runner_screen.dart
lib/features/workout_execution/presentation/workout_runner_strings.dart
lib/shared/constants/app_error_strings.dart
lib/shared/constants/app_routes.dart
lib/shared/constants/app_strings.dart
lib/shared/theme/app_spacing.dart
lib/shared/theme/app_button_styles.dart
lib/shared/domain/set_effort.dart
pubspec.lock
pubspec.yaml
test/app/m4/fake_m4_dependencies.dart
test/app/router/app_router_test.dart
test/app/m4/m4_diagnostic_privacy_acceptance_test.dart
test/app/m4/m4_real_storage_acceptance_test.dart
test/core/db/app_database_test.dart
test/core/db/migration_test.dart
test/features/exercise_library/presentation/exercise_detail_screen_test.dart
test/features/lift_log/application/workout_history_controller_test.dart
test/features/lift_log/application/workout_history_detail_controller_test.dart
test/features/lift_log/data/workout_history_corrections_test.dart
test/features/lift_log/domain/workout_history_set_item_test.dart
test/features/lift_log/presentation/exercise_history_section_test.dart
test/features/lift_log/presentation/completed_exercise_correction_navigation_test.dart
test/features/lift_log/presentation/history_correction_flow_test.dart
test/features/lift_log/presentation/widgets/workout_history_superset_group_card_test.dart
test/features/lift_log/presentation/widgets/workout_history_set_row_test.dart
test/features/lift_log/presentation/widgets/workout_history_exercise_card_test.dart
test/features/lift_log/presentation/lift_log_screen_test.dart
test/features/lift_log/presentation/workout_history_detail_screen_test.dart
test/features/programmes/presentation/programme_builder_screen_test.dart
test/features/workout_execution/application/start_workout_session_use_case_test.dart
test/features/workout_execution/application/workout_runner_controller_test.dart
test/features/workout_execution/data/workout_session_recovery_acceptance_test.dart
test/features/workout_execution/domain/workout_runner_set_policy_test.dart
test/features/workout_execution/presentation/widgets/workout_runner_actual_inputs_test.dart
test/features/workout_execution/presentation/widgets/workout_runner_training_log_test.dart
test/features/workout_execution/presentation/widgets/workout_runner_header_timer_test.dart
test/features/workout_execution/presentation/workout_launch_screen_test.dart
test/features/workout_execution/presentation/workout_effort_superset_flow_test.dart
test/features/workout_execution/presentation/workout_runner_screen_test.dart
tool/verify_m4_process_recovery.sh
test/shared/domain/set_effort_test.dart
```
