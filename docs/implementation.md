# Aedify — Implementation Status

## Current Status

| Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Current Milestone** | M2 — Exercise Dataset Sync + Exercise Library                                                                                                                                                                                                                                                                                                                                                        |
| **Status**            | 10 of 10 tickets + 5 closure items + TTS/audio-cache slice complete (download, parse, persist, list/detail, video/thumbnails, bodymap, candidate query service, custom exercise hooks, dataset sync status and recovery UI, QA fixture suite, version short-circuit, empty-filter semantics, dataset status, thumbnails, TTS service, audio cache DAO, step audio controller, per-step playback UI). |
| **Blockers**          | None                                                                                                                                                                                                                                                                                                                                                                                                 |

## Completed Work

### M0 — Implementation Lock & Backlog Setup

- Created `docs/implementation.md` and `docs/changelog.md` tracking files

### M1 — App Foundation + Local Data Spine (foundation scaffold completed)

- Added validated stack dependencies: `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `sqlcipher_flutter_libs`, `path_provider`, `flutter_secure_storage`, `shared_preferences`, `dio`, `firebase_core`, `firebase_storage`, `firebase_auth`, `firebase_crashlytics`, `flutter_svg`, `fl_chart`, `flutter_tts`, `video_player`, `chewie`, `flutter_local_notifications`, `health`, `go_router`, `intl`, `uuid`, `path`, `equatable`
- Dev deps: `flutter_test`, `flutter_lints`, `drift_dev`, `build_runner`
- Removed `retrofit`, `retrofit_generator`, `json_serializable`, `json_annotation` (no code-gen approach)
- Tracked `collection` as transitive only
- Created full project directory structure (`app/`, `core/`, `shared/`, `features/`, `ai/`)
- `main.dart` with Riverpod `ProviderScope`
- `app/app.dart` with `MaterialApp.router`, light/dark theme from DESIGN.md
- `app/theme/app_theme.dart` — DESIGN.md color tokens, explicit `ColorScheme` slots, `textTheme` set
- `app/theme/app_colors.dart` — all light/dark color tokens
- `app/router/app_router.dart` — go_router routes using `AppRoutes` factory constructors, startup route + bootstrap-driven redirect
- `app/providers/providers.dart` — Riverpod DI graph as `AppProviders` class (static members: `firebaseBootstrapProvider`, `appDatabaseProvider`, `crashlyticsServiceProvider`, etc.)
- `app/bootstrap/app_bootstrap.dart` — provider entry point (`AppBootstrap.controllerProvider`)
- `app/bootstrap/controllers/bootstrap_controller.dart` — `BootstrapController` as `Notifier<BootstrapState>` with explicit phases, failure model, startup sequence, retry
- `app/bootstrap/bootstrap_screen.dart` — startup loading/failure/retry/offline UI
- `app/feature_flags/feature_flags.dart` — feature flag registry
- `core/db/app_database.dart` — Drift foundation + migration harness + `readiness()` + `inTransaction()` methods, schema v2
- `core/db/tables/` — `schema_meta`, `exercises`, `local_file_records`, `schema_migrations_log` tables
- `core/db/daos/` — `exercise_dao.dart`, `local_file_record_dao.dart` (CRUD for file metadata, ownership queries, verification)
- `core/storage/` — `local_file_store.dart` (nestable dirs, relative/absolute path conversion, cleanup), `local_file_record_service.dart` (bridge between filesystem and Drift metadata), `secure_storage_service.dart` (BYOK alias-based API: `saveProviderApiKey`/`readProviderApiKey`/`deleteProviderApiKey`/`rotateProviderApiKey`/`hasProviderApiKey`), `preference_key.dart` (typed allowlist enum), `preferences_service.dart` (enforces `PreferenceKey` allowlist)
- `core/network/` — `dio_client`, `network_status`
- `core/firebase/` — `firebase_bootstrap`, `crashlytics_service`
- `core/privacy/` — `privacy_classifier`, `redaction` (refactored to `Redaction` class)
- `core/logging/app_logger.dart` — structured logging
- `core/errors/app_error.dart` — error model
- `shared/` — `app_text_styles`, `app_text_styles` (dark variants), `app_spacing` (incl. `AppWhiteSpace`), `placeholder_screen`, `context_extensions`
- `shared/constants/` — `app_strings`, `app_routes` (incl. `startup`), `db_constants` (schema_meta keys expanded), `directory_constants` (nested subdirectory constants)
- `features/onboarding/presentation/onboarding_screen.dart` — shows offline informational state after bootstrap redirect
- Placeholder screens for all other 11 feature areas (no hardcoded strings)
- `AGENTS.md` updated with Aedify-specific conventions
- 75 unit tests (privacy, redaction, error model, database/schema/migration, DAO, file store, file record service, secure storage BYOK, preferences allowlist, bootstrap controller, provider overrides, app shell)
- `flutter analyze` — 0 issues
- `flutter test` — 75/75 passed
- `dart run build_runner build` — completed successfully

### M1 closure pass — strict acceptance alignment

- **Feature flags wired into runtime**: `featureFlagsProvider` now drives `CrashlyticsService.enabled`, route fail-closed behavior for AI/imports/sharing/progress media, and developer diagnostics availability.
- **Firebase bootstrap wired to FlutterFire config**: `FirebaseBootstrap.initialize()` now uses `DefaultFirebaseOptions.currentPlatform` from `lib/firebase_options.dart` instead of relying on bare `Firebase.initializeApp()`.
- **Diagnostics support**: added `DeveloperDiagnosticsScreen` with redacted foundation metadata (startup phase, offline state, drift schema version, non-sensitive feature-flag summary) and `AppRoutes.diagnostics()` route.
- **Additional feature-disabled routes**: `aiDisabled`, `importDisabled`, `shareDisabled`, `progressDisabled` plus matching strings.
- **Privacy hardening**: expanded diagnostic allowlist (`non_sensitive_feature_flag`, schema/version fields, `operation_name_without_payload`, `redacted_stack_trace`) and forbidden-field coverage (candidate lists, injuries, screenshot/source-file/database-dump style fields, progress media paths).
- **Logging hardening**: `AppLogger` now supports injectable sinks for test capture, redacts non-allowlisted metadata, and sanitizes error payloads before emission.
- **Crashlytics hardening**: `CrashlyticsService` now uses a `CrashlyticsClient` boundary, gates on feature flags, forwards only allowlisted keys, redacts metadata, and sanitizes error/reason payloads.
- **Networking proof strengthened**: `DioClient` + `RedactedLoggingInterceptor` verified with secret redaction assertions through injectable logger sinks.
- **Preferences allowlist tightened**: `PreferenceKey` reduced to non-critical recoverable keys only (`onboardingCompleted`, `hasSeenOnboardingIntro`, `lastSelectedTab`, `themeMode`, `lastOpenedLibraryFilter`, `featureFlagOverrides`).
- **Secure storage failure handling**: `SecureStorageFailure` added; BYOK operations now sanitize unavailable-storage failures.
- **Schema metadata seeding expanded**: `schema_meta` now seeds all currently tracked M1 foundation keys from `DbConstants`.
- **File-store contract tightened**: directory constants aligned to the storage plan (`images_original`, `images_enhanced`, `aedifyplan`, `exercise_steps`), import/export paths now use `temp/`, progress media now lives under `media/progress/...`, and core startup directory creation includes temp roots.
- **CI added**: `.github/workflows/foundation.yml` runs `flutter pub get`, `dart run build_runner build`, format check, `flutter analyze`, and `flutter test`.
- **Test suite strengthened**: privacy/logging/network tests now assert real redaction behavior instead of only `returnsNormally`; migration, rollback, file-store cleanup, secure-storage failure, feature-flag, diagnostics, and route fail-closed coverage expanded.
- **Verification**: `dart run build_runner build` succeeded, `flutter analyze` passed with 0 issues, `flutter test` passed with 162/162 tests.

### V1-M2-001 — Exercise Dataset Sync Foundation (complete)

- **`FirebaseAuthService`**: `ensureAnonymousSignIn()` with `FirebaseAuthFailure` exception.
- **`FirebaseStorageClient`**: `getText()` (via `getData()`) and `downloadToFile()` (via `writeToFile`) with `FirebaseStorageFailure` exception.
- **`ExerciseDatasetManifest`**: Full JSON model set (`ExerciseDatasetManifest`, `ExerciseDatasetActiveFile`, `ExerciseDatasetHistoryEntry`) with strict type validation in `fromJson()`.
- **`ExerciseDatasetDownloadFailure`**: Typed enum with 9 failure codes (offline, authFailed, manifestFetchFailed, invalidManifest, unsupportedAppSchema, datasetDownloadFailed, interruptedDownload, sizeMismatch, checksumMismatch).
- **`ExerciseDatasetDownloadResult`**: Result model bundling manifest, local paths, download timestamp, and size.
- **`ExerciseDatasetDownloadService`**: Orchestrates auth → manifest fetch → schema compatibility → download → SHA-256 + size verification. Cleans up on failure.
- **`LocalFileStore`**: Added `exerciseDatasetTempDir()` / `exerciseDatasetTempFile()` under `temp/exercise_dataset/`.
- **`DirectoryConstants`**: Added `exerciseDataset` string constant.
- **`DbConstants`**: Added `supportedExerciseDatasetSchemaVersion = 1`.
- **Providers**: `firebaseAuthServiceProvider`, `firebaseStorageClientProvider`, `exerciseDatasetDownloadServiceProvider`.
- **Tests**: 22 tests covering manifest parsing (10) and download service (12). All pass.
- `dart run build_runner build` — N/A (no code generation for this ticket).
- `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 184/184 passed.

