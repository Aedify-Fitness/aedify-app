# M5 analytics screens — V1-M5-005

Implemented 2026-10-26 using DESIGN.md and the Flutter mobile design pack.
The Stats destination now opens a local analytics dashboard; exercise links
open `/analytics/exercises/:id` through the app's named router.

## Screen behavior

- Dashboard: completed working-set session/set counts, external-load volume,
  current-calendar-week versus previous-week comparison, weekly volume chart,
  local plateau review/dismissal, recent record improvements, exercise links
  and recent completed workouts. Recent workouts also retain warm-up-only
  sessions through the existing history repository.
- Exercise detail: reliable Epley trend and per-session volume, all-time
  personal bests, separately labeled low-confidence high-rep estimates, plateau
  state and all-time completed set history. Saved warm-ups remain visible here;
  tapping a history card opens the existing workout correction/review flow.
- Four-week and twelve-week filters include the current calendar week and
  preceding calendar weeks; All time includes the complete source history.
  Record detection always sees earlier history before display filtering, so
  changing the range cannot create false baselines. Current personal bests and
  saved set history are explicitly labeled all time.
- Weighted strength volume is the sum of valid actual kg × reps. Reps-only and
  timed sessions contribute counts without fabricated external-load volume.
  Missing or overflowing totals remain unavailable. Future-dated and invalid
  actuals are excluded from the displayed aggregates.
- Saved profile units drive display-only conversion for values, chart axes,
  tooltips and chart data tables. Canonical logs, Epley calculations and PR
  comparisons remain unchanged. Unit-loading failures expose a recoverable
  state rather than silently displaying a different preference.

## UI and accessibility

The dashboard uses a tonal summary, restrained chart panels and a lazy vertical
list with floating-navigation clearance. Detail provides a focused back path.
Controls use approved spacing, typography, surfaces and SVG assets. Panels use
Material surfaces so pressed/focus ink remains visible. Range controls wrap on
small screens and large text; content remains scrollable without fixed text
heights. Maximum content width also supports larger windows.

The shared `fl_chart` component uses real performance dates, explicit zero-based
value axes, straight segments, sparse-point messaging and touch tooltips. An
expandable readable data table and chart semantics provide access to dates and
values without relying on color or touch precision. Animation respects reduced
motion. High-rep estimates are shown separately and never connected into the
reliable strength trend.

Loading, empty-history, empty-range, insufficient/unsupported estimate,
retryable data/unit/history failures and plateau-action failure states are
explicit. Error text never interpolates raw storage exceptions. An empty
dashboard offers local workout entry; no AI setup or network is needed.

## Boundaries

Application providers and a pure mapper prepare screen DTOs; widgets do not
call Drift, files, Firebase or AI. Analytics evidence adds local exercise and
session display names, which remain private and are excluded from diagnostic,
export and AI payload use. Plateau DTOs/flag basis remain unchanged and exclude
these names. No schema or dependency changes were needed.

M5-006 now supplies [app-wide recomputation/invalidation integration](analytics-consistency.md).
M5-007 retains milestone-wide acceptance; notification and AI suggestion flows
remain in their owning later milestones. This ticket supplies the dashboard,
local review/dismissal and drilldown UI using M5-001–004 services.

## Changed files

- `lib/features/analytics/analytics_strings.dart`
- `lib/features/analytics/domain/{analytics_set_log,analytics_view_data}.dart`
- `lib/features/analytics/data/drift_analytics_repository.dart`
- `lib/features/analytics/application/{analytics_view_mapper,analytics_view_providers}.dart`
- `lib/features/analytics/presentation/{analytics_screen,analytics_exercise_history_screen,analytics_format}.dart`
- `lib/features/analytics/presentation/widgets/{analytics_components,analytics_trend_chart,analytics_records_panel,analytics_plateau_panel}.dart`
- `lib/app/router/app_router.dart`, `lib/shared/constants/app_routes.dart`
- `lib/shared/constants/app_error_strings.dart`, `lib/shared/theme/app_spacing.dart`
- `test/features/analytics/application/analytics_view_mapper_test.dart`
- `test/features/analytics/presentation/analytics_screens_test.dart`
- `integration_test/m5_analytics_ui_test.dart`
- This policy, `docs/changelog.md`, `docs/implementation.md`.

## Verification

- Formatting checked 839 Dart files; final analysis is clean.
- Nine mapping/formatting tests cover empty/sparse modes, session aggregation,
  calendar-week fill/comparison, stable all-history PRs, future/identity filters,
  reliable strength series, invalid/overflow values and imperial conversion.
- Seven widget tests cover loading/safe failure, empty-to-workout navigation,
  dashboard/detail at 320px with 2× text in both themes, chart data access,
  imperial units, high-rep confidence and single-point/250-point series.
- iOS and Android native offline acceptance passed: light/dark dashboard and drilldown,
  visible warm-up history and durable plateau dismissal, with zero HTTP calls.
- The full regression suite passed all 1,789 tests, zero failures/skips. iOS
  light/dark dashboard, chart, exercise and saved-history previews were visually
  reviewed for composition, hierarchy and consistency. Normal `lib/main.dart`
  entrypoints were restored/launched on both devices after acceptance.
- Native integration builds emit the existing flutter_tts Swift Package Manager
  adoption warning on iOS and existing Android plugin migration notices; builds
  and acceptance passed. No package changes were required.

Pause for review before V1-M5-006.
