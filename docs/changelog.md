# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-06-22

### Added (V1-M2 closure — 5 items: version short-circuit, empty-filter semantics, dataset status, thumbnails, tracking docs)

- **Manifest version short-circuit**: `ExerciseDatasetSyncController._runSync()` now fetches the manifest first, compares `LibraryMetaData.libraryVersion` against `manifest.datasetVersion`, and skips download+import when versions match. Status set to `LibrarySyncStatus.synced` explicitly (overrides the `syncing` status set at method entry).
- **Candidate service empty-filter semantics**: `DriftCandidateExerciseQueryService._matchesHardFilters()` now checks `.isNotEmpty` before applying `allowedEquipment`, `allowedDifficulties`, and `allowedModalities` filters. Empty sets mean "no restriction" instead of producing empty results.
- **Settings/About dataset status**: `ExerciseDatasetSyncState` gained `schemaVersion` and `exerciseCount` fields populated from `LibraryMetaData` in `build()` and after import. `ExerciseDatasetStatusTile` on the settings screen now shows real schema version and exercise count instead of null.
- **Real thumbnail handling**: Added `cached_network_image: ^3.4.1` to `pubspec.yaml`. `ExerciseVideoCard` now renders `CachedNetworkImage` (with `CircularProgressIndicator` placeholder and SVG fallback on error) when `video.hasThumbnail` is true, or the existing `videoCamera` SVG when false. Video card tests migrated from `pumpAndSettle` to `pump` to avoid infinite animation from placeholder spinners.
- **M2 tracking docs updated**: `docs/changelog.md` and `docs/implementation.md` updated with M2 closure details.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 359/359 passed.

### Added (V1-M2-010 — Exercise Library QA Fixture Suite)

- **Manifest fixtures** (5 files in `test/fixtures/exercise_library/`):
  - `manifest_valid.json` — valid manifest with 2 history entries, schema v1, 350 exercises.
  - `manifest_same_version.json` — identical dataset for no-download path.
  - `manifest_future_schema_required.json` — `minimum_supported_app_schema_version: 2`.
  - `manifest_missing_active.json` — malformed, no `active` field.
  - `manifest_invalid_shape.json` — missing `exercise_count`.
- **Dataset fixtures** (9 files in `test/fixtures/exercise_library/`):
  - `dataset_valid.json` — 12 exercises covering strength/cardio/bodyweight, multiple modalities/difficulties/muscle groups, mixed video coverage, barbell/dumbbell/cable/machine/null equipment, candidate ranking overlap.
  - `dataset_duplicate_ids.json` — duplicate exercise ID 1.
  - `dataset_unknown_muscle_group.json` — invalid `muscle_groups` value.
  - `dataset_invalid_video_url.json` — invalid video URL format.
  - `dataset_future_schema.json` — future schema version 99.
  - `dataset_count_mismatch.json` — `exercise_count: 99` vs 1 actual exercise.
  - `dataset_invalid_difficulty.json` — difficulty `legendary`.
  - `dataset_invalid_modality.json` — modality `quantum`.
  - `dataset_interrupted_download_stub.json` — truncated JSON for interrupted-download test.
- **Support helpers** (4 files in `test/support/exercise_library/`):
  - `ExerciseLibraryFixtureLoader` — `loadRawString()`, `loadJsonObject()`, `loadJsonArray()` for reading fixtures.
  - `ExerciseLibraryFixtureManifestBuilder` — fluent builder for manifest JSON with overridable fields.
  - `ExerciseLibraryFixtureDatasetBuilder` — fluent builder for dataset JSON with `addExercise()`/`replaceExercises()`.
  - `ExerciseLibraryExpectations` — reusable assertion helpers: `expectContainsExerciseIds`, `expectExactExerciseIdsInOrder`, `expectCandidateDtosContainNoForbiddenFields`, `expectBodymapBucketsAreValid`.
- **Updated tests to use fixtures**:
  - `exercise_dataset_manifest_test.dart` — loads `manifest_valid.json` for valid parsing, `manifest_missing_active.json` for missing-active failure, `manifest_future_schema_required.json` for future-schema test.
  - `exercise_dataset_parser_test.dart` — loads `dataset_valid.json` for valid parsing (12 exercises, no-video check, null-equipment check), loads fixture variants for validation failures (future schema, count mismatch, duplicate IDs, invalid difficulty, invalid modality, unknown muscle group, invalid video URL).
  - `exercise_dataset_download_service_test.dart` — loads `manifest_valid.json` for valid fetch, `manifest_future_schema_required.json` for unsupported schema, uses `ExerciseLibraryFixtureManifestBuilder` for checksum/size tests.
  - `bodymap_asset_contract_test.dart` — uses `ExerciseLibraryExpectations.expectBodymapBucketsAreValid`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 357/357 passed.

### Added (V1-M2-009 — Dataset Sync Status and Recovery UI)

