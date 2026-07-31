# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-07-31

### Onboarding exercise preference sheets — supplied design alignment

- **Shared Step 6 sheet**: Replaced the inline Favorites/Substitutions picker with an imported `OnboardingExerciseSelectionSheet` used by both onboarding launch points.
- **Design-accurate hierarchy**: Added the 90%-height rounded surface, drag handle, `Select Exercises` header, 48px search, horizontal muscle filters, padded metadata rows, square selection controls, and surface-matched pinned `Add Selected Exercises` footer from the supplied reference.
- **Functional filtering**: Search and category filters compose while temporary selections persist; Chest, Back, and Shoulders match exact muscle groups, while Legs aggregates the lower-body buckets. Opposing favorite/substitution IDs remain excluded before filtering.
- **Deferred exercise imagery**: Replaced the reference icons with uppercase exercise initials in 48px tonal tiles and left an adjacent code TODO to swap them for dataset-backed thumbnails when exercise image integration is scheduled.
- **Widget composition**: Replaced the filter-chip and exercise-row `Widget` helper functions with private `StatelessWidget` classes, leaving selection/filter state and callbacks in the owning sheet state.
- **Regression coverage**: Added fixed-390 geometry, color, copy, initial, muscle metadata, filtering, selection-persistence, commit, and both-launch-point assertions. Kept removed/renamed onboarding actions removed and aligned stale test expectations with `Continue` and `Finish setup`.
- **Verification**: `dart format .` checked 686 files, `flutter analyze` reported no issues, all 35 onboarding presentation tests passed, all 10 M3 setup smoke tests passed, and full `flutter test` passed 1117/1117.

### Onboarding Elite Baseline — sliding unit toggles

- **Physical segmented motion**: Replaced the Weight and Height toggles' instantaneous selected fills with one shared underlay per control that slides between equal-width Metric and Imperial segments.
- **Motion language**: Matched the established Core Identity selector with a 200ms `easeOutCubic` transition and synchronized animated label colors while preserving the existing surfaces, radii, touch behavior, and selected semantics.
- **Shared unit state**: Weight and Height indicators animate together because both remain driven by the same preferred-unit draft value; canonical metric persistence and displayed ruler/value conversions are unchanged.
- **Buttonless review tests**: Kept the Experience, Schedule, and Equipment review cards free of visible action buttons and updated Step 9 coverage to assert their tappable surfaces instead of removed labels.
- **Regression coverage**: Added frame-level geometry assertions proving both indicator thumbs move at the animation midpoint and settle at the opposite segment.
- **Verification**: `dart format .` checked 685 files with no remaining changes, `flutter analyze` reported no issues, all 34 onboarding presentation tests passed, and full `flutter test` passed 1116/1116.

### Onboarding review — separate experience tier and duration

- **Distinct review values**: The Experience & Level card now removes the parenthesized date range from Tier and renders only that range in Duration; for example, `Intermediate (6 mo–2 yr)` is displayed as `Intermediate` and `6 mo–2 yr`.
- **Empty-state safety**: Experience values without a parenthesized range, including the review placeholder, remain unchanged instead of being reduced to blank text.
- **Buttonless interactions**: Experience, Schedule, and Equipment remain tappable without visible action buttons, alongside the existing whole-card navigation for AI Intelligence and Metric Integration.
- **Regression coverage**: Step 9 now asserts the exact Tier and Duration tile contents and verifies that the combined experience label is absent.
- **Verification**: `dart format .` checked 684 files with no remaining changes, `flutter analyze` reported no issues, all 33 onboarding presentation tests passed, and full `flutter test` passed 1115/1115.

### Exercise preferences — opposing-selector exclusion

- **Mutually exclusive pickers**: Favorite exercises are now removed from the Avoid/Substitutions picker, and avoided/substituted exercises are removed from the Favorites picker.
- **Consistent editing**: Applied the same cross-filtering to onboarding Step 6 and the editable Profile screen so the conflict cannot be reintroduced after onboarding.
- **Mobile sheet stability**: Constrained the onboarding picker heading so its Done action remains reachable on the fixed 390px design surface.
- **Regression coverage**: Added real in-memory exercise-library interaction coverage for both exclusion directions in onboarding and Profile, and backed the modal tests with router-aware harnesses.
- **Test maintenance**: Aligned remaining Step 4 and Step 7 assertions with the current slider range, removed eyebrow, and 32px Max Lifts spacing; updated the M3 smoke flow for the current `Adept`, `Next Step`, and Elite Baseline copy.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, the complete onboarding/Profile presentation files passed 48/48 tests, and full `flutter test` passed 1115/1115.

### Onboarding presentation tests — stale assertion repair

- **Library boundary**: Replaced test references to the private `_OnboardingSelectionPill` implementation with its stable semantics keys and selected-state contract.
- **Scoped content**: Scoped the duplicated Step 3 title assertion to `OnboardingExperienceGoalsStep`, distinguishing the body headline from the progress-header label.
- **Current duration control**: Replaced obsolete Step 4 ruler-key expectations with assertions for the current discrete 20–120 minute Slider and its 20 divisions.
- **Verification**: Superseded by the cross-filtering verification above; `onboarding_screen_test.dart` now passes all 33 tests.

## 2026-07-30

### Onboarding Core Identity — sliding unit selector

- **Segmented motion**: Replaced the independent Metric/Imperial selected-state cross-fade with one shared indicator that slides between the two choices.
- **Interaction boundary**: Preserved the existing colors, pill shape, shadow, labels, draft updates, touch behavior, and selected semantics while animating the indicator with the established fast `easeOutCubic` motion.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused sliding-selector widget test passed.

### Onboarding navigation — reset scroll position between steps

- **Step transitions**: Added a scaffold-owned scroll controller that returns onboarding content to the top whenever the active `OnboardingStep` changes.
- **Coverage**: The reset applies consistently to forward, Back, and review-card jump navigation while leaving the fixed progress header and pinned action area unchanged.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused widget test passed for both forward and backward transitions after scrolling. The complete onboarding presentation file passed 31 tests and retains its unrelated existing Step 4 duration-ruler assertion failure.

### Onboarding presentation — standalone widget extraction

- **One widget per file**: Moved all 62 private widget classes out of `onboarding_screen.dart` into unique standalone libraries under `lib/features/onboarding/presentation/widgets/onboarding/`, keeping each state class beside its owning stateful widget.
- **Imports and exports**: Renamed extracted widgets with public `Onboarding...` names required by Dart library boundaries, added direct package imports between dependent widgets, and exposed the complete set through `onboarding_widgets.dart`. No `part` directives are used.
- **Screen entry point**: Reduced `onboarding_screen.dart` from 5,848 lines to a 44-line route/state entry point while preserving the existing Riverpod controller boundary.
- **Behavior boundary**: This is a presentation-only structural refactor; onboarding copy, layout, state transitions, validation, persistence, privacy, and navigation behavior are unchanged.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, the focused end-to-end step-transition test passed, and structural checks confirmed 62 exported files with exactly one widget class in each and no private widget classes remaining in `onboarding_screen.dart`. The complete onboarding presentation file passed 30 tests and retains its unrelated existing Step 4 duration-ruler assertion failure.

### Onboarding step nine — Final Architecture Review alignment

- **Review hierarchy**: Moved the Step 9 hero into the review body so the supplied 40px headline, 18px lead copy, 16px internal gap, and 48px card offset are preserved without changing the shared onboarding scaffold.
- **Fixed mobile cards**: Retained the five-card single-column order with 24px gaps and corrected Experience, Schedule, and Equipment to use 32px padding, 12px radii, restrained shadows, reference-style fact tiles, and plain schedule/equipment summaries.
- **AI Intelligence**: Preserved the existing AI card content and tonal treatment, removed its `Modify` button, and made the full card navigate to the optional AI setup step with button semantics and pressed feedback.
- **Metric Integration**: Removed its `Modify` button and made the complete bordered metric card navigate to the Metrics step while retaining truthful local metric copy and chips.
- **Project boundaries**: Kept the shared Step 9 of 9 header and pinned `INITIALIZE WORKSPACE` / `Back` actions instead of reintroducing the reference's inline action or unsupported biometric-sync claims.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused Step 9 design/navigation test passed. The complete onboarding file passed 30 tests and retains its unrelated existing Step 4 duration-ruler assertion failure.

## 2026-07-29

### Onboarding step eight — Intelligence Layer alignment

- **Composition**: Rebuilt Step 8 around the supplied fixed-mobile hierarchy: Configuration eyebrow, 40px Intelligence Layer headline, truthful supporting copy, and compact benefit rows ordered Private → BYOK → Optional.
- **Provider setup**: Replaced compact provider pills with stacked OpenAI, Anthropic, and Google cards using the supplied 48px icon tiles, 12px radii, tonal selected surface, and animated 2px accent outline. OpenAI is selected initially.
- **Credentials**: Added provider-specific API-key labels and hints, a masked 56px credential field with reference visibility behavior and focus ring, secure-storage helper copy, filled `Secure Connection` action, inline failure feedback, and the encrypted dot-line divider.
- **BYOK behavior**: Preserved the required model selector, corrected each provider's initial model to the cheapest catalog option, and now validates a key before saving it through the existing secure-storage repository boundary.
- **Project boundaries**: Retained the nine-step header and shared pinned `Continue` / `Back` actions, omitted the reference's unsupported nutrition/recovery claims and decorative gradient, and kept core Aedify features fully usable without AI.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and both focused Step 8 widget tests passed. The full onboarding file passed 29 tests and retains its unrelated existing Step 4 duration-ruler assertion failure.

### Onboarding step seven — Elite Baseline alignment

- **Composition**: Rebuilt Step 7 around the supplied centered `Onboarding: Step 7` introduction, separate Weight and Height baseline cards, and a dedicated optional Max Lifts card.
- **Metric cards**: Added synchronized compact unit selectors, prominent editable values, and interactive 96px reference-style analogue rulers. Their tick strips now follow the drag direction beneath a fixed center marker, carry release velocity, settle to the nearest increment, support tap-to-seek, and retain accessibility increment/decrement controls. Retained the supplied Weight-before-Height hierarchy and fixed 32px card padding.
- **Max Lifts**: Matched the supplied fixed-mobile card with exact title casing, a 40px post-Height offset, translucent bordered surface and restrained blue ambient shadow, contiguous title/helper hierarchy, and the larger muted accuracy pill.
- **Strength anchors**: Rebuilt Bench Press, Back Squat, and Deadlift as stacked 56px tonal inputs with 8px radii, `0` hints, headline numerals, explicit unit suffix styling, and animated blue label/ring plus white-surface focus states.
- **Behavior boundary**: Preserved optional/null semantics, canonical centimetre/kilogram storage, synchronized global unit preference, imperial conversions, and the existing three strength-anchor fields. Clearing Height or Weight now correctly restores `null`.
- **Actions**: Retained the project-wide pinned stacked `Continue` and `Back` controls established for onboarding.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused Step 7 plus end-to-end onboarding flow tests passed 8/8. The complete onboarding screen file passed 27 tests and retains its unrelated existing Step 4 duration-ruler assertion failure.

### Onboarding step six — Precision Constraints alignment

- **Composition**: Rebuilt Step 6 around the supplied centered introduction and fixed-width single-column sequence: Safety First, injury flags, Favorites, Substitutions / Avoid List, and Other Notes.
- **Safety priority**: Retained Aedify's truthful local-first safety and privacy content, promoted it to the first content section, and kept its quiet tonal surface treatment.
- **Controls**: Reworked limitations into reference-style two-column visual tiles and restyled the real favorite/substitution pickers as tonal input surfaces without replacing their local exercise-ID behavior with mockup-only sample chips.
- **Exercise chips**: Favorite and substitution selections now render their exercise names in selection order. Up to eight selections remain individually visible; additional selections collapse into a single `n selected` overflow chip after the first eight.
- **Actions**: Set the shared pinned action copy to `Next Step` and `Back` while preserving the established stacked layout.
- **Behavior boundary**: Preserved all nine existing optional limitation values, note persistence, exercise selection workflow, nine-step progress, and no-validation progression.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused Step 6 plus end-to-end onboarding flow tests passed 7/7, including the eight-chip boundary and overflow behavior.

### Onboarding step five — Gym Environment alignment

- **Composition**: Matched the supplied centered introduction and tiered equipment-card hierarchy while preserving Aedify's existing equipment taxonomy and selection behavior.
- **Equipment artwork**: Generated and bundled original local images for the squat rack, pull-up bar, and cardio machine—the three displayed equipment choices that previously used icon fallbacks. Bodyweight only intentionally retains its illustrated symbol treatment.
- **Asset boundary**: Added the generated artwork as local JPG assets referenced through `ImageAssets`; onboarding remains offline-first with no runtime image requests.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused Step 5 widget test passed. The complete onboarding suite remains blocked by an existing Step 4 duration-ruler assertion (expected 10 keyed marks; current widget tree contains none).

### Onboarding step four — Your Rhythm alignment

- **Composition**: Rebuilt the schedule screen around the supplied centered intro and three white bento surfaces for weekly availability, session duration, and total weekly load.
- **Controls**: Restyled weekday choices as substantial tonal schedule tiles, added the reference-style inset coaching tip, promoted the duration value, and refined summary metrics plus the seven-day load chart.
- **Session duration**: Added the reference 8px tonal slider track and white-ringed blue thumb with restrained shadow. Corrected the below-slider scale to a compact fixed-gap ten-mark ruler with emphasized intervals and full-width uppercase, tracked, muted Endurance/Optimal/Intensity labels.
- **Total weekly load**: Matched the reference metric copy and hierarchy with uppercase tile labels, `x.x hours` volume formatting, a taller unlabeled seven-bar chart with fixed gaps and top-only rounding, plus the faint analytics decoration.
- **Actions**: Explicitly set the pinned action copy to `Continue` and `Back`.
- **Behavior boundary**: Preserved weekday selections as the authoritative persisted schedule model rather than replacing them with decorative frequency-only numbers.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused onboarding presentation suite passed 21/21.

### Onboarding step three — Define Your Path alignment

- **Composition**: Replaced the two generic form panels with the supplied open layout: centered intro, three standalone Novice/Adept/Elite experience cards, and free-standing wrapped growth-pillar selectors.
- **Interaction**: Experience cards now use the supplied white surface, selected blue outline, emphasized icon, and check state. The pinned primary action is explicitly labeled `Continue`.
- **Growth pillars**: Matched the supplied spacious chip treatment with 24×16 padding, white outlined unselected surfaces, blue selected fills, 12px icon gaps, and no trailing check glyph.
- **Scope**: Preserved the existing experience enums, supported goal taxonomy, validation, and persistence behavior.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused onboarding presentation suite passed 20/20.

### Onboarding step two + shared pinned actions

- **Core Identity**: Rebuilt step two as one centered white identity surface with reference-aligned title, supporting copy, three sex choices, pill measurement selector, and date-of-birth control.
- **Shared navigation**: Moved onboarding actions outside the scrolling content into a bottom-pinned action bar on every step, including Welcome and Final Review. Primary and Back actions are stacked vertically in reference order with standardized rectangular radii, and the pinned area uses the same surface color as the scaffold.
- **Measurement selector**: Corrected the selected segment to a white inset surface with blue text and subtle shadow; unselected segments remain transparent with muted text on the tonal container.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused onboarding presentation suite passed 19/19.

### Onboarding step one — supplied welcome design alignment

- **Composition**: Removed the mobile gym-image hero and rebuilt the welcome step around the supplied headline-first hierarchy: privacy feature grid, display-name field, bottom-pinned rectangular primary action, and trust footer.
- **Product boundaries**: Preserved Aedify's locked nine-step flow and local-only/BYOK copy instead of introducing the supplied mockup's unsupported cloud-sync claims.
- **Verification**: `dart format .` passed, `flutter analyze` reported no issues, and the focused onboarding presentation suite passed 17/17.

### Onboarding — updated nine-step fixed mobile flow

- **Flow order**: Expanded onboarding to Welcome → Core Identity → Experience & Goals → Schedule → Gym Environment → Limitations → Metrics → Optional AI → Review, including updated forward, back, resume, and review-edit navigation.
- **Core Identity stepper**: Retained the theme-aware Aedify logo and applied the Core Identity segmented `Step X of 9` progress treatment to every onboarding page.
- **Weekday frequency**: Replaced independent numeric frequency choices with a fixed four-column Monday–Sunday selector. The selected weekday list is now the source of truth; displayed, saved, reloaded, and reviewed day counts are derived from it.
- **Gym environment**: Bundled and displayed the supplied dumbbell, barbell, bench, kettlebell, resistance-band, cable-machine, and Smith-machine images, with deliberate icon treatments for bodyweight and existing equipment options without supplied artwork.
- **Design SVGs**: Bundled all 55 unique Google Material Symbols referenced by the supplied onboarding design, plus its filled `info` state, under the existing outlined SVG asset family. Centralized every path in `OutlinedSvgAssets`, retained the Aedify logo, and applied the exact design glyphs to onboarding choices, section cues, statuses, and navigation controls.
- **Asset provenance**: Added the upstream Apache 2.0 license alongside the local Material Symbols set. The SVGs ship in the app bundle and require no runtime font or network request.
- **Presentation**: Reworked the supplied design into a fixed mobile composition using Aedify theme, spacing, typography, SVG, privacy, local-first, and optional-AI conventions without adding responsive breakpoints or unsupported cloud/health behavior.
- **Verification**: `dart format .` completed with no changes, `flutter analyze` reported no issues, all 56 downloaded SVG variants passed XML validation, focused onboarding/M3 tests passed 27/27, focused Drift repository tests passed 14/14, and full `flutter test` passed 1098/1098.

## 2026-07-24

### M4 UI redesign — complete Serene Professional mobile experience

- **Design foundation**: Fixed dark-theme button typography and input focus color, added semantic layout spacing and light `bodySm` tokens, documented the approved green/orange difficulty-color exceptions, and added reusable `AppBottomSheet`, `AppDialog`, `AppEmptyState`, `AppIconButton`, `AppListTile`, `AppSectionHeader`, and `AppTogglePill` components.
- **Floating navigation**: Replaced the custom bottom bar with a floating Material 3 `NavigationBar` using rounded tonal surfaces, mode-correct active indicators, SVG destinations, safe-area spacing, and existing `StatefulNavigationShell` branch behavior.
- **Setup and trust surfaces**: Redesigned onboarding, profile, settings, BYOK setup, and provider capabilities with privacy-first tonal hierarchy, semantic pill selectors, grouped mobile forms, secure key presentation, explicit capability states, and touch targets of at least 44 logical pixels.
- **Training discovery**: Redesigned Home as a coach's clipboard with a dominant Start/Resume action, programme continuity, active-session progress, guided empty/error states, and disabled M5 actions. Exercise Detail now stages video, instructions/TTS, bodymap, metadata, notes, and honest history-empty content as alternating visual sections. Bodymap now uses a full-width anatomical stage, bucket pills, and front/back controls.
- **Programme planning**: Redesigned Programme Builder with quiet mode headers, tonal details panels, semantic goals/equipment pills, expandable weeks, clearer workout slots, consistent sheets, inline validation, and a separated save/active-state surface. Programme Calendar now provides current-week, today, completion, rest, and patterned deload treatments with active-session-aware Start/Resume behavior.
- **History review**: Redesigned Lift Log with rich snapshot cards, guided empty/error states, pull-to-refresh, and floating-nav clearance. Workout History Detail now uses a session summary hero, tonal exercise/superset sections, and explicit Warm-up/Working plus Completed/Skipped/In Progress set states.
- **M4 audit cleanup**: Replaced all remaining production Material `Icons.*` and `Navigator.pop` usages, converted the exercise-picker modality switches and onboarding favorite selector to shared controls, removed the unused legacy exercise-filter and superset sheets, and routed the generic workout path to the real active-session runner instead of the obsolete placeholder screen.
- **Scope**: Presentation, theme, routing cleanup, shared UI components, and widget tests only. No product scope, persistence, privacy, AI, or domain behavior changed.
- **Verification**: `dart format .` — 0 pending formatting changes. `flutter analyze` — no issues found. `flutter test` — **1087/1087 passed**.

## 2026-07-20

### Workout execution — Material Icons replaced with SvgPicture.asset

- **`finish_early_session_complete_screen.dart`**: 6 Material icons replaced — `Icons.close` → `OutlinedSvgAssets.xMark`, `Icons.block` → `OutlinedSvgAssets.noSymbol`, bottom-nav `_NavItem.icon` type changed from `IconData` to SVG asset path (`calendar`, `dumbbell` solid, `clock`, `user`).
- **`workout_complete_screen.dart`**: 6 Material icons replaced — `close` → `xMark`, `check_circle` → `SolidSvgAssets.checkCircle`, `auto_awesome` → `sparkles`, `bolt` → `bolt`, `chevron_right` → `chevronRight`, `share` → `share`. Added `flutter_svg` + both SVG asset imports.
- **`exit_workout_sheet.dart`**: 5 Material icons replaced — `pause_circle_filled` → `SolidSvgAssets.pauseCircle`, `save` → `arrowDownTray`, `arrow_forward` → `arrowRight` (both `onSecondary` per button foreground), `play_arrow` → `SolidSvgAssets.play`, `delete_forever` → `trash`. Added `flutter_svg` + both SVG asset imports.
- **`finish_early_dialog.dart`**: 1 Material icon replaced — `Icons.warning` → `OutlinedSvgAssets.exclamationTriangle`. Added `flutter_svg` + outlined SVG asset imports.
- **`workout_runner_screen.dart`**: 4 `Navigator.of(context).pop()` calls in `_showExitWorkoutSheet` replaced with `context.pop()` (go_router was already imported).
- No behavior, layout, or string changes; existing `AppSizing.*` sizes and explicit icon colors preserved.
- Verification: `dart format lib/features/workout_execution/` — 0 changed. `flutter analyze lib/features/workout_execution/` — no issues found.

## 2026-07-07

### Workout detail screen — logging-type-aware exercise cards

- **`_ExerciseCard` now renders per `ExerciseLoggingType`**: `repsWeight` shows "Sets x Reps" + "Intensity" (unchanged); `repsOnly` shows "Sets x Reps" only (no intensity column); `duration` shows "Sets x Duration" with formatted time (`Xs` for <60s, `M:SS` for ≥60s) and no intensity column.
- **`ExerciseDetailItem.loggingType`** field added (defaults to `repsWeight`).
- **Controller** passes resolved `ExerciseLoggingType` from `exerciseModel.loggingType` in both `buildWorkoutDetail` and `buildSavedWorkoutDetail`.
- **`AppStrings.setsAndDuration`** added (`"Sets x Duration"`).
- Files: 4 lib files changed.
- Verification: `dart format .` — 0 issues. `flutter analyze` — 0 issues.

