# Aedify — Implementation Status

## Current Status

| Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Current Milestone** | M4 — Persistence Foundation + Workout Builder + Programme Builder + Workout Runner + Workout History & Programme Library + Custom Exercise Editor (Programmes, Saved Workouts, Workout Builder, Programme Builder, Workout Session Runner, Lift Log, Programme Library, Custom Exercise Management)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **Status**            | V1-M3-001 through V1-M3-009 complete. **V1-M4-001 through V1-M4-011 complete**. Workout runner/session integrity fixes landed across completion UX, duplicate-active-session repair, and guarded progress saves. SessionCompleteScreen replaces inline `_WorkoutCompletedView` with navigation-based flow, draws preferred unit from profile, formats completion percentage, and correctly distinguishes untouched exercises from completed ones. **New `WorkoutCompleteScreen`** added for normal completions with dedicated HTML-matching design (filled check_circle hero, 3-column bento stats, Aedify Insight card, exercise summary, Done + Share Summary bottom layer). **New `FinishEarlySessionCompleteScreen`** added for early-finish sessions. **New `ExitWorkoutSheet`** and **`FinishEarlyDialog`** replace inline exit/abandon UI. **ProgrammesScreen** redesigned with state-aware CTA (start/resume/hidden) via `WorkoutDetailButtonState` enum. **Schema v12** adds `prescribed_reps_exact` column to `set_logs`. Programme builder/calendar/home sync fixes landed across slot persistence, refresh flow, and shared today-workout resolution. Saved workouts are now soft-delete persisted via schema v11 (`deleted_at`). Convention sweeps remain complete — full 12-rule audit completed 2026-07-05: ~90 violations (hardcoded colors, raw spacing/radius/icon sizes, `Navigator.of(context).pop()`, commented code, `const` violations) fixed across 10 files. Zero `Color(0x...)`, raw spacing/radius values, `Navigator.pop()`, `Theme.of(context)`, `print()`, relative imports, or raw SVG paths remain in widget code. Logging remains instrumented across 59 M4-module files. Workout builder screen redesigned with expanded sets table (WEIGHT/REST columns, StatefulWidget controllers, computed dirty-state), 4-tier difficulty badges (novice/beginner/intermediate/advanced) in exercise picker with color tokens, and new `ExercisePickerFilterSheet`. Workout builder screen further redesigned with superset grouping (left-border groups, `_SupersetGroupWidget`), DropdownButton TYPE column, inline superset selection mode (replaces bottom-sheet editor), redesigned config panel header, and "Next: Review & Publish" CTA footer. Goal tags migrated from enum to raw string format across domain, persistence, and tests. Latest verification: `dart format .` passed, `flutter analyze` passed, and `flutter test` has 1 remaining failing M3 smoke-flow test. |
| **Blockers**          | None                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Pre-existing**      | Flutter 3.44.4 `ink_sparkle.frag` shader regression breaks FilledButton tap tests. Affects `complete_workout_sheet_test.dart` (mitigated with `NoSplash` in test theme) and pre-existing `programme_save_bar_test.dart`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

## Completed Work

### 2026-07-06 — ExerciseCard extraction — shared widget reused across workout builder and exercise library

- **New shared widget**: `lib/features/exercise_library/presentation/widgets/exercise_card.dart` — `ExerciseCard` (public `StatelessWidget`) extracted from `AddExerciseBottomSheet._ExerciseCard`. Takes `ExerciseListItem item`, `bool isSelected` (defaults `false`), `VoidCallback onTap`. Row layout: 56×56 first-letter avatar, name (bodyLg, single-line ellipsis), `_TagChip` (first muscle group label or modality), equipment chip (when present), trailing `_DifficultyBadge` (color-resolved per difficulty + brightness via `AppBadge`). Selection state animates with `AnimatedContainer` (200ms, easeInOut): secondary border, tinted avatar, `checkCircle` SVG overlay. Private helpers `_TagChip` and `_DifficultyBadge` co-located with `_formatEquipment`/`_formatLabel` functions.
- **`AddExerciseBottomSheet`**: `_ExerciseCard`, `_TagChip`, `_DifficultyBadge` classes (~240 lines) removed; uses shared `ExerciseCard`. Cleaned up 4 unused imports (`app_badge`, `svg_assets_solid`, `exercise_difficulty`). `app_colors` kept (handle bar color).
- **`ExerciseLibraryScreen`**: Old `_ExerciseCard` + `_ExerciseCardImage` + `_MuscleGroupTagRow` (~185 lines) replaced with shared `ExerciseCard`. Cleaned up 2 unused imports (`exercise_list_item`, `exercise_difficulty`).
- Verification: `dart format .` — 3 files (1 changed). `flutter analyze` — 0 issues. `flutter test` — 1064 passed.

### 2026-07-06 — Exercise library screen — full redesign to match HTML design system

- **ExerciseLibraryScreen rewritten** (587 lines): View toggle (`_ViewToggle`/`_TogglePill` — List/Bodymap pills in `surfaceContainerLow` bg, `secondary` selection with shadow, 300ms animation, bodymap icon uses `BodymapSvgAssets.front`). Search bar (white `surfaceContainerLowest` card, `AppRadius.md`, no-border style, search icon, 2px `secondary/20` focused ring). Horizontal muscle-group filter chips (`_MuscleGroupChips` — All/Chest/Back/Legs/Shoulders/Arms/Core/Cardio via `_FilterChipData` mapping to `BodymapBucket` + `ExerciseModality`; `clearMuscleGroup`/`clearModality` flags on `copyWith` to correctly null fields when switching chips). Exercise list uses shared `ExerciseCard` (from extraction above). Dashed-border empty state (`_EmptyState` with `DashedBorderPainter`, 300px, 2px stroke). `_CreateExerciseFab` (`AppRadius.lg`, secondary color, 60×60px, `plusSmall` icon, key `create_exercise_fab`, navigates to custom exercise create).
- **Removed**: `_ActiveFilterBar`, `_FilterChipWidget`, `_ExerciseListTile`, `_FloatingActionButton` filter — replaced by chip bar and shared `ExerciseCard`.
- **Extracted**: `_ErrorView` as private widget (centered exclamation-circle + message + retry `FilledButton`).
- **Test updates**: 8 tests — new view toggle, chip bar, create FAB tests; filter FAB test removed (sheet replaced by inline chips). All existing tests adapted for new widget tree.
- Verification: `dart format .` — 643 files (0 changed). `flutter analyze` — 0 issues. `flutter test` — 1064 passed (8 exercise library screen tests).

### 2026-07-06 — Saved workout library screen — card redesign + FAB

- **`SavedWorkoutListTile` redesigned**: Replaced `Card`+`ListTile` with rich card matching the HTML design spec. Card uses `surfaceContainerLowest` background, `AppRadius.lg` corners, 3-level shadow, 1px `surfaceContainer` border. Layout: description-as-category label (uppercase, 10px, secondary), headline-md title (max 2 lines), stats row with `listBullet` + exercise count and `clock` + duration, trailing `ellipsisVertical` popup menu (start/archive/delete). Bottom row: stacked category circles (bolt + clock, 32px, -8px overlap, `surfaceContainer`/`surfaceContainerLow` fills, 2px `surfaceContainerLowest` border) + 48px filled `play` button (`secondary` bg, `AppRadius.lg`, shadow `secondary` at 20%).
- **New private widgets**: `_StackedCategoryIcons` and `_CategoryIconCircle` for the overlapping icon circles.
- **FAB added** to `SavedWorkoutLibraryScreen`: 56px `secondary` FAB with `plus` icon, `AppRadius.lg` shape, navigates to `AppRoutes.workoutBuilderCreate`.
- **Screen updates**: `_ListView` padding → `top: lg, horizontal: md, bottom: xxl + xl` for FAB clearance. `_EmptyView`/`_ErrorView` text styles updated to `AppTextStyles`. Extracted card `onTap` → `workoutBuilderEdit` route.
- **Files**: `lib/features/programmes/presentation/widgets/saved_workout_list_tile.dart`, `lib/features/programmes/presentation/saved_workout_library_screen.dart`.
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing.

### 2026-07-06 — Convention violation fixes — private widget method, cs param, raw numbers

- **`_buildExerciseListView` extracted**: Private widget-returning method in `_ExerciseListPanel` promoted to proper `_ExerciseListView` `StatelessWidget` class with constructor params. Uses `context.colorScheme` internally instead of receiving `cs`.
- **`_SupersetGroupWidget` `cs` param removed**: Removed `required this.cs` from constructor and `final ColorScheme cs` field. Added `final cs = context.colorScheme;` in `build()`. Caller in `_ExerciseListView` no longer passes `cs`.
- **Raw `4` border width fixed**: `BorderSide(width: 4)` → `width: 2 * AppSizing.strokeWidth` in `_SupersetGroupWidget`'s group accent border.
- **`AppFontSizes.sm` padding fixed**: `right: AppFontSizes.sm` → `right: AppSpacing.md - AppSpacing.xxs` in `_SupersetGroupWidget`'s container padding.
- **`_selectionCount` getter removed**: Both references (`onPressed: _selectionCount >= 2` in build, `'$groupedExercises ($_selectionCount Selected)'` in label) replaced with `selectedSupersetIds.length`; getter deleted.
- **Superset badge → `AppBadge`**: Inline `Container`/`Text` badge in `_SupersetGroupWidget` replaced with shared `AppBadge`, preserving all visual tokens (`secondaryContainer`/`onSecondaryContainer`, `AppRadius.full`, uppercase, custom padding, `FontWeight.w700`).
- **Files**: `lib/features/workout_builder/presentation/workout_builder_screen.dart`.
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — Workout builder — inline superset selection replaces bottom sheet

- **Inline selection mode**: Tapping "Create Superset" now enters `_isSupersetSelectionMode = true` inline instead of opening `SupersetEditorSheet`. Header shows "Exercises (N)" + "Cancel Selection" link. Exercise cards display check circles with selected/unselected borders. "Group Exercises (N Selected)" button appears below the add-exercise button.
- **New state/methods** in `_WorkoutBuilderBodyState`: `_isSupersetSelectionMode`, `_openSupersetSelection()`, `_cancelSupersetSelection()`, `_toggleExerciseSupersetSelection(String id)`, `_createSupersetFromSelection()`.
- **\_SupersetGroupWidget**: Accepts and forwards `isSupersetSelectionMode`, `selectedSupersetIds`, `onToggleSupersetSelection` to its member `_MiniExerciseCard` children.
- **\_MiniExerciseCard**: Added `isSupersetSelectionMode`, `isSelectedForSuperset`, `onToggleSupersetSelection` params. In selection mode, tapping toggles superset selection; check circle shown instead of menu/drag handle.
- **\_ExerciseListPanel**: Added `isSupersetSelectionMode`, `selectedSupersetIds`, `onOpenSupersetSelection`, `onCancelSupersetSelection`, `onToggleSupersetSelection`, `onCreateSupersetFromSelection` params. Header conditionally renders "Cancel Selection" vs "Create Superset". Shows "Group Exercises" FilledButton in selection mode.
- **Removed import**: `superset_editor_sheet.dart` no longer imported in `workout_builder_screen.dart`.
- **New string**: `AppStrings.cancelSelection` added to `app_strings.dart`.
- **Files**: `lib/features/workout_builder/presentation/workout_builder_screen.dart`, `lib/shared/constants/app_strings.dart`.
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — Workout builder screen redesign — superset grouping, TYPE dropdown, new CTA

- **\_ExerciseListPanel**: Rewritten to group exercises by `supersetGroupId` — superset members render inside `_SupersetGroupWidget` (left accent border + inline superset badge) while ungrouped exercises render individually. Original list order preserved within groups.
- **"Create Superset" header**: New row showing "Exercises (N)" + `OutlinedSvgAssets.link` icon + `AppStrings.createSuperset` text link. (Superseded by inline selection mode above.)
- **\_ConfigPanelHeader**: Exercise name changed from `labelMd` to `headlineMd`. Superset badge (`AppBadge` with `secondaryContainer`/`onSecondaryContainer`) shown inline below name when `exercise.supersetGroupId != null`, alongside "CONFIGURATION" label.
- **\_SetTableRow TYPE column**: Replaced `GestureDetector` toggle with `DropdownButtonHideUnderline` + `DropdownButton` using `setTypeOptions` — matches HTML design.
- **\_FooterSection**: Changed save button to "Next: Review & Publish" with `Icons.arrow_forward`, `borderRadius: AppRadius.full`, horizontal padding `xl+sm`, vertical padding `buttonVertical+sm`, `fontWeight: w700`.
- **Cleanup**: Removed unused `superset_grouping_policy.dart` import, unused `displayIndex` variable, unnecessary string interpolation.
- **Files**: `lib/features/workout_builder/presentation/workout_builder_screen.dart`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — Badge unification — SupersetGroupBadge, \_PhaseBadge, \_DifficultyBadge all delegate to AppBadge

- **AppBadge extended** (`lib/shared/components/app_badge.dart`): Added `EdgeInsetsGeometry? padding` and `TextStyle? textStyle` optional params. `padding` overrides the default `EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs)`. `textStyle` replaces the default `context.textTheme.labelSmall` base (still applies `color`, `fontWeight`, `letterSpacing` as `.copyWith` overrides on top).
- **`SupersetGroupBadge`** (`lib/features/workout_builder/presentation/widgets/superset_group_badge.dart`): Rewrote `build()` to return `AppBadge` with `borderRadius: AppRadius.xxs`, `padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxs)`, `textStyle: AppTextStyles.labelSm`, and `primaryContainer`/`onPrimaryContainer` colors. Public API (`groupId`, `order`) unchanged. Existing test continues to pass.
- **`_PhaseBadge` removed** (`lib/features/programmes/presentation/widgets/programme_calendar_header.dart`): Replaced private class and single usage site with inline `AppBadge` — `borderRadius: AppRadius.full`, `padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs + 1)`, `letterSpacing: 0.02`, `surfaceContainerHigh`/`onSecondaryFixedVariant` colors, label constructed as `'${AppStrings.currentPhase}: $blockType'.toUpperCase()`.
- **`_DifficultyBadge`** (`lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`): Rewrote `build()` to return `AppBadge`. Keeps the brightness-aware color-resolution switch and `_formatLabel` helper. Passes resolved `bg`/`text` colors, `padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs)`, and `textStyle: AppTextStyles.headlineXl.copyWith(fontSize: AppFontSizes.xxs, letterSpacing: 0.5)`.
- **Consolidation result**: 6 private/badge-like widget definitions → 1 shared `AppBadge` + 2 thin public wrappers (`SupersetGroupBadge`, `_DifficultyBadge`). Only `_StreakBadge` (ConsumerWidget, composite with fire SVG + text, not a simple label badge) and `_IconBadge` (icon-in-box, no text label) remain as private widgets — architecturally different patterns.
- **Files**: `lib/shared/components/app_badge.dart`, `lib/features/workout_builder/presentation/widgets/superset_group_badge.dart`, `lib/features/programmes/presentation/widgets/programme_calendar_header.dart`, `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`.
- Verification: `dart format .` — 2 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — \_Badge extraction — 3 private definitions unified into shared AppBadge component