### V1-M2-002 — Exercise Dataset Parser & Schema Validator (complete)

- **`ExerciseDatasetValidationFailure`**: Typed exception with 14-code enum, optional `field`/`exerciseId`.
- **`ExerciseDatasetVideo`**: Leaf DTO with `Uri url`, `angle`, `gender`, nullable `ogImage`.
- **`ExerciseDatasetExercise`**: Exercise DTO with `id`, `name`, `difficulty`, `primaryMuscles`, `muscleGroups`, `modality`, `equipment`, `grips`, `steps`, `videos`.
- **`ExerciseDataset`**: Root dataset model with `schemaVersion`, `generatedAt`, `source`, `exerciseCount`, `exercises`.
- **`ExerciseDatasetParser`**: Deterministic parser validating: top-level shape (JSON object), required fields, schema version bounds, exercise count vs actual, duplicate IDs, difficulty (4 supported), modality (4 supported), muscle groups (14 buckets), strength-equipment rule, non-empty steps, non-empty primary_muscles, valid video URLs.
- **Tests**: 27 new parser tests covering all valid/invalid scenarios.
- `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 211/211 passed.

### V1-M2-003 — Persist Canonical Exercise Library in Drift (complete)

- **3 new Drift tables**: `LibraryMeta`, `ExerciseVideos`, `ExerciseAudioCache`.
- **Exercises table expanded**: M2 canonical shape (19+ columns), removed `autoIncrement`.
- **Schema bumped to v3**: Migration creates tables + adds columns to existing exercises.
- **3 DAOs**: `LibraryMetaDao`, `ExerciseVideoDao`, `ExerciseDao` (expanded with user-state preservation).
- **ExerciseLibraryImporter**: Transactional import preserving user state (favorites, substitutions, notes), bulk-insert, LibraryMeta write. Custom exercises preserved.
- **Failure + Result models**: Typed import failure (4 codes), import result with counts.
- **Tests**: 12 new (DAO + importer), migration/DB tests updated for v3.
- `dart run build_runner build` — completed; `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 223/223 passed.

