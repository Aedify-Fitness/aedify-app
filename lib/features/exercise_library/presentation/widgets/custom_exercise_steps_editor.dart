import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Edits optional, ordered cues without resetting active text selections.
class CustomExerciseStepsEditor extends StatefulWidget {
  const CustomExerciseStepsEditor({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
    this.onSwitchToText,
    this.enabled = true,
    this.validationErrors = const [],
  });

  final List<String> steps;
  final VoidCallback onAddStep;
  final void Function(int index, String value) onUpdateStep;
  final ValueChanged<int> onRemoveStep;
  final VoidCallback? onSwitchToText;
  final bool enabled;
  final List<CustomExerciseValidationError> validationErrors;

  @override
  State<CustomExerciseStepsEditor> createState() =>
      _CustomExerciseStepsEditorState();
}

class _CustomExerciseStepsEditorState extends State<CustomExerciseStepsEditor> {
  late final List<_StepEntry> _entries;
  final List<_StepEntry> _retiredEntries = [];
  int? _requestedRemoval;

  @override
  void initState() {
    super.initState();
    _entries = widget.steps.map(_StepEntry.new).toList();
  }

  @override
  void didUpdateWidget(CustomExerciseStepsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length < _entries.length) {
      final removedCount = _entries.length - widget.steps.length;
      final requested = _requestedRemoval;
      final removedIndex =
          requested != null &&
              removedCount == 1 &&
              requested < oldWidget.steps.length &&
              listEquals([
                for (var index = 0; index < oldWidget.steps.length; index++)
                  if (index != requested) oldWidget.steps[index],
              ], widget.steps)
          ? requested
          : _firstChangedIndex(oldWidget.steps, widget.steps);
      for (var index = 0; index < removedCount; index++) {
        _retire(_entries.removeAt(removedIndex));
      }
    } else if (widget.steps.length > _entries.length) {
      final addedCount = widget.steps.length - _entries.length;
      final addedIndex = _firstChangedIndex(oldWidget.steps, widget.steps);
      for (var offset = 0; offset < addedCount; offset++) {
        _entries.insert(
          addedIndex + offset,
          _StepEntry(widget.steps[addedIndex + offset]),
        );
      }
    }
    _requestedRemoval = null;
    for (var index = 0; index < widget.steps.length; index++) {
      _entries[index].sync(widget.steps[index]);
    }
  }

  int _firstChangedIndex(List<String> previous, List<String> current) {
    var index = 0;
    while (index < previous.length &&
        index < current.length &&
        previous[index] == current[index]) {
      index++;
    }
    return index;
  }

  void _retire(_StepEntry entry) {
    _retiredEntries.add(entry);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_retiredEntries.remove(entry)) entry.dispose();
    });
  }

  void _removeStep(int index) {
    if (!widget.enabled) return;
    _requestedRemoval = index;
    widget.onRemoveStep(index);
  }

  @override
  void dispose() {
    for (final entry in [..._entries, ..._retiredEntries]) {
      entry.dispose();
    }
    _retiredEntries.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddStep =
        widget.enabled &&
        (widget.steps.isEmpty || widget.steps.last.trim().isNotEmpty);
    final errors = widget.validationErrors
        .where((error) => error.scope == CustomExerciseValidationScope.steps)
        .toList();
    return Column(
      key: const Key('custom_exercise_cue_list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.steps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              AppStrings.customExerciseNoSteps,
              style: CustomExerciseEditorStyle.small(context),
            ),
          ),
        for (var index = 0; index < widget.steps.length; index++)
          Padding(
            key: ObjectKey(_entries[index]),
            padding: const EdgeInsets.only(bottom: AppSpacing.controlGap),
            child: Material(
              color: CustomExerciseEditorStyle.panel(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.controlGap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.exerciseStepLabel(index + 1),
                            style: CustomExerciseEditorStyle.label(context),
                          ),
                        ),
                        AppWhiteSpace.wSm,
                        IconButton(
                          key: Key('custom_exercise_step_remove_$index'),
                          onPressed: widget.enabled
                              ? () => _removeStep(index)
                              : null,
                          tooltip: AppStrings.customExerciseRemoveStep,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(
                              AppCustomExerciseEditorTokens.controlSize,
                            ),
                          ),
                          icon: SvgPicture.asset(
                            OutlinedSvgAssets.trash,
                            width: AppSizing.iconSm,
                            height: AppSizing.iconSm,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppWhiteSpace.hSm,
                    AppTextField(
                      key: ObjectKey(_entries[index].controller),
                      controller: _entries[index].controller,
                      enabled: widget.enabled,
                      hintText: AppStrings.customExerciseStepHint,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 2,
                      maxLines: 6,
                      borderRadius: AppRadius.md,
                      style: CustomExerciseEditorStyle.body(context),
                      fillColor: context.colorScheme.surfaceContainerLow,
                      onChanged: (value) => widget.onUpdateStep(index, value),
                    ),
                    for (final error in errors.where(
                      (error) => error.stepIndex == index,
                    ))
                      _StepError(message: error.message),
                  ],
                ),
              ),
            ),
          ),
        for (final error in errors.where((error) => error.stepIndex == null))
          _StepError(message: error.message),
        _InstructionAction(
          key: const Key('custom_exercise_add_step'),
          label: AppStrings.customExerciseAddStep,
          asset: OutlinedSvgAssets.plusCircle,
          onPressed: canAddStep ? widget.onAddStep : null,
        ),
        if (widget.onSwitchToText != null) ...[
          AppWhiteSpace.hXs,
          _InstructionAction(
            key: const Key('custom_exercise_use_text'),
            label: AppStrings.customExerciseUseText,
            asset: OutlinedSvgAssets.bars3BottomLeft,
            onPressed: widget.enabled ? widget.onSwitchToText : null,
          ),
        ],
      ],
    );
  }
}

class _StepEntry {
  _StepEntry(String text) : controller = TextEditingController(text: text);

  final TextEditingController controller;

  void sync(String text) {
    if (controller.text == text) return;
    final selection = controller.selection;
    controller.value = TextEditingValue(
      text: text,
      selection: selection.isValid
          ? TextSelection(
              baseOffset: selection.baseOffset.clamp(0, text.length),
              extentOffset: selection.extentOffset.clamp(0, text.length),
              affinity: selection.affinity,
              isDirectional: selection.isDirectional,
            )
          : TextSelection.collapsed(offset: text.length),
    );
  }

  void dispose() => controller.dispose();
}

class _InstructionAction extends StatelessWidget {
  const _InstructionAction({
    super.key,
    required this.label,
    required this.asset,
    required this.onPressed,
  });

  final String label;
  final String asset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(
          AppCustomExerciseEditorTokens.controlSize,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.buttonVertical,
        ),
        foregroundColor: CustomExerciseEditorStyle.accent(context),
        disabledForegroundColor: context.colorScheme.onSurfaceVariant,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            asset,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              onPressed == null
                  ? context.colorScheme.onSurfaceVariant
                  : CustomExerciseEditorStyle.accent(context),
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              label,
              style: CustomExerciseEditorStyle.label(context).copyWith(
                color: onPressed == null
                    ? context.colorScheme.onSurfaceVariant
                    : CustomExerciseEditorStyle.accent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepError extends StatelessWidget {
  const _StepError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: CustomExerciseEditorStyle.small(
            context,
          ).copyWith(color: context.colorScheme.error),
        ),
      ),
    );
  }
}
