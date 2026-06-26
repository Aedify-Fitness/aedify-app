# Aedify — Implementation Status

## Current Status

| Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Current Milestone** | M3 — Onboarding, Profile, Settings, BYOK Setup                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| **Status**            | V1-M3-001 complete. V1-M3-002 complete. V1-M3-003 complete. V1-M3-004 complete: BYOK provider/model/key configuration UI with secure storage integration, provider/model selectors, API key input with obscured toggle, save/delete/set-active operations, built-in OpenAI/Anthropic/Google options with pricing, key validation via separate Dio endpoints (5s, no retry) before persist, cost-per-workout indicator, "more capable models" hint, "Skip AI for now" button, onboarding BYOK step with key entry form, 4 new repository tests (485 total passing), 0 analyze errors. All `setState` eliminated from `lib/` — both `_obscured` toggles use `ValueNotifier` + `ValueListenableBuilder`. |
| **Blockers**          | None                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

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

### V1-M3-001 — Onboarding Flow, Completion Gate, Debounced Autosave, Resume (complete)

- **Router gate fix** (`lib/app/router/app_router.dart`): Bootstrap guard unchanged. Unresolved `onboardingStatusProvider` keeps user on startup. `complete` status redirects startup/onboarding → home. `incomplete` status redirects non-onboarding routes → onboarding.
- **Debounced draft autosave** (`lib/features/onboarding/application/onboarding_controller.dart`): 400ms debounce on `updateDraft()`. Flush on `nextStep()` and `completeOnboarding()`. Timer cancelled via `ref.onDispose`. Previously the draft was never persisted until final completion.
- **Resume-to-next-incomplete-step** (`OnboardingController._resumeStepForDraft`): `build()` and `loadExistingDraft()` derive step from saved draft. Deterministic progression: experienceGoals → schedule → equipment → unitsMetrics → limitations → byokOptional → review.
- **BYOK skip action** (`lib/features/onboarding/presentation/onboarding_screen.dart`): Explicit `Skip for now` button on BYOK step sets `byokSkipped: true` and advances to review.
- **Post-launch — Bootstrap `mounted` guard** (`lib/app/bootstrap/bootstrap_screen.dart`): Added `if (mounted)` guard around `ref.read(...).start()` in `initState` post-frame callback to prevent `StateError` when the widget is disposed before the callback fires.
- **Post-launch — Chip theme DESIGN.md fix** (`lib/app/theme/app_theme.dart`): Added explicit `backgroundColor`, `selectedColor` to light/dark `chipTheme`. Removed `labelStyle` to let M3 auto-resolve text color from `ColorScheme`.
- **Post-launch — Text field focus loss fix** (`onboarding_screen.dart`): Extracted `_FormField` `StatefulWidget` that creates `TextEditingController` once in `initState` instead of inline in `build()`.
- **Post-launch — Back navigation from all steps** (`onboarding_screen.dart`): Removed guard blocking back from `experienceGoals`. BYOK step simplified — no more special skip button, just Back + Continue.
- **Post-launch — Tappable review rows** (`onboarding_screen.dart`): Added `OnboardingController.jumpToStep()`. Each `_ReviewRow` has `onTap` → `InkWell`, mapped to the source step for inline editing.
- **Post-launch — Experience level chip durations** (`app_strings.dart`): Updated `Beginner`/`Intermediate`/`Advanced` strings to include time ranges (0–6 mo, 6 mo–2 yr, 2+ yr).
- **Post-launch — Branded image assets** (`assets/images/`, `lib/shared/constants/image_assets.dart`, `widgets/onboarding_progress_header.dart`): Added branded light/dark logo PNGs and wired them through `ImageAssets.appLogo()` for use in the onboarding progress header.
- **Post-launch — Full onboarding UI refresh** (`lib/features/onboarding/presentation/onboarding_screen.dart`, `widgets/onboarding_progress_header.dart`, `widgets/onboarding_step_scaffold.dart`): Rebuilt every onboarding step with branded step header, hero welcome treatment, surfaced section cards, grouped equipment panels, premium experience cards, BYOK benefit cards, and grouped editable review summaries while preserving the existing controller/validation flow.
- **Post-launch — Supporting copy and sizing tokens** (`lib/shared/constants/app_strings.dart`, `lib/shared/theme/app_spacing.dart`): Added onboarding helper copy, review affordances, step-label formatter, benefit text, and card/progress sizing tokens required by the new UI.
- **String cleanup**: Goal/equipment/limitation/unit/review labels moved to `AppStrings` constants in `lib/shared/constants/app_strings.dart`.
- **Tests**: 31 onboarding tests (8 repository, 13 controller, 10 screen), router/app tests updated for new gate behavior.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### V1-M3-002 — Profile Repository and Edit Screens (complete)

