# M6 gallery and comparison — V1-M6-004

Date: 2026-11-05. Status: complete; paused for user review before ticket 005.

Progress now opens a local timeline. New check-in opens the existing capture/review flow. Sessions open named detail routes with angle-labelled photos, video thumbnails, explicit muted playback, saved notes, optional measurements in the selected units, and a baseline action. Notes remain editable offline; failed writes preserve dialog input for retry.

Comparison supports baseline/latest, previous/latest and any two saved sessions. Latest/previous follow the repository's capture-date ordering. Photos pair front/front, back/back, left/left and right/right only. Missing views never substitute a different pose. Missing originals retain their session metadata and report a broken-media state, including when a cached thumbnail survives. Selecting the same session twice (or setting latest as baseline) asks for a different selection. Videos remain independent, explicitly opened local players; comparison creates no extracted frames or AI request.

Timeline filters combine media type, photo pose and inclusive local calendar dates. Photo/video filters include mixed sessions. The mixed filter selects mixed sessions only. No matching results can be cleared. A video-only check-in does not match a photo-pose filter. Date and time labels distinguish multiple check-ins on the same day. Filtering does not change saved records or comparison defaults.

Timeline covers and labels follow front/back/left/right/video order rather than storage IDs. The gallery lazily builds cards and loads their details/previews. Pose filtering reads matching session metadata through the repository. Image reads are sandboxed and size-bounded, decode to at most 512px using the existing photo processor, and fall back from a broken thumbnail to the original photo. Video bytes are never read into Dart for a gallery image. Players reuse ticket 003's muted, disposal/lifecycle-owned video_player/Chewie boundary. Private errors, paths and file names are never rendered or forwarded to diagnostics.

Schema v20, existing packages, native adapters and storage ownership are unchanged. Durable writes are limited to explicit notes/baseline actions through the existing repository. All new routes inherit the Progress feature flag and unsaved-draft guard. Reminder cadence (005), durable deletion/cleanup (006), broad privacy exclusions (007), and milestone acceptance (008) remain later tickets.

## Verification

- `dart format .`: 876 files checked.
- `flutter analyze`: no issues.
- `flutter test --reporter expanded`: **1,913/1,913 passed**, zero failures/skips; 26 new regressions (20 gallery and 6 route-guard cases).
- Focused media/router verification passed 122 cases before the additional stable-cover case; the final full suite includes that regression.
- Final synthetic native smoke passed on iOS (17 seconds) and Android (35 seconds). Both verify saved gallery/comparisons, manual selection, notes, baseline changes, missing media, native video playback, durable reopen and zero Dart HTTP attempts. Light/dark timeline/comparison and saved-video captures were reviewed; visual feedback produced stable pose order and saved-playback-specific copy. Normal `lib/main.dart` entrypoints were restored and launched successfully on both platforms. Only generated on-device screenshot copies were removed after collecting host review artifacts.

 Host checks cover comparison presets/manual selection, stale/same-session rejection, same-pose matching, stable covers, inclusive dates and combined filters, live notes/baseline updates, safe failure/retry, missing/corrupt previews, clear filters, new capture navigation and six 320px/2×-text light/dark gallery/detail/compare layouts. Six additional real-router cases verify the new deep-link guards. Host cases separate real SQLite/file coverage from deterministic widget fixtures; native smoke uses real repository/files/metadata/player with generated synthetic media and blocked Dart HTTP. It never accesses the camera, OS media library or private photos. Native route fixtures use the production screens and injected real SQLite/files/metadata/player; actual app-router redirects are exercised by host tests. Physical-device gestures, VoiceOver/TalkBack and OS picker/permission/codec coverage are not certified by this ticket.

## Changed files

- `lib/app/router/app_router.dart`, `lib/shared/constants/app_routes.dart`: gallery/capture/detail/compare routes and inherited guards.
- `lib/features/progress_media/domain/progress_gallery.dart`: ephemeral filters, deterministic comparison selection, same-pose pairing.
- `lib/features/progress_media/application/progress_gallery_providers.dart`: reactive details, filtered timeline, bounded image access and safe notes/baseline actions.
- `lib/features/progress_media/data/progress_gallery_file_service.dart`: sandboxed local preview reads/fallback.
- `lib/features/progress_media/presentation/progress_gallery_screen.dart`: timeline and filters.
- `lib/features/progress_media/presentation/progress_session_screen.dart`: session details, optional snapshot, notes, baseline and saved video.
- `lib/features/progress_media/presentation/progress_comparison_screen.dart`: preset/manual comparisons.
- `lib/features/progress_media/presentation/progress_gallery_components.dart`: shared responsive media, labels and states.
- `lib/features/progress_media/presentation/progress_video_panel.dart`: reuse existing player for saved originals with safe saved-media errors.
- `lib/shared/constants/app_strings.dart`, `app_error_strings.dart`, `lib/shared/theme/app_spacing.dart`: centralized copy and responsive comparison token.
- `test/features/progress_media/progress_gallery_test.dart`, `test/app/router/app_router_test.dart`: gallery/data/policy/error/accessibility and deep-link guard regressions.
- `integration_test/m6_progress_gallery_test.dart`: synthetic offline native UI/playback/reopen smoke and visual captures.
- `docs/changelog.md`, `docs/implementation.md`, `docs/m6-videos.md`, this file: status, scope and evidence.

Evidence logs: `/private/tmp/aedify-m6-004-{format,analyze,tests,focused,ios,android}.log`; generated light/dark timeline/comparison and saved-video captures in `/private/tmp/aedify-m6-004-{ios,android}-previews/`. `flutter test ... --no-uninstall` retains synthetic captures long enough for inspection; the default runner uninstalls its app at completion. Restoration logs: `/private/tmp/aedify-m6-004-restore-{ios,android}.log`.

Sources: locked PRD FR-12.7–8, FR-12.17–22 and privacy restrictions; architecture §19; M6 ticket 004; progress-media feature/data/test plans. The repository's existing v20 schema and thumbnail graph remain the implementation baseline.
