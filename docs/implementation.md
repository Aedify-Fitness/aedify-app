# Aedify — Implementation Status

## Current Status

| Field                 | Value                                                          |
| --------------------- | -------------------------------------------------------------- |
| **Current Milestone** | M1 — App Foundation + Local Data Spine                         |
| **Status**            | M1 closure pass implemented; manual device QA evidence pending |
| **Blockers**          | iOS/Android manual QA not executed in this environment         |

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

## Planned Work

- **M2 — Exercise Dataset Sync + Exercise Library** (remaining 8 tickets)
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
- `flutter test` — 162/162 passed
- `dart run build_runner build` — completed successfully

## Manual QA Evidence

- Fresh install on iOS — **Skipped**, no iOS simulator/device workflow executed in this environment
- Fresh install on Android — **Skipped**, no Android emulator/device workflow executed in this environment
- Launch offline — **Covered by automated bootstrap/offline tests**, manual device execution skipped
- Force close and relaunch — **Skipped**, no running app session/device attached
- Simulate migration failure — **Partially covered by migration/rollback tests**, manual app-level simulation skipped
- Simulate secure-storage failure — **Covered by automated secure-storage failure tests**, manual app-level simulation skipped
- Trigger fake redacted crash event — **Covered by Crashlytics service tests**, manual Firebase-backed verification skipped
- Clear app data and relaunch — **Skipped**, no device/emulator app lifecycle session available
