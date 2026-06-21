# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-06-21

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