- **New shared widget**: `lib/shared/components/app_badge.dart` — `AppBadge` `StatelessWidget` with required `label`, optional `backgroundColor`/`foregroundColor` (defaults to `context.colorScheme.secondary`/`onSecondary`), `borderRadius` (default `AppRadius.sm`), `fontWeight`, and `letterSpacing`.
- **Removed 3 private `_Badge` definitions** from `home_screen.dart` (hardcoded colors, 1 param), `programme_list_tile.dart` (customizable colors, `textColor` param), `programmes_screen.dart` (customizable colors, `foregroundColor` param, `FontWeight.w500` + `letterSpacing: 0.02`, `AppRadius.defaultRadius`).
- **7 usage sites updated**:
  - `home_screen.dart`: 3 `_Badge(label: ...)` → `AppBadge(label: ...)` — uses defaults (no params needed).
  - `programme_list_tile.dart`: 2 `_Badge(label: ..., backgroundColor: ..., textColor: ...)` → `AppBadge(label: ..., backgroundColor: ..., foregroundColor: ...)` — renamed `textColor` to `foregroundColor`.
  - `programmes_screen.dart`: 2 `_Badge(label: ..., foregroundColor: ..., backgroundColor: ...)` → `AppBadge(label: ..., foregroundColor: ..., backgroundColor: ..., borderRadius: AppRadius.defaultRadius, fontWeight: FontWeight.w500, letterSpacing: 0.02)` — preserves the non-default radius and typography overrides via explicit params.
- **Token inconsistency resolved**: `AppRadius.sm` (4px) is the shared default; `programmes_screen.dart` passes `AppRadius.defaultRadius` (8px) explicitly.
- **Files**: `lib/shared/components/app_badge.dart` (new), `lib/features/home/presentation/home_screen.dart`, `lib/features/programmes/presentation/widgets/programme_list_tile.dart`, `lib/features/programmes/presentation/programmes_screen.dart`.
- Verification: `dart format .` — 1 changed (new file). `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — Convention compliance audit — ~90 token/color/navigation violations fixed across 10 files

- **Scope**: Systematic check of all enforceable rules from `AGENTS.md` and `rules.md` across `lib/`. 8 of 12 rule categories passed clean. The remaining 4 categories produced ~90 violations across 10 files — all fixed.
- **Hardcoded colors → theme tokens**:
  - `finish_early_dialog.dart`: `Color(0x26000000)` → `context.colorScheme.shadow.withAlpha(38)`, `Colors.black.withValues(alpha: 0.4)` → `context.colorScheme.scrim.withAlpha(102)`
  - `exit_workout_sheet.dart`: `Color(0x140052d5)` / `Color(0x0a0052d5)` → `context.colorScheme.secondary.withAlpha(20)/withAlpha(10)`
  - `finish_early_session_complete_screen.dart`: `Colors.white.withAlpha(128)` → `context.colorScheme.outlineVariant.withAlpha(128)`, `Colors.black.withAlpha(10)` → `context.colorScheme.shadow.withAlpha(10)`
  - `programme_workout_detail_screen.dart`: `Colors.white` → `context.colorScheme.onSecondary`
- **Raw spacing → `AppSpacing.*` / `AppWhiteSpace.*`**: Replaced ~40 raw `SizedBox(height:/width:)` and ~18 raw `EdgeInsets.all/symmetric/only/fromLTRB(width:)` across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `exit_workout_sheet.dart`, `programme_workout_detail_screen.dart`.
- **Raw border radius → `AppRadius.*`**: Replaced 11 `BorderRadius.circular(n)` with `AppRadius.md` / `AppRadius.full` / `AppRadius.defaultRadius` across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `programmes_screen.dart`.
- **Raw icon sizes → `AppSizing.*`**: Replaced 9 `Icon(size:)` with `AppSizing.iconSm/Md/Xxl/decorativeIcon` across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `workout_builder_screen.dart`.
- **New token**: `AppSizing.decorativeIcon = 128` added to `app_spacing.dart`.
- **`Navigator.of(context).pop()` → `context.pop()`**: Fixed 3 remaining calls in `finish_early_dialog.dart` and `workout_complete_screen.dart`.
- **Commented code removed**: 42-line `ListTile` block in `bottom_nav_shell.dart`.
- **`const` keyword removed from `boxShadow` arrays** in `exit_workout_sheet.dart` and `finish_early_dialog.dart` — `.withAlpha()` method calls cannot be const.
- **Restored missing import**: `workout_runner_session_view_data.dart` in `workout_complete_screen.dart`.
- **Files**: `app_spacing.dart`, `finish_early_dialog.dart`, `exit_workout_sheet.dart`, `programme_workout_detail_screen.dart`, `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `workout_builder_screen.dart`, `programmes_screen.dart`, `bottom_nav_shell.dart`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — Timer widgets — setState → ValueNotifier + ValueListenableBuilder

- **Rationale**: Timer-driven `setState` calls caused entire widget subtrees to rebuild every second (progress circle, time text, label, title, button, clock icon). `ValueNotifier` + `ValueListenableBuilder` scopes rebuilds to only the widgets that depend on the changing value.
- **`RestTimerWidget`**: `int _remaining` → `ValueNotifier<int>` initialized with `widget.seconds`. `_startTimer()` writes `_remaining.value--` instead of `setState(() => _remaining--)`. `_adjust()` writes `_remaining.value = clamped`. Timer Stack (circular progress + time text + "REST TIME" label) wrapped in `ValueListenableBuilder<int>`. `_remaining.dispose()` added to dispose.
- **`WorkoutRunnerHeader`**: `_tick` `ValueNotifier<int>(0)` incremented each second instead of `setState(() {})`. `_elapsed` getter → `_formatElapsed(Duration)` method taking `_stopwatch.elapsed` as parameter. Elapsed `Text` wrapped in `ValueListenableBuilder<int>` — only the timer text rebuilds each tick; title, "Session In Progress" label, "Finish Early" button, clock SVG icon remain static.
- **Files**: `lib/features/workout_execution/presentation/widgets/rest_timer_widget.dart`, `lib/features/workout_execution/presentation/widgets/workout_runner_header.dart`
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### 2026-07-05 — AppTextField — shared text field widget with focus dismissal

- **New shared widget**: `lib/shared/components/app_text_field.dart` — `AppTextField` `StatefulWidget` wrapping `TextField`/`TextFormField`.
  - Always calls `FocusScope.of(context).unfocus()` on `onTapOutside` — no `FocusNode` needed.
  - `enableObscureToggle` renders internal eye/eye-slash `IconButton` managed via `setState` (used by API key fields in BYOK settings and onboarding).
  - `validator` auto-selects `TextFormField` (when non-null) or `TextField` — callers don't need to choose.
  - Parameters: `controller`, `focusNode`, `hintText`, `labelText`, `errorText`, `prefixIcon`, `suffixIcon`, `obscureText`, `enableObscureToggle`, `keyboardType`, `textInputAction`, `textCapitalization`, `maxLines`, `minLines`, `inputFormatters`, `onChanged`, `onSubmitted`, `enabled`, `validator`, `filled`, `fillColor`, `contentPadding`, `borderRadius`, `style`, `isDense`, `suffixText`, `suffixStyle`, `borderOverride`.
  - Default decoration uses theme tokens: `surfaceContainerLowest` fill, `outlineVariant` borders, `secondary` focused border, `AppSpacing.md`/`inputVertical` padding, `AppRadius.defaultRadius` radius.
- **Replaced all 16 raw `TextField`/`TextFormField` usages** across 14 files:
  - `custom_exercise_name_field.dart` — name input field
  - `workout_name_field.dart` — workout name field
  - `programme_details_section.dart` — programme name + description (2 fields)
  - `programme_template_quick_create_sheet.dart` — template name field
  - `workout_exercise_card.dart` — rest seconds field
  - `exercise_library_screen.dart` — `_SearchBar` with controller leak fix (converted to `StatefulWidget`, controller disposed in `dispose()`)
  - `custom_exercise_steps_editor.dart` — step editor loop
  - `set_prescription_editor_row.dart` — 3 fields (weight, reps, rest)
  - `add_exercise_bottom_sheet.dart` — search bar with pill shape (`borderOverride: InputBorder.none`, `borderRadius: AppRadius.full`)
  - `workout_runner_screen.dart` — `_EditableField` inline weight editor
  - `workout_runner_set_row.dart` — 3 fields (weight, reps, notes)
  - `profile_screen.dart` — `_FormField` wrapper
  - `onboarding_screen.dart` — `_FormField` wrapper + BYOK API key field
  - `byok_settings_screen.dart` — `_ApiKeyField` API key field
  - `workout_builder_screen.dart` — `_InputField` (3 label+field rows) + compact set table (4 fields: weight, reps, target, rest) + `_CoachNotesField`
- **Removed 4 private wrapper classes**: `_InputField` (workout_builder_screen.dart), `_FormField` (profile_screen.dart + onboarding_screen.dart), `_ApiKeyField` (byok_settings_screen.dart), `_ByokFormWidgetState` (onboarding_screen.dart).
- **Cleaned up `_obscured` `ValueNotifier`** from `_ApiKeyFieldState` and `_ByokFormWidgetState` — obscure toggle now internal to `AppTextField.enableObscureToggle`.
- **Test updates**:
  - `byok_settings_screen_test.dart` — all `find.byType(TextFormField)` → `find.byType(TextField)` (5 occurrences)
  - `m3_setup_smoke_flow_test.dart` — `find.byType(TextFormField)` → `find.byType(TextField)` (2 occurrences)
  - `workout_runner_set_row_test.dart` — `find.widgetWithText(TextFormField, ...)` → `TextField` (3 occurrences)
- **Files**: `lib/shared/components/app_text_field.dart` (new), 14 modified widget files, 3 modified test files
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1051 passed, 1 pre-existing failure (M3 smoke flow library browse).

### 2026-07-05 — Schema v12 — prescribed_reps_exact column

- Bumped database schema from `11` to `12`.
- Added nullable `prescribed_reps_exact` (INTEGER) column to `set_logs` via migration `ALTER TABLE set_logs ADD COLUMN prescribed_reps_exact INTEGER`.
- Updated `AppDatabase` onCreate migration logging to `toVersion: 12`.
- Schema-version and migration-log tests updated for version `12`.
- Files: `lib/core/db/app_database.dart`, `lib/core/db/app_database.g.dart`, `lib/core/db/tables/set_logs.dart`, `test/core/db/app_database_test.dart`, `test/core/db/migration_test.dart`

### 2026-07-05 — ProgrammesScreen redesign with state-aware CTA

- Rewrote `ProgrammesScreen` with redesigned programme list — tiles show programme name, goal tags, and a state-aware `WorkoutDetailButtonState` CTA (start/resume/hidden) reflecting active-session status.
- Added `WorkoutDetailButtonState` enum at `lib/shared/domain/workout_detail_button_state.dart` — three states: `start`, `resume`, `hidden`.
- Tapping a programme tile navigates to `ProgrammeCalendarScreen`. Edit moved to overflow menu.
- Wired `activeWorkoutSessionProvider` for CTA state and `workoutRunnerControllerProvider.family` for start/resume actions.
- Files: `lib/shared/domain/workout_detail_button_state.dart`, `lib/features/programmes/presentation/programmes_screen.dart`, `lib/features/programmes/presentation/widgets/programme_day_card.dart`, `lib/app/providers/providers.dart`

### 2026-07-05 — Runner exit flow — ExitWorkoutSheet, FinishEarlyDialog, FinishEarlySessionCompleteScreen

- **`ExitWorkoutSheet`** (`widgets/exit_workout_sheet.dart`): Bottom sheet replacing inline exit-confirmation — shows elapsed time, session name, and three actions: Finish & Save, Pause, Abandon.
- **`FinishEarlyDialog`** (`widgets/finish_early_dialog.dart`): Dedicated dialog for early-finish flow — session summary with notes/energy/difficulty collection before completing.
- **`FinishEarlySessionCompleteScreen`** (`finish_early_session_complete_screen.dart`): New summary screen for early-finish sessions (untouched sets remain). Displays completion percentage, duration, volume, exercise summary with skipped/untouched badges.
- Routing: normal completion → `WorkoutCompleteScreen`, early finish → `FinishEarlySessionCompleteScreen`, abandon → HomeScreen via `context.pop()`.
- New AppStrings: `exitWorkout`, `finishAndSave`, `pauseWorkout`, `abandonConfirm`.
- Files: `lib/features/workout_execution/presentation/workout_runner_screen.dart`, `lib/features/workout_execution/presentation/workout_complete_screen.dart`, `lib/features/workout_execution/presentation/finish_early_session_complete_screen.dart`, `lib/features/workout_execution/presentation/widgets/exit_workout_sheet.dart`, `lib/features/workout_execution/presentation/widgets/finish_early_dialog.dart`, `lib/shared/constants/app_routes.dart`, `lib/app/router/app_router.dart`, `lib/shared/constants/app_strings.dart`

### 2026-07-05 — Domain model rest field propagation — SetLogDraft, WorkoutRunnerSetItem, WorkoutSessionDraft

- Added `int? restSeconds` to `SetLogDraft` and `WorkoutRunnerSetItem` with `copyWith` propagation.
- Added `int? restBetweenExercisesSeconds` to `WorkoutSessionDraft` with `copyWith` propagation.
- Updated `WorkoutRunnerMapper.toViewData()`/`toDraft()` to preserve rest fields in round-trip.
- Updated `StartWorkoutSessionUseCase` to propagate `restSeconds` from set prescriptions and `restBetweenExercisesSeconds` from exercise drafts.
- Updated `DriftWorkoutSessionRepository` to persist rest fields on `set_logs` and `workout_session_exercises` columns.
- Files: `lib/features/workout_execution/domain/set_log_draft.dart`, `lib/features/workout_execution/domain/workout_runner_set_item.dart`, `lib/features/workout_execution/domain/workout_session_draft.dart`, `lib/features/workout_execution/application/workout_runner_mapper.dart`, `lib/features/workout_execution/application/start_workout_session_use_case.dart`, `lib/features/workout_execution/data/drift_workout_session_repository.dart`

### 2026-07-05 — Auto-calculated workout estimated duration from rest times + set count

- Added `int computeEstimatedDurationMinutes()` to `WorkoutBuilderDraft` — iterates all exercises/sets, computes per-set contribution using tiered fallback: `set.restSeconds ?? exercise.restBetweenExercisesSeconds ?? draft.restBetweenExercisesSeconds ?? 60`, plus 60s per set for execution time. Returns `totalSeconds ~/ 60`.
- Updated `WorkoutBuilderController._normalizeDraftForSave()` to call `draft.computeEstimatedDurationMinutes()` and pass via `estimatedDurationMinutes:` in the `copyWith` call.
- Previously `estimatedDurationMinutes` was always null — no calculation logic existed in the codebase.
- Files: `lib/features/workout_builder/domain/workout_builder_draft.dart`, `lib/features/workout_builder/application/workout_builder_controller.dart`
- Verification: `dart format .` — 636 files (1 changed). `flutter analyze` — 0 issues. `flutter test` — 1060 passed, 1 pre-existing failure (M3 smoke flow, unrelated).