- **`ExerciseDatasetSyncPhase` enum**: 8 phases covering the full sync lifecycle.
- **`ExerciseDatasetSyncState`**: Immutable state with computed getters (`isLoading`, `needsInitialSync`, `hasFailure`, `isSynced`), `copyWith()` with clear flags, `neverSynced()` constructor.
- **`ExerciseDatasetSyncFailure`**: Code, message, retryable flag.
- **`ExerciseDatasetSyncController`**: `AsyncNotifier<ExerciseDatasetSyncState>` — `build()` reads LibraryMeta + NetworkStatus; `initialize()`, `retry()`, `refresh()`, `clearFailure()`; `_runSync()` orchestrates manifest → download → parse → import with full error typing.
- **DAO expansion**: `LibraryMetaDao.clearSyncFailure()`, `updateManifestMetadata()`.
- **Widgets**:
  - `ExerciseDatasetSyncStatusCard` — reusable card with title, message, optional action, loading spinner.
  - `ExerciseDatasetSyncBanner` — watches sync controller, renders above library list; hidden when synced.
  - `ExerciseDatasetStatusTile` — read-only tile for settings (version, count, sync status).
- **Screen integration**: LibraryScreen shows banner; SettingsScreen shows status tile with sync state.
- **AppStrings**: 12 new sync-related strings.
- **Provider**: `exerciseDatasetSyncControllerProvider` (AsyncNotifierProvider), plus `libraryMetaDaoProvider`, `exerciseDaoProvider`, `exerciseVideoDaoProvider`.
- **Tests**: 19 new — 12 controller (initial state never synced/synced/failed, offline unavailable, offline synced, unsupported app schema, download failure, non-retryable failure, clearFailure, missing file catch-all) + 6 banner widget (hidden when synced, first sync, offline, syncing, failed, update-required) + 3 settings (version/status, never synced label, failed label). Library screen test updated with sync controller override. Settings screen test created.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 355/355 passed.

### Added (V1-M2-008 — Custom Exercise Model Hooks)

- **Domain models**: `CustomExerciseSeed` (name, muscleGroups, modality, equipment, difficulty, steps).
- **Identity service**: `CustomExerciseIdentityService.nextCustomExerciseId()` returns deterministically decreasing negative IDs; `newCustomExerciseUuid()` generates v4 UUIDs. Uses `uuid` package.
- **DAO expansion**: `insertCustomExercise()`, `getCustomExerciseByUuid()`, `getLowestExerciseId()`, `updateCustomExercise()`, `deleteCustomExerciseById()`.
- **Repository expansion**: `getCustomExercises()`, `getCustomExerciseDetail()`, `createCustomExercise()`, `updateCustomExercise()`, `deleteCustomExercise()` — fully implemented.
- **Custom exercise conventions enforced**: negative int ID, `isCustom = true`, `customExerciseUuid != null`, `source = 'custom'`.
- **Provider**: `customExerciseIdentityServiceProvider` wired; repository provider injects identity service.
- **4 mock repositories updated** in test files with stub implementations of 5 new methods.
- **Tests**: 22 new — 7 identity service (next ID, UUID gen, determinism, edge cases) + 7 DAO CRUD (insert, getCustom, getByUuid, lowestId, lowestId negative, update, delete) + 8 repository coexistence (create, uuid/source, list surface, detail no videos, update, delete, coexistence, existing unaffected).
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 336/336 passed.

### Added (V1-M2-007 — Deterministic Candidate Exercise Query Service)

- **Domain models**: `CandidateExerciseDto` (id, name, difficulty, muscleGroups, modality, equipment, mechanic, force, isCustom — no user notes, file paths, or flags), `CandidateExerciseQuery` (hard filter sets + excluded IDs/groups + soft ranking signals + limit), `CandidateExerciseRankedResult` (exercise + score).
- **Abstract interface**: `CandidateExerciseQueryService` with `queryCandidates(CandidateExerciseQuery)`.
- **DAO expansion**: `ExerciseDao.getExercisesForCandidateEngine()` — returns non-deleted rows, optionally excludes custom exercises.
- **Implementation**: `DriftCandidateExerciseQueryService` — applies hard filters (equipment, difficulty, modality, excluded IDs, excluded muscle groups), then soft ranking (+3 per preferred muscle group match, +2 per goal tag match on modality/mechanic/force), then deterministic sort (desc score → asc name → asc id), then limit.
- **Provider**: `AppProviders.candidateExerciseQueryServiceProvider` wired in `providers.dart`.
- **Tests**: 15 new — 12 candidate service (equipment filter, null-equipment pass, difficulty filter, modality filter, excluded IDs, substituted excluded IDs, excluded muscle groups, include custom, exclude custom, preferred muscle group ranking, deterministic ordering, limit, no-forbidden-fields, deleted-row exclusion) + 3 DAO (returns source+custom, excludes deleted, excludes custom when disabled).
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 314/314 passed.

### Added (V1-M2-006 — 14-Bucket SVG Bodymap with Tap-to-Select)