- **4 Drift tables** (`lib/core/db/tables/`): `user_profile.dart` (json columns for list fields, primary key on id), `strength_anchors.dart`, `body_measurements.dart`, `app_settings.dart` (primary key on id).
- **4 DAOs** (`lib/core/db/daos/`): `UserProfileDao` (getProfile, upsertProfile, markOnboardingCompleted), `StrengthAnchorDao`, `BodyMeasurementDao`, `AppSettingsDao` (getSettings, upsertSettings).
- **Domain models** (`lib/features/profile/domain/`): `ProfileViewData` (immutable display model), `ProfileEditDraft` (edit model with copyWith + clear flags), `ProfileSaveImpact` (enum: none / mayAffectActiveProgrammes).
- **ProfileRepository** (`lib/features/profile/data/`): Abstract interface + `DriftProfileRepository` impl with JSON encode/decode for array fields, transactional save, placeholder `evaluateSaveImpact` returning `none` (seam for future active-programme detection).
- **ProfileController** (`lib/features/profile/application/`): `AsyncNotifier<ProfileState>` with auto-evaluate impact on build and every `updateDraft()` call; validates `experienceLevel` required before save; loads profile on init; supports reload.
- **ProfileScreen** (`lib/features/profile/presentation/`): Full editable form — experience/goal/equipment chips, days-per-week selector, session length field, unit toggle, bodyweight/height fields, injuries chips, notes field, save button. Composed of `_ErrorView`, `_ProfileContentView`, `_ValidationBanner`, `_ImpactWarning`, `_SectionCard`, `_ChipSelector`, `_DaysPerWeekSelector`, `_UnitSelector`, `_FormField` StatefulWidget.
- **App wiring**: `AppDatabase` registered 4 new tables, schema version bumped to 5, migration v4→v5. Providers registered (4 DAOs, repository, controller). Route `/profile` added via `AppRoutes.profile()` + `app_router.dart` GoRoute.
- **AppStrings/AppErrorStrings**: ~15 profile labels + validation/save error strings.
- **5 test files** (`test/`): DAO tests (user_profile: get/upsert/markOnboardingCompleted; app_settings: get/upsert), repository tests (get/save/evaluateImpact), controller tests (build/updateDraft/save/validation/reload), widget tests (loading/save/edit/impact warning).
- **Fixes applied**:
  - Added `primaryKey` to `UserProfile` and `AppSettings` tables for `insertOnConflictUpdate` support.
  - Controller auto-evaluates impact on build and every draft update.
  - Onboarding welcome step now shows title above hero (not replaced by hero).
  - `drift_onboarding_repository.dart` fixed for non-null `experienceLevel` column.
  - Test assertions updated for schema v5, cleared `experienceLevel` (now `''`), and async `updateDraft`.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 errors (3 pre-existing unused-field warnings). `flutter test` — 439/439 passed.

### V1-M3-004 — Full BYOK Provider Setup Flow (complete)

- **`AiProviderConfigs` Drift table** (`lib/core/db/tables/ai_provider_configs.dart`): Metadata, capability flags (`supportsTextInput`, `supportsImageInput`, `supportsJsonSchemaMode`, `supportsStreaming`, `supportsToolCalling`), model limits (`maxContextTokens`, `maxOutputTokens`, `maxImagesPerRequest`, `maxImageSizeBytes`), validation tracking (`lastValidatedAt`, `lastValidationStatus`, `lastErrorCode`), timestamps. Primary key `id`.
- **Database migration**: Schema 5→6, `m.createTable(aiProviderConfigs)` in v6 step.
- **`AiProviderConfigDao`** (`lib/core/db/daos/ai_provider_config_dao.dart`): 8 methods — `getAllConfigs`, `getById`, `getActiveConfig`, `upsertConfig`, `setActiveConfig`, `clearActiveConfig`, `deleteConfig`, `updateValidationState`.
- **Domain models**:
  - `ByokProviderOption` — `{ id, providerName, displayName, description, models (List<ByokModelOption>) }`
  - `ByokModelOption` — `{ id, displayName, inputCostPer1kTokens, outputCostPer1kTokens, estimatedCostPerWorkout, isCheapest }`
  - `ByokConfigViewData` — `{ id, providerName, displayName, selectedModel, hasKey, isActive, lastValidationStatus, lastErrorCode }`
  - `ByokEditDraft` — `{ configId, providerName, selectedModel, apiKey, makeActive }` with `copyWith()`/clear flags
