# M6 progress-media deletion and recovery — V1-M6-006

2026-11-06 follow-up: the Android Health activity-registration failure recorded below is fixed and the connected M6 media flow passes again on both platforms. See [M0–M6 gap closure](m0-m6-gap-closure.md). Physical-device verification is on hold by user instruction; the original ticket evidence is retained below.

Date: 2026-11-05. Status: complete; paused for user review before ticket 007.

Users can delete an original photo/video, a full check-in, or all saved progress media. Every action requires a confirmation describing the affected local data and supports cancellation. Progress storage shows active registered bytes, pending file count/bytes and an explicit cleanup retry. Individual deletion includes every descendant thumbnail/frame, including thumbnails of extracted frames. Removing the last original also removes the check-in's notes and measurement snapshot. All-media deletion covers saved check-ins; unsaved active drafts and unrelated files are protected.

## Persistence and recovery

Schema v20 is unchanged. Existing `deleted_at` fields form the durable cleanup queue:

1. One Drift transaction validates exact UUID-owned paths and registry ownership, marks affected media, clears private metadata for removed sessions, detaches/deletes measurement snapshots, updates remaining session type/pose completeness/size, and reconciles baseline/reminder intent.
2. Queries immediately hide marked data. Original/derived file removal starts only after that transaction commits.
3. Cleanup unlinks files through the sandbox wrapper, then transactionally removes their registrations and metadata. Children are purged before parents. A missing file is an idempotent success. A failed file or metadata purge retains enough tombstone ownership for a later retry.
4. Session tombstones are removed after their items and saved-session staging artifacts are gone. Startup/resume recovery runs after bootstrap readiness; cleanup failures remain available in Progress storage instead of blocking app entry.

An interrupted deletion therefore cannot turn into an untracked private file. If deletion is logically committed but some files remain, the UI reports pending cleanup. SQL/filesystem errors become fixed messages; raw notes, paths, filenames, bytes, SQL and platform errors are not logged or displayed.

Deleting the active baseline selects the oldest remaining captured check-in (with stable ID ordering for ties). Deleting the latest check-in reanchors enabled reminders to the latest remaining capture date; unrelated item deletion preserves its cadence/snooze date. Removing the final session clears reminder state so a future first save can show the cadence prompt again. Existing reminder watchers and an explicit post-delete refresh apply cancellation/rescheduling without another permission request.

## Filesystem boundary

Cleanup validates session/item UUIDs, exact folders/extensions, and matching registry ownership before a logical delete. Traversal, cross-owner registrations and linked file/parent paths fail closed. The recovery sweep visits only the progress-session and progress-draft namespaces, does not follow links, and retains unknown names, registered files, young files and active draft leases. Recognized unregistered originals, thumbnails, frames, staging files and atomic-write partials are eligible only after 24 hours, with a fresh ownership check before unlink. This conservative orphan policy protects a capture/save currently copying files. Unrelated feature folders are never swept. Empty session directories are pruned only after a confirmed session deletion.

Deletion invalidates local readers/players and evicts released memory-image previews. The notification and cleanup services remain application/data owned; widgets never call Drift, the filesystem or native APIs directly. There are no package, native configuration, schema or AI changes. M13 analysis tables do not exist yet; their linked-analysis lifecycle must integrate with this boundary when M13 is implemented. Broader export/log/AI exclusion gates remain ticket 007, and full milestone acceptance remains 008.

## Verification

