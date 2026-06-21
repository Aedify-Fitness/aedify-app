# Aedify — Implementation Status

## Current Status

| Field | Value |
|---|---|
| **Current Milestone** | M1 — App Foundation + Local Data Spine |
| **Status** | Complete |
| **Blockers** | None |

## Completed Work

### M0 — Implementation Lock & Backlog Setup
- Created `docs/implementation.md` and `docs/changelog.md` tracking files

### M1 — App Foundation + Local Data Spine (all 11 tickets)
- Added validated stack dependencies: `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `sqlcipher_flutter_libs`, `path_provider`, `flutter_secure_storage`, `shared_preferences`, `dio`, `firebase_core`, `firebase_storage`, `firebase_auth`, `firebase_crashlytics`, `flutter_svg`, `fl_chart`, `flutter_tts`, `video_player`, `chewie`, `flutter_local_notifications`, `health`, `go_router`, `intl`, `uuid`, `path`, `equatable`
- Dev deps: `flutter_test`, `flutter_lints`, `drift_dev`, `build_runner`
- Removed `retrofit`, `retrofit_generator`, `json_serializable`, `json_annotation` (no code-gen approach)
- Tracked `collection` as transitive only
- Created full project directory structure (`app/`, `core/`, `shared/`, `features/`, `ai/`)
- `main.dart` with Riverpod `ProviderScope`
- `app/app.dart` with `MaterialApp.router`, light/dark theme from DESIGN.md
- `app/theme/app_theme.dart` — DESIGN.md color tokens, explicit `ColorScheme` slots, `textTheme` set
- `app/theme/app_colors.dart` — all light/dark color tokens
- `app/router/app_router.dart` — go_router routes using `AppRoutes` factory constructors
- `app/providers/providers.dart` — Riverpod DI graph for all core services
- `app/bootstrap/app_bootstrap.dart` — startup initialization controller
- `app/feature_flags/feature_flags.dart` — feature flag registry
- `core/db/app_database.dart` — Drift foundation + migration harness
- `core/db/tables/` — `schema_meta`, `exercises` tables
- `core/db/daos/exercise_dao.dart` — DriftAccessor
- `core/storage/` — `secure_storage_service`, `preferences_service`, `local_file_store`
- `core/network/` — `dio_client`, `network_status`
- `core/firebase/` — `firebase_bootstrap`, `crashlytics_service`
- `core/privacy/` — `privacy_classifier`, `redaction` (refactored to `Redaction` class)
- `core/logging/app_logger.dart` — structured logging
- `core/errors/app_error.dart` — error model
- `shared/` — `app_text_styles`, `app_text_styles` (dark variants), `app_spacing` (incl. `AppWhiteSpace`), `placeholder_screen`, `context_extensions`
- `shared/constants/` — `app_strings`, `app_routes`, `db_constants`, `directory_constants`
- Placeholder screens for all 12 feature areas (no hardcoded strings)
- `AGENTS.md` updated with Aedify-specific conventions
- 21 unit tests (privacy classifier, redaction, error model, database)
- `flutter analyze` — 0 issues
- `flutter test` — 21/21 passed
- `dart run build_runner build` — successful

## Active Work

_None. M1 is complete._

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
- `flutter test` — 21/21 passed
- `dart run build_runner build` — completed successfully