### Custom exercise editor — step list view redesigned to match HTML

- **`CustomExerciseStepsEditor` redesigned**: Matches the HTML list view with `surfaceContainerLow` container, `rounded-2xl`, `min-h-[240px]`, numbered step rows with white input fields (`border outlineVariant`, `rounded-xl`, `px-4 py-3`), delete icon per step, `add_circle` + "Add Step" button, and two overlay buttons (notes + AI suggestion) with `rounded-lg` and `shadow-sm`.
- **Added `onSwitchToText` callback**: Notes button in steps editor switches back to textarea view by clearing all steps.
- Updated `_InstructionsSection` with `_switchToText` method to handle the toggle.
- Files: `lib/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart`, `lib/features/exercise_library/presentation/custom_exercise_editor_screen.dart`, test file.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1064 all passed.

### Custom exercise editor — third pass: HTML mobile view match, section order fix

- **Section order corrected to match HTML mobile view**: Exercise Name → PRIMARY MUSCLE GROUP → Equipment + Difficulty → MODALITY → Instructions → Logging Type → Action Buttons.
- **Chip spacing**: All chip wraps changed from 4px gap to 8px gap (`gap-2` in HTML).
- **Instructions overlay**: Added second AI suggestion button; both use `rounded-lg` (8px radius) with `shadow-sm`.
- **Action buttons**: Changed from side-by-side `Row` to stacked `Column` (mobile `flex-col`), 16px gap.
- **Logging type spacing**: Header-to-cards gap 24px (`space-y-6`); card wrap spacing 16px (`gap-4`).
- Files: 4 lib files.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1064 all passed.

### Custom exercise editor — second pass: precise HTML design match

- **Section order corrected**: Modality now appears before Primary Muscle Group per the HTML layout.
- **Chips replaced**: `FilterChip` and `SegmentedButton` replaced with custom `GestureDetector` + `Container` pills — `px-5 py-2.5` (20h/10v), `rounded-full`, toggle colors matching HTML exactly (`secondaryContainer`/`onSecondaryContainer`/`secondary` border when selected; `surfaceContainerLowest`/`onSurfaceVariant`/`outlineVariant` when unselected).
- **Section spacing**: 40px (`AppWhiteSpace.hXl`) between major sections.
- **Name input**: `surfaceContainerLow` bg, no border, `rounded-2xl` (16px), `px-6 py-5` (24h/20v), `bodyLg` font, focus state with white bg + blue-tinted shadow.
- **Instructions section**: `TextField(maxLines: 6)` styled as textarea when steps are empty; delegates to `CustomExerciseStepsEditor` when steps exist. "Optional" label tag.
- **Action buttons**: `py-5` (20v padding), `rounded-2xl` (16px radius), 16px gap, primary has `shadow-lg`.
- **Logging type cards**: `shadow-sm` on all cards (selected and unselected), 8px gap between internal elements.
- **Equipment dropdown**: `surfaceContainerLow` bg, `rounded-2xl`, `padding horizontal: 24`, `expand_more` icon.
- **Difficulty segment**: 6px container padding, 12px vertical button padding, 3 segments.
- Files:
  - `lib/features/exercise_library/presentation/custom_exercise_editor_screen.dart` — rewrite
  - `lib/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart` — chip padding fix
  - `lib/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart` — replaced FilterChip with custom toggle chips
  - `lib/features/exercise_library/presentation/widgets/custom_exercise_logging_type_picker.dart` — card shadows/spacing fix
  - `test/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker_test.dart` — updated tests for custom chips
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1064 all passed.

### Custom exercise editor — redesigned to match HTML design, modality moved above muscle groups

- **CustomExerciseModalitySection redesigned**: Replaced `SegmentedButton` + `DropdownButtonFormField` layout with pill-shaped toggle chips matching the HTML design — `surfaceContainerLowest`/`secondaryContainer` toggle with `outlineVariant`/`secondary` border, `AnimatedContainer` for smooth transitions.
- **Modality moved above muscle groups**: The `CustomExerciseEditorScreen` now shows Modality chips before the Primary Muscle Group picker.
- **Equipment + Difficulty combined into `_EquipmentDifficultySection`**: Styled side-by-side layout — equipment dropdown uses `DropdownButton` with `surfaceContainerLow` background and `AppRadius.xl` rounding; difficulty uses 3-segment button group (Beginner/Intermediate/Advanced) with `surfaceContainerLow` container and `surfaceContainerLowest` selected pill.
- **New `CustomExerciseLoggingTypePicker`**: Matches the HTML "Logging Type" section — icon header with `Icons.calculate`, subtitle, and 3 selectable cards (Reps Only, Weight & Reps, Duration) with `AnimatedContainer` selection state, check-circle overlay, and `surfaceContainerLowest`/`secondary` border styling.
- **Instructions section redesigned**: Label updated to "INSTRUCTIONS & FORM NOTES" with "Optional" badge.
- **Bottom buttons redesigned**: "Create Exercise" (primary) and "Discard" (outlined) buttons side by side, using `AppRadius.lg` rounded shape.
- **New controller method**: `setLoggingType(ExerciseLoggingType?)` added to `CustomExerciseEditorController`.
- **Default logging type**: `LoadCustomExerciseDraftUseCase.createEmptyDraft()` now defaults `loggingType` to `ExerciseLoggingType.repsWeight`.
- **New AppStrings**: `customExerciseLoggingType`, `customExerciseLoggingTypeDesc`, `customExerciseLoggingTypeRepsOnly/Desc`, `customExerciseLoggingTypeWeightReps/Desc`, `customExerciseLoggingTypeDuration/Desc`, `createExercise`, `customExercisePrimaryMuscleGroup`, `customExerciseInstructionsHint`, `customExerciseInstructionsOptional`.
- Files:
  - `lib/features/exercise_library/presentation/custom_exercise_editor_screen.dart` — full rewrite
  - `lib/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart` — redesigned
  - `lib/features/exercise_library/presentation/widgets/custom_exercise_logging_type_picker.dart` — new
  - `lib/features/exercise_library/application/custom_exercise_editor_controller.dart` — added `setLoggingType`
  - `lib/features/exercise_library/application/load_custom_exercise_draft_use_case.dart` — default loggingType
  - `lib/shared/constants/app_strings.dart` — new strings
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1064 all passed.

---

## 2026-07-06

### ExerciseLoggingType — new logging type field on exercises

- **New enum**: `ExerciseLoggingType` (`repsWeight`, `repsOnly`, `duration`) in `lib/shared/domain/exercise_logging_type.dart`.
- **New resolver**: `ExerciseLoggingTypeResolver.resolve({modality, equipment?, force?})` — computes defaults from modality/equipment/force per explicit rules: strength + bodyweight equipment → repsOnly, strength + other → repsWeight, flexibility + hold → duration, flexibility + other → repsOnly, cardio → duration, recovery → duration.
- **DB column**: `exercises.logging_type` (nullable TEXT). Schema bumped 12 → 13 with migration that backfills all existing rows via SQL CASE statement.
- **Propagated** through `ExerciseDatasetExercise`, `ExerciseListItem`, `ExerciseDetailViewData`, `CandidateExerciseDto`, `CustomExerciseDraft`, `CustomExerciseSeed`, `ExerciseReference`, dataset parser/importer, repository read/write methods, candidate query service, and custom exercise load/save flow.

### WorkoutDetailScreen — session-aware buttons, goal badge, stale-data fixes

- **Hide start/resume when conflicting session**: `_loadSavedWorkoutDetail` now sets `buttonState = hidden` when there's an active session for a different workout.
- **Stale data after discard**: Added `ref.watch(AppProviders.activeWorkoutSessionProvider)` to saved-workout loading; home-screen discard invalidates this provider, cascading re-fetch.
- **Stale data after edits/pauses**: `_loadSavedWorkoutDetail` also watches `homeRefreshTriggerProvider` (triggered by workout runner on pause/complete).
- **Top-level functions encapsulated**: `_loadProgrammeDetail` and `_loadSavedWorkoutDetail` moved into `_WorkoutDetailProviders` as `static` methods.

### SavedWorkoutListTile — session-aware play button, edit menu, spacing

- **`_PlayButton`**: No session → play starts workout; session IS this workout → play resumes; session for DIFFERENT workout → grayed out, disabled.
- **Removed "Start Workout" from popup menu**: Start action lives exclusively on play button.
- **"Edit Workout" menu item**: `pencil` icon, navigates to `workoutBuilderEdit`.
- **Spacing fixes**: Category `mb-1` 2→4px. Icon-text `gap-1` 2→4px. More button `p-2 -mr-2` via `Transform.translate` + 8px padding.

### WorkoutDetailScreen — dual programme/saved-workout mode

- **Renamed**: `ProgrammeWorkoutDetailScreen` → `WorkoutDetailScreen`. `programId` made nullable; when null loads from `SavedWorkoutRepository`.
- **Goal badge**: `buildSavedWorkoutDetail` parses `goalTagsJson` into display string for hero badge.
- **Controller**: `buildSavedWorkoutDetail(SavedWorkoutAggregate, exerciseModels)` reuses existing formatting.
- **Routes**: New `/workouts/:workoutId` (`AppRoutes.workoutDetail`). `SavedWorkoutListTile` tap now navigates here instead of `workoutBuilderEdit`.

### CreateActionFab — shared component

- Extracted from `_CreateExerciseFab` into `lib/shared/components/create_action_fab.dart`. Used in both `ExerciseLibraryScreen` and `SavedWorkoutLibraryScreen`.

### SavedWorkoutListItem — focus + modalities

- **`focus`**: Required field from `goalTagsJson`, formatted via `_formatFocus` in use case.
- **`modalities`**: Required `List<String>` from exercise lookups via `ExerciseDao.getModalityByIds(List<int>)`.

### _StackedCategoryIcons — modality-driven, up to 3

- Maps modality strings to icons (`dumbbell`/`heart`/`meditation`). `.take(3)` with progressive offsets for proper overlap.

### Convention violations — widget method, cs param, raw numbers

- `_buildExerciseListView` → `_ExerciseListView` widget class.
- `_SupersetGroupWidget`: removed `cs` param, uses `context.colorScheme`.
- Raw `4` → `2 * AppSizing.strokeWidth`. `AppFontSizes.sm` → `AppSpacing.md - AppSpacing.xxs`.
- `_selectionCount` inlined. Superset badge → `AppBadge`.

### ProgrammeWorkoutDetailScreen — superset grouping

- `ExerciseDetailItem` gains `supersetGroupId`/`supersetOrder`. `_ExerciseList` groups into `_SupersetGroupSection` (left accent border, badge, 5% bg).

### Saved workout library screen — card redesign + FAB

### Exercise library screen — full redesign to match HTML design system

- **ExerciseLibraryScreen rewritten** (587 lines, down from 391+185): Matches the HTML design with view toggle (List/Bodymap pill toggle using `surfaceContainerLow` bg + `AppRadius.full`), search bar (white card, `AppRadius.md`, no-border style, focused ring at `secondary/20`), horizontal scrollable muscle-group filter chips (`_MuscleGroupChips` — All/Chest/Back/Legs/Shoulders/Arms/Core/Cardio mapping to `BodymapBucket` and `ExerciseModality`), exercise list using shared `ExerciseCard` component, das
hed-border empty state (`_EmptyState` with `DashedBorderPainter`), and `_CreateExerciseFab` (`AppRadius.lg`, secondary color, plus icon, navigates to custom exercise creation).
- **View toggle**: `_ViewToggle` and `_TogglePill` widgets — animated container with 300ms duration, selected pill uses `secondary` bg + shadow, unselected uses transparent bg. Bodymap tab icon uses `BodymapSvgAssets.front` (existing large SVG scaled to icon size).
- **Chip-based filtering replaces filter FAB + bottom sheet**: `_MuscleGroupChips` provides quick muscle-group access inline. `_FilterChipData` static list maps 8 labels to `BodymapBucket?` + `ExerciseModality?`. `_MuscleGroupChips` `onSelected` uses `copyWith` with `clearMuscleGroup: bucket == null` and `clearModality: modality == null` to correctly clear fields when switching chips — fixes the `??` fallback pattern that prevented clearing filter values to null.
- **Empty state redesigned**: Dashed-border container (300px, `DashedBorderPainter` with 2px stroke, 8px dash, 8px gap, `AppRadius.md`) with circle icon, headline, and subtext. Replaces centered icon + text pattern.
- **New `_ErrorView`**: Extracted from screen body — centered layout with `exclamationCircle` icon, error message, and `FilledButton` retry.
- **New `_CreateExerciseFab`**: GestureDetector + Container (60x60px, `secondary` bg, `AppRadius.lg`, key: `create_exercise_fab`) replacing `FloatingActionButton` filter icon.
- **Removed** `_ActiveFilterBar`, `_FilterChipWidget`, `_ExerciseListTile` — functionality replaced by new chip bar and shared `ExerciseCard`.
- Files: `lib/features/exercise_library/presentation/exercise_library_screen.dart`, `test/features/exercise_library/presentation/exercise_library_screen_test.dart`.
- Verification: `dart format .` — 643 files (0 changed). `flutter analyze` — 0 issues. `flutter test` — 1064 passed (8 exercise library screen tests).

### ExerciseCard extraction — shared widget reused across workout builder and exercise library

- **New shared widget**: `lib/features/exercise_library/presentation/widgets/exercise_card.dart` — `ExerciseCard` (public `StatelessWidget`) extracted from `AddExerciseBottomSheet._ExerciseCard`. Takes `ExerciseListItem item`, `bool isSelected` (defaults `false`), `VoidCallback onTap`. Renders row layout: 56x56 avatar with first-letter initial, name + `_TagChip` (first muscle group or modality) + equipment chip (if present), trailing `_DifficultyBadge` (color-resolved per difficulty + brightness via `AppBadge`). Selection state animates with `AnimatedContainer` (200ms, `easeInOut`): secondary border + tinted avatar + `checkCircle` overlay. Private helpers `_TagChip` and `_DifficultyBadge` (previously in `add_exercise_bottom_sheet.dart`) moved into this file along with `_formatEquipment` / `_formatLabel` functions.
- **`AddExerciseBottomSheet` updated**: `_ExerciseCard`, `_TagChip`, `_DifficultyBadge` classes (~240 lines) removed; import replaced with shared `ExerciseCard`. Unused imports (`app_badge`, `svg_assets_solid`, `exercise_difficulty`) removed. `app_colors` import kept (used by handle bar color).
- **`ExerciseLibraryScreen` updated**: Old `_ExerciseCard` (with `_ExerciseCardImage` gradient placeholder + `_MuscleGroupTagRow`, ~185 lines) replaced with shared `ExerciseCard`. Unused imports (`exercise_list_item`, `exercise_difficulty`) removed.
- Files: `lib/features/exercise_library/presentation/widgets/exercise_card.dart` (new), `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`, `lib/features/exercise_library/presentation/exercise_library_screen.dart`.
- Verification: `dart format .` — 3 files (1 changed). `flutter analyze` — 0 issues. `flutter test` — 1064 passed.

### Saved workout library screen — card redesign + FAB

- **`SavedWorkoutListTile` redesigned**: Replaced `Card`+`ListTile` pattern with a rich card matching the HTML design — `surfaceContainerLowest` background, 3-level shadow, `AppRadius.lg` corners, 1px `surfaceContainer` border. Card layout: top row with description-as-category label (uppercase, 10px, secondary), headline-md title (max 2 lines), stats row with `listBullet` icon + exercise count and `clock` icon + duration. Trailing `ellipsisVertical` PopupMenuButton (start/archive/delete). Bottom row with stacked category icon circles (bolt + clock, 32px, overlapping -8px, `surfaceContainer`/`surfaceContainerLow` backgrounds, 2px `surfaceContainerLowest` border) and 48px filled `play` button (`secondary` bg, `AppRadius.lg`, shadow).
- **FAB added**: 56px `secondary` FAB with `plus` icon, `AppRadius.lg` shape, navigates to `AppRoutes.workoutBuilderCreate`.
- **`SavedWorkoutLibraryScreen` updated**: `_ListView` padding updated to `top: lg, horizontal: md, bottom: xxl + xl` for FAB clearance. `_EmptyView` and `_ErrorView` text styles updated to use `AppTextStyles`. Extracted `onTap` callback for card tap → `workoutBuilderEdit`.
- **New private widgets**: `_StackedCategoryIcons` and `_CategoryIconCircle` for the overlapping icon circles.
- **Files**: `lib/features/programmes/presentation/widgets/saved_workout_list_tile.dart`, `lib/features/programmes/presentation/saved_workout_library_screen.dart`.
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing (M3 smoke flow).

### Convention violation fixes — private widget method, cs param, raw numbers

- **`_buildExerciseListView` → `_ExerciseListView` widget class**: Private method returning a `Widget` extracted into a proper `StatelessWidget` class, per `rules.md` ("Use small, private `Widget` classes instead of private helper methods that return a `Widget`").
- **`_SupersetGroupWidget` `cs` param removed**: Widget now uses `context.colorScheme` in `build()` instead of receiving `ColorScheme` via constructor, matching the file-wide convention of extracting `cs` from `context.colorScheme` (via ThemeX extension).
- **Raw `4` border width**: `BorderSide(width: 4)` → `2 * AppSizing.strokeWidth`.
- **`AppFontSizes.sm` as padding**: `right: AppFontSizes.sm` → `right: AppSpacing.md - AppSpacing.xxs` (preserves 14px intent with spacing tokens).
- **`_selectionCount` getter inlined**: Both call sites replaced with `selectedSupersetIds.length`, getter removed.
- **Superset badge in `_SupersetGroupWidget`**: Inline `Container`/`Text` (with `secondaryContainer`/`onSecondaryContainer`, `AppRadius.full`, uppercase, custom padding, `FontWeight.w700`) replaced with shared `AppBadge` component.
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing (M3 smoke flow).

## 2026-07-05

### Workout builder — inline superset selection replaces bottom sheet

- **Inline superset selection**: Tapping "Create Superset" now enters inline selection mode (`_isSupersetSelectionMode`) instead of opening `SupersetEditorSheet` bottom sheet. Exercise cards show check circles; selected exercises get secondary border + shadow. "Cancel Selection" link replaces "Create Superset" in the header; "Group Exercises (N Selected)" button appears below the add-exercise button.
- **Removed `SupersetEditorSheet` import** from `workout_builder_screen.dart` — no longer used.
- **Added `AppStrings.cancelSelection`** ('Cancel Selection') to `app_strings.dart`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Workout builder screen redesign — superset grouping, DropdownButton TYPE, new CTA

- **Superset grouping in exercise list**: `_ExerciseListPanel` rewritten to group exercises by `supersetGroupId` into `_SupersetGroupWidget` (left border + inline superset badge). Preserves original exercise order; ungrouped exercises render individually.
- **"Create Superset" header link**: Exercise list header shows "Exercises (N)" + icon + text link. Initially wired to `SupersetEditorSheet` bottom sheet, later replaced by inline selection mode.
- **`_ConfigPanelHeader` redesigned**: Exercise name now uses `headlineMd`; superset badge + "CONFIGURATION" label side by side below name; delete button preserved.
- **`_SetTableRow` TYPE column**: Changed from `GestureDetector` toggle to `DropdownButton` with `setTypeOptions` — matches HTML design.
- **`_FooterSection`**: Changed save button to "Next: Review & Publish" with `arrow_forward` icon, rounded-full shape, increased padding.
- **Cleanup**: Removed unused `superset_grouping_policy.dart` import, `displayIndex` variable, and string interpolation warning.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Badge unification — SupersetGroupBadge, _PhaseBadge, _DifficultyBadge all delegate to AppBadge

- **AppBadge extended**: Added `EdgeInsetsGeometry? padding` and `TextStyle? textStyle` optional params to support custom padding and text-style overrides without losing the shared badge pattern.
- **`SupersetGroupBadge`** (`superset_group_badge.dart`): Rewrote `build()` to delegate to `AppBadge` — passes custom padding (`xs`/`xxxs`), `borderRadius: AppRadius.xxs`, `textStyle: AppTextStyles.labelSm`, and `primaryContainer`/`onPrimaryContainer` colors. Public API (`groupId`, `order`) and test unchanged.
- **`_PhaseBadge`** removed from `programme_calendar_header.dart`: Inlined `AppBadge` at the single usage site with `borderRadius: AppRadius.full`, custom padding (`md`/`xxs+1`), `letterSpacing: 0.02`, and `surfaceContainerHigh`/`onSecondaryFixedVariant` colors.
- **`_DifficultyBadge`** (`add_exercise_bottom_sheet.dart`): Rewrote `build()` to delegate to `AppBadge` — keeps its color-resolution switch and `_formatLabel` helper, passes resolved `bg`/`text` colors, custom padding (`sm`/`xs`), and `textStyle: AppTextStyles.headlineXl.copyWith(fontSize: AppFontSizes.xxs, letterSpacing: 0.5)`.
- **6 private `_Badge`/badge-like widget definitions now consolidated into 1 shared `AppBadge`** + 2 thin public wrappers (`SupersetGroupBadge`, `_DifficultyBadge`).
- Verification: `dart format .` — 2 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### _Badge extraction — 3 private definitions unified into shared AppBadge component

- **New shared widget** `lib/shared/components/app_badge.dart` — `AppBadge` StatelessWidget with required `label`, optional `backgroundColor`/`foregroundColor` (defaults to `secondary`/`onSecondary`), `borderRadius` (default `AppRadius.sm`), `fontWeight`, and `letterSpacing`.
- **Removed 3 private `_Badge` definitions** from `home_screen.dart`, `programme_list_tile.dart`, `programmes_screen.dart`.
- **7 usage sites updated**: `home_screen.dart` (3 sites, uses defaults), `programme_list_tile.dart` (2 sites, `textColor` renamed to `foregroundColor`), `programmes_screen.dart` (2 sites, passes explicit `borderRadius: AppRadius.defaultRadius`, `fontWeight: FontWeight.w500`, `letterSpacing: 0.02` to preserve existing appearance).
- Verification: `dart format .` — 1 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Convention compliance audit — fixed ~90 token, color, and navigation violations across 10 files

