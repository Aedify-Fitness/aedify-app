import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
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
  bool _isSupersetSelectionMode = false;
  final Set<String> _selectedSupersetIds = {};

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
        (_selectedExerciseIndex! >= widget.state.draft.exercises.length ||
            _selectedExerciseIndex! < 0)) {
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

  void _openSupersetSelection() {
    setState(() {
      _selectedSupersetIds.clear();
      _isSupersetSelectionMode = true;
    });
  }

  void _cancelSupersetSelection() {
    setState(() {
      _selectedSupersetIds.clear();
      _isSupersetSelectionMode = false;
    });
  }

  void _toggleExerciseSupersetSelection(String id) {
    final exercises = widget.state.draft.exercises;
    final exercise = exercises.where((e) => e.id == id).firstOrNull;
    if (exercise == null || exercise.supersetGroupId != null) return;
    setState(() {
      if (_selectedSupersetIds.contains(id)) {
        _selectedSupersetIds.remove(id);
      } else {
        _selectedSupersetIds.add(id);
      }
    });
  }

  void _createSupersetFromSelection() {
    if (_selectedSupersetIds.length < 2) return;
    final notifier = ref.read(
      AppProviders.workoutBuilderControllerProvider(_providerKey).notifier,
    );
    notifier.createSuperset(_selectedSupersetIds.toList());
    setState(() {
      _selectedSupersetIds.clear();
      _isSupersetSelectionMode = false;
    });
  }

  void _removeFromSuperset(String exerciseDraftId) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider(_providerKey).notifier,
        )
        .removeExerciseFromSuperset(exerciseDraftId);
  }

  void _reorderWithinSuperset(String exerciseDraftId, int newOrder) {
    ref
        .read(
          AppProviders.workoutBuilderControllerProvider(_providerKey).notifier,
        )
        .reorderWithinSuperset(
          exerciseDraftId: exerciseDraftId,
          newOrder: newOrder,
        );
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
        selectedExerciseIdx != null &&
            selectedExerciseIdx >= 0 &&
            selectedExerciseIdx < exercises.length
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
                AppWhiteSpace.hLg,
                _InputSection(
                  nameController: _nameController,
                  focusController: _focusController,
                  restController: _restController,
                  onNameChanged: _onNameChanged,
                  onFocusChanged: _onFocusChanged,
                  onRestChanged: _onRestChanged,
                ),
                AppWhiteSpace.hXl,
                _MainContentSection(
                  exercises: exercises,
                  selectedExercise: selectedExercise,
                  selectedExerciseIndex: _selectedExerciseIndex,
                  providerKey: _providerKey,
                  onAddExercise: _showAddExerciseSheet,
                  isSupersetSelectionMode: _isSupersetSelectionMode,
                  selectedSupersetIds: _selectedSupersetIds,
                  onOpenSupersetSelection: _openSupersetSelection,
                  onCancelSupersetSelection: _cancelSupersetSelection,
                  onToggleSupersetSelection: _toggleExerciseSupersetSelection,
                  onCreateSupersetFromSelection: _createSupersetFromSelection,
                  onRemoveFromSuperset: _removeFromSuperset,
                  onReorderWithinSuperset: _reorderWithinSuperset,
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
                AppWhiteSpace.hXl,
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
        AppWhiteSpace.hXs,
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
        AppTextField(
          labelText: AppStrings.workoutName,
          hintText: AppStrings.workoutNameHint,
          controller: nameController,
          onChanged: onNameChanged,
        ),
        AppWhiteSpace.hMd,
        AppTextField(
          labelText: AppStrings.workoutFocus,
          hintText: AppStrings.workoutFocusHint,
          controller: focusController,
          onChanged: onFocusChanged,
        ),
        AppWhiteSpace.hMd,
        AppTextField(
          labelText: AppStrings.workoutRestLabel,
          hintText: AppStrings.defaultRestHint,
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
    required this.isSupersetSelectionMode,
    required this.selectedSupersetIds,
    required this.onOpenSupersetSelection,
    required this.onCancelSupersetSelection,
    required this.onToggleSupersetSelection,
    required this.onCreateSupersetFromSelection,
    required this.onRemoveFromSuperset,
    required this.onReorderWithinSuperset,
    required this.onSelectExercise,
    required this.onReorderExercises,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final WorkoutBuilderExerciseDraft? selectedExercise;
  final int? selectedExerciseIndex;
  final ({WorkoutBuilderMode mode, String? savedWorkoutId}) providerKey;
  final VoidCallback onAddExercise;
  final bool isSupersetSelectionMode;
  final Set<String> selectedSupersetIds;
  final VoidCallback onOpenSupersetSelection;
  final VoidCallback onCancelSupersetSelection;
  final ValueChanged<String> onToggleSupersetSelection;
  final VoidCallback onCreateSupersetFromSelection;
  final ValueChanged<String> onRemoveFromSuperset;
  final void Function(String exerciseDraftId, int newOrder)
  onReorderWithinSuperset;
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
          isSupersetSelectionMode: isSupersetSelectionMode,
          selectedSupersetIds: selectedSupersetIds,
          onOpenSupersetSelection: onOpenSupersetSelection,
          onCancelSupersetSelection: onCancelSupersetSelection,
          onToggleSupersetSelection: onToggleSupersetSelection,
          onCreateSupersetFromSelection: onCreateSupersetFromSelection,
          onRemoveFromSuperset: onRemoveFromSuperset,
          onReorderWithinSuperset: onReorderWithinSuperset,
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
        AppWhiteSpace.hLg,
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

class _ExerciseListPanel extends StatelessWidget {
  const _ExerciseListPanel({
    required this.exercises,
    required this.selectedIndex,
    required this.isSupersetSelectionMode,
    required this.selectedSupersetIds,
    required this.onOpenSupersetSelection,
    required this.onCancelSupersetSelection,
    required this.onToggleSupersetSelection,
    required this.onCreateSupersetFromSelection,
    required this.onRemoveFromSuperset,
    required this.onReorderWithinSuperset,
    required this.onSelect,
    required this.onReorder,
    required this.onRemove,
    required this.onDuplicate,
    required this.onAddExercise,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final int? selectedIndex;
  final bool isSupersetSelectionMode;
  final Set<String> selectedSupersetIds;
  final VoidCallback onOpenSupersetSelection;
  final VoidCallback onCancelSupersetSelection;
  final ValueChanged<String> onToggleSupersetSelection;
  final VoidCallback onCreateSupersetFromSelection;
  final ValueChanged<String> onRemoveFromSuperset;
  final void Function(String exerciseDraftId, int newOrder)
  onReorderWithinSuperset;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.exercisesLabel} (${exercises.length})',
              style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
            ),
            GestureDetector(
              onTap: isSupersetSelectionMode
                  ? onCancelSupersetSelection
                  : onOpenSupersetSelection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    isSupersetSelectionMode
                        ? OutlinedSvgAssets.xMark
                        : OutlinedSvgAssets.link,
                    width: AppSizing.iconXs,
                    height: AppSizing.iconXs,
                    colorFilter: ColorFilter.mode(
                      cs.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wXxs,
                  Text(
                    isSupersetSelectionMode
                        ? AppStrings.cancelSelection
                        : AppStrings.createSuperset,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        _ExerciseListView(
          exercises: exercises,
          selectedIndex: selectedIndex,
          isSupersetSelectionMode: isSupersetSelectionMode,
          selectedSupersetIds: selectedSupersetIds,
          onToggleSupersetSelection: onToggleSupersetSelection,
          onRemoveFromSuperset: onRemoveFromSuperset,
          onReorderWithinSuperset: onReorderWithinSuperset,
          onSelect: onSelect,
          onReorder: onReorder,
          onRemove: onRemove,
          onDuplicate: onDuplicate,
        ),
        AppWhiteSpace.hMd,
        _AddExerciseButton(onTap: onAddExercise),
        if (isSupersetSelectionMode) ...[
          AppWhiteSpace.hMd,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: selectedSupersetIds.length >= 2
                  ? onCreateSupersetFromSelection
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: cs.secondaryContainer,
                foregroundColor: cs.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.link,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  cs.onSecondaryContainer,
                  BlendMode.srcIn,
                ),
              ),
              label: Text(
                '${AppStrings.groupedExercises} (${selectedSupersetIds.length} Selected)',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseListView extends StatelessWidget {
  const _ExerciseListView({
    required this.exercises,
    required this.selectedIndex,
    required this.isSupersetSelectionMode,
    required this.selectedSupersetIds,
    required this.onToggleSupersetSelection,
    required this.onRemoveFromSuperset,
    required this.onReorderWithinSuperset,
    required this.onSelect,
    required this.onReorder,
    required this.onRemove,
    required this.onDuplicate,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final int? selectedIndex;
  final bool isSupersetSelectionMode;
  final Set<String> selectedSupersetIds;
  final ValueChanged<String> onToggleSupersetSelection;
  final ValueChanged<String> onRemoveFromSuperset;
  final void Function(String exerciseDraftId, int newOrder)
  onReorderWithinSuperset;
  final ValueChanged<int> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDuplicate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    if (exercises.isEmpty) {
      return Center(
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
              AppWhiteSpace.hXs,
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
      );
    }

    // Build display items: each is either a superset group or a standalone exercise
    final processedGroups = <String>{};
    final displayKeys = <String>[];
    final displayFirstExerciseIndex = <int>[];
    final displayItemCounts = <int>[];

    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final groupId = exercise.supersetGroupId;

      if (groupId != null) {
        if (processedGroups.contains(groupId)) continue;
        processedGroups.add(groupId);
        displayKeys.add('superset_$groupId');
        displayFirstExerciseIndex.add(i);
        var count = 0;
        for (var j = i; j < exercises.length; j++) {
          if (exercises[j].supersetGroupId == groupId) count++;
        }
        displayItemCounts.add(count);
      } else {
        displayKeys.add(exercise.id);
        displayFirstExerciseIndex.add(i);
        displayItemCounts.add(1);
      }
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayKeys.length,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) =>
          Material(color: Colors.transparent, child: child),
      onReorderItem: (oldDisplayIndex, newDisplayIndex) {
        final oldFirstIndex = displayFirstExerciseIndex[oldDisplayIndex];
        final oldCount = displayItemCounts[oldDisplayIndex];

        int newFirstIndex;
        if (newDisplayIndex >= displayKeys.length) {
          newFirstIndex = exercises.length - oldCount;
        } else if (newDisplayIndex > oldDisplayIndex) {
          newFirstIndex =
              displayFirstExerciseIndex[newDisplayIndex] +
              displayItemCounts[newDisplayIndex] -
              oldCount;
        } else {
          newFirstIndex = displayFirstExerciseIndex[newDisplayIndex];
        }

        if (oldCount == 1) {
          onReorder(oldFirstIndex, newFirstIndex);
        } else if (newFirstIndex > oldFirstIndex) {
          for (var k = oldCount - 1; k >= 0; k--) {
            onReorder(oldFirstIndex + k, newFirstIndex + k);
          }
        } else if (newFirstIndex < oldFirstIndex) {
          for (var k = 0; k < oldCount; k++) {
            onReorder(oldFirstIndex + k, newFirstIndex + k);
          }
        }
      },
      itemBuilder: (context, displayIndex) {
        final key = displayKeys[displayIndex];
        final firstIndex = displayFirstExerciseIndex[displayIndex];
        final exercise = exercises[firstIndex];

        if (exercise.supersetGroupId != null) {
          // Build group members
          final groupMembers = <WorkoutBuilderExerciseDraft>[];
          final memberIndices = <int>[];
          for (var j = firstIndex; j < exercises.length; j++) {
            if (exercises[j].supersetGroupId == exercise.supersetGroupId) {
              groupMembers.add(exercises[j]);
              memberIndices.add(j);
            }
          }

          return Padding(
            key: ValueKey(key),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SupersetGroupWidget(
              exercises: groupMembers,
              memberIndices: memberIndices,
              displayIndex: displayIndex,
              selectedIndex: selectedIndex,
              isSupersetSelectionMode: isSupersetSelectionMode,
              selectedSupersetIds: selectedSupersetIds,
              onToggleSupersetSelection: onToggleSupersetSelection,
              onRemoveFromSuperset: onRemoveFromSuperset,
              onReorderWithinSuperset: onReorderWithinSuperset,
              onSelect: onSelect,
              onReorder: onReorder,
              onRemove: onRemove,
              onDuplicate: onDuplicate,
            ),
          );
        }

        final isSelected = selectedIndex == firstIndex;
        return Padding(
          key: ValueKey(key),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _MiniExerciseCard(
            exercise: exercise,
            index: firstIndex,
            displayIndex: displayIndex,
            isSelected: isSelected,
            isSupersetSelectionMode: isSupersetSelectionMode,
            isSelectedForSuperset: selectedSupersetIds.contains(exercise.id),
            onToggleSupersetSelection: () =>
                onToggleSupersetSelection(exercise.id),
            onSelect: () => onSelect(firstIndex),
            onRemove: () => onRemove(exercise.id),
            onDuplicate: () => onDuplicate(exercise.id),
          ),
        );
      },
    );
  }
}

class _SupersetGroupWidget extends StatelessWidget {
  const _SupersetGroupWidget({
    required this.exercises,
    required this.memberIndices,
    required this.displayIndex,
    required this.selectedIndex,
    required this.isSupersetSelectionMode,
    required this.selectedSupersetIds,
    required this.onToggleSupersetSelection,
    required this.onRemoveFromSuperset,
    required this.onReorderWithinSuperset,
    required this.onSelect,
    required this.onReorder,
    required this.onRemove,
    required this.onDuplicate,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final List<int> memberIndices;
  final int displayIndex;
  final int? selectedIndex;
  final bool isSupersetSelectionMode;
  final Set<String> selectedSupersetIds;
  final ValueChanged<String> onToggleSupersetSelection;
  final ValueChanged<String> onRemoveFromSuperset;
  final void Function(String exerciseDraftId, int newOrder)
  onReorderWithinSuperset;
  final ValueChanged<int> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDuplicate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    // Sort group members by supersetOrder for correct display
    final sortedIndices = List.generate(exercises.length, (i) => i)
      ..sort(
        (a, b) => (exercises[a].supersetOrder ?? a).compareTo(
          exercises[b].supersetOrder ?? b,
        ),
      );
    final sortedExercises = sortedIndices.map((i) => exercises[i]).toList();
    final sortedMemberIndices = sortedIndices
        .map((i) => memberIndices[i])
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              right: AppSpacing.md - AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: cs.secondary,
                  width: 2 * AppSizing.strokeWidth,
                ),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.defaultRadius),
                bottomRight: Radius.circular(AppRadius.defaultRadius),
              ),
              color: cs.secondaryContainer.withValues(alpha: 0.03),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppBadge(
                          label: AppStrings.superset.toUpperCase(),
                          backgroundColor: cs.secondaryContainer,
                          foregroundColor: cs.onSecondaryContainer,
                          borderRadius: AppRadius.full,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + AppSpacing.xxs,
                            vertical: AppSpacing.xxs,
                          ),
                          textStyle: AppTextStyles.headlineXl.copyWith(
                            fontSize: AppFontSizes.xxs,
                            letterSpacing: -0.3,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: displayIndex,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                          ),
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
                  ...sortedExercises.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final exercise = entry.value;
                    final globalIndex = sortedMemberIndices[idx];
                    final isSelected = selectedIndex == globalIndex;
                    final isFirst = idx == 0;
                    final isLast = idx == sortedExercises.length - 1;
                    return _MiniExerciseCard(
                      key: ValueKey(exercise.id),
                      exercise: exercise,
                      index: globalIndex,
                      isSelected: isSelected,
                      isSupersetSelectionMode: isSupersetSelectionMode,
                      isSelectedForSuperset: selectedSupersetIds.contains(
                        exercise.id,
                      ),
                      onToggleSupersetSelection: () =>
                          onToggleSupersetSelection(exercise.id),
                      isInSupersetGroup: true,
                      isFirstInGroup: isFirst,
                      isLastInGroup: isLast,
                      onMoveUp: isFirst
                          ? null
                          : () => onReorderWithinSuperset(
                              exercise.id,
                              exercise.supersetOrder! - 1,
                            ),
                      onMoveDown: isLast
                          ? null
                          : () => onReorderWithinSuperset(
                              exercise.id,
                              exercise.supersetOrder! + 1,
                            ),
                      onRemoveFromSuperset: () =>
                          onRemoveFromSuperset(exercise.id),
                      onSelect: () => onSelect(globalIndex),
                      onRemove: () => onRemove(exercise.id),
                      onDuplicate: () => onDuplicate(exercise.id),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniExerciseCard extends StatelessWidget {
  const _MiniExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    this.displayIndex,
    required this.isSelected,
    required this.isSupersetSelectionMode,
    required this.isSelectedForSuperset,
    required this.onToggleSupersetSelection,
    required this.onSelect,
    required this.onRemove,
    required this.onDuplicate,
    this.isInSupersetGroup = false,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemoveFromSuperset,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final int index;
  final int? displayIndex;
  final bool isSelected;
  final bool isSupersetSelectionMode;
  final bool isSelectedForSuperset;
  final VoidCallback onToggleSupersetSelection;
  final VoidCallback onSelect;
  final VoidCallback onRemove;
  final VoidCallback onDuplicate;
  final bool isInSupersetGroup;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemoveFromSuperset;

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

    final effectiveBorderColor =
        isSupersetSelectionMode && isSelectedForSuperset
        ? cs.secondary
        : isSelected
        ? cs.secondary
        : cs.outlineVariant;
    final effectiveBorderWidth =
        (isSupersetSelectionMode && isSelectedForSuperset) || isSelected
        ? 2.0
        : 1.0;
    final effectiveShadow = isSupersetSelectionMode && isSelectedForSuperset
        ? [
            BoxShadow(
              color: cs.secondary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : isSelected
        ? [
            BoxShadow(
              color: cs.secondary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : null;

    final isInSuperset = exercise.supersetGroupId != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: isSupersetSelectionMode && !isInSuperset
            ? onToggleSupersetSelection
            : onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            border: Border.all(
              color: effectiveBorderColor,
              width: effectiveBorderWidth,
            ),
            boxShadow: effectiveShadow,
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
                        AppWhiteSpace.hXxs,
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
                  if (isSupersetSelectionMode && !isInSuperset)
                    Container(
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelectedForSuperset
                            ? cs.secondary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelectedForSuperset
                              ? cs.secondary
                              : cs.outlineVariant,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isSelectedForSuperset
                          ? Icon(
                              Icons.check,
                              size: AppSizing.iconSm - 2,
                              color: cs.onSecondary,
                            )
                          : null,
                    )
                  else if (isSelected)
                    _ExerciseMenu(
                      onDuplicate: onDuplicate,
                      onDelete: onRemove,
                      onRemoveFromSuperset: onRemoveFromSuperset,
                    )
                  else if (!isInSupersetGroup)
                    ReorderableDragStartListener(
                      index: displayIndex ?? index,
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
                  if (isInSupersetGroup &&
                      !isSupersetSelectionMode &&
                      !isSelected) ...[
                    AppWhiteSpace.hXxs,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onMoveUp != null)
                          GestureDetector(
                            onTap: onMoveUp,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xxs),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: SvgPicture.asset(
                                OutlinedSvgAssets.chevronUp,
                                width: AppSizing.iconXs + 2,
                                height: AppSizing.iconXs + 2,
                                colorFilter: ColorFilter.mode(
                                  cs.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        if (onMoveDown != null)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs),
                            child: GestureDetector(
                              onTap: onMoveDown,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.xxs),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  OutlinedSvgAssets.chevronDown,
                                  width: AppSizing.iconXs + 2,
                                  height: AppSizing.iconXs + 2,
                                  colorFilter: ColorFilter.mode(
                                    cs.onSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              AppWhiteSpace.hSm,
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
                  AppWhiteSpace.wXs,
                  Text(
                    '$setCount sets',
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected ? cs.secondary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (summary != null) ...[
                    AppWhiteSpace.wXs,
                    Text(
                      '•',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? cs.secondary.withValues(alpha: 0.5)
                            : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    AppWhiteSpace.wXs,
                    Text(
                      summary,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? cs.secondary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (restSec != null) ...[
                    AppWhiteSpace.wXs,
                    Text(
                      '•',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? cs.secondary.withValues(alpha: 0.5)
                            : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    AppWhiteSpace.wXs,
                    SvgPicture.asset(
                      OutlinedSvgAssets.clock,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        isSelected ? cs.secondary : cs.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wXxs,
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
  const _ExerciseMenu({
    required this.onDuplicate,
    required this.onDelete,
    this.onRemoveFromSuperset,
  });

  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback? onRemoveFromSuperset;

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
          case 'removeFromSuperset':
            onRemoveFromSuperset?.call();
        }
      },
      color: cs.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      itemBuilder: (context) => [
        if (onRemoveFromSuperset != null)
          PopupMenuItem(
            value: 'removeFromSuperset',
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.linkSlash,
                  width: AppSizing.iconXs,
                  height: AppSizing.iconXs,
                  colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
                ),
                AppWhiteSpace.wSm,
                Text(
                  AppStrings.removeFromSuperset,
                  style: AppTextStyles.labelSm.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ),
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
              AppWhiteSpace.wSm,
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
              AppWhiteSpace.wSm,
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
        foregroundPainter: DashedBorderPainter(
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
              AppWhiteSpace.wSm,
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
            AppWhiteSpace.hMd,
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
            size: AppSizing.iconSm,
          ),
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.exercise.name,
                style: AppTextStyles.headlineMd.copyWith(
                  color: cs.onSurface,
                  fontSize: AppFontSizes.xl,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppWhiteSpace.hXxs,
              Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (exercise.supersetGroupId != null)
                    AppBadge(
                      label: AppStrings.superset.toUpperCase(),
                      backgroundColor: cs.secondaryContainer,
                      foregroundColor: cs.onSecondaryContainer,
                      borderRadius: AppRadius.sm,
                    ),
                  Text(
                    AppStrings.configLabel.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
            AppWhiteSpace.custom(width: AppSizing.handleWidth),
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
        AppWhiteSpace.hSm,
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
                AppWhiteSpace.wXs,
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
                  child: AppTextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.sm,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 36,
                  child: AppTextField(
                    controller: _repsController,
                    keyboardType: TextInputType.text,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.sm,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: AppTextField(
                    controller: _targetController,
                    hintText: AppStrings.rpeHint,
                    keyboardType: TextInputType.text,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.sm,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 36,
                  child: AppTextField(
                    controller: _restController,
                    keyboardType: TextInputType.number,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.sm,
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurface,
                      fontSize: AppFontSizes.sm,
                    ),
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
          AppWhiteSpace.hSm,
          AppTextField(
            controller: _controller,
            hintText: AppStrings.coachNotesHint,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