- **Domain models**: `BodymapBucket` enum (14 approved buckets with labels), `BodymapViewSide` enum (front, back).
- **Asset contract**: `BodymapAssetContract` with explicit `frontPathToBucket` (17 path IDs → 11 buckets), `backPathToBucket` (19 path IDs → 10 buckets). `assetPathForSide()`, `mappingForSide()`, `allBucketsForSide()` helpers.
- **Controller**: `BodymapSelectionState` (side + selectedBucket) + `BodymapSelectionController` (Notifier with `selectBucket`, `clearSelection`, `toggleSide`, `setSide`). Provider wired in `AppProviders.bodymapSelectionControllerProvider`.
- **SVG assets**: `assets/svgs/bodymap/front.svg` and `back.svg` with path `id` attributes matching contract keys.
- **Widgets**: `BodymapSvgView` renders SVG via `flutter_svg` with side label + `GestureDetector` wrapper (placeholder hit-test). `BodymapBucketChipBar` shows all 14 buckets as `ChoiceChip` + clear button via `OulinedSvgAssets.xMark`.
- **Screen**: `BodymapScreen` (ConsumerWidget) with side-toggle button (`arrowsRightLeft` SVG), `BodymapSvgView`, chip bar, filter handoff button (`magnifyingGlass` SVG + `browseByMuscle` label).
- **Route**: `AppRoutes.bodymap()` in `app_routes.dart`. `GoRoute` entry in `app_router.dart` before workout route.
- **Entry point**: `IconButton` (OulinedSvgAssets.user) in `ExerciseLibraryScreen` app bar navigates via `context.pushNamed(AppRoutes.bodymap().name)`.
- **Filter sheet corrected**: `ExerciseFilterSheet.muscleGroupOptions` replaced from 15 non-compliant values to 14 approved bucket labels (matches bodymap bucket labels exactly).
- **Filter handoff**: Selected bucket pushes `ExerciseFilterState.muscleGroup` = `state.selectedBucket!.label`, clears bodymap selection, pops back to exercise library.
- **Strings added to AppStrings**: `bodymap`, `bodymapFront`, `bodymapBack`, `browseByMuscle`, `clearSelection`, `noExercisesForBodymap`, `bodymapLoadFailed`.
- **Tests**: 25 new — 6 controller, 8 asset contract, 4 chip bar, 4 screen, 1 filter sheet bucket assertion, 1 router test, 1 browse-button scroll fix.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 297/297 passed.

### Added (V1-M2-005 — Exercise Video & Thumbnail Handling)

- **`ExerciseVideoPlaybackState` enum**: `idle`, `loading`, `ready`, `failed` — per-video playback tracking.
- **`ExerciseVideoStateController`** (lib/features/exercise_library/application): `Notifier<Map<String, ExerciseVideoPlaybackState>>` with `markLoading`, `markReady`, `markFailed`, `reset`, `resetAll`. Wired via `AppProviders.exerciseVideoStateControllerProvider`.
- **`ExerciseVideoCard`** (lib/features/exercise_library/presentation/widgets): ListTile-based card with SVG icon + angle/gender metadata. Failed state shows `exclamationTriangle` icon + retry `FilledButton.tonalIcon`.
- **`ExerciseVideoSection`** (lib/features/exercise_library/presentation/widgets): Empty state → `videoCameraSlash` icon + `noExerciseVideos` string. Non-empty → section header + list of `ExerciseVideoCard`s.
- **`ExerciseDetailVideoViewData.hasThumbnail`** getter: Returns true when `ogImageUrl` is non-null.
- **`AppStrings`**: Added `exerciseVideos`, `noExerciseVideos`, `exerciseVideoLoadFailed`, `retryVideo`. Removed unused `videos`.
- **`AppSizing`**: Added `iconXxs = 16` for small button icon sizes.
- **Detail screen updated**: Uses `ExerciseVideoSection` instead of inline video cards. Retry triggers `ref.invalidate` on the detail controller.
- **Tests**: 19 new — 6 controller, 5 card, 5 section, 3 detail screen (no-video fallback, video header, instructions remain visible).
- Removed unused `AppStrings.videos`.
- **AGENTS.md**: Added empty-string null-coalescing rule (`?? ''` allowed for data-display fields, not a required `AppStrings` constant) to Text Styles and Strings sections.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 272/272 passed.

### Refactored (code style & conventions — full sweep)

- **Moved all top-level declarations into classes**: `AedifyLightColors.seedColor`, `AppTheme` (lightTheme/darkTheme), `AppRouter` (appRouterProvider, guards), `AppDatabase._openConnection()`. Deleted unused `exercise_detail_controller.dart`.
- **Replaced all `Theme.of(context).*`** with `context.colorScheme`/`context.textTheme` via `ThemeX` across 3 exercise library files.
- **Replaced `Navigator.pop(context)`** with `context.pop()` (go_router) in `exercise_filter_sheet.dart`.
- **Replaced `context.push()`/`context.go()`** with `context.pushNamed()`/`context.goNamed()` using `AppRoutes.{route}().name` across exercise library and onboarding screens.
- **Replaced all Material `Icons.*`** with `SvgPicture.asset` using SVG constants in exercise library screens + bootstrap failure screen.
- **Replaced `EdgeInsets.fromLTRB`** with `EdgeInsets.symmetric`.
- **Renamed all SVGs** under `assets/svgs/` from kebab-case to snake_case.
- **Created `svg_assets_outlined.dart`** — `OulinedSvgAssets` with 326 camelCase constants.
- **Created `svg_assets_solid.dart`** — `SolidSvgAssets` with 326 camelCase constants.

### Moved (hardcoded strings → constants classes)