- **Audit scope**: Systematic check of all enforceable rules from `AGENTS.md` and `rules.md` across `lib/`. 12 rule categories passed cleanly; ~90 violations fixed across 10 files.
- **Hardcoded colors → theme tokens**:
  - `finish_early_dialog.dart`: `Color(0x26000000)` → `context.colorScheme.shadow.withAlpha(38)`, `Colors.black.withValues(alpha: 0.4)` → `context.colorScheme.scrim.withAlpha(102)`
  - `exit_workout_sheet.dart`: `Color(0x140052d5)` / `Color(0x0a0052d5)` → `context.colorScheme.secondary.withAlpha(20/10)`
  - `finish_early_session_complete_screen.dart`: `Colors.white.withAlpha(128)` → `context.colorScheme.outlineVariant.withAlpha(128)`, `Colors.black.withAlpha(10)` → `context.colorScheme.shadow.withAlpha(10)`
  - `programme_workout_detail_screen.dart`: `Colors.white` → `context.colorScheme.onSecondary`
- **Raw spacing → `AppSpacing.*` / `AppWhiteSpace.*`**: Replaced ~40 `SizedBox(height:/width:)` with `AppWhiteSpace.*` tokens and ~18 `EdgeInsets.all/symmetric/only/fromLTRB` with `AppSpacing.*` tokens across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `exit_workout_sheet.dart`, `programme_workout_detail_screen.dart`.
- **Raw border radius → `AppRadius.*`**: Replaced 11 `BorderRadius.circular(n)` with `AppRadius.md` / `AppRadius.full` / `AppRadius.defaultRadius` across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `programmes_screen.dart`.
- **Raw icon sizes → `AppSizing.*`**: Replaced 9 `size:` values with `AppSizing.iconSm/Md/Xxl` across `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `workout_builder_screen.dart`.
- **New token**: `AppSizing.decorativeIcon = 128` added to `app_spacing.dart` for one-off decorative icon.
- **`Navigator.of(context).pop()` → `context.pop()`**: Fixed 3 remaining calls in `finish_early_dialog.dart` and `workout_complete_screen.dart`.
- **Commented code removed**: 42-line commented-out `ListTile` block in `bottom_nav_shell.dart`.
- **`boxShadow: const` removed from `exit_workout_sheet.dart`** and `finish_early_dialog.dart` — `const` arrays cannot contain `.withAlpha()` method calls.
- **Restored missing import**: `workout_runner_session_view_data.dart` import added back to `workout_complete_screen.dart`.
- Files: `app_spacing.dart`, `finish_early_dialog.dart`, `exit_workout_sheet.dart`, `programme_workout_detail_screen.dart`, `workout_complete_screen.dart`, `finish_early_session_complete_screen.dart`, `workout_builder_screen.dart`, `programmes_screen.dart`, `bottom_nav_shell.dart`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure (M3 smoke flow library browse).

### ProgrammeTemplateQuickCreateSheet — narrowed empty-setState rebuild to ListenableBuilder

- **`programme_template_quick_create_sheet.dart`**: Removed `onChanged: (_) => setState(() {})` from the template name `AppTextField` — previously every keystroke rebuilt the entire bottom sheet (exercise list, count text, button) just to re-evaluate the Create button's enabled state.
- **New pattern**: Create button wrapped in `ListenableBuilder(listenable: _nameController, builder: ...)`. Only the button rebuilds on keystrokes. Exercise add/remove still uses `setState` (the exercise list itself changes).
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Timer widgets — migrated from setState to ValueNotifier + ValueListenableBuilder

- **`RestTimerWidget`** (`rest_timer_widget.dart`): `int _remaining` → `ValueNotifier<int> _remaining`. Timer ticks and `_adjust()` now write to `_remaining.value` instead of `setState`. Timer display (circular progress + time text + label) wrapped in a single `ValueListenableBuilder<int>` — only that subtree rebuilds each tick.
- **`WorkoutRunnerHeader`** (`workout_runner_header.dart`): Timer-driven `setState(() {})` → `_tick` `ValueNotifier<int>` incremented each second. Elapsed `Text` wrapped in `ValueListenableBuilder<int>` — header title, button, and clock icon no longer rebuild every second.
- Both files now have zero `setState` calls. Timer-scoped rebuilds replace full-widget rebuilds.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure (M3 smoke flow library browse).

### AppTextField — shared text field widget with focus dismissal (replaces all raw TextField/TextFormField)

- **New widget**: `AppTextField` at `lib/shared/components/app_text_field.dart` — wraps `TextField`/`TextFormField` with built-in `onTapOutside` unfocus. Supports `enableObscureToggle` for API key fields, `style`, `isDense`, `suffixText`/`suffixStyle`, `borderOverride`, `borderRadius`, and all standard text field parameters. Auto-selects `TextFormField` when `validator` is non-null, `TextField` otherwise.
- **Replaced all 16 raw `TextField`/`TextFormField` usages** across 14 files with `AppTextField`.
- **Controller leak fix**: `_SearchBar` in `exercise_library_screen.dart` converted from `StatelessWidget` to `StatefulWidget` — `TextEditingController` now properly created in `initState` and disposed in `dispose()`.
- **Removed 4 private wrapper classes**: `_InputField` (workout_builder_screen), `_FormField` (profile_screen + onboarding_screen variants), `_ApiKeyField` (byok_settings_screen), `_ByokFormWidgetState` (onboarding_screen).
- **Cleaned up `_obscured` `ValueNotifier`** from `_ApiKeyFieldState` and `_ByokFormWidgetState` — obscure toggle now managed internally by `AppTextField.enableObscureToggle`.
- **Test updates**: `byok_settings_screen_test`, `m3_setup_smoke_flow_test`, `workout_runner_set_row_test` — `find.byType(TextFormField)` → `TextField`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1051 passed, 1 pre-existing failure (M3 smoke flow library browse test, pre-dates this change).

### WorkoutCompleteScreen — new normal-completion screen matching HTML design

- **New screen**: `WorkoutCompleteScreen` at `lib/features/workout_execution/presentation/workout_complete_screen.dart` — a dedicated success screen for workouts that were completed normally (not finished early). Matches the HTML design exactly: filled check_circle hero with pulse glow, 3-column bento stats grid (Duration, Volume, Sets), Aedify Insight card with `auto_awesome` background decoration and `completionInsight` message, Exercise Summary list with chevron_right icons, and a fixed bottom layer with Done + Share Summary buttons.
- **New route**: `sessionComplete` (`/workout/summary`, name `sessionComplete`) added to `AppRoutes` and `app_router.dart`.
- **New strings**: `shareSummary`, `setsLabel`, `volumeLabel`, `completionInsight` added to `AppStrings`.
- **Navigation routing**: `workout_runner_screen.dart` now distinguishes normal completion from early finish. When all sets are completed or skipped, it navigates to `sessionComplete` route. When there are untouched sets (early finish), it navigates to `finishEarlySummary` route.
- **Test updates**: Added `finishEarlySummary` route to test GoRouter for the finish early test case.
- Verification: `dart format .` — passed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing M3 smoke flow failure.

### Session complete screen — workout summary fix, percentage formatting, preferred unit support

- **Bug fix**: Workout summary no longer shows untouched exercises as completed. Replaced `allSkipped || (hasSkipped && !hasCompleted)` with `!hasCompleted` in `_WorkoutSummarySection`.
- **`{percentage}` placeholder**: `AppStrings.recoveryIsProgress` changed from `static const` to `static String recoveryIsProgress(int percentage)`. The insight card now computes completion percentage: volume-based when all sets have prescribed weight/reps, otherwise falls back to set completion ratio.
- **Preferred unit**: `SessionCompleteScreen` converted from `StatelessWidget` to `ConsumerWidget`. Wires `profileControllerProvider` to read `preferredUnits`. Volume stat card and exercise card now show `kg` or `lbs` based on profile preference.
- **Navigation collision fix**: Cancel/abandon flow no longer triggers SessionCompleteScreen navigation. Added `session.status == WorkoutSessionStatus.completed` guard to `pushReplacementNamed` call. Removed redundant `context.pop()` after `completeWorkout()` in exit sheet handler.
- **Test updates**: 3 `workout_runner_screen_test.dart` tests updated for navigation-based completion flow (GoRouter + SessionCompleteScreen expectations).
- Verification: `dart format .` — passed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing M3 smoke flow failure.

### ProgrammeWorkoutDetailScreen — redesigned to match HTML spec (v2)

- Rewrote `ProgrammeWorkoutDetailScreen` to exactly follow the HTML design (iteration 2): no AppBar/back button, `Wrap` for flex-wrap stat rows, Material Icons for stat icons (`fitness_center`, `schedule`, `my_location`), `p-5` (20px) card padding, `gap-5` (20px) image-content gap, `mt-8` (32px) before stats, `mb-1`/`mt-2` (12px total) between name row and stats row, `headline-lg` for "Workout Flow" heading, `rounded-2xl` (16px) on atmospheric section, fixed start button with `play_arrow` icon and `headlineMd` text.
- Added `programmeName`, `focusAreas` to `ProgrammeWorkoutDetailViewData` and `modality` to `ExerciseDetailItem`.
- Updated `ProgrammeWorkoutDetailController` to accept full `Exercise` models and compute focus areas from primary muscles.
- Updated provider to pass full `Exercise` models.
- New AppStrings: `minutes`, `focusLabel`, `workoutFlow`, `movements`, `setsAndReps`, `intensity`, `readyToPush`, `sessionInspirationMessage`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure (M3 smoke flow, unrelated).

### Home screen `durationMinutes` now reflects today's workout only (not entire programme)

- Changed `durationMinutes` calculation on home screen from summing `estimatedDurationMinutes` across all programme templates to resolving only the template for `todayWorkoutId` via `workoutTemplateId` lookup.
- Previously showed total estimated duration of every workout in the programme. Now shows the duration of today's scheduled workout only.
- Verification: `dart format .` — 636 files (1 changed). `flutter analyze` — 0 issues. `flutter test` — 1060 passed, 1 pre-existing failure (M3 smoke flow, unrelated).

### Auto-calculated workout estimated duration from rest times + set count

- Added `computeEstimatedDurationMinutes()` to `WorkoutBuilderDraft` — computes estimated duration per set using tiered fallback: per-set `restSeconds` (priority 1), per-exercise `restBetweenExercisesSeconds` (priority 2), global `restBetweenExercisesSeconds` (priority 3), default 60s (priority 4), plus 60s per set for execution time.
- Updated `WorkoutBuilderController._normalizeDraftForSave()` to call `computeEstimatedDurationMinutes()` and set `estimatedDurationMinutes` before persistence.
- Previously `estimatedDurationMinutes` was never calculated — the field existed in the model but was always null. Now every saved workout auto-computes its estimate from current exercises, sets, and rest values.
- Downstream consumers (home screen, programme calendar) already read `estimatedDurationMinutes` — no changes needed.
- Verification: `dart format .` — 636 files (1 changed). `flutter analyze` — 0 issues. `flutter test` — 1060 passed, 1 pre-existing failure (M3 smoke flow, unrelated).

### Shared `DashedBorderPainter` extracted from workout builder screen

- Extracted `DashedBorderPainter` (was `_DashedBorderPainter`) from `workout_builder_screen.dart` into `lib/shared/widgets/dashed_border_painter.dart`.
- Updated both `workout_builder_screen.dart` and `programmes_screen.dart` to import and use the shared `DashedBorderPainter`.
- Removed duplicate local `_DashedBorderPainter` definition from `programmes_screen.dart`.
- Verification: `dart format .` — 0 changed. `flutter analyze` — 0 issues.

### Schema v12 — `prescribed_reps_exact` column on `set_logs`

- Bumped database schema from `11` to `12`.
- Added nullable `prescribed_reps_exact` (INTEGER) column to `set_logs` table via migration: `ALTER TABLE set_logs ADD COLUMN prescribed_reps_exact INTEGER`.
- Updated `AppDatabase` onCreate logging to record `toVersion: 12`.
- Migration-log and schema-version tests updated for version `12`.
- Files: `lib/core/db/app_database.dart`, `lib/core/db/app_database.g.dart`, `lib/core/db/tables/set_logs.dart`, `test/core/db/app_database_test.dart`, `test/core/db/migration_test.dart`

### ProgrammesScreen — redesigned list with state-aware start/resume CTA

- Rewrote `ProgrammesScreen` with redesigned programme list: each tile shows programme name, goal tags, and a state-aware `WorkoutDetailButtonState` CTA (start/resume/hidden) that reflects the active-session status of the programme's today workout.
- Added `WorkoutDetailButtonState` enum at `lib/shared/domain/workout_detail_button_state.dart` — three states: `start`, `resume`, `hidden`.
- Tapping a programme tile navigates to `ProgrammeCalendarScreen`. The edit action moved to the overflow menu.
- `ProgrammesScreen` now watches `activeWorkoutSessionProvider` to determine CTA state and uses `workoutRunnerControllerProvider.family` for start/resume actions.
- Wired `programmeSyncProvider` refresh trigger for post-save state consistency.
- Files: `lib/shared/domain/workout_detail_button_state.dart`, `lib/features/programmes/presentation/programmes_screen.dart`, `lib/features/programmes/presentation/widgets/programme_day_card.dart`, `lib/app/providers/providers.dart`
- Verification: `dart format .` — passed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Runner exit flow — ExitWorkoutSheet, FinishEarlyDialog, FinishEarlySessionCompleteScreen

- **`ExitWorkoutSheet`** (`lib/features/workout_execution/presentation/widgets/exit_workout_sheet.dart`): Replaces inline exit-confirmation UI with a dedicated bottom sheet showing elapsed session time, session name, and three action buttons — Finish & Save, Pause, Abandon.
- **`FinishEarlyDialog`** (`lib/features/workout_execution/presentation/widgets/finish_early_dialog.dart`): Replaces the old `CancelWorkoutDialog` for early-finish flow with a dedicated dialog that shows session summary (duration, volume, completed sets) and collects optional notes/energy/difficulty before completing.
- **`FinishEarlySessionCompleteScreen`** (`lib/features/workout_execution/presentation/finish_early_session_complete_screen.dart`): New dedicated summary screen for workouts finished early (untouched sets remain). Displays completion percentage, duration, volume, exercise summary with skipped/untouched badges, and Done CTA. Separate from `WorkoutCompleteScreen` which handles full-completion flow.
- Updated `workout_runner_screen.dart` routing: normal completion → `WorkoutCompleteScreen` (sessionComplete route), early finish → `FinishEarlySessionCompleteScreen` (finishEarlySummary route), abandon/cancel → HomeScreen via `context.pop()`.
- New AppStrings: `exitWorkout`, `finishAndSave`, `pauseWorkout`, `abandonConfirm`.
- Files: `lib/features/workout_execution/presentation/workout_runner_screen.dart`, `lib/features/workout_execution/presentation/workout_complete_screen.dart`, `lib/features/workout_execution/presentation/finish_early_session_complete_screen.dart`, `lib/features/workout_execution/presentation/widgets/exit_workout_sheet.dart`, `lib/features/workout_execution/presentation/widgets/finish_early_dialog.dart`, `lib/shared/constants/app_routes.dart`, `lib/app/router/app_router.dart`, `lib/shared/constants/app_strings.dart`, `test/features/workout_execution/presentation/workout_runner_screen_test.dart`
- Verification: `dart format .` — passed. `flutter analyze` — 0 issues. `flutter test` — 1061 passed, 1 pre-existing failure.

### Domain model rest field propagation — SetLogDraft, WorkoutRunnerSetItem, WorkoutSessionDraft

- Added `int? restSeconds` to `SetLogDraft` and `WorkoutRunnerSetItem` domain models with `copyWith` propagation.
- Added `int? restBetweenExercisesSeconds` to `WorkoutSessionDraft` with `copyWith` propagation.
- Updated `WorkoutRunnerMapper.toViewData()`/`toDraft()` to preserve `restSeconds` and `restBetweenExercisesSeconds` in round-trip.
- Updated `StartWorkoutSessionUseCase` to propagate `restSeconds` from set prescriptions and `restBetweenExercisesSeconds` from exercise drafts into session domain models.
- Updated `DriftWorkoutSessionRepository` to persist `restSeconds` on `set_logs` and `restBetweenExercisesSeconds` on `workout_session_exercises` columns.
- Files: `lib/features/workout_execution/domain/set_log_draft.dart`, `lib/features/workout_execution/domain/workout_runner_set_item.dart`, `lib/features/workout_execution/domain/workout_session_draft.dart`, `lib/features/workout_execution/application/workout_runner_mapper.dart`, `lib/features/workout_execution/application/start_workout_session_use_case.dart`, `lib/features/workout_execution/data/drift_workout_session_repository.dart`

### Convention compliance — all `SizedBox` whitespace migrated to `AppWhiteSpace`

- Added `wXxs` and `hXxs` constants to `AppWhiteSpace` in `app_spacing.dart` for the 2px (AppSpacing.xxs) spacing token.
- Replaced all `SizedBox(height: AppSpacing.*)` with `AppWhiteSpace.h*` (~135 occurrences across 55 files).
- Replaced all `SizedBox(width: AppSpacing.*)` with `AppWhiteSpace.w*` (~52 occurrences across 19 files).
- Replaced raw-number `SizedBox(width: 2)` with `AppWhiteSpace.wXxs` in `workout_builder_screen.dart`.
- Replaced raw-number `SizedBox(width: 40)` with `AppWhiteSpace.custom(width: AppSizing.handleWidth)` in `workout_builder_screen.dart`.
- Files: `lib/shared/theme/app_spacing.dart` + 60 feature files.
- Verification: `dart format .` — 0 unchanged. `flutter analyze` — 0 issues. `flutter test` — 1060 passed, 1 pre-existing failure (M3 smoke flow, unrelated).



### Workout builder screen — enhanced sets table, WEIGHT/REST columns, controller lifecycle

- Expanded `_ExerciseConfigPanel` sets table with WEIGHT and REST columns alongside existing SET/TYPE/REPS/TARGET — inline `TextField` editors with proper `TextEditingController` lifecycle managed via `StatefulWidget` (`_SetTableRow`). Weight parsed as `double`, rest as `int`, reps as range or exact, target as RPE range or RIR.
- Added `_SetTableRow` (StatefulWidget) with `_onWeightChanged`, `_onRestChanged`, `_onRepsChanged`, `_onTargetChanged` listeners and `_isSyncing` guard to prevent feedback loops. `_syncControllers` on `didUpdateWidget` preserves cursor position.
- Added `_CoachNotesField` (StatefulWidget) for per-exercise notes textarea — controller lifecycle, `didUpdateWidget` sync on `exerciseId` change.
- Added `_DashedBorderPainter` (`CustomPainter`, later moved to `lib/shared/widgets/dashed_border_painter.dart` as `DashedBorderPainter`) for the dashed-border "Add Exercise" button, `_AddExerciseButton` with plus-circle icon, `_ExerciseMenu` popup menu (duplicate/delete) replacing always-visible icons.
- Added rest seconds display in `_MiniExerciseCard` summary line — shows clock icon + `{restSec}s` when set-level rest is present.
- Added `SetPrescriptionDraft.clearTarget()`, `clearReps()`, `clearWeight()`, `clearRest()` mutation helpers and full `==`/`hashCode` overrides for dirty-state comparison.
- Added `WorkoutBuilderDraft.clearRestBetweenExercises()`, `==`/`hashCode` with `listEquals` for list fields, and `WorkoutBuilderExerciseDraft` `==`/`hashCode`.
- Added `ExerciseReference` `==`/`hashCode` override.
- Added `stack.svg` asset and `OutlinedSvgAssets.stack` for set count icon in mini cards.
- New AppStrings: `weightColumn`, `restColumn`, `configLabel`, `reorderButton`, `defaultRestHint`, `rpeHint`, `secondsUnitAbbreviation`, `duplicateExercise`, `removeSet`.
- Added `AppRadius.xxl = 32` for panel padding.
- Controller: removed mutable `isDirty` field from `WorkoutBuilderState` — replaced with computed `isDirty` getter comparing `draft != originalDraft`. State gains `originalDraft` field. `updateExerciseNotes`, `updateGoalTags`, `updateDescription`, `updateRestBetweenExercises` all simplified with no `isDirty: true`.
- `LoadWorkoutDraftUseCase` now accepts optional `ExerciseDao` — resolves `modality` per exercise from DB for badge display; `goalTags` decoded from JSON string list instead of `GoalTag` enum.
- `SaveWorkoutDraftUseCase` uses raw string goal tags (`Set<String>`) — removed `_goalTagFromString`.
- `SavedWorkoutDraft.goalTags` type changed from `Set<GoalTag>` to `Set<String>`.
- `DriftSavedWorkoutRepository` serializes goal tags with `jsonEncode(draft.goalTags.toList())` instead of `EnumCodec.encodeSet`.
- `AppTheme`: added `surfaceTintColor` to light and dark `AppBarTheme`.
- Provider `loadWorkoutDraftUseCaseProvider` now injects `exerciseDaoProvider`.
- Integration test uses `createNewWorkout` string assertion and `ensureVisible` for add exercise button.
- Controller tests (4 groups) add `loadWorkoutDraftUseCaseProvider` override.
- M4 tests: `GoalTag.generalFitness` replaced with `'general_fitness'` string.
- Files: `lib/features/workout_builder/presentation/workout_builder_screen.dart`, `lib/features/workout_builder/application/workout_builder_controller.dart`, `lib/features/workout_builder/application/workout_builder_state.dart`, `lib/features/workout_builder/application/load_workout_draft_use_case.dart`, `lib/features/workout_builder/application/save_workout_draft_use_case.dart`, `lib/features/workout_builder/domain/exercise_reference.dart`, `lib/features/workout_builder/domain/set_prescription_draft.dart`, `lib/features/workout_builder/domain/workout_builder_draft.dart`, `lib/features/workout_builder/domain/workout_builder_exercise_draft.dart`, `lib/features/workout_builder/domain/saved_workout_draft.dart`, `lib/features/workout_builder/data/drift_saved_workout_repository.dart`, `lib/app/providers/providers.dart`, `lib/app/theme/app_theme.dart`, `lib/shared/constants/app_strings.dart`, `lib/shared/constants/svg_assets_outlined.dart`, `lib/shared/theme/app_spacing.dart`, `assets/svgs/outline/stack.svg`, `test/features/workout_builder/application/workout_builder_controller_test.dart`, `test/features/workout_builder/presentation/workout_builder_integration_test.dart`, `test/app/m4/m4_manual_tracker_acceptance_test.dart`, `test/app/m4/m4_privacy_integrity_blockers_test.dart`

### Exercise picker bottom sheet — expanded difficulty badges (4 tiers), restyled cards

- Redesigned `AddExerciseBottomSheet` as full-height container with handle bar, close button + "Add Exercise" header, pill-shaped search bar with magnifying glass and filter icons, horizontal muscle-group filter chips (All/Chest/Back/Legs/Shoulders/Arms/Core), single-column exercise card list with colored initial-letter avatar, tag chips, and animated bottom action bar with selection count + confirm button.
- Expanded difficulty badges from 2 tiers (beginner, intermediate) to 4 tiers (novice, beginner, intermediate, advanced) — each with dedicated color tokens (`difficultyNoviceBg/Text`, `difficultyBeginnerBg/Text`, `difficultyIntermediateBg/Text`, `difficultyAdvancedBg/Text`) in both `AedifyLightColors` and `AedifyDarkColors`.
- Exercise cards show color-coded difficulty badge: novice (blue-tinted), beginner (green), intermediate (orange), advanced (red). Selected cards get secondary border, tinted background, and check-circle overlay.
- 35 new filter-related AppStrings for difficulty labels/descriptions, muscle group names, equipment types, modality types, and filter UI labels.
- Files: `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`, `lib/shared/theme/app_colors.dart`, `lib/shared/constants/app_strings.dart`

### Exercise picker filter sheet

- Created `ExercisePickerFilterSheet` — a full filter bottom sheet triggered by tapping the search suffix icon. Includes multi-select muscle group pills, a 2-column equipment card grid (with Material icons), radio-style difficulty picker with descriptions, iOS-style modality toggles, and Cancel/Apply Filters footer with active filter count badge.
- Fixed header in `AddExerciseBottomSheet` to properly show the "Add Exercise" title alongside the close button.
- Wired the search bar's filter icon to open the new filter sheet.
- Files: `lib/features/workout_builder/presentation/widgets/exercise_picker_filter_sheet.dart`, `lib/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart`
- Verification: `dart format` passed, `flutter analyze` — 0 issues.

## 2026-07-04

### Workout runner completion and active-session integrity

- Completing a workout no longer immediately pops the route. `WorkoutRunnerScreen` now transitions into a dedicated completed-state summary showing workout name, duration, total volume, completed sets, completed exercises, and a `Done` CTA for intentional exit.
- Cleared transient runner UI (`_showRestTimer`, `_restSeconds`) before completion/cancel and added explicit placeholders for `completing` / `cancelling` phases so the interactive runner body cannot linger in an invalid state.
- Fixed the final-set path so logging the last incomplete set auto-completes exactly once and enters the same summary flow as finish-early completion.
- Removed pre-pop invalidation of `workoutRunnerControllerProvider(...)` from finish-early and cancel flows. This prevents the still-mounted screen from rebuilding the auto-starting controller and creating a second persisted `in_progress` session while the route is exiting.
- Hardened session persistence against stale-active state:
  - `WorkoutSessionDao.updateSessionIfInProgress(...)` guards progress writes so a late autosave cannot revive a completed session.
  - `DriftWorkoutSessionRepository.getActiveSession()` now repairs duplicate active rows by abandoning rows superseded by a later completed row and collapsing remaining duplicates to the most recent in-progress session.
  - `completeSession()` abandons sibling in-progress rows for the same workout identity immediately after completion.
  - `startSession()` performs the in-progress count check inside the transaction step instead of before transaction execution.
- Added regression coverage for finish-early route exit, final-set auto-completion, late progress-save race protection, and duplicate active-session repair / sibling abandonment.
- Files: `lib/features/workout_execution/presentation/workout_runner_screen.dart`, `lib/core/db/daos/workout_session_dao.dart`, `lib/features/workout_execution/data/drift_workout_session_repository.dart`, `test/features/workout_execution/presentation/workout_runner_screen_test.dart`, `test/features/workout_execution/data/drift_workout_session_repository_test.dart`

### Programme builder save/load correctness and refresh flow

- Fixed a multi-week save bug where programme expansion only reused slot-day configuration from week 1. `ProgrammeDraft` now carries `weekSlotDayIndices` and `weekSlotTemplateIds`, and the repository uses week-specific slot config when available.
- Fixed edit-mode slot reconstruction by using the slot's sequential position within the week instead of `scheduledDayIndex` as `slotIndex`.
- Restored saved day labels on edit by decoding `scheduledDayIndex` back into `TrainingDay`.
- Added an optional day-of-week picker to workout slots in the programme builder. Users can tap the slot day label to override the assigned day via a bottom sheet; slots still fall back to auto-assignment when no override is chosen.
- Fixed post-save refresh behavior:
  - programme list refresh now uses explicit `reload()` after `context.pop()` instead of relying on a lost invalidation signal
  - programme calendar refresh now also calls `reload()` on the family controller after save when editing an existing programme
- Files: `lib/features/programmes/domain/programme_draft.dart`, `lib/features/programmes/application/save_programme_builder_draft_use_case.dart`, `lib/features/programmes/application/load_programme_builder_draft_use_case.dart`, `lib/features/programmes/data/drift_programme_repository.dart`, `lib/features/programmes/application/programme_builder_controller.dart`, `lib/features/programmes/presentation/programme_builder_screen.dart`, `lib/features/programmes/presentation/widgets/programme_workout_slot_card.dart`, `lib/features/programmes/presentation/widgets/programme_week_card.dart`, `lib/features/programmes/presentation/widgets/programme_weeks_overview.dart`, `lib/shared/constants/app_strings.dart`

### Programme calendar, home sync, and progress resolution

- Extracted shared flat-index progression logic into `TodayWorkoutResolver` so the calendar and home screen agree on which workout counts as "today" when days are skipped or the user starts mid-week.
- Fixed calendar completion state to come from resolved workout-session data (`completedWorkoutIds`) instead of the never-updated `program_workouts.status` column.
- `programmeSyncProvider` now watches the programme library controller as a data dependency, and `homeRefreshTriggerProvider` forces home-screen-related providers to refresh after completion/cancel so home and calendar state update immediately.
- Fixed the runner rest-timer trigger to respect the default 60-second fallback by always calling `RestResolver.effectiveRest()`.
- Active programme progress now reflects the current week instead of total programme count:
  - `ProgrammeListItem` now carries `startDateLocal`
  - home progress uses current-week sessions remaining and completion ratio
  - current week is derived consistently from start date / flat-index resolution
- Completed workouts now reflect correctly across the programme surfaces:
  - today's completed workout shows a checkmark in the calendar
  - the home today-workout card hides when no incomplete workout remains for today
  - home and calendar both use active-session-aware resume / disable logic for start buttons when another workout session is already in progress
- Files: `lib/app/providers/providers.dart`, `lib/features/home/presentation/home_screen.dart`, `lib/features/programmes/application/today_workout_resolver.dart`, `lib/features/programmes/application/list_programmes_use_case.dart`, `lib/features/programmes/application/programme_calendar_controller.dart`, `lib/features/programmes/domain/programme_list_item.dart`, `lib/features/programmes/presentation/programme_calendar_screen.dart`, `lib/features/programmes/presentation/widgets/programme_calendar_header.dart`, `lib/features/programmes/presentation/widgets/programme_day_card.dart`, `lib/features/workout_execution/application/workout_runner_controller.dart`, `lib/shared/domain/week_calculator.dart`

### Saved workout persistence moves to soft delete; schema v11

- Bumped the database schema from `10` to `11`.
- Added nullable `deleted_at` to `saved_workouts` and migrated existing databases with `ALTER TABLE saved_workouts ADD COLUMN deleted_at TEXT NULL`.
- `SavedWorkoutDao.getAll()` and `getByStatus()` now exclude soft-deleted rows.
- `DriftSavedWorkoutRepository.deleteSavedWorkout()` now performs a soft delete by setting `status = 'deleted'`, `deletedAt`, and `updatedAt` instead of deleting the saved-workout root row.
- Updated schema-version and migration-log tests for version `11`.
- Files: `lib/core/db/app_database.dart`, `lib/core/db/app_database.g.dart`, `lib/core/db/tables/saved_workouts.dart`, `lib/core/db/daos/saved_workout_dao.dart`, `lib/features/workout_builder/data/drift_saved_workout_repository.dart`, `test/core/db/app_database_test.dart`, `test/core/db/migration_test.dart`

### Programme/library navigation and UI refinements

- `ProgrammesScreen` now treats tapping a programme as navigation into the programme calendar, while edit moved into the overflow menu as an explicit action.
- `ProgrammeListTile` now shows the primary goal label from `goalTags` instead of a placeholder and remains fully tappable as a details entry point.
- `ProgrammeCalendarScreen`, `ProgrammeCalendarHeader`, `ProgrammeWeekSection`, and `ProgrammeDayCard` were visually refined:
  - current week gets a distinct highlighted expanded section
  - today cards and rest-day cards have dedicated presentation states
  - the header uses the active-session-aware start/resume CTA and a cleaner full-bleed layout
- `HomeScreen` now includes a `View details` path from the active programme surface into the programme calendar.
- Removed nested child-screen app bars from the library/programme tab surfaces so the hub shell owns the top chrome consistently.
- Added new SVG assets `leaf` and `meditation`, introduced `AppSizing.iconS`, reduced `iconXs`, and retuned deload-pattern sizing to support the updated programme/calendar visuals.
- Files: `lib/features/programmes/presentation/programmes_screen.dart`, `lib/features/programmes/presentation/widgets/programme_list_tile.dart`, `lib/features/programmes/presentation/programme_calendar_screen.dart`, `lib/features/programmes/presentation/widgets/programme_calendar_header.dart`, `lib/features/programmes/presentation/widgets/programme_day_card.dart`, `lib/features/programmes/presentation/widgets/programme_week_section.dart`, `lib/features/home/presentation/home_screen.dart`, `lib/features/exercise_library/presentation/exercise_library_screen.dart`, `lib/features/library/presentation/library_hub_screen.dart`, `lib/features/programmes/presentation/saved_workout_library_screen.dart`, `lib/features/bodymap/presentation/bodymap_screen.dart`, `lib/features/bodymap/presentation/widgets/bodymap_bucket_chip_bar.dart`, `lib/shared/constants/svg_assets_outlined.dart`, `lib/shared/constants/svg_assets_solid.dart`, `lib/shared/theme/app_spacing.dart`, `assets/svgs/outline/leaf.svg`, `assets/svgs/solid/meditation.svg`

### Verification snapshot

- Fresh verification run on 2026-07-04:
  - `dart format .` — passed (`Formatted 634 files (0 changed) in 1.35 seconds`)
  - `flutter analyze` — passed (`No issues found!`)
  - `flutter test` — 1060 passed, 1 failed
- The single failing test remains `test/app/m3/m3_setup_smoke_flow_test.dart: M3 Setup Smoke Flow library browse: exercise list screen renders with empty state`.
- Result: the latest schema v11 soft-delete work and programme/library UI refinements did not introduce new format or analyzer issues; the test sweep still has the same outstanding M3 smoke-flow failure.

## 2026-07-03

### Programme builder: goal tags and week type save/load roundtrip fix

- **Goal tags now restored on edit** (`LoadProgrammeBuilderDraftUseCase.loadForEdit()`): `goalTags` and `equipment` are now decoded from `goalTagsJson`/`equipmentJson` via `EnumCodec.decodeSet` — previously they were silently dropped on load, so saved tags appeared empty when reopening a programme.
- **Week type now persisted on save** (`DriftProgrammeRepository._insertExpandedProgramRows()`): Added `List<WeekType?>? weekTypes` to `ProgrammeDraft` domain model. `SaveProgrammeBuilderDraftUseCase` now extracts week types from builder weeks. The repository passes the value to `_buildProgramWeekCompanion(weekType: ...)` instead of always `null`.
- **Week type now restored on edit** (`LoadProgrammeBuilderDraftUseCase.loadForEdit()`): Reads `w.weekType` and passes `WeekType.fromDb()` to `ProgrammeBuilderWeekDraft(weekType: ...)`.
- Files changed: `programme_draft.dart`, `save_programme_builder_draft_use_case.dart`, `drift_programme_repository.dart`, `load_programme_builder_draft_use_case.dart`.

### Full failing-test sweep to green

- **Full suite green**: `flutter test` now passes cleanly at **1056/1056**.
- **Workout builder warmup ordering fix**: `WorkoutBuilderController.addSet(..., setType: SetType.warmup)` now inserts warmup sets before working sets, fixing an unsaveable-workout bug exposed by tests.
- **DB version / migration test repairs**: Updated schema-version expectations to `10` and fixed `AppDatabase` on-create migration logging from `toVersion: 9` to `toVersion: 10`.
- **Router-backed widget tests**: Repaired dialog and bottom-sheet widget tests that now rely on `context.pop()` by wrapping them in `GoRouter`-backed harnesses. Covered workout builder, workout runner, custom exercise, BYOK settings, programme builder, and template reassignment surfaces.
- **Runner autosave test stability**: Updated debounce tests to keep the `autoDispose` workout-runner provider alive while timers elapse.

### Workout builder save-time warmup normalization

- **Editing behavior preserved**: Adding a warmup set no longer immediately reorders the draft while the user is editing.
- **Save-time reordering**: `WorkoutBuilderController.saveWorkout()` now normalizes each exercise before validation/persistence so all warmup sets are saved before working sets, while preserving relative order within each group.
- **Edit-mode consistency**: After a successful save in edit mode, the controller state is updated to the normalized set order so the UI matches what was persisted.
- **Coverage**: Added/updated workout-builder controller tests for mixed pre-save order, normalized saved payload order, and normalized post-save edit state.

### Workout runner lifecycle hardening + HomeScreen in-progress card

- **Lifecycle hardening** (extends 2026-07-02 fix): `autoSave` timer cancelled on `completeWorkout()`/`cancelWorkout()` — prevents save-after-complete race. `autoSave` now guards on `session.status == inProgress`. `activeWorkoutSessionProvider` invalidated after start/resume/save/complete/cancel — consumers reflect current session state immediately.
- **Cancel pops runner**: After `cancelWorkout()` succeeds, dialog invalidates controller provider and calls `context.pop()`, returning to HomeScreen.
- **HomeScreen ongoing card**: `_OngoingWorkoutCard` shown when `activeWorkoutSessionProvider` returns a session — progress (completed/total sets), elapsed time, resume button, discard button (calls `AbandonWorkoutSessionUseCase` + refreshes provider).
- **New provider**: `AppProviders.activeWorkoutSessionProvider` — `FutureProvider<WorkoutRunnerSessionViewData?>`.

### Rest timer wiring + warmup chip in runner

- **Rest timer duration-aware**: `onSetLogged` passes `int restSeconds` computed via `RestResolver.effectiveRest(setRest:, exerciseRest:)`. Timer starts with resolved duration (set-level > exercise-level > 60s default).
- **Log set gating**: Button disabled until both `actualWeightKg` and `actualReps` entered — prevents logging incomplete sets.
- **Active set index recomputed per build**: Removed mutable `_activeSetIndex` from `_SetTableState` — derived statically from completion state.
- **Warmup chip in runner**: `SetTypeChip` shown for warmup sets in runner's `_SetTable`.
- **`copyWithActuals` preserves rest**: `restSeconds` propagated. Params changed from `double?`/`int?` to `String?` with parse in body.

### DB schema v10 — rest columns + warmup validation

- **Schema v10**: Added `restSeconds` (nullable int) to `set_logs`, `restBetweenExercisesSeconds` (nullable int) to `workout_session_exercises`. v9→v10 migration.
- **Warmup ordering validation**: `DefaultDraftValidationService._validateSetOrdering()` — detects warmup sets after working sets. `DraftValidationCode.warmupSetOrdering`, `AppStrings.warmupSetsMustComeFirst`.
- **Saved workout delete simplified**: `DriftSavedWorkoutRepository.deleteSavedWorkout()` always hard-deletes (removed archive-on-history conditional). DAO `deleteById()` added.

### Domain + data-layer rest field propagation

- **Domain models**: `restSeconds` on `SetLogDraft` / `WorkoutRunnerSetItem`. `restBetweenExercisesSeconds` on `WorkoutSessionExerciseDraft`. All with `copyWith`.
- **Load use case**: Maps `restBetweenExercisesSeconds` from saved workout aggregate. Fixes `exerciseRef` → `exercise.name`.
- **Start use case**: Propagates `restSeconds` from set prescriptions and `restBetweenExercisesSeconds` from exercise drafts (saved + program paths).
- **Mapper**: `toViewData()`/`toDraft()` preserve rest fields in round-trip.
- **Repository**: Writes `restSeconds` / `restBetweenExercisesSeconds` columns when saving session.

### Workout builder rest field StatefulWidget extraction

- **`_RestField`** (`workout_builder_screen.dart`): Extracted from inline `TextField` + `TextEditingController.fromValue(...)` to `StatefulWidget` with controller lifecycle — fixes cursor loss on rebuild.
- **`_ExerciseRestField`** (`workout_exercise_card.dart`): Same extraction for per-exercise rest field.

### New AppStrings

- `warmupSetsMustComeFirst`, `workoutInProgress`, `discardWorkout`.

- Verification: `dart format` — pending. `flutter analyze` — pending. `flutter test` — pending.

## 2026-07-02

### Workout runner abandon/restart fix

- **Runner provider lifecycle**: `AppProviders.workoutRunnerControllerProvider` is now `autoDispose.family`, so reopening the same saved workout or programme workout does not reuse a stale controller instance after the screen is dismissed.
- **Cancel flow reset**: `workout_runner_screen.dart` now invalidates the current runner provider instance after `cancelWorkout()` succeeds and immediately pops the runner screen, preventing an abandoned in-memory session from being reused on the next launch.
- **Regression coverage**: `workout_runner_screen_test.dart` now covers abandoning a workout, leaving the runner, reopening the same workout, and verifying that a fresh session is started.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test test/features/workout_execution/presentation/workout_runner_screen_test.dart` — passed. `flutter test` — not clean due pre-existing unrelated failures in BYOK/workout-builder widget tests and Flutter test runner shutdown errors.

