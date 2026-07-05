import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
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
        appBar: AppBar(),
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
  late final TextEditingController _nameController;
  late final TextEditingController _focusController;
  late final TextEditingController _restController;
  late final ({WorkoutBuilderMode mode, String? savedWorkoutId}) _providerKey;
  int? _selectedExerciseIndex;

  @override
  void initState() {
    super.initState();
    _providerKey = (mode: widget.mode, savedWorkoutId: widget.savedWorkoutId);
    _nameController = TextEditingController(text: widget.state.draft.name);
    _focusController = TextEditingController(
      text: widget.state.draft.goalTags.isNotEmpty
          ? widget.state.draft.goalTags.first
          : '',
    );
    _restController = TextEditingController(
      text: widget.state.draft.restBetweenExercisesSeconds?.toString() ?? '',
    );
    if (widget.state.draft.exercises.isNotEmpty) {
      _selectedExerciseIndex = 0;
    }
  }

  @override
  void didUpdateWidget(_WorkoutBuilderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.draft.name != oldWidget.state.draft.name &&
        widget.state.draft.name != _nameController.text) {
      _nameController.text = widget.state.draft.name;
    }
    final focus = widget.state.draft.goalTags.isNotEmpty
        ? widget.state.draft.goalTags.first
        : '';
    if (focus != _focusController.text) {
      _focusController.text = focus;
    }
    final rest = widget.state.draft.restBetweenExercisesSeconds;
    if (rest != null && rest.toString() != _restController.text) {
      _restController.text = rest.toString();
    }
    if (widget.state.draft.exercises.isNotEmpty &&
        _selectedExerciseIndex == null) {
      _selectedExerciseIndex = 0;
    } else if (widget.state.draft.exercises.isEmpty &&
        _selectedExerciseIndex != null) {
      _selectedExerciseIndex = null;
    } else if (_selectedExerciseIndex != null &&
        _selectedExerciseIndex! >= widget.state.draft.exercises.length) {
      _selectedExerciseIndex = widget.state.draft.exercises.length - 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
          )).notifier,
        )
        .renameWorkout(value);
  }

  void _onFocusChanged(String value) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
          )).notifier,
        )
        .updateGoalTags(value.isNotEmpty ? [value] : []);
  }

  void _onRestChanged(String value) {
    final parsed = int.tryParse(value);
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
          )).notifier,
        )
        .updateRestBetweenExercises(parsed);
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddExerciseBottomSheet(
        onSelectExercises: (exercises) {
          final notifier = ref.read(
            AppProviders.workoutBuilderControllerProvider((
              mode: widget.mode,
              savedWorkoutId: widget.savedWorkoutId,
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

  void _saveWorkout() async {
    final ctx = context;
    final currentMode = widget.mode;
    final currentId = widget.savedWorkoutId;

    final notifier = ref.read(
      AppProviders.workoutBuilderControllerProvider((
        mode: currentMode,
        savedWorkoutId: currentId,
      )).notifier,
    );
    await notifier.saveWorkout();

    final state = ref
        .read(
          AppProviders.workoutBuilderControllerProvider((
            mode: currentMode,
            savedWorkoutId: currentId,
          )),
        )
        .asData
        ?.value;

    if (state != null && ctx.mounted) {
      if (state.hasValidationErrors) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(AppStrings.invalidWorkout)));
      } else if (state.phase == WorkoutBuilderPhase.failure) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(AppStrings.workoutSaveFailed)));
      } else {
        ref.invalidate(AppProviders.savedWorkoutLibraryControllerProvider);
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.workoutSaved)));
        if (ctx.mounted) {
          ctx.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.state.draft.exercises;
    final selectedExerciseIdx = _selectedExerciseIndex;
    final selectedExercise =
        selectedExerciseIdx != null && selectedExerciseIdx < exercises.length
        ? exercises[selectedExerciseIdx]
        : null;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              top: AppSpacing.md,
              right: AppSpacing.lg,
              bottom: AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(mode: widget.mode),
                const SizedBox(height: AppSpacing.lg),
                _InputSection(
                  nameController: _nameController,
                  focusController: _focusController,
                  restController: _restController,
                  onNameChanged: _onNameChanged,
                  onFocusChanged: _onFocusChanged,
                  onRestChanged: _onRestChanged,
                ),
                const SizedBox(height: AppSpacing.xl),
                _MainContentSection(
                  exercises: exercises,
                  selectedExercise: selectedExercise,
                  selectedExerciseIndex: _selectedExerciseIndex,
                  providerKey: _providerKey,
                  onAddExercise: _showAddExerciseSheet,
                  onSelectExercise: (index) {
                    setState(() => _selectedExerciseIndex = index);
                  },
                  onReorderExercises: (oldIndex, newIndex) {
                    ref
                        .read(
                          AppProviders.workoutBuilderControllerProvider(
                            _providerKey,
                          ).notifier,
                        )
                        .reorderExercises(oldIndex, newIndex);
                    if (_selectedExerciseIndex == oldIndex) {
                      setState(() => _selectedExerciseIndex = newIndex);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _FooterSection(
                  canSave:
                      widget.state.isDirty &&
                      widget.state.draft.name.trim().isNotEmpty &&
                      widget.state.draft.exercises.isNotEmpty,
                  onSave: _saveWorkout,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.mode});

  final WorkoutBuilderMode mode;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mode == WorkoutBuilderMode.create
              ? AppStrings.createNewWorkout
              : AppStrings.editWorkout,
          style: AppTextStyles.headlineLgMobile,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.workoutBuilderSubtitle,
          style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.nameController,
    required this.focusController,
    required this.restController,
    required this.onNameChanged,
    required this.onFocusChanged,
    required this.onRestChanged,
  });

  final TextEditingController nameController;
  final TextEditingController focusController;
  final TextEditingController restController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onFocusChanged;
  final ValueChanged<String> onRestChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputField(
          label: AppStrings.workoutName,
          hint: AppStrings.workoutNameHint,
          controller: nameController,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _InputField(
          label: AppStrings.workoutFocus,
          hint: AppStrings.workoutFocusHint,
          controller: focusController,
          onChanged: onFocusChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _InputField(
          label: AppStrings.workoutRestLabel,
          hint: AppStrings.defaultRestHint,
          controller: restController,
          onChanged: onRestChanged,
        ),
      ],
    );
  }
}

