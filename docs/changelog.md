# Aedify — Changelog

All meaningful project changes are recorded here in reverse chronological order.

---

## 2026-07-01

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