### Convention compliance sweep — hardcoded strings + raw layout values

- **30 new `AppStrings` constants** added — 8 missing equipment labels, 12 BYOK provider/model display names, 3 custom exercise validation messages, 2 rest timer labels, 2 duration abbreviations.
- **`profile_screen.dart` taxonomy** (26 strings): Replaced all hardcoded experience/goal/equipment labels in `_ProfileTaxonomy` and chip `options:` lists with `AppStrings` constants. Also replaced `suffixText: 'min'` with `AppStrings.onboardingReviewMinutes`.
- **`onboarding_screen.dart` taxonomy** (14 strings): Replaced hardcoded goal labels and 8 remaining equipment labels in `_OnboardingTaxonomy` with `AppStrings` constants.
- **`drift_byok_repository.dart`** (12 strings): Replaced all provider `displayName:` and model `displayName:` values with `AppStrings` constants.
- **`custom_exercise_validator.dart`** (3 strings): Replaced validation messages with `AppStrings` constants.
- **`custom_exercise_editor_controller.dart`** (2 strings): Replaced error messages with existing `AppStrings.customExerciseSaveFailed` / `customExerciseDeleteFailed`.
- **`custom_exercise_error_banner.dart`** (1 string): Replaced `'Retry'` with `AppStrings.retry`.
- **`programme_calendar_controller.dart`** (1 string): Replaced `'Active Recovery'` with `AppStrings.activeRecovery`.
- **`rest_timer_widget.dart`** (2 strings): Replaced `'-15s'` / `'+15s'` with `AppStrings.restMinus15` / `restPlus15`.
- **`complete_workout_sheet.dart`** (1 string): Replaced `'$minutes min'` to use `AppStrings.onboardingReviewMinutes`.
- **`workout_history_detail_screen.dart`** (2 strings): Replaced `'h'` / `'m'` duration abbreviations with `AppStrings.durationHoursAbbreviation` / `durationMinutesAbbreviation`.
- **Raw layout values → tokens**: Added 20 new `AppSizing` tokens (`videoCardHeight`, `videoPreviewHeight`, `emptyStateHeight`, `restTimerSize`, `weekTypeDropdownWidth`, `dataFieldWidthSm/Md`, `timerStrokeWidth`, `hairlineStrokeWidth`, `activeIndicatorHeight`, `deloadLineStrokeWidth/Spacing`, `exerciseNumberCircle`, `setNumberColumnWidth`). Replaced 30+ raw values across 10 files — `exercise_detail_screen.dart`, `workout_runner_screen.dart`, `rest_timer_widget.dart`, `week_selector_pills.dart`, `programme_list_tile.dart`, `programme_week_card.dart`, `programme_workout_detail_screen.dart`, `onboarding_screen.dart`, `custom_exercise_editor_screen.dart`, `workout_history_detail_screen.dart`, `pattern_deload_painter.dart`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues.

### Convention compliance sweep — Navigator.pop, EdgeInsets.fromLTRB, TextStyle, Theme.of(context)

- **`Navigator.of(context).pop()` → `context.pop()`** (22 files): Replaced all remaining `Navigator.of(context).pop()`, `Navigator.of(context).pop(true/false)`, and `Navigator.pop(ctx)` with go_router's `context.pop()` / `ctx.pop()`. Added missing `go_router` imports. Affected files: `custom_exercise_editor_screen`, `exercise_detail_screen`, `delete_custom_exercise_dialog`, `discard_custom_exercise_changes_dialog`, `home_screen`, `onboarding_screen`, `profile_screen`, `programme_builder_screen`, `programmes_screen`, `active_programme_warning_dialog`, `add_week_dialog`, `archive_item_dialog`, `delete_item_dialog`, `discard_programme_changes_dialog`, `programme_template_quick_create_sheet`, `template_reassignment_bottom_sheet`, `byok_settings_screen`, `add_exercise_bottom_sheet`, `discard_changes_dialog`, `workout_builder_header`, `workout_builder_screen`, `cancel_workout_dialog`, `workout_runner_screen`.
- **`EdgeInsets.fromLTRB()` → `EdgeInsets.only()`** (4 locations, 3 files): `programme_calendar_header.dart`, `programme_week_section.dart` (×2), `workout_runner_screen.dart`.
- **`TextStyle(...)` → `AppTextStyles.*.copyWith()` / `context.textTheme.*.copyWith()`** (10 locations, 8 files): `exercise_detail_screen.dart` (×2), `home_screen.dart` (×2), `active_programme_warning_dialog.dart`, `add_week_dialog.dart`, `discard_programme_changes_dialog.dart`, `programme_list_tile.dart`, `saved_workout_list_tile.dart`, `workout_runner_screen.dart` (×3).
- **`Theme.of(context).colorScheme` → `context.colorScheme`** (2 files): `delete_custom_exercise_dialog.dart`, `delete_item_dialog.dart`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Final widget-builder helper method sweep — zero violations remaining