class _MainContentSection extends ConsumerWidget {
  const _MainContentSection({
    required this.exercises,
    required this.selectedExercise,
    required this.selectedExerciseIndex,
    required this.providerKey,
    required this.onAddExercise,
    required this.onSelectExercise,
    required this.onReorderExercises,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final WorkoutBuilderExerciseDraft? selectedExercise;
  final int? selectedExerciseIndex;
  final ({WorkoutBuilderMode mode, String? savedWorkoutId}) providerKey;
  final VoidCallback onAddExercise;
  final void Function(int index) onSelectExercise;
  final void Function(int oldIndex, int newIndex) onReorderExercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = providerKey;

    return Column(
      children: [
        _ExerciseListPanel(
          exercises: exercises,
          selectedIndex: selectedExerciseIndex,
          onSelect: onSelectExercise,
          onReorder: onReorderExercises,
          onRemove: (id) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .removeExercise(id);
          },
          onDuplicate: (id) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .duplicateExercise(id);
          },
          onAddExercise: onAddExercise,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ExerciseConfigPanel(
          selectedExercise: selectedExercise,
          setTypeOptions: ref
              .read(AppProviders.setTypeOptionsUseCaseProvider)
              .execute(),
          onAddSet: (id) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .addSet(id);
          },
          onRemoveSet: (exerciseId, setId) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .removeSet(exerciseDraftId: exerciseId, setId: setId);
          },
          onUpdateSet: (exerciseId, setId, prescription) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .updateSet(
                  exerciseDraftId: exerciseId,
                  setId: setId,
                  prescription: prescription,
                );
          },
          onUpdateNotes: (exerciseId, notes) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .updateExerciseNotes(exerciseId, notes);
          },
          onDeleteExercise: (id) {
            ref
                .read(
                  AppProviders.workoutBuilderControllerProvider(key).notifier,
                )
                .removeExercise(id);
          },
        ),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection({required this.canSave, required this.onSave});

  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: canSave
          ? SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.secondary,
                  foregroundColor: cs.onSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.buttonVertical + AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                label: Text(
                  AppStrings.saveWorkout,
                  style: AppTextStyles.labelMd.copyWith(color: cs.onSecondary),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: BorderSide(color: cs.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.inputVertical,
            ),
          ),
          style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }
}