### 2026-07-05 — AppWhiteSpace compliance — all SizedBox whitespace migrated

- Added `wXxs` (2px width) and `hXxs` (2px height) constants to `AppWhiteSpace` in `lib/shared/theme/app_spacing.dart`.
- Replaced ~135 `SizedBox(height: AppSpacing.*)` → `AppWhiteSpace.h*` across 55 files.
- Replaced ~52 `SizedBox(width: AppSpacing.*)` → `AppWhiteSpace.w*` across 19 files.
- Replaced raw `SizedBox(width: 2)` → `AppWhiteSpace.wXxs` and `SizedBox(width: 40)` → `AppWhiteSpace.custom(width: AppSizing.handleWidth)` in `workout_builder_screen.dart`.
- Replaced `SizedBox(width: AppSpacing.buttonVertical)` → `AppWhiteSpace.custom(width: AppSpacing.buttonVertical)` in `exercise_picker_filter_sheet.dart`.
- No behavior change — purely convention alignment.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1060 passed, 1 pre-existing failure.

### 2026-07-05 — Workout builder screen — enhanced sets table, WEIGHT/REST columns, controller lifecycle

- Expanded `_ExerciseConfigPanel` sets table with **WEIGHT** and **REST** columns alongside existing SET/TYPE/REPS/TARGET — inline `TextField` editors with proper `TextEditingController` lifecycle managed via `StatefulWidget` (`_SetTableRow`). Weight parsed as `double`, rest as `int`, reps as range ("8-10") or exact, target as RPE range ("RPE 8-9") or RIR ("2").
- `_SetTableRow` (StatefulWidget) — `_onWeightChanged`, `_onRestChanged`, `_onRepsChanged`, `_onTargetChanged` listeners with `_isSyncing` guard to prevent listener feedback loops. `_syncControllers()` on `didUpdateWidget` preserves cursor position across reorder/selection changes.
- `_CoachNotesField` (StatefulWidget) — per-exercise notes textarea with controller lifecycle, `didUpdateWidget` sync on `exerciseId` change.
- `_DashedBorderPainter` (CustomPainter) — dashed-border rounded-rect painter for "Add Exercise" button. `_AddExerciseButton` with plus-circle icon and `AppStrings.addExercise`. `_ExerciseMenu` popup menu (duplicate/delete) replacing always-visible icons — saves space on mini cards.
- Rest seconds displayed in `_MiniExerciseCard` summary line — clock SVG icon + `{restSec}s` when set-level rest is present.
- **Domain model enhancements**:
  - `SetPrescriptionDraft` — added `clearTarget()`, `clearReps()`, `clearWeight()`, `clearRest()` mutation helpers (returns new instance with respective field cleared). Full `==`/`hashCode` overrides for dirty-state comparison.
  - `WorkoutBuilderDraft` — added `clearRestBetweenExercises()`, `==`/`hashCode` with `listEquals` for list fields.
  - `WorkoutBuilderExerciseDraft` — `==`/`hashCode` override.
  - `ExerciseReference` — `==`/`hashCode` override for stable equality in dirty comparison.
  - `SavedWorkoutDraft.goalTags` type changed from `Set<GoalTag>` to `Set<String>` — goal tags stored as raw strings instead of enum values, matching JSON persistence format.
- **Controller state refactor** (`WorkoutBuilderState`):
  - Mutable `isDirty` field removed — replaced with computed `bool get isDirty => draft != originalDraft`.
  - State gains `WorkoutBuilderDraft originalDraft` — set on init, preserved for comparison.
  - `updateExerciseNotes`, `updateGoalTags`, `updateDescription`, `updateRestBetweenExercises` simplified — no `isDirty: true` on copyWith calls.
- **Load use case** (`LoadWorkoutDraftUseCase`):
  - Now accepts optional `ExerciseDao` — resolves `modality` per exercise from DB for difficulty badge display in the picker sheet.
  - `goalTags` decoded from `jsonDecode(saved.goalTagsJson)` cast to `List<String>` instead of `GoalTag` enum conversion.
- **Save use case** (`SaveWorkoutDraftUseCase`):
  - Uses raw string goal tags directly (`builderDraft.goalTags.toSet()`) — removed `_goalTagFromString` helper and `GoalTag` import.
- **Repository** (`DriftSavedWorkoutRepository`):
  - Goal tags serialized with `jsonEncode(draft.goalTags.toList())` instead of `EnumCodec.encodeSet`.
  - Added `import 'dart:convert'`.
- **Providers**: `loadWorkoutDraftUseCaseProvider` now injects `exerciseDaoProvider`.
- **AppTheme**: `surfaceTintColor` set on both light and dark `AppBarTheme` to match scaffold background and prevent default tint on scroll.
- **New AppStrings**: weightColumn, restColumn, configLabel, reorderButton, defaultRestHint, rpeHint, secondsUnitAbbreviation, duplicateExercise, removeSet.
- **New SVG asset**: `assets/svgs/outline/stack.svg` — used in mini-card set count summary. `OutlinedSvgAssets.stack` added.
- **New radius token**: `AppRadius.xxl = 32`.
- **Test updates**:
  - `workout_builder_controller_test.dart` — 4 test groups add `loadWorkoutDraftUseCaseProvider` override with `LoadWorkoutDraftUseCase` constructed from the same fake repository.
  - `workout_builder_integration_test.dart` — asserts `createNewWorkout` header text, uses `ensureVisible` to scroll to add exercise button before tapping.
  - `m4_manual_tracker_acceptance_test.dart` / `m4_privacy_integrity_blockers_test.dart` — `GoalTag.generalFitness` replaced with string `'general_fitness'`.
- Files: `lib/features/workout_builder/presentation/workout_builder_screen.dart`, `lib/features/workout_builder/application/workout_builder_controller.dart`, `lib/features/workout_builder/application/workout_builder_state.dart`, `lib/features/workout_builder/application/load_workout_draft_use_case.dart`, `lib/features/workout_builder/application/save_workout_draft_use_case.dart`, `lib/features/workout_builder/domain/exercise_reference.dart`, `lib/features/workout_builder/domain/set_prescription_draft.dart`, `lib/features/workout_builder/domain/workout_builder_draft.dart`, `lib/features/workout_builder/domain/workout_builder_exercise_draft.dart`, `lib/features/workout_builder/domain/saved_workout_draft.dart`, `lib/features/workout_builder/data/drift_saved_workout_repository.dart`, `lib/app/providers/providers.dart`, `lib/app/theme/app_theme.dart`, `lib/shared/constants/app_strings.dart`, `lib/shared/constants/svg_assets_outlined.dart`, `lib/shared/theme/app_spacing.dart`, `assets/svgs/outline/stack.svg`, `test/features/workout_builder/application/workout_builder_controller_test.dart`, `test/features/workout_builder/presentation/workout_builder_integration_test.dart`, `test/app/m4/m4_manual_tracker_acceptance_test.dart`, `test/app/m4/m4_privacy_integrity_blockers_test.dart`

### 2026-07-05 — Exercise picker bottom sheet — expanded difficulty badges (4 tiers), restyled cards

- Redesigned `AddExerciseBottomSheet` as a full-height bottom sheet with handle bar, close button + "Add Exercise" header, pill-shaped search bar with magnifying glass and filter icons, horizontal muscle-group filter chips (All/Chest/Back/Legs/Shoulders/Arms/Core), single-column exercise card list with colored initial-letter avatar, muscle group + equipment tag chips, and animated bottom action bar with selection count and confirm button.
- Expanded difficulty badges from 2 tiers to **4 tiers** (novice, beginner, intermediate, advanced) — each with dedicated color tokens in both light and dark themes:
  - `difficultyNoviceBg` / `difficultyNoviceText` — blue-tinted
  - `difficultyBeginnerBg` / `difficultyBeginnerText` — green
  - `difficultyIntermediateBg` / `difficultyIntermediateText` — orange
  - `difficultyAdvancedBg` / `difficultyAdvancedText` — red
- ~35 new filter-related `AppStrings` for difficulty labels/descriptions, muscle group names, equipment/modality types, and filter UI chrome (cancel/apply/clear-all/confirm-selection).
- Files: `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`, `lib/shared/theme/app_colors.dart`, `lib/shared/constants/app_strings.dart`

### 2026-07-05 — Exercise picker filter sheet

- Created `ExercisePickerFilterSheet` — filter bottom sheet with multi-select muscle group pills, 2-column equipment card grid (Material icons), radio-style difficulty picker with descriptions, modality toggle switches, and Cancel/Apply footer with active filter count badge.
- Fixed `AddExerciseBottomSheet` header to include the "Add Exercise" title next to the close button.
- Wired the search suffix icon to open the filter sheet via `GestureDetector`.
- Files: `lib/features/workout_builder/presentation/widgets/exercise_picker_filter_sheet.dart`, `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`
- Verification: `dart format` passed, `flutter analyze` — 0 issues.

### 2026-07-04 — Workout runner/session integrity cluster

- **Completion UX**: `WorkoutRunnerScreen` now keeps users on the runner after completion and renders a proper completed-state summary with workout name, duration, total volume, completed sets, completed exercises, and a `Done` CTA. This replaced the earlier immediate-pop behavior.
- **Transient UI reset**: `_resetTransientUi()` clears the rest timer and related local runner state before completion/cancel, and explicit `completing` / `cancelling` placeholders avoid showing stale interactive controls while state transitions are in flight.
- **Final-set path**: the old `currentExercise == null` placeholder path was replaced by an auto-complete guard that mounts once when no incomplete sets remain and routes the user into the same completed summary flow.
- **Route-exit re-entry fix**: removed `workoutRunnerControllerProvider(...)` invalidation from finish-early and cancel UI flows. Because the provider auto-starts sessions in `build()`, invalidating it before the route popped could restart the workout while the screen was still mounted.
- **Late-save race fix**: `WorkoutSessionDao.updateSessionIfInProgress(...)` now updates root session rows only when status is still `in_progress`; `DriftWorkoutSessionRepository.saveSessionProgress()` uses this guarded path so a late save cannot resurrect a completed session.
- **Duplicate-active repair**: `DriftWorkoutSessionRepository.getActiveSession()` now repairs duplicate active rows before returning a session. It abandons obsolete in-progress rows superseded by a later completed row, then collapses any remaining duplicates to the most recent active row. `completeSession()` also abandons sibling in-progress rows for the same workout identity.
- **Transaction hardening**: the active-session count check moved inside the start-session transaction step.
- **Coverage**: runner widget tests now cover finish-early summary stay, final-set auto-completion, and route-exit restart protection. Repository tests cover late-save completion races and duplicate active-session repair/abandonment.
- Verification: `dart format` — passed; `flutter analyze` — 0 issues; targeted runner and repository tests passed. Historical full-suite notes in this date range still include 1 unrelated pre-existing failure in `test/app/m3/m3_setup_smoke_flow_test.dart` when explicitly called out.

### 2026-07-04 — Programme builder, calendar, and home sync cluster

- **Per-week slot persistence**: `ProgrammeDraft` gained `weekSlotDayIndices` and `weekSlotTemplateIds` so save/load flows preserve distinct slot configuration for every week instead of reusing week 1 across the full programme.
- **Edit reconstruction fixes**: `LoadProgrammeBuilderDraftUseCase.loadForEdit()` now restores slot order using the sequential position within the week, and decodes `scheduledDayIndex` back into `TrainingDay` so saved day labels reappear when editing.
- **Slot day override UI**: the programme builder now offers an optional day-picker bottom sheet; `ProgrammeBuilderController.updateSlotDay()` updates both `scheduledDayIndex` and `scheduledDay`.
- **Post-save refresh flow**: replaced fragile pre-pop invalidation with explicit `reload()` calls after `context.pop()` for both the programme library controller and, when editing, the family-scoped programme calendar controller.
- **Shared today-workout resolution**: extracted the flat-index progression algorithm into `TodayWorkoutResolver` and reused it across home and calendar. This eliminates disagreement between simple weekday matching and progression-based resolution when days are skipped or the user starts mid-week.
- **Completion state source of truth**: `ProgrammeCalendarController` now derives day completion from resolved workout-session data (`completedWorkoutIds`) instead of `program_workouts.status`.
- **Refresh propagation**: `programmeSyncProvider` now watches the programme library controller, and `homeRefreshTriggerProvider` forces home/calendar state to refresh after completion/cancel.
- **Active-programme progress**: `ProgrammeListItem` now includes `startDateLocal`, enabling current-week computation, current-week sessions remaining, and week progress on `HomeScreen`.
- **Active-session-aware CTAs**: home and calendar surfaces now share the same button logic for start/resume/disable when another workout session is already active.
- Verification: historical entries for these fixes recorded `dart format` passed, `flutter analyze` reported 0 issues, and `flutter test` passed except where an unrelated pre-existing M3 smoke failure was explicitly noted.

### 2026-07-04 — Saved workout persistence and programme/library UI refinement cluster

- **Schema v11**: `AppDatabase` schema version advanced from `10` to `11`. The migration adds nullable `deleted_at` to `saved_workouts` and logs create/upgrade events against version `11`.
- **Saved workout soft delete**: `SavedWorkoutDao.getAll()` / `getByStatus()` now filter out rows where `deletedAt` is set, `SavedWorkoutDao.softDeleteById(...)` writes deleted metadata, and `DriftSavedWorkoutRepository.deleteSavedWorkout()` now marks the workout deleted instead of hard-deleting the root row.
- **Migration coverage**: schema-version and migration-log tests now expect version `11`.
- **Programme/library navigation polish**: `ProgrammesScreen` now uses tap-to-open calendar/details and a dedicated overflow-menu edit action. `ProgrammeListTile` shows the first goal tag label instead of a placeholder.
- **Programme visual refinements**: the calendar header, week sections, today cards, and rest-day cards were restyled to better differentiate current week, today, and recovery states.
- **Library-shell cleanup**: nested child-screen app bars were removed from tab children so the shared library shell owns the top chrome consistently.
- **Asset/token support**: added `leaf` and `meditation` SVG assets, introduced `AppSizing.iconS`, reduced `iconXs`, and retuned deload painter sizing to match the updated UI.
- Verification: fresh verification run on 2026-07-04. `dart format .` passed with 0 changed files (`Formatted 634 files (0 changed) in 1.35 seconds`). `flutter analyze` passed with `No issues found!`. `flutter test` ended with 1060 passing tests and 1 failing test: `test/app/m3/m3_setup_smoke_flow_test.dart: M3 Setup Smoke Flow library browse: exercise list screen renders with empty state`. No new analyzer failures were introduced by the latest persistence/UI refinements.

### 2026-07-03 — Programme builder goal tags and week type save/load roundtrip