### V1-M2-004 — Exercise Library List + Detail Screens (complete)

- **Domain models**: `ExerciseFilterState`, `ExerciseListItem`, `ExerciseDetailVideoViewData`, `ExerciseDetailViewData`.
- **Repository layer**: `ExerciseRepository` + `DriftExerciseRepository` with search/exercise detail/favorite/substituted operations.
- **DAO expansion**: `ExerciseDao.searchExercises()` (SQL-level filters for query, difficulty, equipment, modality, favorites, excludeSubstituted; Dart-level muscle-group filter). `ExerciseDao.setFavorite()`, `ExerciseDao.setSubstitutedOut()`. `ExerciseVideoDao.getVideosByExerciseId()` with sort ordering.
- **Controllers**: `ExerciseSearchController` (Notifier) with `updateSearchQuery`, `updateFilters`, `clearFilters`, `reload`. `exerciseDetailProvider` (FutureProvider.family).
- **Screens**: Full `ExerciseLibraryScreen` with search bar, active filter bar, loading/empty/error states, filter FAB. `ExerciseDetailScreen` with metadata chips, muscle groups, instructions, videos, toggles. `ExerciseFilterSheet` bottom sheet.
- **Routes**: `exerciseDetail` path (`/exercises/:id`), sub-route in GoRouter.
- **Providers**: 3 new in `AppProviders` (repository, search controller, detail controller).
- **Codebase convention enforcement**: All `Theme.of(context)` → `ThemeX`, `Navigator.pop` → `context.pop()`, `Icons.*` → `SvgPicture.asset`, `EdgeInsets.fromLTRB` → `EdgeInsets.symmetric`, top-level declarations → classes, route strings → `AppRoutes`, hardcoded strings → `AppStrings`/`AppErrorStrings`, hardcoded numbers → sizing tokens in `app_spacing.dart`. SVGs renamed to snake_case + constants classes created. `AGENTS.md` updated with all enforced rules.
- **Tests**: 18 new — 9 repository, 4 search controller, 3 detail controller, 6 library screen widget, 6 detail screen widget.
- `dart run build_runner build` — completed; `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 253/253 passed.

  - (Flakiness fix: async timing in search controller tests — await `reload()` instead of `Future.delayed`; detail controller tests use polling helper `resolveDetail()` retrying until `AsyncData`.)
- `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 253/253 passed.