- **11 files converted**: `exercise_dataset_status_tile`, `exercise_step_audio_button`, `workout_history_detail_screen`, `exercise_detail_screen`, `exercise_library_screen`, `programme_calendar_header`, `programme_week_section`, `programme_day_card`, `programme_workout_detail_screen`, `onboarding_screen`, `home_screen`.
- **5 deferred helpers also converted** (all previous stragglers now resolved):
  - `home_screen.dart`: `_buildScheduled` → `_ScheduledView` (StatelessWidget), `_buildEmpty` → `_EmptyView` (StatelessWidget).
  - `onboarding_screen.dart`: `_infoPanel` → `_ByokInfoPanel` (StatelessWidget), `_buildForm` + `_saveKey` + mutable fields → `_ByokForm` (ConsumerStatefulWidget).
  - `workout_runner_screen.dart`: `_buildBody` + `_showCompleteSheet` + `_showCancelDialog` → `_WorkoutRunnerBody` (ConsumerWidget).
- **Exhaustive verification**: Grep-confirmed zero non-build methods returning `Widget` in `lib/`. The only non-build widget-returning functions are static `AppWhiteSpace.both`/`custom` factory methods (intentional design-token utilities).
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Final top-level declaration sweep — zero violations remaining

- **Moved `const _items` into `_BottomNavItemData`** in `lib/app/router/bottom_nav_shell.dart:16` — converted from a top-level constant to a `static const` member of the existing private class, with references updated to `_BottomNavItemData.items.length` / `_BottomNavItemData.items[index]`.
- **Moved `_findFirstIncomplete` into `WorkoutRunnerScreen`** in `lib/features/workout_execution/presentation/workout_runner_screen.dart:301` — converted from a top-level helper function to a `static` method of `WorkoutRunnerScreen`, called from within `build()`.
- **Exhaustive verification**: Grep-confirmed zero top-level declarations remain outside `main()` in `main.dart` across all of `lib/`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### HomeScreen — greeting, active programme, today's workout

- **New `HomeScreen`** (`lib/features/home/presentation/home_screen.dart`): 688-line `ConsumerWidget` with time-of-day greeting (good morning/afternoon/evening), user display name from profile, active programme card with tap-to-navigate, today's scheduled workout card with start/resume actions, volume metric card, and quick action grid.
- **Provider wiring**: Wired through `profileControllerProvider` for name, `programmeLibraryControllerProvider` for active programme, `workoutRunnerControllerProvider.family` for session start/resume.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Rest timer widget + workout runner metrics refactor

- **New `RestTimerWidget`** (`lib/features/workout_execution/presentation/widgets/rest_timer_widget.dart`): Animated countdown timer with circular progress, remaining time display, add-30-seconds button, and dismiss action. Uses `AnimationController` + `Timer.periodic` for 1s tick updates.
- **Runner integration**: `WorkoutRunnerScreen` and `WorkoutRunnerHeader` manage rest timer visibility — appears after completing a set, auto-dismisses when elapsed or user taps skip. `WorkoutRunnerExerciseCard` shows effective rest time per exercise.
- **Metrics extraction**: `_CompleteWorkoutMetrics` class extracted from `CompleteWorkoutSheet` — centralizes total volume, completed sets, and completed exercise calculations.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Exercise detail screen — StatefulWidget migration + error handling

- **Converted `ExerciseDetailScreen`** from `ConsumerWidget` to `ConsumerStatefulWidget` — proper lifecycle for video state, audio playback, and async reloads.
- **Improved error states**: Retry button on failure, explicit loading/error/missing states via `_ExerciseDetailState` enum, `ErrorWidget` with CTA.
- **Supporting widgets updated**: `ExerciseVideoCard`, `ExerciseDatasetStatusTile`, `ExerciseStepAudioButton` — error propagation alignment.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Exercise multi-select refactor + onboarding provider structure

- **Multi-select extraction**: Reusable chip patterns extracted from `OnboardingScreen`, `ProfileScreen`, and `AddExerciseBottomSheet` — reduced duplication in exercise/equipment/goal selection.
- **Onboarding providers**: Refactored local provider declarations in `onboarding_screen.dart` — grouped by concern, removed unused providers.
- **Slot day assignment**: Extended `slot_day_assignment.dart` with improved training-day anchor resolution.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Logging sweep — 59 files instrumented across M4 modules

- **Systematic logging**: `AppLogger` integrated into 59 files — all controllers (BYOK, settings, workout builder/runner, programme builder, onboarding, profile, exercise library, sync), all repositories (Drift BYOK/settings/saved-workout/session/programme/history), all use cases (load/save/complete/abandon/start), validators/adapters/services, and core infrastructure (bootstrap, Firebase, network, TTS, transactions, secure storage, file store).
- **Pattern**: Every public method logs entry/exit at appropriate severity — `info` for state transitions, `warning` for recoverable failures, `severe` for unrecoverable errors. No sensitive data included.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Minor refactors and fixes

- **Validation scope rename** (`lib/core/validation/`): `DraftValidationScope.set` → `DraftValidationScope.exerciseSet` across 5 files (service, adapters, tests).
- **Custom exercise editor invalidation** (`custom_exercise_editor_screen.dart`): Controller invalidates provider state on "Done" — ensures fresh state on re-entry.
- **_InfoRow extraction** (`workout_history_detail_screen.dart`): Repeated `_infoRow` helper → standalone `_InfoRow` StatelessWidget.
- **VSCode launch config** (`.vscode/launch.json`): Flutter debug/run configuration for IDE development.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

## 2026-07-01

### Rule-compliance cleanup + failing test repair

- **Top-level declaration cleanup**: Wrapped remaining touched-surface top-level helpers/providers into private classes or static members to comply with the Aedify rule against top-level declarations outside `main()`. This included slot-day assignment, exercise-video label formatting, complete-workout metrics, onboarding/profile exercise multi-select helpers, onboarding local providers, programme workout detail helpers, and profile 1RM helper generation.
- **Programmes screen repair**: Rebuilt `ProgrammesScreen` into a minimal valid library screen wired to `ProgrammeLibraryController`, restoring compile health and correct archive/delete/activate entrypoints.
- **Exercise detail repair**: Restored visible metadata chips (difficulty, modality, equipment, force) and a substitution tooltip so the detail screen once again matches its widget-test contract.
- **Runner test alignment**: Updated the workout-runner widget test to assert the current runner UI contract (`finishEarly`, `logSet`) and suppressed repeated drift warnings in that test file.
- **Widget polish**: Added missing `_TodayBadge` const constructor and removed stale helper-state issues exposed during verification.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Programme goals + status/list visibility fixes

- **Programme builder goals UI**: Added a goal selector to `ProgrammeDetailsSection` using multi-select chips for all `GoalTag` values. Wired `ProgrammeBuilderScreen` to pass current `goalTags` and `ProgrammeBuilderController.setGoalTags(...)`.
- **Programme validation**: Added programme-goal validation so a programme must have at least one goal before save. Added `DraftValidationCode.noGoals`, `AppErrorCodes.noGoals`, `AppStrings.programmeGoalsRequired`, and `ProgrammeBuilderValidator._validateGoals(...)`.
- **Programme status consistency**: Fixed `status` / `active` divergence so activation state is now written consistently across all save and toggle flows:
  - `ProgrammeBuilderController.setProgrammeStatus(...)` now updates both `status` and `active`
  - `SaveProgrammeBuilderDraftUseCase` now derives `active` from `status == ProgramStatus.active`
  - `ProgramDao.clearActiveProgram(...)` now also writes `status: 'inactive'`
  - `ProgramDao.setProgramActive(...)` now writes both `active` and `status`
- **Programme list visibility**: New programmes default to `inactive` instead of `draft`, and both active and inactive programmes are now visible on the list screens:
  - `LoadProgrammeBuilderDraftUseCase.createEmptyDraft()` now defaults to `ProgramStatus.inactive`
  - `ListProgrammesUseCase` no longer filters to `status: 'active'`
  - `ListSavedWorkoutsUseCase` no longer filters to `status: 'active'`
- **Result**: Newly created inactive programmes now appear on `ProgrammesScreen`, and the status chip stays in sync after activation/deactivation.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Deload week flag + three-tier rest model

- **Deload week**: `ProgrammeBuilderWeekDraft` now has `WeekType? weekType` field. `ProgrammeWeekCard` shows a dropdown with all 6 `WeekType` values (normal, deload, test, taper, hypertrophy, strength). Controller `setWeekType` added.
- **Rest resolver** (`lib/shared/domain/rest_resolver.dart`): `RestResolver.effectiveRest(set?, exercise?, workout?)` resolves the three-tier chain → defaults to 60s when all null.
- **Domain models** (5 files): Added `int? restBetweenExercisesSeconds` to `WorkoutBuilderDraft`, `WorkoutBuilderExerciseDraft`, `ProgrammeBuilderTemplateDraft`, `ProgrammeExerciseDraft`, `ProgrammeBuilderDraft`. Added `restBetweenExercisesSeconds` to persistence drafts `SavedWorkoutDraft` and `SavedWorkoutExerciseDraft`.
- **Drift migration v8→v9**: Added 4 nullable `restBetweenExercisesSeconds` columns to `saved_workouts`, `saved_workout_exercises`, `program_workout_templates`, `program_template_exercises`.
- **Controllers**: `WorkoutBuilderController` +`updateRestBetweenExercises` and `updateExerciseRest`. `ProgrammeBuilderController` +`setWeekType` and `updateTemplateRestBetweenExercises`.
- **Repository**: `DriftSavedWorkoutRepository` companion builders map new rest columns. `SaveWorkoutDraftUseCase` maps rest fields from builder to persistence draft.
- **UI**: `ProgrammeWeekCard` shows week type dropdown. `ProgrammeWeeksOverview` passes `onSetWeekType` callback. `ProgrammeBuilderScreen` wires both deload and template rest.
- **Strings**: `workoutRestLabel`, `workoutRestHint`, `restSecondsUnit`, `weekTypeLabel`.
- **Tests**: `rest_resolver_test.dart` (6 tests), `programme_builder_controller_test.dart` (setWeekType test). Migration and schema version tests updated for v9.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1053/1053 passed.

### Day-of-week selection — onboarding + programme defaults

- **Onboarding schedule step**: Replaced number picker (1-7) with day-of-week toggle (Mon-Sun) using `TrainingDay.displayLabel`. Users now select exact workout days. `trainingDaysPerWeek` is derived from `trainingDays.length`.
- **Onboarding controller**: `_resumeStepForDraft` and `_validateStep` now check `trainingDays.isEmpty` instead of `trainingDaysPerWeek`.
- **Review step**: Displays selected day names instead of just the count.
- **`TrainingDay`**: Added `displayLabel` getter (Mon/Tue/Wed/...).
- **`ProgrammeBuilderWorkoutSlotDraft`**: Added `TrainingDay? scheduledDay` field + `copyWith`.
- **Slot day assignment algorithm** (`lib/features/programmes/application/slot_day_assignment.dart`): Derives calendar-ordered days from training anchors. Supports day-of-week selection enforcement for future >7 slot weeks.
- **Programme builder screen**: `onAddSlot` now reads profile `trainingDays` and computes `scheduledDay`/`scheduledDayIndex` using the algorithm.
- **`ProgrammeBuilderController.addSlot()`**: Now accepts optional `TrainingDay? scheduledDay`.
- **Programme slot card**: Shows `scheduledDay?.displayLabel` or fallback.
- **Validator**: Added `scheduledDayRequired` error for weeks with >7 slots where slot days aren't explicitly set.
- **AppStrings** (+1): `scheduledDayRequired`. **AppErrorCodes** (+1): `noScheduledDay`.
- **Tests updated**: Onboarding controller/screen tests use day toggle taps. M3 smoke flow updated. All pre-existing tests pass.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1043/1043 passed.

### V1-M4-011 — M4 manual tracker acceptance suite (complete)

- **Test harness** (`test/app/m4/m4_test_harness.dart`): App-level pump helper with provider overrides for savedWorkoutRepository, programmeRepository, workoutSessionRepository, exerciseRepository, workoutHistoryRepository, and networkStatus. Mirrors the M3 harness pattern.
- **Fake dependencies** (`test/app/m4/fake_m4_dependencies.dart`): `FakeSavedWorkoutRepository`, `FakeProgrammeRepository`, `FakeWorkoutSessionRepository`, `FakeWorkoutHistoryRepository`, `FakeExerciseRepository`, `FakeNetworkStatus`.
- **Acceptance tests** (`test/app/m4/m4_manual_tracker_acceptance_test.dart` — 8 tests): create custom exercise, create workout, create multi-week programme, start active session + complete, recover active workout, complete + view history, warmup sets visible in history, superset grouping survives.
- **Privacy integrity blocker tests** (`test/app/m4/m4_privacy_integrity_blockers_test.dart` — 4 tests): full offline flow, completion failure leaves session recoverable, history readable after source delete, no sentinel data leaks.
- **Helpers**: `m4_route_driver.dart`, `m4_expectations.dart`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1013/1013 passed.

### V1-M4-010 — Transactional save and rollback service (complete)

- **Core transaction infrastructure** (`lib/core/db/transactions/` — 7 files): `TransactionOperation`, `TransactionFailureInjection`, `NoOpTransactionFailureInjection`, `TransactionExecutionFailure`, `TransactionStep`, `TransactionExecutor` (abstract), `DriftTransactionExecutor`.
- **Test support** (2 files): `ThrowingTransactionFailureInjection` (injects failures before/after named operations), `CapturingTransactionFailureInjection` (records operation sequence).
- **Repository refactor**: `DriftProgrammeRepository`, `DriftSavedWorkoutRepository`, and `DriftWorkoutSessionRepository` now use `TransactionExecutor` instead of raw `_database.inTransaction()`. Each repository exposes step-builder methods with stable operation names.
- **Provider wiring**: Added `transactionFailureInjectionProvider` and `transactionExecutorProvider`. Updated all 3 repository providers to inject `TransactionExecutor`.
- **Removed `_database` field** from all three repositories — the executor now owns the transaction boundary.
- **Tests**: 7 new — 4 core executor tests (step ordering, rollback before, rollback after, error wrapping) + 3 programme repository rollback tests (template insertion, expanded row insertion, root write rollback).
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 1001/1001 passed.

### V1-M4-009 — Reusable draft validation service (complete)

- **Core validation models** (13 files in `lib/core/validation/`): `DraftValidationScope`, `DraftValidationCode`, `DraftValidationPath`, `DraftValidationIssue`, `DraftValidationResult`, and 7 validated draft types (`ValidatedSetDraft`, `ValidatedExerciseDraft`, `ValidatedWorkoutDraft`, `ValidatedProgrammeTemplateDraft`, `ValidatedProgrammeSlotDraft`, `ValidatedProgrammeWeekDraft`, `ValidatedProgrammeDraft`).
- **Service**: `DraftValidationService` (abstract) + `DefaultDraftValidationService` — validates workout drafts (10 rules: name, exercises, sets, reps, weight, RPE, RIR, rest, set type, superset) and programme drafts (6 rules: name, weeks, templates, week sequence, slot templates, template exercises).
- **Feature adapters**: `WorkoutBuilderValidationAdapter` (maps `WorkoutBuilderDraft` → `ValidatedWorkoutDraft`; maps shared issues → `WorkoutBuilderValidationError`). `ProgrammeBuilderValidationAdapter` (maps `ProgrammeBuilderDraft` → `ValidatedProgrammeDraft`; maps shared issues → `ProgrammeBuilderValidationError`).
- **Validator refactor**: `WorkoutBuilderValidator` and `ProgrammeBuilderValidator` now thin façades over shared `DraftValidationService` + adapters. No signature change needed in controllers.
- **Providers**: `draftValidationServiceProvider`, `workoutBuilderValidationAdapterProvider`, `programmeBuilderValidationAdapterProvider`. Updated `workoutBuilderValidatorProvider` and `programmeBuilderValidatorProvider` to wire shared service.
- **Tests**: 42 new — 20 workout service, 12 programme service, 5 workout adapter, 5 programme adapter. Existing validator/controller tests updated to use shared service.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 994/994 passed.

### V1-M4-008 — Manual superset / execution group support (complete)

- **Shared domain** (3 files): `ExecutionGroup`, `SupersetGroupSummary`, `SupersetGroupingPolicy`.
- **Domain enums/models**: `WorkoutBuilderSupersetAction`, `ProgrammeTemplateSupersetAction`, `SupersetSelectionState`.
- **Application layer** (6 files): builder + programme superset services and validators, runner + history grouping mappers.
- **Model fixes**: Extended `ProgrammeBuilderTemplateDraft` with `exercises: List<ProgrammeExerciseDraft>`; added `supersetOrder` + `copyWith` to `WorkoutRunnerExerciseItem` and `WorkoutHistoryExerciseItem`; added `copyWith` to `ProgrammeExerciseDraft`.
- **Load/save wiring**: `LoadProgrammeBuilderDraftUseCase` now loads template exercises via `ProgrammeRepository.getTemplateExercises()`. `SaveProgrammeBuilderDraftUseCase` preserves template exercises from builder draft. `DriftProgrammeRepository` maps template exercise/set rows to domain drafts.
- **WorkoutBuilderController** (+4 methods): `createSuperset`, `removeExerciseFromSuperset`, `deleteSupersetGroup`, `reorderWithinSuperset`.
- **ProgrammeBuilderController** (+4 methods): `createTemplateSuperset`, `removeTemplateExerciseFromSuperset`, `deleteTemplateSuperset`, `reorderTemplateSupersetMember`.
- **ProgrammeRepository**: Added `getTemplateExercises(String templateId)` to abstract interface.
- **Presentation widgets** (6 files):
  - `SupersetEditorSheet` — multi-select exercise sheet for creating supersets.
  - `SupersetGroupBadge` — primaryContainer badge showing order.
  - `SupersetActionsMenu` — PopupMenuButton with create/remove/delete.
  - `WorkoutRunnerSupersetGroupCard` — grouped display in runner.
  - `WorkoutHistorySupersetGroupCard` — grouped display in history.
  - `ProgrammeSupersetEditorSheet` — programme template exercise superset sheet.
- **Screen wiring**: `WorkoutBuilderScreen` → ConsumerStatefulWidget with sheet. `WorkoutExerciseCard`/`WorkoutExerciseList` extended. `WorkoutRunnerScreen` passes groups. `WorkoutHistoryDetailScreen` renders groups. `ProgrammeWorkoutSlotCard` extended with superset actions + exercise list.
- **AppStrings** (+21), **AppProviders** (+7).
- **Tests**: 48 total — 4 policy, 10 services, 10 validators, 7 mappers, 4 builder controller, 3 programme controller, 4 widget (editor sheet, group badge, runner card, history card), expanded history detail + repository tests.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 945/945 passed.

### V1-M4-007 — Compliance closure pass

- Replaced remaining `Icons.*` in the touched workout-builder 007 surface with `SvgPicture.asset` + `OutlinedSvgAssets` (`WorkoutBuilderScreen`, `WorkoutExerciseCard`, `SetPrescriptionEditorRow`).
- Removed remaining raw layout values in the touched 007 widgets by extending `AppSpacing` / `AppSizing` with reusable tokens (`xxxs`, `inputHorizontal`, `fieldWidthXs`, `fieldWidthXl`) and applying them in `SetTypeChip`, `SetPrescriptionEditorRow`, and `WorkoutRunnerSetRow`.
- Moved remaining touched-surface hardcoded strings into `AppStrings` (`skipped`, `setNumberLabel`) and updated runner/history rendering to use them.
- Refactored `SetPrescriptionEditorRow` from recreating `TextEditingController.fromValue(...)` inside `build()` to a `StatefulWidget` with controller lifecycle managed in `initState` / `didUpdateWidget` / `dispose`.
- Updated widget tests to match SVG/tooltip-based interactions and shared string usage.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 894/894 passed.

### V1-M4-007 — Warmup vs working set behavior (complete)

