import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_error_banner.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_logging_type_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/delete_custom_exercise_dialog.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/discard_custom_exercise_changes_dialog.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CustomExerciseEditorScreen extends ConsumerWidget {
  const CustomExerciseEditorScreen.create({super.key})
    : mode = CustomExerciseEditorMode.create,
      exerciseId = null;

  const CustomExerciseEditorScreen.edit({super.key, required this.exerciseId})
    : mode = CustomExerciseEditorMode.edit;

  final CustomExerciseEditorMode mode;
  final int? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.customExerciseEditorControllerProvider((
        mode: mode,
        exerciseId: exerciseId,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        actions: mode == CustomExerciseEditorMode.create
            ? null
            : [
                IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.trash,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DeleteCustomExerciseDialog(
                        onConfirm: () {
                          ref
                              .read(
                                AppProviders.customExerciseEditorControllerProvider(
                                  (mode: mode, exerciseId: exerciseId),
                                ).notifier,
                              )
                              .delete();
                        },
                      ),
                    );
                  },
                  tooltip: AppStrings.customExerciseDelete,
                ),
              ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.customExerciseLoadFailed,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge,
                ),
                AppWhiteSpace.hMd,
                FilledButton(
                  onPressed: () => ref.invalidate(
                    AppProviders.customExerciseEditorControllerProvider((
                      mode: mode,
                      exerciseId: exerciseId,
                    )),
                  ),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          if (state.phase == CustomExerciseEditorPhase.saved) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      OutlinedSvgAssets.checkBadge,
                      width: AppSpacing.xxl,
                      height: AppSpacing.xxl,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    Text(
                      AppStrings.customExerciseSaved,
                      style: AppTextStyles.headlineMd,
                    ),
                    AppWhiteSpace.hLg,
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(
                          AppProviders.customExerciseEditorControllerProvider((
                            mode: CustomExerciseEditorMode.create,
                            exerciseId: null,
                          )),
                        );
                        context.pop(true);
                      },
                      child: const Text(AppStrings.done),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.phase == CustomExerciseEditorPhase.deleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pop(true);
              }
            });
            return const SizedBox.shrink();
          }

          final controller = ref.read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: mode,
              exerciseId: exerciseId,
            )).notifier,
          );
          final editorProvider =
              AppProviders.customExerciseEditorControllerProvider((
                mode: mode,
                exerciseId: exerciseId,
              ));

          void closeEditor() {
            context.pop();
            ref.invalidate(editorProvider);
          }

          Future<void> confirmDiscard() async {
            final shouldDiscard = await showDialog<bool>(
              context: context,
              builder: (_) => DiscardCustomExerciseChangesDialog(
                onDiscard: controller.discardChanges,
              ),
            );
            if (shouldDiscard == true && context.mounted) {
              closeEditor();
            }
          }

          return PopScope(
            canPop: !state.isDirty,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || !state.isDirty) return;
              await confirmDiscard();
            },
            child: SingleChildScrollView(
              key: const Key('custom_exercise_editor_scroll'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizing.customExerciseEditorMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.phase == CustomExerciseEditorPhase.failure &&
                          state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CustomExerciseErrorBanner(
                            message: state.errorMessage!,
                            onRetry: () => controller.save(),
                          ),
                        ),
                      if (state.hasValidationErrors)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CustomExerciseErrorBanner(
                            message: AppStrings.customExerciseMissingFields,
                          ),
                        ),
                      _ExerciseNameField(
                        initialValue: state.draft.name,
                        onChanged: (value) => controller.rename(value),
                        errorText: state.validationErrors
                            .where(
                              (e) =>
                                  e.scope == CustomExerciseValidationScope.name,
                            )
                            .map((e) => e.message)
                            .firstOrNull,
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      CustomExerciseMuscleGroupPicker(
                        selected: state.draft.muscleGroups,
                        onToggle: (bucket) =>
                            controller.toggleMuscleGroup(bucket),
                        errorText: state.validationErrors
                            .where(
                              (e) =>
                                  e.scope ==
                                  CustomExerciseValidationScope.muscleGroups,
                            )
                            .map((e) => e.message)
                            .firstOrNull,
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      _EquipmentDifficultySection(
                        equipment: state.draft.equipment,
                        onEquipmentChanged: (value) =>
                            controller.setEquipment(value),
                        difficulty: state.draft.difficulty,
                        onDifficultyChanged: (value) =>
                            controller.setDifficulty(value),
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      CustomExerciseModalitySection(
                        modality: state.draft.modality,
                        onChanged: (value) => controller.setModality(value),
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      _InstructionsSection(
                        steps: state.draft.steps,
                        onAddStep: () => controller.addStep(),
                        onUpdateStep: (index, value) =>
                            controller.updateStep(index: index, value: value),
                        onRemoveStep: (index) => controller.removeStep(index),
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      CustomExerciseLoggingTypePicker(
                        selected: state.draft.loggingType,
                        onChanged: (value) => controller.setLoggingType(value),
                      ),
                      AppWhiteSpace.hFormSectionGap,
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: _EditorActions(
                          mode: mode,
                          isSaving: state.isSaving,
                          onSave: () => controller.save(),
                          onDiscard: state.isDirty
                              ? confirmDiscard
                              : closeEditor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.mode,
    required this.isSaving,
    required this.onSave,
    required this.onDiscard,
  });

  final CustomExerciseEditorMode mode;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      key: const Key('custom_exercise_editor_actions'),
      children: [
        FilledButton(
          key: const Key('custom_exercise_primary_action'),
          onPressed: isSaving ? null : onSave,
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondary,
            foregroundColor: cs.onSecondary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: AppSizing.customExerciseActionElevation,
            shadowColor: cs.secondary.withValues(alpha: 0.3),
          ),
          child: isSaving
              ? SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizing.strokeWidth,
                    color: cs.onSecondary,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: Text(
                    mode == CustomExerciseEditorMode.create
                        ? AppStrings.createExercise
                        : AppStrings.save,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(
                      color: cs.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        AppWhiteSpace.hMd,
        OutlinedButton(
          key: const Key('custom_exercise_discard_action'),
          onPressed: onDiscard,
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.onSurfaceVariant,
            backgroundColor: cs.surfaceContainerLowest,
            side: BorderSide(color: cs.outlineVariant),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            minimumSize: const Size.fromHeight(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              AppStrings.customExerciseDiscard,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseNameField extends StatefulWidget {
  const _ExerciseNameField({
    required this.initialValue,
    required this.onChanged,
    this.errorText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_ExerciseNameField> createState() => _ExerciseNameFieldState();
}

class _ExerciseNameFieldState extends State<_ExerciseNameField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(_ExerciseNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == oldWidget.initialValue ||
        _controller.text == widget.initialValue) {
      return;
    }

    final currentValue = _controller.value;
    final newText = widget.initialValue;
    final selection = currentValue.selection;
    final baseOffset = selection.baseOffset < 0
        ? 0
        : selection.baseOffset > newText.length
        ? newText.length
        : selection.baseOffset;
    final extentOffset = selection.extentOffset < 0
        ? 0
        : selection.extentOffset > newText.length
        ? newText.length
        : selection.extentOffset;
    final composing =
        currentValue.composing.isValid &&
            currentValue.composing.end <= newText.length
        ? currentValue.composing
        : TextRange.empty;

    _controller.value = currentValue.copyWith(
      text: newText,
      selection: selection.isValid
          ? TextSelection(
              baseOffset: baseOffset,
              extentOffset: extentOffset,
              affinity: selection.affinity,
              isDirectional: selection.isDirectional,
            )
          : TextSelection.collapsed(offset: newText.length),
      composing: composing,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            AppStrings.customExerciseNameLabel.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        AppWhiteSpace.hControlGap,
        AnimatedContainer(
          key: const Key('custom_exercise_name_field_surface'),
          duration: AppDurations.formFocus,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isFocused
                ? cs.surfaceContainerLowest
                : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, AppSpacing.xs),
                      blurRadius: AppSizing.customExerciseInputFocusBlur,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            key: const Key('custom_exercise_name_text_field'),
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: AppStrings.customExerciseNameHintPlaceholder,
              hintStyle: AppTextStyles.bodyLg.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.formFieldVertical,
              ),
              isDense: false,
            ),
            style: AppTextStyles.bodyLg.copyWith(color: cs.onSurface),
            onTapOutside: (_) => _focusNode.unfocus(),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
            ),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.labelSm.copyWith(color: cs.error),
            ),
          ),
      ],
    );
  }
}

class _EquipmentDifficultySection extends StatelessWidget {
  const _EquipmentDifficultySection({
    required this.equipment,
    required this.onEquipmentChanged,
    required this.difficulty,
    required this.onDifficultyChanged,
  });

  final EquipmentTag? equipment;
  final ValueChanged<EquipmentTag?> onEquipmentChanged;
  final ExerciseDifficulty? difficulty;
  final ValueChanged<ExerciseDifficulty?> onDifficultyChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EquipmentSelector(equipment: equipment, onChanged: onEquipmentChanged),
        AppWhiteSpace.hLg,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                AppStrings.customExerciseDifficulty.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            AppWhiteSpace.hControlGap,
            Container(
              key: const Key('custom_exercise_difficulty_control'),
              padding: const EdgeInsets.all(AppSpacing.inputHorizontal),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Stack(
                children: [
                  if (difficulty != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedAlign(
                          key: const Key(
                            'custom_exercise_difficulty_sliding_indicator',
                          ),
                          alignment: _difficultyAlignment(difficulty!),
                          duration: AppDurations.segmentedControl,
                          curve: Curves.easeOutCubic,
                          child: FractionallySizedBox(
                            widthFactor: 1 / ExerciseDifficulty.values.length,
                            heightFactor: 1,
                            child: DecoratedBox(
                              key: const Key(
                                'custom_exercise_difficulty_sliding_thumb',
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.shadow.withValues(alpha: 0.04),
                                    offset: const Offset(0, AppSpacing.xxs),
                                    blurRadius: AppSpacing.sm,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: ExerciseDifficulty.values.map((d) {
                      return _DifficultySegment(
                        label: _formatLabel(d.dbValue),
                        isSelected: difficulty == d,
                        onTap: () => onDifficultyChanged(d),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  AlignmentGeometry _difficultyAlignment(ExerciseDifficulty difficulty) {
    final index = ExerciseDifficulty.values.indexOf(difficulty);
    final lastIndex = ExerciseDifficulty.values.length - 1;
    return AlignmentGeometry.lerp(
      AlignmentDirectional.centerStart,
      AlignmentDirectional.centerEnd,
      index / lastIndex,
    )!;
  }
}

class _EquipmentSelector extends StatefulWidget {
  const _EquipmentSelector({required this.equipment, required this.onChanged});

  final EquipmentTag? equipment;
  final ValueChanged<EquipmentTag?> onChanged;

  @override
  State<_EquipmentSelector> createState() => _EquipmentSelectorState();
}

class _EquipmentSelectorState extends State<_EquipmentSelector> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            AppStrings.customExerciseEquipment.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        AppWhiteSpace.hControlGap,
        Focus(
          onFocusChange: (isFocused) {
            if (_isFocused == isFocused) return;
            setState(() => _isFocused = isFocused);
          },
          child: AnimatedContainer(
            key: const Key('custom_exercise_equipment_control'),
            duration: AppDurations.formFocus,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _isFocused
                  ? cs.surfaceContainerLowest
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: cs.secondary.withValues(alpha: 0.08),
                        offset: const Offset(0, AppSpacing.xs),
                        blurRadius: AppSizing.customExerciseInputFocusBlur,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<EquipmentTag>(
                value: widget.equipment,
                isExpanded: true,
                hint: Text(
                  AppStrings.customExerciseEquipmentSelect,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                items: EquipmentTag.values
                    .map(
                      (tag) => DropdownMenuItem<EquipmentTag>(
                        value: tag,
                        child: Text(
                          _formatLabel(tag.dbValue),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.onChanged,
                style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
                dropdownColor: cs.surfaceContainerLowest,
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.chevronDown,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    cs.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _DifficultySegment extends StatelessWidget {
  const _DifficultySegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.buttonVertical,
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.segmentedControl,
              curve: Curves.easeOutCubic,
              style: AppTextStyles.labelMd.copyWith(
                fontSize: AppFontSizes.xs,
                color: isSelected ? cs.secondary : cs.onSurfaceVariant,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionsSection extends StatefulWidget {
  const _InstructionsSection({
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
  });

  final List<String> steps;
  final VoidCallback onAddStep;
  final void Function(int index, String value) onUpdateStep;
  final ValueChanged<int> onRemoveStep;

  @override
  State<_InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<_InstructionsSection> {
  late final TextEditingController _textareaController;
  late bool _showCueList;
  late bool _hasTextStep;

  @override
  void initState() {
    super.initState();
    _showCueList = widget.steps.length > 1;
    _hasTextStep = widget.steps.isNotEmpty;
    _textareaController = TextEditingController(text: widget.steps.join('\n'));
  }

  @override
  void didUpdateWidget(_InstructionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps.isEmpty && widget.steps.isNotEmpty) {
      _hasTextStep = true;
    }
  }

  void _updateText(String value) {
    if (value.trim().isEmpty) {
      if (_hasTextStep) {
        for (var index = widget.steps.length - 1; index >= 0; index--) {
          widget.onRemoveStep(index);
        }
        _hasTextStep = false;
      }
      return;
    }

    if (!_hasTextStep) {
      widget.onAddStep();
      _hasTextStep = true;
    }
    for (var index = widget.steps.length - 1; index > 0; index--) {
      widget.onRemoveStep(index);
    }
    widget.onUpdateStep(0, value);
  }

  List<String> _normalizedTextareaSteps() {
    return _textareaController.text
        .split(RegExp(r'\r?\n'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList(growable: false);
  }

  void _switchToCueList() {
    final normalizedSteps = _normalizedTextareaSteps();
    for (var index = widget.steps.length - 1; index >= 0; index--) {
      widget.onRemoveStep(index);
    }
    for (var index = 0; index < normalizedSteps.length; index++) {
      widget.onAddStep();
      widget.onUpdateStep(index, normalizedSteps[index]);
    }
    _hasTextStep = normalizedSteps.isNotEmpty;
    setState(() => _showCueList = true);
  }

  void _switchToText() {
    _textareaController.text = widget.steps.join('\n');
    _textareaController.selection = TextSelection.collapsed(
      offset: _textareaController.text.length,
    );
    _hasTextStep = widget.steps.isNotEmpty;
    setState(() {
      _showCueList = false;
    });
  }

  @override
  void dispose() {
    _textareaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Text(
                  AppStrings.customExerciseInstructionsLabel.toUpperCase(),
                  style: AppTextStyles.labelMd.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            AppWhiteSpace.wSm,
            Text(
              AppStrings.customExerciseInstructionsOptional,
              style: AppTextStyles.labelSm.copyWith(color: cs.outline),
            ),
          ],
        ),
        AppWhiteSpace.hControlGap,
        if (!_showCueList)
          _InstructionsTextArea(
            controller: _textareaController,
            onChanged: _updateText,
            onCueList: _switchToCueList,
          )
        else
          CustomExerciseStepsEditor(
            steps: widget.steps,
            onAddStep: widget.onAddStep,
            onUpdateStep: widget.onUpdateStep,
            onRemoveStep: widget.onRemoveStep,
            onSwitchToText: _switchToText,
          ),
      ],
    );
  }
}

class _InstructionsTextArea extends StatefulWidget {
  const _InstructionsTextArea({
    required this.controller,
    required this.onChanged,
    required this.onCueList,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCueList;

  @override
  State<_InstructionsTextArea> createState() => _InstructionsTextAreaState();
}

class _InstructionsTextAreaState extends State<_InstructionsTextArea> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (_isFocused == _focusNode.hasFocus) return;
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Stack(
      children: [
        AnimatedContainer(
          key: const Key('custom_exercise_instructions_surface'),
          duration: AppDurations.formFocus,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isFocused
                ? cs.surfaceContainerLowest
                : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, AppSpacing.xs),
                      blurRadius: AppSizing.customExerciseInputFocusBlur,
                    ),
                  ]
                : null,
          ),
          child: AppTextField(
            key: const Key('custom_exercise_instructions_text_field'),
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: 6,
            minLines: 6,
            hintText: AppStrings.customExerciseInstructionsHint,
            filled: false,
            borderOverride: InputBorder.none,
            contentPadding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.formFieldVertical,
              bottom: AppSpacing.xxl,
            ),
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
            onChanged: widget.onChanged,
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: Semantics(
            button: true,
            label: AppStrings.customExerciseAddCueList,
            child: Tooltip(
              message: AppStrings.customExerciseAddCueList,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: AppSizing.cardBadge,
                  minHeight: AppSizing.cardBadge,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      offset: const Offset(0, AppSpacing.xxs),
                      blurRadius: AppSpacing.sm,
                    ),
                  ],
                ),
                child: Material(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  child: InkWell(
                    key: const Key('custom_exercise_add_cue_list'),
                    onTap: widget.onCueList,
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        OutlinedSvgAssets.listBullet,
                        height: AppSizing.iconS,
                        colorFilter: ColorFilter.mode(
                          cs.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