- **Added 22 strings to `AppStrings`**: filter labels, tooltips, error messages, section titles. Removed hardcoded strings from `exercise_detail_screen.dart`, `exercise_library_screen.dart`, `error_mapper.dart`, `secure_storage_service.dart`, `firebase_auth_service.dart`, `firebase_storage_client.dart`.
- **Created `app_error_strings.dart`** (`AppErrorStrings` class) for network, storage, firebase failure messages. 14 constants moved out of `AppStrings`.

### Moved (hardcoded numbers → sizing tokens)

- **Extended `lib/shared/theme/app_spacing.dart`**: `AppSpacing.xxs`(2), `buttonVertical`(12), `inputVertical`(14). `AppRadius.xxs`(2). New classes: `AppSizing` (iconXs=18, iconSm=20, handleWidth=40, divider=1), `AppFontSizes` (xs=12).
- **Replaced ~24 hardcoded numbers** with named constants across 7 files: icon sizes, font sizes, divider heights, drag handle dimensions, button/input padding, border radii.

### Updated (AGENTS.md)

- Added new subsections: SVG Assets, Strings and Error Messages, Spacing and Sizing.
- Expanded Navigation with `context.pop()` and `pushNamed`/`goNamed` rules.
- Expanded Architecture with top-level declaration ban, `ThemeX` DON'T, `EdgeInsets` rule.
- Expanded Constants Organization with SVG + layout token locations.
- Updated Text Styles with hardcoded string prohibition.

### Verification

- `dart format` — passed.
- `flutter analyze` — 0 issues.
- `flutter test` — 253/253 passed.

## 2026-06-21

### Added (V1-M2-004 — Exercise Library List + Detail Screens)

- **Domain models**: `ExerciseFilterState` (search query, muscle group, equipment, difficulty, modality, favoritesOnly, excludeSubstituted with `copyWith`), `ExerciseListItem`, `ExerciseDetailVideoViewData`, `ExerciseDetailViewData`.
- **Repository layer**: `ExerciseRepository` abstract interface + `DriftExerciseRepository` implementation with `searchExercises()`, `getExerciseDetail()`, `setFavorite()`, `setSubstitutedOut()`.
- **DAO expansion**: `ExerciseDao.searchExercises()` with SQL-level filtering (query, difficulty, equipment, modality, favorites, excludeSubstituted) and Dart-level muscle-group filter. `setFavorite()`, `setSubstitutedOut()`. `ExerciseVideoDao.getVideosByExerciseId()` with sort ordering.
- **Controllers**: `ExerciseSearchController` (Notifier) with `updateSearchQuery`, `updateFilters`, `clearFilters`, `reload`. `exerciseDetailProvider` (FutureProvider.family).
- **Screens**: Full `ExerciseLibraryScreen` (search bar, active filter bar, loading/empty/error states, result list, filter FAB). `ExerciseDetailScreen` (metadata chips, muscle groups, instructions, videos, favorite/substituted toggles). `ExerciseFilterSheet` bottom sheet.
- **Routes**: `exerciseDetail` path (`/exercises/:id`), sub-route in GoRouter.
- **Tests**: 18 new — 9 repository, 4 search controller, 3 detail controller, 6 library screen widget, 6 detail screen widget.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 241/241 passed.

### Fixed (V1-M2-004 test flakiness)

- Fixed async timing in `exercise_search_controller_test.dart` — controller tests now await `reload()` instead of relying on `Future.delayed`.
- Fixed DetailScreen test matching `'Strength'` (capitalized by `_formatModality`) instead of `'strength'`.
- Fixed `exercise_detail_controller_test.dart` with polling helper `resolveDetail()` to retry until `AsyncData`.
- `flutter analyze` — 0 issues. `flutter test` — 253/253 passed.

### Refactored (syncStatus string constants → LibrarySyncStatus enum)

- Created `LibrarySyncStatus` enum (`lib/core/db/enums/library_sync_status.dart`) with `neverSynced`, `syncing`, `synced`, `failed` values and a `.value` getter.
- Replaced 4 `String` constants in `DbConstants` with the enum.
- Updated `LibraryMetaDao.setSyncStatus()` to accept `LibrarySyncStatus` instead of `String`.
- Updated `ExerciseLibraryImporter` to use `LibrarySyncStatus.synced`.
- Updated test to compare against `LibrarySyncStatus.synced.value`.

### Added (V1-M2-003 — Persist Canonical Exercise Library in Drift)

