# M6 progress reminders — V1-M6-005

Date: 2026-11-05. Status: complete; paused for user review before ticket 006.

The first committed progress check-in unlocks an inline cadence prompt on the saved screen and Progress gallery. Nothing requests notification permission or schedules reminders before that save. The prompt remains available until the user explicitly chooses every 2 weeks, monthly, every 3 months, or off. Dismissing the capture screen does not silently enable reminders. The persisted choice is editable through Progress → Check-in reminders and Settings → Notifications → Check-in reminders.

Drift schema v20 remains the source of truth for cadence, enabled intent, last check-in, next reminder and answered-prompt timestamp. No migration or code generation is needed. An explicit off choice records the answer and cancels this feature's notifications. Denied permission preserves the chosen cadence, shows recovery guidance and schedules nothing. Retrying or reopening checks permission without displaying another OS prompt. Only explicitly applying a non-off cadence requests permission. The global Notifications switch pauses the queue while preserving cadence; saving it on again resumes eligible reminders. Disabling the Progress feature or removing the last active session cancels its queue.

Cadence follows the latest captured check-in. Two weeks uses 14 local calendar days, preserving local wall time through daylight saving. Monthly/quarterly dates clamp to the month's last day without accumulating day drift. A later check-in resets the next date in the same media-save transaction; backdated imports do not move it backward. Overdue dates roll forward to the next future occurrence rather than replaying missed alerts. Snooze means 24 hours; Skip advances to the next regular cadence date. Supported notification actions open the app to Take progress media, Snooze 1 day, or Skip this reminder. Scheduling tokens reject stale/duplicate actions after a reset or preference change.

The app prepares twelve upcoming local notifications (about six months at the shortest cadence) and refreshes the window on startup, resume, saved settings/check-ins and notification actions. This is a bounded queue, not an unlimited background recurrence. Android restores plugin-managed pending requests after reboot/app update and uses inexact alarms without exact-alarm permission. The plugin owns a recoverable native schedule cache; it is derived from Drift and contains fixed notification copy, reserved IDs and scheduling timestamps only. No media/session IDs, paths, notes, photos, thumbnails, bodyweight or measurement data enter the notification adapter. Lock-screen content is the app name and “Time for a check-in.”

Reconciliation serializes platform work, coalesces refreshes, checks for concurrent database changes and reuses an identical pending queue. Failed OS replacement retains durable intent and reports a safe retry state; partial schedules are compensated by cancellation. Cancellation is restricted to IDs 61000–61011 and never calls cancelAll. Another feature's notifications are preserved. The app-level job waits for bootstrap and completed onboarding, then runs without a media screen being open. Widgets call application controllers only.

The existing timezone 0.11.1 transitive package is now a direct dependency because the selected flutter_local_notifications API requires TZDateTime. Package versions and resolved binaries are unchanged; offline pub resolution passed. Native setup adds the Android notification drawable/receivers/boot permission and iOS notification-center delegate. iOS initialization deliberately requests no permissions; its false authorization result is treated separately from initialization errors.

## Verification

- `dart format .`: 886 files checked.
- `flutter analyze`: no issues.
- Full `flutter test`: **1,947/1,947 passed**, zero failures/skips; 34 new cases (32 reminder cases, 2 reminder-route guard cases).
- Focused reminder tests: **32/32 passed**; broader media/settings/router/app fixture run passed 262 cases before the final two queue/concurrency regressions. The final full suite includes both.
- Separate `TZ=America/New_York` daylight-saving test: passed.
- Final native smoke: iOS passed in 16 seconds, Android in 12 seconds, with zero Dart HTTP attempts. Actual pending queues were inspected for twelve requests, fixed copy, token-only payloads, replacement/reset, cancellation and durable reopen. Prompt/scheduled light/dark captures were reviewed.

 The tests cover calendar math, daylight saving, first-save gating, explicit choices, storage rollback, permission denial/unsupported recovery, global/feature disable, missing sessions, reset/backdated import, concurrent saves/permission requests, stale actions, snooze/skip/Take, bootstrap readiness, reactive settings, private error filtering and 320px/2×-text light/dark states. Platform-channel fixtures exercise actual plugin mapping, no-prompt initialization on iOS/Android, allowlisted actions/cancellation, generic payloads, compensation and identical-queue reuse.

