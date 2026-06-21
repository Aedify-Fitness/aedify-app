# Aedify — Implementation Status

## Current Status

| Field                 | Value                                          |
| --------------------- | ---------------------------------------------- |
| **Current Milestone** | M1 — App Foundation + Local Data Spine         |
| **Status**            | Group 3 implemented; Group 4 pending before M2 |
| **Blockers**          | Group 4 completion                             |

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
- `app/providers/providers.dart` — Riverpod DI graph for all core services including firebaseBootstrapProvider
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

### Group 3 — Privacy + Networking + Router Guards (implemented baseline)

Router guards are complete. Privacy and networking baseline infrastructure is implemented and documented to current behavior. Group 4 remains required before M2.

- **Privacy infrastructure**: `PrivacyClassifier` with `isAllowedInCrashlytics`, `isAllowedInExport`, `isAllowedInLog`, `isDiagnosticFieldAllowed`, `classifyField` methods; `Redaction` class with `sensitive`, `apiKey`, `filePath`, `valueForField`, `metadata`, `headers`, `queryParameters` static helpers; `CrashlyticsService` with `setCustomKeySafe`, `recordErrorSafe`, `logSafe` methods using allowlist-based key filtering and redaction.
- **Networking**: `DioClient` wrapping Dio with 30s connect/receive/send timeouts and `RedactedLoggingInterceptor`; `RetryPolicy` (configurable max retries, exponential backoff, no retry on 4xx or cancellation); `ErrorMapper` mapping `DioException` to `AppError`; `NetworkStatus` with DNS-based connectivity check via `InternetAddress.lookup`.
- **Router guards**: `OnboardingStatus`, `AiAvailability`, `DraftGuard` enum providers; bootstrap guard (initializing/failure -> startup), onboarding guard (incomplete -> onboarding), AI guard (missingKey -> aiUnavailable, unsupported -> aiUnsupported), draft guard (blockedByUnsavedDraft on 8 guarded routes -> draftBlocked). Strict guard ordering enforced.
- **Placeholder guard routes**: `/ai-unavailable`, `/ai-unsupported`, `/draft-blocked` each with descriptive Scaffold + Text
- **Constants**: `AppRoutes.aiUnavailable`, `AppRoutes.aiUnsupported`, `AppRoutes.draftBlocked`; `AppStrings.aiUnavailable`, `AppStrings.aiUnavailableMessage`, `AppStrings.aiUnsupported`, `AppStrings.aiUnsupportedMessage`, `AppStrings.draftBlocked`, `AppStrings.draftBlockedMessage`
- 12 new tests (9 router redirect unit + 3 app widget guard)
- Total: 144 tests
- `flutter analyze` — 0 issues
- `flutter test` — 144/144 passed
- `dart run build_runner build` — not needed (no code-gen changes)

## Planned Work

- **M2 — Exercise Dataset Sync + Exercise Library** (10 tickets)
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
- `flutter test` — 144/144 passed
- `dart run build_runner build` — not needed since last run (no code-gen changes)