- **`ByokRepository`** (abstract) + **`DriftByokRepository`** (`lib/features/settings/data/`): 3 built-in providers — OpenAI (GPT-4o, GPT-4o-mini, o1, o1-mini with pricing), Anthropic (Claude Sonnet 4.6 / Haiku 4.5 / Opus 4.7 with pricing), Google (Gemini 2.5 Pro / Gemini 2.5 Flash with pricing). Save/rotateKey/deleteConfig/setActiveConfig/validateKey. API key stored only in `SecureStorageService` (never in Drift), `hasKey` boolean only in view data.
- **`ProviderKeyValidator`** (`lib/features/settings/data/provider_key_validator.dart`): Per-provider Dio endpoints (5s timeout, no retry) — OpenAI `/v1/models` (Authorization header), Anthropic `/v1/messages` (x-api-key header), Google `/v1/models` (x-goog-api-key header). Returns `KeyValidationResult{isValid, errorCode}`. Privacy-redacted errors.
- **`ByokSetupController`** (`lib/features/settings/application/`): `AsyncNotifier<ByokSetupState>` with `updateDraft()`/`save()` (validates key via `ProviderKeyValidator` before persist, shows `isTesting` spinner)/`rotateKey()`/`deleteConfig()`/`setActiveConfig()`/`reload()`. Validation rejects empty keys/missing provider.
- **`ByokSettingsScreen`** (`lib/features/settings/presentation/`): Full configuration screen — existing configs as cards (active badge, model, hasKey indicator, setActive/delete with confirmation dialog), provider selector via `ChoiceChip`, model selector via `DropdownButtonFormField` (shows PRD display names), obscured API key input with toggle, `_CostIndicator` ("Est. cost: $0.xx"), `_MoreCapableHint` ("More capable models available"), error/validation banners, save button with spinner, "Skip AI for now" `OutlinedButton`.
- **Onboarding BYOK step** (`_ByokOptionalStep` in `lib/features/onboarding/presentation/onboarding_screen.dart`): Rewritten as `ConsumerStatefulWidget` — loads provider options on init, shows provider selection (ChoiceChip), model selection (Dropdown), API key input (obscured toggle), "Save key" `FilledButton` that persists to `ByokRepository` and sets `byokSkipped: false`, success banner with key icon. Scaffold Continue button always skips forward.
- **setState elimination**: Both `_obscured` toggles (`_ByokOptionalStepState`, `_ApiKeyFieldState`) migrated from `bool` + `setState` to `ValueNotifier<bool>` + `ValueListenableBuilder`. **Zero `setState` calls remain in `lib/`**.
- **Routing**: `AppRoutes.byokSettings()` (`/settings/byok`) — existing `aiProviderSettings` route redirects to `byokSettings`.
- **Strings**: 20 total BYOK strings in `AppStrings` (13 original + `skipAiForNow`, `estimatedCostPerWorkout`, `byokTestingKey`, `lessThan`, `byokMoreCapableModelsHint`, `byokOnboardingSaved`, 3 provider descriptions). 8 total in `AppErrorStrings` (6 original + `byokKeyValidationFailed`, `byokValidationNetworkError`).
- **Tests**: 25 new — 6 DAO, 10 repository (7 original + 3 new provider/model/pricing/correctness), 7 controller, 2 widget. Shared `FakeConfigDao`/`FakeSecureStorage` in `fake_dependencies.dart`. Controller/screen tests use `_ValidatingFakeRepository` subclass that bypasses real HTTP validation.
- **Fixes**: `_ModelSelector` type cast for `DropdownButtonFormField<String>`; `_ApiKeyField` Riverpod build-time state modification (moved `onChanged` to `TextFormField.onChanged`); pre-existing test schema version 5→6; `isNotNull`/`isNull` ambiguity with drift exports; unused import cleanup; `FakeConfigDao.upsertConfig()` companion absent-field handling.
- **setState elimination**: Both `_obscured` toggles (`_ByokOptionalStepState`, `_ApiKeyFieldState`) migrated from `bool` + `setState` to `ValueNotifier<bool>` + `ValueListenableBuilder`. **Zero `setState` calls remain in `lib/`**.
- **Verification**: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 485/485 passed.