- **Shared domain** (`lib/shared/domain/`): `WarmupSetPolicy` (isWarmup/isWorking/shouldBeExcludedFromFutureAnalytics), `SetTypeOption` (type/label/description model for dropdowns).
- **Set type options use case** (`lib/features/workout_builder/application/set_type_options_use_case.dart`): Returns warmup + working `SetTypeOption`s with labels and descriptions.
- **Extension helpers**: `SetPrescriptionDraftX`, `WorkoutRunnerSetItemX`, `WorkoutHistorySetItemX` — `isWarmup`/`isWorking` getters and `withSetType()` mutation.
- **Shared UI helper**: `SetTypeChip` provides the reusable warmup/working chip used by builder/runner/history surfaces.
- **Builder controller** (`workout_builder_controller.dart`): Added `addWarmupSet()`, `updateSetType()`. `addSet()` now accepts optional `SetType` (defaults to `SetType.working`).
- **SetPrescriptionEditorRow**: Now shows a `DropdownButtonFormField<SetType>` between the set number and fields — user can toggle warmup/working. Requires `setTypeOptions` parameter. Prop-drilled through `SetPrescriptionList` → `WorkoutExerciseCard` → `WorkoutExerciseList` → `WorkoutBuilderScreen`.
- **WorkoutRunnerSetRow**: Warmup sets get a distinct `tertiaryContainer` background + chip label with `onTertiaryContainer` text. Working sets get `secondaryContainer` chip. Set type is read-only in runner (matches plan — fixed from template).
- **WorkoutHistorySetRow**: Now shows a warmup chip (`tertiaryContainer` tint) when `setType == SetType.warmup`. Working sets appear without a chip (cleaner look).
- **AppStrings**: Added `setTypeWarmup`, `setTypeWorking`, `setTypeWarmupDescription`, `setTypeWorkingDescription`, `addWarmupSet`, `addWorkingSet`, `warmupExcludedFromAnalytics`, `warmupSetDescription`, `setTypeRequired`.
- **AppProviders**: Added `warmupSetPolicyProvider`, `setTypeOptionsUseCaseProvider`.
- **ProgrammeBuilderController**: Skipped — programme templates are assigned from builder, not edited inline. No set-level UI exists in programme builder.
- **WorkoutRunnerController**: Skipped — set type is read-only during active session (matches plan's conditional guidance).
- **Tests**: 9 new unit tests — 6 `warmup_set_policy`, 3 `set_type_options_use_case`; expanded `workout_builder_controller_test.dart`; expanded `workout_builder_widgets_test.dart` for set type dropdown behavior; new `workout_history_set_row_test.dart` for warmup label rendering.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 894/894 passed.

## 2026-06-30

### Fix — Onboarding imperial unit conversion

- **Root cause**: `toImperialHeight`/`toImperialWeight` in `PreferredUnit` had inverted conditionals — when `isImperial` was true, they returned canonical values (cm/kg) instead of converting to imperial (in/lbs). Unit choice chip `onSelected` also corrupted canonical fields by storing converted display values back into `heightCm`/`bodyweightKg`.
- **Fix 1** (`lib/shared/domain/preferred_unit.dart`): Flipped if/else bodies in `toImperialHeight` and `toImperialWeight` so imperial mode properly converts cm→in and kg→lbs.
- **Fix 2** (`lib/features/onboarding/presentation/onboarding_screen.dart`): Removed conversion logic from unit choice chip `onSelected` — now only updates `preferredUnits`. Canonical values are always stored in metric; display adapts on-read.
- **Fix 3** (`lib/features/onboarding/presentation/onboarding_screen.dart`): Added `ValueKey` keyed on `preferredUnits` to bench/squat/deadlift `_FormField` widgets so they re-create their controller on unit switch, matching the pattern already used by height/weight fields.
- **Verification**: `dart format` — passed. `flutter analyze` — 0 new issues. `flutter test` — 863/863 pass (all 47 onboarding tests pass).

### V1-M4-004 — Active Workout Session Runner (complete)

- **6 domain models**: `WorkoutRunnerMode` (savedWorkout/programWorkout/resume), `WorkoutRunnerSetItem`, `WorkoutRunnerExerciseItem`, `WorkoutRunnerSessionViewData`, `WorkoutRunnerCompletionDraft`, `WorkoutRunnerResumeDecision`.
- **9 application files**: `WorkoutRunnerPhase` (6 states), `WorkoutRunnerState` (loading/ready/blocked/paused/failure/completed), `StartWorkoutSessionUseCase`, `LoadActiveWorkoutSessionUseCase`, `SaveWorkoutSessionProgressUseCase`, `CompleteWorkoutSessionUseCase`, `AbandonWorkoutSessionUseCase`, `WorkoutRunnerMapper` (toViewData/toDraft round-trip), `WorkoutRunnerController` (AsyncNotifier with constructor injection — 19 mutation methods: build all 3 modes, resume/discard recovery, updateSet, toggleSetCompleted/Skipped, pauseWorkout, continueWorkout, saveProgress, completeWorkout, cancelWorkout, updateSessionNotes/EnergyLevel/PerceivedDifficulty).
- **10 presentation files**: `WorkoutRunnerScreen` (3 named constructors), `WorkoutRunnerHeader`, `WorkoutRunnerExerciseList`, `WorkoutRunnerExerciseCard`, `WorkoutRunnerSetRow`, `WorkoutRunnerResumeBanner`, `CompleteWorkoutSheet`, `CancelWorkoutDialog`, `WorkoutRunnerErrorBanner`.
- **Infrastructure updates**: `AppRoutes` (+3 route factories), `AppStrings` (+26 runtime strings), `AppRouter` (+3 GoRoute entries), `AppProviders` (+7 runner providers).
- **AppSizing**: Added `iconXxl = 48`.
- **Fixes**: Controller mutation methods use `state.asData?.value` / `AsyncData(...)` pattern matching `ProgrammeBuilderController`. Pre-existing issues fixed: duplicate import in `providers.dart`, unnecessary braces in `complete_workout_sheet.dart`, non-exhaustive `DioExceptionType.transformTimeout` switch in `error_mapper.dart`.
- **Tests**: 58 new — 24 controller, 8 mapper, 4 screen, 8 set row, 4 complete sheet, 3 cancel dialog.
- **Flutter SDK note**: Widget tests for `FilledButton` use `NoSplash.splashFactory` to work around Flutter 3.44.4 `ink_sparkle.frag` shader version mismatch bug (also affects pre-existing tests).
- **Verification**: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 58/58 workout_execution tests pass (pre-existing 14 failures in exercise_library/bodymap unchanged).

### Rule-violation gap closure pass (M4-003)

- **Icons.\* → SvgPicture.asset**: Replaced all 18 `Icons.*` across 7 programme
  feature files with `SvgPicture.asset` using heroicon-style SVG constants.
  Updated `programme_save_bar_test.dart` to match new non-Icon dirty indicator.
- Pre-existing compilation errors (`ProgrammeAggregate`, `AppRoutes` missing
  imports in `programmes_screen.dart`) remain — not part of this pass.

## 2026-06-29

### V1-M4-003 — Manual multi-week programme builder (complete)

- **6 domain models**: `ProgrammeBuilderDraft` (18 fields with typed enums), `ProgrammeBuilderWeekDraft`, `ProgrammeBuilderWorkoutSlotDraft`, `ProgrammeBuilderTemplateDraft` (dayType enum, id, name), `ProgrammeBuilderValidationError` (scope enum, optional weekIndex/slotIndex/templateKey), `ProgrammeBuilderSaveRequest`.
- **8 application files**: `ProgrammeBuilderMode` (create/edit/duplicate), `ProgrammeBuilderPhase` (6 states), `ProgrammeBuilderState` (copyWith/initial), `ProgrammeBuilderValidator` (10 rules: name, at least one week, week numbers sequential, at least one slot per week, at least one template, every slot references template, + composite), `LoadProgrammeBuilderDraftUseCase` (createEmpty/loadForEdit/loadDuplicate), `SaveProgrammeBuilderDraftUseCase` (maps ProgrammeBuilderDraft → ProgrammeDraft), `ProgrammeBuilderController` (all mutations: add/remove/duplicate week, add/remove slot, assign template, save, discard, updateName, clearValidation).
- **Infrastructure updates**: `AppRoutes` (+3 programme builder routes), `AppStrings` (+45 builder constants), `AppErrorCodes` (+7 programme builder error codes), `AppRouter` (+3 GoRoute entries as sub-routes of `/programmes`), `AppProviders` (+4 provider declarations).
- **12 presentation files**: `ProgrammeBuilderScreen` (create/edit/duplicate factory constructors, PopScope for unsaved changes, validation banner, error banner, template sheet placeholder), `ProgrammesScreen` (overhauled: list view with programme cards, empty/error state, FAB linking to builder), `ProgrammeDetailsSection`, `ProgrammeWeeksOverview` (empty state + week list + add button), `ProgrammeWeekCard` (week header with duplicate/remove, slot list, add slot), `ProgrammeWorkoutSlotCard` (template display, assign/remove), `ProgrammeSaveBar` (dirty indicator, save button), `ProgrammeBuilderErrorBanner`, `DiscardProgrammeChangesDialog`, `ActiveProgrammeWarningDialog`, `AddWeekDialog`, `TemplateReassignmentBottomSheet`.
- **Compilation fixes**: Riverpod `AsyncNotifier<State>` constructor injection, `asData?.value` pattern, explicit generics for all draft list operations, const router entries, missing `CreationMethod.duplicate` fallback → `CreationMethod.manual`, null-check safety, missing imports, icon token fallback (no `iconXl`), unused parameter cleanup.
- **Gap closure pass**: Wired `TemplateReassignmentBottomSheet` (was `Placeholder`), added save-confirmation snackbar, moved 4 hardcoded strings to `AppStrings`, replaced 3 deprecated `withAlpha` calls with pre-baked `errorSurface` color tokens.
- **Tests**: 34 new — 12 validator tests (all 10 validation rules + composite/multi-week scenarios) + 22 controller tests (create mode: build/rename/addWeek/removeWeek/duplicateWeek/addSlot/removeSlot/assignTemplate/save/validation/clearErrors; edit mode: load/initial dirty; duplicate mode: load; edge cases: out-of-range indices) + 25 widget tests (week card display/callbacks, slot card display/callbacks, save bar dirty/disabled/spinner/save, 4 dialog confirm/cancel).
- **Verification**: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 713/713 passed.

### Settings and exercise-library test migration to enum-backed provider/exercise taxonomy

- Updated the targeted settings, exercise-library, and M3 smoke tests plus shared fakes to use enum-backed `AiProviderName`, `ProviderValidationStatus`, `ExerciseDifficulty`, `ExerciseModality`, `EquipmentTag`, `BodymapBucket`, `ExerciseVideoAngle`, and `ExerciseVideoGender` APIs instead of legacy strings.
- Adjusted repository/controller/widget expectations to assert enum values or formatted enum labels at the UI boundary, and refreshed the dataset parser/importer test fixture inputs to match the new closed vocabularies.
- Verification: targeted `flutter test test/features/settings test/features/exercise_library test/app/m3` now passes.

### Onboarding/profile test migration to enum-backed profile taxonomy

- Updated onboarding and profile tests under `test/features/onboarding/**` and `test/features/profile/**` to use the new enum-backed `ExperienceLevel`, `GoalTag`, `EquipmentTag`, and `Sex` APIs instead of legacy strings/lists.
- Adjusted fake repositories, test fixtures, and expectations to match typed `Set<GoalTag>` / `Set<EquipmentTag>` fields and nullable `experienceLevel` behavior.
- Verification: `dart format` on updated tests completed. Targeted analysis/tests run after this entry.

### Enum-backed taxonomy rollout for exercise, profile, onboarding, and provider models

- Added 18 shared taxonomy/support files in `lib/shared/domain/` covering enum-backed parsing for experience level, sex, goals, equipment, training days, exercise difficulty/modality/source/force/mechanic/video metadata, strength anchors, AI provider names, and provider validation status plus a shared `EnumCodec` helper for JSON text enum arrays.
- Converted implemented exercise-library domain models from raw taxonomy strings to enums/enum sets where the reference docs define closed vocabularies: filters, list/detail view data, candidate DTO/query, custom exercise seed, dataset exercise/video DTOs, and exercise repository/query-service mapping.
- Tightened exercise filter UI to the documented exercise modality taxonomy (`strength`, `flexibility`, `cardio`, `recovery`) and wired filter selections/bodymap buckets through enum-backed state instead of raw strings.
- Converted implemented profile and onboarding models to enum-backed constraints for `experienceLevel`, `sex`, `goals`, `equipmentAccess`, and `trainingDayNames`, while intentionally keeping `primaryMuscles`, notes, steps, and limitations as validated/freeform strings per the docs.
- Converted implemented programme and saved-workout draft metadata to `Set<GoalTag>` / `Set<EquipmentTag>` and typed `experienceLevelAtCreation` / `preferredUnitsAtCreation` fields.
- Replaced strength-anchor magic strings in `DriftProfileRepository` with typed `StrengthAnchorType` / `StrengthAnchorSource` values.
- Converted BYOK/provider-facing implemented models and repositories to typed `AiProviderName` and `ProviderValidationStatus` values, including provider capability repository/controller and key validation routing.
- Verification: `dart format` pending, `flutter analyze` pending, `flutter test` pending at the time of this entry.

### Codebase-wide enum conversion for ~20 string-typed fields + convention fixes

- **18 new enum files** in `lib/shared/domain/`: `SetType`, `SetIntent`, `WeightPrescriptionType`, `LoadingModel`, `ExerciseRole`, `WorkoutSource`, `SessionSource`, `CreationMethod`, `ImportOrigin`, `ImportReviewStatus`, `ExportPrivacyMode`, `ProgramStatus`, `SavedWorkoutStatus`, `ProgramWorkoutStatus`, `WorkoutSessionStatus`, `DayType`, `WeekType`, `PeriodisationModel`, `TrainingStyle`, `ChangeType`, `UpdateScope`.
- **Enum pattern**: `dbValue` getter + `fromDb()` static factory, conversion only at repository boundaries (Drift `text()` columns remain `String`).
- **Domain models updated**: All draft classes in `workout_builder/`, `programmes/`, `workout_execution/` now use typed enums instead of `String`.
- **Repository/use case boundaries**: `DriftSavedWorkoutRepository`, `DriftProgrammeRepository`, `DriftWorkoutSessionRepository`, `LoadWorkoutDraftUseCase` convert enum↔DB string at boundaries.
- **`set` → `prescription` rename**: Reserved-word avoidance across all workout builder, programmes, and workout execution files (7 lib + 2 test).
- **Raw sizing doubles fixed**: `strokeWidth: 2` → `AppSizing.strokeWidth` (6 files), field widths 80/72/64 → `fieldWidthLg/Md/Sm`, bodymap SVG 240×480 → `bodymapSvgWidth/Height`.
- **Token-type mismatch fixes** (4): `fontSize: AppSpacing.lg` → `AppFontSizes.xxl`, `size: AppSpacing.xxxl` → `AppSizing.iconLg`, `strokeWidth: AppSpacing.xxs` → `AppSizing.strokeWidth`.
- **Color modulation fix**: `withAlpha`/`withValues` runtime modulations replaced with 6 pre-baked alpha color tokens in `AedifyLightColors`/`AedifyDarkColors`.
- **Relative imports → package imports**: All 33 `../` imports in workout_builder feature converted.
- **Hardcoded strings → AppStrings**: 14 new constants + 1 static method for controller/validator/sync UI strings.
- **Test enum migration**: `drift_programme_repository_test.dart` (28 matches), `workout_builder_validator_test.dart` (9 matches) updated to use enum values; `workout_builder_controller_test.dart` corrected — Drift data classes remain `String`.
- **Unused import cleanup**: 14 warnings removed across 4 lib files.
- **Hardcoded Exception → AppErrorStrings**: `LoadWorkoutDraftUseCase.loadForEdit()` hardcoded `Exception('Saved workout not found: $savedWorkoutId')` replaced with `AppErrorStrings.workoutNotFoundWithId(savedWorkoutId)` — a parameterized static method preserving the original message while keeping strings in the constants file.
- **AppErrorCodes file created**: `lib/shared/constants/app_error_codes.dart` — central constant file for all 46 string-literal error codes previously scattered across 14 source files. Organized by domain (Validator, Network, Workout, Profile, Settings, BYOK, Onboarding, Audio, Key Validation). All 14 files updated to reference `AppErrorCodes.xxx` instead of inline string literals. Enum-based failure codes (`ExerciseDatasetDownloadFailureCode`, `ExerciseDatasetValidationFailureCode`, `ExerciseLibraryImportFailureCode`, `ProviderGateFailureReason`) left as typed enums.
- **Verification**: `flutter analyze` — 0 issues. `flutter test` — 655/655 passed.

## 2026-06-28

### V1-M4-002 — Workout builder: create/edit saved workouts with exercises/sets offline

- **6 domain models**: `ExerciseReference`, `SetPrescriptionDraft` (with `copyWith`), `WorkoutBuilderExerciseDraft`, `WorkoutBuilderDraft`, `WorkoutBuilderValidationError`, `WorkoutBuilderSaveRequest`.
- **5 application files**: `WorkoutBuilderState` (mode/phase/draft/errors/dirty), `WorkoutBuilderValidator` (10 rules), `LoadWorkoutDraftUseCase`, `SaveWorkoutDraftUseCase`, `WorkoutBuilderController` (all mutations: add/remove/reorder exercises, add/update/remove sets, save, discard, rename).
- **Data layer**: `SavedWorkoutRepository` abstract interface + `DriftSavedWorkoutRepository` (child replacement, aggregate with flat sets).
- **10 presentation files**: `WorkoutBuilderScreen` (create/edit ctors, PopScope, all UX states) + 9 widgets (header, name field, exercise list, exercise card, set list, set editor row, error banner, discard dialog, add-exercise bottom sheet).
- **Infrastructure updates**: `AppStrings` (+28 builder strings), `AppRoutes` (+2 routes), `AppRouter` (+2 GoRoutes), `AppProviders` (+4 provider declarations).
- **Exercise library wiring**: added `isCustom` to `ExerciseListItem`; `AddExerciseBottomSheet` now watches real `exerciseSearchControllerProvider`.
- **Tests**: 17 validator tests + 12 controller tests (10 create-mode + 2 edit-mode: load aggregate, load-edit round-trip) + 13 widget tests + 1 integration test (create → name → add exercise → verify state).
- **Lint fixes**: unused imports removed, `__` → `_` in widget test callbacks.
- **Production bugfix**: `ReorderableListView` in `WorkoutExerciseList` given `shrinkWrap: true` + `NeverScrollableScrollPhysics()` to prevent layout crash when nested inside outer `ListView`.
- **Verification**: `flutter analyze` — 0 issues, `flutter test` — 655/655 passed.
- **Analyzer fixes**: Fixed Riverpod controller base class (uses `AsyncNotifier<State>` with constructor injection matching codebase pattern), fixed provider family declaration, fixed import paths, fixed text style names (`bodyMd`, `labelSm`, `headlineMd`), fixed `providers.dart` import, fixed flat set access in load use case.
- **27 tests**: 17 validator tests (all 10 rules) + 10 controller tests (create mode: init, rename, add/remove exercise, add/remove set, duplicate, reorder, save validation, discard; edit mode: load failure).
- `flutter analyze` — 0, `flutter test` — 639/639.

### V1-M4-001 — M4 persistence foundation (all gaps closed): schema v8, 15 tables, 15 DAOs, 3 repos, domain models, provider wiring

- **Schema v8**: Added 15 new Drift tables (`programs`, `program_workout_templates`, `program_template_exercises`, `program_template_exercise_sets`, `program_weeks`, `program_workouts`, `program_exercises`, `program_exercise_sets`, `program_revisions`, `saved_workouts`, `saved_workout_exercises`, `saved_workout_exercise_sets`, `workout_sessions`, `workout_session_exercises`, `set_logs`) with v7→v8 migration (parent-first creation order).
- **15 DAOs**: Full CRUD methods for each table including upsert, delete-by-parent, ordered queries.
- **Domain models**: 11 draft/aggregate files across programmes, workout_builder, and workout_execution features.
- **3 repository implementations**: `DriftProgrammeRepository` (template+expanded hierarchy save with child replacement, active program management, soft-delete with history check), `DriftSavedWorkoutRepository` (full CRUD with child replacement, history-safe delete), `DriftWorkoutSessionRepository` (session lifecycle: start/save/complete/abandon/delete with in-progress guard).
- **Provider graph**: 15 DAO providers + 3 repository providers in `AppProviders`.
- **Privacy updates**: Added M4-sensitive field keys to `Redaction._sensitiveFields` and `PrivacyClassifier._forbiddenFields`.
- **Duplicate entries removed**: Cleaned up duplicated keys in `redaction.dart` and `privacy_classifier.dart` const sets.
- **Cleanup**: Removed unnecessary casts in DAOs, unused imports/elements in repos, unused `Uuid`/`_newId()` helpers.
- **Fixed expanded rows data integrity**: `_insertExpandedProgramRows` now copies template exercises and sets into `program_exercises`/`program_exercise_sets` per expanded workout. Previously rows were deleted but never repopulated, causing `_buildAggregate` to return empty lists.
- **Fixed root upsert DAO methods**: `upsertProgram`, `upsertSavedWorkout`, `upsertSession` changed from plain `insert()` to `insert(mode: InsertMode.insertOrReplace)` to handle re-save of the same root id.
- **Repository tests**: Added `test/features/programmes/data/drift_programme_repository_test.dart` with 6 tests covering CRUD, expanded rows round-trip, child replacement on re-save, archive, soft-delete, and activate/deactivate.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 612/612 passed.

## 2026-06-27

### Fixed (Test infrastructure — drift warning suppression, off-screen taps)

- **Drift "multiple database instances" warning fix**: Removed ineffectual top-level IIFE from `test/features/settings/data/fake_dependencies.dart` — Dart `final` top-level variables are lazily initialized, so the private `_suppressDriftWarning` variable was never read and never ran. Moved `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true` directly into `main()` in 3 test files: `drift_byok_repository_test.dart`, `byok_setup_controller_test.dart`, `byok_settings_screen_test.dart`.
- **Profile screen off-screen tap fix** (`test/features/profile/presentation/profile_screen_test.dart:221`): Added `tester.ensureVisible()` before tapping "Save profile" — button was below the 800×600 viewport.
- **Onboarding screen off-screen tap fix** (`test/features/onboarding/presentation/onboarding_screen_test.dart:265`): Added `tester.ensureVisible()` before tapping "Build muscle" goal — chip was below the viewport in the full-flow test.
- Verification: `dart format` — passed. `flutter test` — 606/606 passed, zero drift warnings, zero off-screen tap warnings.

### Fixed (M3 audit — isCheapest, resume-byokOptional, unused DAOs)

- **Removed broken `isCheapest` getter** (`lib/features/settings/domain/byok_model_option.dart`): The `totalCostPer1kTokens == 0` check always returned `false`. The getter was unused in UI code (`_MoreCapableHint` computes cost comparison inline), so it was removed entirely.
- **Fixed resume step for BYOK-skipped drafts** (`lib/features/onboarding/application/onboarding_controller.dart`): Changed `_resumeStepForDraft` to send to `review` instead of `byokOptional` when `byokSkipped` is `true`, avoiding unnecessary detours.
- **Removed unused `_appSettingsDao` and `_bodyMeasurementDao`** (`lib/features/profile/data/drift_profile_repository.dart`): Cleaned up constructor, fields, and all provider/test wiring. Removed unused imports from `test/`.

### Refactored (M1–M3 codebase sweep — theme, casts, SVGs, architecture, deps, font tokens)

- **Batch 1 — `Theme.of(context)` → `context.theme`**: Fixed 5 occurrences across `placeholder_screen.dart` (×4) and `exercise_step_audio_button.dart` (×1).
- **Batch 2 — Inline `TextStyle()` → `AppTextStyles`**: Replaced 10 inline `TextStyle(fontSize: ...)` in `exercise_detail_screen.dart`, `exercise_library_screen.dart`, `bodymap_bucket_chip_bar.dart`, `byok_settings_screen.dart`.
- **Batch 3 — Safe typed casts**: Changed `_CostIndicator`, `_MoreCapableHint`, `_ModelSelector` from `List<dynamic>` to `List<ByokProviderOption>`. Removed 3 unsafe `as` casts in `byok_settings_screen.dart`.
- **Batch 4 — Bodymap SVG constant class**: Created `BodymapSvgAssets` in `lib/shared/constants/svg_assets_bodymap.dart`. Updated `bodymap_asset_contract.dart` to reference it.
- **Batch 5 — Sync controller architecture fix**: Added `exerciseLibraryImporterProvider` in `providers.dart`. Updated `ExerciseDatasetSyncController` to use providers instead of inline DAO/importer construction.
- **Batch 6 — Removed unused deps**: Removed `cupertino_icons` and `equatable` from `pubspec.yaml`.
- **Batch 7 — AppFontSizes extended**: Added `xxs(10)`, `sm(14)`, `md(16)`, `lg(18)`, `xl(20)`, `xxl(24)`, `xxxl(28)`, `displaySm(32)`, `displayMd(40)`. Updated `AppTextStyles` and `AppTextStylesDark` to reference them.
- **Batch 8 — Theme constants consolidated**: Moved `app_colors.dart` from `lib/app/theme/` to `lib/shared/theme/`. Updated `app_theme.dart` import.
- Verification: `dart format` ✓ → `flutter analyze` ✓ 0 errors → `flutter test` ✓ 606/606 passing.

### Added (V1-M3-008 — Create onboarding/profile/BYOK privacy tests)

- **3 support files**: `privacy_sentinel_values.dart`, `privacy_output_matchers.dart`, `fake_crashlytics_capture.dart`.
- **30 new privacy tests** across crashlytics, secure storage, logger, onboarding, profile, BYOK, provider gate, BYOK widget.
- **5 leaks found and fixed**: Crashlytics `notes` redaction gap, empty key test `contains('')`, `rotateKey` fake repo override, onboarding save error assertion, BYOK widget validation test.
- **`notes` added to `Redaction._sensitiveFields`** and `PrivacyClassifier._forbiddenFields`.
- **Tests**: 30 new. **585/585 passing**.
- **M3 status**: V1-M3-008 complete. **1 ticket remains**: V1-M3-009 (P0).

### Added (V1-M3-009 — M3 acceptance smoke flow tests)

- **Test scaffold**: `test/app/m3/fake_m3_dependencies.dart` (5 fakes) + `m3_test_harness.dart` (pumpApp with 10 overrides) + `m3_setup_smoke_flow_test.dart` (8 acceptance tests).
- **8 acceptance tests**: fresh install → onboarding welcome, full 7-step onboarding, post-onboarding nav (profile/settings/BYOK), BYOK key save (no sentinel leak), AI gating missing/available key, onboarding validation block, BYOK validation safe error.
- **Existing tests expanded**: `app_router_test` (M3 gate routes), `onboarding_screen_test` (completion), `byok_settings_screen_test` (validation + delete), `default_provider_gate_service_test` (text-capable vs json-schema).
- **Fixes**: gate service json-schema requirement, AI gating split, BYOK validation assertion (form stays visible on failure — privacy gate is no persistence/logging), `AppStrings.profileEdit` for profile screen, router nav 2 `pump()` calls, delete dialog confirmation required.
- **M3 complete**: **All V1-M3 tickets closed** (001–009).
- **Verification**: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing warnings). `flutter test` — 605/605 passed.

