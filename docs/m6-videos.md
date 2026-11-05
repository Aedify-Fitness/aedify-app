# M6 video capture/import — V1-M6-003

Date: 2026-11-05. Status: complete; awaiting user review.
Ticket 002 was approved in conversation. Pause after this ticket;
V1-M6-004 gallery/comparison has not started.

## Implemented behavior

The existing Progress review supports an optional all-sides video alongside the
four photo poses. Users choose camera or library, set a 30- or 60-second limit
(default 60), review a muted local preview, replace/remove/cancel and explicitly
save a video-only or mixed session. Notes/bodyweight use the existing draft and
canonical units. Save stays disabled until the selected video's player has
initialized; preview failures expose retry/replace/remove actions. Tightening a
limit below the selected duration blocks saving until corrected. Late preview
callbacks cannot approve a different video.

The controller/store keep their ticket-002 names to avoid unrelated renaming;
the shared draft now owns both media types. Existing photo-only behavior remains
covered. Schema v20 already supports video/both and parent-linked thumbnails,
so no migration, extra table or hidden preference persistence is introduced.

## Validation and resource limits

- Camera receives the selected duration cap. Imports and capture results undergo
  independent post-selection validation; the native picker is not trusted to
  enforce the cap. Both limits are injected/testable through `ProgressVideoLimits`.
- At most 100 MiB encoded per video. Length is checked before processing, streams
  enforce the limit while copying, and actual staged length must match selection
  length. No entire-video Dart byte buffer is created.
- Supported input is an MP4/MOV ISO base-media container with an allowed brand
  and a real native video track. Duration must be positive and no greater than
  the selected cap; dimensions must be valid. Fractional seconds are rounded up
  only for the existing integer metadata field, after exact-duration validation.
- Native extraction produces only a first-frame PNG thumbnail with a longest
  edge at most 512 pixels. It creates no `video_frame` records or AI artifacts.
  Thumbnail failure preserves the valid original and allows playback review.
- Android API 27+ uses scaled frame retrieval. The API-26 fallback rejects video
  above 16 million pixels before an unscaled decode. iOS validates finite,
  bounded dimensions and rejects external asset references.
- User messages distinguish permission/microphone, invalid/unsupported input,
  duration/size, preview and storage failures. Native/platform exceptions never
  include original messages, paths, notes or private metadata in app errors.

## Native and storage boundaries