Native integration uses synthetic session metadata, real file-backed SQLite and the real notification plugin/OS queue. Its authorization seam simulates denial before enabling the queue. The iOS test then obtains silent provisional authorization only in the simulator and verifies the real permission probe, allowing real OS enqueue/cancel/reopen checks without a dialog. Android uses the controlled authorization seam with real native pending requests. Regular OS permission dialogs and actual lock-screen delivery are not certified by these checks. Real-device permission dialogs, delivery under OS battery/focus policies, reboot delivery and native action-button taps remain manual checks. Automated service tests exercise action semantics and cold-start processing. Progress capture/gallery and broader privacy/deletion gates retain their earlier/later ticket boundaries.

Evidence: `/private/tmp/aedify-m6-005-{format,analyze,unit,focused,tests,dst,ios,android}.log`; generated prompt/scheduled light/dark screenshots in `/private/tmp/aedify-m6-005-{ios,android}-previews/`. Normal `lib/main.dart` entrypoints were restored and launched successfully on both platforms. Only the generated on-device screenshots were removed after preserving host review copies. Restoration logs use `/private/tmp/aedify-m6-005-restore-{ios,android}.log`. Final full-suite evidence is `/private/tmp/aedify-m6-005-tests-final.log`.

## Changed files

- `lib/features/progress_media/domain/progress_reminder.dart`: cadence/window/action policies and safe state/failures.
- `lib/features/progress_media/data/progress_reminder_repository.dart`: transactional choice/CAS due-date updates, minimal reactive context.
- `lib/features/progress_media/data/progress_reminder_scheduler.dart`: selected native plugin adapter, permission checks, generic bounded queues and action parsing.
- `lib/features/progress_media/data/drift_progress_media_repository.dart`: atomic cadence reset with a later check-in.
- `lib/features/progress_media/application/progress_reminder_service.dart`, `progress_reminder_providers.dart`: serial reconciliation, lifecycle-independent actions/state and coalescing.
- `lib/app/bootstrap/progress_reminder_job.dart`, `lib/app/app.dart`: readiness, app resume, feature updates and capture-navigation bridge.
- `lib/features/progress_media/presentation/progress_reminder_screen.dart`, `progress_media_screen.dart`, `progress_gallery_screen.dart`: cadence controls and post-save/gallery entrypoints.
- `lib/features/settings/presentation/settings_screen.dart`, `lib/app/router/app_router.dart`, `lib/shared/constants/app_routes.dart`: Settings entrypoint and guarded reminder route.
- `lib/shared/constants/app_strings.dart`, `app_error_strings.dart`: centralized labels/recovery copy.
- `lib/core/db/tables/progress_media_tables.dart`: ownership comment only; schema unchanged.
- `pubspec.yaml`, `pubspec.lock`: promote the existing timezone dependency; no version changes.
- `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/drawable/ic_notification_aedify.xml`, `ios/Runner/AppDelegate.swift`: selected plugin platform setup.
- `test/features/progress_media/progress_reminder_test.dart`, `progress_reminder_scheduler_test.dart`, `integration_test/m6_progress_reminder_test.dart`: policy/storage/controller/UI/platform/native regressions.
- `test/features/progress_media/progress_photo_flow_test.dart`, `progress_gallery_test.dart`, `test/app/app_test.dart`: isolate established fixtures from the newly independent reminder workflow.
- `test/app/router/app_router_test.dart`: feature/draft guards cover the reminder deep link.
- `docs/changelog.md`, `docs/implementation.md`, `docs/m6-gallery.md`, this file: status, handoff and evidence.

Sources: locked PRD FR-12.11–16; architecture §19/§25; M6 ticket 005; progress-media feature, data-model §5 and acceptance-test plans. Platform setup and limits follow the [selected plugin's versioned documentation](https://pub.dev/packages/flutter_local_notifications/versions/22.0.1).

Silent provisional authorization is a simulator-test technique only; see [Apple notification authorization guidance](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications). Production uses the explicit regular-permission flow.

Ticket 006 handoff: deletion must update reminder intent against the remaining active sessions when removing the latest check-in. The existing watcher already observes session/deletion changes and cancels the queue when no active session remains.