- Formatting: `dart format .` checked 895 files.
- Analysis: `flutter analyze` found no issues.
- Final full suite: **1,970/1,970 passed**, zero failures/skips, using `--concurrency=2`; 23 new regressions (21 deletion/recovery/UI cases and 2 storage-route guard cases).
- Dedicated final deletion/UI checks: **21/21 passed**. These include refusing confirmation if its target changes while the dialog is open.
- An initial broad run timed out in an unchanged workout-save concurrency case during concurrent native builds. Its complete existing controller suite passed **59/59** unchanged. Full-suite reruns with lower concurrency passed; no timeout or workout production/test changes were made.
- Native smoke: iOS passed in 14 seconds and Android in 4m22s. Both exercised real playback/files/SQLite, preserved unrelated files, reported pending cleanup and completed durable restart/retry with zero Dart HTTP attempts. Light/dark confirmation and pending-cleanup captures were reviewed. Singular-count copy was subsequently corrected and verified by the final host gate.

 Dedicated tests cover cascades, completeness/totals, last-item removal, temporary files, private-metadata removal, baseline/reminder reconciliation, transaction rollback, failed unlink, failed DB purge after unlink, file-backed restart/retry, missing files, unsafe ownership, symlinks, conservative aged-orphan/partial cleanup, private log sentinels, readiness-gated startup cleanup, confirmation/cancellation, safe error/pending states and 320px/2×-text light/dark controls. The new storage deep link inherits both existing route guards.

Synthetic native integration uses real SQLite, sandbox files and video playback, including deleting a playing video. It checks cancellation, video/derived removal, a deliberately blocked file deletion, pending storage UI, database close/reopen/retry, all-media deletion, reminder metadata, preservation of an unrelated file and zero Dart HTTP attempts. Reminder scheduling is injected in this fixture; the real native notification adapter was verified in ticket 005. No private media or physical camera/library is accessed. Physical-device accessibility/gestures and OS-level storage-pressure checks remain manual.

Evidence logs: `/private/tmp/aedify-m6-006-{format,analyze,unit,focused,deletion-final,tests,tests-final,workout-recheck,ios,android}.log`. Synthetic confirmation/pending-cleanup captures: `/private/tmp/aedify-m6-006-{ios,android}-previews/`. Normal `lib/main.dart` entrypoints were restored/launched on both platforms; generated on-device screenshots were removed after preserving host copies. Android launch exposed a Health plugin `ComponentActivity` cast/registration error in unchanged `MainActivity` code. Aedify stayed running and deletion/video smoke passed, but Health integration needs separate correction/verification. Logs use `/private/tmp/aedify-m6-006-restore-{ios,android}.log`.

## Changed files

- `lib/features/progress_media/domain/progress_deletion.dart`: safe failures and aggregate cleanup status.
- `lib/features/progress_media/data/progress_media_deletion_service.dart`: durable logical delete, dependent-file graph cleanup, retry/purge, conservative orphans and baseline/reminder reconciliation.
- `lib/core/storage/local_file_store.dart`: bounded-namespace file enumeration and empty-directory pruning without link traversal.
- `lib/features/progress_media/data/progress_photo_file_service.dart`: active draft ownership leases for orphan protection.
- `lib/features/progress_media/application/progress_deletion_providers.dart`: shared serialized workflow, reader invalidation and notification refresh.
- `lib/features/progress_media/data/progress_gallery_file_service.dart`, `application/progress_gallery_providers.dart`: preview eviction on release.
- `lib/app/bootstrap/progress_cleanup_job.dart`, `lib/app/app.dart`: readiness/resume recovery.
- `lib/features/progress_media/presentation/progress_delete_controls.dart`, `progress_storage_screen.dart`, `progress_session_screen.dart`, `progress_gallery_screen.dart`: confirmed deletion, storage/retry, removed-session state and entrypoint.
- `lib/app/router/app_router.dart`, `lib/shared/constants/app_routes.dart`: guarded Progress storage route.
- `lib/shared/constants/app_strings.dart`, `app_error_strings.dart`: centralized deletion/storage copy and safe errors.
- `test/features/progress_media/progress_deletion_test.dart`, `progress_delete_controls_test.dart`: storage/recovery/privacy/UI regressions.
- `test/app/app_test.dart`, `test/app/router/app_router_test.dart`: shell-fixture isolation and storage-route guards.
- `integration_test/m6_progress_deletion_test.dart`: synthetic native playback/deletion/restart smoke.
- `docs/changelog.md`, `docs/implementation.md`, `docs/m6-reminders.md`, this file: scope, evidence and handoff.

Sources: locked PRD FR-12.8–9/FR-12.11–15 and privacy restrictions; architecture progress-media/storage boundaries; M6 ticket 006; progress-media data model §9 and feature/testing acceptance plans. No locked source plans were changed.
