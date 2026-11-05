# M6 photo capture/import — V1-M6-002

Date: 2026-11-05. Status: complete; awaiting user review.
Ticket 001 was approved in conversation. Pause after this ticket; video capture
and import (V1-M6-003) has not started.

## Shipped behavior

The existing Progress route now opens a photo review flow. Users choose camera
or photo library for each explicitly labelled front/back/left/right view. They
can replace/remove photos, cancel a picker without changing the draft, add notes
and optional bodyweight, and explicitly save a partial or four-pose set. The
screen uses DESIGN.md tokens, named SVGs and existing action styles. It adapts to
small screens/large text, preserves inputs after errors, reveals failures after
Save and confirms that the session was saved locally. Back navigation asks
before discarding unsaved content and waits for cleanup.

The controller reads the saved unit preference before allowing editing, converts
bodyweight to canonical kilograms and uses ticket 001's repository. No schema,
new preference persistence, AI/provider, export or notification workflow is added.
Schema v20 remains unchanged. Thumbnail records use the existing parent-linked
media-item graph and M1 file registry.

## Ownership and privacy

- Platform selections are read only through an injectable picker adapter. Full
  photo metadata is not requested. Only plugin-created copies inside the app's
  temporary directory may be released; source library files are never deleted.
- Unsaved originals/previews live under UUID-owned
  `temp/progress_photo_drafts/{session}/`. Before Save, no session, file registry
  entry or durable progress-media file is created. Replaced/removed/cancelled
  drafts are cleaned locally; startup removes abandoned photo drafts.
- Flutter's local image descriptor/codec validates supported JPEG/PNG/WebP/HEIC
  data and generates an aspect-preserving PNG preview with a 512-pixel longest
  edge. Resource guards allow at most 20 MiB encoded and 64 million pixels;
  animated inputs are rejected. HEIC also requires platform decoder support.
  These are local resource limits, not an OCR or image-enhancement pipeline.
- Originals retain the selected bytes. Preview encoding omits source metadata.
  Thumbnail storage failure retains the valid original and allows a fallback
  save. Permission, invalid file, size, storage and cleanup failures use fixed
  safe codes/messages without original platform exceptions or paths.
- Save copies the reviewed files to their final UUID paths, then uses the
  existing atomic metadata/registration transaction. Failed saves compensate
  those copies and retain the draft for retry. Cleanup ownership is retained
  when deletion fails. After commit, staging cleanup failure cannot turn a
  successful save into a retry that duplicates the session; startup retries
  temporary cleanup. Crash recovery for unregistered durable files and all
  saved-media deletion remain ticket 006.
- Android interrupted-picker results are retrieved once at app entry. A
  recovered image is never saved automatically: the user assigns both its pose
  and original source in the review flow. Temporary drafts do not survive as
  durable user records. OS-process termination itself is not certified by the
  deterministic recovery fixture.

Reminder state remains disabled with no scheduled notification. Ticket 005 owns
cadence prompting/scheduling after the first saved session. Timeline/gallery and
comparison UI remain ticket 004; current confirmation is the ticket 002 save
surface. Full export/diagnostic exclusions and milestone acceptance remain
007/008. Optional AI analysis remains M13.

## Package and platform decision

Added and pinned `image_picker: 1.2.3`, a Flutter-maintained camera/library
adapter, with its resolved transitive dependencies and iOS CocoaPods lock.
This version was available in the local cache and is validated by this ticket's
host/native runs; it is not represented as the latest published version.
The existing Riverpod/Drift/file-store stack is retained. No image processing
package is added.