- **`LibraryMeta` table** (`lib/core/db/tables/library_meta.dart`): Tracks sync status, schema version, library version, exercise count, manifest metadata, error state.
- **`ExerciseVideos` table** (`lib/core/db/tables/exercise_videos.dart`): Video metadata per exercise (url, angle, gender, ogImageUrl, sortOrder).
- **`ExerciseAudioCache` table** (`lib/core/db/tables/exercise_audio_cache.dart`): TTS cache entries per exercise step (text hash, file path, voice).
- **`Exercises` table expanded** (`lib/core/db/tables/exercises.dart`): M2 canonical shape with `isCustom`, `nameNormalized`, `primaryMusclesJson`, `muscleGroupsJson`, `gripsJson`, `stepsJson`, `isSubstitutedOut`, `userNotes`, `importedFromShare`, `sourceDatasetVersion`, `sourceSchemaVersion`, `deletedAt`, timestamps. Removed `autoIncrement` from `id` (now dataset-sourced).
- **`AppDatabase` updated** (`lib/core/db/app_database.dart`): Schema bumped to v3. Registers 3 new tables. Migration creates tables and adds new exercise columns with ALTER TABLE (non-nullable columns given defaults). Schema meta seeding updated.
- **`LibraryMetaDao`** (`lib/core/db/daos/library_meta_dao.dart`): `getLibraryMeta()`, `upsertLibraryMeta()`, `setSyncStatus()`.
- **`ExerciseVideoDao`** (`lib/core/db/daos/exercise_video_dao.dart`): `insertVideosBulk()`, `deleteAllForExerciseIds()`, `deleteAllVideos()`.
- **`ExerciseDao` expanded** (`lib/core/db/daos/exercise_dao.dart`): `getSourceExercises()`, `getCustomExercises()`, `getUserStateByExerciseIds()`, `deleteSourceExercises()`, `restoreUserState()`, `searchExercisesByName()`.
- **`ExerciseLibraryImportFailure`** (`lib/features/exercise_library/data/dataset/exercise_library_import_failure.dart`): Typed failure with 4 codes.
- **`ExerciseLibraryImportResult`** (`lib/features/exercise_library/data/dataset/exercise_library_import_result.dart`): Counts and version.
- **`ExerciseLibraryImporter`** (`lib/features/exercise_library/data/dataset/exercise_library_importer.dart`): Transactional import that preserves user state (favorites, substitutions, notes), deletes old source exercises, bulk-inserts new exercises + videos, writes `LibraryMeta`. Custom exercises never deleted.
- **`DbConstants` additions**: `exerciseLibraryMetaId`, `syncStatusNeverSynced/Syncing/Synced/Failed`.
- **Tests**: 12 new — 3 video DAO tests (bulk insert, delete all, delete by IDs), 5 importer tests (imports exercises/videos, writes meta, preserves user state, doesn't delete custom, returns counts), 4 database/migration tests updated for v3 schema.
- Verification: `dart run build_runner build`, `dart format`, `flutter analyze`, `flutter test` — 223/223 passed.

### Added (V1-M2-002 — Exercise Dataset Parser & Schema Validator)

- **`ExerciseDatasetValidationFailure`** (`lib/features/exercise_library/data/dataset/exercise_dataset_validation_failure.dart`): Typed exception with `ExerciseDatasetValidationFailureCode` enum (14 codes) and optional `field`/`exerciseId` context.
- **`ExerciseDatasetVideo`** (`lib/features/exercise_library/data/dataset/exercise_dataset_video.dart`): Leaf DTO with `Uri url`, `angle`, `gender`, nullable `ogImage`.
- **`ExerciseDatasetExercise`** (`lib/features/exercise_library/data/dataset/exercise_dataset_exercise.dart`): Exercise DTO with typed lists and nullable fields.
- **`ExerciseDataset`** (`lib/features/exercise_library/data/dataset/exercise_dataset.dart`): Root validated dataset model with `DateTime generatedAt` and declared `exerciseCount`.
- **`ExerciseDatasetParser`** (`lib/features/exercise_library/data/dataset/exercise_dataset_parser.dart`): Single parser class with deterministic validation:
  - Validates top-level shape, required fields, schema version bounds, exercise count, duplicate IDs.
  - Validates per-exercise: non-empty name, difficulty (4 supported values), modality (4 supported), muscle groups (14 buckets), strength-equipment rule, steps non-empty, primary_muscles non-empty.
  - Validates videos: URL parsed to `Uri`, must have scheme + authority.
  - Rejects malformed JSON, non-object roots, missing/invalid fields with typed failure codes.
- **Tests**: 27 new tests covering valid parsing, all rejection scenarios, nullable field handling, and empty video lists.
- Verification: `dart format`, `flutter analyze`, `flutter test` — 211/211 passed.

### Added (V1-M2-001 — Exercise Dataset Sync Foundation)

- **`FirebaseAuthService`** (`lib/core/firebase/firebase_auth_service.dart`): Wraps `FirebaseAuth` with `ensureAnonymousSignIn()`. Throws `FirebaseAuthFailure` on error.
- **`FirebaseStorageClient`** (`lib/core/firebase/firebase_storage_client.dart`): Wraps `FirebaseStorage` with `getText()` (via `getData()`) and `downloadToFile()` (via `writeToFile`). Throws `FirebaseStorageFailure`.
- **`ExerciseDatasetManifest` / `ActiveFile` / `HistoryEntry`** (`lib/features/exercise_library/data/dataset/exercise_dataset_manifest.dart`): JSON-deserializable models with strict type validation in `fromJson()`. Includes transport-shape validation (`schema_version`, `active` required).
- **`ExerciseDatasetDownloadFailure`** (`lib/features/exercise_library/data/dataset/exercise_dataset_download_failure.dart`): Typed failure enum covering all download error modes (auth, manifest fetch, invalid manifest, unsupported schema, download failure, interrupted, size mismatch, checksum mismatch).
- **`ExerciseDatasetDownloadResult`** (`lib/features/exercise_library/data/dataset/exercise_dataset_download_result.dart`): Result model with manifest, local paths, timestamp, and size.
- **`ExerciseDatasetDownloadService`** (`lib/features/exercise_library/data/dataset/exercise_dataset_download_service.dart`): Orchestrates anonymous auth, manifest fetch, schema compatibility check, dataset download to temp directory, and SHA-256 + size verification. Cleans up files on failure.
- **`LocalFileStore` additions**: `exerciseDatasetTempDir()` and `exerciseDatasetTempFile()` helpers under `temp/exercise_dataset/`.
- **`DirectoryConstants` addition**: `exerciseDataset` constant.
- **`DbConstants` addition**: `supportedExerciseDatasetSchemaVersion = 1`.
- **Providers** (`lib/app/providers/providers.dart`): Added `firebaseAuthServiceProvider`, `firebaseStorageClientProvider`, `exerciseDatasetDownloadServiceProvider`.
- **Tests**: 22 new tests — 10 manifest parse/validation tests, 12 download service tests (success, auth failure, manifest fetch failure, invalid JSON/array/missing field, size mismatch, checksum mismatch, unsupported schema).
- Added `crypto` dependency to `pubspec.yaml` for SHA-256 verification.
- Verification: `dart format`, `flutter analyze`, `flutter test` — 184/184 passed.

### Changed

- **`lib/app/providers/providers.dart`**: Converted from top-level providers to `AppProviders` class with `static final` members. All references updated across source and test files to use `AppProviders.providerName` syntax.

### Added (Strict M1 closure pass)

- Wired `FirebaseBootstrap` to `DefaultFirebaseOptions.currentPlatform` from `lib/firebase_options.dart`
- Wired `featureFlagsProvider` into runtime behavior, including `crashlyticsEnabled` gating and fail-closed router behavior for AI/imports/sharing/progress routes
- Added `DeveloperDiagnosticsScreen` plus diagnostics route guarded by `diagnosticsEnabled`
- Added disabled-feature routes and strings: `aiDisabled`, `importDisabled`, `shareDisabled`, `progressDisabled`
- Expanded privacy allowlist/forbidden-field policy and strengthened `Redaction` heuristics for diagnostic metadata
- Refactored `AppLogger` to support injectable sinks and sanitized error emission for assertion-based privacy tests
- Refactored `CrashlyticsService` to use a `CrashlyticsClient` boundary and sanitized error/reason forwarding
- Tightened file-store path contract to match the storage plan (`media/progress/...`, `imports/temp/...`, `exports/temp/...`, `audio-cache/exercise_steps/...`)
- Expanded `schema_meta` seeding and tightened `PreferenceKey` allowlist to non-critical recoverable keys only
- Added `SecureStorageFailure` and sanitized unavailable-storage handling
- Added `.github/workflows/foundation.yml` for build_runner + analyze + test enforcement
- Strengthened tests to strict assertions for privacy/logging/network redaction, feature flags, diagnostics routing, migration rollback, file-store cleanup, and secure-storage failure behavior
- Verification: `dart run build_runner build` passed, `flutter analyze` passed, `flutter test` passed (162/162)

### Added (Group 3 — Privacy + Networking + Router Guards)

#### Privacy Infrastructure

- **`PrivacyClassifier`**: Policy-driven classification with `isAllowedInCrashlytics`, `isAllowedInExport`, `isAllowedInLog`, `isDiagnosticFieldAllowed`, `classifyField` methods. Categorizes data into allowed/forbidden/redactable by feature area.
- **`Redaction`**: Static utility class with `sensitive`, `apiKey`, `filePath`, `valueForField`, `metadata`, `headers`, `queryParameters` methods.
- **`CrashlyticsService`**: Allowlist-based key filtering via `setCustomKeySafe`, `recordErrorSafe`, `logSafe`. Forbidden keys silently dropped; error metadata redacted via `Redaction`.
- **Tests**: 8 privacy tests (classification, forbidden/allowed field checks, redaction helpers, Crashlytics allowlist, disabled/no-op behavior).

#### Networking

- **`DioClient`**: Dio wrapper with 30s connect/receive/send timeouts, `RedactedLoggingInterceptor`, and `RetryPolicy`-driven retry loop (configurable max retries, exponential backoff, no retry on 4xx or cancellation). Routes GET/POST/PUT/DELETE through the same retry path. `ErrorMapper` maps `DioException` to `AppError`.
- **`NetworkStatus`**: Connectivity check via `InternetAddress.lookup`. Exposes `isOnline` getter, `onStatusChanged` stream, and `check()` one-shot method.
- **Tests**: `retry_policy_test.dart` (retry decisions, delay math), `error_mapper_test.dart` (all Dio error type mappings + status codes), `dio_client_test.dart` (construction, default retry, interceptor install).

#### Router Guards

- **Guard providers** (`lib/app/guard/guard_state.dart` + `lib/app/providers/providers.dart`): `OnboardingStatus` enum, `AiAvailability` enum (available/missingKey/unsupported), `DraftGuard` enum (clear/blockedByUnsavedDraft). All simple overridable Riverpod providers.
- **`app_router.dart`**: Added bootstrap guard (initializing/failure -> startup), onboarding guard (incomplete -> onboarding), AI availability guard (missingKey -> aiUnavailable, unsupported -> aiUnsupported), draft guard (blockedByUnsavedDraft on 8 guarded routes -> draftBlocked). Strict guard ordering: bootstrap -> onboarding -> AI -> draft.
- **Placeholder routes**: `aiUnavailable`, `aiUnsupported`, `draftBlocked` each with descriptive `Scaffold` + `Text` UI.
- **Route constants**: `AppRoutes.aiUnavailable()`, `AppRoutes.aiUnsupported()`, `AppRoutes.draftBlocked()` in `app_routes.dart`.
- **String constants**: `aiUnavailable`, `aiUnavailableMessage`, `aiUnsupported`, `aiUnsupportedMessage`, `draftBlocked`, `draftBlockedMessage` in `app_strings.dart`.
- **Tests**: 9 router unit tests (redirect outcomes: startup redirects, onboarding redirects, ai redirects, draft redirects, guard precedence, safe routes pass through). 3 app widget tests (missing key, unsupported, draft blocked — all navigate and assert visible text).
- `flutter analyze` — 0 issues; `flutter test` — 144/144 passed

### Added (Group 2 — Storage/Data Foundation)

#### Batch A — DB Tables & DAO

- **`lib/core/db/tables/local_file_records.dart`** (new): Drift table for managed file metadata (category, ownerType, ownerId, localRelativePath, fileSizeBytes, contentHash, mimeType, width, height, durationSeconds, createdAt, lastVerifiedAt).
- **`lib/core/db/tables/schema_migrations_log.dart`** (new): Drift table for migration auditability (fromVersion, toVersion, appliedAt, notes).
- **`lib/core/db/app_database.dart`**: Schema bumped to v2. New tables registered. `onUpgrade` handles 1→2. `onCreate` seeds `drift_schema_version` in `schema_meta`. Added `inTransaction()` helper. Migration log auto-inserted on create/upgrade.
- **`lib/core/db/daos/local_file_record_dao.dart`** (new): Drift DAO with `insertFileRecord`, `upsertFileRecord`, `getByRelativePath`, `getByOwner`, `deleteByRelativePath`, `deleteByOwner`, `markVerified`.
- **`lib/shared/constants/db_constants.dart`**: Expanded with all `schema_meta` key constants.
- **Tests**: `app_database_test.dart` expanded (schema version 2, table access, readiness, inTransaction). `local_file_record_dao_test.dart` (6 tests: insert, query by owner, delete, markVerified). `migration_test.dart` (2 tests: seed, table access).

#### Batch B — File Store Expansion

- **`lib/shared/constants/directory_constants.dart`**: Added nested subdirectory constants (progress, sessions, originals, thumbnails, frames, extracted, imagesOriginal, imagesEnhanced, aedifyPlan, pdf, audioCache, exerciseSteps, db, temp).
- **`lib/core/storage/local_file_store.dart`**: `FileCategory` enum with 17 paths. Added `subDir()`, `clearCategory()`, `deleteFile()`, `cleanupTemporaryImports()`, `cleanupTemporaryExports()`, `cleanupStartupTemporaryArtifacts()`, `toRelativePath()`, `toAbsolutePath()`, session/import/export path helpers.
- **Tests**: `local_file_store_test.dart` (9 tests: dir creation, file ops, cleanup, path conversion).

#### Batch C — File Record Service

- **`lib/core/storage/local_file_record_service.dart`** (new): `LocalFileRecordService` bridging Drift metadata and filesystem. Methods: `registerManagedFile`, `getByRelativePath`, `getByOwner`, `deleteManagedFile`, `deleteManagedFilesForOwner`, `verifyManagedFile`.
- **Tests**: `local_file_record_service_test.dart` (5 tests: register, query, delete single, delete bulk, verify).

#### Batch D — Secure Storage BYOK Refactor

- **`lib/core/storage/secure_storage_service.dart`**: Replaced raw `write`/`read`/`delete`/`containsKey` with `saveProviderApiKey(alias, value)`, `readProviderApiKey(alias)`, `deleteProviderApiKey(alias)`, `rotateProviderApiKey(alias, newValue)`, `hasProviderApiKey(alias)`. Keys prefixed with `ai_provider_api_key:`.
- **Tests**: `secure_storage_service_test.dart` (8 tests: round-trip, missing, has, delete, rotate, deleteAll, isolation).

#### Batch E — Preferences Allowlist

- **`lib/core/storage/preference_key.dart`** (new): `PreferenceKey` enum with typed allowlist (onboardingCompleted, lastSeenVersion, themeMode, selectedLocale, aiDefaultProvider, aiDefaultModel, etc.).
- **`lib/core/storage/preferences_service.dart`**: All methods now accept `PreferenceKey` instead of raw `String`. Keys validated at compile time.
- **Tests**: `preferences_service_test.dart` (6 tests: get/set string, bool, int, remove, key mapping).

#### Providers

- **`lib/app/providers/providers.dart`**: Added `localFileRecordDaoProvider` and `localFileRecordServiceProvider`.

### Changed

- Updated `docs/implementation.md` with Group 2 completed work. Test count: 33→75.
- DB tests now use `NativeDatabase.memory()` for platform-channel independence.

### Fixed

- Corrected M1 status in `docs/implementation.md` from `Complete` to `In Progress (partial)`. Foundation scaffold and Group A (startup/DI/state machine) are now complete.

### Added (Group A — Startup State Machine + DI Hardening)

- **`lib/app/bootstrap/controllers/bootstrap_controller.dart`** (new): `BootstrapController` as `Notifier<BootstrapState>` with `start()` and `retry()` methods. State model: `StartupPhase` enum, `BootstrapState` (phase/failure/isOffline), `BootstrapFailure` (code/message/retryable). Startup sequence: Firebase init -> DB readiness -> file-store init -> network check (non-blocking). Firebase, DB, and file-store failures are blocking; offline is informational. Controller reads all dependencies from providers.
- **`lib/app/bootstrap/app_bootstrap.dart`**: Wrapper exposing `AppBootstrap.controllerProvider`.
- **`lib/app/bootstrap/bootstrap_screen.dart`** (new): Startup screen with loading, failure/retry, and offline informational UI. Uses `AppStrings`, `AppTextStyles`, `AppSpacing`, `AppWhiteSpace`, `ThemeX`.
- **`lib/app/router/app_router.dart`**: Added startup route. Added redirect logic: bootstrapping/failure -> stay on startup, success -> redirect to onboarding. Preserved all existing placeholder routes.
- **`lib/app/providers/providers.dart`**: Added `firebaseBootstrapProvider`; all bootstrap deps independently overridable.
- **`lib/shared/constants/app_routes.dart`**: Added `AppRoutes.startup()` factory. Changed `initialRoute` to `/startup`.
- **`lib/shared/constants/app_strings.dart`**: Added `startingApp`, `startupFailed`, `startupComplete`, `retry`, `offlineModeInfo`.
- **`lib/core/db/app_database.dart`**: Added `readiness()` method. Constructor accepts optional `QueryExecutor` for testability.
- **`lib/core/storage/local_file_store.dart`**: Added `ensureCoreDirectories()`.
- **`lib/features/onboarding/presentation/onboarding_screen.dart`**: Shows offline informational banner after bootstrap redirect when device is offline.
- **Tests**: 33 total (+12 new). 4 app shell widget tests (loading, failure, redirect, offline-onboarding). 6 bootstrap controller unit tests. 3 provider override tests.
- Group A complete: `flutter analyze` — 0 issues; `flutter test` — 33/33 passed

### Changed

- Converted all relative imports to `package:aedify/` imports across 5 files
- Created `app_colors.dart` with all DESIGN.md light/dark color tokens; replaced all hardcoded `Color(0x...)` values in `app_theme.dart`
- Created `AppWhiteSpace` class in `app_spacing.dart` with width/height SizedBox helpers
- Replaced raw spacing/radius values in `app_theme.dart` and `onboarding_screen.dart` with `AppSpacing.*`, `AppRadius.*`, `AppWhiteSpace.*` tokens
- Created `AppTextStylesDark` variant class for dark mode (Inter for body/labels)
- Set `textTheme` on both light/dark themes using `AppTextStyles` / `AppTextStylesDark`
- Created `ThemeX` extension on `BuildContext` for `theme`, `colorScheme`, `textTheme` access
- Replaced `ColorScheme.fromSeed` with explicit `const ColorScheme(...)` populating all color slots
- Added `shadow`/`scrim` constants to `AedifyLightColors`/`AedifyDarkColors`
- Created `app_strings.dart` with all app display strings; removed hardcoded strings from all 14 feature/infrastructure files
- Created `app_routes.dart` with factory constructor pattern for route paths/names; removed nav constants from `app_strings.dart`
- Created `db_constants.dart` and `directory_constants.dart`; moved relevant constants out of `app_strings.dart`
- Refactored `redaction.dart` top-level functions into `Redaction` class with static methods
- Updated `AGENTS.md` with Aedify-specific conventions section (colors, text, nav, constants, imports, architecture)

## 2026-06-20

### Added

#### M1-T001 — Flutter project structure and module boundaries

- Added all validated dependencies to pubspec.yaml (Riverpod, Drift, Dio, Firebase, UI packages, etc.)
- Created full project directory structure per architecture plan
- Implemented Drift database foundation with `schema_meta` table and migration harness
- Implemented `SecureStorageService`, `PreferencesService`, `LocalFileStore` wrappers
- Implemented `DioClient`, `NetworkStatus`, `FirebaseBootstrap`, `CrashlyticsService`
- Implemented `PrivacyClassifier`, redaction utilities, `AppLogger`, `AppError`
- Implemented `GoRouter` routing shell with all feature screen placeholders
- Implemented `FeatureFlags`, `AppBootstrap`, Riverpod `Provider` DI graph
- Implemented DESIGN.md theme tokens (light/dark themes, typography, spacing)
- Generated Drift code with `build_runner`
- 21 passing unit tests for privacy, redaction, errors, and database
- `flutter analyze` — 0 issues

#### M0 — Implementation lock & backlog setup

- Created `implementation.md` and `changelog.md` tracking files
