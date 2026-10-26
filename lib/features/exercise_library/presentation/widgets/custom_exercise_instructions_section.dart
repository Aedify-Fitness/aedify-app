import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Keeps optional instructions editable as free text or an ordered cue list.
class CustomExerciseInstructionsSection extends StatefulWidget {
  const CustomExerciseInstructionsSection({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
    this.enabled = true,
    this.validationErrors = const [],
  });

  final List<String> steps;
  final VoidCallback onAddStep;
  final void Function(int index, String value) onUpdateStep;
  final ValueChanged<int> onRemoveStep;
  final bool enabled;
  final List<CustomExerciseValidationError> validationErrors;

  @override
  State<CustomExerciseInstructionsSection> createState() =>
      _CustomExerciseInstructionsSectionState();
}

class _CustomExerciseInstructionsSectionState
    extends State<CustomExerciseInstructionsSection> {
  late final TextEditingController _textController;
  late List<String> _latestSteps;
  late bool _showCueList;

  @override
  void initState() {
    super.initState();
    _latestSteps = [...widget.steps];
    _showCueList = widget.steps.length > 1;
    _textController = TextEditingController(text: widget.steps.join('\n'));
  }

  @override
  void didUpdateWidget(CustomExerciseInstructionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(_latestSteps, widget.steps)) return;
    _latestSteps = [...widget.steps];
    if (!_showCueList) _syncText(widget.steps.join('\n'));
  }

  void _syncText(String text) {
    if (_textController.text == text) return;
    final selection = _textController.selection;
    _textController.value = TextEditingValue(
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

  void _updateText(String value) {
    if (!widget.enabled) return;
    final previousCount = _latestSteps.length;
    final hasText = value.trim().isNotEmpty;
    _latestSteps = hasText ? [value] : [];
    if (!hasText) {
      for (var index = previousCount - 1; index >= 0; index--) {
        widget.onRemoveStep(index);
      }
      return;
    }
    if (previousCount == 0) widget.onAddStep();
    for (var index = previousCount - 1; index > 0; index--) {
      widget.onRemoveStep(index);
    }
    widget.onUpdateStep(0, value);
  }

  void _addStep() {
    if (!widget.enabled) return;
    _latestSteps = [..._latestSteps, ''];
    widget.onAddStep();
  }

  void _updateStep(int index, String value) {
    if (!widget.enabled) return;
    _latestSteps = [..._latestSteps]..[index] = value;
    widget.onUpdateStep(index, value);
  }

  void _removeStep(int index) {
    if (!widget.enabled) return;
    _latestSteps = [..._latestSteps]..removeAt(index);
    widget.onRemoveStep(index);
  }

  void _switchToCueList() {
    if (!widget.enabled) return;
    final normalized = _textController.text
        .split(RegExp(r'\r?\n'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    final previousCount = _latestSteps.length;
    _latestSteps = normalized;
    for (var index = previousCount - 1; index >= 0; index--) {
      widget.onRemoveStep(index);
    }
    for (var index = 0; index < normalized.length; index++) {
      widget.onAddStep();
      widget.onUpdateStep(index, normalized[index]);
    }
    setState(() => _showCueList = true);
  }

  void _switchToText() {
    if (!widget.enabled) return;
    _syncText(_latestSteps.join('\n'));
    setState(() => _showCueList = false);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.validationErrors
        .where((error) => error.scope == CustomExerciseValidationScope.steps)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                AppStrings.customExerciseInstructionsLabel,
                style: CustomExerciseEditorStyle.heading(context),
              ),
            ),
            Text(
              AppStrings.customExerciseInstructionsOptional,
              style: CustomExerciseEditorStyle.caption(context),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        if (_showCueList)
          CustomExerciseStepsEditor(
            steps: _latestSteps,
            enabled: widget.enabled,
            validationErrors: errors,
            onAddStep: _addStep,
            onUpdateStep: _updateStep,
            onRemoveStep: _removeStep,
            onSwitchToText: _switchToText,
          )
        else ...[
          Material(
            key: const Key('custom_exercise_instructions_surface'),
            color: CustomExerciseEditorStyle.panel(context),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AppTextField(
              key: const Key('custom_exercise_instructions_text_field'),
              controller: _textController,
              enabled: widget.enabled,
              minLines: 6,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              hintText: AppStrings.customExerciseInstructionsHint,
              style: CustomExerciseEditorStyle.body(context),
              onChanged: _updateText,
              filled: false,
              borderOverride: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          for (final error in errors)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  error.message,
                  style: CustomExerciseEditorStyle.small(
                    context,
                  ).copyWith(color: context.colorScheme.error),
                ),
              ),
            ),
          AppWhiteSpace.hSm,
          TextButton(
            key: const Key('custom_exercise_add_cue_list'),
            onPressed: widget.enabled ? _switchToCueList : null,
            style: TextButton.styleFrom(
              foregroundColor: CustomExerciseEditorStyle.accent(context),
              disabledForegroundColor: context.colorScheme.onSurfaceVariant,
              minimumSize: const Size.fromHeight(
                AppCustomExerciseEditorTokens.controlSize,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.buttonVertical,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.listBullet,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    widget.enabled
                        ? CustomExerciseEditorStyle.accent(context)
                        : context.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.customExerciseAddCueList,
                    style: CustomExerciseEditorStyle.label(context).copyWith(
                      color: widget.enabled
                          ? CustomExerciseEditorStyle.accent(context)
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