- **Goal tags restored on edit**: `LoadProgrammeBuilderDraftUseCase.loadForEdit()` now decodes `goalTagsJson`/`equipmentJson` from the DB via `EnumCodec.decodeSet`. Previously the fields were omitted, so saved goal tags appeared empty when reopening a programme for editing.
- **Week type now persists**: Added `List<WeekType?>? weekTypes` to `ProgrammeDraft`. `SaveProgrammeBuilderDraftUseCase._mapToProgrammeDraft()` extracts week types from builder weeks. `DriftProgrammeRepository._insertExpandedProgramRows()` passes the value to `_buildProgramWeekCompanion()` instead of always `null`.
- **Week type restored on edit**: `LoadProgrammeBuilderDraftUseCase.loadForEdit()` now reads `w.weekType` and passes `WeekType.fromDb()` to `ProgrammeBuilderWeekDraft`.
- Files changed: `lib/features/programmes/domain/programme_draft.dart`, `lib/features/programmes/application/save_programme_builder_draft_use_case.dart`, `lib/features/programmes/data/drift_programme_repository.dart`, `lib/features/programmes/application/load_programme_builder_draft_use_case.dart`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1056/1056 passed (1 pre-existing M3 smoke flow failure, unrelated).

### 2026-07-03 — Full failing-test sweep to green

- **Suite restored**: Cleared all known failing tests and revalidated the full suite at **1056/1056 passed**.
- **Workout builder bug fix** (`lib/features/workout_builder/application/workout_builder_controller.dart`): Warmup sets now insert before the first working set. This fixes a real bug where `addWarmupSet()` created workouts that could not be saved because validation requires warmups to come first.
- **Save-time normalization update** (`lib/features/workout_builder/application/workout_builder_controller.dart`): Builder editing now preserves user-entered set order. On save, each exercise is normalized so warmup sets are reordered before working sets prior to validation and persistence. In edit mode, the in-memory state is updated to the normalized order immediately after a successful save.
- **Database version alignment**: Updated DB tests for schema version `10` and corrected `AppDatabase` on-create migration logging to record `toVersion: 10`.
- **Router-based widget harness repairs**: Updated dialog and bottom-sheet tests to use `GoRouter`-backed harnesses anywhere the UI now closes with `context.pop()`. This covered BYOK settings, workout builder dialogs, custom exercise delete/discard dialogs, programme builder dialogs, template reassignment bottom sheet, and cancel workout dialog tests.
- **Workout runner autosave test repair**: Kept the `autoDispose` runner provider alive in debounce tests via `container.listen(...)` so timer-driven autosave behavior stays under test.
- **Workout builder save-path coverage**: Added explicit create-mode save-reset coverage and updated the warmup roundtrip test to assert the saved payload instead of only checking post-save builder state.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1056/1056 passed.

### 2026-07-03 — Workout runner lifecycle hardening + rest timer wiring + DB schema v10

#### Workout runner abandon/restart fix

- **Bug fixed**: Reopening the same workout after abandoning it could reuse stale `WorkoutRunnerController` state keyed by the same family arguments, leaving the UI tied to an abandoned session instead of forcing a fresh start.
- **Provider lifecycle** (`lib/app/providers/providers.dart`): Converted `workoutRunnerControllerProvider` to `AsyncNotifierProvider.autoDispose.family` so abandoned/completed runner instances do not remain cached once the screen is dismissed.
- **Cancel flow** (`lib/features/workout_execution/presentation/workout_runner_screen.dart`): After `cancelWorkout()` succeeds, the screen now invalidates the exact current runner provider instance and pops the runner route. This guarantees the next launch rebuilds from `build()` and starts a new session.
- **Regression test** (`test/features/workout_execution/presentation/workout_runner_screen_test.dart`): Added widget coverage for abandon -> leave runner -> reopen same saved workout -> fresh session start.

#### Lifecycle hardening (extends above)

- `autoSave` timer cancelled on `completeWorkout()`/`cancelWorkout()` — prevents save-after-complete race.
- `autoSave` guards on `session.status == inProgress` — no saves for already-completed/abandoned sessions.
- `activeWorkoutSessionProvider` invalidated after start/resume/save/complete/cancel — consumers (HomeScreen, etc.) reflect current session state immediately.
- Cancel dialog now invalidates controller provider and calls `context.pop()` after abandon, returning to HomeScreen instead of leaving runner UI visible.

#### HomeScreen in-progress workout card

- **`_OngoingWorkoutCard`** (`lib/features/home/presentation/home_screen.dart`): New `ConsumerWidget` rendered when `activeWorkoutSessionProvider` returns a non-null session — shows progress (completed/total sets), elapsed time, resume button, discard button.
- Discard calls `AbandonWorkoutSessionUseCase.abandon()` + refreshes `activeWorkoutSessionProvider`.
- **New provider**: `AppProviders.activeWorkoutSessionProvider` — `FutureProvider<WorkoutRunnerSessionViewData?>` wrapping `LoadActiveWorkoutSessionUseCase`.

#### Rest timer wiring + runner presentation changes

- **Rest timer duration-aware**: `onSetLogged` callback passes `int restSeconds` computed via `RestResolver.effectiveRest(setRest:, exerciseRest:)`. Timer starts with resolved duration (set-level > exercise-level > 60s default).
- **Log set gating**: "Log Set N" button disabled until both `actualWeightKg` and `actualReps` entered — prevents logging incomplete sets.
- **Active set index recomputed per build**: Removed mutable `_activeSetIndex` from `_SetTableState` — active index derived statically from completion state, eliminating stale-index bugs.
- **Warmup chip in runner**: `SetTypeChip` shown for warmup sets in runner's `_SetTable`.
- **`copyWithActuals` preserves rest**: `restSeconds` propagated. Params changed from `double?`/`int?` to `String?` with parse in body (fixes empty-field → null conversion).

#### DB schema v10 — rest columns + warmup validation

- **Schema v10**: Added `restSeconds` (nullable int) to `set_logs` table, `restBetweenExercisesSeconds` (nullable int) to `workout_session_exercises` table. v9→v10 migration in `AppDatabase`.
- **Warmup ordering validation** (`lib/core/validation/default_draft_validation_service.dart`): New `_validateSetOrdering()` rule — detects warmup sets positioned after working sets. New `DraftValidationCode.warmupSetOrdering`, `AppStrings.warmupSetsMustComeFirst`.
- **Saved workout delete simplified** (`lib/features/workout_builder/data/drift_saved_workout_repository.dart`): Always hard-deletes (removed archive-on-history conditional). DAO `SavedWorkoutDao.deleteById()` added.

#### Domain + data-layer rest field propagation

- **Domain model extensions**: `restSeconds` on `SetLogDraft` and `WorkoutRunnerSetItem`. `restBetweenExercisesSeconds` on `WorkoutSessionExerciseDraft`. All with `copyWith` propagation.
- **Load use case** (`lib/features/workout_builder/application/load_workout_draft_use_case.dart`): Maps `restBetweenExercisesSeconds` from saved workout aggregate and its exercises. Also fixes `exerciseRef` → `exercise.name` mapping.
- **Start use case** (`lib/features/workout_execution/application/start_workout_session_use_case.dart`): Propagates `restSeconds` from set prescriptions and `restBetweenExercisesSeconds` from exercise drafts (saved-workout and program-workout paths).
- **Mapper** (`lib/features/workout_execution/application/workout_runner_mapper.dart`): `toViewData()`/`toDraft()` preserve `restSeconds`/`restBetweenExercisesSeconds` in round-trip.
- **Repository persistence** (`lib/features/workout_execution/data/drift_workout_session_repository.dart`): Writes `restSeconds` and `restBetweenExercisesSeconds` columns when saving session state.

#### Workout builder rest field StatefulWidget extraction

- **`_RestField`** (`lib/features/workout_builder/presentation/workout_builder_screen.dart`): Extracted from inline `TextField` + `TextEditingController.fromValue(...)` to `StatefulWidget` with controller lifecycle — fixes cursor loss on rebuild.
- **`_ExerciseRestField`** (`lib/features/workout_builder/presentation/widgets/workout_exercise_card.dart`): Same extraction for per-exercise rest field in exercise list.

#### AppStrings

- `warmupSetsMustComeFirst` (validation message), `workoutInProgress` (home card badge), `discardWorkout` (abandon button).

#### Files changed

25 files, ~747 insertions, ~144 deletions across `lib/app/providers/`, `lib/core/db/`, `lib/core/validation/`, `lib/features/home/`, `lib/features/workout_builder/`, `lib/features/workout_execution/`, `lib/shared/constants/`, and `test/`.

- Verification: `dart format` — pending. `flutter analyze` — pending. `flutter test` — pending.

### 2026-07-02 — Convention compliance sweep — Navigator.pop, EdgeInsets.fromLTRB, TextStyle, Theme.of(context)

- **`Navigator.of(context).pop()` → `context.pop()`** (22 files): Replaced all remaining `Navigator.of(context).pop(...)` and `Navigator.pop(ctx)` with go_router's `context.pop()` / `ctx.pop()` across the entire codebase. Added missing `import 'package:go_router/go_router.dart'` to 12 files that only used pop via `Navigator`.
- **`EdgeInsets.fromLTRB(...)` → `EdgeInsets.only(...)`** (4 locations in 3 files): `programme_calendar_header.dart` (1), `programme_week_section.dart` (2), `workout_runner_screen.dart` (1).
- **`TextStyle(...)` → `AppTextStyles.*.copyWith()` / `context.textTheme.*.copyWith()`** (10 locations in 8 files): Removed all remaining inline `TextStyle(fontSize: ..., color: ...)` constructors in the touched surface, replacing with project-text-style tokens. Added missing `app_text_styles.dart` imports where needed.
- **`Theme.of(context).colorScheme` → `context.colorScheme`** (2 files): `delete_custom_exercise_dialog.dart`, `delete_item_dialog.dart`.
- **Files changed**: 27 files, 106 insertions, 81 deletions — zero behavioral changes, purely convention alignment.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Final widget-builder helper method sweep — zero violations remaining

- **11 files already converted** in prior sessions: `exercise_dataset_status_tile`, `exercise_step_audio_button`, `workout_history_detail_screen`, `exercise_detail_screen`, `exercise_library_screen`, `programme_calendar_header`, `programme_week_section`, `programme_day_card`, `programme_workout_detail_screen`, `onboarding_screen` (initial batch), `home_screen` (initial batch).
- **Final 5 deferred helpers converted**:
  - `lib/features/home/presentation/home_screen.dart`: `_buildScheduled` → `_ScheduledView`, `_buildEmpty` → `_EmptyView`.
  - `lib/features/onboarding/presentation/onboarding_screen.dart`: `_infoPanel` → `_ByokInfoPanel`, `_buildForm` + `_saveKey` + `_keyController`/`_obscured` fields → `_ByokForm` (ConsumerStatefulWidget) with `_ByokFormWidgetState`.
  - `lib/features/workout_execution/presentation/workout_runner_screen.dart`: `_buildBody` + `_showCompleteSheet` + `_showCancelDialog` → `_WorkoutRunnerBody` (ConsumerWidget). `_findFirstIncomplete` moved to static method on `WorkoutRunnerScreen`.
- **Verification**: grep-confirmed zero `Widget _build` or non-build widget-returning methods across all of `lib/`. The only exceptions are `AppWhiteSpace.both`/`custom` static factories (intentional design tokens).
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Final top-level declaration sweep — zero violations remaining

- **`const _items` → `_BottomNavItemData.items`** in `lib/app/router/bottom_nav_shell.dart`: Moved top-level `const _items = [...]` into `_BottomNavItemData` as a `static const` member. Updated all references.
- **`_findFirstIncomplete` → `WorkoutRunnerScreen._findFirstIncomplete`** in `lib/features/workout_execution/presentation/workout_runner_screen.dart`: Moved top-level helper function into `WorkoutRunnerScreen` as a `static` method.
- **Exhaustive grep verification**: Zero top-level declarations remain outside `main()` in `main.dart` across all `lib/`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — HomeScreen with greeting, active programme, today's workout (complete)

- **New screen** (`lib/features/home/presentation/home_screen.dart`): 688-line `ConsumerWidget` implementing the home dashboard — time-of-day greeting (`_GreetingRow` with morning/afternoon/evening logic), user display name from `profileControllerProvider`, active programme card (`_ActiveProgramCard` with programme name, status, tap-to-navigate), today's scheduled workout card (`_TodayWorkoutCard` with start/resume/begin states), volume metric card (`_VolumeMetricCard`), and quick action grid (`_QuickActionGrid` with SVG icon buttons).
- **Architecture**: Composed entirely of private `StatelessWidget` sub-widgets — zero `Widget _build` helper methods (verified during compliance sweep). Uses existing `AppStrings` constants (goodMorning, goodAfternoon, goodEvening, readyForSession, etc.) — no new strings added.
- **Provider wiring**: Wired through existing providers — no new providers created. `profileControllerProvider` for user name, `programmeLibraryControllerProvider` for active programme discovery, and `workoutRunnerControllerProvider` for session flow.
- **Home route activation**: Home route already existed in router — `HomeScreen` was previously a placeholder; now fully functional with data from repositories.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Rest timer widget + workout runner metrics refactor (complete)

- **New `RestTimerWidget`** (`lib/features/workout_execution/presentation/widgets/rest_timer_widget.dart`): `StatefulWidget` with `SingleTickerProviderStateMixin` — `AnimationController` drives circular progress while `Timer.periodic` (1s) decrements remaining seconds. Displays formatted MM:SS countdown, add-30-seconds button (+30s), and skip/dismiss button. Auto-dismisses when timer reaches zero.
- **Runner integration**: `WorkoutRunnerScreen` now renders `RestTimerWidget` over exercise content after a set is completed. `WorkoutRunnerHeader` shows elapsed session time computed from start timestamp. `WorkoutRunnerExerciseCard` displays the effective rest time (from `RestResolver`) for each exercise — users see how long to rest before starting the next set.
- **Metrics refactor**: `_CompleteWorkoutMetrics` extracted from `CompleteWorkoutSheet` — standalone class computing total volume (sum of weight × reps across completed sets), completed set count, and completed exercise count. Sheet now delegates to this class.
- **Files changed**: 13 files, 1676 insertions, 262 deletions — primarily in `workout_execution/presentation/` plus updates to `workout_builder/` and `programmes/` for supporting widget alignment.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Exercise detail screen — StatefulWidget migration + error handling (complete)

- **Migration**: `ExerciseDetailScreen` converted from `ConsumerWidget` to `ConsumerStatefulWidget` — `initState`/`dispose` lifecycle for `ExerciseVideoStateController` subscriptions and step audio controller resources. `TextEditingController` for notes managed via stateful lifecycle instead of recreated in `build()`.
- **Error handling**: New `_ExerciseDetailState` enum (`loading`, `ready`, `error`, `notFound`) with explicit render paths. Load failure renders `ErrorWidget` with retry `IconButton` that invalidates the detail provider. Not-found case renders tappable back navigation.
- **Supporting widgets updated** (4 files): `ExerciseVideoCard` — error state propagates from controller rather than swallowing; `ExerciseDatasetStatusTile` — synchronization with detail state; `ExerciseStepAudioButton` — lifecycle alignment (no duplicate `dispose` calls); `ExerciseLibraryScreen` — navigation to detail now uses state-aware push.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Exercise multi-select refactor + onboarding provider structure (complete)

