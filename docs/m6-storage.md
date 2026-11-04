# M6 storage foundation — V1-M6-001

Date: 2026-11-04. Status: complete; awaiting user review.
M5 was approved by the user on this date. Pause after every M6 ticket;
V1-M6-002 is not started.

## Implemented boundary

Schema v20 adds `progress_media_sessions`, `progress_media_items`,
`progress_measurement_snapshots` and `progress_media_reminder_settings`.
The detailed data-model plan §4 represents thumbnails and future video frames
as typed media items with parent references. This implements thumbnail metadata
without a redundant thumbnail table. Measurement snapshots copy canonical values
into independent records; later profile/history edits cannot change them.

`DriftProgressMediaRepository` saves validated session metadata, snapshots,
original/derived item links, M1 local-file registrations and initial reminder
state in one SQLite transaction. Raw media bytes remain files. The first active
saved session becomes the baseline; an index enforces one active baseline.
Baseline changes are transactional. Four original photo poses mark a complete
set; partial, video and mixed sessions are supported.

Reads provide timeline ordering by capture date descending with stable ID ties,
baseline/latest, detail, same-pose photo pairs and registered storage totals.
Detail reads retain metadata when a file is missing or its size changed and
report `isFileAvailable = false`. Totals describe registered active bytes, not a
live filesystem scan. Notes may be updated/cleared. Soft-deleted records are
excluded from reads; deletion operations and cleanup remain ticket 006.
Dates returned by this boundary use UTC; presentation can format them locally.

Riverpod exposes injectable database/file-store/clock dependencies and an async
timeline with loading, empty, data and fixed-code error states. Stream errors
are sanitized and cancellation propagates directly to Drift.

## File ownership and failure policy

Save input refers to files already staged by a local capture/import service.
Session and item IDs and filenames use canonical lowercase UUIDs under
`media/progress/sessions/{session}/originals|thumbnails|frames/`. Paths must match
the owning session/item exactly. Structural validation checks file relationships,
sources, poses, positive duration/dimensions and finite positive measurements.
The file-store wrapper checks actual file presence/size and rejects symlinks.
Existing file registrations cannot be reassigned to new owners.

No file copy, media decoding or thumbnail/frame generation occurs here.
A successful save transfers metadata ownership to progress-media items.
A failed save rolls back all database registrations and leaves staged files
owned by the caller for retry/cancel. Capture/import tickets must clean cancelled
staging files and compensate failed file preparation; ticket 006 owns durable
deletion, orphan cleanup and startup recovery.

The repository has no HTTP, AI, export or diagnostic dependency. Domain values
have no serialization API and are private local UI data, not future AI DTOs.
SQL/filesystem exceptions are replaced with fixed failure codes. File-store
directory events omit paths entirely; an injected logger enables a regression
test of the real emitted events. Thumbnail pointers are exposed only when linked
to an active thumbnail item in the same session.

## Reminder and milestone limits

There is no reminder record/prompt eligibility before a successful save. Save
creates disabled state, records the latest captured session date without
regressing for old imports, and leaves scheduling/prompt timestamps unset.
This ticket does not prompt, select cadence, request permissions or schedule
notifications; cadence workflows and rescheduling are ticket 005.

Tickets 002–008 still own photo/video capture/import, codec and configurable
video size/duration checks, generated thumbnails, gallery/comparison UI,
reminders, deletion/cleanup, full privacy exclusions and native acceptance.
No screen, dependency, permission or platform configuration changes are included.
M6 acceptance is not complete. AI physique analysis remains M13.

## Verification

Drift code generation succeeded. `dart format .` checked 851 Dart files;
`flutter analyze` reported no issues. The full `flutter test` suite passed all
**1,849 tests**, zero failures/skips, including 33 new cases: 28 progress-media
repository/provider cases, four file-store cases and one v19 migration case.
Existing migration/plateau fixtures were updated to target v20 and remain green.
`git diff --check` passed. Test and analysis logs are available locally at
`/private/tmp/aedify-m6-001-tests.log` and
`/private/tmp/aedify-m6-001-analyze.log`.

Fixtures cover structural/path validation,
ownership conflicts, partial/complete/mixed sessions, derived-file links,
foreign keys, concurrent saves, immutable snapshots, baseline uniqueness and
rollback, late-write rollback/retry, missing files, safe failures, stream
updates/cancellation, provider states and disk reopen. File-store fixtures check
path traversal, symlinks and diagnostic sentinels. Migration fixtures check
fresh creation and v7/v14–v19 upgrades, including source preservation and no-op
reopen. Native media smoke is deferred to the owning capture/acceptance tickets;
this is a data/application-only ticket.

Reproduction:

```sh
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

The installed generator accepts the project command but reports that
`--delete-conflicting-outputs` is obsolete and ignored. Generation succeeds.

## Changed files

- `lib/core/db/tables/progress_media_tables.dart`
- `lib/core/db/app_database.dart` and generated `app_database.g.dart`
- `lib/core/storage/local_file_store.dart`
- `lib/features/progress_media/domain/progress_media.dart`
- `lib/features/progress_media/data/progress_media_repository.dart`
- `lib/features/progress_media/data/drift_progress_media_repository.dart`
- `lib/features/progress_media/data/progress_media_storage_policy.dart`
- `lib/features/progress_media/application/progress_media_providers.dart`
- `lib/shared/constants/app_error_strings.dart`
- `test/core/db/app_database_test.dart`
- `test/core/db/migration_test.dart`
- `test/core/storage/local_file_store_test.dart`
- `test/features/plateau_detection/data/drift_plateau_repository_test.dart`
- `test/features/progress_media/data/drift_progress_media_repository_test.dart`
- `test/features/progress_media/application/progress_media_providers_test.dart`
- This evidence file, `docs/m5-acceptance.md`, `docs/changelog.md` and
  `docs/implementation.md`.