### V1-M3-003 — Settings Shell, BYOK Entry, Feature Status Display (complete)

- **`PreferredUnit` enum** (`lib/shared/domain/preferred_unit.dart`): Expanded to own all unit concerns — `isImperial`/`isMetric` getters, `heightLabel`/`weightLabel`/`heightHint`/`weightHint`/`heightUnit`/`weightUnit` display properties, `toMetricHeight`/`toMetricWeight`/`toImperialHeight`/`toImperialWeight` conversion methods. Replaced raw conversion constants and private static helpers in widgets.
- **`ThemeModeSetting` enum** (`lib/shared/domain/theme_mode_setting.dart`): `system`/`light`/`dark` with `dbValue`/`fromDb`/`toMaterialThemeMode`/`displayLabel`.
- **Domain models switched from `String` to typed enums**: `OnboardingDraft.preferredUnits`, `ProfileViewData.preferredUnits`, `ProfileEditDraft.preferredUnits`, `SettingsViewData.preferredUnits`/`themeMode` — all use `PreferredUnit`/`ThemeModeSetting` enums instead of raw strings.
- **Repository boundary conversion**: `DriftOnboardingRepository`, `DriftProfileRepository`, `DriftSettingsRepository` convert enum ↔ DB string at the boundary via `.dbValue`/`.fromDb()`.
- **Settings domain** (`lib/features/settings/`): `SettingsViewData` (13 fields), `SettingsEditDraft` (7 mutable fields with `copyWith()`), `SettingsRepository` (abstract), `DriftSettingsRepository` (reads/writes `AppSettings` table through `AppSettingsDao`, merges `FeatureFlags` for status-only display).
- **SettingsController** (`lib/features/settings/application/settings_controller.dart`): `AsyncNotifier<SettingsState>` with `updateDraft()`/`save()`/`reload()`. State model: `isLoading`, `viewData`, `editDraft`, `errorCode`/`errorMessage`, `isSaving`, `hasError`.
- **SettingsScreen** (`lib/features/settings/presentation/settings_screen.dart`): Full shell — profile nav tile, exercise dataset status, app settings card (units dropdown, theme dropdown, 5 switches + save), AI setup nav tile, feature status section (5 tiles from FeatureFlags), privacy/storage card, diagnostics nav tile.
- **3 reusable widgets**: `settings_section_card.dart`, `settings_feature_status_tile.dart`, `settings_storage_boundary_card.dart`.
- **Theme mode wiring** (`lib/app/app.dart`): `AedifyApp` watches `settingsControllerProvider` and applies `themeMode.toMaterialThemeMode()`.
- **Routing**: `AppRoutes.aiProviderSettings()` path `/settings/ai-provider` + placeholder GoRoute in `app_router.dart`.
- **Providers**: `settingsRepositoryProvider` and `settingsControllerProvider` registered in `AppProviders`.
- **AppStrings**: 18 new strings (settings section titles, imperial unit labels/hints/units, feature status labels).
- **AppErrorStrings**: 2 new strings (`settingsLoadFailedMessage`, `settingsSaveFailedMessage`).
- **Onboarding form improvements**: Switching units now converts displayed values (cm↔in, kg↔lbs) instead of just relabeling; `_FormField` uses `ValueKey('height_${draft.preferredUnits}')`/`ValueKey('weight_${draft.preferredUnits}')` to force recreation; review step shows correct labels and converted imperial values.
- **Tests**: 18 new — 3 drift_settings_repository, 5 settings_controller, 8 settings_screen, 2 storage_boundary_card. Profile/onboarding/presentation tests updated for `PreferredUnit` enum type. App test bootstrap controllers simplified (start in `success` state directly); `_FixedOnboardingNotifier` added to override `onboardingControllerProvider` and bypass Drift in widget tests.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 460/460 passed.

## Planned Work

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

- `flutter analyze` — 0 issues (2 pre-existing unused-field warnings in `drift_profile_repository.dart:28:24` and `:30:30`)
- `flutter test` — 485/485 passed (25 new: 6 DAO, 10 repository, 7 controller, 2 widget)
- `dart run build_runner build` — passed (280 outputs)
- `dart format` — all files formatted

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