### V1-M2-005 — Exercise Video & Thumbnail Handling (complete)

- **`ExerciseVideoPlaybackState`**: enum (`idle`, `loading`, `ready`, `failed`) for per-video playback tracking.
- **`ExerciseVideoStateController`**: `Notifier<Map<String, ExerciseVideoPlaybackState>>` with 5 methods. Provider in `AppProviders.exerciseVideoStateControllerProvider`.
- **`ExerciseVideoCard`**: ListTile widget showing SVG icon + angle/gender metadata. Failed state renders error message + retry button.
- **`ExerciseVideoSection`**: Section wrapper — empty fallback with `noExerciseVideos` string, populated list of `ExerciseVideoCard`s.
- **`ExerciseDetailVideoViewData.hasThumbnail`** getter returns `true` when `ogImageUrl` is non-null.
- **AppStrings**: 4 new video strings. Removed unused `videos`.
- **AppSizing**: Added `iconXxs (16)` for retry button icon.
- **Detail screen**: Uses `ExerciseVideoSection`; retry invalidates detail controller. Instructions remain visible regardless of video state.
- **AGENTS.md compliance audit**: All new files checked against all 10 convention sections — one violation found (`strokeWidth: 2` → `AppSpacing.xxs`) and fixed. DESIGN.md read per §162 for UI work. AGENTS.md updated with empty-string null-coalescing rule (§509-510, §557-560).
- **Tests**: 19 new — 6 controller, 5 card, 5 section, 3 detail screen. 272 total passing.
- `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 272/272 passed.

### V1-M2-006 — 14-Bucket SVG Bodymap with Tap-to-Select (complete)

- **Domain models**: `BodymapBucket` enum (14 approved buckets), `BodymapViewSide` enum (front/back).
- **Asset contract**: `BodymapAssetContract` with explicit `frontPathToBucket` (17 path IDs → 11 buckets), `backPathToBucket` (19 path IDs → 10 buckets). `assetPathForSide()`, `mappingForSide()`, `allBucketsForSide()` helpers.
- **Controller**: `BodymapSelectionState` (side + selectedBucket) + `BodymapSelectionController` (Notifier with `selectBucket`, `clearSelection`, `toggleSide`, `setSide`). Provider in `AppProviders.bodymapSelectionControllerProvider`.
- **SVG assets**: `assets/svgs/bodymap/front.svg` and `back.svg` — path `id` attributes matching contract keys.
- **Widgets**: `BodymapSvgView` (SVG + side label + `GestureDetector` wrapper), `BodymapBucketChipBar` (14 `ChoiceChip`s + clear button via `xMark` SVG).
- **Screen**: `BodymapScreen` — app bar with side toggle (`arrowsRightLeft` SVG), SVG view, chip bar, filter handoff (`magnifyingGlass` SVG).
- **Route**: `AppRoutes.bodymap()` + `GoRoute` in app router.
- **Entry point**: `IconButton` (OulinedSvgAssets.user) in `ExerciseLibraryScreen` app bar → `context.pushNamed(AppRoutes.bodymap().name)`.
- **Filter sheet corrected**: 15 non‑compliant options → 14 approved bucket labels.
- **Filter handoff**: Selected bucket label → `ExerciseFilterState.muscleGroup`, clears bodymap selection, pops back.
- **AppStrings**: 7 new bodymap strings.
- **Tests**: 25 new — 6 controller, 8 asset contract, 4 chip bar, 4 screen, 1 filter sheet, 1 router, 1 browse-button scroll fix. 297 total passing.
- `dart format` — passed; `flutter analyze` — 0 issues; `flutter test` — 297/297 passed.

### V1-M2-007 — Deterministic Candidate Exercise Query Service (complete)

- **Domain models**: `CandidateExerciseDto` (id, name, difficulty, muscleGroups, modality, equipment, mechanic, force, isCustom — no user notes, file paths, or flags), `CandidateExerciseQuery` (hard filter sets + excluded IDs/groups + soft ranking signals + limit), `CandidateExerciseRankedResult` (exercise + score).
- **Abstract interface**: `CandidateExerciseQueryService` with `queryCandidates()` method.
- **DAO expansion**: `ExerciseDao.getExercisesForCandidateEngine()` — non-deleted rows, optional custom exercise exclusion.
- **Implementation**: `DriftCandidateExerciseQueryService` — hard filters (equipment, difficulty, modality, excluded IDs, excluded muscle groups), soft ranking (+3 per preferred muscle group, +2 per goal tag match on modality/mechanic/force), deterministic sort (desc score → asc name → asc id), limit.
- **Provider**: `AppProviders.candidateExerciseQueryServiceProvider`.
- **No controller yet** — service-layer only for M2; later AI/import flows will consume it.
- **Tests**: 15 new — 12 candidate service + 3 DAO. 314 total passing.
- `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 314/314 passed.