class _ExerciseListPanel extends StatelessWidget {
  const _ExerciseListPanel({
    required this.exercises,
    required this.selectedIndex,
    required this.onSelect,
    required this.onReorder,
    required this.onRemove,
    required this.onDuplicate,
    required this.onAddExercise,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDuplicate;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.exercisesLabel} (${exercises.length})',
          style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        if (exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Column(
                children: [
                  Text(
                    AppStrings.noExercisesInWorkout,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.addExercisesToGetStarted,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            onReorderItem: onReorder,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isSelected = selectedIndex == index;
              return _MiniExerciseCard(
                key: ValueKey(exercise.id),
                exercise: exercise,
                index: index,
                isSelected: isSelected,
                onSelect: () => onSelect(index),
                onRemove: () => onRemove(exercise.id),
                onDuplicate: () => onDuplicate(exercise.id),
              );
            },
          ),
        const SizedBox(height: AppSpacing.md),
        _AddExerciseButton(onTap: onAddExercise),
      ],
    );
  }
}

class _MiniExerciseCard extends StatelessWidget {
  const _MiniExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.isSelected,
    required this.onSelect,
    required this.onRemove,
    required this.onDuplicate,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final int index;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onRemove;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    final setCount = exercise.sets.length;

    SetPrescriptionDraft? lastSet;
    for (var i = exercise.sets.length - 1; i >= 0; i--) {
      final s = exercise.sets[i];
      if (s.prescribedRpeMin != null ||
          s.prescribedRpeMax != null ||
          s.prescribedRir != null ||
          s.prescribedRepsMin != null ||
          s.prescribedRepsMax != null ||
          s.prescribedRepsExact != null ||
          s.prescribedWeightKg != null ||
          s.restSeconds != null) {
        lastSet = s;
        break;
      }
    }
    if (lastSet == null && exercise.sets.isNotEmpty) {
      lastSet = exercise.sets.first;
    }

    final restSec = lastSet?.restSeconds;

