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
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
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
        title: Text(
          mode == CustomExerciseEditorMode.create
              ? AppStrings.createCustomExercise
              : AppStrings.editCustomExercise,
        ),
        actions: [
          if (mode == CustomExerciseEditorMode.edit)
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
              tooltip: AppStrings.customExerciseDeleted,
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xl,
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
                      AppWhiteSpace.hXl,
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
                      AppWhiteSpace.hXl,
                      _EquipmentDifficultySection(
                        equipment: state.draft.equipment,
                        onEquipmentChanged: (value) =>
                            controller.setEquipment(value),
                        difficulty: state.draft.difficulty,
                        onDifficultyChanged: (value) =>
                            controller.setDifficulty(value),
                      ),
                      AppWhiteSpace.hXl,
                      CustomExerciseModalitySection(
                        modality: state.draft.modality,
                        onChanged: (value) => controller.setModality(value),
                      ),
                      AppWhiteSpace.hXl,
                      _InstructionsSection(
                        steps: state.draft.steps,
                        onAddStep: () => controller.addStep(),
                        onUpdateStep: (index, value) =>
                            controller.updateStep(index: index, value: value),
                        onRemoveStep: (index) => controller.removeStep(index),
                      ),
                      AppWhiteSpace.hXl,
                      CustomExerciseLoggingTypePicker(
                        selected: state.draft.loggingType,
                        onChanged: (value) => controller.setLoggingType(value),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        onPressed: state.isSaving
                            ? null
                            : () => controller.save(),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.secondary,
                          foregroundColor: context.colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.inputVertical,
                          ),
                          minimumSize: const Size.fromHeight(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 6,
                          shadowColor: context.colorScheme.secondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        child: state.isSaving
                            ? const SizedBox(
                                width: AppSpacing.lg,
                                height: AppSpacing.lg,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSizing.strokeWidth,
                                  color: Colors.white,
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: Text(
                                  mode == CustomExerciseEditorMode.create
                                      ? AppStrings.createExercise
                                      : AppStrings.save,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: context.colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                      ),
                      AppWhiteSpace.hMd,
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colorScheme.onSurfaceVariant,
                          backgroundColor:
                              context.colorScheme.surfaceContainerLowest,
                          side: BorderSide(
                            color: context.colorScheme.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.inputVertical,
                          ),
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
                            style: AppTextStyles.headlineMd.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isDirty)
                PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (didPop) return;
                    showDialog(
                      context: context,
                      builder: (_) => DiscardCustomExerciseChangesDialog(
                        onDiscard: () {
                          controller.discardChanges();
                          context.pop();
                          context.pop();
                        },
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
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
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
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
        AppWhiteSpace.hSm,
        Container(
          decoration: BoxDecoration(
            color: _isFocused
                ? cs.surfaceContainerLowest
                : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: TextField(
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
                vertical: AppSpacing.inputVertical,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                AppStrings.customExerciseEquipment.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            AppWhiteSpace.hSm,
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EquipmentTag>(
                  value: equipment,
                  isExpanded: true,
                  hint: Text(
                    AppStrings.customExerciseEquipmentSelect,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  items: [
                    ...EquipmentTag.values.map(
                      (tag) => DropdownMenuItem<EquipmentTag>(
                        value: tag,
                        child: Text(
                          _formatLabel(tag.dbValue),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: onEquipmentChanged,
                  style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
                  dropdownColor: cs.surfaceContainerLowest,
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.chevronDown,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
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
            AppWhiteSpace.hSm,
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: ExerciseDifficulty.values.map((d) {
                  return _DifficultySegment(
                    label: _formatLabel(d.dbValue),
                    isSelected: difficulty == d,
                    onTap: () => onDifficultyChanged(d),
                  );
                }).toList(),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.buttonVertical,
          ),
          decoration: BoxDecoration(
            color: isSelected ? cs.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      offset: const Offset(0, AppSpacing.xxs),
                      blurRadius: AppSpacing.sm,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(
              fontSize: AppFontSizes.xs,
              color: isSelected ? cs.secondary : cs.onSurfaceVariant,
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
  TextEditingController? _textareaController;
  bool _textareaCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.steps.isEmpty) {
      _textareaController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(_InstructionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length == 1 &&
        oldWidget.steps.isEmpty &&
        !_textareaCreated) {
      _textareaCreated = true;
    }
  }

  void _switchToText() {
    for (var i = widget.steps.length - 1; i >= 0; i--) {
      widget.onRemoveStep(i);
    }
    setState(() {
      _textareaCreated = false;
    });
  }

  @override
  void dispose() {
    _textareaController?.dispose();
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
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                AppStrings.customExerciseInstructionsLabel.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            AppBadge(
              label: AppStrings.customExerciseInstructionsOptional,
              backgroundColor: cs.surfaceContainerLow,
              foregroundColor: cs.outline,
              textStyle: AppTextStyles.labelSm,
            ),
          ],
        ),
        AppWhiteSpace.hSm,
        if (widget.steps.isEmpty)
          _buildTextarea(cs)
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

  Widget _buildTextarea(ColorScheme cs) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: TextField(
            controller: _textareaController,
            maxLines: 6,
            minLines: 6,
            decoration: InputDecoration(
              hintText: AppStrings.customExerciseInstructionsHint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.inputVertical,
                bottom: AppSpacing.xxl,
              ),
            ),
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurface),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: (value) {
              if (value.isNotEmpty && !_textareaCreated) {
                _textareaCreated = true;
                widget.onAddStep();
              }
              if (_textareaCreated) {
                widget.onUpdateStep(0, value);
              }
            },
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: GestureDetector(
            onTap: () {
              if (!_textareaCreated) {
                _textareaCreated = true;
                widget.onAddStep();
                widget.onUpdateStep(0, _textareaController?.text ?? '');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.04),
                    offset: const Offset(0, AppSpacing.xxs),
                    blurRadius: AppSpacing.sm,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                OutlinedSvgAssets.listBullet,
                height: AppSizing.iconS,
                colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
