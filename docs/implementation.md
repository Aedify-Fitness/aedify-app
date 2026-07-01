# Aedify — Implementation Status

## Current Status

| Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Current Milestone** | M4 — Persistence Foundation + Workout Builder + Programme Builder + Workout Runner + Workout History & Programme Library + Custom Exercise Editor (Programmes, Saved Workouts, Workout Builder, Programme Builder, Workout Session Runner, Lift Log, Programme Library, Custom Exercise Management)                                                                                                                                                                                        |
| **Status**            | V1-M3-001 through V1-M3-009 complete. **V1-M4-001 (persistence foundation) complete**. **V1-M4-002 (workout builder) complete**. **V1-M4-003 (programme builder) complete**. **V1-M4-004 (workout session runner) complete**. **V1-M4-005 (workout history & programme library) complete**. **V1-M4-006 (custom exercise editor) complete**. **V1-M4-007 (warmup vs working set behavior) complete**. **V1-M4-008 (superset / execution groups) complete**. **V1-M4-009 (reusable draft validation service) complete**. **V1-M4-010 (transactional save and rollback service) complete** — 7 core transaction files, 3 repositories refactored, 2 test injection utilities, 7 new transaction/rollback tests, 1001/1001 passed. |
| **Blockers**          | None                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **Pre-existing**      | Flutter 3.44.4 `ink_sparkle.frag` shader regression breaks FilledButton tap tests. Affects `complete_workout_sheet_test.dart` (mitigated with `NoSplash` in test theme) and pre-existing `programme_save_bar_test.dart`.                                                                                                                                                                                                                                                                   |

## Completed Work

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