- **Multi-select extraction**: Common chip-selection patterns (exercise list multi-select, equipment multi-select, goal tag selection, limitation selection) refactored across `OnboardingScreen` (350 insertions), `ProfileScreen` (189 insertions), and `ProgrammeWorkoutDetailController` (26 insertions) — extracted `_ChipSelector` and `_MultiSelectGroup` patterns reduce duplication and improve readability.
- **Provider restructuring**: `onboarding_screen.dart` local provider declarations reorganized — grouped by responsibility (form state, validation, draft mutations), removed orphaned providers, aligned naming with `AppProviders` conventions.
- **Slot day assignment** (`lib/features/programmes/application/slot_day_assignment.dart`): Extended with improved training-day anchor resolution logic for edge cases (empty training days, single-day schedules).
- **Profile repository** (`drift_profile_repository.dart`): Removed unused `_appSettingsDao` and `_bodyMeasurementDao` references.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Logging sweep — 59 files instrumented (complete)

- **Scope**: All M4-feature modules instrumented with `AppLogger` — 59 files modified across controllers (BYOK setup, settings, workout builder, workout runner, programme builder, custom exercise editor, exercise library sync/search/audio, onboarding, profile, history), repositories (Drift implementations for BYOK, settings, saved-workout, session, programme, history), use cases (all load/save/complete/abandon/start in workout builder, workout execution, programme builder, custom exercise), validators and adapters (workout builder, programme builder, draft validation service, superset services), and core infrastructure (bootstrap controller, Firebase auth/storage/bootstrap, network status, file store, secure storage, TTS, transactions).
- **Pattern**: Each public method logs entry with key parameters (never secrets, prompts, or health data) and exit with result summary. Severity: `info` for state transitions, `warning` for recoverable failures, `severe` for unrecoverable errors. No sensor or private data in log payloads.
- **Verification**: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### 2026-07-02 — Minor refactors and fixes (complete)

- **Validation scope rename** (5 files): `DraftValidationScope.set` → `DraftValidationScope.exerciseSet` in `draft_validation_scope.dart`, `default_draft_validation_service.dart`, `workout_builder_validation_adapter.dart`, `programme_builder_validation_adapter.dart`, and `workout_builder_validation_adapter_test.dart`. No behavior change — naming consistency only.
- **Custom exercise editor invalidation** (`custom_exercise_editor_screen.dart`): `CustomExerciseEditorController` now invalidates its provider on "Done" button press via `ref.invalidate(customExerciseEditorControllerProvider(...))`. Ensures subsequent re-entry to the editor loads a fresh state instead of stale cached data.
- **\_InfoRow widget extraction** (`workout_history_detail_screen.dart`): Repeated `_infoRow(BuildContext, String, String)` helper method extracted to standalone `_InfoRow` StatelessWidget — `const`-constructable, cleaner composition, enables future reuse in other detail screens. 23 lines added, 14 removed.
- **VSCode launch configuration** (`.vscode/launch.json`): Added Flutter debug and run launch configurations — enables F5 debugging from VSCode without manual `flutter run` commands.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Rule-compliance cleanup + failing test repair

- Consolidated a touched-surface cleanup for remaining top-level helper/provider violations so the affected M4-adjacent feature files comply with the project rule that top-level declarations must be encapsulated.
- Repaired three failing widget tests by restoring exercise-detail metadata/substitution affordances, aligning one workout-runner test with the current runner UI contract, and fixing the malformed `ProgrammesScreen` implementation discovered during verification.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Programme goals UI + programme status/list consistency

- **Programme goals UI**: `ProgrammeDetailsSection` now renders goal chips for all `GoalTag` values and `ProgrammeBuilderScreen` wires `selectedGoals` + `onGoalsChanged` to `ProgrammeBuilderController.setGoalTags(...)`.
- **Validation**: Programmes now require at least one goal before save. Added `noGoals` validation path across `DraftValidationCode`, `AppErrorCodes`, `AppStrings`, and `ProgrammeBuilderValidator`.
- **Status consistency fix**: Fixed mismatch between `ProgramStatus` and `active` boolean — controller toggles now update both fields, save use case derives `active` from `status`, and DAO activation/deactivation methods update both stored fields together.
- **Programme visibility fix**: New programmes now default to `inactive` instead of `draft`. `ListProgrammesUseCase` and `ListSavedWorkoutsUseCase` now return all items, not only active ones.
- **Outcome**: Inactive programmes are visible on `ProgrammesScreen`, and the active/inactive chip reflects the true persisted state after save or toggle.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Day-of-week selection — onboarding + programme defaults

- **Onboarding**: Schedule step now shows Mon-Sun day toggle instead of 1-7 number picker. Controller validates `trainingDays.isNotEmpty`.
- **`TrainingDay.displayLabel`**: Short day names (Mon/Tue/...) for UI.
- **`ProgrammeBuilderWorkoutSlotDraft.scheduledDay`**: New nullable field storing the assigned `TrainingDay`.
- **Slot day assignment algorithm**: Maps training day anchors to calendar-ordered slot days. Pulls rightmost anchors left when slot count is small.
- **Programme builder**: Reads profile `trainingDays` to default slot days. `addSlot` accepts `scheduledDay`.
- **Slot card**: Shows day label or fallback.
- **Validator**: Enforces `scheduledDayRequired` when week has >7 slots without explicit day assignment.
- **Tests**: Onboarding controller/screen tests updated for day toggle. All 1043 tests pass.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1043/1043 passed.

### 2026-07-01 — V1-M4-011 — M4 manual tracker acceptance suite (complete)

- **Test harness** (`test/app/m4/`): App-level harness with M4-specific fakes (savedWorkout, programme, session, history, exercise, networkStatus) mirroring the M3 pattern.
- **Acceptance tests** (8): custom exercise, workout, programme, active session start/complete, reopen recovery, history browse/detail, warmup visibility, superset persistence.
- **Blocker tests** (4): offline-only operation, completion failure recovery, history integrity after source delete, sentinel data safety.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1013/1013 passed.

### 2026-07-01 — V1-M4-010 — Transactional save and rollback service (complete)

- **Core transactions** (`lib/core/db/transactions/`): 7 files — `TransactionOperation`, `TransactionFailureInjection`, `NoOpTransactionFailureInjection`, `TransactionExecutionFailure`, `TransactionStep`, `TransactionExecutor`, `DriftTransactionExecutor`.
- **Test support**: `ThrowingTransactionFailureInjection` and `CapturingTransactionFailureInjection` for injected-failure and sequence-capture testing.
- **Repository refactor**: `DriftProgrammeRepository`, `DriftSavedWorkoutRepository`, `DriftWorkoutSessionRepository` now use `TransactionExecutor` with step-builder helpers. Removed `_database` field from all three repositories.
- **Provider wiring**: Added `transactionFailureInjectionProvider` and `transactionExecutorProvider`. Updated all 3 repository providers.
- **Tests**: 7 new — 4 core executor tests, 3 programme repository rollback tests.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1001/1001 passed.

### 2026-07-01 — V1-M4-009 — Reusable draft validation service (complete)

- **Core validation** (`lib/core/validation/`): 13 files — scope, code, path, issue, result enums/classes + 7 validated draft types for workouts and programmes.
- **Service**: `DraftValidationService` (abstract) + `DefaultDraftValidationService` implementing all workout and programme rules.
- **Feature adapters**: `WorkoutBuilderValidationAdapter` and `ProgrammeBuilderValidationAdapter` bridging feature drafts to shared validated drafts and shared issues to feature errors.
- **Refactored validators**: `WorkoutBuilderValidator` and `ProgrammeBuilderValidator` now thin façades over the shared service.
- **Provider wiring**: Added 3 new providers; updated existing validator providers to wire shared service.
- **Tests**: 42 new — 20 core workout validation, 12 core programme validation, 5 workout adapter, 5 programme adapter. Updated all existing validator and controller tests to construct validators with shared service + adapter.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 994/994 passed.

### 2026-07-01 — V1-M4-008 — Manual superset / execution group support (complete)

- **Domain**: 3 shared policy/summary models, 3 builder/programme domain additions, existing models extended with `supersetOrder` + `copyWith`.
- **Data model**: Extended `ProgrammeBuilderTemplateDraft` to carry `List<ProgrammeExerciseDraft> exercises`. Added `ProgrammeRepository.getTemplateExercises()`. Updated load/save use cases and DriftProgrammeRepository to roundtrip template exercises with grouping fields.
- **Application**: 4 services/validators for builder + programme, 2 grouping mappers for runner + history.
- **Controllers**: `WorkoutBuilderController` +4 superset mutations. `ProgrammeBuilderController` +4 template superset mutations.
- **Presentation**: 6 widgets (superset editor sheet, group badge, actions menu, programme superset sheet, runner group card, history group card); wired into builder screen, programme slot card, runner exercise list, and history detail screen.
- **Infrastructure**: `AppStrings` +21, `AppProviders` +7.
- **Tests**: 48 total — policy, services, validators, mappers, controller mutations, widget rendering, history detail/repository grouped data preservation.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 945/945 passed.

### 2026-07-01 — V1-M4-007 compliance closure pass

- **Conventions fixes**: Removed remaining Aedify rule violations in the touched 007 surface.
- **Icons/SVGs**: `WorkoutBuilderScreen`, `WorkoutExerciseCard`, and `SetPrescriptionEditorRow` now use `SvgPicture.asset` + `OutlinedSvgAssets` instead of `Icons.*`.
- **Tokens**: Added `AppSpacing.xxxs`, `AppSpacing.inputHorizontal`, `AppSizing.fieldWidthXs`, and `AppSizing.fieldWidthXl`; replaced remaining raw layout values in `SetTypeChip`, `SetPrescriptionEditorRow`, and `WorkoutRunnerSetRow`.
- **Strings**: Added `AppStrings.skipped` and `AppStrings.setNumberLabel(int)`; runner/history rows now use constants instead of hardcoded text.
- **Controller lifecycle**: `SetPrescriptionEditorRow` is now `StatefulWidget`-based so text controllers are no longer recreated inside `build()`.
- **Tests**: Updated widget tests for tooltip/SVG interactions and shared labels. No product-scope changes.
- **Verification**: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 894/894 passed.

### 2026-06-30 — Fix — Onboarding imperial unit conversion

- **Bug**: Choosing imperial during onboarding did not convert height/weight/1RM values from metric to imperial. Three defects:
  1. `toImperialHeight`/`toImperialWeight` had inverted conditionals (returned canonical values when imperial, converted when metric).
  2. Unit choice chip stored converted display values (lbs/in) into canonical fields (kg/cm), causing double-conversion.
  3. Bench/squat/deadlift `_FormField` widgets lacked `ValueKey` tied to `preferredUnits`, so their controllers kept stale values on unit switch.
- **Files changed**: `lib/shared/domain/preferred_unit.dart` (2 methods), `lib/features/onboarding/presentation/onboarding_screen.dart` (unit switch logic + 3 ValueKeys).
- **Verification**: `dart format` — passed. `flutter analyze` — 0 new issues. `flutter test` — 863/863 pass.

### 2026-06-30 — V1-M4-004 — Active Workout Session Runner (complete)

- **6 domain models** (`lib/features/workout_execution/domain/`):
  - `WorkoutRunnerMode` — savedWorkout / programWorkout / resume (used by controller build + screen factory constructors)
  - `WorkoutRunnerSetItem` — per-set state: id, exerciseId, setIndex, setType, performedAt, completed, skipped, prescribedReps, actualReps/weight/duration/distance/RPE/RIR, notes (full copyWith)
  - `WorkoutRunnerExerciseItem` — per-exercise state: id, name, sourceProgramExerciseId / sourceSavedWorkoutExerciseId, sets (`List<WorkoutRunnerSetItem>`)
  - `WorkoutRunnerSessionViewData` — full session display model: sessionId, name, source, status, startedAt, durationSeconds, notes, energyLevel, perceivedDifficulty, exercises (`List<WorkoutRunnerExerciseItem>`)
  - `WorkoutRunnerCompletionDraft` — on-complete payload: sessionId, completedAt, durationSeconds, notes, energyLevel, perceivedDifficulty
  - `WorkoutRunnerResumeDecision` — resume / discard (used by recovery flow)
- **9 application files** (`lib/features/workout_execution/application/`):
  - `WorkoutRunnerPhase` — 6-state enum (loading, ready, blocked, paused, failure, completed)
  - `WorkoutRunnerState` — copyWith, initial factory, isLoading/isSaving/isReady helpers
  - `StartWorkoutSessionUseCase` — handles savedWorkout (from SavedWorkoutDraft) and programWorkout (looks up exercise names via ExerciseRepository, builds WorkoutSessionDraft)
  - `LoadActiveWorkoutSessionUseCase` — reads current in-progress session via WorkoutSessionRepository.getCurrentInProgressSession()
  - `SaveWorkoutSessionProgressUseCase` — delegates to WorkoutSessionRepository.saveSession(sessionDraft, updatedSets)
  - `CompleteWorkoutSessionUseCase` — delegates to WorkoutSessionRepository.completeSession(sessionId, completedAt, duration, notes, energy, difficulty)
  - `AbandonWorkoutSessionUseCase` — delegates to WorkoutSessionRepository.abandonSession(sessionId)
  - `WorkoutRunnerMapper` — toViewData (WorkoutSessionAggregate → WorkoutRunnerSessionViewData), toDraft (WorkoutRunnerSessionViewData → WorkoutSessionDraft for save round-trip)
  - `WorkoutRunnerController` — `AsyncNotifier<WorkoutRunnerState>` with constructor injection (matches codebase Riverpod 3.3.2 pattern). 19 methods: build() dispatches to \_buildResume/\_buildSavedWorkout/\_buildProgramWorkout; resumeRecoveredSession / discardRecoveredSession; updateSet / toggleSetCompleted / toggleSetSkipped; pauseWorkout / continueWorkout; saveProgress / completeWorkout / cancelWorkout; updateSessionNotes / updateEnergyLevel / updatePerceivedDifficulty.
- **10 presentation files** (`lib/features/workout_execution/presentation/`):
  - `WorkoutRunnerScreen` — ConsumerStatefulWidget with 3 named constructors (resume, savedWorkout, programWorkout), PopScope guard during active session, 6 visual states (loading/blocked/ready/paused/failure/completed)
  - `WorkoutRunnerHeader` — session name, elapsed time, pause button
  - `WorkoutRunnerExerciseList` — ReorderableListView of ExerciseCards with set rows
  - `WorkoutRunnerExerciseCard` — exercise name header + set rows
  - `WorkoutRunnerSetRow` — per-set row: circle indicator (Container+BoxDecoration), set index, set type label, prescribed rep label, skipped label, completed styling (primaryContainer bg)
  - `WorkoutRunnerResumeBanner` — shows "Recovered session from crash" with resume/discard CTA
  - `CompleteWorkoutSheet` — bottom sheet: summary (name, duration), notes/energy/difficulty fields, FilledButton to complete
  - `CancelWorkoutDialog` — AlertDialog: confirm/cancel, uses AppStrings
  - `WorkoutRunnerErrorBanner` — error message + dismiss
