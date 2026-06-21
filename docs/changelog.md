# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-06-21

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