### Added (V1-M3-007 — Implement unit and measurement preference handling)

- **`UnitConversion`** (`lib/shared/domain/unit_conversion.dart`): Pure numeric conversions — kg↔lb, cm↔in, `formatSafe`.
- **Consolidated conversion math**: `PreferredUnit.toImperialHeight/Weight` and `toMetricHeight/Weight` now delegate to `UnitConversion` instead of inline `* 0.45359237` / `/ 2.54` factors.
- **`MeasurementParser`** (`lib/shared/formatters/measurement_parser.dart`): `parseWeightToCanonicalKg`, `parseHeightToCanonicalCm`.
- **`MeasurementFormatter`** (`lib/shared/formatters/measurement_formatter.dart`): `formatWeight`, `formatHeight`.
- **`PreferredUnit` extended** (`lib/shared/domain/preferred_unit.dart`): `toDisplayWeight`, `toDisplayHeight`, `toCanonicalWeight`, `toCanonicalHeight`.
- **`ProfileController` extended**: `updatePreferredUnits`, `updateBodyweightFromDisplay`, `updateHeightFromDisplay`.
- **`ProfileScreen` unit-aware**: Bodyweight/height + all three 1RM fields use `MeasurementFormatter`/`MeasurementParser` + dynamic unit suffix.
- **`_FormField.didUpdateWidget`**: Syncs `TextEditingController` when `initialValue` changes on unit switch.
- **Gap closed**: 1RM fields had hardcoded `'kg'` suffix + raw `double.tryParse` — now unit-aware with display conversion and input parsing.
- **Tests**: 28 new. **555/555 passing**.
- **M3 status**: V1-M3-007 complete. **2 tickets remain**: V1-M3-008 (P0), V1-M3-009 (P0).

## 2026-06-26

### Added (V1-M3-006 — Connect profile preferences to candidate engine)

- **`ProfileCandidatePreferences`**: New domain model bridging profile data with the candidate exercise engine — equipment, difficulty, modality, exclusions, goal tags, and ranking inputs.
- **`ProfileCandidatePreferencesService`** (abstract) + **`DefaultProfileCandidatePreferencesService`**: Implementation reads `ProfileRepository.getProfile()` and maps deterministically — equipment pass-through, experience→difficulty 4-tier, goals→goalTags (hypertrophy/cardio/strength), substituted→excludedExerciseIds, no free-text injury heuristics.
- **Provider wired**: `profileCandidatePreferencesServiceProvider` in `AppProviders`.
- **Gap closed**: `_mapModalities` was returning raw goal strings (would hard-filter all exercises). Fixed to return empty set — no hard modality filter; modality scoring handled by `goalTags` soft ranking.
- **No `CandidateExerciseQuery` or `CandidateExerciseQueryService` changes** — existing model covers all fields.
- **No `ProfileViewData` expansion needed** — all 7 required fields already present.
- **Tests**: 18 new (17 service + 4 profile-derived candidate integration, −1 removed old modality test). 527/527 total passing.
- **Docs**: `implementation.md` updated — V1-M3-006 entry added, remaining tickets corrected (3 left), test count 527.
- **Compliance closeout**: Cross-referenced build ticket backlog (V1-M3-006), data model plan (privacy/storage boundaries), and data privacy rules. Privacy audit confirmed `DefaultProfileCandidatePreferencesService` is clean — no logging, Crashlytics, storage writes, or raw profile data in DTOs. `dart run build_runner build` passed. No rules violations remain.

### Fixed (M3 status correction — 5 of 9 tickets complete, 4 remaining)

- V1-M3-001 through V1-M3-006 are complete (onboarding, profile, settings, BYOK, capability gate, profile→candidate wiring). V1-M3-007 (P1), V1-M3-008 (P0), V1-M3-009 (P0) remain open.
- `docs/implementation.md` updated: status line, completed work section, planned work all reflect accurate M3 progress.
- No code changes.

### Changed (setState elimination — API key visibility toggles use ValueNotifier)

- `_ByokOptionalStepState` (`onboarding_screen.dart`): Replaced `bool _obscured` + `setState` with `ValueNotifier<bool>` + `ValueListenableBuilder` for the API key obscurity toggle.
- `_ApiKeyFieldState` (`byok_settings_screen.dart`): Same refactor — `ValueNotifier<bool>` + `ValueListenableBuilder` instead of `setState`.
- Result: **Zero `setState` calls remain anywhere in `lib/`**.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 485/485 passed.

### Added (V1-M3-005 — Provider Capability Matrix & Gate Service)

- **`AiModelCapabilities` Drift table** (`lib/core/db/tables/ai_model_capabilities.dart`): Model-level capability cache — `id`, `providerName`, `modelName`, `supportsTextInput`, `supportsImageInput`, `supportsJsonSchemaMode`, `supportsStreaming`, `maxContextTokens`, `maxOutputTokens`, `maxImagesPerRequest`, `checkedAt`. Composite ID key.
- **Database migration**: Schema 6→7, `m.createTable(aiModelCapabilities)` in v7 step.
- **`AiModelCapabilityDao`** (`lib/core/db/daos/ai_model_capability_dao.dart`): 3 methods — `getCapability(providerName, modelName)`, `upsertCapability(AiModelCapabilitiesCompanion)`, `deleteCapability(providerName, modelName)`.
- **Domain models** (`lib/features/settings/domain/`):
  - `ProviderCapabilityType` — enum: `textInput`, `imageInput`, `jsonSchemaMode`, `streaming`, `toolCalling`.
  - `ProviderOperationType` — enum: `aiChat`, `aiWorkoutGeneration`, `aiProgrammeGeneration`, `structuredSaveFlow`, `externalTextImportParse`, `imageImport`, `physiqueAnalysis`.
  - `ProviderCapabilityViewData` — data class with all capability flags + `checkedAt`.
  - `ProviderGateDecision` — `allowed`/`blocked` constructors with `isAllowed`, `reason`, `message`.
  - `ProviderGateFailureReason` — enum: 8 failure reasons (`missingProviderConfig`, `missingKey`, `unsupportedModel`, `missingTextCapability`, `missingImageCapability`, `missingJsonSchemaCapability`, `offline`, `capabilityUnknown`).
- **`ProviderCapabilityRepository`** (abstract) + **`DriftProviderCapabilityRepository`** (`lib/features/settings/data/`): Maps DB row ↔ `ProviderCapabilityViewData`. Methods: `getCapability`, `saveCapability`, `clearCapability`.
- **`ProviderGateService`** (abstract) + **`DefaultProviderGateService`** (`lib/features/settings/data/`): Fail-closed gate — checks: active config exists → hasKey → model selected → network online → capability cache exists → operation-specific capability present → allowed. All failure paths return safe `AppStrings` guidance.
- Capability requirements per operation: `aiChat`/`externalTextImportParse` → textInput; `aiWorkoutGeneration`/`aiProgrammeGeneration` → textInput + jsonSchemaMode; `structuredSaveFlow` → jsonSchemaMode; `imageImport`/`physiqueAnalysis` → imageInput.
- **`ProviderCapabilityState`** + **`ProviderCapabilityController`** (`lib/features/settings/application/`): `AsyncNotifier` using Riverpod 3.x family pattern (`AsyncNotifierProvider.family` with constructor args). `build()` reads cached capability; `reload()` refreshes.
- **Optional `ProviderCapabilityScreen`** (`lib/features/settings/presentation/provider_capability_screen.dart`): `ConsumerWidget` for displaying cached capability (loading/error/capability views).
- **Provider wiring** (`lib/app/providers/providers.dart`): 4 new providers — `aiModelCapabilityDaoProvider`, `providerCapabilityRepositoryProvider`, `providerGateServiceProvider`, `providerCapabilityControllerProvider` (family).
- **Strings**: 7 new `AppStrings` (capability and gate guidance messages), 2 new `AppErrorStrings` (capability load errors).
- **Tests**: 18 new — 4 DAO, 3 repository, 8 gate service (all fail-closed scenarios), 3 controller. Shared `FakeConfigDao`/`FakeSecureStorage`/`FakeNetworkStatus` extended. Schema version tests updated 6→7.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `dart run build_runner build` — passed (314 outputs). `flutter test` — 503/503 passed.

### Fixed (V1-M3-005 gap closure — tool calling, SVGs, retry, redaction test, AppStrings compliance)

- **`AiModelCapabilities` table**: Added `supportsToolCalling` nullable bool column — matches data model plan §9. Companion updated by codegen.
- **`ProviderCapabilityViewData`**: Added `supportsToolCalling` nullable field with conditional display in capability screen.
- **`DriftProviderCapabilityRepository`**: Added `supportsToolCalling` to DB↔view data mapping in both read and save paths.
- **`ProviderCapabilityScreen`**: Added Tool Calling capability tile (shown only when non-null). Replaced `Icons.check_circle`/`Icons.cancel` with `OutlinedSvgAssets.checkCircle`/`OutlinedSvgAssets.xCircle`. Added retry button (`OutlinedButton.icon` with `arrowPath` SVG) to `_UnavailableView` that invalidates the controller provider.
- **Hardcoded strings → AppStrings**: Moved all 10 user-facing labels (`providerCapabilityTitle`, `capabilityTextInput`, `capabilityImageInput`, `capabilityJsonSchemaMode`, `capabilityStreaming`, `capabilityToolCalling`, `capabilityMaxContextTokens`, `capabilityMaxOutputTokens`, `capabilityMaxImagesPerRequest`, `capabilityLastChecked`) and reused existing `AppStrings.retry`. Zero hardcoded strings remain in the screen.
- **Design compliance**: Read `DESIGN.md` per AGENTS.md §162. Applied Flutter mobile design skill pack per §163-164. Confirmed colors use `context.colorScheme`, text uses `AppTextStyles`, spacing uses `AppSpacing`/`AppWhiteSpace`/`AppSizing`, no raw tokens.
- **Redaction test**: Added `all block messages are safe AppStrings — no internal details leaked` test — verifies all 6 failure-path messages are known safe `AppStrings` constants with no forbidden patterns (provider/model names, API keys, file paths, error terminology).
- **1 new test** — 504 total passing. No schema change (nullable column addition, no migration needed).
- Verification: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing warnings). `flutter test` — 504/504 passed.

## 2026-06-25

### Fixed (V1-M3-004 — 10 gap fix: Google provider, correct models, key validation, cost indicator, onboarding BYOK step, more-capable hint)

- **Google provider added**: Gemini 2.5 Pro + Gemini 2.5 Flash — matches PRD §5.1.1 three-provider spec.
- **OpenAI models corrected**: Replaced `gpt-4-turbo`, `gpt-4`, `gpt-3.5-turbo` with `o1`, `o1-mini`.
- **Anthropic models use PRD display names**: "Claude Sonnet 4.6", "Claude Haiku 4.5", "Claude Opus 4.7" — API ID mapping deferred to M7.
- **`ByokModelOption` domain model** (`lib/features/settings/domain/byok_model_option.dart`): Model option with `id`, `displayName`, `inputCostPer1kTokens`, `outputCostPer1kTokens`, `estimatedCostPerWorkout`, `isCheapest` getter.
- **`ByokProviderOption.description` added**: Per-provider descriptions for OpenAI, Anthropic, Google.
- **`ProviderKeyValidator`** (`lib/features/settings/data/provider_key_validator.dart`): Validates keys via per-provider Dio endpoints (5s timeout, no retry, privacy-redacted errors). OpenAI (`/v1/models` with `Authorization`), Anthropic (`/v1/messages` with `x-api-key`), Google (`/v1/models` with `x-goog-api-key`). Returns `KeyValidationResult` with `isValid` + `errorCode`.
- **`ByokRepository.validateKey()` added**: Abstract + `DriftByokRepository` implementation delegates to `ProviderKeyValidator`.
- **`ByokSetupController.save()` rewritten**: Now validates key via `repository.validateKey()` before persisting — shows `isTesting` spinner state, surfaces `byokKeyValidationFailed` on rejection.
- **Cost indicator** (`_CostIndicator` widget in `byok_settings_screen.dart`): Shows "Est. cost: $0.xx" below the model selector, computed from `inputCostPer1kTokens`/`outputCostPer1kTokens` × ~2K input + ~1K output tokens per workout generation.
- **More capable hint** (`_MoreCapableHint` widget): Shows "More capable models available" when a non-priciest model is selected.
- **Skip AI for now button**: `OutlinedButton` at bottom of `ByokSettingsScreen` that pops navigation.
- **Onboarding BYOK step rewritten** (`_ByokOptionalStep` in `onboarding_screen.dart`): `ConsumerStatefulWidget` with provider/model/key entry form, "Save key" button that persists via `ByokRepository`, `byokSkipped` flag update, success banner, scaffold Continue skips.
- **Strings**: 7 new `AppStrings` (`skipAiForNow`, `estimatedCostPerWorkout`, `byokTestingKey`, `lessThan`, `byokMoreCapableModelsHint`, `byokOnboardingSaved`, 3 provider descriptions), 2 new `AppErrorStrings` (`byokKeyValidationFailed`, `byokValidationNetworkError`).
- **Tests**: 4 new repository tests (3 providers, correct OpenAI/Anthropic/Google models, pricing assertions), all tests pass (485/485).
- **Verification**: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 485/485 passed.

### Added (V1-M3-004 — Full BYOK Provider Setup Flow)

- `AiProviderConfigs` Drift table with metadata, capability flags, validation tracking, timestamps; schema 5→6 migration.
- `AiProviderConfigDao` with 8 methods (getAll, getById, getActive, upsert, setActive, clearActive, delete, updateValidation).
- Domain models: `ByokProviderOption`, `ByokConfigViewData`, `ByokEditDraft` (with `copyWith`/clear flags).
- `ByokRepository` (abstract) + `DriftByokRepository`: built-in OpenAI/Anthropic provider options, save/rotate/delete/setActive, API key stored only in `SecureStorageService` (never in Drift), `hasKey` boolean only.
- `ByokSetupController` (AsyncNotifier): build/updateDraft/save (with empty-key validation)/rotateKey/deleteConfig/setActiveConfig/reload.
- `ByokSettingsScreen`: provider selector (ChoiceChip), model selector (DropdownButtonFormField), obscured API key input with toggle, config cards with active badge/setActive/delete, error/validation banners.
- Routing: `AppRoutes.byokSettings()` (`/settings/byok`), `aiProviderSettings` redirect → `byokSettings`.
- 13 `AppStrings` + 6 `AppErrorStrings` for BYOK flow.
- 21 tests (6 DAO, 6 repository, 7 controller, 2 widget) — 481 total passing.
- Shared `FakeConfigDao`/`FakeSecureStorage` test dependencies.
- Fixed `_ModelSelector` type cast for `DropdownButtonFormField<String>`.
- Fixed `_ApiKeyField` Riverpod build-time state modification (moved `onChanged` to `TextFormField.onChanged`).

### Added (V1-M3-003 — Settings Shell, BYOK Entry, Feature Status Display)

- **`PreferredUnit` enum expanded** (`lib/shared/domain/preferred_unit.dart`): Now owns all unit concerns — `isImperial`, `isMetric` getters, `heightLabel`/`weightLabel`/`heightHint`/`weightHint`/`heightUnit`/`weightUnit` display properties, `toMetricHeight`/`toMetricWeight`/`toImperialHeight`/`toImperialWeight` conversion methods. Replaced raw conversion constants and static helper methods in widgets. Converted to enhanced enum with field constructors matching `ThemeModeSetting`'s pattern.
- **DRY dropdown refactor**: Both settings dropdowns (`PreferredUnit`, `ThemeModeSetting`) now derive options and labels via `.values.map((e) => e.name / .displayLabel)` instead of hardcoded arrays — consistent, type-safe, and DRY.
- **`ThemeModeSetting` enum** (`lib/shared/domain/theme_mode_setting.dart`): `system`/`light`/`dark` with `dbValue`/`fromDb`/`toMaterialThemeMode`/`displayLabel`.
- **Domain models using enums**: `OnboardingDraft.preferredUnits` (`String?` → `PreferredUnit?`), `ProfileViewData.preferredUnits` (`String` → `PreferredUnit`), `ProfileEditDraft.preferredUnits` (`String` → `PreferredUnit`), `SettingsViewData.preferredUnits`/`themeMode` typed enums.
- **Repository boundary conversion**: `DriftOnboardingRepository`, `DriftProfileRepository`, `DriftSettingsRepository` now convert enum ↔ DB string via `.dbValue`/`.fromDb()` at the boundary.
- **Settings domain**: `SettingsViewData` (13 fields), `SettingsEditDraft` (7 mutable fields with `copyWith()`), `SettingsRepository` (abstract), `DriftSettingsRepository` (reads/writes `AppSettings` table, merges `FeatureFlags`).
- **SettingsController**: `AsyncNotifier<SettingsState>` with `updateDraft()`/`save()`/`reload()`.
- **SettingsScreen**: Full shell — profile nav tile, exercise dataset status, app settings card (units dropdown, theme dropdown, 5 switches + save), AI setup nav tile, feature status section (5 tiles from FeatureFlags), privacy/storage card, diagnostics nav tile.
- **3 widget files**: `settings_section_card.dart`, `settings_feature_status_tile.dart`, `settings_storage_boundary_card.dart`.
- **Theme mode wiring**: `AedifyApp` watches `settingsControllerProvider` and applies `themeMode.toMaterialThemeMode()` instead of hardcoded `ThemeMode.system`.
- **Routing**: `AppRoutes.aiProviderSettings()` + placeholder GoRoute.
- **Providers**: `settingsRepositoryProvider`, `settingsControllerProvider` registered.
- **AppStrings**: 18 new strings (settings labels, imperial units, unit labels/hints).
- **AppErrorStrings**: 2 new strings (`settingsLoadFailedMessage`, `settingsSaveFailedMessage`).
- **Onboarding screen form behavior**: Switching units now converts displayed values (cm↔in, kg↔lbs); `_FormField` uses `ValueKey` to force recreation on unit change; review step shows correct unit labels and converted imperial values.
- **Tests**: 18 new — 3 drift_settings_repository, 5 settings_controller, 8 settings_screen, 2 storage_boundary_card. Profile/onboarding tests updated for `PreferredUnit` enum type. App test bootstrap controllers simplified (start in `success` state directly); `_FixedOnboardingNotifier` overrides `onboardingControllerProvider` to bypass Drift in widget tests.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors (2 pre-existing unused-field warnings). `flutter test` — 460/460 passed.

## 2026-06-24

### Added (V1-M3-002 — Profile Repository and Edit Screens)

- **4 Drift tables**: `user_profile`, `strength_anchors`, `body_measurements`, `app_settings` — JSON columns for array fields (goals, equipment, injuries), all with primary keys.
- **4 DAOs**: `UserProfileDao` (get/upsert/markOnboardingCompleted), `StrengthAnchorDao`, `BodyMeasurementDao`, `AppSettingsDao` (read/upsert).
- **Domain layer**: `ProfileViewData` (display model), `ProfileEditDraft` (edit model with `copyWith` + clear flags), `ProfileSaveImpact` (none / mayAffectActiveProgrammes).
- **Repository layer**: `ProfileRepository` (abstract) + `DriftProfileRepository` (impl with JSON encode/decode, transactional save, placeholder `evaluateSaveImpact`).
- **ProfileController**: `AsyncNotifier<ProfileState>` — auto-evaluates impact on build and every draft update; validates `experienceLevel` required; loads profile on init.
- **ProfileScreen**: Full editable form — experience/goal chips, equipment chips, days-per-week selector, session length field, unit toggle, bodyweight/height fields, injuries chips, notes field, save button; `_ErrorView`, `_ProfileContentView`, `_ValidationBanner`, `_ImpactWarning`, `_SectionCard`, `_ChipSelector`, `_DaysPerWeekSelector`, `_UnitSelector`, `_FormField` widgets.
- **App wiring**: `AppDatabase` schema v5 (migration v4→v5), providers registered, `/profile` route added.
- **AppStrings/AppErrorStrings**: ~15 profile labels + validation/save error strings.
- **5 test files**: DAO tests (user_profile, app_settings), repository tests, controller tests, widget tests (loading, save, edit, impact warning).
- **Fixes**: Added `primaryKey` to `UserProfile` and `AppSettings` tables for `insertOnConflictUpdate`; automatic impact evaluation on build and draft update; onboarding welcome step now shows title above hero; onboarding repository fixed for non-null `experienceLevel` column.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 errors (3 pre-existing unused-field warnings). `flutter test` — 439/439 passed.