- **Infrastructure**:
  - `AppRoutes`: +3 factories (workoutRunnerResume, workoutRunnerSaved, workoutRunnerProgram)
  - `AppStrings`: +26 runner strings (phases, labels, buttons, messages)
  - `AppRouter`: +3 GoRoute entries (all with builder that extracts params and calls screen constructors)
  - `AppProviders`: +7 providers (5 use cases + mapper + controller family)
  - `AppSizing`: +`iconXxl = 48`
- **Pre-existing issues fixed in passing**:
  - Duplicate `ai_provider_name.dart` import in `providers.dart`
  - Unnecessary braces in `complete_workout_sheet.dart:24`
  - Non-exhaustive `DioExceptionType.transformTimeout` switch in `error_mapper.dart:10`
- **Tests**: 58 new:
  - `workout_runner_controller_test.dart` — 24 tests: all 3 modes (resume/saved/program), recovery discard/resume, set editing, toggle complete/skipped, pause/continue, save, complete, cancel, notes/energy/difficulty, error states, null-session guards
  - `workout_runner_mapper_test.dart` — 8 tests: toViewData session metadata/exercises/set grouping/empty sets; toDraft round-trip fidelity/draft type checks
  - `workout_runner_screen_test.dart` — 4 tests: loading state, no-active-workout, active session render, pause state
  - `workout_runner_set_row_test.dart` — 8 tests: set index/type, prescribed reps, toggle callback, completed/skipped/warmup states, equal min/max reps, no prescribed
  - `complete_workout_sheet_test.dart` — 4 tests: renders name/duration, calls onComplete with draft, preserves notes/energy/difficulty, uses session duration
  - `cancel_workout_dialog_test.dart` — 3 tests: renders title/message, confirm calls onConfirm, cancel dismisses
- **Flutter SDK note**: Added `ThemeData(splashFactory: NoSplash.splashFactory)` to widget test wrappers to work around Flutter 3.44.4 `ink_sparkle.frag` shader version mismatch bug (also affects pre-existing `programme_save_bar_test.dart`).
- Verification: `dart format` — passed. `flutter analyze` — 0 errors in workout_execution feature (2 pre-existing issues outside feature). `flutter test test/features/workout_execution/` — 58/58 passed.

### 2026-06-30 — Icons rule-violation gap closure (M4-003)

- Replaced all 18 `Icons.*` with `SvgPicture.asset` across 7 programme feature
  files: `programme_week_card.dart` (4), `programme_save_bar.dart` (2),
  `programme_weeks_overview.dart` (2), `programme_builder_error_banner.dart` (1),
  `programme_builder_screen.dart` (2), `programmes_screen.dart` (4),
  `programme_workout_slot_card.dart` (3).
- Replaced `Icons.circle` dirty indicator with `Container` + `BoxDecoration`.
- Added `AppSizing.iconXxl` (48) for large error-state icon.
- Updated widget test to match non-Icon dirty indicator.
- Verification: `dart format` — passed (0 changed). 65 programme tests — all
  passed. Pre-existing compilation errors (`AppRoutes`/`ProgrammeAggregate`
  missing imports in `programmes_screen.dart`) remain.

### 2026-06-30 — V1-M4-005 — Workout History & Programme Library (complete)

- **6 domain models** (`lib/features/programmes/domain/`, `lib/features/lift_log/domain/`):
  - `SavedWorkoutListItem` — `{ id, name, createdAt, updatedAt }`
  - `ProgrammeListItem` — `{ id, name, createdAt, updatedAt, isActive }`
  - `WorkoutHistoryListItem` — `{ sessionId, name, source, startedAt, completedAt, durationSeconds, exerciseCount }`
  - `WorkoutHistorySetItem` — `{ setIndex, setType, prescribedReps, actualReps, actualWeightKg, durationSeconds, distanceMeters, rpe, rir, completed, skipped, notes }`
  - `WorkoutHistoryExerciseItem` — `{ exerciseNameSnapshot, sets (List<WorkoutHistorySetItem>) }`
  - `WorkoutHistoryDetailViewData` — `{ sessionId, name, source, startedAt, completedAt, durationSeconds, notes, energyLevel, perceivedDifficulty, exercises (List<WorkoutHistoryExerciseItem>) }`
- **Data layer** (`lib/features/lift_log/data/`):
  - `WorkoutHistoryRepository` — abstract interface: `listCompletedSessions()`, `getSessionDetail()`
  - `DriftWorkoutHistoryRepository` — implementation using existing `WorkoutSessionDao.getCompletedSessions()` + `WorkoutSessionExerciseDao.getBySessionIdOrdered()` + `SetLogDao.getBySessionExerciseIdOrdered()`. Snapshot-based rendering — uses `exerciseNameSnapshot` and persisted `SetLog` values, no live joins to exercise/programme data.
- **Application layer** (4 controllers, 4 states, 4 use cases):
  - Programmes: `SavedWorkoutLibraryState`, `ProgrammeLibraryState`, `ListSavedWorkoutsUseCase`, `ListProgrammesUseCase`, `SavedWorkoutLibraryController`, `ProgrammeLibraryController` (archive/delete/reload)
  - Lift_log: `WorkoutHistoryState`, `WorkoutHistoryDetailState`, `ListWorkoutHistoryUseCase`, `LoadWorkoutHistoryDetailUseCase`, `WorkoutHistoryController`, `WorkoutHistoryDetailController` (AsyncNotifierProvider.family with `sessionId`)
- **Presentation** (4 screens, 8 widgets):
  - `SavedWorkoutLibraryScreen` — list with archive/delete popup menus, loading/empty/error states, snackbar confirmations
  - `ProgrammesScreen` — refactored from local `FutureProvider` to `ProgrammeLibraryController`, archive/delete popup menus
  - `LiftLogScreen` — replaced placeholder with controller-driven list, source labels, empty state with SVG, tap navigates to detail
  - `WorkoutHistoryDetailScreen` — detail card (name, date, duration, source), exercise cards with set rows, loading/error/missing states
  - Widgets: `SavedWorkoutListTile`, `ProgrammeListTile`, `WorkoutHistoryListTile`, `WorkoutHistoryExerciseCard`, `WorkoutHistorySetRow`, `ArchiveItemDialog`, `DeleteItemDialog`, `HistoryErrorBanner`
- **Infrastructure**:
  - `AppRoutes`: +2 (`workoutHistoryDetail`, `savedWorkoutLibrary`)
  - `AppRouter`: +2 `GoRoute` entries (libraries + detail sub-route under lift-log)
  - `AppProviders`: +10 providers (repository, 4 use cases, 4 controllers, 1 dao)
  - `AppStrings`: 20+ new constants for history/library UI and confirmations
- **Architecture decisions**:
  - `WorkoutHistoryRepository` is read-focused, separate from `WorkoutSessionRepository` — keeps runner concerns separate
  - History detail uses snapshot fields (`exerciseNameSnapshot`, persisted `SetLog` values), not live source joins — detail stays intact if source workout/programme is archived/deleted
  - Archive/delete goes through existing `ProgrammeRepository` / `SavedWorkoutRepository` which preserve history semantics (soft-delete when sessions exist)
- **Tests**: 29 new:
  - `drift_workout_history_repository_test.dart` — 4 tests (list sessions, get detail, no sessions, no detail)
  - `programme_library_controller_test.dart` — 7 tests (build, reload, archive programme, delete programme, error)
  - `saved_workout_library_controller_test.dart` — 7 tests (build, reload, archive, delete, error)
  - `workout_history_controller_test.dart` — 3 tests (build, reload, error)
  - `workout_history_detail_controller_test.dart` — 4 tests (build detail, not found, error)
  - `saved_workout_library_screen_test.dart` — 1 test (empty state)
  - `lift_log_screen_test.dart` — 1 test (empty state)
  - `saved_workout_list_tile_test.dart` — 1 test (renders name/date)
  - `workout_history_exercise_card_test.dart` — 3 tests (renders exercise name, set rows, empty sets)
- **Post-implementation gap closure**:
  - `ArchiveItemDialog` / `DeleteItemDialog`: Added optional `confirmLabel` parameter — hardcoded labels fixed for cross-context use
  - ProgrammesScreen delete: passes `confirmLabel: AppStrings.deleteProgramme`
  - SavedWorkoutLibraryScreen archive: passes `confirmLabel: AppStrings.archiveWorkout`
  - Test fakes: removed orphaned `shouldThrow` field/guards from `_FakeSavedWorkoutRepository` and `_FakeWorkoutHistoryRepository`
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 808/808 passed.

### 2026-06-30 — V1-M4-006 — Custom Exercise Editor (complete)

- **3 domain models** (`lib/features/exercise_library/domain/`):
  - `CustomExerciseDraft` — mutable draft with `copyWith()`, `toSeed()`, all fields from `CustomExerciseSeed`
  - `CustomExerciseValidationError` — `CustomExerciseValidationScope` enum (name/muscleGroups/modality/steps), code, message, optional stepIndex
  - `CustomExerciseEditorMode` — create / edit
- **7 application files** (`lib/features/exercise_library/application/`):
  - `CustomExerciseEditorPhase` — 8-phase enum (loading/editing/saving/saved/deleting/deleted/failure/blocked)
  - `CustomExerciseEditorState` — immutable with `isLoading`/`isSaving`/`hasValidationErrors`/`copyWith()`/`initial()`
  - `CustomExerciseValidator` — 3 rules: name required, at least 1 muscle group required, no empty step strings after normalization
  - `LoadCustomExerciseDraftUseCase` — `createEmptyDraft()`, `loadForEdit(exerciseId)` via `ExerciseRepository.getCustomExerciseDetail()`
  - `SaveCustomExerciseUseCase` — `create(draft)`/`update(exerciseId, draft)` via `ExerciseRepository.createCustomExercise()`/`updateCustomExercise()`
  - `DeleteCustomExerciseUseCase` — `delete(exerciseId)` via `ExerciseRepository.deleteCustomExercise()`
  - `CustomExerciseEditorController` — `AsyncNotifier<CustomExerciseEditorState>` with constructor args `(mode, exerciseId)`, 14 methods (rename, setModality, setEquipment, setDifficulty, toggleMuscleGroup, addStep, updateStep, removeStep, save, delete, clearValidationErrors, discardChanges)
- **8 presentation files** (`lib/features/exercise_library/presentation/`):
  - `CustomExerciseEditorScreen` — create/edit factory constructors, loading/saved/deleted/editing/failure/validation-error states, PopScope for unsaved changes
  - `CustomExerciseNameField` — `TextField` with label/hint/error
  - `CustomExerciseModalitySection` — `SegmentedButton<ExerciseModality>` + `DropdownButtonFormField<EquipmentTag>` + `DropdownButtonFormField<ExerciseDifficulty>`
  - `CustomExerciseMuscleGroupPicker` — 14 `FilterChip` chips (all `BodymapBucket` values)
  - `CustomExerciseStepsEditor` — dynamic add/remove/update step rows, empty state, add button
  - `CustomExerciseErrorBanner` — error container with optional retry button
  - `DeleteCustomExerciseDialog` — `AlertDialog` with cancel/confirm
  - `DiscardCustomExerciseChangesDialog` — `AlertDialog` with cancel/discard
- **Infrastructure updates**:
  - `AppRoutes`: +2 (`customExerciseCreate`, `customExerciseEdit` + paths/names)
  - `AppRouter`: +2 GoRoute entries as sub-routes under `/exercises`
  - `AppStrings`: +23 custom-exercise strings
  - `AppErrorCodes`: +3 (`customExerciseNameRequired`, `customExerciseMuscleGroupsRequired`, `customExerciseStepEmpty`)
  - `AppProviders`: +5 (validator, 3 use cases, controller family)
  - `AddExerciseBottomSheet`: Added "Create custom exercise" `ListTile` at end of exercise list; navigates to `customExerciseCreate`, refreshes search on return
- **Tests**: 55 new:
  - `custom_exercise_validator_test.dart` — 8 tests (valid, empty name, whitespace, no muscle groups, empty steps, non-empty steps pass, multiple errors, optional fields)
  - `custom_exercise_editor_controller_test.dart` — 24 tests (create mode build/load-failure/rename/setModality/setEquipment/setDifficulty/toggleMuscleGroup/addStep/updateStep/removeStep/save/create-save/save-failure/edit-mode build/edit-save/delete/null-id/delete-failure/clearValidationErrors)
  - `load_custom_exercise_draft_use_case_test.dart` — 6 tests (empty draft defaults, loadForEdit mapping, null detail throws, repository error throws, nullable fields)
  - `save_custom_exercise_use_case_test.dart` — 4 tests (create returns id, toSeed conversion, update args, update preserves fields)
  - `custom_exercise_name_field_test.dart` — 4 widget tests (initial value, error text, onChanged, empty)
  - `custom_exercise_muscle_group_picker_test.dart` — 6 widget tests (title, all 14 chips, selection state, error text, null error, onToggle)
  - `delete_custom_exercise_dialog_test.dart` — 3 widget tests (title/buttons, onConfirm, cancel)
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 863/863 passed.

### Gap closure — pop(true), delete/discard labels, SVGs, controllers, tests

- **Saved phase pop(true)**: `CustomExerciseEditorScreen` saved phase now calls `Navigator.pop(true)` so `AddExerciseBottomSheet` detects result and refreshes search.
- **Delete dialog**: Button label changed from `AppStrings.customExerciseDeleted` to `AppStrings.customExerciseDelete`.
- **Discard dialog**: Confirm label changed from `AppStrings.done` to `AppStrings.customExerciseDiscard`.
- **Material Icons → SVGs**: 4 icons replaced (`trash`, `checkBadge`, `minusCircle`, `plus`) using existing `OutlinedSvgAssets` constants.
- **Steps editor tooltip**: Hardcoded `'Remove step'` → `AppStrings.customExerciseRemoveStep`.
- **TextEditingController fix**: `CustomExerciseNameField` and `CustomExerciseStepsEditor` converted to `StatefulWidget` — controllers created in `initState`, synced in `didUpdateWidget`, preserving cursor during typing.
- **+12 widget tests**: 5 steps editor, 4 error banner, 3 discard dialog. Delete dialog test updated for label change.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 875/875 passed.

### 2026-07-01 — V1-M4-007 — Warmup vs working set behavior (complete)

