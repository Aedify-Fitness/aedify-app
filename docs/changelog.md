# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-06-21

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