The [publisher documentation](https://pub.dev/packages/image_picker/versions/1.2.3)
requires iOS camera/photo-library usage descriptions and Android lost-result
handling. These are implemented. Android uses platform picker/intents without
adding broad media-storage or camera permissions to the manifest. Microphone
access/video configuration is deferred to ticket 003. iOS 15+ and Android API
26+ requirements are unchanged. [Flutter image-codec documentation](https://api.flutter.dev/flutter/dart-ui/instantiateImageCodec.html)
describes the local decoding boundary and platform-dependent formats.

## Verification and exact limits

Final formatting checked 859 Dart files; analysis is clean and all **1,871 host tests passed**, zero failures/skips (22 new regression cases). The focused storage/startup/photo run passed 76 cases. The final save-error visibility refinement passed all 20 photo-flow cases, including 320px/2x-text light/dark error/retry states. Final synthetic native smoke passed on iOS (12 seconds) and Android (26 seconds), with zero Dart HTTP attempts. The normal `lib/main.dart` entrypoint was restored and launched on both simulators. One Android rerun stalled before test execution in the emulator app-stop operation; a cold boot without wiping userdata cleared it and the rerun passed. No SQLite-hook, SDK or platform build workaround remains in the project.

New host cases cover picker source/metadata flags, safe permission/unavailable
errors, temporary-only preparation, actual local decoding/thumbnails, complete
and partial saves, canonical unit conversion, replace/remove/cancel, invalid and
oversized input, invalid bodyweight, late SQL rollback/compensation/retry, low
storage, thumbnail fallback, recovery review, duplicate actions, disposal during
selection, cleanup retry, startup cleanup, traversal/symlink rejection, responsive
form/source-sheet/keyboard behavior and discard confirmation.

`integration_test/m6_progress_photo_test.dart` mounts the real screen/controller,
picker adapter, local codec, file service and file-backed SQLite on iOS/Android.
A synthetic ImagePicker selection seam returns app-temporary PNGs instead of
opening camera/library UI. It verifies four poses, cancellation/replacement,
notes, imperial bodyweight, explicit save, linked files, disk reopen and zero
Dart HTTP attempts. Native screenshots cover empty/review/success in light/dark.
These smoke tests do not certify physical camera hardware, OS picker gestures,
real permission dialogs, a limited-access photo library or real-device HEIC.
Those remain hands-on checks within M6's capture/acceptance work; private user
photos and the connected physical phone were not accessed.

Reproduction:

```sh
flutter pub get
dart format .
flutter analyze
flutter test
flutter test integration_test/m6_progress_photo_test.dart -d <ios-simulator-id> --no-uninstall
flutter test integration_test/m6_progress_photo_test.dart -d emulator-5554 --no-uninstall
```

No Drift code generation is needed because schema v20 is unchanged. Existing
Swift Package Manager/Kotlin Gradle migration notices are separate dependency
maintenance and do not fail these builds.

Local evidence: `/private/tmp/aedify-m6-002-{analyze,tests,focused,final-focused,ios,android}.log`.
Synthetic captures: `/private/tmp/aedify-m6-002-{ios,android}-previews/`.
Normal app restoration logs: `/private/tmp/aedify-m6-002-restore-{ios,android}.log`. Final light/dark captures were visually reviewed on both platforms, and generated on-device screenshot copies were removed after collection. `git diff --check` passed. A final conventions pass reused existing Front/Back/Optional strings without changing displayed text.

## Changed files

- `pubspec.yaml`, `pubspec.lock`, `ios/Podfile.lock`, `ios/Runner/Info.plist`
- `lib/app/app.dart`
- `lib/app/bootstrap/controllers/bootstrap_controller.dart`
- `lib/core/storage/local_file_store.dart`
- `lib/features/progress_media/domain/progress_photo_draft.dart`
- `lib/features/progress_media/data/progress_photo_picker.dart`
- `lib/features/progress_media/data/progress_photo_file_service.dart`
- `lib/features/progress_media/application/progress_photo_controller.dart`
- `lib/features/progress_media/application/progress_photo_providers.dart`
- `lib/features/progress_media/presentation/progress_photo_components.dart`
- `lib/features/progress_media/presentation/progress_media_screen.dart`
- `lib/shared/constants/app_strings.dart`, `app_error_strings.dart`, `directory_constants.dart`
- `lib/shared/theme/app_spacing.dart`
- `test/features/progress_media/progress_photo_flow_test.dart`
- `test/core/storage/local_file_store_test.dart`
- `test/app/bootstrap/app_bootstrap_test.dart`, `test/app/providers/providers_test.dart`
- `integration_test/m6_progress_photo_test.dart`
- This evidence file, `docs/m6-storage.md`, `docs/changelog.md`, `docs/implementation.md`.