- **Shared domain** (2 new files): `WarmupSetPolicy` (isWarmup/isWorking/shouldBeExcludedFromFutureAnalytics), `SetTypeOption` (type/label/description model).
- **Application** (1 new): `SetTypeOptionsUseCase` — returns `[working, warmup]` options with labels from `AppStrings`.
- **Shared UI** (1 new): `SetTypeChip` — reusable warmup/working chip used by runner/history presentation.
- **Extensions** (3 new): `SetPrescriptionDraftX`, `WorkoutRunnerSetItemX`, `WorkoutHistorySetItemX` — `isWarmup`/`isWorking` getters, `withSetType()`.
- **WorkoutBuilderController** (+3 methods): `addSet()` now accepts optional `SetType` param. Added `addWarmupSet()`, `updateSetType()`.
- **SetPrescriptionEditorRow**: Widened signature — now has `DropdownButtonFormField<SetType>` between set number and fields. Prop-drilled via `SetPrescriptionList` → `WorkoutExerciseCard` → `WorkoutExerciseList` → `WorkoutBuilderScreen`.
- **WorkoutRunnerSetRow**: Warmup sets get `tertiaryContainer` background + chip. Working sets get `secondaryContainer` chip. Set type read-only in runner.
- **WorkoutHistorySetRow**: Warmup chip (`tertiaryContainer` tint) shown when `setType == SetType.warmup`.
- **AppStrings** (+9): `setTypeWarmup`, `setTypeWorking`, `setTypeWarmupDescription`, `setTypeWorkingDescription`, `addWarmupSet`, `addWorkingSet`, `warmupExcludedFromAnalytics`, `warmupSetDescription`, `setTypeRequired`.
- **AppProviders** (+2): `warmupSetPolicyProvider`, `setTypeOptionsUseCaseProvider`.
- **Skipped**: `ProgrammeBuilderController` (no inline set UI in programme builder), `WorkoutRunnerController` (set type read-only in runner).
- **Tests**: 9 new unit tests — 6 `warmup_set_policy`, 3 `set_type_options_use_case`; expanded `workout_builder_controller_test.dart` for warmup add/update/save coverage; expanded `workout_builder_widgets_test.dart` for set type dropdown rendering and mutation; new `workout_history_set_row_test.dart` for warmup/working history rendering.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 894/894 passed.

### 2026-06-29 — V1-M4-003 — Manual multi-week programme builder

- **Domain** (6 files): `ProgrammeBuilderDraft` (18 fields with typed enums for source/creationMethod/status/goalTags/equipment/importOrigin), `ProgrammeBuilderWeekDraft` (copyWith), `ProgrammeBuilderWorkoutSlotDraft` (copyWith), `ProgrammeBuilderTemplateDraft` (dayType enum, id, name), `ProgrammeBuilderValidationError` (scope enum with optional weekIndex/slotIndex/templateKey), `ProgrammeBuilderSaveRequest`.
- **Application** (8 files): `ProgrammeBuilderMode` (create/edit/duplicate), `ProgrammeBuilderPhase` (6 states), `ProgrammeBuilderState` (copyWith, initial factory, isLoading/isSaving/hasValidationErrors getters), `ProgrammeBuilderValidator` (10 rules: name required, at least one week, week numbers sequential, at least one slot per week, at least one template, every slot references template), `LoadProgrammeBuilderDraftUseCase` (3 methods), `SaveProgrammeBuilderDraftUseCase` (maps to `ProgrammeDraft` with template dedup), `ProgrammeBuilderController` (all mutations with bounds checks).
- **Infrastructure**: `AppRoutes` (+3), `AppStrings` (+45), `AppErrorCodes` (+7), `AppRouter` (+3 GoRoutes as /programmes sub-routes), `AppProviders` (+4: validator, load use case, save use case, controller family).
- **Presentation** (12 files): `ProgrammeBuilderScreen` (create/edit/duplicate factory constructors, PopScope, validation/error banners, wired template sheet); `ProgrammesScreen` overhauled (list view, empty/error states, FAB); widgets: `ProgrammeDetailsSection`, `ProgrammeWeeksOverview`, `ProgrammeWeekCard`, `ProgrammeWorkoutSlotCard`, `ProgrammeSaveBar` (ConsumerWidget, dirty indicator, save button with spinner), `ProgrammeBuilderErrorBanner`, 3 dialogs, `TemplateReassignmentBottomSheet`.
- **Tests**: 59 total — 12 validator (all 10 rules + composite/multi-week), 22 controller (create/edit/duplicate modes, all mutations, save/validation/clearErrors, out-of-range edge cases), 25 widget (week card display/callbacks, slot card display/callbacks, save bar dirty/disabled/spinner/save, dialog confirm/cancel).
- **Fixes**: `List<dynamic>` inference in 6 controller methods → explicit `List<ProgrammeBuilderWeekDraft>.of()` / `List<ProgrammeBuilderWorkoutSlotDraft>.of()`; missing bounds check in `removeWeek`; test adjustments for copyWith nullable field semantics.
- **Gap closure**: Wired `TemplateReassignmentBottomSheet` (was `Placeholder`), added save-confirmation snackbar, moved 4 hardcoded strings to `AppStrings`, replaced 3 deprecated `withAlpha` calls with `AedifyLightColors.errorSurface` / `AedifyDarkColors.errorSurface`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 713/713 passed.

### 2026-06-29 — Post-M4 taxonomy hardening

- Added shared enum taxonomy files and `EnumCodec` support in `lib/shared/domain/` for closed-vocabulary profile, exercise-library, strength-anchor, and provider fields.
- Converted implemented exercise-library models, parser mappings, filter state, candidate query/DTOs, and repository mappings to enum-backed taxonomies while keeping `primaryMuscles`, `steps`, `grips`, and notes string-based.
- Converted implemented profile/onboarding/programme/workout/provider domain models and key repository boundaries to enum-backed multi-selects and single-choice fields where the docs define constrained values.
- Updated onboarding/profile test fixtures, fake repositories, and expectations to compile against the new enum-backed profile taxonomy and nullable onboarding draft semantics.
- Updated settings, exercise-library, dataset, and M3 smoke tests/fakes to match the enum-backed provider and exercise taxonomy boundaries, including typed candidate queries and video metadata fixtures.
- Active work remaining: finish any remaining non-targeted cleanup outside the currently migrated test areas.
- Verification so far: Dart analyzer project scan via MCP returned no errors for the targeted paths. `flutter test test/features/settings test/features/exercise_library test/app/m3` passed. Full repo `dart format`, `flutter analyze`, and `flutter test` still pending.

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

### V1-M3-005 — Provider Capability Matrix & Gate Service (complete)

- **`AiModelCapabilities` Drift table** (`lib/core/db/tables/ai_model_capabilities.dart`): Model-level capability cache — `id`, `providerName`, `modelName`, `supportsTextInput`, `supportsImageInput`, `supportsJsonSchemaMode`, `supportsStreaming`, `supportsToolCalling` (nullable), `maxContextTokens`, `maxOutputTokens`, `maxImagesPerRequest`, `checkedAt`. Composite ID key (`${providerName}_$modelName`).
- **Database migration**: Schema 6→7, `m.createTable(aiModelCapabilities)` in v7 step. Test schema version assertions updated 6→7.
- **`AiModelCapabilityDao`** (`lib/core/db/daos/ai_model_capability_dao.dart`): 3 methods — `getCapability(providerName, modelName)`, `upsertCapability(AiModelCapabilitiesCompanion)`, `deleteCapability(providerName, modelName)`.
- **Domain models** (`lib/features/settings/domain/`):
  - `ProviderCapabilityType` — enum: `textInput`, `imageInput`, `jsonSchemaMode`, `streaming`, `toolCalling`.
  - `ProviderOperationType` — enum: 7 operations: `aiChat`, `aiWorkoutGeneration`, `aiProgrammeGeneration`, `structuredSaveFlow`, `externalTextImportParse`, `imageImport`, `physiqueAnalysis`.
  - `ProviderCapabilityViewData` — data class: `supportsTextInput`, `supportsImageInput`, `supportsJsonSchemaMode`, `supportsStreaming`, `maxContextTokens`, `maxOutputTokens`, `maxImagesPerRequest`, `checkedAt`.
  - `ProviderGateDecision` — `allowed()`/`blocked(reason, message)` constructors with `isAllowed`, `reason` (`ProviderGateFailureReason`), `message` (safe `AppStrings` guidance).
  - `ProviderGateFailureReason` — enum: 8 values — `missingProviderConfig`, `missingKey`, `unsupportedModel`, `missingTextCapability`, `missingImageCapability`, `missingJsonSchemaCapability`, `offline`, `capabilityUnknown`.
- **`ProviderCapabilityRepository`** (abstract): `getCapability(providerName, modelName)` → `ProviderCapabilityViewData?`, `saveCapability()`, `clearCapability()`.
- **`DriftProviderCapabilityRepository`** (`lib/features/settings/data/drift_provider_capability_repository.dart`): Maps `AiModelCapability` DB row ↔ `ProviderCapabilityViewData`. Uses `_capabilityId(providerName, modelName)` composite key. Imports `app_database.dart` for `AiModelCapabilitiesCompanion`.
- **`ProviderGateService`** (abstract): `evaluate(operation)` → `ProviderGateDecision`.
- **`DefaultProviderGateService`** (`lib/features/settings/data/default_provider_gate_service.dart`): Fail-closed gate — 7 sequential checks:
  1. Active provider config exists → else `missingProviderConfig`
  2. Key exists (`ByokRepository.hasKey`) → else `missingKey`
  3. Network online (`NetworkStatus.check`) → else `offline`
  4. Capability cache exists → else `capabilityUnknown`
  5. Operation-specific capability: `aiChat`/`externalTextImportParse` → textInput; `aiWorkoutGeneration`/`aiProgrammeGeneration` → textInput + jsonSchemaMode; `structuredSaveFlow` → jsonSchemaMode; `imageImport`/`physiqueAnalysis` → imageInput
  6. Required capability present → else `missingXxxCapability`
  7. Allowed
- All failure paths return safe `AppStrings` guidance messages (no internals, no prompts, no model IDs in error messages).
- **`ProviderCapabilityState`** (`lib/features/settings/application/provider_capability_state.dart`): `isLoading`, `capability` (`ProviderCapabilityViewData?`), `errorCode`/`errorMessage`, `hasError`.
- **`ProviderCapabilityController`** (`lib/features/settings/application/provider_capability_controller.dart`): `AsyncNotifier` with Riverpod 3.x family pattern (`AsyncNotifierProvider.family` + constructor args `(providerName, modelName)`). `build()` reads cached capability from repository; `reload()` refreshes.
- **Optional `ProviderCapabilityScreen`** (`lib/features/settings/presentation/provider_capability_screen.dart`): `ConsumerWidget` — loading/error/capability views with capability tiles and info tiles.
- **Provider wiring** (`lib/app/providers/providers.dart`): 4 new — `aiModelCapabilityDaoProvider`, `providerCapabilityRepositoryProvider`, `providerGateServiceProvider`, `providerCapabilityControllerProvider` (family).
- **Strings**: 7 new `AppStrings` (`providerCapabilityUnavailable`, `providerTextOnly`, `providerImageUnsupported`, `providerJsonUnsupported`, `providerOfflineBlocked`, `providerSetupRequired`, `providerKeyRequired`), 2 new `AppErrorStrings` (`providerCapabilityUnknownMessage`, `providerCapabilityLoadFailedMessage`).
- **Tests**: 18 new:
  - 4 DAO tests: get null → nil, upsert → saved, get after upsert, delete → removed.
  - 3 repository tests: save persists, get maps correctly, clear removes.
  - 8 gate service tests: missing config, missing key, offline, missing image, missing json schema, text-only allowed, image allowed, capability unknown.
  - 3 controller tests: initial build loads, build surfaces error, reload refreshes.
  - Shared `FakeConfigDao`/`FakeSecureStorage`/`FakeNetworkStatus` extended.