### V1-M2-008 — Custom Exercise Model Hooks (complete)

- **Domain models**: `CustomExerciseSeed` (name, muscleGroups, modality, equipment, difficulty, steps).
- **Identity service**: `CustomExerciseIdentityService` — deterministic decreasing negative IDs via `nextCustomExerciseId()`, v4 UUIDs via `newCustomExerciseUuid()`.
- **DAO expansion**: `insertCustomExercise()`, `getCustomExerciseByUuid()`, `getLowestExerciseId()`, `updateCustomExercise()`, `deleteCustomExerciseById()`.
- **Repository**: 5 new methods fully implemented (`getCustomExercises`, `getCustomExerciseDetail`, `createCustomExercise`, `updateCustomExercise`, `deleteCustomExercise`). `DriftExerciseRepository` injects `CustomExerciseIdentityService`.
- **Conventions enforced**: negative int ID, `isCustom = true`, `customExerciseUuid != null`, `source = 'custom'`.
- **Provider**: `customExerciseIdentityServiceProvider` wired; repository updated to inject it.
- **4 mock repositories updated** in test files.
- **Tests**: 22 new — 7 identity service, 7 DAO CRUD, 8 repository coexistence. 336 total passing.
- `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 336/336 passed.

### V1-M2-009 — Dataset Sync Status and Recovery UI (complete)

- **`ExerciseDatasetSyncPhase` enum**: 8 phases covering the full sync lifecycle.
- **`ExerciseDatasetSyncState`**: Immutable state with computed getters (`isLoading`, `needsInitialSync`, `hasFailure`, `isSynced`), `copyWith()` with clear flags, `neverSynced()` constructor.
- **`ExerciseDatasetSyncFailure`**: Code, message, retryable flag.
- **`ExerciseDatasetSyncController`**: `AsyncNotifier<ExerciseDatasetSyncState>` — `build()` reads LibraryMeta + NetworkStatus; `initialize()`, `retry()`, `refresh()`, `clearFailure()`; `_runSync()` orchestrates manifest → download → parse → import with full error typing.
- **DAO expansion**: `LibraryMetaDao.clearSyncFailure()`, `updateManifestMetadata()`.
- **Widgets**: `ExerciseDatasetSyncStatusCard`, `ExerciseDatasetSyncBanner`, `ExerciseDatasetStatusTile`.
- **Screen integration**: LibraryScreen shows banner; SettingsScreen shows status tile with sync state.
- **AppStrings**: 12 new sync-related strings.
- **Providers**: `exerciseDatasetSyncControllerProvider`, `libraryMetaDaoProvider`, `exerciseDaoProvider`, `exerciseVideoDaoProvider`.
- **Tests**: 19 new — 12 controller, 6 banner, 3 settings. Library screen test updated with controller override.
- `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 355/355 passed.