`image_picker`, `video_player` and Chewie were already selected dependencies;
no package or lockfile change is required. A small method-channel adapter uses
[AVFoundation](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator)
on iOS and [MediaMetadataRetriever](https://developer.android.com/reference/android/media/MediaMetadataRetriever)
on Android. Each verifies app-owned local paths and size/duration before frame
generation. iOS uses [container-only reference restrictions](https://developer.apple.com/documentation/avfoundation/avassetreferencerestrictions/forbidall).
No URL or arbitrary external file is accepted. This is a thumbnail/metadata
boundary, not a general frame-extraction or AI service.

The application-owned playback service resolves only verified sandbox files,
initializes the player muted and pauses it when the app leaves the foreground.
The widget renders Chewie and reports preview readiness/errors; it does not
read files or call persistence APIs. Player resources are disposed with the
preview provider.

Selected originals/thumbnails remain in the shared temporary media draft root
until Save. The existing store streams them into final UUID-owned paths, then
commits all photo/video metadata, registrations and reminder state together.
A failed transaction compensates all new durable copies and retains the draft
for retry. Cancel/remove/replacement/disposal/startup cleanup use the same draft ownership rules as photos. Durable deletion/orphan recovery remains ticket 006.

Android picker recovery now routes video results to video preparation and asks
for their original source before playback review and save. It never guesses a
saved source or silently persists recovered media. Photo recovery remains intact.

Updated iOS camera/library descriptions and added microphone usage copy. The
system camera may require microphone access; denial has a safe state and library
import remains available, including silent video. The app does not promise
silent camera recording when the OS picker cannot provide it. No new broad
Android media/camera/microphone manifest permission is added. iOS 15+ and Android
API 26+ requirements remain unchanged.

## Verification

Formatting checked 867 Dart files; `flutter analyze` is clean. The full suite passed **1,887 tests**, zero failures/skips, including 16 new regressions (12 video policy/transaction/platform cases, two selected-video widget cases and two bounded file-store cases). The focused media/storage run passed all 83 checks. Final synthetic native smoke passed on iOS (27 seconds) and Android (69 seconds), including real play/pause/seek and muted/no-autoplay assertions. Both normal `lib/main.dart` entrypoints were restored and launched; no temporary configuration or dependency changes remain. `git diff --check` passed.

Host fixtures cover video-only/mixed saves, inclusive duration/stream-size caps,
invalid formats/native replies, permission sanitization, source/capture limits,
preview-readiness gates, cancellation/replacement/removal, thumbnail fallback,
recovery review, late SQL rollback/retry, bounded-copy atomicity and 320px/2x-text
light/dark selected-video layouts. Existing photo/storage regressions still pass.

`integration_test/m6_progress_video_test.dart` embeds a generated silent two-second
96x128 H.264 clip. Synthetic picker selections feed the real native metadata
adapter, thumbnail decoder, video_player/Chewie preview, file service and SQLite
on each simulator. It checks native duration/size rejection, remote-input
rejection, thumbnail bounds, muted/no-autoplay state, play/pause/seek, replacement
and cancel, video-only/mixed save, linked files, disk reopen and zero Dart HTTP
attempts. No physical camera, OS picker gestures, microphone/limited-library dialogs, real-device HEVC/rotation coverage, API-26 fallback execution or process-kill recovery is certified.
No private user media or connected physical phone is accessed.

One generic `flutter build ios --simulator` preflight requested both arm64 and
x86_64 while the local Flutter framework cache contains arm64. Targeted iOS
simulator builds work; no repository architecture/platform workaround is added.
Existing Swift Package Manager/Kotlin migration notices remain separate from
this ticket.

Reproduction:

```sh
dart format .
flutter analyze
flutter test
flutter test integration_test/m6_progress_video_test.dart -d <ios-simulator-id> --no-uninstall
flutter test integration_test/m6_progress_video_test.dart -d emulator-5554 --no-uninstall
```

Local logs: `/private/tmp/aedify-m6-003-{analyze,focused,tests,ios,android}.log`.
Synthetic previews: `/private/tmp/aedify-m6-003-{ios,android}-previews/`.
Light/dark captures were visually reviewed on both platforms. Generated on-device screenshot copies were removed after collection. Normal-entrypoint logs: `/private/tmp/aedify-m6-003-restore-{ios,android}.log`.
No Drift code generation is needed; schema v20 is unchanged. Gallery/comparison,
reminder scheduling, durable cleanup, full privacy exclusions and milestone
acceptance remain tickets 004–008. Optional AI analysis remains M13.

## Changed files

- `android/app/src/main/kotlin/com/example/aedify/MainActivity.kt`
- `android/app/src/main/kotlin/com/example/aedify/ProgressVideoMetadata.kt`
- `ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist`
- `lib/core/storage/local_file_store.dart`
- `lib/features/progress_media/domain/progress_media.dart`, `progress_photo_draft.dart`, `progress_video_draft.dart`
- `lib/features/progress_media/application/progress_photo_controller.dart`, `progress_video_providers.dart`
- `lib/features/progress_media/data/progress_photo_file_service.dart`, `progress_photo_picker.dart`
- `lib/features/progress_media/data/progress_video_file_service.dart`, `progress_video_metadata_service.dart`, `progress_video_picker.dart`, `progress_video_playback.dart`
- `lib/features/progress_media/presentation/progress_media_screen.dart`, `progress_photo_components.dart`, `progress_video_panel.dart`
- `lib/shared/constants/app_strings.dart`, `app_error_strings.dart`
- `lib/shared/theme/app_spacing.dart`
- `test/core/storage/local_file_store_test.dart`
- `test/features/progress_media/progress_photo_flow_test.dart`
- `integration_test/m6_progress_video_test.dart`
- This evidence file, `docs/m6-photos.md`, `docs/changelog.md`, `docs/implementation.md`.

User approved continuing to ticket 004 on 2026-11-05. See [gallery/comparison](m6-gallery.md).