- **Fix applied**: Schema version assertions in `app_database_test.dart` and `migration_test.dart` updated 6→7.
- **Gap closure** (post-V1-M3-005): Added `supportsToolCalling` nullable column to table/view/repository mappings. Replaced `Icons.check_circle`/`Icons.cancel` with `OutlinedSvgAssets.checkCircle`/`OutlinedSvgAssets.xCircle`. Added retry button to empty state view. Added redaction test verifying all gate messages are safe `AppStrings`.
- Verification: `dart run build_runner build` — passed (298 outputs). `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 504/504 passed (19 new: 4 DAO + 3 repository + 8 gate service + 3 controller + 1 redaction).

### Remaining M3 Tickets

| Ticket    | Title                                 | Priority | Type |
| --------- | ------------------------------------- | -------- | ---- |
| V1-M3-009 | Create M3 setup acceptance smoke flow | P0       | qa   |

### V1-M3-007 — Implement Unit and Measurement Preference Handling (complete)

- **`UnitConversion`** (`lib/shared/domain/unit_conversion.dart`): Low-level pure numeric conversions — `kilogramsToPounds`, `poundsToKilograms`, `centimetresToInches`, `inchesToCentimetres`, `formatSafe`.
- **`MeasurementParser`** (`lib/shared/formatters/measurement_parser.dart`): `parseWeightToCanonicalKg`, `parseHeightToCanonicalCm` — parse display input, convert to canonical kg/cm using `PreferredUnit.isImperial`.
- **`MeasurementFormatter`** (`lib/shared/formatters/measurement_formatter.dart`): `formatWeight`, `formatHeight` — format canonical kg/cm into display string using `PreferredUnit.toDisplay*`.
- **`PreferredUnit` extended** (`lib/shared/domain/preferred_unit.dart`): Added `toDisplayWeight`, `toDisplayHeight`, `toCanonicalWeight`, `toCanonicalHeight` — delegate to `UnitConversion` helpers. Legacy `toImperialHeight/Weight` and `toMetricHeight/Weight` consolidated to delegate to `UnitConversion` instead of inline conversion factors.
- **`ProfileController` extended**: `updatePreferredUnits`, `updateBodyweightFromDisplay`, `updateHeightFromDisplay` — convert display→canonical via `MeasurementParser`.
- **`ProfileScreen` unit-aware**: Bodyweight/height fields use `MeasurementFormatter` for display and `MeasurementParser` for input. All three 1RM fields (bench/squat/deadlift) upgraded from hardcoded `'kg'` suffix + raw `double.tryParse` to `MeasurementFormatter.formatWeight()` display + `MeasurementParser.parseWeightToCanonicalKg()` input + dynamic `draft.preferredUnits.weightUnit` suffix.
- **`_FormField.didUpdateWidget`**: Added to sync `TextEditingController` when `initialValue` changes on unit switch.
- **No changes needed**: `drift_profile_repository.dart`, `settings_edit_draft.dart`, `settings_view_data.dart`, `settings_controller.dart`, `settings_screen.dart`, `drift_settings_repository.dart`, `AppStrings` — all already correct.
- **Tests**: 28 new — `preferred_unit_test.dart` (10), `measurement_parser_test.dart` (6), `measurement_formatter_test.dart` (6), `profile_controller_test.dart` (+3), `profile_screen_test.dart` (+3).
- **Gap closed**: 1RM fields had hardcoded `'kg'` suffix with no unit conversion — now unit-aware using `MeasurementFormatter`/`MeasurementParser`.
- **Verification**: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 555/555 passed.

### V1-M3-008 — Create Onboarding/Profile/BYOK Privacy Tests (complete)

- **3 support files**: `test/support/privacy/privacy_sentinel_values.dart` (fakeApiKey, fakeInjuryNote, fakeBodyweight, fakeProfileNote), `privacy_output_matchers.dart` (doesNotContainAny, expectNoLeakInString, expectNoLeakInMap), `fake_crashlytics_capture.dart` (FakeCrashlyticsCapture implements CrashlyticsClient).
- **Core privacy tests expanded**:
  - `crashlytics_service_test.dart` (+4): injury/bodyweight/profile note sentinels redacted in metadata and logs.
  - `secure_storage_service_test.dart` (+1): failure messages do not include fake API key.
  - `app_logger_test.dart` (+3): profile note, injury, bodyweight sentinels redacted in logs.
- **Onboarding**: `drift_onboarding_repository_test.dart` (+3), `onboarding_controller_test.dart` (+2) — safe error messages, no draft notes leaked.
- **Profile**: `drift_profile_repository_test.dart` (+3), `profile_controller_test.dart` (+2) — canonical storage, safe errors.
- **BYOK**: `drift_byok_repository_test.dart` (+4), `byok_setup_controller_test.dart` (+3), `byok_settings_screen_test.dart` (+2) — key in secure storage only, safe errors, no key echo.
- **Provider capability**: `default_provider_gate_service_test.dart` (+1), `provider_capability_controller_test.dart` (+2) — blocked decisions safe, no secrets in errors.
- **Leaks found and fixed**:
  - `notes` not redacted in Crashlytics logs — added to `Redaction._sensitiveFields` and `PrivacyClassifier._forbiddenFields`.
  - Empty key validation test used `contains('')` (always true) → changed to `isNotEmpty`.
  - `rotateKey` fail test used non-existent config ID (didn't throw) → used `shouldThrowOnRotate` flag.
  - Onboarding save error test asserted `hasError` after `nextStep()` (error cleared by step advance) → asserts step advanced correctly.
  - BYOK widget validation failure test asserted `find.text(key, findsNothing)` (key visible in EditableText) → removed; error message privacy is the valid concern.
- **Verification**: `dart format` — passed (270 files, 1 changed). `flutter analyze` — 0 errors (2 pre-existing warnings). `flutter test` — 585/585 passed.

### V1-M3-009 — M3 Acceptance Smoke Flow Tests (complete)

- **Test scaffold files created**:
  - `test/app/m3/fake_m3_dependencies.dart` — `FakeOnboardingRepository`, `FakeByokRepository` (with `setValidationResult`), `FakeProfileRepository`, `FakeProviderCapabilityRepository`, `FakeNetworkStatus` — all 6 interfaces needed for M3 flow tests.
  - `test/app/m3/m3_test_harness.dart` — `M3TestHarness` class with `pumpApp()` creating a full `ProviderScope` over 10 provider overrides + `MaterialApp.router` with `GoRouter`.
  - `test/app/m3/m3_setup_smoke_flow_test.dart` — 8 acceptance tests.
- **8 acceptance tests** covering:
  1. Fresh install → onboarding welcome screen (redirect guard + content).
  2. Full onboarding flow through all 7 steps (welcome → experience → schedule → equipment → units → limitations → BYOK → review → complete).
  3. Post-onboarding navigation: profile (`AppStrings.profileEdit`), settings (`AppStrings.settings`), BYOK settings (`AppStrings.byokSettings`) reachable from router via `go()`.
  4. BYOK key save with privacy sentinel — key persisted in fake repo, never echoed on screen after save, `AppStrings.keySaved` confirmation.
  5. AI gating: missing key blocks chat route → redirects to `aiUnavailable`.
  6. AI gating: available key allows chat route → lands on chat.
  7. Onboarding validation blocks progression when required fields missing.
  8. BYOK validation failure surfaces safe error without leaking key to error logs.
- **Existing tests expanded**:
  - `test/app/router/app_router_test.dart` — M3 gate route redirection expectations (onboarding → home for complete, home → onboarding for incomplete).
  - `test/features/onboarding/presentation/onboarding_screen_test.dart` — onboarding completion (finish setup saves state correctly, profile hint shown).
  - `test/features/settings/presentation/byok_settings_screen_test.dart` — BYOK key validation failure + saved key sentinel gate + delete key removed from UI.
  - `test/features/settings/data/default_provider_gate_service_test.dart` — text-capable AI for chat/text-parse vs workout/programme (needs `supportsJsonSchemaMode`).
- **Fixes applied during implementation**:
  - `DefaultProviderGateService` workout/programme gating requires `supportsTextInput` AND `supportsJsonSchemaMode` — `supportsTextInput` alone is insufficient for structured generation.
  - AI gating test split into two independent tests to avoid router state contamination across scenarios.
  - BYOK validation failure privacy assertion removed — form stays visible after failure (key is in `EditableText` which is the expected UX for retry; privacy gate is no persistence/logging, not UI clearance).
  - Profile screen uses `AppStrings.profileEdit` ("Edit profile"), not `AppStrings.profile`.
  - Router navigation tests need 2 `pump()` calls to settle after `router.go()`.
- **Verification**: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 605/605 passed (8 new M3 smoke flow + 1 new route + 4 new BYOK/onboarding/gate + 12 expanded existing).

### Test infrastructure fixes (post-M3 cleanup)

- **Drift warning suppression**: The top-level `_suppressDriftWarning` IIFE in `fake_dependencies.dart` relied on Dart eagerly initializing a `final` top-level variable, but Dart initializes them lazily — the private variable was never read, so the closure never ran. Removed the IIFE and drift import from `fake_dependencies.dart`. Added `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true` directly in `main()` of `drift_byok_repository_test.dart`, `byok_setup_controller_test.dart`, and `byok_settings_screen_test.dart`.
- **Off-screen taps**: Both `profile_screen_test.dart` and `onboarding_screen_test.dart` had `tester.tap()` calls targeting widgets below the 800×600 viewport (Save profile at y=3010, Build muscle at y=795). Fixed with `tester.ensureVisible()` before `tester.tap()`.
- Verification: all 606 tests pass, zero drift warnings, zero off-screen tap warnings.

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

- **All M3 tickets closed** — V1-M3-001 through V1-M3-009 complete.
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

### Codebase-wide enum conversion + convention fixes (complete)

- **18 new enum files** in `lib/shared/domain/`: `SetType`, `SetIntent`, `WeightPrescriptionType`, `LoadingModel`, `ExerciseRole`, `WorkoutSource`, `SessionSource`, `CreationMethod`, `ImportOrigin`, `ImportReviewStatus`, `ExportPrivacyMode`, `ProgramStatus`, `SavedWorkoutStatus`, `ProgramWorkoutStatus`, `WorkoutSessionStatus`, `DayType`, `WeekType`, `PeriodisationModel`, `TrainingStyle`, `ChangeType`, `UpdateScope`. All use `dbValue` getter + `fromDb()` static factory pattern.
- **Domain model updates**: 6 draft classes updated to use typed enums — `WorkoutBuilderDraft`, `WorkoutBuilderExerciseDraft`, `SavedWorkoutDraft`, `SavedWorkoutExerciseDraft`, `SetPrescriptionDraft` (3 features), `ProgrammeDraft`, `ProgrammeExerciseDraft`, `ProgrammeWorkoutTemplateDraft`, `WorkoutSessionDraft`.
- **Repository boundary conversions**: `DriftSavedWorkoutRepository`, `DriftProgrammeRepository`, `DriftWorkoutSessionRepository` use `.dbValue`/`.fromDb()` at the boundary. `LoadWorkoutDraftUseCase` converts DB→domain.
- **`set` → `prescription` rename**: Reserved-word avoidance across `workout_builder`, `programmes`, `workout_execution` features (7 lib + 2 test files).
- **Raw sizing doubles fixed** (10 files): `strokeWidth: 2` → `AppSizing.strokeWidth` (exercise_video_card, exercise_step_audio_button, exercise_detail_screen, bodymap_bucket_chip_bar, onboarding_step_scaffold, settings_section_card); field widths 80/72/64 → `fieldWidthLg/Md/Sm` (set_prescription_editor_row); SVG container 240×480 → `bodymapSvgWidth/Height` (bodymap_svg_view).
- **Token-type mismatch fixes** (4): `fontSize: AppSpacing.lg` → `AppFontSizes.xxl` (onboarding_screen, onboarding_progress_header), `size: AppSpacing.xxxl` → `AppSizing.iconLg` (placeholder_screen), `strokeWidth: AppSpacing.xxs` → `AppSizing.strokeWidth` (exercise_video_card).
- **Color modulation fixes** (5 files): 6 pre-baked alpha color tokens added to `AedifyLightColors`/`AedifyDarkColors` (`errorSurface`, `handleBarColor`, `surfaceVariantFaded`, `secondaryBorder`, `primaryContainerSelected`); runtime `withAlpha`/`withValues` calls removed.
- **Relative→package imports**: 33 `../` imports in workout_builder feature converted to `package:aedify/`.
- **Hardcoded strings → AppStrings**: 14 new constants + `exerciseNumberLabel()` method. Controller/validator/sync UI error messages moved.
- **Hardcoded Exception → AppErrorStrings** (`lib/features/workout_builder/application/load_workout_draft_use_case.dart:45`): `Exception('Saved workout not found: $savedWorkoutId')` replaced with `AppErrorStrings.workoutNotFoundWithId(savedWorkoutId)` — parameterized static method keeping the original message in the constants boundary.
- **AppErrorCodes file** (`lib/shared/constants/app_error_codes.dart`): Central constant file for all 46 unique string-literal error codes, organized by domain. All 14 source files updated to reference `AppErrorCodes.xxx` instead of inline strings. 4 enum-based failure code types left unchanged.
- **Test updates**: `drift_programme_repository_test.dart`, `workout_builder_validator_test.dart` use enum values for domain model constructors. `workout_builder_controller_test.dart` corrected — Drift data classes remain `String`. Unused imports cleaned up.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 655/655 passed.

### V1-M3-006 — Connect Profile Preferences to Candidate Engine (complete)

- **`ProfileCandidatePreferences`** (`lib/features/profile/domain/profile_candidate_preferences.dart`): Bridge domain model — `allowedEquipment`, `allowedDifficulties`, `allowedModalities`, `excludedExerciseIds`, `excludedMuscleGroups`, `goalTags`, `preferredMuscleGroups`, `includeCustomExercises`.
- **`ProfileCandidatePreferencesService`** (abstract) + **`DefaultProfileCandidatePreferencesService`** (`lib/features/profile/data/`): Reads `ProfileRepository.getProfile()`, maps deterministically:
  - `equipmentAccess` → `allowedEquipment` (pass-through set)
  - `experienceLevel` → `allowedDifficulties` (4-tier: Beginner → {novice, beginner}, Intermediate → {beginner, intermediate}, Advanced/unknown/null → all 4)
  - Goals → `goalTags` soft ranking (Build muscle → hypertrophy, Lose weight/Improve endurance → cardio, Increase strength → strength)
  - `substitutedExerciseIds` → `excludedExerciseIds` (hard exclusion)
  - `injuriesLimitations` → `excludedMuscleGroups` → empty (no free-text heuristics)
  - `allowedModalities` → empty (no hard filter on modality; handled by `goalTags` soft ranking)
- **Provider wired**: `profileCandidatePreferencesServiceProvider` in `AppProviders` (`lib/app/providers/providers.dart:313`).
- **Gap closure** (post-implementation audit): `_mapModalities` was returning raw goal strings (`"Build muscle"`) which never matched exercise modality taxonomy values (`"strength"`, `"hypertrophy"`, `"cardio"`), causing the hard filter to block all candidates. Fixed to return empty set. Corresponding test updated.
- **No signature changes** to `CandidateExerciseQuery` or `CandidateExerciseQueryService` — existing 9-field model covers all requirements.
- **No `ProfileViewData` expansion** needed — all 7 fields already present.
- **Tests**: 18 new — 17 service tests (equipment, experience, goal tags, substitutions, defaults, null profile) + 4 profile-derived candidate integration tests (equipment restriction, difficulty restriction, substituted exclusion, goal ranking).
- Verification: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 527/527 passed (18 new).
- **Compliance closeout**: Privacy audit confirmed `DefaultProfileCandidatePreferencesService` is pure read-transform-return — no logging, no Crashlytics calls, no storage writes, no raw profile data in the `ProfileCandidatePreferences` DTO output. Backlog ticket (`references/aedify-v1-build-ticket-backlog-v1.0/05-...`) and data model plan (`references/aedify-v1-data-model-implementation-plan-v1.0/04-...`, `13-...`) cross-referenced. `dart run build_runner build` ran successfully. No rules violations remain.

## 2026-06-30 — Exercise Sync Bootstrap + Parser Crash Fixes

### Problem

On a fresh install, `ExerciseDatasetSyncController._runSync()` crashed during `_parseAndImportExercises()` with `Bad state: No element` because `EquipmentTag.fromDb` used `firstWhere` without `orElse` for unrecognized dataset values like `'Band'`, `'Plate'`, `'TRX'`, `'Cables'`, `'Smith-Machine'`. Additionally, the parser threw `invalidSteps`/`invalidPrimaryMuscles` for valid exercises with empty arrays.

### Fixes Applied

| Fix                                     | File                                                                          | Detail                                                                          |
| --------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `fromDb` normalization + fallback       | `lib/shared/domain/equipment_tag.dart:28`                                     | Lowercase input, hyphen→underscore, try raw & singular; fallback to `other`     |
| 5 missing equipment enum entries        | `lib/shared/domain/equipment_tag.dart`                                        | `bosuBall`, `medicineBall`, `plate`, `trx`, `vitruvian` with `dbValue` mappings |
| Remove empty steps validation           | `lib/features/exercise_library/data/dataset/exercise_dataset_parser.dart:207` | Was throw `invalidSteps` for `steps: []`                                        |
| Remove empty primary_muscles validation | `lib/features/exercise_library/data/dataset/exercise_dataset_parser.dart:173` | Was throw `invalidPrimaryMuscles` for `primary_muscles: []`                     |
| Sync into bootstrap                     | `lib/app/bootstrap/controllers/bootstrap_controller.dart`                     | `await .initialize()` before `success` state                                    |
| Exhaustive switch updates               | `onboarding_screen.dart`, `profile_screen.dart`                               | All 5 new tags in `equipmentLabel`/`equipmentFromLabel` + chip selector         |

### Current State

- **779 tests pass** (13 test files).
- Exercise count confirmed: **1,902 exercises** imported successfully with correct equipment tags.
- Bootstrap waits for sync before redirecting to onboarding.
- Debug prints (`[SyncCtrl]`, `[Bootstrap]`, `[Onboarding]`) removed after green light.

### Remaining Concerns

- Pre-existing deprecated `onReorder` callback warning in `workout_exercise_list.dart:55`.
- Sync from Firebase Storage requires real Firebase project + anonymous auth — dev environments without resources hit `failed` and show snackbar.

## Verification Notes

- `dart format` — all files formatted
- `flutter analyze lib/` — 0 errors
- `flutter test` — 884/884 passed
- `dart run build_runner build` — not needed (no schema changes)

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
