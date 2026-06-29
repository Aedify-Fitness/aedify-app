import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_name_field.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_list.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_builder_error_banner.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/discard_changes_dialog.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';

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
          data: (state) => _WorkoutBuilderBody(state: state),
        ),
        floatingActionButton:
            controller.asData?.value.phase == WorkoutBuilderPhase.editing
            ? FloatingActionButton.extended(
                onPressed: () => _showAddExerciseSheet(context, ref),
                icon: const Icon(Icons.add),
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

class _WorkoutBuilderBody extends ConsumerWidget {
  const _WorkoutBuilderBody({required this.state});

  final WorkoutBuilderState state;

  void _saveWorkout(WidgetRef ref) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: state.mode,
            savedWorkoutId: state.savedWorkoutId,
          )).notifier,
        )
        .saveWorkout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (state.phase == WorkoutBuilderPhase.failure &&
            state.errorMessage != null)
          WorkoutBuilderErrorBanner(
            message: state.errorMessage!,
            onRetry: state.errorCode == 'save_failed'
                ? () => _saveWorkout(ref)
                : null,
          ),
        if (state.phase == WorkoutBuilderPhase.saved)
          WorkoutBuilderErrorBanner(message: AppStrings.workoutSaved),
        if (state.hasValidationErrors)
          WorkoutBuilderErrorBanner(message: AppStrings.invalidWorkout),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl * 2),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: WorkoutNameField(
                  initialValue: state.draft.name,
                  onChanged: (value) {
                    ref
                        .read(
                          AppProviders.workoutBuilderControllerProvider((
                            mode: state.mode,
                            savedWorkoutId: state.savedWorkoutId,
                          )).notifier,
                        )
                        .renameWorkout(value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              WorkoutExerciseList(
                exercises: state.draft.exercises,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
                        )).notifier,
                      )
                      .reorderExercises(oldIndex, newIndex);
                },
                onRemove: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
                        )).notifier,
                      )
                      .removeExercise(id);
                },
                onDuplicate: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
                        )).notifier,
                      )
                      .duplicateExercise(id);
                },
                onAddSet: (id) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
                        )).notifier,
                      )
                      .addSet(id);
                },
                onUpdateSet: (exerciseId, setId, prescription) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
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
                          mode: state.mode,
                          savedWorkoutId: state.savedWorkoutId,
                        )).notifier,
                      )
                      .removeSet(exerciseDraftId: exerciseId, setId: setId);
                },
                validationErrors: state.validationErrors,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