    String? summary;
    if (lastSet != null) {
      final parts = <String>[];
      if (lastSet.prescribedRpeMin != null &&
          lastSet.prescribedRpeMax != null) {
        parts.add(
          'RPE ${lastSet.prescribedRpeMin!.toInt()}-${lastSet.prescribedRpeMax!.toInt()}',
        );
      } else if (lastSet.prescribedRir != null) {
        parts.add('RIR ${lastSet.prescribedRir}');
      } else if (lastSet.prescribedRepsExact != null) {
        parts.add('${lastSet.prescribedRepsExact} reps');
      } else if (lastSet.prescribedRepsMin != null &&
          lastSet.prescribedRepsMax != null) {
        parts.add(
          '${lastSet.prescribedRepsMin}-${lastSet.prescribedRepsMax} reps',
        );
      }
      summary = parts.isNotEmpty ? parts.first : null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            border: Border.all(
              color: isSelected ? cs.secondary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exercise.name,
                          style: AppTextStyles.labelMd.copyWith(
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.surfaceContainerHigh
                                : cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            exercise.exercise.modality.toUpperCase(),
                            style: AppTextStyles.headlineXl.copyWith(
                              fontSize: AppFontSizes.xxs,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    _ExerciseMenu(onDuplicate: onDuplicate, onDelete: onRemove)
                  else
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: SvgPicture.asset(
                          OutlinedSvgAssets.bars3,
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          colorFilter: ColorFilter.mode(
                            cs.outline,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.stack,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      isSelected ? cs.secondary : cs.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$setCount sets',
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected ? cs.secondary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (summary != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '•',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? cs.secondary.withValues(alpha: 0.5)
                            : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      summary,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? cs.secondary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (restSec != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '•',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? cs.secondary.withValues(alpha: 0.5)
                            : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    SvgPicture.asset(
                      OutlinedSvgAssets.clock,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        isSelected ? cs.secondary : cs.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${restSec}s',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? cs.secondary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseMenu extends StatelessWidget {
  const _ExerciseMenu({required this.onDuplicate, required this.onDelete});

  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'duplicate':
            onDuplicate();
          case 'delete':
            onDelete();
        }
      },
      color: cs.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.documentDuplicate,
                width: AppSizing.iconXs,
                height: AppSizing.iconXs,
                colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.duplicateExercise,
                style: AppTextStyles.labelSm.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.trash,
                width: AppSizing.iconXs,
                height: AppSizing.iconXs,
                colorFilter: ColorFilter.mode(cs.error, BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.removeExercise,
                style: AppTextStyles.labelSm.copyWith(color: cs.error),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: SvgPicture.asset(
          OutlinedSvgAssets.ellipsisVertical,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _AddExerciseButton extends StatelessWidget {
  const _AddExerciseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashWidth: 6,
          gapWidth: 8,
          borderRadius: AppRadius.defaultRadius,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.plusCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  cs.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.addExercise,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gapWidth != gapWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _ExerciseConfigPanel extends StatelessWidget {
  const _ExerciseConfigPanel({
    required this.selectedExercise,
    required this.setTypeOptions,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
    required this.onUpdateNotes,
    required this.onDeleteExercise,
  });

  final WorkoutBuilderExerciseDraft? selectedExercise;
  final List<SetTypeOption> setTypeOptions;

  final ValueChanged<String> onAddSet;
  final void Function(String exerciseId, String setId) onRemoveSet;
  final void Function(
    String exerciseId,
    String setId,
    SetPrescriptionDraft prescription,
  )
  onUpdateSet;
  final void Function(String exerciseId, String? notes) onUpdateNotes;
  final ValueChanged<String> onDeleteExercise;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    final exercise = selectedExercise;
    if (exercise == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.arrowsRightLeft,
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              colorFilter: ColorFilter.mode(
                cs.onSurfaceVariant.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.selectExerciseToConfigure,
              style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigPanelHeader(
            exercise: exercise,
            onDelete: () => onDeleteExercise(exercise.id),
          ),
          AppWhiteSpace.hXl,
          _SetsTable(
            exercise: exercise,
            setTypeOptions: setTypeOptions,
            onAddSet: () => onAddSet(exercise.id),
            onRemoveSet: (setId) => onRemoveSet(exercise.id, setId),
            onUpdateSet: (setId, prescription) =>
                onUpdateSet(exercise.id, setId, prescription),
          ),
          const Divider(height: 1, thickness: 1),
          _CoachNotesField(
            exerciseId: exercise.id,
            initialNotes: exercise.notes,
            onChanged: (notes) => onUpdateNotes(exercise.id, notes),
          ),
        ],
      ),
    );
  }
}

class _ConfigPanelHeader extends StatelessWidget {
  const _ConfigPanelHeader({required this.exercise, required this.onDelete});

  final WorkoutBuilderExerciseDraft exercise;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.fitness_center,
            color: cs.onSecondaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.exercise.name,
                style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                AppStrings.configLabel.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: AppFontSizes.xxs,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.trash,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
          ),
          onPressed: onDelete,
          tooltip: AppStrings.removeExercise,
        ),
      ],
    );
  }
}

class _SetsTable extends StatelessWidget {
  const _SetsTable({
    required this.exercise,
    required this.setTypeOptions,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final List<SetTypeOption> setTypeOptions;
  final VoidCallback onAddSet;
  final ValueChanged<String> onRemoveSet;
  final void Function(String setId, SetPrescriptionDraft prescription)
  onUpdateSet;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TableHeader(label: AppStrings.setNumberColumn, flex: 2),
            _TableHeader(label: AppStrings.setTypeColumn, flex: 3),
            _TableHeader(label: AppStrings.weightColumn, flex: 4),
            _TableHeader(label: AppStrings.repsColumn, flex: 3),
            _TableHeader(label: AppStrings.targetColumn, flex: 4),
            _TableHeader(label: AppStrings.restColumn, flex: 2),
            const SizedBox(width: 40),
          ],
        ),
        const Divider(height: 1, thickness: 1),
        ...exercise.sets.map(
          (set) => _SetTableRow(
            key: ValueKey(set.id),
            set: set,
            setTypeOptions: setTypeOptions,
            onUpdate: (updated) => onUpdateSet(set.id, updated),
            onRemove: () => onRemoveSet(set.id),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onAddSet,
          child: Container(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.plus,
                  width: AppSizing.iconXs,
                  height: AppSizing.iconXs,
                  colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppStrings.addSet,
                  style: AppTextStyles.labelSm.copyWith(
                    color: cs.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _SetTableRow extends StatefulWidget {
  const _SetTableRow({
    super.key,
    required this.set,
    required this.setTypeOptions,
    required this.onUpdate,
    required this.onRemove,
  });

  final SetPrescriptionDraft set;
  final List<SetTypeOption> setTypeOptions;
  final ValueChanged<SetPrescriptionDraft> onUpdate;
  final VoidCallback onRemove;

  @override
  State<_SetTableRow> createState() => _SetTableRowState();
}

class _SetTableRowState extends State<_SetTableRow> {
  late final TextEditingController _repsController;
  late final TextEditingController _targetController;
  late final TextEditingController _weightController;
  late final TextEditingController _restController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _targetController = TextEditingController();
    _weightController = TextEditingController();
    _restController = TextEditingController();
    _syncControllers();
    _repsController.addListener(_onRepsChanged);
    _targetController.addListener(_onTargetChanged);
    _weightController.addListener(_onWeightChanged);
    _restController.addListener(_onRestChanged);
  }

  @override
  void didUpdateWidget(_SetTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.set.id != oldWidget.set.id ||
        widget.set.setIndex != oldWidget.set.setIndex ||
        widget.set.prescribedRepsMin != oldWidget.set.prescribedRepsMin ||
        widget.set.prescribedRepsMax != oldWidget.set.prescribedRepsMax ||
        widget.set.prescribedRepsExact != oldWidget.set.prescribedRepsExact ||
        widget.set.prescribedRpeMin != oldWidget.set.prescribedRpeMin ||
        widget.set.prescribedRpeMax != oldWidget.set.prescribedRpeMax ||
        widget.set.prescribedRir != oldWidget.set.prescribedRir ||
        widget.set.prescribedWeightKg != oldWidget.set.prescribedWeightKg ||
        widget.set.restSeconds != oldWidget.set.restSeconds) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _targetController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  static String _formatWeight(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toString();
  }

  void _syncControllers() {
    _isSyncing = true;
    _repsController.text = _formatReps();
    _targetController.text = _formatTarget();
    _weightController.text = widget.set.prescribedWeightKg != null
        ? _formatWeight(widget.set.prescribedWeightKg!)
        : '';
    _restController.text = widget.set.restSeconds?.toString() ?? '';
    _isSyncing = false;
  }

  String _formatReps() {
    final min = widget.set.prescribedRepsMin;
    final max = widget.set.prescribedRepsMax;
    final exact = widget.set.prescribedRepsExact;
    if (exact != null) return '$exact';
    if (min != null && max != null) return '$min-$max';
    if (min != null) return '$min';
    return '';
  }

  String _formatTarget() {
    final rpeMin = widget.set.prescribedRpeMin;
    final rpeMax = widget.set.prescribedRpeMax;
    final rir = widget.set.prescribedRir;
    if (rpeMin != null && rpeMax != null) {
      return '${rpeMin.toInt()}-${rpeMax.toInt()}';
    }
    if (rir != null) return '$rir';
    return '';
  }

  void _onRepsChanged() {
    if (_isSyncing) return;
    final text = _repsController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearReps());
      return;
    }
    final parts = text.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0].trim());
      final max = int.tryParse(parts[1].trim());
      if (min != null && max != null) {
        widget.onUpdate(
          widget.set.clearReps().copyWith(
            prescribedRepsMin: min,
            prescribedRepsMax: max,
          ),
        );
      }
    } else {
      final exact = int.tryParse(parts[0].trim());
      widget.onUpdate(
        widget.set.clearReps().copyWith(prescribedRepsExact: exact),
      );
    }
  }

  void _onTargetChanged() {
    if (_isSyncing) return;
    final text = _targetController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearTarget());
      return;
    }
    final upper = text.toUpperCase();
    if (upper.startsWith('RPE')) {
      final numbers = text.substring(3).trim().split('-');
      if (numbers.length == 2) {
        final min = double.tryParse(numbers[0].trim());
        final max = double.tryParse(numbers[1].trim());
        widget.onUpdate(
          widget.set.clearTarget().copyWith(
            prescribedRpeMin: min,
            prescribedRpeMax: max,
          ),
        );
      }
    } else if (upper.startsWith('RIR')) {
      final rir = int.tryParse(text.substring(3).trim());
      if (rir != null) {
        widget.onUpdate(widget.set.clearTarget().copyWith(prescribedRir: rir));
      }
    } else if (text.contains('-')) {
      final parts = text.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].trim());
        final max = double.tryParse(parts[1].trim());
        if (min != null && max != null) {
          widget.onUpdate(
            widget.set.clearTarget().copyWith(
              prescribedRpeMin: min,
              prescribedRpeMax: max,
            ),
          );
        }
      }
    } else {
      final rir = int.tryParse(text);
      if (rir != null) {
        widget.onUpdate(widget.set.clearTarget().copyWith(prescribedRir: rir));
      }
    }
  }

  void _onWeightChanged() {
    if (_isSyncing) return;
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearWeight());
      return;
    }
    final value = double.tryParse(text);
    if (value != null) {
      widget.onUpdate(widget.set.copyWith(prescribedWeightKg: value));
    }
  }

  void _onRestChanged() {
    if (_isSyncing) return;
    final text = _restController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearRest());
      return;
    }
    final value = int.tryParse(text);
    if (value != null) {
      widget.onUpdate(widget.set.copyWith(restSeconds: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final set = widget.set;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: set.setIndex == 0
                ? AppSpacing.xs + AppSpacing.sm
                : AppSpacing.xxs + AppSpacing.xs,
            bottom: AppSpacing.xxs + AppSpacing.xs,
          ),
          child: Row(
            spacing: AppSpacing.xs,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '${set.setIndex + 1}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    final newType = set.setType == SetType.working
                        ? SetType.warmup
                        : SetType.working;
                    widget.onUpdate(set.copyWith(setType: newType));
                  },
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: set.setType == SetType.working
                          ? cs.secondary.withValues(alpha: 0.1)
                          : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      set.setType == SetType.working
                          ? AppStrings.setTypeWorking
                          : AppStrings.setTypeWarmup,
                      style: AppTextStyles.labelSm.copyWith(
                        color: set.setType == SetType.working
                            ? cs.secondary
                            : cs.onSurfaceVariant,
                        fontSize: AppFontSizes.xxs,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _repsController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      hintText: AppStrings.rpeHint,
                      hintStyle: AppTextStyles.labelSm.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _restController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.trash,
                    width: AppSizing.iconXs,
                    height: AppSizing.iconXs,
                    colorFilter: ColorFilter.mode(
                      cs.onSurfaceVariant.withValues(alpha: 0.5),
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: widget.onRemove,
                  tooltip: AppStrings.removeSet,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoachNotesField extends StatefulWidget {
  const _CoachNotesField({
    required this.exerciseId,
    required this.initialNotes,
    required this.onChanged,
  });

  final String exerciseId;
  final String? initialNotes;
  final ValueChanged<String?> onChanged;

  @override
  State<_CoachNotesField> createState() => _CoachNotesFieldState();
}

class _CoachNotesFieldState extends State<_CoachNotesField> {
  late final TextEditingController _controller;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(_CoachNotesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exerciseId != oldWidget.exerciseId ||
        widget.initialNotes != oldWidget.initialNotes) {
      if (widget.initialNotes != _controller.text) {
        _isSyncing = true;
        _controller.text = widget.initialNotes ?? '';
        _isSyncing = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_isSyncing) return;
    widget.onChanged(_controller.text.isNotEmpty ? _controller.text : null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.coachNotes,
            style: AppTextStyles.labelSm.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStrings.coachNotesHint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                borderSide: BorderSide(color: cs.secondary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