### V1-M2-010 — Exercise Library QA Fixture Suite (complete)

- **Manifest fixtures** (5 files in `test/fixtures/exercise_library/`): valid, same version, future schema required, missing active, invalid shape.
- **Dataset fixtures** (9 files in `test/fixtures/exercise_library/`): valid (12 exercises with full coverage), duplicate IDs, unknown muscle group, invalid video URL, future schema, count mismatch, invalid difficulty, invalid modality, interrupted download stub.
- **Support helpers** (4 files in `test/support/exercise_library/`): `ExerciseLibraryFixtureLoader` (raw/JSON loading), `ExerciseLibraryFixtureManifestBuilder` (fluent manifest builder), `ExerciseLibraryFixtureDatasetBuilder` (fluent dataset builder), `ExerciseLibraryExpectations` (reusable assertion helpers).
- **Tests updated**: manifest test, parser test, download service test, bodymap contract test — all load fixture files instead of inline JSON.
- `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 357/357 passed.

### V1-M2 TTS/Audio Cache Slice (complete)

- **`ExerciseTtsService`** (`lib/core/tts/exercise_tts_service.dart`): Abstract interface — `isAvailable()`, `speak()`, `stop()`, `synthesizeToFile()`.
- **`FlutterExerciseTtsService`** (`lib/core/tts/flutter_exercise_tts_service.dart`): Implementation wrapping `FlutterTts`. Graceful fallback — file synthesis failure falls back to runtime `speak()`, cache persisted only on success.
- **`ExerciseAudioCacheDao`** (`lib/core/db/daos/exercise_audio_cache_dao.dart`): Drift DAO — `upsertCacheEntry()`, `getByExerciseAndStep()`, `deleteByExerciseId()`, `deleteByRelativePath()`, `updateLastAccessed()`, `watchByExerciseId()`.
- **`ExerciseStepAudioState`** (`lib/features/exercise_library/domain/exercise_step_audio_state.dart`): 6-phase immutable state (`idle`, `checkingCache`, `generating`, `speaking`, `unavailable`, `failed`) with `isBusy` getter and safe error code/message.
- **`ExerciseStepAudioController`** (`lib/features/exercise_library/application/exercise_step_audio_controller.dart`): `Notifier<Map<String, ExerciseStepAudioState>>` keyed by `'$exerciseId:$stepIndex'`. `playStep()` orchestrates cache check → TTS availability → cache hit/miss → synthesis → speak. `stop()` tears down.
- **`ExerciseStepAudioButton`** (`lib/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart`): `ConsumerWidget` rendering SVG play/stop/spinner/speakerXMark per phase.
- **Detail screen**: Each step row has an `ExerciseStepAudioButton`. Text remains visible regardless of audio state.
- **Providers**: 3 new in `AppProviders` — `exerciseTtsServiceProvider`, `exerciseAudioCacheDaoProvider`, `exerciseStepAudioControllerProvider`.
- **Strings**: 4 in `AppStrings`, 3 safe error strings in `AppErrorStrings`.
- **Tests**: 20 new — 5 DAO + 6 controller + 7 widget + 2 detail screen. 379 total passing.
- `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 379/379 passed.

### M2 Closure — 5 Items (complete)

