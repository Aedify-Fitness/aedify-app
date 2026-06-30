import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_name_field.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_list.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_builder_error_banner.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/discard_changes_dialog.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_editor_sheet.dart';

class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen.create({super.key})
    : mode = WorkoutBuilderMode.create,
      savedWorkoutId = null;

  const WorkoutBuilderScreen.edit({super.key, required this.savedWorkoutId})
    : mode = WorkoutBuilderMode.edit;

  final WorkoutBuilderMode mode;
  final String? savedWorkoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      AppProviders.workoutBuilderControllerProvider((
        mode: mode,
        savedWorkoutId: savedWorkoutId,
      )),
    );

    return PopScope(
      canPop: !_hasUnsavedChanges(controller),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showDiscardDialog(context, ref);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            mode == WorkoutBuilderMode.create
                ? AppStrings.createWorkout
                : AppStrings.editWorkout,
          ),
          actions: [
            TextButton(
              onPressed: controller.asData?.value.isSaving == true
                  ? null
                  : () => _saveWorkout(context, ref),
              child: controller.asData?.value.isSaving == true
                  ? const SizedBox(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizing.strokeWidth,
                      ),
                    )
                  : Text(AppStrings.saveWorkout),
            ),
          ],
        ),
        body: controller.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => WorkoutBuilderErrorBanner(
            message: AppStrings.workoutLoadFailed,
            onRetry: () => ref.invalidate(
              AppProviders.workoutBuilderControllerProvider((
                mode: mode,
                savedWorkoutId: savedWorkoutId,
              )),
            ),
          ),
          data: (state) => _WorkoutBuilderBody(
            state: state,
            mode: mode,
            savedWorkoutId: savedWorkoutId,
          ),
        ),
        floatingActionButton:
            controller.asData?.value.phase == WorkoutBuilderPhase.editing
            ? FloatingActionButton.extended(
                onPressed: () => _showAddExerciseSheet(context, ref),
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.plus,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                ),
                label: Text(AppStrings.addExercise),
              )
            : null,
      ),
    );
  }

  bool _hasUnsavedChanges(AsyncValue<WorkoutBuilderState> controller) {
    final state = controller.asData?.value;
    return state?.isDirty == true;
  }

  void _showDiscardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => DiscardChangesDialog(
        onDiscard: () {
          ref
              .read(
                AppProviders.workoutBuilderControllerProvider((
                  mode: mode,
                  savedWorkoutId: savedWorkoutId,
                )).notifier,
              )
              .discardChanges();
        },
      ),
    );
  }

  void _showAddExerciseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddExerciseBottomSheet(
        onSelectExercise: (exercise) {
          ref
              .read(
                AppProviders.workoutBuilderControllerProvider((
                  mode: mode,
                  savedWorkoutId: savedWorkoutId,
                )).notifier,
              )
              .addExercise(exercise);
        },
      ),
    );
  }

  void _saveWorkout(BuildContext context, WidgetRef ref) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: mode,
            savedWorkoutId: savedWorkoutId,
          )).notifier,
        )
        .saveWorkout();
  }
}

class _WorkoutBuilderBody extends ConsumerStatefulWidget {
  const _WorkoutBuilderBody({
    required this.state,
    required this.mode,
    required this.savedWorkoutId,
  });

  final WorkoutBuilderState state;
  final WorkoutBuilderMode mode;
  final String? savedWorkoutId;

  @override
  ConsumerState<_WorkoutBuilderBody> createState() =>
      _WorkoutBuilderBodyState();
}

class _WorkoutBuilderBodyState extends ConsumerState<_WorkoutBuilderBody> {
  final _supersetSelection = <String>{};

  void _saveWorkout() {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
          )).notifier,
        )
        .saveWorkout();
  }

  void _showSupersetSheet() {
    final exercises = widget.state.draft.exercises;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final selected = {..._supersetSelection};
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SupersetEditorSheet(
              exercises: exercises,
              selectedExerciseIds: selected,
              onToggleSelection: (id) {
                setSheetState(() {
                  if (selected.contains(id)) {
                    selected.remove(id);
                  } else {
                    selected.add(id);
                  }
                });
              },
              onCreateSuperset: () {
                if (selected.length >= 2) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .createSuperset(selected.toList());
                  Navigator.pop(ctx);
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.state.phase == WorkoutBuilderPhase.failure &&
            widget.state.errorMessage != null)
          WorkoutBuilderErrorBanner(
            message: widget.state.errorMessage!,
            onRetry: widget.state.errorCode == AppErrorCodes.saveFailed
                ? () => _saveWorkout()
                : null,
          ),
        if (widget.state.phase == WorkoutBuilderPhase.saved)
          WorkoutBuilderErrorBanner(message: AppStrings.workoutSaved),
        if (widget.state.hasValidationErrors)
          WorkoutBuilderErrorBanner(message: AppStrings.invalidWorkout),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl * 2),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: WorkoutNameField(
                  initialValue: widget.state.draft.name,
                  onChanged: (value) {
                    ref
                        .read(
                          AppProviders.workoutBuilderControllerProvider((
                            mode: widget.mode,
                            savedWorkoutId: widget.savedWorkoutId,
                          )).notifier,
                        )
                        .renameWorkout(value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              WorkoutExerciseList(
                exercises: widget.state.draft.exercises,
                setTypeOptions: ref
                    .watch(AppProviders.setTypeOptionsUseCaseProvider)
                    .execute(),
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .reorderExercises(oldIndex, newIndex);
                },
                onRemove: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .removeExercise(id);
                },
                onDuplicate: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .duplicateExercise(id);
                },
                onAddSet: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .addSet(id);
                },
                onUpdateSet: (exerciseId, setId, prescription) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .updateSet(
                        exerciseDraftId: exerciseId,
                        setId: setId,
                        prescription: prescription,
                      );
                },
                onRemoveSet: (exerciseId, setId) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .removeSet(exerciseDraftId: exerciseId, setId: setId);
                },
                validationErrors: widget.state.validationErrors,
                onOpenSupersetEditor: _showSupersetSheet,
                onRemoveFromSuperset: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .removeExerciseFromSuperset(id);
                },
                onDeleteSuperset: (groupId) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .deleteSupersetGroup(groupId);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
