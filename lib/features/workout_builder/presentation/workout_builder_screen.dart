import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        onSelectExercises: (exercises) {
          final notifier = ref.read(
            AppProviders.workoutBuilderControllerProvider((
              mode: mode,
              savedWorkoutId: savedWorkoutId,
            )).notifier,
          );
          for (final exercise in exercises) {
            notifier.addExercise(exercise);
          }
        },
      ),
    ).then((_) {
      ref
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .clearFilters();
    });
  }

  Future<void> _saveWorkout(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(
      AppProviders.workoutBuilderControllerProvider((
        mode: mode,
        savedWorkoutId: savedWorkoutId,
      )).notifier,
    );
    await notifier.saveWorkout();

    final state = ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: mode,
            savedWorkoutId: savedWorkoutId,
          )),
        )
        .asData
        ?.value;

    if (state != null && context.mounted) {
      if (state.hasValidationErrors) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.invalidWorkout)));
      } else if (state.phase == WorkoutBuilderPhase.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.workoutSaveFailed)));
      } else {
        ref.invalidate(AppProviders.savedWorkoutLibraryControllerProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.workoutSaved)));
        if (context.mounted) {
          context.pop();
        }
      }
    }
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

  Future<void> _saveWorkout() async {
    final notifier = ref.read(
      AppProviders.workoutBuilderControllerProvider((
        mode: widget.mode,
        savedWorkoutId: widget.savedWorkoutId,
      )).notifier,
    );
    await notifier.saveWorkout();

    final state = ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
          )),
        )
        .asData
        ?.value;

    if (state != null && mounted) {
      if (state.hasValidationErrors) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.invalidWorkout)));
      } else if (state.phase == WorkoutBuilderPhase.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.workoutSaveFailed)));
      } else {
        ref.invalidate(AppProviders.savedWorkoutLibraryControllerProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.workoutSaved)));
        if (context.mounted) {
          context.pop();
        }
      }
    }
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
                ? () {
                    _saveWorkout();
                  }
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
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text:
                          widget.state.draft.restBetweenExercisesSeconds
                              ?.toString() ??
                          '',
                    ),
                  ),
                  decoration: const InputDecoration(
                    labelText: AppStrings.workoutRestLabel,
                    hintText: AppStrings.workoutRestHint,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    ref
                        .read(
                          AppProviders.workoutBuilderControllerProvider((
                            mode: widget.mode,
                            savedWorkoutId: widget.savedWorkoutId,
                          )).notifier,
                        )
                        .updateRestBetweenExercises(int.tryParse(v));
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
                onRestChanged: (exerciseId, rest) {
                  ref
                      .read(
                        AppProviders.workoutBuilderControllerProvider((
                          mode: widget.mode,
                          savedWorkoutId: widget.savedWorkoutId,
                        )).notifier,
                      )
                      .updateExerciseRest(exerciseId, rest);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