1. **Manifest version short-circuit** (`lib/features/exercise_library/application/exercise_dataset_sync_controller.dart`): `_runSync()` fetches manifest first, compares `LibraryMetaData.libraryVersion` vs `manifest.datasetVersion`, skips download + parse + import when unchanged. Status set to `LibrarySyncStatus.synced` explicitly.
2. **Candidate service empty-filter semantics** (`lib/features/exercise_library/data/drift_candidate_exercise_query_service.dart`): `_matchesHardFilters()` checks `.isNotEmpty` on `allowedEquipment`, `allowedDifficulties`, `allowedModalities` before applying — empty set = no restriction, not empty result.
3. **Settings/About dataset status** (`lib/features/exercise_library/application/exercise_dataset_sync_state.dart`, `lib/features/settings/presentation/settings_screen.dart`): `ExerciseDatasetSyncState` now carries `schemaVersion` and `exerciseCount` populated from `LibraryMetaData`. Settings screen shows real values instead of null.
4. **Real thumbnail handling** (`lib/features/exercise_library/presentation/widgets/exercise_video_card.dart`): Uses `CachedNetworkImage` when `video.hasThumbnail` is true (with `CircularProgressIndicator` placeholder and SVG fallback on error), existing `videoCamera` SVG when false. Added `cached_network_image: ^3.4.1` to pubspec. Video card tests use `pump()` instead of `pumpAndSettle()` to avoid infinite animation.
5. **Tracking docs updated**: `docs/changelog.md` and `docs/implementation.md` updated with closure details.

- `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 359/359 passed.

## Planned Work

- M3 — Onboarding, Profile, Settings, BYOK Setup
- M4 — Manual Programmes, Workouts, Logging
- M5 — Analytics, PRs, Plateau Base Logic
- M6 — Progress Media Tracking
- M7 — AI Infrastructure
- M8 — AI Workout + Programme Generation
- M9 — AI Trainer Chat + AI Update Flows
- M10 — Local Sharing + PDF Export
- M11 — External Text File Import
- M12 — Image/Screenshot External Import
- M13 — Optional AI Physique Analysis
- M14 — Privacy, Resilience, Release Hardening

## Verification Notes

- `flutter analyze` — 0 issues
- `flutter test` — 379/379 passed (359 existing + 20 new TTS/audio-cache tests)
- `dart run build_runner build` — passed (7s, 142 outputs)

## Codebase Convention Enforcement Status

All items below are checked with zero violations:

- [x] No top-level declarations outside `main()` — all classes/constants inside classes
- [x] No `Theme.of(context).*` — all replaced with `context.theme`/`colorScheme`/`textTheme` via `ThemeX`
- [x] No `Navigator.pop(context)` — all replaced with `context.pop()`
- [x] No `context.push()`/`context.go()` with hardcoded paths — all use `pushNamed`/`goNamed` with `AppRoutes`
- [x] No Material `Icons.*` — all replaced with `SvgPicture.asset` using SVG constants
- [x] No `EdgeInsets.fromLTRB` — all replaced with `symmetric`/`only`
- [x] No hardcoded user-facing strings — all moved to `AppStrings` or `AppErrorStrings`
- [x] No hardcoded layout/sizing numbers — all use tokens from `AppSpacing`/`AppRadius`/`AppSizing`/`AppFontSizes`
- [x] SVGs in snake_case — accessed via `OulinedSvgAssets`/`SolidSvgAssets`

## Manual QA Evidence

- Fresh install on iOS — **Skipped**, no iOS simulator/device workflow executed in this environment
- Fresh install on Android — **Skipped**, no Android emulator/device workflow executed in this environment
- Launch offline — **Covered by automated bootstrap/offline tests**, manual device execution skipped
- Force close and relaunch — **Skipped**, no running app session/device attached
- Simulate migration failure — **Partially covered by migration/rollback tests**, manual app-level simulation skipped
- Simulate secure-storage failure — **Covered by automated secure-storage failure tests**, manual app-level simulation skipped
- Trigger fake redacted crash event — **Covered by Crashlytics service tests**, manual Firebase-backed verification skipped
- Clear app data and relaunch — **Skipped**, no device/emulator app lifecycle session available