### Changed (Onboarding scaffold — title visibility)

- `onboarding_step_scaffold.dart`: Always render the step title, even when a hero widget is present. Previously the hero replaced the title; now it appears below the title + description.

### Changed (Profile controller — auto-evaluate impact)

- `profile_controller.dart`: `build()` now calls `evaluateSaveImpact()` and sets initial impact. `updateDraft()` auto-evaluates impact on every draft change (was a no-op).

### Fixed (Drift schema errors)

- `user_profile.dart`: Added `@override Set<Column> get primaryKey => {id};` — required for `insertOnConflictUpdate` to work.
- `app_settings.dart`: Added `@override Set<Column> get primaryKey => {id};` — same fix.
- `drift_onboarding_repository.dart`: `experienceLevel` column is non-nullable `Text` — uses `Value(draft.experienceLevel ?? '')` in save and `const Value('')` in clear instead of `Value(null)`.

### Fixed (Test assertions)

- `onboarding_screen_test.dart`: Uses hero description text (`onboardingWelcomeDescription`) instead of title text (`onboardingWelcomeTitle`) which is not rendered when hero is present.
- `drift_onboarding_repository_test.dart`: Expects `''` instead of `null` for cleared `experienceLevel`.
- `app_database_test.dart`: Schema version 4→5.
- `migration_test.dart`: Migration `toVersion` 4→5.
- `profile_controller_test.dart`: `updateDraft` calls are now `await` (was `void`, now `Future<void>`). Initial build test checks `hasError` and `requireValue.isLoading` instead of `isLoading` on raw `AsyncValue`.
- `profile_screen_test.dart`: `_FakeProfileRepositoryWithImpact` returns non-null profile + matches `ProfileViewData` required params.

### Redesigned (Onboarding UI refresh across all steps)

- **Scaffold + progress refresh** (`onboarding_step_scaffold.dart`, `onboarding_progress_header.dart`): Reworked onboarding chrome with branded step header, `Step x of y` label, slim progress bar, cleaner content spacing, and elevated bottom CTA area. Added branded light/dark logo assets (`assets/images/logo_light.png`, `logo_dark.png`) wired through `ImageAssets.appLogo()`.
- **Welcome screen refresh** (`onboarding_screen.dart`): Added hero copy, privacy-focused onboarding panels, and an AI-optional informational card inspired by the reference designs.
- **Experience / schedule / equipment / units / limitations refresh** (`onboarding_screen.dart`): Converted plain form layout into surfaced sections with premium selection cards, metric tiles, grouped equipment chip panels, and structured body-metric / notes cards.
- **BYOK + review refresh** (`onboarding_screen.dart`): Redesigned BYOK as a benefits/info surface and grouped review into editable summary cards while preserving jump-to-step behavior.
- **Supporting content + tokens** (`app_strings.dart`, `app_spacing.dart`): Added onboarding-specific helper copy, labels, review affordances, and sizing tokens for cards, badges, and progress UI.
- **Tests updated** (`test/features/onboarding/presentation/onboarding_screen_test.dart`): Adjusted onboarding widget tests to match the refreshed interaction model while keeping existing flow assertions.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Refactored (AGENTS.md compliance — onboarding widget code conventions)

- **`Colors.white` → theme token** (`onboarding_step_scaffold.dart`): Replaced hardcoded `Colors.white` with `context.colorScheme.onPrimary` via `ThemeX` extension. Added missing `context_extensions.dart` import.
- **`Theme.of(context)` → `context.colorScheme`** (`onboarding_progress_header.dart`): Replaced `Theme.of(context).colorScheme.*` with `context.colorScheme.*` via `ThemeX` extension. Added missing `context_extensions.dart` import.
- **Hardcoded input hint/suffix strings → `AppStrings`** (`onboarding_screen.dart`): 3 hint texts and 3 suffix texts moved to `AppStrings` constants.
- **Raw `width: 120` → `AppSizing.fieldWidth`** (`onboarding_screen.dart`): 3 usages replaced with new sizing token.
- **Function widget builders → proper widget classes** (`onboarding_screen.dart`): Extracted `_buildStep` → `_OnboardingStepView`, `_stepContent` → `_StepContent`, `_buildValidationOrError` → `_ValidationMessage`, `_reviewRow` → `_ReviewRow` as proper `StatelessWidget`/`ConsumerWidget` classes per `rules.md` §118-121.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Fixed (Bootstrap screen — `mounted` guard for post-frame callback)

- **`mounted` guard added** (`bootstrap_screen.dart:24`): Wrapped `ref.read(AppBootstrap.controllerProvider.notifier).start()` call in `if (mounted)` to prevent `StateError:`ref`used after widget was disposed` when the post-frame callback fires after the widget has been unmounted.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Fixed (Chip theme — missing DESIGN.md color tokens in `app_theme.dart`)

- **Light `chipTheme`** (`app_theme.dart`): Added `backgroundColor: AedifyLightColors.surfaceContainerLow`, `selectedColor: AedifyLightColors.secondaryContainer`. Removed `labelStyle` — chips now fall back to `textTheme.labelSmall` (already `AppTextStyles.labelSm`) and auto-resolve text color from `ColorScheme` (`onSurfaceVariant` unselected, `onSecondaryContainer` selected).
- **Dark `chipTheme`** (`app_theme.dart`): Added `backgroundColor: AedifyDarkColors.surfaceContainerHigh`, `selectedColor: AedifyDarkColors.primaryContainer.withValues(alpha: 0.3)`, removed `labelStyle`, fixed `labelSmall` in textTheme to use `AppTextStylesDark.labelSm`.
- Fixes `withOpacity` deprecation → `withValues(alpha: ...)`.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Fixed (Onboarding text fields — focus loss on keystroke)

- **Root cause**: Inline `TextEditingController(...)` in `StatelessWidget.build()` created a new controller instance on every rebuild, causing Flutter to lose focus on every keystroke.
- **Fix**: Extracted `_FormField` `StatefulWidget` (`onboarding_screen.dart`) that creates its `TextEditingController` once in `initState`, disposes it in `dispose`, and never overwrites controller text from external rebuilds.
- Applied to all 4 text fields: `_ScheduleStep` (session minutes), `_UnitsMetricsStep` (height, weight), `_LimitationsStep` (notes).
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Added (Onboarding back navigation and editable review rows)

- **`OnboardingController.jumpToStep()`** (`onboarding_controller.dart`): New method that sets `currentStep` to any step — enables tappable review rows and direct step navigation.
- **Back from `experienceGoals`** (`onboarding_screen.dart`): Removed guard blocking back button on first non-welcome step. Back now works on every step (including review going back to BYOK).
- **BYOK step simplified** (`onboarding_screen.dart`): Removed special "Skip for now" back-button override. Since `byokSkipped` defaults to `true`, the user clicks **Continue** to proceed to review. Left button shows "Back" → `previousStep()`.
- **Review rows now tappable** (`onboarding_screen.dart`): Each `_ReviewRow` maps to its source step — tap any field to jump back and edit, then Continue returns to review.
- **Test updated**: "Continue from BYOK advances to review" replaces "BYOK skip advances to review".
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

### Fixed (V1-M3-001 — Onboarding completion gate, debounced autosave, resume-to-step)

- **Router gate fix** (`lib/app/router/app_router.dart`): Replaced unconditional `startup -> onboarding` redirect. New behavior:
  - Bootstrap guard unchanged.
  - Unresolved onboarding status stays on startup.
  - `OnboardingStatus.complete` redirects from startup/onboarding to home.
  - `OnboardingStatus.incomplete` redirects non-onboarding routes to onboarding.
- **Debounced draft autosave** (`lib/features/onboarding/application/onboarding_controller.dart`): `updateDraft()` now schedules a 400ms debounced Drift save. `nextStep()` and `completeOnboarding()` flush pending saves immediately. Timer cancelled via `ref.onDispose`.
- **Resume-to-next-incomplete-step** (`OnboardingController._resumeStepForDraft`): `build()` and `loadExistingDraft()` now derive the correct step from saved draft contents instead of always starting at welcome. Order: experienceGoals → schedule → equipment → unitsMetrics → limitations → byokOptional → review.
- **BYOK explicit skip action** (`lib/features/onboarding/presentation/onboarding_screen.dart`): BYOK step shows `Skip for now` which sets `byokSkipped: true` and advances to review.
- **Hardcoded strings → AppStrings constants**: Goal labels, equipment labels, limitation labels, unit labels, review labels moved to `AppStrings` in `lib/shared/constants/app_strings.dart`.
- **Tests updated**: Controller tests cover debounce, flush-on-next, resume-step, and collapse behavior. Router tests cover complete→home, incomplete→onboarding, and unresolved→startup. Widget tests cover BYOK skip and partial-draft resume.
- Verification: `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 420/420 passed.

## 2026-06-30

### V1-M4-006 — Custom Exercise Editor (complete)

- **Domain layer** (`lib/features/exercise_library/domain/`):
  - `CustomExerciseDraft` — writable draft model with `copyWith()`/`toSeed()`
  - `CustomExerciseValidationError` — typed error with scope/code/message/stepIndex
  - `CustomExerciseEditorMode` — create / edit enum
- **Application layer** (`lib/features/exercise_library/application/`):
  - `CustomExerciseEditorPhase` — 8-phase state machine (loading/editing/saving/saved/deleting/deleted/failure/blocked)
  - `CustomExerciseEditorState` — immutable state with `isLoading`/`isSaving`/`hasValidationErrors`/`copyWith()`/`initial()`
  - `CustomExerciseValidator` — 3 validation rules: name required, muscle groups required, no empty steps
  - `LoadCustomExerciseDraftUseCase` — `createEmptyDraft()` and `loadForEdit()` via existing `ExerciseRepository`
  - `SaveCustomExerciseUseCase` — `create()` and `update()` via existing `ExerciseRepository`
  - `DeleteCustomExerciseUseCase` — `delete()` via existing `ExerciseRepository`
  - `CustomExerciseEditorController` — `AsyncNotifier<CustomExerciseEditorState>` with constructor args (mode, exerciseId). 14 mutation methods: rename, setModality, setEquipment, setDifficulty, toggleMuscleGroup, addStep, updateStep, removeStep, save, delete, clearValidationErrors, discardChanges
- **Presentation layer** (`lib/features/exercise_library/presentation/`):
  - `CustomExerciseEditorScreen` — create/edit factory constructors, loading/error/saved/deleted/editing states, PopScope for unsaved changes
  - 7 widgets: `CustomExerciseNameField`, `CustomExerciseModalitySection` (SegmentedButton + equipment/difficulty dropdowns), `CustomExerciseMuscleGroupPicker` (14 FilterChips), `CustomExerciseStepsEditor` (dynamic add/remove/update), `CustomExerciseErrorBanner`, `DeleteCustomExerciseDialog`, `DiscardCustomExerciseChangesDialog`
- **Infrastructure updates**:
  - `AppRoutes`: +2 — `customExerciseCreate()` (`/exercises/custom/new`), `customExerciseEdit()` (`/exercises/custom/:id/edit`)
  - `AppRouter`: +2 GoRoute entries as sub-routes of `/exercises`
  - `AppStrings`: +23 custom-exercise strings (labels, hints, confirmations)
  - `AppErrorCodes`: +3 custom-exercise error codes
  - `AppProviders`: +5 providers (validator, 3 use cases, controller family)
  - `AddExerciseBottomSheet`: added "Create custom exercise" entry at end of list; navigates to editor, refreshes search on return
- **Critical architecture decisions**:
  - Reuses `ExerciseRepository` — no new persistence, table, or ID generation
  - Keeps all custom exercise editing inside `features/exercise_library/` — closest to persistence
  - Controller uses `AsyncNotifier` with constructor args + `AsyncNotifierProvider.family` (matching codebase family pattern)
  - Integrates into manual flows via `AddExerciseBottomSheet` "Create custom exercise" action
- **Tests**: 55 new — 8 validator, 24 controller, 6 load use case, 4 save use case, 4 name field widget, 6 muscle group picker widget, 3 delete dialog widget
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 863/863 passed.

### V1-M4-006 gap closure — 7 fixes (pop(true), delete/discard labels, SVGs, controllers, tests)

- **Saved phase pop(true)**: `CustomExerciseEditorScreen` saved phase now calls `Navigator.pop(true)` so `AddExerciseBottomSheet` detects the result and refreshes search on return.
- **Delete dialog button label**: Changed from `AppStrings.customExerciseDeleted` (status message) to `AppStrings.customExerciseDelete` ("Delete exercise").
- **Discard dialog button label**: Changed from `AppStrings.done` to `AppStrings.customExerciseDiscard` ("Discard").
- **Material Icons → SVGs**: Replaced `Icons.delete_outline`/`check_circle_outline`/`remove_circle_outline`/`Icons.add` with `OutlinedSvgAssets.trash`/`checkBadge`/`minusCircle`/`plus`.
- **Steps editor tooltip**: Changed from hardcoded `'Remove step'` to `AppStrings.customExerciseRemoveStep`.
- **Inline TextEditingController → StatefulWidget**: `CustomExerciseNameField` and `CustomExerciseStepsEditor` now use `StatefulWidget` with controllers created in `initState` and synced in `didUpdateWidget`, preserving cursor position during typing.
- **3 widget test files added**: `custom_exercise_steps_editor_test` (5 tests), `custom_exercise_error_banner_test` (4 tests), `discard_custom_exercise_changes_dialog_test` (3 tests). Delete dialog test updated for new string constant.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 875/875 passed.

### Fixed (exercise sync bootstrap crash — dataset parser crashes + sync wired into startup)

### Added (V1-M4-005 — Workout History & Programme Library)

- **Saved workout library**: `SavedWorkoutLibraryScreen` with list, archive, delete via `SavedWorkoutLibraryController`.
- **Programme library refactored**: `ProgrammesScreen` now uses `ProgrammeLibraryController` instead of local `FutureProvider`, with archive/delete popup menus.
- **Workout history list**: `LiftLogScreen` replaced placeholder with real controller-driven list, source labels, empty/retry states.
- **Workout history detail**: `WorkoutHistoryDetailScreen` shows session info (name, source, notes, duration) plus read-only exercise/set cards.
- **Domain models**: `SavedWorkoutListItem`, `ProgrammeListItem`, `WorkoutHistoryListItem`, `WorkoutHistoryExerciseItem`, `WorkoutHistorySetItem`, `WorkoutHistoryDetailViewData`.
- **Data layer**: `WorkoutHistoryRepository` (abstract) + `DriftWorkoutHistoryRepository` using existing session/exercise/set DAOs with snapshot-based rendering.
- **Application layer**: 4 controllers, 4 states, 4 use cases all wired into `AppProviders`.
- **Presentation widgets**: `SavedWorkoutListTile`, `ProgrammeListTile`, `WorkoutHistoryListTile`, `WorkoutHistoryExerciseCard`, `WorkoutHistorySetRow`, `ArchiveItemDialog`, `DeleteItemDialog`, `HistoryErrorBanner`.
- **Routes**: `AppRoutes.workoutHistoryDetail()` (`/lift-log/:sessionId`), `AppRoutes.savedWorkoutLibrary()` (`/workouts`).
- **Strings**: 20+ new `AppStrings` for history/library UI and confirmation dialogs.
- **Tests**: 29 new — 1 drift repository (4 tests), 4 controller tests (14 tests), 4 widget tests (7 tests), 2 screen tests (2 tests), 2 widget tests for tiles/cards (4 tests).
- **Architecture**: History detail uses snapshot fields, not live source joins. `WorkoutHistoryRepository` is read-focused, separate from runner repositories. Archive/delete preserves history semantics.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 808/808 passed.

### Post-V1-M4-005 gap closure — dialog confirm labels, test fake cleanup

- **`ArchiveItemDialog` / `DeleteItemDialog`**: Added optional `confirmLabel` parameter. Previously both used hardcoded labels (`AppStrings.archiveProgramme` / `AppStrings.deleteWorkout`) regardless of context.
- **ProgrammesScreen delete**: Now passes `confirmLabel: AppStrings.deleteProgramme` to `DeleteItemDialog` (was silently showing "Delete workout" for programmes).
- **SavedWorkoutLibraryScreen archive**: Now passes `confirmLabel: AppStrings.archiveWorkout` to `ArchiveItemDialog` (was silently showing "Archive programme" for saved workouts).
- **Test fake cleanup**: Removed `shouldThrow` field/constructor param from `_FakeSavedWorkoutRepository` and `_FakeWorkoutHistoryRepository` — both still had `if (shouldThrow)` guards referencing the removed field. Removed throw guards. Removed unused `shouldThrow` import.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 808/808 passed.

- **`EquipmentTag.fromDb` normalizes input** (`lib/shared/domain/equipment_tag.dart`): Instead of exact `dbValue` match, lowercases input, replaces hyphens/underscores, and tries both raw and singular forms. Fallback to `EquipmentTag.other` for unrecognized values. This fixes `Bad state: No element` for `'Band'`, `'Plate'`, `'TRX'`, `'Cables'`, `'Smith-Machine'`, etc.
- **5 new `EquipmentTag` entries**: `bosuBall` (`bosu_ball`), `medicineBall` (`medicine_ball`), `plate`, `trx`, `vitruvian` — all with `dbValue` mappings and exhaustive switch coverage in onboarding/profile taxonomy.
- **Removed strict parser validation**: `exercise_dataset_parser.dart` no longer throws on empty `steps` or empty `primary_muscles` arrays — dataset has valid exercises with these fields missing.
- **Sync integrated into bootstrap**: `BootstrapController.start()` now calls `await ref.read(exerciseDatasetSyncControllerProvider.notifier).initialize()` before setting `BootstrapState.success()`. The router only redirects to onboarding after sync reaches a terminal state (synced/unavailableOffline/failed).
- **Onboarding/profile exhaustive switches**: `_OnboardingTaxonomy` and `_ProfileTaxonomy` `equipmentLabel()`/`equipmentFromLabel()` updated for all 5 new tags. Profile equipment chip selector list extended.
- **Test updates**: Parser tests updated (`"rejects empty steps"` → `"allows empty steps"`, same for primary_muscles). `_FakeSyncController` added to bootstrap test overrides.
- Verification: `dart format` — passed. `flutter analyze` — 0 errors. `flutter test` — 779/779 passed (across all 13 test files).

## 2026-06-22

### Added (V1-M2 TTS/audio-cache slice — TTS service, audio cache DAO, step audio controller, per-step playback UI)

- **`ExerciseTtsService`** (`lib/core/tts/exercise_tts_service.dart`): Abstract interface with `isAvailable()`, `speak()`, `stop()`, `synthesizeToFile()`.
- **`FlutterExerciseTtsService`** (`lib/core/tts/flutter_exercise_tts_service.dart`): Implements `ExerciseTtsService` via `FlutterTts`. Wraps platform TTS with graceful fallback — synthesis failure falls back to runtime `speak()`, cache persisted only when file generation succeeds.
- **`ExerciseAudioCacheDao`** (`lib/core/db/daos/exercise_audio_cache_dao.dart`): Drift DAO with upsert, query by exercise+step+hash, delete by exercise/path, last-accessed update, and `watchByExerciseId()` stream.
- **`ExerciseStepAudioState`** (`lib/features/exercise_library/domain/exercise_step_audio_state.dart`): Immutable state model with 6 phases (`idle`, `checkingCache`, `generating`, `speaking`, `unavailable`, `failed`), optional error code/message, and `isBusy` getter.
- **`ExerciseStepAudioController`** (`lib/features/exercise_library/application/exercise_step_audio_controller.dart`): `Notifier<Map<String, ExerciseStepAudioState>>` — keyed by `'$exerciseId:$stepIndex'`. `playStep()` orchestrates cache check → TTS availability → cache hit/miss → synthesis → speak. `stop()` tears down playback.
- **`ExerciseStepAudioButton`** (`lib/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart`): `ConsumerWidget` — renders appropriate SVG icon (play/stop/spinner/speakerXMark) per phase, with tooltips from `AppStrings`.
- **Detail screen integration**: Each step row in `ExerciseDetailScreen` now shows an `ExerciseStepAudioButton` alongside the step text. Text remains visible regardless of audio state.
- **Provider wiring**: 3 new providers in `AppProviders` — `exerciseTtsServiceProvider`, `exerciseAudioCacheDaoProvider`, `exerciseStepAudioControllerProvider`.
- **Strings**: 3 TTS strings in `AppStrings` (`playStepAudio`, `stopStepAudio`, `audioGenerating`, `audioUnavailable`), 3 safe error strings in `AppErrorStrings` (`ttsUnavailableMessage`, `audioPlaybackFailedMessage`, `audioGenerationFailedMessage`).
- **Tests**: 20 new — 5 DAO (upsert, read, update last accessed, delete by exercise, delete by path) + 6 controller (initial state, unavailable TTS, cache hit, cache miss with generation, stop, generation failure) + 7 widget (idle, speaking, checking, generating, unavailable, failed, button present) + 2 detail screen (audio buttons alongside steps, text visible).
- Security: Safe error codes only — no step text, file paths, or internal identifiers in error messages.
- SVG icons: Uses existing `OulinedSvgAssets.play`, `.stop`, `.speakerXMark`.
- Verification: `dart run build_runner build` — passed. `dart format` — passed. `flutter analyze` — 0 issues. `flutter test` — 379/379 passed.

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
# 2026-07-29 — Final onboarding review body aligned to supplied design

- Reworked `OnboardingScreen` final review into the supplied fixed mobile, single-column bento composition.
- Added exact review hierarchy and spacing for experience, AI status, schedule, equipment, metric integration, and the in-body initialize action.
- Added centralized review sizing and copy tokens; retained editable section actions and local-first/BYOK-safe content.
- Updated `OnboardingStepScaffold` so only the final review places its primary action in the content body.
- Verification: `dart format .` passed; `flutter analyze` passed; onboarding widget tests passed 17/17; full `flutter test` passed 1098/1098.
